Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABED1828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:40:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a66so21749057wme.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:40:02 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id 8si4586561wmu.80.2016.07.01.08.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:40:00 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 1A0191C14A3
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:40:00 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 12/31] mm, vmscan: make shrink_node decisions more node-centric
Date: Fri,  1 Jul 2016 16:37:27 +0100
Message-Id: <1467387466-10022-13-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Earlier patches focused on having direct reclaim and kswapd use data that
is node-centric for reclaiming but shrink_node() itself still uses too
much zone information.  This patch removes unnecessary zone-based
information with the most important decision being whether to continue
reclaim or not.  Some memcg APIs are adjusted as a result even though
memcg itself still uses some zone information.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/memcontrol.h | 19 ++++++++--------
 include/linux/mmzone.h     |  4 ++--
 include/linux/swap.h       |  2 +-
 mm/memcontrol.c            |  4 ++--
 mm/page_alloc.c            |  2 +-
 mm/vmscan.c                | 57 ++++++++++++++++++++++++++--------------------
 mm/workingset.c            |  6 ++---
 7 files changed, 51 insertions(+), 43 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1927dcb6921e..48b43c709ed7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -325,22 +325,23 @@ mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
 }
 
 /**
- * mem_cgroup_zone_lruvec - get the lru list vector for a zone and memcg
+ * mem_cgroup_lruvec - get the lru list vector for a node or a memcg zone
+ * @node: node of the wanted lruvec
  * @zone: zone of the wanted lruvec
  * @memcg: memcg of the wanted lruvec
  *
- * Returns the lru list vector holding pages for the given @zone and
- * @mem.  This can be the global zone lruvec, if the memory controller
+ * Returns the lru list vector holding pages for a given @node or a given
+ * @memcg and @zone. This can be the node lruvec, if the memory controller
  * is disabled.
  */
-static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
-						    struct mem_cgroup *memcg)
+static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
+				struct zone *zone, struct mem_cgroup *memcg)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
-		lruvec = zone_lruvec(zone);
+		lruvec = node_lruvec(pgdat);
 		goto out;
 	}
 
@@ -610,10 +611,10 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
 {
 }
 
-static inline struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
-						    struct mem_cgroup *memcg)
+static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
+				struct zone *zone, struct mem_cgroup *memcg)
 {
-	return zone_lruvec(zone);
+	return node_lruvec(pgdat);
 }
 
 static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index eb74e63df5cf..f88cbbb476c8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -739,9 +739,9 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
 	return &zone->zone_pgdat->lru_lock;
 }
 
-static inline struct lruvec *zone_lruvec(struct zone *zone)
+static inline struct lruvec *node_lruvec(struct pglist_data *pgdat)
 {
-	return &zone->zone_pgdat->lruvec;
+	return &pgdat->lruvec;
 }
 
 static inline unsigned long pgdat_end_pfn(pg_data_t *pgdat)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 916e2eddecd6..0ad616d7c381 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -316,7 +316,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 						  unsigned long nr_pages,
 						  gfp_t gfp_mask,
 						  bool may_swap);
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
+extern unsigned long mem_cgroup_shrink_node(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 50c86ad121bc..c9ebec98e92a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1432,8 +1432,8 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 			}
 			continue;
 		}
-		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
-						     zone, &nr_scanned);
+		total += mem_cgroup_shrink_node(victim, gfp_mask, false,
+					zone, &nr_scanned);
 		*total_scanned += nr_scanned;
 		if (!soft_limit_excess(root_memcg))
 			break;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f58548139bf2..b76ea2527c09 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5954,6 +5954,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 #endif
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
+	lruvec_init(node_lruvec(pgdat));
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
@@ -6016,7 +6017,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
-		lruvec_init(zone_lruvec(zone));
 		if (!size)
 			continue;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2f898ba2ee2e..b8e0f76b6e00 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2226,10 +2226,11 @@ static inline void init_tlb_ubc(void)
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_zone_memcg(struct zone *zone, struct mem_cgroup *memcg,
+static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memcg,
 			      struct scan_control *sc, unsigned long *lru_pages)
 {
-	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	struct zone *zone = &pgdat->node_zones[sc->reclaim_idx];
+	struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, zone, memcg);
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -2362,13 +2363,14 @@ static bool in_reclaim_compaction(struct scan_control *sc)
  * calls try_to_compact_zone() that it will have enough free pages to succeed.
  * It will give up earlier than that if there is difficulty reclaiming pages.
  */
