Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21D5D8E0082
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 18:08:28 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 74so5896718pfk.12
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 15:08:28 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id i7si24473410pgc.144.2019.01.24.15.08.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 15:08:26 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv5 06/10] node: Add heterogenous memory access attributes
Date: Thu, 24 Jan 2019 16:07:20 -0700
Message-Id: <20190124230724.10022-7-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
References: <20190124230724.10022-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Heterogeneous memory systems provide memory nodes with different latency
and bandwidth performance attributes. Provide a new kernel interface
for subsystems to register the attributes under the memory target
node's initiator access class. If the system provides this information,
applications may query these attributes when deciding which node to
request memory.

The following example shows the new sysfs hierarchy for a node exporting
performance attributes:

  # tree -P "read*|write*"/sys/devices/system/node/nodeY/accessZ/initiators/
  /sys/devices/system/node/nodeY/accessZ/initiators/
  |-- read_bandwidth
  |-- read_latency
  |-- write_bandwidth
  `-- write_latency

The bandwidth is exported as MB/s and latency is reported in
nanoseconds. The values are taken from the platform as reported by the
manufacturer.

Memory accesses from an initiator node that is not one of the memory's
access "Z" initiator nodes linked in the same directory may observe
different performance than reported here. When a subsystem makes use
of this interface, initiators of a different access number may not have
the same performance relative to initiators in other access numbers, or
omitted from the any access class' initiators.

Descriptions for memory access initiator performance access attributes
are added to sysfs stable documentation.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 28 ++++++++++++++
 drivers/base/Kconfig                        |  8 ++++
 drivers/base/node.c                         | 59 +++++++++++++++++++++++++++++
 include/linux/node.h                        | 19 ++++++++++
 4 files changed, 114 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index fb843222a281..41cb9345e1e0 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -114,3 +114,31 @@ Contact:	Keith Busch <keith.busch@intel.com>
 Description:
 		The directory containing symlinks to memory targets that
 		this initiator node has class "Y" access.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/read_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read bandwidth in MB/s when accessed from
+		nodes found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/read_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read latency in nanoseconds when accessed
+		from nodes found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/write_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write bandwidth in MB/s when accessed from
+		found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/write_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write latency in nanoseconds when access
+		from nodes found in this class's linked initiators.
diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 3e63a900b330..32dc81bd7056 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
 	  unusable. You should say N here unless you are explicitly looking to
 	  test this functionality.
 
+config HMEM_REPORTING
+	bool
+	default n
+	depends on NUMA
+	help
+	  Enable reporting for heterogenous memory access attributes under
+	  their non-uniform memory nodes.
+
 source "drivers/base/test/Kconfig"
 
 config SYS_HYPERVISOR
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 6f4097680580..2de546a040a5 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -71,6 +71,9 @@ struct node_access_nodes {
 	struct device		dev;
 	struct list_head	list_node;
 	unsigned		access;
+#ifdef CONFIG_HMEM_REPORTING
+	struct node_hmem_attrs	hmem_attrs;
+#endif
 };
 #define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
 
@@ -148,6 +151,62 @@ static struct node_access_nodes *node_init_node_access(struct node *node,
 	return NULL;
 }
 
+#ifdef CONFIG_HMEM_REPORTING
+#define ACCESS_ATTR(name) 						   \
+static ssize_t name##_show(struct device *dev,				   \
+			   struct device_attribute *attr,		   \
+			   char *buf)					   \
+{									   \
+	return sprintf(buf, "%u\n", to_access_nodes(dev)->hmem_attrs.name); \
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
+
+/**
+ * node_set_perf_attrs - Set the performance values for given access class
+ * @nid: Node identifier to be set
+ * @hmem_attrs: Heterogeneous memory performance attributes
+ * @access: The access class the for the given attributes
+ */
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned access)
+{
+	struct node_access_nodes *c;
+	struct node *node;
+	int i;
+
+	if (WARN_ON_ONCE(!node_online(nid)))
+		return;
+
+	node = node_devices[nid];
+	c = node_init_node_access(node, access);
+	if (!c)
+		return;
+
+	c->hmem_attrs = *hmem_attrs;
+	for (i = 0; access_attrs[i] != NULL; i++) {
+		if (sysfs_add_file_to_group(&c->dev.kobj, access_attrs[i],
+					    "initiators")) {
+			pr_info("failed to add performance attribute to node %d\n",
+				nid);
+			break;
+		}
+	}
+}
+#endif
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
diff --git a/include/linux/node.h b/include/linux/node.h
index f34688a203c1..2db077363d9c 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -20,6 +20,25 @@
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
+			 unsigned access);
+#endif
+
 struct node {
 	struct device	dev;
 	struct list_head access_list;
-- 
2.14.4
