Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB4118E00A1
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:47:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so4583458pll.0
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:47:59 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c10si25675731pla.173.2019.01.09.09.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:47:58 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 04/13] node: Link memory nodes to their compute nodes
Date: Wed,  9 Jan 2019 10:43:32 -0700
Message-Id: <20190109174341.19818-5-keith.busch@intel.com>
In-Reply-To: <20190109174341.19818-1-keith.busch@intel.com>
References: <20190109174341.19818-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Systems may be constructed with various specialized nodes. Some nodes
may provide memory, some provide compute devices that access and use
that memory, and others may provide both. Nodes that provide memory are
referred to as memory targets, and nodes that can initiate memory access
are referred to as memory initiators.

Memory targets will often have varying access characteristics from
different initiators, and platforms may have ways to express those
relationships. In preparation for these systems, provide interfaces
for the kernel to export the memory relationship among different node's
memory targets and their initiators with symlinks to each other's nodes,
and export node lists showing the same relationship.

If a system provides access locality for each initiator-target pair, nodes
may be grouped into ranked access classes relative to other nodes. The new
interface allows a subsystem to register relationships of varying classes
if available and desired to be exported. A lower class number indicates
a higher performing tier, with 0 being the best performing class.

A memory initiator may have multiple memory targets in the same access
class. The initiator's memory targets in given class indicate the node's
access characteristics perform better relative to other initiator nodes
either unreported or in lower class numbers. The targets within an
initiator's class, though, do not necessarily perform the same as each
other.

A memory target node may have multiple memory initiators. All linked
initiators in a target's class have the same access characteristics as
each other to that target.

The following example show the nodes' new sysfs hierarchy for a memory
target node 'Y' with class 0 access from initiator node 'X':

  # symlinks -v /sys/devices/system/node/nodeX/class0/
  relative: /sys/devices/system/node/nodeX/class0/targetY -> ../../nodeY

  # symlinks -v /sys/devices/system/node/nodeY/class0/
  relative: /sys/devices/system/node/nodeY/class0/initiatorX -> ../../nodeX

And the same information is reflected in the nodelist:

  # cat /sys/devices/system/node/nodeX/class0/target_nodelist
  Y

  # cat /sys/devices/system/node/nodeY/class0/initiator_nodelist
  X

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/base/node.c  | 127 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/node.h |   6 ++-
 2 files changed, 131 insertions(+), 2 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..1da5072116ab 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -17,6 +17,7 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/device.h>
+#include <linux/pm_runtime.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
 
@@ -59,6 +60,91 @@ static inline ssize_t node_read_cpulist(struct device *dev,
 static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
+struct node_class_nodes {
+	struct device		dev;
+	struct list_head	list_node;
+	unsigned		class;
+	nodemask_t		initiator_nodes;
+	nodemask_t		target_nodes;
+};
+#define to_class_nodes(dev) container_of(dev, struct node_class_nodes, dev)
+
+static ssize_t initiator_nodelist_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct node_class_nodes *c = to_class_nodes(dev);
+	return scnprintf(buf, PAGE_SIZE - 1, "%*pbl\n",
+			 nodemask_pr_args(&c->initiator_nodes));
+}
+static DEVICE_ATTR_RO(initiator_nodelist);
+
+static ssize_t target_nodelist_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct node_class_nodes *c = to_class_nodes(dev);
+	return scnprintf(buf, PAGE_SIZE - 1, "%*pbl\n",
+			 nodemask_pr_args(&c->target_nodes));
+}
+static DEVICE_ATTR_RO(target_nodelist);
+
+static struct attribute *node_class_node_attrs[] = {
+	&dev_attr_initiator_nodelist.attr,
+	&dev_attr_target_nodelist.attr,
+	NULL,
+};
+ATTRIBUTE_GROUPS(node_class_node);
+
+static void node_remove_classes(struct node *node)
+{
+	struct node_class_nodes *c, *cnext;
+
+	list_for_each_entry_safe(c, cnext, &node->class_list, list_node) {
+		list_del(&c->list_node);
+		device_unregister(&c->dev);
+	}
+}
+
+static void node_class_release(struct device *dev)
+{
+	kfree(to_class_nodes(dev));
+}
+
+static struct node_class_nodes *node_init_node_class(struct device *parent,
+						     struct list_head *list,
+						     unsigned class)
+{
+	struct node_class_nodes *class_node;
+	struct device *dev;
+
+	list_for_each_entry(class_node, list, list_node)
+		if (class_node->class == class)
+			return class_node;
+
+	class_node = kzalloc(sizeof(*class_node), GFP_KERNEL);
+	if (!class_node)
+		return NULL;
+
+	class_node->class = class;
+	dev = &class_node->dev;
+	dev->parent = parent;
+	dev->release = node_class_release;
+	dev->groups = node_class_node_groups;
+	if (dev_set_name(dev, "class%u", class))
+		goto free;
+
+	if (device_register(dev))
+		goto free_name;
+
+	pm_runtime_no_callbacks(dev);
+	list_add_tail(&class_node->list_node, list);
+	return class_node;
+free_name:
+	kfree_const(dev->kobj.name);
+free:
+	kfree(class_node);
+	return NULL;
+}
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
@@ -340,7 +426,7 @@ static int register_node(struct node *node, int num)
 void unregister_node(struct node *node)
 {
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
-
+	node_remove_classes(node);
 	device_unregister(&node->dev);
 }
 
