Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4125F6B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 08:56:07 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so9947091pdi.2
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 05:56:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tw8si30958628pbc.2.2015.01.14.05.56.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 05:56:05 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] vmscan: move reclaim_state handling to shrink_slab
Date: Wed, 14 Jan 2015 16:55:36 +0300
Message-ID: <1421243736-21367-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

current->reclaim_state is only used to count the number of slab pages
reclaimed by shrink_slab(). So instead of initializing it before we are
going to call try_to_free_pages() or shrink_zone(), let's set in
directly in shrink_slab().

This patch also makes shrink_slab() return the number of reclaimed slab
pages (obtained from reclaim_state) instead of the number of reclaimed
objects, because the latter is not of much use - it was only checked by
drop_slab() to decide whether it should continue reclaim or abort. The
number of reclaimed pages is more appropriate, because it also can be
used by shrink_zone() to accumulate scan_control->nr_reclaimed.

Note that after this patch try_to_free_mem_cgroup_pages() will count not
only reclaimed user pages, but also slab pages, which is expected,
because it can reclaim kmem from kmem-active sub cgroups.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/page_alloc.c |    4 ---
 mm/vmscan.c     |   73 ++++++++++++++++++++-----------------------------------
 2 files changed, 27 insertions(+), 50 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e1963ea0684a..f528e4ba91b5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2448,7 +2448,6 @@ static int
 __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 		  nodemask_t *nodemask)
 {
-	struct reclaim_state reclaim_state;
 	int progress;
 
 	cond_resched();
@@ -2457,12 +2456,9 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order, struct zonelist *zonelist,
 	cpuset_memory_pressure_bump();
 	current->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	current->reclaim_state = &reclaim_state;
 
 	progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
 
-	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	current->flags &= ~PF_MEMALLOC;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 16f3e45742d6..9b61fcb0b45b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -229,10 +229,10 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
 
-static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
-				    struct shrinker *shrinker,
-				    unsigned long nr_scanned,
-				    unsigned long nr_eligible)
+static void do_shrink_slab(struct shrink_control *shrinkctl,
+			   struct shrinker *shrinker,
+			   unsigned long nr_scanned,
+			   unsigned long nr_eligible)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -246,7 +246,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0)
-		return 0;
+		return;
 
 	/*
 	 * copy the current shrinker scan count into a local variable
@@ -337,7 +337,6 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
 
 	trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
-	return freed;
 }
 
 /**
@@ -367,15 +366,17 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  * the ->seeks setting of the shrink function, which indicates the
  * cost to recreate an object relative to that of an LRU page.
  *
- * Returns the number of reclaimed slab objects.
+ * Returns the number of reclaimed slab pages.
  */
 static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 				 struct mem_cgroup *memcg,
 				 unsigned long nr_scanned,
 				 unsigned long nr_eligible)
 {
+	struct reclaim_state reclaim_state = {
+		.reclaimed_slab = 0,
+	};
 	struct shrinker *shrinker;
-	unsigned long freed = 0;
 
 	if (memcg && !memcg_kmem_is_active(memcg))
 		return 0;
@@ -384,16 +385,12 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		nr_scanned = SWAP_CLUSTER_MAX;
 
 	if (!down_read_trylock(&shrinker_rwsem)) {
-		/*
-		 * If we would return 0, our callers would understand that we
-		 * have nothing else to shrink and give up trying. By returning
-		 * 1 we keep it going and assume we'll be able to shrink next
-		 * time.
-		 */
-		freed = 1;
-		goto out;
+		cond_resched();
+		return 0;
 	}
 
+	current->reclaim_state = &reclaim_state;
+
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
@@ -407,13 +404,15 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
+		do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
 	}
 
+	current->reclaim_state = NULL;
+
 	up_read(&shrinker_rwsem);
-out:
+
 	cond_resched();
-	return freed;
+	return reclaim_state.reclaimed_slab;
 }
 
 void drop_slab_node(int nid)
@@ -428,7 +427,7 @@ void drop_slab_node(int nid)
 			freed += shrink_slab(GFP_KERNEL, nid, memcg,
 					     1000, 1000);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
-	} while (freed > 10);
+	} while (freed);
 }
 
 void drop_slab(void)
@@ -2339,7 +2338,6 @@ static inline bool should_continue_reclaim(struct zone *zone,
 static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			bool is_classzone)
 {
-	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
 
@@ -2369,9 +2367,10 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			zone_lru_pages += lru_pages;
 
 			if (memcg && is_classzone)
-				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
-					    memcg, sc->nr_scanned - scanned,
-					    lru_pages);
+				sc->nr_reclaimed += shrink_slab(sc->gfp_mask,
+						zone_to_nid(zone), memcg,
+						sc->nr_scanned - scanned,
+						lru_pages);
 
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
@@ -2396,14 +2395,10 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		 * the eligible LRU pages were scanned.
 		 */
 		if (global_reclaim(sc) && is_classzone)
-			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
-				    sc->nr_scanned - nr_scanned,
-				    zone_lru_pages);
-
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
+			sc->nr_reclaimed += shrink_slab(sc->gfp_mask,
+					zone_to_nid(zone), NULL,
+					sc->nr_scanned - nr_scanned,
+					zone_lru_pages);
 
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
 			   sc->nr_scanned - nr_scanned,
@@ -3367,17 +3362,12 @@ static int kswapd(void *p)
 	int balanced_classzone_idx;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
-
-	struct reclaim_state reclaim_state = {
-		.reclaimed_slab = 0,
-	};
 	const struct cpumask *cpumask = cpumask_of_node(pgdat->node_id);
 
 	lockdep_set_current_reclaim_state(GFP_KERNEL);
 
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(tsk, cpumask);
-	current->reclaim_state = &reclaim_state;
 
 	/*
 	 * Tell the memory management that we're a "memory allocator",
@@ -3449,7 +3439,6 @@ static int kswapd(void *p)
 	}
 
 	tsk->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD);
-	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 
 	return 0;
@@ -3492,7 +3481,6 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
  */
 unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 {
-	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = nr_to_reclaim,
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
@@ -3508,12 +3496,9 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 
 	p->flags |= PF_MEMALLOC;
 	lockdep_set_current_reclaim_state(sc.gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
 
-	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	p->flags &= ~PF_MEMALLOC;
 
@@ -3678,7 +3663,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	/* Minimum pages needed in order to stay on node */
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
-	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
 		.gfp_mask = (gfp_mask = memalloc_noio_flags(gfp_mask)),
@@ -3697,8 +3681,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	 */
 	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
 	lockdep_set_current_reclaim_state(gfp_mask);
-	reclaim_state.reclaimed_slab = 0;
-	p->reclaim_state = &reclaim_state;
 
 	if (zone_pagecache_reclaimable(zone) > zone->min_unmapped_pages) {
 		/*
@@ -3710,7 +3692,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
-	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
 	lockdep_clear_current_reclaim_state();
 	return sc.nr_reclaimed >= nr_pages;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
