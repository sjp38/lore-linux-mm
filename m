Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3F9828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:42:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a66so21786310wme.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:42:04 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id p4si3967202wjz.184.2016.07.01.08.42.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 08:42:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 3BD9298E1F
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 15:42:03 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 24/31] mm, vmscan: Avoid passing in classzone_idx unnecessarily to compaction_ready
Date: Fri,  1 Jul 2016 16:37:39 +0100
Message-Id: <1467387466-10022-25-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

The scan_control structure has enough information available for
compaction_ready() to make a decision. The classzone_idx manipulations in
shrink_zones() are no longer necessary as the highest populated zone is
no longer used to determine if shrink_slab should be called or not.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 28 ++++++++--------------------
 1 file changed, 8 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6534fbe1b96f..c4094d7771a7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2521,7 +2521,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
  * Returns true if compaction should go ahead for a high-order request, or
  * the high-order allocation would succeed without compaction.
  */
-static inline bool compaction_ready(struct zone *zone, int order, int classzone_idx)
+static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
 {
 	unsigned long watermark;
 	bool watermark_ok;
@@ -2532,21 +2532,21 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
 	 * there is a buffer of free pages available to give compaction
 	 * a reasonable chance of completing and allocating the page
 	 */
-	watermark = high_wmark_pages(zone) + (2UL << order);
-	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, classzone_idx);
+	watermark = high_wmark_pages(zone) + (2UL << sc->order);
+	watermark_ok = zone_watermark_ok_safe(zone, 0, watermark, sc->reclaim_idx);
 
 	/*
 	 * If compaction is deferred, reclaim up to a point where
 	 * compaction will have a chance of success when re-enabled
 	 */
-	if (compaction_deferred(zone, order))
+	if (compaction_deferred(zone, sc->order))
 		return watermark_ok;
 
 	/*
 	 * If compaction is not ready to start and allocation is not likely
 	 * to succeed without it, then keep reclaiming.
 	 */
-	if (compaction_suitable(zone, order, 0, classzone_idx) == COMPACT_SKIPPED)
+	if (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx) == COMPACT_SKIPPED)
 		return false;
 
 	return watermark_ok;
@@ -2567,7 +2567,6 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
-	enum zone_type classzone_idx;
 	pg_data_t *last_pgdat = NULL;
 
 	/*
@@ -2578,7 +2577,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	orig_mask = sc->gfp_mask;
 	if (buffer_heads_over_limit) {
 		sc->gfp_mask |= __GFP_HIGHMEM;
-		sc->reclaim_idx = classzone_idx = gfp_zone(sc->gfp_mask);
+		sc->reclaim_idx = gfp_zone(sc->gfp_mask);
 	}
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
@@ -2587,17 +2586,6 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			continue;
 
 		/*
-		 * Note that reclaim_idx does not change as it is the highest
-		 * zone reclaimed from which for empty zones is a no-op but
-		 * classzone_idx is used by shrink_node to test if the slabs
-		 * should be shrunk on a given node.
-		 */
-		classzone_idx = sc->reclaim_idx;
-		while (!populated_zone(zone->zone_pgdat->node_zones +
-							classzone_idx))
-			classzone_idx--;
-
-		/*
 		 * Shrink each node in the zonelist once. If the zonelist is
 		 * ordered by zone (not the default) then a node may be
 		 * shrunk multiple times but in that case the user prefers
@@ -2631,8 +2619,8 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			 */
 			if (IS_ENABLED(CONFIG_COMPACTION) &&
 			    sc->order > PAGE_ALLOC_COSTLY_ORDER &&
-			    zonelist_zone_idx(z) <= classzone_idx &&
-			    compaction_ready(zone, sc->order, classzone_idx)) {
+			    zonelist_zone_idx(z) <= sc->reclaim_idx &&
+			    compaction_ready(zone, sc)) {
 				sc->compaction_ready = true;
 				continue;
 			}
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
