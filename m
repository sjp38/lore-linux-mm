Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 4C1816B0062
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 09:04:32 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/10] mm: vmscan: Move logic from balance_pgdat() to kswapd_shrink_zone()
Date: Sun, 17 Mar 2013 13:04:16 +0000
Message-Id: <1363525456-10448-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1363525456-10448-1-git-send-email-mgorman@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

balance_pgdat() is very long and some of the logic can and should
be internal to kswapd_shrink_zone(). Move it so the flow of
balance_pgdat() is marginally easier to follow.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 104 +++++++++++++++++++++++++++++-------------------------------
 1 file changed, 51 insertions(+), 53 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8c66e5a..d7cf384 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2660,18 +2660,53 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
  * reclaim or if the lack of process was due to pages under writeback.
  */
 static bool kswapd_shrink_zone(struct zone *zone,
+			       int classzone_idx,
 			       struct scan_control *sc,
 			       unsigned long lru_pages,
 			       bool shrinking_slab)
 {
+	int testorder = sc->order;
 	unsigned long nr_slab = 0;
+	unsigned long balance_gap;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct shrink_control shrink = {
 		.gfp_mask = sc->gfp_mask,
 	};
+	bool lowmem_pressure;
 
 	/* Reclaim above the high watermark. */
 	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
+
+	/*
+	 * Kswapd reclaims only single pages with compaction enabled. Trying
+	 * too hard to reclaim until contiguous free pages have become
+	 * available can hurt performance by evicting too much useful data
+	 * from memory. Do not reclaim more than needed for compaction.
+	 */
+	if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
+			compaction_suitable(zone, sc->order) !=
+				COMPACT_SKIPPED)
+		testorder = 0;
+
+	/*
+	 * We put equal pressure on every zone, unless one zone has way too
+	 * many pages free already. The "too many pages" is defined as the
+	 * high wmark plus a "gap" where the gap is either the low
+	 * watermark or 1% of the zone, whichever is smaller.
+	 */
+	balance_gap = min(low_wmark_pages(zone),
+		(zone->managed_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+		KSWAPD_ZONE_BALANCE_GAP_RATIO);
+
+	/*
+	 * If there is no low memory pressure or the zone is balanced then no
+	 * reclaim is necessary
+	 */
+	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
+	if (!(lowmem_pressure || !zone_balanced(zone, testorder,
+						balance_gap, classzone_idx)))
+		return true;
+
 	shrink_zone(zone, sc);
 
 	/*
@@ -2689,6 +2724,16 @@ static bool kswapd_shrink_zone(struct zone *zone,
 
 	zone_clear_flag(zone, ZONE_WRITEBACK);
 
+	/*
+	 * If a zone reaches its high watermark, consider it to be no longer
+	 * congested. It's possible there are dirty pages backed by congested
+	 * BDIs but as pressure is relieved, speculatively avoid congestion
+	 * waits.
+	 */
+	if (!zone->all_unreclaimable &&
+	    zone_balanced(zone, testorder, 0, classzone_idx))
+		zone_clear_flag(zone, ZONE_CONGESTED);
+
 	return sc->nr_scanned >= sc->nr_to_reclaim;
 }
 
@@ -2821,8 +2866,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int testorder;
-			unsigned long balance_gap;
 
 			if (!populated_zone(zone))
 				continue;
@@ -2843,61 +2886,16 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			sc.nr_reclaimed += nr_soft_reclaimed;
 
 			/*
-			 * We put equal pressure on every zone, unless
-			 * one zone has way too many pages free
-			 * already. The "too many pages" is defined
-			 * as the high wmark plus a "gap" where the
-			 * gap is either the low watermark or 1%
-			 * of the zone, whichever is smaller.
-			 */
-			balance_gap = min(low_wmark_pages(zone),
-				(zone->managed_pages +
-					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
-				KSWAPD_ZONE_BALANCE_GAP_RATIO);
-			/*
-			 * Kswapd reclaims only single pages with compaction
-			 * enabled. Trying too hard to reclaim until contiguous
-			 * free pages have become available can hurt performance
-			 * by evicting too much useful data from memory.
-			 * Do not reclaim more than needed for compaction.
+			 * There should be no need to raise the scanning
+			 * priority if enough pages are already being scanned
+			 * that that high watermark would be met at 100%
+			 * efficiency.
 			 */
-			testorder = order;
-			if (IS_ENABLED(CONFIG_COMPACTION) && order &&
-					compaction_suitable(zone, order) !=
-						COMPACT_SKIPPED)
-				testorder = 0;
-
-			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-			    !zone_balanced(zone, testorder,
-					   balance_gap, end_zone)) {
-				/*
-				 * There should be no need to raise the
-				 * scanning priority if enough pages are
-				 * already being scanned that that high
-				 * watermark would be met at 100% efficiency.
-				 */
-				if (kswapd_shrink_zone(zone, &sc,
+			if (kswapd_shrink_zone(zone, end_zone, &sc,
 						lru_pages, shrinking_slab))
 					raise_priority = false;
 
-				nr_to_reclaim += sc.nr_to_reclaim;
-			}
-
-			if (zone->all_unreclaimable) {
-				if (end_zone && end_zone == i)
-					end_zone--;
-				continue;
-			}
-
-			if (zone_balanced(zone, testorder, 0, end_zone))
-				/*
-				 * If a zone reaches its high watermark,
-				 * consider it to be no longer congested. It's
-				 * possible there are dirty pages backed by
-				 * congested BDIs but as pressure is relieved,
-				 * speculatively avoid congestion waits
-				 */
-				zone_clear_flag(zone, ZONE_CONGESTED);
+			nr_to_reclaim += sc.nr_to_reclaim;
 		}
 
 		/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
