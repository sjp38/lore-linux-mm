Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B33FF6B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 10:54:44 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc patch 2/6] vmscan: make distinction between memcg reclaim and LRU list selection
Date: Thu, 12 May 2011 16:53:54 +0200
Message-Id: <1305212038-15445-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
References: <1305212038-15445-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The reclaim code has a single predicate for whether it currently
reclaims on behalf of a memory cgroup, as well as whether it is
reclaiming from the global LRU list or a memory cgroup LRU list.

Up to now, both cases always coincide, but subsequent patches will
change things such that global reclaim will scan memory cgroup lists.

This patch adds a new predicate that tells global reclaim from memory
cgroup reclaim, and then changes all callsites that are actually about
global reclaim heuristics rather than strict LRU list selection.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   96 ++++++++++++++++++++++++++++++++++------------------------
 1 files changed, 56 insertions(+), 40 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f6b435c..ceeb2a5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -104,8 +104,12 @@ struct scan_control {
 	 */
 	reclaim_mode_t reclaim_mode;
 
-	/* Which cgroup do we reclaim from */
-	struct mem_cgroup *mem_cgroup;
+	/*
+	 * The memory cgroup we reclaim on behalf of, and the one we
+	 * are currently reclaiming from.
+	 */
+	struct mem_cgroup *memcg;
+	struct mem_cgroup *current_memcg;
 
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
@@ -154,16 +158,24 @@ static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-#define scanning_global_lru(sc)	(!(sc)->mem_cgroup)
+static bool global_reclaim(struct scan_control *sc)
+{
+	return !sc->memcg;
+}
+static bool scanning_global_lru(struct scan_control *sc)
+{
+	return !sc->current_memcg;
+}
 #else
-#define scanning_global_lru(sc)	(1)
+static bool global_reclaim(struct scan_control *sc) { return 1; }
+static bool scanning_global_lru(struct scan_control *sc) { return 1; }
 #endif
 
 static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
 						  struct scan_control *sc)
 {
 	if (!scanning_global_lru(sc))
-		return mem_cgroup_get_reclaim_stat(sc->mem_cgroup, zone);
+		return mem_cgroup_get_reclaim_stat(sc->current_memcg, zone);
 
 	return &zone->reclaim_stat;
 }
@@ -172,7 +184,7 @@ static unsigned long zone_nr_lru_pages(struct zone *zone,
 				struct scan_control *sc, enum lru_list lru)
 {
 	if (!scanning_global_lru(sc))
-		return mem_cgroup_zone_nr_pages(sc->mem_cgroup, zone, lru);
+		return mem_cgroup_zone_nr_pages(sc->current_memcg, zone, lru);
 
 	return zone_page_state(zone, NR_LRU_BASE + lru);
 }
@@ -635,7 +647,7 @@ static enum page_references page_check_references(struct page *page,
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
 
-	referenced_ptes = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
+	referenced_ptes = page_referenced(page, 1, sc->current_memcg, &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
@@ -1228,7 +1240,7 @@ static int too_many_isolated(struct zone *zone, int file,
 	if (current_is_kswapd())
 		return 0;
 
-	if (!scanning_global_lru(sc))
+	if (!global_reclaim(sc))
 		return 0;
 
 	if (file) {
@@ -1397,6 +1409,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, 0, file);
+	} else {
+		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
+			&page_list, &nr_scanned, sc->order,
+			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
+					ISOLATE_BOTH : ISOLATE_INACTIVE,
+			zone, sc->current_memcg,
+			0, file);
+	}
+
+	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
 			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
@@ -1404,17 +1426,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		else
 			__count_zone_vm_events(PGSCAN_DIRECT, zone,
 					       nr_scanned);
-	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
-			&page_list, &nr_scanned, sc->order,
-			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
-					ISOLATE_BOTH : ISOLATE_INACTIVE,
-			zone, sc->mem_cgroup,
-			0, file);
-		/*
-		 * mem_cgroup_isolate_pages() keeps track of
-		 * scanned pages on its own.
-		 */
 	}
 
 	if (nr_taken == 0) {
@@ -1435,9 +1446,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	}
 
 	local_irq_disable();
-	if (current_is_kswapd())
-		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
-	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
+	if (global_reclaim(sc)) {
+		if (current_is_kswapd())
+			__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
+		__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
+	}
 
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 
@@ -1520,18 +1533,16 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 						&pgscanned, sc->order,
 						ISOLATE_ACTIVE, zone,
 						1, file);
