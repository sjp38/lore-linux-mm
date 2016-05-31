Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 378246B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:14:28 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h68so64509021lfh.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:14:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si50583079wjy.88.2016.05.31.06.08.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:08:38 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 18/18] mm, vmscan: use proper classzone_idx in should_continue_reclaim()
Date: Tue, 31 May 2016 15:08:18 +0200
Message-Id: <20160531130818.28724-19-vbabka@suse.cz>
In-Reply-To: <20160531130818.28724-1-vbabka@suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

The should_continue_reclaim() function decides during direct reclaim/compaction
whether shrink_zone() should continue reclaming, or whether compaction is ready
to proceed in that zone. This relies mainly on the compaction_suitable() check,
but by passing a zero classzone_idx, there can be false positives and reclaim
terminates prematurely. Fix this by passing proper classzone_idx.

Additionally, the function checks whether (2UL << pages) were reclaimed. This
however overlaps with the same gap used by compaction_suitable(), and since the
number sc->nr_reclaimed is accumulated over all reclaimed zones, it doesn't
make much sense for deciding about a given single zone anyway. So just drop
this code.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 31 +++++++++----------------------
 1 file changed, 9 insertions(+), 22 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 640d2e615c36..391e5d2c4e32 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2309,11 +2309,9 @@ static bool in_reclaim_compaction(struct scan_control *sc)
 static inline bool should_continue_reclaim(struct zone *zone,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
-					struct scan_control *sc)
+					struct scan_control *sc,
+					int classzone_idx)
 {
-	unsigned long pages_for_compaction;
-	unsigned long inactive_lru_pages;
-
 	/* If not in reclaim/compaction mode, stop */
 	if (!in_reclaim_compaction(sc))
 		return false;
@@ -2341,20 +2339,8 @@ static inline bool should_continue_reclaim(struct zone *zone,
 			return false;
 	}
 
-	/*
-	 * If we have not reclaimed enough pages for compaction and the
-	 * inactive lists are large enough, continue reclaiming
-	 */
-	pages_for_compaction = compact_gap(sc->order);
-	inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
-	if (get_nr_swap_pages() > 0)
-		inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
-	if (sc->nr_reclaimed < pages_for_compaction &&
-			inactive_lru_pages > pages_for_compaction)
-		return true;
-
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(zone, sc->order, 0, 0)) {
+	switch (compaction_suitable(zone, sc->order, 0, classzone_idx)) {
 	case COMPACT_PARTIAL:
 	case COMPACT_CONTINUE:
 		return false;
@@ -2364,11 +2350,12 @@ static inline bool should_continue_reclaim(struct zone *zone,
 }
 
 static bool shrink_zone(struct zone *zone, struct scan_control *sc,
-			bool is_classzone)
+			int classzone_idx)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
+	bool is_classzone = (classzone_idx == zone_idx(zone));
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2450,7 +2437,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			reclaimable = true;
 
 	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
-					 sc->nr_scanned - nr_scanned, sc));
+			 sc->nr_scanned - nr_scanned, sc, classzone_idx));
 
 	return reclaimable;
 }
@@ -2580,7 +2567,7 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
+		shrink_zone(zone, sc, classzone_idx);
 	}
 
 	/*
@@ -3076,7 +3063,7 @@ static bool kswapd_shrink_zone(struct zone *zone,
 						balance_gap, classzone_idx))
 		return true;
 
-	shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
+	shrink_zone(zone, sc, classzone_idx);
 
 	clear_bit(ZONE_WRITEBACK, &zone->flags);
 
@@ -3678,7 +3665,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * priorities until we have enough memory freed.
 		 */
 		do {
-			shrink_zone(zone, &sc, true);
+			shrink_zone(zone, &sc, zone_idx(zone));
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
