Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 93BB48D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 17:22:05 -0500 (EST)
Date: Mon, 28 Feb 2011 23:21:38 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] remove compaction from kswapd
Message-ID: <20110228222138.GP22700@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

This is important to apply in 2.6.38. The imporoved
compaction-in-kswapd logic worked much better then the upstream one,
but performance was still a little better with no compaction in
kswapd. This is also somewhat saver as it removes a feature (that is
hurting performance a bit) instead of improving it. We used a network
benchmark. This is also confirmed by Arthur on lkml using a different
multimedia workload and checking kswapd CPU utilization.

This goes on top of the two lowlatency fixes for compaction (those
fixes improve latency when kswapd runs compaction, but they don't
reduce the kswapd load at all).

Later we can rethink (without hurry) if to readd the feature but for
2.6.38 it's safer to remove it.

===
Subject: compaction: remove compaction from kswapd

From: Andrea Arcangeli <aarcange@redhat.com>

It's safer to stop calling compaction from kswapd as that creates too
high load during memory pressure that can't be offseted by the
improved performance of compound allocations. NOTE: this is not
related to THP (THP allocations uses __GFP_NO_KSWAPD), this is only
related to frequent and small order allocations that make kswapd go
wild with compaction.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -405,10 +423,7 @@ static int compact_finished(struct zone 
 		return COMPACT_COMPLETE;
 
 	/* Compaction run is not finished if the watermark is not met */
-	if (cc->compact_mode != COMPACT_MODE_KSWAPD)
-		watermark = low_wmark_pages(zone);
-	else
-		watermark = high_wmark_pages(zone);
+	watermark = low_wmark_pages(zone);
 	watermark += (1 << cc->order);
 
 	if (!zone_watermark_ok(zone, cc->order, watermark, 0, 0))
@@ -421,15 +436,6 @@ static int compact_finished(struct zone 
 	if (cc->order == -1)
 		return COMPACT_CONTINUE;
 
-	/*
-	 * Generating only one page of the right order is not enough
-	 * for kswapd, we must continue until we're above the high
-	 * watermark as a pool for high order GFP_ATOMIC allocations
-	 * too.
-	 */
-	if (cc->compact_mode == COMPACT_MODE_KSWAPD)
-		return COMPACT_CONTINUE;
-
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		/* Job done if page is free of the right migratetype */
@@ -551,8 +557,7 @@ static int compact_zone(struct zone *zon
 
 unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync,
-				 int compact_mode)
+				 bool sync)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -561,7 +566,6 @@ unsigned long compact_zone_order(struct 
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.compact_mode = compact_mode,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
@@ -607,8 +611,7 @@ unsigned long try_to_compact_pages(struc
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync,
-					    COMPACT_MODE_DIRECT_RECLAIM);
+		status = compact_zone_order(zone, order, gfp_mask, sync);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
@@ -639,7 +642,6 @@ static int compact_node(int nid)
 			.nr_freepages = 0,
 			.nr_migratepages = 0,
 			.order = -1,
-			.compact_mode = COMPACT_MODE_DIRECT_RECLAIM,
 		};
 
 		zone = &pgdat->node_zones[zoneid];
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -11,9 +11,6 @@
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	3
 
-#define COMPACT_MODE_DIRECT_RECLAIM	0
-#define COMPACT_MODE_KSWAPD		1
-
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
@@ -28,8 +25,7 @@ extern unsigned long try_to_compact_page
 			bool sync);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
 extern unsigned long compact_zone_order(struct zone *zone, int order,
-					gfp_t gfp_mask, bool sync,
-					int compact_mode);
+					gfp_t gfp_mask, bool sync);
 
 /* Do not skip compaction more than 64 times */
 #define COMPACT_MAX_DEFER_SHIFT 6
@@ -74,8 +70,7 @@ static inline unsigned long compaction_s
 }
 
 static inline unsigned long compact_zone_order(struct zone *zone, int order,
-					       gfp_t gfp_mask, bool sync,
-					       int compact_mode)
+					       gfp_t gfp_mask, bool sync)
 {
 	return COMPACT_CONTINUE;
 }
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2397,7 +2397,6 @@ loop_again:
 		 * cause too much scanning of the lower zones.
 		 */
 		for (i = 0; i <= end_zone; i++) {
-			int compaction;
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
 			unsigned long balance_gap;
@@ -2438,24 +2437,9 @@ loop_again:
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 
-			compaction = 0;
-			if (order &&
-			    zone_watermark_ok(zone, 0,
-					       high_wmark_pages(zone),
-					      end_zone, 0) &&
-			    !zone_watermark_ok(zone, order,
-					       high_wmark_pages(zone),
-					       end_zone, 0)) {
-				compact_zone_order(zone,
-						   order,
-						   sc.gfp_mask, false,
-						   COMPACT_MODE_KSWAPD);
-				compaction = 1;
-			}
-
 			if (zone->all_unreclaimable)
 				continue;
-			if (!compaction && nr_slab == 0 &&
+			if (nr_slab == 0 &&
 			    !zone_reclaimable(zone))
 				zone->all_unreclaimable = 1;
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
