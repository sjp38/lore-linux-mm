Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF7468E00A6
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 12:48:02 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t72so5722495pfi.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 09:48:02 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c10si25675731pla.173.2019.01.09.09.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 09:48:01 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv3 10/13] node: Add memory caching attributes
Date: Wed,  9 Jan 2019 10:43:38 -0700
Message-Id: <20190109174341.19818-11-keith.busch@intel.com>
In-Reply-To: <20190109174341.19818-1-keith.busch@intel.com>
References: <20190109174341.19818-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

System memory may have side caches to help improve access speed to
frequently requested address ranges. While the system provided cache is
transparent to the software accessing these memory ranges, applications
can optimize their own access based on cache attributes.

Provide a new API for the kernel to register these memory side caches
under the memory node that provides it.

The new sysfs representation is modeled from the existing cpu cacheinfo
attributes, as seen from /sys/devices/system/cpu/cpuX/side_cache/.
Unlike CPU cacheinfo, though, the node cache level is reported from
the view of the memory. A higher number is nearer to the CPU, while
lower levels are closer to the backing memory. Also unlike CPU cache,
it is assumed the system will handle flushing any dirty cached memory
to the last level on a power failure if the range is persistent memory.

The attributes we export are the cache size, the line size, associativity,
and write back policy.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/base/node.c  | 142 +++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/node.h |  39 ++++++++++++++
 2 files changed, 181 insertions(+)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 1e909f61e8b1..7ff3ed566d7d 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -191,6 +191,146 @@ void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
 		pr_info("failed to add performance attribute group to node %d\n",
 			nid);
 }
+
+struct node_cache_info {
+	struct device dev;
+	struct list_head node;
+	struct node_cache_attrs cache_attrs;
+};
+#define to_cache_info(device) container_of(device, struct node_cache_info, dev)
+
+#define CACHE_ATTR(name, fmt) 						\
+static ssize_t name##_show(struct device *dev,				\
+			   struct device_attribute *attr,		\
+			   char *buf)					\
+{									\
+	return sprintf(buf, fmt "\n", to_cache_info(dev)->cache_attrs.name);\
+}									\
+DEVICE_ATTR_RO(name);
+
+CACHE_ATTR(size, "%llu")
+CACHE_ATTR(level, "%u")
+CACHE_ATTR(line_size, "%u")
+CACHE_ATTR(associativity, "%u")
+CACHE_ATTR(write_policy, "%u")
+
+static struct attribute *cache_attrs[] = {
+	&dev_attr_level.attr,
+	&dev_attr_associativity.attr,
+	&dev_attr_size.attr,
+	&dev_attr_line_size.attr,
+	&dev_attr_write_policy.attr,
+	NULL,
+};
+ATTRIBUTE_GROUPS(cache);
+
+static void node_cache_release(struct device *dev)
+{
+	kfree(dev);
+}
+
+static void node_cacheinfo_release(struct device *dev)
+{
+	struct node_cache_info *info = to_cache_info(dev);
+	kfree(info);
+}
+
+static void node_init_cache_dev(struct node *node)
+{
+	struct device *dev;
+
+	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return;
+
+	dev->parent = &node->dev;
+	dev->release = node_cache_release;
+	if (dev_set_name(dev, "side_cache"))
+		goto free_dev;
+
+	if (device_register(dev))
+		goto free_name;
+
+	pm_runtime_no_callbacks(dev);
+	node->cache_dev = dev;
+	return;
+free_name:
+	kfree_const(dev->kobj.name);
+free_dev:
+	kfree(dev);
+}
+
+void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs)
+{
+	struct node_cache_info *info;
+	struct device *dev;
+	struct node *node;
+
+	if (!node_online(nid) || !node_devices[nid])
+		return;
+
+	node = node_devices[nid];
+	list_for_each_entry(info, &node->cache_attrs, node) {
+		if (info->cache_attrs.level == cache_attrs->level) {
+			dev_warn(&node->dev,
+				"attempt to add duplicate cache level:%d\n",
+				cache_attrs->level);
+			return;
+		}
+	}
+
+	if (!node->cache_dev)
+		node_init_cache_dev(node);
+	if (!node->cache_dev)
+		return;
+
+	info = kzalloc(sizeof(*info), GFP_KERNEL);
+	if (!info)
+		return;
+
+	dev = &info->dev;
+	dev->parent = node->cache_dev;
+	dev->release = node_cacheinfo_release;
+	dev->groups = cache_groups;
+	if (dev_set_name(dev, "index%d", cache_attrs->level))
+		goto free_cache;
+
+	info->cache_attrs = *cache_attrs;
+	if (device_register(dev)) {
+		dev_warn(&node->dev, "failed to add cache level:%d\n",
+			 cache_attrs->level);
+		goto free_name;
+	}
+	pm_runtime_no_callbacks(dev);
+	list_add_tail(&info->node, &node->cache_attrs);
+	return;
+free_name:
+	kfree_const(dev->kobj.name);
+free_cache:
+	kfree(info);
+}
+
+static void node_remove_caches(struct node *node)
+{
+	struct node_cache_info *info, *next;
+
+	if (!node->cache_dev)
+		return;
+
+	list_for_each_entry_safe(info, next, &node->cache_attrs, node) {
+		list_del(&info->node);
+		device_unregister(&info->dev);
+	}
+	device_unregister(node->cache_dev);
+}
+
+static void node_init_caches(unsigned int nid)
+{
+	INIT_LIST_HEAD(&node_devices[nid]->cache_attrs);
+}
+#else
+static void node_init_caches(unsigned int nid) { }
+static void node_remove_caches(struct node *node) { }
 #endif
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
@@ -475,6 +615,7 @@ void unregister_node(struct node *node)
 {
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
 	node_remove_classes(node);
+	node_remove_caches(node);
 	device_unregister(&node->dev);
 }
 