-static inline bool should_continue_reclaim(struct zone *zone,
+static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
 					struct scan_control *sc)
 {
 	unsigned long pages_for_compaction;
 	unsigned long inactive_lru_pages;
+	int z;
 
 	/* If not in reclaim/compaction mode, stop */
 	if (!in_reclaim_compaction(sc))
@@ -2402,21 +2404,27 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE);
+	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
 	if (get_nr_swap_pages() > 0)
-		inactive_lru_pages += node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
+		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(zone, sc->order, 0, 0)) {
-	case COMPACT_PARTIAL:
-	case COMPACT_CONTINUE:
-		return false;
-	default:
-		return true;
+	for (z = 0; z <= sc->reclaim_idx; z++) {
+		struct zone *zone = &pgdat->node_zones[z];
+
+		switch (compaction_suitable(zone, sc->order, 0, sc->reclaim_idx)) {
+		case COMPACT_PARTIAL:
+		case COMPACT_CONTINUE:
+			return false;
+		default:
+			/* check next zone */
+			;
+		}
 	}
+	return true;
 }
 
 static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
@@ -2425,15 +2433,14 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
-	struct zone *zone = &pgdat->node_zones[classzone_idx];
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
 		struct mem_cgroup_reclaim_cookie reclaim = {
-			.zone = zone,
+			.zone = &pgdat->node_zones[classzone_idx],
 			.priority = sc->priority,
 		};
-		unsigned long zone_lru_pages = 0;
+		unsigned long node_lru_pages = 0;
 		struct mem_cgroup *memcg;
 
 		nr_reclaimed = sc->nr_reclaimed;
@@ -2454,11 +2461,11 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
 
-			shrink_zone_memcg(zone, memcg, sc, &lru_pages);
-			zone_lru_pages += lru_pages;
+			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
+			node_lru_pages += lru_pages;
 
 			if (!global_reclaim(sc))
-				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
+				shrink_slab(sc->gfp_mask, pgdat->node_id,
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
 
@@ -2470,7 +2477,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
 			 * cgroups to fulfill the overall scan target for the
-			 * zone.
+			 * node.
 			 *
 			 * Limit reclaim, on the other hand, only cares about
 			 * nr_to_reclaim pages to be reclaimed and it will
@@ -2489,9 +2496,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 		 * the eligible LRU pages were scanned.
 		 */
 		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
+			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
 				    sc->nr_scanned - nr_scanned,
-				    zone_lru_pages);
+				    node_lru_pages);
 
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -2506,7 +2513,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
-	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
+	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
 	return reclaimable;
@@ -2903,7 +2910,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
 #ifdef CONFIG_MEMCG
 
-unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
+unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned)
@@ -2928,11 +2935,11 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
-	 * if we don't reclaim here, the shrink_zone from balance_pgdat
+	 * if we don't reclaim here, the shrink_node from balance_pgdat
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_zone_memcg(zone, memcg, &sc, &lru_pages);
+	shrink_node_memcg(zone->zone_pgdat, memcg, &sc, &lru_pages);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2991,7 +2998,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, zone, memcg);
 
 		if (inactive_list_is_low(lruvec, false))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
diff --git a/mm/workingset.c b/mm/workingset.c
index ebe14445809a..de68ad681585 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -218,7 +218,7 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	VM_BUG_ON_PAGE(page_count(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
-	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, zone, memcg);
 	eviction = atomic_long_inc_return(&lruvec->inactive_age);
 	return pack_shadow(memcgid, zone, eviction);
 }
@@ -267,7 +267,7 @@ bool workingset_refault(void *shadow)
 		rcu_read_unlock();
 		return false;
 	}
-	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	lruvec = mem_cgroup_lruvec(zone->zone_pgdat, zone, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
 	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
 	rcu_read_unlock();
@@ -319,7 +319,7 @@ void workingset_activation(struct page *page)
 	memcg = page_memcg_rcu(page);
 	if (!mem_cgroup_disabled() && !memcg)
 		goto out;
-	lruvec = mem_cgroup_zone_lruvec(page_zone(page), memcg);
+	lruvec = mem_cgroup_lruvec(page_pgdat(page), page_zone(page), memcg);
 	atomic_long_inc(&lruvec->inactive_age);
 out:
 	rcu_read_unlock();
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
