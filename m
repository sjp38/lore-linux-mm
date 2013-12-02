Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id DEB8F6B0078
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 06:20:10 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id c11so8543718lbj.9
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 03:20:10 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h3si4257657lbd.171.2013.12.02.03.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 03:20:09 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v12 09/18] vmscan: shrink slab on memcg pressure
Date: Mon, 2 Dec 2013 15:19:44 +0400
Message-ID: <be01fd9afeedb7d5c7979347f4d6ddaf67c9082d.1385974612.git.vdavydov@parallels.com>
In-Reply-To: <cover.1385974612.git.vdavydov@parallels.com>
References: <cover.1385974612.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, vdavydov@parallels.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch makes direct reclaim path shrink slabs not only on global
memory pressure, but also when we reach memory cgroup limit. To achieve
that, it introduces a new per-shrinker flag, SHRINKER_MEMCG_AWARE, which
should be set if the shrinker can handle per-memcg reclaim. For such
shrinkers, shrink_slab() will iterate over all eligible memory cgroups
(i.e. the cgroup that triggered the reclaim and all its descendants) and
pass the current memory cgroup to the shrinker in shrink_control.memcg
just like it passes the current NUMA node to NUMA-aware shrinkers.  It
is completely up to memcg-aware shrinkers how to organize objects in
order to provide required functionality. Currently none of the existing
shrinkers is memcg-aware, but next patches will introduce per-memcg
list_lru, which will facilitate the process of turning shrinkers that
use list_lru to be memcg-aware.

The number of slab objects scanned on memcg pressure is calculated in
the same way as on global pressure - it is proportional to the number of
pages scanned over the number of pages eligible for reclaim (i.e. the
number of on-LRU pages in the target memcg and all its descendants) -
except we do not employ the nr_deferred per-shrinker counter to avoid
memory cgroup isolation issues. Ideally, this counter should be made
per-memcg.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   22 +++++++++
 include/linux/shrinker.h   |   10 +++-
 mm/memcontrol.c            |   37 +++++++++++++-
 mm/vmscan.c                |  117 +++++++++++++++++++++++++++++++-------------
 4 files changed, 150 insertions(+), 36 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b3e7a66..c0f24a9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -80,6 +80,9 @@ extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
+unsigned long mem_cgroup_zone_reclaimable_pages(struct zone *,
+						struct mem_cgroup *);
+
 /* For coalescing uncharge for reducing memcg' overhead*/
 extern void mem_cgroup_uncharge_start(void);
 extern void mem_cgroup_uncharge_end(void);
@@ -289,6 +292,12 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 	return &zone->lruvec;
 }
 
+static inline unsigned long mem_cgroup_zone_reclaimable_pages(struct zone *zone,
+							struct mem_cgroup *)
+{
+	return 0;
+}
+
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
@@ -479,6 +488,9 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
+bool memcg_kmem_is_active(struct mem_cgroup *memcg);
+bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg);
+
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -620,6 +632,16 @@ static inline bool memcg_kmem_enabled(void)
 	return false;
 }
 
+static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
+static inline bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
 static inline bool
 memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 {
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 68c0970..ab79b17 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -20,8 +20,15 @@ struct shrink_control {
 
 	/* shrink from these nodes */
 	nodemask_t nodes_to_scan;
+
+	/* shrink from this memory cgroup hierarchy (if not NULL) */
+	struct mem_cgroup *target_mem_cgroup;
+
 	/* current node being shrunk (for NUMA aware shrinkers) */
 	int nid;
+
+	/* current memcg being shrunk (for memcg aware shrinkers) */
+	struct mem_cgroup *memcg;
 };
 
 #define SHRINK_STOP (~0UL)
@@ -63,7 +70,8 @@ struct shrinker {
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
 /* Flags */
-#define SHRINKER_NUMA_AWARE (1 << 0)
+#define SHRINKER_NUMA_AWARE	(1 << 0)
+#define SHRINKER_MEMCG_AWARE	(1 << 1)
 
 extern int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3a92ab3..3f12cec 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -358,7 +358,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
 	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
-static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
@@ -1333,6 +1333,26 @@ out:
 	return lruvec;
 }
 
+unsigned long mem_cgroup_zone_reclaimable_pages(struct zone *zone,
+						struct mem_cgroup *memcg)
+{
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+	unsigned long nr = 0;
+	struct mem_cgroup *iter;
+
+	iter = memcg;
+	do {
+		nr += mem_cgroup_zone_nr_lru_pages(iter, nid, zid,
+						   LRU_ALL_FILE);
+		if (do_swap_account)
+			nr += mem_cgroup_zone_nr_lru_pages(iter, nid, zid,
+							   LRU_ALL_ANON);
+		iter = mem_cgroup_iter(memcg, iter, NULL);
+	} while (iter);
+	return nr;
+}
+
 /*
  * Following LRU functions are allowed to be used without PCG_LOCK.
  * Operations are called by routine of global LRU independently from memcg.
@@ -2959,6 +2979,21 @@ static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 		(memcg->kmem_account_flags & KMEM_ACCOUNTED_MASK);
 }
 
+bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *iter;
+
+	iter = memcg;
+	do {
+		if (memcg_kmem_is_active(iter)) {
+			mem_cgroup_iter_break(memcg, iter);
+			return true;
+		}
+		iter = mem_cgroup_iter(memcg, iter, NULL);
+	} while (iter);
+	return false;
+}
+
 /*
  * helper for acessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7601b95..04df967 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -225,7 +225,7 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	unsigned long long delta;
 	long total_scan;
 	long max_pass;
-	long nr;
+	long nr = 0;
 	long new_nr;
 	int nid = shrinkctl->nid;
 	long batch_size = shrinker->batch ? shrinker->batch
@@ -236,11 +236,17 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 		return 0;
 
 	/*
-	 * copy the current shrinker scan count into a local variable
-	 * and zero it so that other concurrent shrinker invocations
-	 * don't also do this scanning work.
+	 * Do not touch global counter of deferred objects on memcg pressure to
+	 * avoid isolation issues. Ideally the counter should be per-memcg.
 	 */
-	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
+	if (!shrinkctl->target_mem_cgroup) {
+		/*
+		 * copy the current shrinker scan count into a local variable
+		 * and zero it so that other concurrent shrinker invocations
+		 * don't also do this scanning work.
+		 */
+		nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
+	}
 
 	total_scan = nr;
 	delta = (4 * fraction) / shrinker->seeks;
@@ -296,21 +302,46 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 		cond_resched();
 	}
 