@@ -372,6 +458,44 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 				 kobject_name(&node_devices[nid]->dev.kobj));
 }
 
+int register_memory_node_under_compute_node(unsigned int m, unsigned int p,
+					    unsigned class)
+{
+	struct node *init, *targ;
+	struct node_class_nodes *i, *t;
+	char initiator[20]; /* "initiator4294967295\0" */
+	char target[17];    /* "target4294967295\0" */
+	int ret;
+
+	if (!node_online(p) || !node_online(m))
+		return -ENODEV;
+
+	init = node_devices[p];
+	targ = node_devices[m];
+	i = node_init_node_class(&init->dev, &init->class_list, class);
+	t = node_init_node_class(&targ->dev, &targ->class_list, class);
+	if (!i || !t)
+		return -ENOMEM;
+
+	snprintf(initiator, sizeof(initiator), "initiator%u", p);
+	snprintf(target, sizeof(target), "target%u", m);
+	ret = sysfs_create_link(&i->dev.kobj, &targ->dev.kobj, target);
+	if (ret)
+		return ret;
+
+	ret = sysfs_create_link(&t->dev.kobj, &init->dev.kobj, initiator);
+	if (ret)
+		goto err;
+
+	node_set(m, i->target_nodes);
+	node_set(p, t->initiator_nodes);
+	return 0;
+ err:
+	sysfs_remove_link(&node_devices[p]->dev.kobj,
+			  kobject_name(&node_devices[m]->dev.kobj));
+	return ret;
+}
+
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
 	struct device *obj;
@@ -580,6 +704,7 @@ int __register_one_node(int nid)
 			register_cpu_under_node(cpu, nid);
 	}
 
+	INIT_LIST_HEAD(&node_devices[nid]->class_list);
 	/* initialize work queue for memory hot plug */
 	init_node_hugetlb_work(nid);
 
diff --git a/include/linux/node.h b/include/linux/node.h
index 257bb3d6d014..8e3666c12ef2 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -17,11 +17,12 @@
 
 #include <linux/device.h>
 #include <linux/cpumask.h>
+#include <linux/list.h>
 #include <linux/workqueue.h>
 
 struct node {
 	struct device	dev;
-
+	struct list_head class_list;
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
 	struct work_struct	node_work;
 #endif
@@ -75,6 +76,9 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 					   unsigned long phys_index);
 
+extern int register_memory_node_under_compute_node(unsigned int m, unsigned int p,
+						   unsigned class);
+
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
 					 node_registration_func_t unregister);
-- 
2.14.4
