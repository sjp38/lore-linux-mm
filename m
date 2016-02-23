Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA2E6B0258
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 08:51:14 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id a4so209925484wme.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 05:51:14 -0800 (PST)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id bm5si44796840wjb.92.2016.02.23.05.45.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 05:45:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 5C80198E22
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:45:19 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 13/27] mm, vmscan: Make shrink_node decisions more node-centric
Date: Tue, 23 Feb 2016 13:45:02 +0000
Message-Id: <1456235116-32385-14-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
References: <1456235116-32385-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Earlier patches focused on having direct reclaim and kswapd use data that
is node-centric for reclaiming but shrink_node() itself still uses too much
zone information. This patch removes unnecessary zone-based information
with the most important decision being whether to continue reclaim or
not. Some memcg APIs are adjusted as a result even though memcg itself
still uses some zone information.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/memcontrol.h |  9 +++----
 include/linux/mmzone.h     |  4 ++--
 include/linux/swap.h       |  2 +-
 mm/memcontrol.c            | 17 +++++++-------
 mm/page_alloc.c            |  2 +-
 mm/vmscan.c                | 58 ++++++++++++++++++++++++++--------------------
 mm/workingset.c            |  6 ++---
 7 files changed, 54 insertions(+), 44 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f5626a5c88c2..51f4441a69fc 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -306,7 +306,8 @@ void mem_cgroup_uncharge_list(struct list_head *page_list);
 
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
 
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+struct lruvec *mem_cgroup_lruvec(struct pglist_data *, struct zone *zone,
+				 struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
@@ -592,10 +593,10 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
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
index 8f164ce06627..ffe8a6e606b9 100644
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
index a776f6506522..2137416c1f15 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -324,7 +324,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 						  unsigned long nr_pages,
 						  gfp_t gfp_mask,
 						  bool may_swap);
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
+extern unsigned long mem_cgroup_shrink_node(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e9e35424c57e..1cfb7c40fa36 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -943,22 +943,23 @@ static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
 	     iter = mem_cgroup_iter(NULL, iter, NULL))
 
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
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
-				      struct mem_cgroup *memcg)
+struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
+				 struct zone *zone, struct mem_cgroup *memcg)
 {
 	struct mem_cgroup_per_zone *mz;
 	struct lruvec *lruvec;
 
 	if (mem_cgroup_disabled()) {
-		lruvec = zone_lruvec(zone);
+		lruvec = node_lruvec(pgdat);
 		goto out;
 	}
 
@@ -1454,8 +1455,8 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
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
index 34faebad3972..d320524d68c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5521,6 +5521,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	init_waitqueue_head(&pgdat->kcompactd_wait);
 #endif
 	pgdat_page_ext_init(pgdat);
+	lruvec_init(node_lruvec(pgdat));
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
@@ -5585,7 +5586,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
-		lruvec_init(zone_lruvec(zone));
 		if (!size)
 			continue;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 39ad2ab76a2b..3f67edc69e04 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2219,10 +2219,11 @@ static inline void init_tlb_ubc(void)
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
@@ -2355,13 +2356,14 @@ static bool in_reclaim_compaction(struct scan_control *sc)
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
@@ -2395,21 +2397,27 @@ static inline bool should_continue_reclaim(struct zone *zone,
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
+		switch (compaction_suitable(zone, sc->order, 0, 0)) {
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
@@ -2419,15 +2427,14 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
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
@@ -2449,11 +2456,11 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 			scanned = sc->nr_scanned;
 
 			sc->reclaim_idx = reclaim_idx;
-			shrink_zone_memcg(zone, memcg, sc, &lru_pages);
-			zone_lru_pages += lru_pages;
+			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
+			node_lru_pages += lru_pages;
 
 			if (!global_reclaim(sc) && reclaim_idx == classzone_idx)
-				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
+				shrink_slab(sc->gfp_mask, pgdat->node_id,
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
 
@@ -2465,7 +2472,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
 			 * cgroups to fulfill the overall scan target for the
-			 * zone.
+			 * node.
 			 *
 			 * Limit reclaim, on the other hand, only cares about
 			 * nr_to_reclaim pages to be reclaimed and it will
@@ -2484,9 +2491,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 		 * the eligible LRU pages were scanned.
 		 */
 		if (global_reclaim(sc) && reclaim_idx == classzone_idx)
-			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
+			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
 				    sc->nr_scanned - nr_scanned,
-				    zone_lru_pages);
+				    node_lru_pages);
 
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -2501,7 +2508,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
-	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
+	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
 	return reclaimable;
@@ -2887,7 +2894,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
 #ifdef CONFIG_MEMCG
 
-unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
+unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned)
@@ -2897,6 +2904,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.target_mem_cgroup = memcg,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
+		.reclaim_idx = zone_idx(zone),
 		.may_swap = !noswap,
 	};
 	unsigned long lru_pages;
@@ -2911,11 +2919,11 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
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
 
@@ -2973,7 +2981,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, zone, memcg);
 
 		if (inactive_anon_is_low(lruvec))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
diff --git a/mm/workingset.c b/mm/workingset.c
index 173399b239be..f68cc74a7795 100644
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
@@ -317,7 +317,7 @@ void workingset_activation(struct page *page)
 	 */
 	if (!mem_cgroup_disabled() && !page_memcg(page))
 		goto out;
-	lruvec = mem_cgroup_zone_lruvec(page_zone(page), page_memcg(page));
+	lruvec = mem_cgroup_lruvec(page_zone(page)->zone_pgdat, page_zone(page), page_memcg(page));
 	atomic_long_inc(&lruvec->inactive_age);
 out:
 	unlock_page_memcg(page);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
