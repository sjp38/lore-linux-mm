Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 46F306004A3
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 19:05:50 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/5] vmscan: remove may_swap scan control
Date: Sat,  1 May 2010 01:05:33 +0200
Message-Id: <20100430224316.198324471@cmpxchg.org>
In-Reply-To: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
Content-Disposition: inline; filename=vmscan-remove-may_swap-scan-control.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The may_swap scan control flag can be naturally merged into the
swappiness parameter: swap only if swappiness is non-zero.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/swap.h |    4 ++--
 mm/memcontrol.c      |   13 +++++++++----
 mm/vmscan.c          |   27 +++++++++------------------
 3 files changed, 20 insertions(+), 24 deletions(-)

--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -248,10 +248,10 @@ static inline void lru_cache_add_active_
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						  gfp_t gfp_mask, bool noswap,
+						  gfp_t gfp_mask,
 						  unsigned int swappiness);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
+						gfp_t gfp_mask,
 						unsigned int swappiness,
 						struct zone *zone,
 						int nid);
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1234,6 +1234,8 @@ static int mem_cgroup_hierarchical_recla
 		noswap = true;
 
 	while (1) {
+		unsigned int swappiness;
+
 		victim = mem_cgroup_select_victim(root_mem);
 		if (victim == root_mem) {
 			loop++;
@@ -1268,13 +1270,16 @@ static int mem_cgroup_hierarchical_recla
 			continue;
 		}
 		/* we use swappiness of local cgroup */
+		if (noswap)
+			swappiness = 0;
+		else
+			swappiness = get_swappiness(victim);
 		if (check_soft)
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, get_swappiness(victim), zone,
-				zone->zone_pgdat->node_id);
+				swappiness, zone, zone->zone_pgdat->node_id);
 		else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap, get_swappiness(victim));
+							swappiness);
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -2966,7 +2971,7 @@ try_to_free:
 			goto out;
 		}
 		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
-						false, get_swappiness(mem));
+							get_swappiness(mem));
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -65,9 +65,6 @@ struct scan_control {
 
 	int may_writepage;
 
-	/* Can pages be swapped as part of reclaim? */
-	int may_swap;
-
 	int swappiness;
 
 	int order;
@@ -1545,7 +1542,7 @@ static void get_scan_count(struct zone *
 	int noswap = 0;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || (nr_swap_pages <= 0)) {
+	if (!sc->swappiness || (nr_swap_pages <= 0)) {
 		noswap = 1;
 		fraction[0] = 0;
 		fraction[1] = 1;
@@ -1870,7 +1867,6 @@ unsigned long try_to_free_pages(struct z
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
@@ -1883,13 +1879,11 @@ unsigned long try_to_free_pages(struct z
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
-						gfp_t gfp_mask, bool noswap,
-						unsigned int swappiness,
-						struct zone *zone, int nid)
+					gfp_t gfp_mask, unsigned int swappiness,
+					struct zone *zone, int nid)
 {
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
-		.may_swap = !noswap,
 		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem,
@@ -1913,14 +1907,11 @@ unsigned long mem_cgroup_shrink_node_zon
 }
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
-					   gfp_t gfp_mask,
-					   bool noswap,
-					   unsigned int swappiness)
+					gfp_t gfp_mask, unsigned int swappiness)
 {
 	struct zonelist *zonelist;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
-		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1992,7 +1983,6 @@ static unsigned long balance_pgdat(pg_da
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
-		.may_swap = 1,
 		/*
 		 * kswapd doesn't want to be bailed out while reclaim. because
 		 * we want to put equal scanning pressure on each zone.
@@ -2372,7 +2362,6 @@ unsigned long shrink_all_memory(unsigned
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
-		.may_swap = 1,
 		.may_writepage = 1,
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
@@ -2554,16 +2543,18 @@ static int __zone_reclaim(struct zone *z
 	struct reclaim_state reclaim_state;
 	int priority;
 	struct scan_control sc = {
-		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
-		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,
 				       SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
-		.swappiness = vm_swappiness,
 		.order = order,
 	};
 	unsigned long slab_reclaimable;
 
+	if (zone_reclaim_mode & RECLAIM_WRITE)
+		sc.may_writepage = 1;
+	if (zone_reclaim_mode & RECLAIM_SWAP)
+		sc.swappiness = vm_swappiness;
+
 	disable_swap_token();
 	cond_resched();
 	/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
