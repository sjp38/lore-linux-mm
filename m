Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 5463F6B00B9
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:51:37 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART3 Patch v2 13/14] page_alloc: use N_MEMORY instead N_HIGH_MEMORY change the node_states initialization
Date: Thu, 15 Nov 2012 16:57:36 +0800
Message-Id: <1352969857-26623-14-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
References: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Lin feng <linfeng@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Since we introduced N_MEMORY, we update the initialization of node_states.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c |  4 +++-
 mm/page_alloc.c       | 42 +++++++++++++++++++++++-------------------
 2 files changed, 26 insertions(+), 20 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 3baff25..2ead3c8 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -630,7 +630,9 @@ void __init paging_init(void)
 	 *	 numa support is not compiled in, and later node_set_state
 	 *	 will not set it back.
 	 */
-	node_clear_state(0, N_NORMAL_MEMORY);
+	node_clear_state(0, N_MEMORY);
+	if (N_MEMORY != N_NORMAL_MEMORY)
+		node_clear_state(0, N_NORMAL_MEMORY);
 
 	zone_sizes_init();
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5b74de6..4054aaf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1692,7 +1692,7 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
  *
  * If the zonelist cache is present in the passed in zonelist, then
  * returns a pointer to the allowed node mask (either the current
- * tasks mems_allowed, or node_states[N_HIGH_MEMORY].)
+ * tasks mems_allowed, or node_states[N_MEMORY].)
  *
  * If the zonelist cache is not available for this zonelist, does
  * nothing and returns NULL.
@@ -1721,7 +1721,7 @@ static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
 
 	allowednodes = !in_interrupt() && (alloc_flags & ALLOC_CPUSET) ?
 					&cpuset_current_mems_allowed :
-					&node_states[N_HIGH_MEMORY];
+					&node_states[N_MEMORY];
 	return allowednodes;
 }
 
@@ -3194,7 +3194,7 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 		return node;
 	}
 
-	for_each_node_state(n, N_HIGH_MEMORY) {
+	for_each_node_state(n, N_MEMORY) {
 
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
@@ -3336,7 +3336,7 @@ static int default_zonelist_order(void)
  	 * local memory, NODE_ORDER may be suitable.
          */
 	average_size = total_size /
-				(nodes_weight(node_states[N_HIGH_MEMORY]) + 1);
+				(nodes_weight(node_states[N_MEMORY]) + 1);
 	for_each_online_node(nid) {
 		low_kmem_size = 0;
 		total_size = 0;
@@ -4687,7 +4687,7 @@ unsigned long __init find_min_pfn_with_active_regions(void)
 /*
  * early_calculate_totalpages()
  * Sum pages in active regions for movable zone.
- * Populate N_HIGH_MEMORY for calculating usable_nodes.
+ * Populate N_MEMORY for calculating usable_nodes.
  */
 static unsigned long __init early_calculate_totalpages(void)
 {
@@ -4700,7 +4700,7 @@ static unsigned long __init early_calculate_totalpages(void)
 
 		totalpages += pages;
 		if (pages)
-			node_set_state(nid, N_HIGH_MEMORY);
+			node_set_state(nid, N_MEMORY);
 	}
   	return totalpages;
 }
@@ -4717,9 +4717,9 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 	unsigned long usable_startpfn;
 	unsigned long kernelcore_node, kernelcore_remaining;
 	/* save the state before borrow the nodemask */
-	nodemask_t saved_node_state = node_states[N_HIGH_MEMORY];
+	nodemask_t saved_node_state = node_states[N_MEMORY];
 	unsigned long totalpages = early_calculate_totalpages();
-	int usable_nodes = nodes_weight(node_states[N_HIGH_MEMORY]);
+	int usable_nodes = nodes_weight(node_states[N_MEMORY]);
 
 	/*
 	 * If movablecore was specified, calculate what size of
@@ -4754,7 +4754,7 @@ static void __init find_zone_movable_pfns_for_nodes(void)
 restart:
 	/* Spread kernelcore memory as evenly as possible throughout nodes */
 	kernelcore_node = required_kernelcore / usable_nodes;
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		unsigned long start_pfn, end_pfn;
 
 		/*
@@ -4846,23 +4846,27 @@ restart:
 
 out:
 	/* restore the node_state */
-	node_states[N_HIGH_MEMORY] = saved_node_state;
+	node_states[N_MEMORY] = saved_node_state;
 }
 
-/* Any regular memory on that node ? */
-static void __init check_for_regular_memory(pg_data_t *pgdat)
+/* Any regular or high memory on that node ? */
+static void check_for_memory(pg_data_t *pgdat, int nid)
 {
-#ifdef CONFIG_HIGHMEM
 	enum zone_type zone_type;
 
-	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
+	if (N_MEMORY == N_NORMAL_MEMORY)
+		return;
+
+	for (zone_type = 0; zone_type <= ZONE_MOVABLE - 1; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
 		if (zone->present_pages) {
-			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
+			node_set_state(nid, N_HIGH_MEMORY);
+			if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&
+			    zone_type <= ZONE_NORMAL)
+				node_set_state(nid, N_NORMAL_MEMORY);
 			break;
 		}
 	}
-#endif
 }
 
 /**
@@ -4945,8 +4949,8 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
 		/* Any memory on that node */
 		if (pgdat->node_present_pages)
-			node_set_state(nid, N_HIGH_MEMORY);
-		check_for_regular_memory(pgdat);
+			node_set_state(nid, N_MEMORY);
+		check_for_memory(pgdat, nid);
 	}
 }
 
@@ -6105,7 +6109,7 @@ void reset_zone_present_pages(void)
 	struct zone *z;
 	int i, nid;
 
-	for_each_node_state(nid, N_HIGH_MEMORY) {
+	for_each_node_state(nid, N_MEMORY) {
 		for (i = 0; i < MAX_NR_ZONES; i++) {
 			z = NODE_DATA(nid)->node_zones + i;
 			z->present_pages = 0;
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
