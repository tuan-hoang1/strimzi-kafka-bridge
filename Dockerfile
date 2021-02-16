FROM registry.access.redhat.com/ubi7:latest
ARG JAVA_VERSION=11

RUN yum -y update \
    && yum -y install java-${JAVA_VERSION}-openjdk-headless openssl \
    && yum -y clean all

# Set JAVA_HOME env var
ENV JAVA_HOME /usr/lib/jvm/java

# Add strimzi user with UID 1001
# The user is in the group 0 to have access to the mounted volumes and storage
RUN useradd -r -m -u 1001 -g 0 strimzi

ARG strimzi_kafka_bridge_version=1.0-SNAPSHOT
ENV STRIMZI_KAFKA_BRIDGE_VERSION ${strimzi_kafka_bridge_version}
ENV STRIMZI_HOME=/opt/strimzi
RUN mkdir -p ${STRIMZI_HOME}
WORKDIR ${STRIMZI_HOME}

COPY target/kafka-bridge-${strimzi_kafka_bridge_version}/kafka-bridge-${strimzi_kafka_bridge_version} ./

#####
# Add Tini
#####
ENV TINI_VERSION v0.18.0
ENV TINI_SHA256=c8aaa618ea7897f26979ea10920373e06f3e6dfeb41ef95342eda2eb5672f24d
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-s390x /usr/bin/tini
RUN echo "${TINI_SHA256} */usr/bin/tini" | sha256sum -c \
    && chmod +x /usr/bin/tini

USER 1001

CMD ["/opt/strimzi/bin/kafka_bridge_run.sh"]
