Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 088668E0010
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so15273932pgc.3
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Message-Id: <20181226133351.644607371@intel.com>
Date: Wed, 26 Dec 2018 21:14:56 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 10/21] mm: build separate zonelist for PMEM and DRAM node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0016-page-alloc-Build-separate-zonelist-for-PMEM-and-RAM-.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Fan Du <fan.du@intel.com>

When allocate page, DRAM and PMEM node should better not fall back to
each other. This allows migration code to explicitly control which type
of node to allocate pages from.

With this patch, PMEM NUMA node can only be used in 2 ways:
- migrate in and out
- numactl

That guarantees PMEM NUMA node will only hold anon pages.
We don't detect hotness for other types of pages for now.
So need to prevent some PMEM page goes hot while not able to
detect/move it to DRAM.

Another implication is, new page allocations will by default goto
DRAM nodes. Which is normally a good choice -- since DRAM writes
are cheaper than PMEM, it's often benefitial to watch new pages in
DRAM for some time and only move the likely cold pages to PMEM.

However there can be exceptions. For example, if PMEM:DRAM ratio is
very high, some page allocations may better go to PMEM nodes directly.
In long term, we may create more kind of fallback zonelists and make
them configurable by NUMA policy.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/mempolicy.c  |   14 ++++++++++++++
 mm/page_alloc.c |   42 +++++++++++++++++++++++++++++-------------
 2 files changed, 43 insertions(+), 13 deletions(-)

--- linux.orig/mm/mempolicy.c	2018-12-26 20:03:49.821417489 +0800
+++ linux/mm/mempolicy.c	2018-12-26 20:29:24.597884301 +0800
@@ -1745,6 +1745,20 @@ static int policy_node(gfp_t gfp, struct
 		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
 	}
 
+	if (policy->mode == MPOL_BIND) {
+		nodemask_t nodes = policy->v.nodes;
+
+		/*
+		 * The rule is if we run on DRAM node and mbind to PMEM node,
+		 * perferred node id is the peer node, vice versa.
+		 * if we run on DRAM node and mbind to DRAM node, #PF node is
+		 * the preferred node, vice versa, so just fall back.
+		 */
+		if ((is_node_dram(nd) && nodes_subset(nodes, numa_nodes_pmem)) ||
+			(is_node_pmem(nd) && nodes_subset(nodes, numa_nodes_dram)))
+			nd = NODE_DATA(nd)->peer_node;
+	}
+
 	return nd;
 }
 
--- linux.orig/mm/page_alloc.c	2018-12-26 20:03:49.821417489 +0800
+++ linux/mm/page_alloc.c	2018-12-26 20:03:49.817417321 +0800
@@ -5153,6 +5153,10 @@ static int find_next_best_node(int node,
 		if (node_isset(n, *used_node_mask))
 			continue;
 
+		/* DRAM node doesn't fallback to pmem node */
+		if (is_node_pmem(n))
+			continue;
+
 		/* Use the distance array to find the distance */
 		val = node_distance(node, n);
 
@@ -5242,19 +5246,31 @@ static void build_zonelists(pg_data_t *p
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
-		/*
-		 * We don't want to pressure a particular node.
-		 * So adding penalty to the first node in same
-		 * distance group to make it round-robin.
-		 */
-		if (node_distance(local_node, node) !=
-		    node_distance(local_node, prev_node))
-			node_load[node] = load;
-
-		node_order[nr_nodes++] = node;
-		prev_node = node;
-		load--;
+	/* Pmem node doesn't fallback to DRAM node */
+	if (is_node_pmem(local_node)) {
+		int n;
+
+		/* Pmem nodes should fallback to each other */
+		node_order[nr_nodes++] = local_node;
+		for_each_node_state(n, N_MEMORY) {
+			if ((n != local_node) && is_node_pmem(n))
+				node_order[nr_nodes++] = n;
+		}
+	} else {
+		while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+			/*
+			 * We don't want to pressure a particular node.
+			 * So adding penalty to the first node in same
+			 * distance group to make it round-robin.
+			 */
+			if (node_distance(local_node, node) !=
+			    node_distance(local_node, prev_node))
+				node_load[node] = load;
+
+			node_order[nr_nodes++] = node;
+			prev_node = node;
+			load--;
+		}
 	}
 
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
