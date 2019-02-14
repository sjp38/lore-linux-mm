Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 829BBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D5FE222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:11:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D5FE222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C271A8E000A; Thu, 14 Feb 2019 12:10:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB4118E0004; Thu, 14 Feb 2019 12:10:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93F538E0009; Thu, 14 Feb 2019 12:10:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDA48E0004
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so4732856plb.20
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Q16/BWjL2iMNXbF5aNrZRK4IxAXKbEgek9c/l+EmgZc=;
        b=Egx3+Ty2S3+t0bvNAGjEhtCQb5re/d1AYgqlpLDYGL1wB5MTG149fP3HifEEtp9tJh
         eKnQ6R4rIs2D0FBTCVYk3VZvzdy0jtmXlrC3e9O3P3tmXfdt9CaGca56r40h1QG0ulWu
         VWZ3VwiGm+sU/uGDNqFU1+DIx2It55FPHpCC0AvAM43ZaEo71Wsv3RCRoOBde6J+CrDf
         U9lgyFSRRvvQLxqGL+QPX66BST4YJMCGH8tEjZ3l5HAXytOHTwKmEKERtWcEHOVdbBzg
         GxmyApshgX4ev3DwZVtBDIPSnNaN8OBn7oGPlsZw79+tRxAum9i6segV7+GrZ5ANDgov
         SJLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAua8PiD2DiYaadrnujr81c1p800Bon9+BRg/yVs7GFBhpiBO8C35
	zdzdmt5Qc0M/198Bsm2gXNjiA1lEAWdIRNhUMcR0g0EHnwvKvPXw1VivWWwP6QdtJ45X0qX8AND
	JypFo0Jst7j2dCIwh8pEuvDOMzsJgkFkchnRPtymo/lj2FRGJHcl/GNymubKJc/XgJA==
X-Received: by 2002:a62:3141:: with SMTP id x62mr5097853pfx.12.1550164243928;
        Thu, 14 Feb 2019 09:10:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib/JNaMay6VsmS2mq5RUrtf8YWv/ZpmKpeiI0qE24hrOHH3h5o9NL0TzlVDxvX8yol+aTOK
X-Received: by 2002:a62:3141:: with SMTP id x62mr5097752pfx.12.1550164242501;
        Thu, 14 Feb 2019 09:10:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164242; cv=none;
        d=google.com; s=arc-20160816;
        b=V0hbDSIDuAEOX/Zo0pCffRUgUcBYhh0jJqSeOCKu9U9krSg1pv/KqhzDoe5uHA1YK2
         cUXzeYmoajiBCEaJOgwMdODEMwD/nAQ3CrJo86ylm3kIG3iZiJfLo5f8ssWbLSAP4PPy
         U8PLcTHaW0vgygdlovgDIwi084SAksSvi/QJeWHAwo3mqCKpJtY/eJUvDRmFsse6HOcS
         KVnKqxtBhnuhObn0dgALfygfEa22ONvNCC5vVDI32LDdP0UoaXlS1VaDPk+kkx32ox1J
         QjT71H18wJpNpd6PtzxcDLgzt5ue4Oq/IvRp5pqc3Z9P3o6PxIfpEgf8us8f9nXFOcX7
         ZtNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Q16/BWjL2iMNXbF5aNrZRK4IxAXKbEgek9c/l+EmgZc=;
        b=wvUD5M8Kg+bsB8A/Pf3r8APgKINUECHgSDjyLGyslpSGL2eirP4nVnCtI3i5H5tAmc
         3oshTozoeQO4nwIHQDEpzQl60BKB8+9hCYRhhglUhicrgj7C9IW9+x2JNkOqRXHcPTZS
         4WJ/Tz1X9t5rvVIrgBnLD7bq4MP67GzM06r7wnP/V2zyftlv3wK4eD0BGwqtU960aqMa
         WFWlY1cDfUJA19SvZ1U7CHU6S360kdqDrDPLPElH1NL/BAz7SGB2IQPNcA/QbkNnL5iA
         auv2u16Ptm1OMZUPyeTQVflVBU4wOBuLBiEtSP+DerS0XI8Ysn738YQm3eZ+c7pGtpC9
         W5OA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:42 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613123"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:41 -0800
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
Subject: [PATCHv6 06/10] node: Add memory-side caching attributes
Date: Thu, 14 Feb 2019 10:10:13 -0700
Message-Id: <20190214171017.9362-7-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
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

The exported attributes are the cache size, the line size, associativity,
and write back policy, and add the attributes for the system memory
caches to sysfs stable documentation.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node |  35 +++++++
 drivers/base/node.c                         | 151 ++++++++++++++++++++++++++++
 include/linux/node.h                        |  34 +++++++
 3 files changed, 220 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index cd64b62152ba..5c88cb9ca14e 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -143,3 +143,38 @@ Contact:	Keith Busch <keith.busch@intel.com>
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
+		The caches associativity: 0 for direct mapped, non-zero if
+What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/associativity
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The caches associativity: 0 for direct mapped, non-zero if
+		indexed.
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
index a1795c9c9f7d..575bad0e910d 100644
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
+CACHE_ATTR(associativity, "%u")
+CACHE_ATTR(write_policy, "%u")
+
+static struct attribute *cache_attrs[] = {
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
 
@@ -780,6 +930,7 @@ int __register_one_node(int nid)
 	INIT_LIST_HEAD(&node_devices[nid]->access_list);
 	/* initialize work queue for memory hot plug */
 	init_node_hugetlb_work(nid);
+	node_init_caches(nid);
 
 	return error;
 }
diff --git a/include/linux/node.h b/include/linux/node.h
index 2db077363d9c..9c88095b65c6 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -37,6 +37,36 @@ struct node_hmem_attrs {
 };
 void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
 			 unsigned access);
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
+ * @level:		The cache hierarchy level
+ */
+struct node_cache_attrs {
+	enum cache_associativity associativity;
+	enum cache_write_policy write_policy;
+	u64 size;
+	u16 line_size;
+	u8 level;
+};
+void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs);
 #endif
 
 struct node {
@@ -45,6 +75,10 @@ struct node {
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

