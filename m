Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 962416B0027
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 07:18:02 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims at each priority
Date: Tue,  9 Apr 2013 12:06:56 +0100
Message-Id: <1365505625-9460-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1365505625-9460-1-git-send-email-mgorman@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The number of pages kswapd can reclaim is bound by the number of pages it
scans which is related to the size of the zone and the scanning priority. In
many cases the priority remains low because it's reset every SWAP_CLUSTER_MAX
reclaimed pages but in the event kswapd scans a large number of pages it
cannot reclaim, it will raise the priority and potentially discard a large
percentage of the zone as sc->nr_to_reclaim is ULONG_MAX. The user-visible
effect is a reclaim "spike" where a large percentage of memory is suddenly
freed. It would be bad enough if this was just unused memory but because
of how anon/file pages are balanced it is possible that applications get
pushed to swap unnecessarily.

This patch limits the number of pages kswapd will reclaim to the high
watermark. Reclaim will still overshoot due to it not being a hard limit as
shrink_lruvec() will ignore the sc.nr_to_reclaim at DEF_PRIORITY but it
prevents kswapd reclaiming the world at higher priorities. The number of
pages it reclaims is not adjusted for high-order allocations as kswapd will
reclaim excessively if it is to balance zones for high-order allocations.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 53 +++++++++++++++++++++++++++++------------------------
 1 file changed, 29 insertions(+), 24 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 88c5fed..4835a7a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2593,6 +2593,32 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 }
 
 /*
+ * kswapd shrinks the zone by the number of pages required to reach
+ * the high watermark.
+ */
+static void kswapd_shrink_zone(struct zone *zone,
+			       struct scan_control *sc,
+			       unsigned long lru_pages)
+{
+	unsigned long nr_slab;
+	struct reclaim_state *reclaim_state = current->reclaim_state;
+	struct shrink_control shrink = {
+		.gfp_mask = sc->gfp_mask,
+	};
+
+	/* Reclaim above the high watermark. */
+	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
+	shrink_zone(zone, sc);
+
+	reclaim_state->reclaimed_slab = 0;
+	nr_slab = shrink_slab(&shrink, sc->nr_scanned, lru_pages);
+	sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+
+	if (nr_slab == 0 && !zone_reclaimable(zone))
+		zone->all_unreclaimable = 1;
+}
+
+/*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at high_wmark_pages(zone).
  *
@@ -2619,27 +2645,16 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	bool pgdat_is_balanced = false;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
-	unsigned long total_scanned;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
 		.may_swap = 1,
-		/*
-		 * kswapd doesn't want to be bailed out while reclaim. because
-		 * we want to put equal scanning pressure on each zone.
-		 */
-		.nr_to_reclaim = ULONG_MAX,
 		.order = order,
 		.target_mem_cgroup = NULL,
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
 loop_again:
-	total_scanned = 0;
 	sc.priority = DEF_PRIORITY;
 	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
@@ -2710,7 +2725,7 @@ loop_again:
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab, testorder;
+			int testorder;
 			unsigned long balance_gap;
 
 			if (!populated_zone(zone))
@@ -2730,7 +2745,6 @@ loop_again:
 							order, sc.gfp_mask,
 							&nr_soft_scanned);
 			sc.nr_reclaimed += nr_soft_reclaimed;
-			total_scanned += nr_soft_scanned;
 
 			/*
 			 * We put equal pressure on every zone, unless
@@ -2759,17 +2773,8 @@ loop_again:
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
 			    !zone_balanced(zone, testorder,
-					   balance_gap, end_zone)) {
-				shrink_zone(zone, &sc);
-
-				reclaim_state->reclaimed_slab = 0;
-				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
-				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-				total_scanned += sc.nr_scanned;
-
-				if (nr_slab == 0 && !zone_reclaimable(zone))
-					zone->all_unreclaimable = 1;
-			}
+					   balance_gap, end_zone))
+				kswapd_shrink_zone(zone, &sc, lru_pages);
 
 			/*
 			 * If we're getting trouble reclaiming, start doing
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
