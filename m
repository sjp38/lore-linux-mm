Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A3EAC6004A3
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 19:06:03 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] vmscan: remove may_unmap scan control
Date: Sat,  1 May 2010 01:05:30 +0200
Message-Id: <20100430224315.978273568@cmpxchg.org>
In-Reply-To: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
Content-Disposition: inline; filename=vmscan-remove-may_unmap-scan-control.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Every reclaim entry function sets this to the same value.

Make it default behaviour and remove the knob.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   12 ------------
 1 file changed, 12 deletions(-)

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -65,9 +65,6 @@ struct scan_control {
 
 	int may_writepage;
 
-	/* Can mapped pages be reclaimed? */
-	int may_unmap;
-
 	/* Can pages be swapped as part of reclaim? */
 	int may_swap;
 
@@ -655,9 +652,6 @@ static unsigned long shrink_page_list(st
 		if (unlikely(!page_evictable(page, NULL)))
 			goto cull_mlocked;
 
-		if (!sc->may_unmap && page_mapped(page))
-			goto keep_locked;
-
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
@@ -1868,7 +1862,6 @@ unsigned long try_to_free_pages(struct z
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.may_unmap = 1,
 		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
@@ -1889,7 +1882,6 @@ unsigned long mem_cgroup_shrink_node_zon
 {
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
-		.may_unmap = 1,
 		.may_swap = !noswap,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1922,7 +1914,6 @@ unsigned long try_to_free_mem_cgroup_pag
 	struct zonelist *zonelist;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
-		.may_unmap = 1,
 		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
@@ -1996,7 +1987,6 @@ static unsigned long balance_pgdat(pg_da
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
-		.may_unmap = 1,
 		.may_swap = 1,
 		/*
 		 * kswapd doesn't want to be bailed out while reclaim. because
@@ -2379,7 +2369,6 @@ unsigned long shrink_all_memory(unsigned
 	struct scan_control sc = {
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
 		.may_swap = 1,
-		.may_unmap = 1,
 		.may_writepage = 1,
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
@@ -2563,7 +2552,6 @@ static int __zone_reclaim(struct zone *z
 	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
-		.may_unmap = 1,
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,
 				       SWAP_CLUSTER_MAX),


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