@@ -755,6 +896,7 @@ int __register_one_node(int nid)
 	INIT_LIST_HEAD(&node_devices[nid]->class_list);
 	/* initialize work queue for memory hot plug */
 	init_node_hugetlb_work(nid);
+	node_init_caches(nid);
 
 	return error;
 }
diff --git a/include/linux/node.h b/include/linux/node.h
index e22940a593c2..8cdf2b2808e4 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -37,12 +37,47 @@ struct node_hmem_attrs {
 };
 void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
 			 unsigned class);
+
+enum cache_associativity {
+	NODE_CACHE_DIRECT_MAP,
+	NODE_CACHE_INDEXED,
+	NODE_CACHE_OTHER,
+};
+
+enum cache_write_policy {
+	NODE_CACHE_WRITE_BACK,
+	NODE_CACHE_WRITE_THROUGH,
+	NODE_CACHE_WRITE_OTHER,
+};
+
+/**
+ * struct node_cache_attrs - system memory caching attributes
+ *
+ * @associativity:	The ways memory blocks may be placed in cache
+ * @write_policy:	Write back or write through policy
+ * @size:		Total size of cache in bytes
+ * @line_size:		Number of bytes fetched on a cache miss
+ * @level:		Represents the cache hierarchy level
+ */
+struct node_cache_attrs {
+	enum cache_associativity associativity;
+	enum cache_write_policy write_policy;
+	u64 size;
+	u16 line_size;
+	u8  level;
+};
+void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs);
 #else
 static inline void node_set_perf_attrs(unsigned int nid,
 				       struct node_hmem_attrs *hmem_attrs,
 				       unsigned class)
 {
 }
+
+static inline void node_add_cache(unsigned int nid,
+				  struct node_cache_attrs *cache_attrs)
+{
+}
 #endif
 
 struct node {
@@ -51,6 +86,10 @@ struct node {
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
 	struct work_struct	node_work;
 #endif
+#ifdef CONFIG_HMEM_REPORTING
+	struct list_head cache_attrs;
+	struct device *cache_dev;
+#endif
 };
 
 struct memory_block;
-- 
2.14.4
