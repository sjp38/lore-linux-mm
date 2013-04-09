Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 2CBF46B003B
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 07:18:11 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/10] mm: vmscan: Have kswapd shrink slab only once per priority
Date: Tue,  9 Apr 2013 12:07:03 +0100
Message-Id: <1365505625-9460-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-1-git-send-email-mgorman@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

If kswaps fails to make progress but continues to shrink slab then it'll
either discard all of slab or consume CPU uselessly scanning shrinkers.
This patch causes kswapd to only call the shrinkers once per priority.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9fa72f7..c929d1e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2686,9 +2686,10 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 static bool kswapd_shrink_zone(struct zone *zone,
 			       struct scan_control *sc,
 			       unsigned long lru_pages,
+			       bool shrinking_slab,
 			       unsigned long *nr_attempted)
 {
-	unsigned long nr_slab;
+	unsigned long nr_slab = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct shrink_control shrink = {
 		.gfp_mask = sc->gfp_mask,
@@ -2698,9 +2699,15 @@ static bool kswapd_shrink_zone(struct zone *zone,
 	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
 	shrink_zone(zone, sc);
 
-	reclaim_state->reclaimed_slab = 0;
-	nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
-	sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+	/*
+	 * Slabs are shrunk for each zone once per priority or if the zone
+	 * being balanced is otherwise unreclaimable
+	 */
+	if (shrinking_slab || !zone_reclaimable(zone)) {
+		reclaim_state->reclaimed_slab = 0;
+		nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
+		sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+	}
 
 	/* Account for the number of pages attempted to reclaim */
 	*nr_attempted += sc->nr_to_reclaim;
@@ -2741,6 +2748,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
+	bool shrinking_slab = true;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.priority = DEF_PRIORITY,
@@ -2893,8 +2901,9 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				 * already being scanned that high
 				 * watermark would be met at 100% efficiency.
 				 */
-				if (kswapd_shrink_zone(zone, &sc, lru_pages,
-						       &nr_attempted))
+				if (kswapd_shrink_zone(zone, &sc,
+						lru_pages, shrinking_slab,
+						&nr_attempted))
 					raise_priority = false;
 			}
 
@@ -2933,6 +2942,9 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				pfmemalloc_watermark_ok(pgdat))
 			wake_up(&pgdat->pfmemalloc_wait);
 
+		/* Only shrink slab once per priority */
+		shrinking_slab = false;
+
 		/*
 		 * Fragmentation may mean that the system cannot be rebalanced
 		 * for high-order allocations in all zones. If twice the
@@ -2957,8 +2969,10 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
 		 */
-		if (raise_priority || !this_reclaimed)
+		if (raise_priority || !this_reclaimed) {
 			sc.priority--;
+			shrinking_slab = true;
+		}
 	} while (sc.priority >= 1 &&
 		 !pgdat_balanced(pgdat, order, *classzone_idx));
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
