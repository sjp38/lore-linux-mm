Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E64788E006C
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:51 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id v72so8653714pgb.10
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:51 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:49 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 06/12] node: Add heterogenous memory performance
Date: Mon, 10 Dec 2018 18:03:04 -0700
Message-Id: <20181211010310.8551-7-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Heterogeneous memory systems provide memory nodes with different latency
and bandwidth performance attributes. Create an interface for the kernel
to register the attributes for the primary memory initiators under the
memory node. If the system provides this information, applications can
then query the node attributes when deciding which node to request memory.

The following example shows the new sysfs hierarchy for a node exporting
performance attributes:

  # tree /sys/devices/system/node/nodeY/primary_initiator_access
  /sys/devices/system/node/nodeY/primary_initiator_access
  |-- read_bandwidth
  |-- read_latency
  |-- write_bandwidth
  `-- write_latency

The bandwidth is exported as MB/s and latency is reported in nanoseconds.
Memory accesses from an initiator node that is not one of the memory's
primary compute nodes may encounter a performance penalty that does not
match the performance reported for primary memory initiators.

As an example of what you may be able to do with this, let's say we have
a PCIe storage device, /dev/nvme0n1, attached to a particular node, and
we want to run IO to it using the fastest memory with primary access
from the same node as that PCIe device. The following shell script is
such an example to achieve that goal:

  #!/bin/bash
  DEV_NODE=/sys/devices/system/node/node$(cat /sys/block/nvme0n1/device/device/numa_node)
  BEST_WRITE_BW=0
  BEST_MEM_NODE=0
  for i in $(ls -d ${DEV_NODE}/primary_target*); do
    tmp=$(cat ${i}/primary_initiator_access/write_bandwidth);
    if ((${tmp} > ${BEST_WRITE_BW})); then
      BEST_WRITE_BW=${tmp}
      BEST_MEM_NODE=$(echo ${i} | sed s/^.*primary_target//g)
    fi
  done

  numactl --membind=${BEST_MEM_NODE} \
    --cpunodebind=$(cat ${DEV_NODE}/primary_cpu_nodelist) \
    -- fio --filename=/dev/nvme0n1 --bs=4k --name=access-test

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/base/Kconfig |  8 ++++++++
 drivers/base/node.c  | 44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/node.h | 22 ++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 3e63a900b330..6014980238e8 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
 	  unusable. You should say N here unless you are explicitly looking to
 	  test this functionality.
 
+config HMEM_REPORTING
+	bool
+	default y
+	depends on NUMA
+	help
+	  Enable reporting for heterogenous memory access attributes under
+	  their non-uniform memory nodes.
+
 source "drivers/base/test/Kconfig"
 
 config SYS_HYPERVISOR
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 50412ce3fd7d..768612c06c56 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -99,6 +99,50 @@ static DEVICE_ATTR_RO(primary_cpu_nodelist);
 static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
+#ifdef CONFIG_HMEM_REPORTING
+const struct attribute_group node_access_attrs_group;
+
+#define ACCESS_ATTR(name) 						\
+static ssize_t name##_show(struct device *dev,				\
+			   struct device_attribute *attr,		\
+			   char *buf)					\
+{									\
+	return sprintf(buf, "%d\n", to_node(dev)->hmem_attrs.name);	\
+}									\
+static DEVICE_ATTR_RO(name);
+
+ACCESS_ATTR(read_bandwidth)
+ACCESS_ATTR(read_latency)
+ACCESS_ATTR(write_bandwidth)
+ACCESS_ATTR(write_latency)
+
+static struct attribute *access_attrs[] = {
+	&dev_attr_read_bandwidth.attr,
+	&dev_attr_read_latency.attr,
+	&dev_attr_write_bandwidth.attr,
+	&dev_attr_write_latency.attr,
+	NULL,
+};
+
+const struct attribute_group node_access_attrs_group = {
+	.name		= "primary_initiator_access",
+	.attrs		= access_attrs,
+};
+
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs)
+{
+	struct node *node;
+
+	if (WARN_ON_ONCE(!node_online(nid)))
+		return;
+	node = node_devices[nid];
+	node->hmem_attrs = *hmem_attrs;
+	if (sysfs_create_group(&node->dev.kobj, &node_access_attrs_group))
+		pr_info("failed to add performance attribute group to node %d\n",
+			nid);
+}
+#endif
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
diff --git a/include/linux/node.h b/include/linux/node.h
index 3d06de045cbf..71abaf0d4f4b 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -17,8 +17,27 @@
 
 #include <linux/device.h>
 #include <linux/cpumask.h>
+#include <linux/list.h>
 #include <linux/workqueue.h>
 
+#ifdef CONFIG_HMEM_REPORTING
+/**
+ * struct node_hmem_attrs - heterogeneous memory performance attributes
+ *
+ * read_bandwidth:	Read bandwidth in MB/s
+ * write_bandwidth:	Write bandwidth in MB/s
+ * read_latency:	Read latency in nanoseconds
+ * write_latency:	Write latency in nanoseconds
+ */
+struct node_hmem_attrs {
+	unsigned int read_bandwidth;
+	unsigned int write_bandwidth;
+	unsigned int read_latency;
+	unsigned int write_latency;
+};
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs);
+#endif
+
 struct node {
 	struct device	dev;
 	nodemask_t	primary_mem_nodes;
@@ -27,6 +46,9 @@ struct node {
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
 	struct work_struct	node_work;
 #endif
+#ifdef CONFIG_HMEM_REPORTING
+	struct node_hmem_attrs hmem_attrs;
+#endif
 };
 
 struct memory_block;
-- 
2.14.4
