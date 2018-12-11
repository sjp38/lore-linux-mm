Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2550F8E006F
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 20:05:54 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h11so11241000pfj.13
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 17:05:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i1si11402278pfj.276.2018.12.10.17.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 17:05:52 -0800 (PST)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCHv2 09/12] node: Add memory caching attributes
Date: Mon, 10 Dec 2018 18:03:07 -0700
Message-Id: <20181211010310.8551-10-keith.busch@intel.com>
In-Reply-To: <20181211010310.8551-1-keith.busch@intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

System memory may have side caches to help improve access speed. While
the system provided cache is transparent to the software accessing
these memory ranges, applications can optimize their own access based
on cache attributes.

Provide a new API for the kernel to register these memory side caches
under the memory node that provides it.

The kernel's sysfs representation is modeled from the cpu cacheinfo
attributes, as seen from /sys/devices/system/cpu/cpuX/side_cache/.
Unlike CPU cacheinfo, though, the node cache level is reported from
the view of the memory.  A higher number is nearer to the CPU, while
lower levels are closer to the backing memory. Also unlike CPU cache,
it is assumed the system will handle flushing any dirty cached memory to
the last level the memory on a power failure if the range is persistent
memory.

The attributes we export are the cache size, the line size, associativity,
and write back policy.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/base/node.c  | 140 +++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/node.h |  23 +++++++++
 2 files changed, 163 insertions(+)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 768612c06c56..54184424ca7f 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -17,6 +17,7 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/device.h>
+#include <linux/pm_runtime.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
 
@@ -141,6 +142,143 @@ void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs)
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
+#define CACHE_ATTR(name, fmt) 							\
+static ssize_t name##_show(struct device *dev,					\
+			   struct device_attribute *attr,			\
+			   char *buf)						\
+{										\
+	return sprintf(buf, fmt "\n", to_cache_info(dev)->cache_attrs.name);	\
+}										\
+DEVICE_ATTR_RO(name);
+
+CACHE_ATTR(size, "%lld")
+CACHE_ATTR(level, "%d")
+CACHE_ATTR(line_size, "%d")
+CACHE_ATTR(associativity, "%d")
+CACHE_ATTR(write_policy, "%d")
+
+static struct attribute *cache_attrs[] = {
+	&dev_attr_level.attr,
+	&dev_attr_associativity.attr,
+	&dev_attr_size.attr,
+	&dev_attr_line_size.attr,
+	&dev_attr_write_policy.attr,
+	NULL,
+};
+
+const struct attribute_group node_cache_attrs_group = {
+	.attrs = cache_attrs,
+};
+
+const struct attribute_group *node_cache_attrs_groups[] = {
+	&node_cache_attrs_group,
+	NULL,
+};
+
+static void node_release(struct device *dev)
+{
+	kfree(dev);
+}
+
+static void node_cache_release(struct device *dev)
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
+	dev->release = node_release;
+	dev_set_name(dev, "side_cache");
+
+	if (device_register(dev)) {
+		kfree(dev);
+		return;
+	}
+	pm_runtime_no_callbacks(dev);
+	node->cache_dev = dev;
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
+	dev->release = node_cache_release;
+	dev->groups = node_cache_attrs_groups;
+	dev_set_name(dev, "index%d", cache_attrs->level);
+	info->cache_attrs = *cache_attrs;
+	if (device_register(dev)) {
+		dev_warn(&node->dev, "failed to add cache level:%d\n",
+			 cache_attrs->level);
+		kfree(info);
+		return;
+	}
+	pm_runtime_no_callbacks(dev);
+	list_add_tail(&info->node, &node->cache_attrs);
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
@@ -389,6 +527,7 @@ static void node_device_release(struct device *dev)
 	 */
 	flush_work(&node->node_work);
 #endif
+	node_remove_caches(node);
 	kfree(node);
 }
 
@@ -711,6 +850,7 @@ int __register_one_node(int nid)
 
 	/* initialize work queue for memory hot plug */
 	init_node_hugetlb_work(nid);
+	node_init_caches(nid);
 
 	return error;
 }
diff --git a/include/linux/node.h b/include/linux/node.h
index 71abaf0d4f4b..897e04e99e80 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -36,6 +36,27 @@ struct node_hmem_attrs {
 	unsigned int write_latency;
 };
 void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs);
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
+struct node_cache_attrs {
+	enum cache_associativity associativity;
+	enum cache_write_policy write_policy;
+	u64 size;
+	u16 line_size;
+	u8  level;
+};
+void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs);
 #endif
 
 struct node {
@@ -48,6 +69,8 @@ struct node {
 #endif
 #ifdef CONFIG_HMEM_REPORTING
 	struct node_hmem_attrs hmem_attrs;
+	struct list_head cache_attrs;
+	struct device *cache_dev;
 #endif
 };
 
-- 
2.14.4
