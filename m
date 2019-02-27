Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 845F7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35EBD2133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:50:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35EBD2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F1308E000A; Wed, 27 Feb 2019 17:50:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A6248E0004; Wed, 27 Feb 2019 17:50:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E78978E000A; Wed, 27 Feb 2019 17:50:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1CAA8E0004
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 17:50:35 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id y66so14373150pfg.16
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:50:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=17OD5DxVPEfXl7F6sLMWaqS7bcMAwEh9QfsaU/GPtRQ=;
        b=oFt3jiP+kEUDHGFd2a0OSgSo18D6LpCexUReXBgorNPl0Wu+PuEP502K36LdqL0dhP
         p9471hi6hy8UhZqrcJnF3VMjwVdF5jPWi8xHWyLTk1LmBNBsofLrUYYIleZgpxU8rXG7
         4KzeGVK2M97JKYWs6p2UKZGDyDgkOmV6i3uDkII+I4l3+UjpFkyxJeiGAAfbqUoPJTfG
         zWJWp9Ib6qzcTbws4NEPzkVVYAC+vWO4cDN/+wAzujPl/MILYgMg9agMWrPYAHu2vza3
         u9ZjKWSg8QiNJfcZEgKGHszsyMSbzGlNVD9cqWj6H6YzBZKqtETaZ5pujsjikvZ/RYc5
         D3cA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubOis1qybYBXneS3u3HEZCGzIra0DADs99EYELXAj6kap95BXLK
	iGhveOXyrykWuioSllLjfvLHCoEnFGvJE7y9QZe/IMi7CJe+j8L4FX6LOoYu3QJOHnS5HlD2WH3
	pekQiXqD/RC/zVfkDoUvmRP20wDVV5GA+Cfj0MsZyKRvhMwR0b/wlXPHl0krObKJvzQ==
X-Received: by 2002:a63:545:: with SMTP id 66mr5283391pgf.102.1551307835260;
        Wed, 27 Feb 2019 14:50:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaBDbAQnDO5ifrw5Hqr7aQtf9/XmlDog9kY4Lr/Ec4JecZaSzCFuVKs4KXiCmrFXGIKLE/4
X-Received: by 2002:a63:545:: with SMTP id 66mr5283271pgf.102.1551307833600;
        Wed, 27 Feb 2019 14:50:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551307833; cv=none;
        d=google.com; s=arc-20160816;
        b=0dgBH7fk2jclGa2LuSI006gZOqVfWVu4G7RMA78v3FRav/YR0Uwnw6XXJREyt0npri
         8p+qWiu1CbEvjGFJcYDPF3NZHKcIeUIHhU++qfruYU1uJfXI1UcMzLVqcYLbIzN/n4YW
         1yoOCbNT6HdbZm5DJS5KsU6PBUCEkfVJSKzK5djPFGlyP3o6tXaXXcoqUlKhpsN3VDkF
         9O21JILKTU/LFiPB8EVJ8IHllKluapyxRb4YdTdmSVwP4CSE4X98B7ApLtdiI+T1RddJ
         Ngb6t6MWI9pf8yKgFYMxcZXKawPLThHiA7PUpRMKIBTo8IqIH7mClp2Vx4/NnYqI4sqf
         3Q/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=17OD5DxVPEfXl7F6sLMWaqS7bcMAwEh9QfsaU/GPtRQ=;
        b=WrdVtr/ZoSBy3fIER2m/PuKuYU9eaVfFGLGWSFqD6E3KR9aaGFDgthzalgs7UESdFb
         JjG4dt12u85YBwROdW6C1GqSqiPmCeqDHpQmqTjLOp5xEIGY35Iq7abv9wnxbVebuobz
         Wye3V7hz3xRdGL3Q0CAL0BRXWVNSq0YfbwbZQQan7QxQ7Nt/DxdAqUzfl0N3e3mk1EYG
         jhZWRng/BPcqEgioe/GNW9MDSi6Ipsf9DRWZjTjhVwLr30SHTfrbQyStCUG4emPU/t1B
         E/hS0i3XYi2wVzTwFsN3kCpKPeWNsNE3XUWeVy+3qo/8HA2k1hOUlMNn/fv1Zy4Nw2/M
         mH8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id z20si10836901pgf.324.2019.02.27.14.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 14:50:33 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Feb 2019 14:50:33 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,420,1544515200"; 
   d="scan'208";a="121349415"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 27 Feb 2019 14:50:32 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv7 06/10] node: Add memory-side caching attributes
