if [ "" = "$1" ]; then
    echo ""
    echo "Error: This command need parameters to run!"
    echo ""
    echo "Param needed:"
    echo "ELASTIC_INDEX_NAME: Used to Identify the ClusterRegion of Openshift what will be monitored"
    echo ""
    echo "Command sintax:"
    echo "./configure-it.sh ELASTIC_INDEX_NAME"
else
    oc new-project monitoring
    oc project monitoring
    oc adm policy add-scc-to-user anyuid system:serviceaccount:monitoring:default
    oc create secret docker-registry registry --docker-server=PRIVATE_REGISTRY_NAME:4430 --docker-username="USERNAME" --docker-password="XX_PASSWORD_XX" --docker-email=PRIVATE_REGISTRY_EMAIL -n 
    oc secrets link --for=pull default registry -n monitoring
    ELASTIC_INDEX_NAME=$1
    cat metricbeat.yaml | sed 's@ELASTIC_INDEX_NAME@'"${ELASTIC_INDEX_NAME}"'@g' | oc create -f -
    oc secrets link --for=pull metricbeat  registry -n monitoring
    oc adm policy add-scc-to-user privileged system:serviceaccount:monitoring:metricbeat
    oc patch namespace monitoring -p '{"metadata": {"annotations": {"openshift.io/node-selector": ""}}}'
    oc -n monitoring  get ds/metricbeat
fi
