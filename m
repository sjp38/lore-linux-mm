Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id D106F900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:59 -0400 (EDT)
Received: by laar3 with SMTP id r3so48498576laa.3
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga2si5299460wjb.135.2015.06.08.06.56.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:54 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 10/25] mm, vmscan: Make shrink_node decisions more node-centric
Date: Mon,  8 Jun 2015 14:56:16 +0100
Message-Id: <1433771791-30567-11-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Earlier patches focused on having direct reclaim and kswapd use data that
is node-centric for reclaiming but shrink_node() itself still uses too much
zone information. This patch removes unnecessary zone-based information
with the most important decision being whether to continue reclaim or
not. Some memcg APIs are adjusted as a result even though memcg itself
still uses some zone information.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/memcontrol.h |  9 ++++----
 include/linux/mmzone.h     |  4 ++--
 include/linux/swap.h       |  2 +-
 mm/memcontrol.c            | 17 ++++++++-------
 mm/page_alloc.c            |  2 +-
 mm/vmscan.c                | 53 ++++++++++++++++++++++++++--------------------
 6 files changed, 48 insertions(+), 39 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index df225059daf3..b1ba7f5b3851 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -84,7 +84,8 @@ void mem_cgroup_uncharge_list(struct list_head *page_list);
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 			bool lrucare);
 
-struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
+struct lruvec *mem_cgroup_lruvec(struct pglist_data *, struct zone *zone,
+				 struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
 
 bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
@@ -240,10 +241,10 @@ static inline void mem_cgroup_migrate(struct page *oldpage,
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
index fab74af19f26..1830c2180555 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -799,9 +799,9 @@ static inline spinlock_t *zone_lru_lock(struct zone *zone)
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
index 7067eca501e2..bb9597213e39 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -323,7 +323,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 						  unsigned long nr_pages,
 						  gfp_t gfp_mask,
 						  bool may_swap);
-extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
+extern unsigned long mem_cgroup_shrink_node(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 10eed58506a0..7c39930c8d86 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1170,22 +1170,23 @@ out:
 EXPORT_SYMBOL(__mem_cgroup_count_vm_event);
 
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
 
@@ -1721,8 +1722,8 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
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
index 49a29e8ae493..34201c141916 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4879,6 +4879,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 	init_waitqueue_head(&pgdat->kswapd_wait);
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 	pgdat_page_ext_init(pgdat);
+	lruvec_init(node_lruvec(pgdat));
 
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
@@ -4948,7 +4949,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		/* For bootup, initialized properly in watermark setup */
 		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
-		lruvec_init(zone_lruvec(zone));
 		if (!size)
 			continue;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e069decbcfa1..3a6a2fac48e5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2278,13 +2278,14 @@ static bool in_reclaim_compaction(struct scan_control *sc)
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
@@ -2318,21 +2319,27 @@ static inline bool should_continue_reclaim(struct zone *zone,
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
@@ -2342,15 +2349,14 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
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
@@ -2369,23 +2375,24 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 				mem_cgroup_events(memcg, MEMCG_LOW, 1);
 			}
 
-			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+			lruvec = mem_cgroup_lruvec(pgdat,
+					&pgdat->node_zones[reclaim_idx], memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
 			scanned = sc->nr_scanned;
 
 			sc->reclaim_idx = reclaim_idx;
 			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
-			zone_lru_pages += lru_pages;
+			node_lru_pages += lru_pages;
 
 			if (!global_reclaim(sc) && reclaim_idx == classzone_idx)
-				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
+				shrink_slab(sc->gfp_mask, pgdat->node_id,
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
 
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
 			 * cgroups to fulfill the overall scan target for the
-			 * zone.
+			 * node.
 			 *
 			 * Limit reclaim, on the other hand, only cares about
 			 * nr_to_reclaim pages to be reclaimed and it will
@@ -2404,9 +2411,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
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
@@ -2420,7 +2427,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc,
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
-	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
+	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
 	return reclaimable;
@@ -2822,7 +2829,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
 #ifdef CONFIG_MEMCG
 
-unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
+unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
 						gfp_t gfp_mask, bool noswap,
 						struct zone *zone,
 						unsigned long *nr_scanned)
@@ -2834,7 +2841,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 	};
-	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	struct lruvec *lruvec = mem_cgroup_lruvec(zone->zone_pgdat, zone, memcg);
 	int swappiness = mem_cgroup_swappiness(memcg);
 	unsigned long lru_pages;
 
@@ -2848,7 +2855,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
-	 * if we don't reclaim here, the shrink_zone from balance_pgdat
+	 * if we don't reclaim here, the shrink_node from balance_pgdat
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
@@ -2910,7 +2917,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 
 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
 	do {
-		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, zone, memcg);
 
 		if (inactive_anon_is_low(lruvec))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