Date: Wed, 27 Feb 2019 15:50:34 -0700
Message-Id: <20190227225038.20438-7-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190227225038.20438-1-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

System memory may have caches to help improve access speed to frequently
requested address ranges. While the system provided cache is transparent
to the software accessing these memory ranges, applications can optimize
their own access based on cache attributes.

Provide a new API for the kernel to register these memory-side caches
under the memory node that provides it.

The new sysfs representation is modeled from the existing cpu cacheinfo
attributes, as seen from /sys/devices/system/cpu/<cpu>/cache/.  Unlike CPU
cacheinfo though, the node cache level is reported from the view of the
memory. A higher level number is nearer to the CPU, while lower levels
are closer to the last level memory.

The exported attributes are the cache size, the line size, associativity
indexing, and write back policy, and add the attributes for the system
memory caches to sysfs stable documentation.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node |  34 +++++++
 drivers/base/node.c                         | 151 ++++++++++++++++++++++++++++
 include/linux/node.h                        |  39 +++++++
 3 files changed, 224 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 41cb9345e1e0..970fef47e6cd 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -142,3 +142,37 @@ Contact:	Keith Busch <keith.busch@intel.com>
 Description:
 		This node's write latency in nanoseconds when access
 		from nodes found in this class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The directory containing attributes for the memory-side cache
+		level 'Y'.
+
+What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/indexing
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The caches associativity indexing: 0 for direct mapped,
+		non-zero if indexed.
+
+What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/line_size
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The number of bytes accessed from the next cache level on a
+		cache miss.
+
+What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/size
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The size of this memory side cache in bytes.
+
+What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/write_policy
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The cache write policy: 0 for write-back, 1 for write-through,
+		other or unknown.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 2de546a040a5..8598fcbd2a17 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -205,6 +205,155 @@ void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
 		}
 	}
 }
+
+/**
+ * struct node_cache_info - Internal tracking for memory node caches
+ * @dev:	Device represeting the cache level
+ * @node:	List element for tracking in the node
+ * @cache_attrs:Attributes for this cache level
+ */
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
+CACHE_ATTR(line_size, "%u")
+CACHE_ATTR(indexing, "%u")
+CACHE_ATTR(write_policy, "%u")
+
+static struct attribute *cache_attrs[] = {
+	&dev_attr_indexing.attr,
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
+	if (dev_set_name(dev, "memory_side_cache"))
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
+/**
+ * node_add_cache() - add cache attribute to a memory node
+ * @nid: Node identifier that has new cache attributes
+ * @cache_attrs: Attributes for the cache being added
+ */
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
@@ -489,6 +638,7 @@ void unregister_node(struct node *node)
 {
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
 	node_remove_accesses(node);
+	node_remove_caches(node);
 	device_unregister(&node->dev);
 }
 
@@ -781,6 +931,7 @@ int __register_one_node(int nid)
 	INIT_LIST_HEAD(&node_devices[nid]->access_list);
 	/* initialize work queue for memory hot plug */
 	init_node_hugetlb_work(nid);
+	node_init_caches(nid);
 
 	return error;
 }
diff --git a/include/linux/node.h b/include/linux/node.h
index 45e14e1e0c18..8fa350e01acc 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -35,10 +35,45 @@ struct node_hmem_attrs {
 	unsigned int write_latency;
 };
 
+enum cache_indexing {
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
+ * @indexing:		The ways memory blocks may be placed in cache
+ * @write_policy:	Write back or write through policy
+ * @size:		Total size of cache in bytes
+ * @line_size:		Number of bytes fetched on a cache miss
+ * @level:		The cache hierarchy level
+ */
+struct node_cache_attrs {
+	enum cache_indexing indexing;
+	enum cache_write_policy write_policy;
+	u64 size;
+	u16 line_size;
+	u8 level;
+};
+
 #ifdef CONFIG_HMEM_REPORTING
+void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs);
 void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
 			 unsigned access);
 #else
+static inline void node_add_cache(unsigned int nid,
+				  struct node_cache_attrs *cache_attrs)
+{
+} 
+
 static inline void node_set_perf_attrs(unsigned int nid,
 				       struct node_hmem_attrs *hmem_attrs,
 				       unsigned access)
@@ -52,6 +87,10 @@ struct node {
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

