Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 631098E0003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:07 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 89so13992674ple.19
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c7si33395890pgg.339.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Message-Id: <20181226133351.521151384@intel.com>
Date: Wed, 26 Dec 2018 21:14:54 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 08/21] mm: introduce and export pgdat peer_node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0019-mm-Introduce-and-export-peer_node-for-pgdat.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Fan Du <fan.du@intel.com>

Each CPU socket can have 1 DRAM and 1 PMEM node, we call them "peer nodes".
Migration between DRAM and PMEM will by default happen between peer nodes.

It's a temp solution. In multiple memory layers, a node can have both
promotion and demotion targets instead of a single peer node. User space
may also be able to infer promotion/demotion targets based on future
HMAT info.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/base/node.c    |   11 +++++++++++
 include/linux/mmzone.h |   12 ++++++++++++
 mm/page_alloc.c        |   29 +++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+)

--- linux.orig/drivers/base/node.c	2018-12-23 19:39:51.647261099 +0800
+++ linux/drivers/base/node.c	2018-12-23 19:39:51.643261112 +0800
@@ -242,6 +242,16 @@ static ssize_t type_show(struct device *
 }
 static DEVICE_ATTR(type, S_IRUGO, type_show, NULL);
 
+static ssize_t peer_node_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+	struct pglist_data *pgdat = NODE_DATA(nid);
+
+	return sprintf(buf, "%d\n", pgdat->peer_node);
+}
+static DEVICE_ATTR(peer_node, S_IRUGO, peer_node_show, NULL);
+
 static struct attribute *node_dev_attrs[] = {
 	&dev_attr_cpumap.attr,
 	&dev_attr_cpulist.attr,
@@ -250,6 +260,7 @@ static struct attribute *node_dev_attrs[
 	&dev_attr_distance.attr,
 	&dev_attr_vmstat.attr,
 	&dev_attr_type.attr,
+	&dev_attr_peer_node.attr,
 	NULL
 };
 ATTRIBUTE_GROUPS(node_dev);
--- linux.orig/include/linux/mmzone.h	2018-12-23 19:39:51.647261099 +0800
+++ linux/include/linux/mmzone.h	2018-12-23 19:39:51.643261112 +0800
@@ -713,6 +713,18 @@ typedef struct pglist_data {
 	/* Per-node vmstats */
 	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
 	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
+
+	/*
+	 * Points to the nearest node in terms of latency
+	 * E.g. peer of node 0 is node 2 per SLIT
+	 * node distances:
+	 * node   0   1   2   3
+	 *   0:  10  21  17  28
+	 *   1:  21  10  28  17
+	 *   2:  17  28  10  28
+	 *   3:  28  17  28  10
+	 */
+	int	peer_node;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
--- linux.orig/mm/page_alloc.c	2018-12-23 19:39:51.647261099 +0800
+++ linux/mm/page_alloc.c	2018-12-23 19:39:51.643261112 +0800
@@ -6926,6 +6926,34 @@ static void check_for_memory(pg_data_t *
 	}
 }
 
+/*
+ * Return the nearest peer node in terms of *locality*
+ * E.g. peer of node 0 is node 2 per SLIT
+ * node distances:
+ * node   0   1   2   3
+ *   0:  10  21  17  28
+ *   1:  21  10  28  17
+ *   2:  17  28  10  28
+ *   3:  28  17  28  10
+ */
+static int find_best_peer_node(int nid)
+{
+	int n, val;
+	int min_val = INT_MAX;
+	int peer = NUMA_NO_NODE;
+
+	for_each_online_node(n) {
+		if (n == nid)
+			continue;
+		val = node_distance(nid, n);
+		if (val < min_val) {
+			min_val = val;
+			peer = n;
+		}
+	}
+	return peer;
+}
+
 /**
  * free_area_init_nodes - Initialise all pg_data_t and zone data
  * @max_zone_pfn: an array of max PFNs for each zone
@@ -7012,6 +7040,7 @@ void __init free_area_init_nodes(unsigne
 		if (pgdat->node_present_pages)
 			node_set_state(nid, N_MEMORY);
 		check_for_memory(pgdat, nid);
+		pgdat->peer_node = find_best_peer_node(nid);
 	}
 }
 
