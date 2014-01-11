Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id C1C786B0039
	for <linux-mm@kvack.org>; Sat, 11 Jan 2014 07:36:50 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id p9so2261238lbv.19
        for <linux-mm@kvack.org>; Sat, 11 Jan 2014 04:36:50 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id wj2si5251231lbb.118.2014.01.11.04.36.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 11 Jan 2014 04:36:49 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 5/5] mm: vmscan: remove shrink_control arg from do_try_to_free_pages()
Date: Sat, 11 Jan 2014 16:36:35 +0400
Message-ID: <e0f12399d20d6fd7949bccda73d8dfe0275fb16c.1389443272.git.vdavydov@parallels.com>
In-Reply-To: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
References: <7d37542211678a637dc6b4d995fd6f1e89100538.1389443272.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@gmail.com>

There is no need passing on a shrink_control struct from
try_to_free_pages() and friends to do_try_to_free_pages() and then to
shrink_zones(), because it is only used in shrink_zones() and the only
field initialized on the top level is gfp_mask, which is always equal to
scan_control.gfp_mask. So let's move shrink_control initialization to
shrink_zones().

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@gmail.com>
---
 mm/vmscan.c |   32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b364f3c..b09e1cd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2291,8 +2291,7 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
  * the caller that it should consider retrying the allocation instead of
  * further reclaim.
  */
-static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
-			 struct shrink_control *shrink)
+static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -2301,6 +2300,9 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	unsigned long lru_pages = 0;
 	bool aborted_reclaim = false;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
+	struct shrink_control shrink = {
+		.gfp_mask = sc->gfp_mask,
+	};
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2310,7 +2312,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	if (buffer_heads_over_limit)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
-	nodes_clear(shrink->nodes_to_scan);
+	nodes_clear(shrink.nodes_to_scan);
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2325,7 +2327,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 				continue;
 
 			lru_pages += zone_reclaimable_pages(zone);
-			node_set(zone_to_nid(zone), shrink->nodes_to_scan);
+			node_set(zone_to_nid(zone), shrink.nodes_to_scan);
 
 			if (sc->priority != DEF_PRIORITY &&
 			    !zone_reclaimable(zone))
@@ -2370,7 +2372,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
 	 * pages.
 	 */
 	if (global_reclaim(sc)) {
-		shrink_slab(shrink, sc->nr_scanned, lru_pages);
+		shrink_slab(&shrink, sc->nr_scanned, lru_pages);
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -2417,8 +2419,7 @@ static bool all_unreclaimable(struct zonelist *zonelist,
  * 		else, the number of pages reclaimed
  */
 static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
-					struct scan_control *sc,
-					struct shrink_control *shrink)
+					  struct scan_control *sc)
 {
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
@@ -2433,7 +2434,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
 		sc->nr_scanned = 0;
-		aborted_reclaim = shrink_zones(zonelist, sc, shrink);
+		aborted_reclaim = shrink_zones(zonelist, sc);
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2596,9 +2597,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.target_mem_cgroup = NULL,
 		.nodemask = nodemask,
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
 
 	/*
 	 * Do not enter reclaim if fatal signal was delivered while throttled.
@@ -2612,7 +2610,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				sc.may_writepage,
 				gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
 
@@ -2679,9 +2677,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
 
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
@@ -2696,7 +2691,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					    sc.may_writepage,
 					    sc.gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
@@ -3352,9 +3347,6 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.order = 0,
 		.priority = DEF_PRIORITY,
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
@@ -3364,7 +3356,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
