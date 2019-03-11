Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB638C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ADBD214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ADBD214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C8A248E0002; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C38F58E0009; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9789A8E0002; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 595938E0009
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 73so132513pga.18
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=WexqlXIng2b0rfWkBcflY1F0Uo+DnA6o9DrpLS10oQI=;
        b=MKJaKEPmd93M38kaQOxmC8cIzr2exZLwwj7+HOMWvAM+XA8Me/9IiyNz7ac2J2zIS2
         jOYy2UNALWle2rn3JELvs5a3bltl76KdZuUOl1HsSVi2IA27W9BiHjMwjooBCZWsYhOA
         5j0NJf6i8/S/t1n/HuvWZOTdzkHo283cKsAjKP6RPOy4I9DdGVfnEjn5phefcn5St6gp
         i+NCvLJEyYjqATq6iIYXlJGAciVUALBl3ESWjcg+T+DZleO21Z4gq4Mxzud247ca1o7i
         ljhw9cyXD/CR2o8tB6J1x274qR0ifunYVWf3cZyNoddF8mht3Jf19kIKJ2fmY6Q5ke5V
         phfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUpaERZmZpQg1I0ZZkKsIa9JBNkvH4RIi510G/869Sjr1eNkAXV
	n5zeABui3GtuC+ceOv+iLN8EPQo5BJUwT8HWjsO4IfhdTL8rDI2XiKDyGOggqv+YDHq6d5cj6V5
	mM8jtVYo2NSnyi1pypxy8biIQHK9eTA9ZN+F8+Q+/LnJOWGKpGFs6GhybWxhnPwzaEA==
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr36215762plp.165.1552337744014;
        Mon, 11 Mar 2019 13:55:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzazqmqaVkBHIyb0/5fNSX2UMfrpq2tZ3q4RKYJhJL7AObfY3u1lU8Z6ftvvnOoBwKFajxy
X-Received: by 2002:a17:902:9893:: with SMTP id s19mr36215697plp.165.1552337742715;
        Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337742; cv=none;
        d=google.com; s=arc-20160816;
        b=mCN/vXAetEQsB1RaMRwoYVFQtxMStKgQgTvbQYzZUAgKvdQUbDvxZaDNn9vXQNWegr
         fhDpQCWORZ2IdAf6DF+vsbpQ99RIKiIJ/ReB+5yNAT0GwQNUHTpS45IFWp1gaUxsOZlw
         9XtZ1kkcdz/bsOOvii/rfkRKt0TjCpnXEZeOSU/ZxSkqM6wrxH5d9uhiuxYTfUhz2WPD
         u89lzkxVGvRUgR/4zQ/tVen+y2WOk/arr3N/+iloQeIPcJh/W+ENwFk58ijU9TWPevnJ
         15HCzg+yGfkGd2Wn560RJyNm6UQs5UrxgcSXqP6shlVb0Qp1jy5QTh5V9efMa72KWVfC
         OZMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=WexqlXIng2b0rfWkBcflY1F0Uo+DnA6o9DrpLS10oQI=;
        b=BKqh4PLW9A7ihMs+SeavXI4vt6OvfM97Cw4/AkKKgl8PpTUaw7CAfbbmk91C8z7X6T
         5OFDD1GCS2b5SovaY4v6/5ug2SJd+1DYqFqI18ytfoJMC3/kLLW56MLQtwS2GrQoAucX
         z0iJljG9bvIBgwamhqekj/KiQRGRe9Z3QsMpEBd3mopkyBJ3/I1JnVSqN7oVpeCesrBD
         8pPUu/vX29C+Qw+LIOhbaM4ABvl8iLQzei6uRXMCTEELpWXAhmATQwi/vGc5X1mpk7QP
         QUqntO75R2yuA4GxKONjMZ2Tpn/1tiym8jxLqZ0bQW256y5TRyG3c0+HZZJKSeoJfcQk
         FsvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910178"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:42 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv8 06/10] node: Add memory-side caching attributes
Date: Mon, 11 Mar 2019 14:56:02 -0600
Message-Id: <20190311205606.11228-7-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
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
index 735a40a3f9b2..f7ce68fbd4b9 100644
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
index 4139d728f8b3..1a557c589ecb 100644
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
@@ -53,6 +88,10 @@ struct node {
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