-	/*
-	 * move the unused scan count back into the shrinker in a
-	 * manner that handles concurrent updates. If we exhausted the
-	 * scan, there is no need to do an update.
-	 */
-	if (total_scan > 0)
-		new_nr = atomic_long_add_return(total_scan,
+	if (!shrinkctl->target_mem_cgroup) {
+		/*
+		 * move the unused scan count back into the shrinker in a
+		 * manner that handles concurrent updates. If we exhausted the
+		 * scan, there is no need to do an update.
+		 */
+		if (total_scan > 0)
+			new_nr = atomic_long_add_return(total_scan,
 						&shrinker->nr_deferred[nid]);
-	else
-		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
+		else
+			new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
+	}
 
 	trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
 	return freed;
 }
 
+static unsigned long
+shrink_slab_memcg(struct shrink_control *shrinkctl, struct shrinker *shrinker,
+		  unsigned long fraction, unsigned long denominator)
+{
+	unsigned long freed = 0;
+
+	if (shrinkctl->memcg && !memcg_kmem_is_active(shrinkctl->memcg))
+		return 0;
+
+	for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
+		if (!node_online(shrinkctl->nid))
+			continue;
+
+		if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
+		    (shrinkctl->nid != 0))
+			break;
+
+		freed += shrink_slab_node(shrinkctl, shrinker,
+					  fraction, denominator);
+	}
+	return freed;
+}
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -352,18 +383,23 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
-			if (!node_online(shrinkctl->nid))
-				continue;
-
-			if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
-			    (shrinkctl->nid != 0))
+		shrinkctl->memcg = shrinkctl->target_mem_cgroup;
+		do {
+			if (!(shrinker->flags & SHRINKER_MEMCG_AWARE) &&
+			    (shrinkctl->memcg != NULL)) {
+				mem_cgroup_iter_break(
+						shrinkctl->target_mem_cgroup,
+						shrinkctl->memcg);
 				break;
+			}
 
-			freed += shrink_slab_node(shrinkctl, shrinker,
-						  fraction, denominator);
+			freed += shrink_slab_memcg(shrinkctl, shrinker,
+						   fraction, denominator);
 
-		}
+			shrinkctl->memcg = mem_cgroup_iter(
+						shrinkctl->target_mem_cgroup,
+						shrinkctl->memcg, NULL);
+		} while (shrinkctl->memcg);
 	}
 	up_read(&shrinker_rwsem);
 out:
@@ -2285,6 +2321,7 @@ static bool shrink_zones(struct zonelist *zonelist,
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct shrink_control shrink = {
 		.gfp_mask = sc->gfp_mask,
+		.target_mem_cgroup = sc->target_mem_cgroup,
 	};
 
 	/*
@@ -2301,17 +2338,22 @@ static bool shrink_zones(struct zonelist *zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
+
+		if (global_reclaim(sc) &&
+		    !cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+			continue;
+
+		lru_pages += global_reclaim(sc) ?
+				zone_reclaimable_pages(zone) :
+				mem_cgroup_zone_reclaimable_pages(zone,
+						sc->target_mem_cgroup);
+		node_set(zone_to_nid(zone), shrink.nodes_to_scan);
+
 		/*
 		 * Take care memory controller reclaiming has small influence
 		 * to global LRU.
 		 */
 		if (global_reclaim(sc)) {
-			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-				continue;
-
-			lru_pages += zone_reclaimable_pages(zone);
-			node_set(zone_to_nid(zone), shrink.nodes_to_scan);
-
 			if (sc->priority != DEF_PRIORITY &&
 			    !zone_reclaimable(zone))
 				continue;	/* Let kswapd poll it */
@@ -2349,12 +2391,11 @@ static bool shrink_zones(struct zonelist *zonelist,
 	}
 
 	/*
-	 * Don't shrink slabs when reclaiming memory from over limit
-	 * cgroups but do shrink slab at least once when aborting
-	 * reclaim for compaction to avoid unevenly scanning file/anon
-	 * LRU pages over slab pages.
+	 * Shrink slabs at least once when aborting reclaim for compaction
+	 * to avoid unevenly scanning file/anon LRU pages over slab pages.
 	 */
-	if (global_reclaim(sc)) {
+	if (global_reclaim(sc) ||
+	    memcg_kmem_should_reclaim(sc->target_mem_cgroup)) {
 		shrink_slab(&shrink, sc->nr_scanned, lru_pages);
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -2648,6 +2689,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
 	int nid;
+	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
@@ -2670,6 +2712,10 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = NODE_DATA(nid)->node_zonelists;
 
+	lockdep_set_current_reclaim_state(sc.gfp_mask);
+	reclaim_state.reclaimed_slab = 0;
+	current->reclaim_state = &reclaim_state;
+
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,
 					    sc.gfp_mask);
@@ -2678,6 +2724,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
+	current->reclaim_state = NULL;
+	lockdep_clear_current_reclaim_state();
+
 	return nr_reclaimed;
 }
 #endif
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
