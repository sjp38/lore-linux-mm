Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id D6A3B6B0039
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:17:22 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id w7so830316lbi.16
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:17:22 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h3si3525676lbd.81.2013.12.16.04.17.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 04:17:21 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v14 10/18] vmscan: remove shrink_control arg from do_try_to_free_pages()
Date: Mon, 16 Dec 2013 16:16:59 +0400
Message-ID: <a3ffeeb63e044912bdc67c9eed2bf802c1063f0c.1387193771.git.vdavydov@parallels.com>
In-Reply-To: <cover.1387193771.git.vdavydov@parallels.com>
References: <cover.1387193771.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

There is no need passing on a shrink_control struct from
try_to_free_pages() and friends to do_try_to_free_pages() and then to
shrink_zones(), because it is only used in shrink_zones() and the only
field initialized on the top level is gfp_mask, which is always equal to
scan_control.gfp_mask. So let's move shrink_control initialization to
shrink_zones().

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   32 ++++++++++++--------------------
 1 file changed, 12 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 035ab3a..33b356e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2274,8 +2274,7 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
  * further reclaim.
  */
 static bool shrink_zones(struct zonelist *zonelist,
-			 struct scan_control *sc,
-			 struct shrink_control *shrink)
+			 struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -2284,6 +2283,9 @@ static bool shrink_zones(struct zonelist *zonelist,
 	unsigned long lru_pages = 0;
 	bool aborted_reclaim = false;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
+	struct shrink_control shrink = {
+		.gfp_mask = sc->gfp_mask,
+	};
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2293,7 +2295,7 @@ static bool shrink_zones(struct zonelist *zonelist,
 	if (buffer_heads_over_limit)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
-	nodes_clear(shrink->nodes_to_scan);
+	nodes_clear(shrink.nodes_to_scan);
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -2308,7 +2310,7 @@ static bool shrink_zones(struct zonelist *zonelist,
 				continue;
 
 			lru_pages += zone_reclaimable_pages(zone);
-			node_set(zone_to_nid(zone), shrink->nodes_to_scan);
+			node_set(zone_to_nid(zone), shrink.nodes_to_scan);
 
 			if (sc->priority != DEF_PRIORITY &&
 			    !zone_reclaimable(zone))
@@ -2353,7 +2355,7 @@ static bool shrink_zones(struct zonelist *zonelist,
 	 * LRU pages over slab pages.
 	 */
 	if (global_reclaim(sc)) {
-		shrink_slab(shrink, sc->nr_scanned, lru_pages);
+		shrink_slab(&shrink, sc->nr_scanned, lru_pages);
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -2400,8 +2402,7 @@ static bool all_unreclaimable(struct zonelist *zonelist,
  * 		else, the number of pages reclaimed
  */
 static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
-					struct scan_control *sc,
-					struct shrink_control *shrink)
+					  struct scan_control *sc)
 {
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
@@ -2416,7 +2417,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
 		sc->nr_scanned = 0;
-		aborted_reclaim = shrink_zones(zonelist, sc, shrink);
+		aborted_reclaim = shrink_zones(zonelist, sc);
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2579,9 +2580,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.target_mem_cgroup = NULL,
 		.nodemask = nodemask,
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
 
 	/*
 	 * Do not enter reclaim if fatal signal was delivered while throttled.
@@ -2595,7 +2593,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				sc.may_writepage,
 				gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
 
@@ -2662,9 +2660,6 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
 
 	/*
 	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
@@ -2679,7 +2674,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 					    sc.may_writepage,
 					    sc.gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc, &shrink);
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
@@ -3335,9 +3330,6 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.order = 0,
 		.priority = DEF_PRIORITY,
 	};
-	struct shrink_control shrink = {
-		.gfp_mask = sc.gfp_mask,
-	};
 	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
 	struct task_struct *p = current;
 	unsigned long nr_reclaimed;
@@ -3347,7 +3339,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
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
