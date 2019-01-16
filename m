Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 336458E0006
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:59:43 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so4309772pgv.23
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:59:43 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d18si6701527pgm.212.2019.01.16.09.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:59:41 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv4 07/13] node: Add heterogenous memory access attributes
Date: Wed, 16 Jan 2019 10:57:58 -0700
Message-Id: <20190116175804.30196-8-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-1-keith.busch@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Heterogeneous memory systems provide memory nodes with different latency
and bandwidth performance attributes. Provide a new kernel interface for
subsystems to register the attributes under the memory target node's
initiator access class. If the system provides this information, applications
may query these attributes when deciding which node to request memory.

The following example shows the new sysfs hierarchy for a node exporting
performance attributes:

  # tree -P "read*|write*" /sys/devices/system/node/nodeY/classZ/
  /sys/devices/system/node/nodeY/classZ/
  |-- read_bandwidth
  |-- read_latency
  |-- write_bandwidth
  `-- write_latency

The bandwidth is exported as MB/s and latency is reported in nanoseconds.
Memory accesses from an initiator node that is not one of the memory's
class "Z" initiator nodes may encounter different performance than
reported here. When a subsystem makes use of this interface, initiators
of a lower class number, "Z", have better performance relative to higher
class numbers. When provided, class 0 is the highest performing access
class.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/base/Kconfig |  8 ++++++++
 drivers/base/node.c  | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/node.h | 25 +++++++++++++++++++++++++
 3 files changed, 81 insertions(+)

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
index 1da5072116ab..1e909f61e8b1 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -66,6 +66,9 @@ struct node_class_nodes {
 	unsigned		class;
 	nodemask_t		initiator_nodes;
 	nodemask_t		target_nodes;
+#ifdef CONFIG_HMEM_REPORTING
+	struct node_hmem_attrs	hmem_attrs;
+#endif
 };
 #define to_class_nodes(dev) container_of(dev, struct node_class_nodes, dev)
 
@@ -145,6 +148,51 @@ static struct node_class_nodes *node_init_node_class(struct device *parent,
 	return NULL;
 }
 
+#ifdef CONFIG_HMEM_REPORTING
+#define ACCESS_ATTR(name) 						   \
+static ssize_t name##_show(struct device *dev,				   \
+			   struct device_attribute *attr,		   \
+			   char *buf)					   \
+{									   \
+	return sprintf(buf, "%u\n", to_class_nodes(dev)->hmem_attrs.name); \
+}									   \
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
+ATTRIBUTE_GROUPS(access);
+
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned class)
+{
+	struct node_class_nodes *c;
+	struct node *node;
+
+	if (WARN_ON_ONCE(!node_online(nid)))
+		return;
+
+	node = node_devices[nid];
+	c = node_init_node_class(&node->dev, &node->class_list, class);
+	if (!c)
+		return;
+
+	c->hmem_attrs = *hmem_attrs;
+	if (sysfs_create_groups(&c->dev.kobj, access_groups))
+		pr_info("failed to add performance attribute group to node %d\n",
+			nid);
+}
+#endif
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
diff --git a/include/linux/node.h b/include/linux/node.h
index 8e3666c12ef2..e22940a593c2 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -20,6 +20,31 @@
 #include <linux/list.h>
 #include <linux/workqueue.h>
 
+#ifdef CONFIG_HMEM_REPORTING
+/**
+ * struct node_hmem_attrs - heterogeneous memory performance attributes
+ *
+ * @read_bandwidth:	Read bandwidth in MB/s
+ * @write_bandwidth:	Write bandwidth in MB/s
+ * @read_latency:	Read latency in nanoseconds
+ * @write_latency:	Write latency in nanoseconds
+ */
+struct node_hmem_attrs {
+	unsigned int read_bandwidth;
+	unsigned int write_bandwidth;
+	unsigned int read_latency;
+	unsigned int write_latency;
+};
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned class);
+#else
+static inline void node_set_perf_attrs(unsigned int nid,
+				       struct node_hmem_attrs *hmem_attrs,
+				       unsigned class)
+{
+}
+#endif
+
 struct node {
 	struct device	dev;
 	struct list_head class_list;
-- 
2.14.4
