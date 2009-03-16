Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAFAC6B0088
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:31 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 20/35] Use a pre-calculated value for num_online_nodes()
Date: Mon, 16 Mar 2009 09:46:15 +0000
Message-Id: <1237196790-7268-21-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

num_online_nodes() is called by the page allocator to decide whether the
zonelist needs to be filtered based on cpusets or the zonelist cache.
This is actually a heavy function and touches a number of cache lines.
This patch stores the number of online nodes at boot time and when
nodes get onlined and offlined.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/nodemask.h |   16 ++++++++++++++--
 mm/page_alloc.c          |    6 ++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 848025c..4749e30 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -449,13 +449,25 @@ static inline int num_node_state(enum node_states state)
 	node;					\
 })
 
+/* Recorded value for num_online_nodes() */
+extern int static_num_online_nodes;
+
 #define num_online_nodes()	num_node_state(N_ONLINE)
 #define num_possible_nodes()	num_node_state(N_POSSIBLE)
 #define node_online(node)	node_state((node), N_ONLINE)
 #define node_possible(node)	node_state((node), N_POSSIBLE)
 
-#define node_set_online(node)	   node_set_state((node), N_ONLINE)
-#define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
+static inline void node_set_online(int nid)
+{
+	node_set_state(nid, N_ONLINE);
+	static_num_online_nodes = num_node_state(N_ONLINE);
+}
+
+static inline void node_set_offline(int nid)
+{
+	node_clear_state(nid, N_ONLINE);
+	static_num_online_nodes = num_node_state(N_ONLINE);
+}
 
 #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
 #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e620c91..d297780 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -70,6 +70,7 @@ EXPORT_SYMBOL(node_states);
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
 unsigned long highest_memmap_pfn __read_mostly;
+int static_num_online_nodes __read_mostly;
 int percpu_pagelist_fraction;
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
@@ -1442,7 +1443,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	/* Determine in advance if the zonelist needs filtering */
 	if ((alloc_flags & ALLOC_CPUSET) && unlikely(number_of_cpusets > 1))
 		zonelist_filter = 1;
-	if (num_online_nodes() > 1)
+	if (static_num_online_nodes > 1)
 		zonelist_filter = 1;
 
 zonelist_scan:
@@ -1488,7 +1489,7 @@ this_zone_full:
 			zlc_mark_zone_full(zonelist, z);
 try_next_zone:
 		if (NUMA_BUILD && zonelist_filter) {
-			if (!did_zlc_setup && num_online_nodes() > 1) {
+			if (!did_zlc_setup && static_num_online_nodes > 1) {
 				/*
 				 * do zlc_setup after the first zone is tried
 				 * but only if there are multiple nodes to make
@@ -2645,6 +2646,7 @@ void build_all_zonelists(void)
 	else
 		page_group_by_mobility_disabled = 0;
 
+	static_num_online_nodes = num_node_state(N_ONLINE);
 	printk("Built %i zonelists in %s order, mobility grouping %s.  "
 		"Total pages: %ld\n",
 			num_online_nodes(),
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
