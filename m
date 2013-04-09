Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 7EDFB6B0037
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 07:18:06 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/10] mm: vmscan: Decide whether to compact the pgdat based on reclaim progress
Date: Tue,  9 Apr 2013 12:06:59 +0100
Message-Id: <1365505625-9460-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-1-git-send-email-mgorman@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

In the past, kswapd makes a decision on whether to compact memory after the
pgdat was considered balanced. This more or less worked but it is late to
make such a decision and does not fit well now that kswapd makes a decision
whether to exit the zone scanning loop depending on reclaim progress.

This patch will compact a pgdat if at least the requested number of pages
were reclaimed from unbalanced zones for a given priority. If any zone is
currently balanced, kswapd will not call compaction as it is expected the
necessary pages are already available.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 60 ++++++++++++++++++++++++++++++------------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 78268ca..a9e68b4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2640,7 +2640,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
  */
 static bool kswapd_shrink_zone(struct zone *zone,
 			       struct scan_control *sc,
-			       unsigned long lru_pages)
+			       unsigned long lru_pages,
+			       unsigned long *nr_attempted)
 {
 	unsigned long nr_slab;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
@@ -2656,6 +2657,9 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
 	sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 
+	/* Account for the number of pages attempted to reclaim */
+	*nr_attempted += sc->nr_to_reclaim;
+
 	if (nr_slab == 0 && !zone_reclaimable(zone))
 		zone->all_unreclaimable = 1;
 
@@ -2703,8 +2707,11 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 
 	do {
 		unsigned long lru_pages = 0;
+		unsigned long nr_attempted = 0;
 		unsigned long nr_reclaimed = sc.nr_reclaimed = 0;
+		unsigned long this_reclaimed;
 		bool raise_priority = true;
+		bool pgdat_needs_compaction = (order > 0);
 
 		/*
 		 * Scan in the highmem->dma direction for the highest
@@ -2752,7 +2759,21 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
+			if (!populated_zone(zone))
+				continue;
+
 			lru_pages += zone_reclaimable_pages(zone);
+
+			/*
+			 * If any zone is currently balanced then kswapd will
+			 * not call compaction as it is expected that the
+			 * necessary pages are already available.
+			 */
+			if (pgdat_needs_compaction &&
+					zone_watermark_ok(zone, order,
+						low_wmark_pages(zone),
+						*classzone_idx, 0))
+				pgdat_needs_compaction = false;
 		}
 
 		/*
@@ -2821,7 +2842,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				 * already being scanned that high
 				 * watermark would be met at 100% efficiency.
 				 */
-				if (kswapd_shrink_zone(zone, &sc, lru_pages))
+				if (kswapd_shrink_zone(zone, &sc, lru_pages,
+						       &nr_attempted))
 					raise_priority = false;
 			}
 
@@ -2873,42 +2895,20 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		if (try_to_freeze() || kthread_should_stop())
 			break;
 
+		/* Compact if necessary and kswapd is reclaiming efficiently */
+		this_reclaimed = sc.nr_reclaimed - nr_reclaimed;
+		if (pgdat_needs_compaction && this_reclaimed > nr_attempted)
+			compact_pgdat(pgdat, order);
+
 		/*
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
 		 */
-		if (raise_priority || sc.nr_reclaimed - nr_reclaimed == 0)
+		if (raise_priority || !this_reclaimed)
 			sc.priority--;
 	} while (sc.priority >= 0 &&
 		 !pgdat_balanced(pgdat, order, *classzone_idx));
 
-	/*
-	 * If kswapd was reclaiming at a higher order, it has the option of
-	 * sleeping without all zones being balanced. Before it does, it must
-	 * ensure that the watermarks for order-0 on *all* zones are met and
-	 * that the congestion flags are cleared. The congestion flag must
-	 * be cleared as kswapd is the only mechanism that clears the flag
-	 * and it is potentially going to sleep here.
-	 */
-	if (order) {
-		int zones_need_compaction = 1;
-
-		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-
-			if (!populated_zone(zone))
-				continue;
-
-			/* Check if the memory needs to be defragmented. */
-			if (zone_watermark_ok(zone, order,
-				    low_wmark_pages(zone), *classzone_idx, 0))
-				zones_need_compaction = 0;
-		}
-
-		if (zones_need_compaction)
-			compact_pgdat(pgdat, order);
-	}
-
 out:
 	/*
 	 * Return the order we were reclaiming at so prepare_kswapd_sleep()
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
