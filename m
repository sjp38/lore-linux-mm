Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 686CB6B000E
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:53:05 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 3-v6so13032891plc.18
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:53:05 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l13-v6si29485562pls.222.2018.11.14.14.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 14:53:03 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 2/7] node: Add heterogenous memory performance
Date: Wed, 14 Nov 2018 15:49:15 -0700
Message-Id: <20181114224921.12123-3-keith.busch@intel.com>
In-Reply-To: <20181114224921.12123-2-keith.busch@intel.com>
References: <20181114224921.12123-2-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Heterogeneous memory systems provide memory nodes with latency
and bandwidth performance attributes that are different from other
nodes. Create an interface for the kernel to register these attributes
under the node that provides the memory. If the system provides this
information, applications can query the node attributes when deciding
which node to request memory.

When multiple memory initiators exist, accessing the same memory target
from each may not perform the same as the other. The highest performing
initiator to a given target is considered to be a local initiator for
that target. The kernel provides performance attributes only for the
local initiators.

The memory's compute node should be symlinked in sysfs as one of the
node's initiators.

The following example shows the new sysfs hierarchy for a node exporting
performance attributes:

  # tree /sys/devices/system/node/nodeY/initiator_access
  /sys/devices/system/node/nodeY/initiator_access
  |-- read_bandwidth
  |-- read_latency
  |-- write_bandwidth
  `-- write_latency

The bandwidth is exported as MB/s and latency is reported in nanoseconds.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/base/Kconfig |  8 ++++++++
 drivers/base/node.c  | 44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/node.h | 22 ++++++++++++++++++++++
 3 files changed, 74 insertions(+)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index ae213ed2a7c8..2cf67c80046d 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
 	  unusable. You should say N here unless you are explicitly looking to
 	  test this functionality.
 
+config HMEM
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
index a9b7512a9502..232535761998 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -59,6 +59,50 @@ static inline ssize_t node_read_cpulist(struct device *dev,
 static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
+#ifdef CONFIG_HMEM
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
+	.name		= "initiator_access",
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
index 1fd734a3fb3f..6a1aa6a153f8 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -17,14 +17,36 @@
 
 #include <linux/device.h>
 #include <linux/cpumask.h>
+#include <linux/list.h>
 #include <linux/workqueue.h>
 
+#ifdef CONFIG_HMEM
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
 
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
 	struct work_struct	node_work;
 #endif
+#ifdef CONFIG_HMEM
+	struct node_hmem_attrs hmem_attrs;
+#endif
 };
 
 struct memory_block;
-- 
2.14.4
