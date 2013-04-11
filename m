Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C04AF6B0036
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 15:58:10 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/10] mm: vmscan: Flatten kswapd priority loop
Date: Thu, 11 Apr 2013 20:57:51 +0100
Message-Id: <1365710278-6807-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1365710278-6807-1-git-send-email-mgorman@suse.de>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

kswapd stops raising the scanning priority when at least SWAP_CLUSTER_MAX
pages have been reclaimed or the pgdat is considered balanced. It then
rechecks if it needs to restart at DEF_PRIORITY and whether high-order
reclaim needs to be reset. This is not wrong per-se but it is confusing
to follow and forcing kswapd to stay at DEF_PRIORITY may require several
restarts before it has scanned enough pages to meet the high watermark even
at 100% efficiency. This patch irons out the logic a bit by controlling
when priority is raised and removing the "goto loop_again".

This patch has kswapd raise the scanning priority until it is scanning
enough pages that it could meet the high watermark in one shrink of the
LRU lists if it is able to reclaim at 100% efficiency. It will not raise
the scanning prioirty higher unless it is failing to reclaim any pages.

To avoid infinite looping for high-order allocation requests kswapd will
not reclaim for high-order allocations when it has reclaimed at least
twice the number of pages as the allocation request.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 86 +++++++++++++++++++++++++++++--------------------------------
 1 file changed, 41 insertions(+), 45 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6bca2c..f979a67 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2643,8 +2643,12 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 /*
  * kswapd shrinks the zone by the number of pages required to reach
  * the high watermark.
+ *
+ * Returns true if kswapd scanned at least the requested number of pages to
+ * reclaim. This is used to determine if the scanning priority needs to be
+ * raised.
  */
-static void kswapd_shrink_zone(struct zone *zone,
+static bool kswapd_shrink_zone(struct zone *zone,
 			       struct scan_control *sc,
 			       unsigned long lru_pages)
 {
@@ -2664,6 +2668,8 @@ static void kswapd_shrink_zone(struct zone *zone,
 
 	if (nr_slab == 0 && !zone_reclaimable(zone))
 		zone->all_unreclaimable = 1;
+
+	return sc->nr_scanned >= sc->nr_to_reclaim;
 }
 
 /*
@@ -2690,26 +2696,26 @@ static void kswapd_shrink_zone(struct zone *zone,
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int *classzone_idx)
 {
-	bool pgdat_is_balanced = false;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
+		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.may_writepage = !laptop_mode,
 		.order = order,
 		.target_mem_cgroup = NULL,
 	};
-loop_again:
-	sc.priority = DEF_PRIORITY;
-	sc.nr_reclaimed = 0;
-	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
 	do {
 		unsigned long lru_pages = 0;
+		bool raise_priority = true;
+
+		sc.nr_reclaimed = 0;
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2751,10 +2757,8 @@ loop_again:
 			}
 		}
 
-		if (i < 0) {
-			pgdat_is_balanced = true;
+		if (i < 0)
 			goto out;
-		}
 
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
@@ -2821,8 +2825,16 @@ loop_again:
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
 			    !zone_balanced(zone, testorder,
-					   balance_gap, end_zone))
-				kswapd_shrink_zone(zone, &sc, lru_pages);
+					   balance_gap, end_zone)) {
+				/*
+				 * There should be no need to raise the
+				 * scanning priority if enough pages are
+				 * already being scanned that high
+				 * watermark would be met at 100% efficiency.
+				 */
+				if (kswapd_shrink_zone(zone, &sc, lru_pages))
+					raise_priority = false;
+			}
 
 			/*
 			 * If we're getting trouble reclaiming, start doing
@@ -2857,46 +2869,29 @@ loop_again:
 				pfmemalloc_watermark_ok(pgdat))
 			wake_up(&pgdat->pfmemalloc_wait);
 
-		if (pgdat_balanced(pgdat, order, *classzone_idx)) {
-			pgdat_is_balanced = true;
-			break;		/* kswapd: all done */
-		}
-
 		/*
-		 * We do this so kswapd doesn't build up large priorities for
-		 * example when it is freeing in parallel with allocators. It
-		 * matches the direct reclaim path behaviour in terms of impact
-		 * on zone->*_priority.
+		 * Fragmentation may mean that the system cannot be rebalanced
+		 * for high-order allocations in all zones. If twice the
+		 * allocation size has been reclaimed and the zones are still
+		 * not balanced then recheck the watermarks at order-0 to
+		 * prevent kswapd reclaiming excessively. Assume that a
+		 * process requested a high-order can direct reclaim/compact.
 		 */
-		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
-			break;
-	} while (--sc.priority >= 0);
-
-out:
-	if (!pgdat_is_balanced) {
-		cond_resched();
+		if (order && sc.nr_reclaimed >= 2UL << order)
+			order = sc.order = 0;
 
-		try_to_freeze();
+		/* Check if kswapd should be suspending */
+		if (try_to_freeze() || kthread_should_stop())
+			break;
 
 		/*
-		 * Fragmentation may mean that the system cannot be
-		 * rebalanced for high-order allocations in all zones.
-		 * At this point, if nr_reclaimed < SWAP_CLUSTER_MAX,
-		 * it means the zones have been fully scanned and are still
-		 * not balanced. For high-order allocations, there is
-		 * little point trying all over again as kswapd may
-		 * infinite loop.
-		 *
-		 * Instead, recheck all watermarks at order-0 as they
-		 * are the most important. If watermarks are ok, kswapd will go
-		 * back to sleep. High-order users can still perform direct
-		 * reclaim if they wish.
+		 * Raise priority if scanning rate is too low or there was no
+		 * progress in reclaiming pages
 		 */
-		if (sc.nr_reclaimed < SWAP_CLUSTER_MAX)
-			order = sc.order = 0;
-
-		goto loop_again;
-	}
+		if (raise_priority || !sc.nr_reclaimed)
+			sc.priority--;
+	} while (sc.priority >= 0 &&
+		 !pgdat_balanced(pgdat, order, *classzone_idx));
 
 	/*
 	 * If kswapd was reclaiming at a higher order, it has the option of
@@ -2925,6 +2920,7 @@ out:
 			compact_pgdat(pgdat, order);
 	}
 
+out:
 	/*
 	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
 	 * makes a decision on the order we were last reclaiming at. However,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