-		zone->pages_scanned += pgscanned;
 	} else {
 		nr_taken = mem_cgroup_isolate_pages(nr_pages, &l_hold,
 						&pgscanned, sc->order,
 						ISOLATE_ACTIVE, zone,
-						sc->mem_cgroup, 1, file);
-		/*
-		 * mem_cgroup_isolate_pages() keeps track of
-		 * scanned pages on its own.
-		 */
+						sc->current_memcg, 1, file);
 	}
 
+	if (global_reclaim(sc))
+		zone->pages_scanned += pgscanned;
+
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
@@ -1552,7 +1563,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			continue;
 		}
 
-		if (page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		if (page_referenced(page, 0, sc->current_memcg, &vm_flags)) {
 			nr_rotated += hpage_nr_pages(page);
 			/*
 			 * Identify referenced, file-backed active pages and
@@ -1629,7 +1640,7 @@ static int inactive_anon_is_low(struct zone *zone, struct scan_control *sc)
 	if (scanning_global_lru(sc))
 		low = inactive_anon_is_low_global(zone);
 	else
-		low = mem_cgroup_inactive_anon_is_low(sc->mem_cgroup);
+		low = mem_cgroup_inactive_anon_is_low(sc->current_memcg);
 	return low;
 }
 #else
@@ -1672,7 +1683,7 @@ static int inactive_file_is_low(struct zone *zone, struct scan_control *sc)
 	if (scanning_global_lru(sc))
 		low = inactive_file_is_low_global(zone);
 	else
-		low = mem_cgroup_inactive_file_is_low(sc->mem_cgroup);
+		low = mem_cgroup_inactive_file_is_low(sc->current_memcg);
 	return low;
 }
 
@@ -1752,7 +1763,7 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	file  = zone_nr_lru_pages(zone, sc, LRU_ACTIVE_FILE) +
 		zone_nr_lru_pages(zone, sc, LRU_INACTIVE_FILE);
 
-	if (scanning_global_lru(sc)) {
+	if (global_reclaim(sc)) {
 		free  = zone_page_state(zone, NR_FREE_PAGES);
 		/* If we have very few page cache pages,
 		   force-scan anon pages. */
@@ -1903,6 +1914,8 @@ restart:
 	nr_scanned = sc->nr_scanned;
 	get_scan_count(zone, sc, nr, priority);
 
+	sc->current_memcg = sc->memcg;
+
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
@@ -1941,6 +1954,9 @@ restart:
 		goto restart;
 
 	throttle_vm_writeout(sc->gfp_mask);
+
+	/* For good measure, noone higher up the stack should look at it */
+	sc->current_memcg = NULL;
 }
 
 /*
@@ -1973,7 +1989,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
 		 */
-		if (scanning_global_lru(sc)) {
+		if (global_reclaim(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
@@ -2038,7 +2054,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	get_mems_allowed();
 	delayacct_freepages_start();
 
-	if (scanning_global_lru(sc))
+	if (global_reclaim(sc))
 		count_vm_event(ALLOCSTALL);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
@@ -2050,7 +2066,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
 		 */
-		if (scanning_global_lru(sc)) {
+		if (global_reclaim(sc)) {
 			unsigned long lru_pages = 0;
 			for_each_zone_zonelist(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask)) {
@@ -2111,7 +2127,7 @@ out:
 		return 0;
 
 	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (scanning_global_lru(sc) && !all_unreclaimable(zonelist, sc))
+	if (global_reclaim(sc) && !all_unreclaimable(zonelist, sc))
 		return 1;
 
 	return 0;
@@ -2129,7 +2145,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
-		.mem_cgroup = NULL,
+		.memcg = NULL,
 		.nodemask = nodemask,
 	};
 
@@ -2158,7 +2174,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.may_swap = !noswap,
 		.swappiness = swappiness,
 		.order = 0,
-		.mem_cgroup = mem,
+		.memcg = mem,
 	};
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2195,7 +2211,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
-		.mem_cgroup = mem_cont,
+		.memcg = mem_cont,
 		.nodemask = NULL, /* we don't care the placement */
 	};
 
@@ -2333,7 +2349,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		.nr_to_reclaim = ULONG_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
-		.mem_cgroup = NULL,
+		.memcg = NULL,
 	};
 loop_again:
 	total_scanned = 0;
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
