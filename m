Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2756B006E
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:02 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id n7so8086492lam.2
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:02 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id d9si14152656lad.120.2013.12.02.03.20.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:01 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 07/18] vmscan: move call to shrink_slab() to shrink_zones()
Date: Mon, 2 Dec 2013 15:19:42 +0400
Message-ID: <852be876efc790ff8ed271d3d2e82cd85d0fb6d6.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

This reduces the indentation level of do_try_to_free_pages() and removes
extra loop over all eligible zones counting the number of on-LRU pages.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c |   57 ++++++++++++++++++++++++++-------------------------------
 1 file changed, 26 insertions(+), 31 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6946997..ba1ad6e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2273,13 +2273,17 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
  * the caller that it should consider retrying the allocation instead of
  * further reclaim.
  */
-static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
+static bool shrink_zones(struct zonelist *zonelist,
+			 struct scan_control *sc,
+			 struct shrink_control *shrink)
 {
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
+	unsigned long lru_pages = 0;
 	bool aborted_reclaim = false;
+	struct reclaim_state *reclaim_state = current->reclaim_state;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2289,6 +2293,8 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	if (buffer_heads_over_limit)
 		sc->gfp_mask |= __GFP_HIGHMEM;
 
+	nodes_clear(shrink->nodes_to_scan);
+
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
 		if (!populated_zone(zone))
@@ -2300,6 +2306,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		if (global_reclaim(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
+
+			lru_pages += zone_reclaimable_pages(zone);
+			node_set(zone_to_nid(zone), shrink->nodes_to_scan);
+
 			if (sc->priority != DEF_PRIORITY &&
 			    !zone_reclaimable(zone))
 				continue;	/* Let kswapd poll it */
@@ -2336,6 +2346,20 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 		shrink_zone(zone, sc);
 	}
 
+	/*
+	 * Don't shrink slabs when reclaiming memory from over limit
+	 * cgroups but do shrink slab at least once when aborting
+	 * reclaim for compaction to avoid unevenly scanning file/anon
+	 * LRU pages over slab pages.
+	 */
+	if (global_reclaim(sc)) {
+		shrink_slab(shrink, sc->nr_scanned, lru_pages);
+		if (reclaim_state) {
+			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
+		}
+	}
+
 	return aborted_reclaim;
 }
 
@@ -2380,9 +2404,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					struct shrink_control *shrink)
 {
 	unsigned long total_scanned = 0;
-	struct reclaim_state *reclaim_state = current->reclaim_state;
-	struct zoneref *z;
-	struct zone *zone;
 	unsigned long writeback_threshold;
 	bool aborted_reclaim;
 
@@ -2395,34 +2416,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
 		sc->nr_scanned = 0;
-		aborted_reclaim = shrink_zones(zonelist, sc);
-
-		/*
-		 * Don't shrink slabs when reclaiming memory from over limit
-		 * cgroups but do shrink slab at least once when aborting
-		 * reclaim for compaction to avoid unevenly scanning file/anon
-		 * LRU pages over slab pages.
-		 */
-		if (global_reclaim(sc)) {
-			unsigned long lru_pages = 0;
+		aborted_reclaim = shrink_zones(zonelist, sc, shrink);
 
-			nodes_clear(shrink->nodes_to_scan);
-			for_each_zone_zonelist(zone, z, zonelist,
-					gfp_zone(sc->gfp_mask)) {
-				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-					continue;
-
-				lru_pages += zone_reclaimable_pages(zone);
-				node_set(zone_to_nid(zone),
-					 shrink->nodes_to_scan);
-			}
-
-			shrink_slab(shrink, sc->nr_scanned, lru_pages);
-			if (reclaim_state) {
-				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-				reclaim_state->reclaimed_slab = 0;
-			}
-		}
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
 			goto out;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
