Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id E5CEF6B0039
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 05:31:57 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so9587532pdj.36
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:31:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bs7si8628753pdb.119.2014.07.28.02.31.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jul 2014 02:31:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 3/6] vmscan: shrink slab on memcg pressure
Date: Mon, 28 Jul 2014 13:31:25 +0400
Message-ID: <59f7adfd425e60701035389647ca12def82cb9ca.1406536261.git.vdavydov@parallels.com>
In-Reply-To: <cover.1406536261.git.vdavydov@parallels.com>
References: <cover.1406536261.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, david@fromorbit.com, viro@zeniv.linux.org.uk, gthelen@google.com, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch makes direct reclaim path shrink slab not only on global
memory pressure, but also when we reach the user memory limit of a
memcg. To achieve that, it makes shrink_slab() walk over the memcg
hierarchy and run shrinkers marked as memcg-aware on the target memcg
and all its descendants. The memcg to scan is passed in a shrink_control
structure; memcg-unaware shrinkers are still called only on global
memory pressure with memcg=NULL. It is up to the shrinker how to
organize the objects it is responsible for to achieve per-memcg reclaim.

Note that we do not intend to have true per memcg per node reclaim.
Since most memcgs are small and typically confined to a single NUMA node
or two by external means and therefore do not need the scalability NUMA
aware shrinkers provide, we actually call per node shrinking only for
the global list (memcg=NULL), while per-memcg lists are always scanned
only once irrespective of the nodemask with nid=0.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   22 +++++++++++
 include/linux/shrinker.h   |   10 ++++-
 mm/memcontrol.c            |   45 ++++++++++++++++++++-
 mm/vmscan.c                |   94 ++++++++++++++++++++++++++++++++++----------
 4 files changed, 149 insertions(+), 22 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e0752d204d9e..d0f3d8f0990c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -68,6 +68,9 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 struct lruvec *mem_cgroup_zone_lruvec(struct zone *, struct mem_cgroup *);
 struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
+unsigned long mem_cgroup_zone_reclaimable_pages(struct zone *zone,
+						struct mem_cgroup *memcg);
+
 bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 				  struct mem_cgroup *memcg);
 bool task_in_mem_cgroup(struct task_struct *task,
@@ -251,6 +254,12 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
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
@@ -421,6 +430,9 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
+bool memcg_kmem_is_active(struct mem_cgroup *memcg);
+bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg);
+
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -554,6 +566,16 @@ static inline bool memcg_kmem_enabled(void)
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
index 68c097077ef0..ab79b174bfbe 100644
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
index b7c9a202dee9..6a96a3994692 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -391,7 +391,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
 	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
-static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
@@ -1409,6 +1409,34 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 	VM_BUG_ON((long)(*lru_size) < 0);
 }
 
+unsigned long mem_cgroup_zone_reclaimable_pages(struct zone *zone,
+						struct mem_cgroup *memcg)
+{
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+	unsigned long nr = 0;
+	unsigned int lru_mask;
+	struct mem_cgroup *iter;
+
+	lru_mask = LRU_ALL_FILE;
+	if (do_swap_account)
+		lru_mask |= LRU_ALL_ANON;
+
+	iter = memcg;
+	do {
+		struct mem_cgroup_per_zone *mz;
+		enum lru_list lru;
+
+		mz = &memcg->nodeinfo[nid]->zoneinfo[zid];
+		for_each_lru(lru) {
+			if (BIT(lru) & lru_mask)
+				nr += mz->lru_size[lru];
+		}
+	} while ((iter = mem_cgroup_iter(memcg, iter, NULL)) != NULL);
+
+	return nr;
+}
+
 /*
  * Checks whether given mem is same or in the root_mem_cgroup's
  * hierarchy subtree
@@ -2886,6 +2914,21 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg, u64 size)
 		css_put(&memcg->css);
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
+	} while ((iter = mem_cgroup_iter(memcg, iter, NULL)) != NULL);
+
+	return false;
+}
+
 /*
  * helper for acessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d698f4f7b0f2..290dd18a6959 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -340,6 +340,33 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	return freed;
 }
 
+static unsigned long
+run_shrinker(struct shrink_control *shrinkctl, struct shrinker *shrinker,
+	     unsigned long nr_pages_scanned, unsigned long lru_pages)
+{
+	unsigned long freed = 0;
+
+	/*
+	 * Since most memory cgroups are small and typically confined to a
+	 * single NUMA node or two by external means and therefore do not need
+	 * the scalability NUMA aware shrinkers provide, we implement per node
+	 * shrinking only for the global list.
+	 */
+	if (!(shrinker->flags & SHRINKER_NUMA_AWARE) ||
+	    shrinkctl->memcg) {
+		shrinkctl->nid = 0;
+		return shrink_slab_node(shrinkctl, shrinker,
+					nr_pages_scanned, lru_pages);
+	}
+
+	for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
+		if (node_online(shrinkctl->nid))
+			freed += shrink_slab_node(shrinkctl, shrinker,
+						  nr_pages_scanned, lru_pages);
+	}
+	return freed;
+}
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -381,20 +408,34 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
-			shrinkctl->nid = 0;
-			freed += shrink_slab_node(shrinkctl, shrinker,
-					nr_pages_scanned, lru_pages);
+		/*
+		 * Call memcg-unaware shrinkers only on global pressure.
+		 */
+		if (!(shrinker->flags & SHRINKER_MEMCG_AWARE)) {
+			if (!shrinkctl->target_mem_cgroup) {
+				shrinkctl->memcg = NULL;
+				freed += run_shrinker(shrinkctl, shrinker,
+						nr_pages_scanned, lru_pages);
+			}
 			continue;
 		}
 
-		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
-			if (node_online(shrinkctl->nid))
-				freed += shrink_slab_node(shrinkctl, shrinker,
+		/*
+		 * For memcg-aware shrinkers iterate over the target memcg
+		 * hierarchy and run the shrinker on each kmem-active memcg
+		 * found in the hierarchy.
+		 */
+		shrinkctl->memcg = shrinkctl->target_mem_cgroup;
+		do {
+			if (!shrinkctl->memcg ||
+			    memcg_kmem_is_active(shrinkctl->memcg))
+				freed += run_shrinker(shrinkctl, shrinker,
 						nr_pages_scanned, lru_pages);
-
-		}
+		} while ((shrinkctl->memcg =
+			  mem_cgroup_iter(shrinkctl->target_mem_cgroup,
+					  shrinkctl->memcg, NULL)) != NULL);
 	}
+
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
@@ -2369,6 +2410,7 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	gfp_t orig_mask;
 	struct shrink_control shrink = {
 		.gfp_mask = sc->gfp_mask,
+		.target_mem_cgroup = sc->target_mem_cgroup,
 	};
 	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
 	bool reclaimable = false;
@@ -2388,17 +2430,22 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
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
@@ -2446,12 +2493,11 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	}
 
 	/*
-	 * Don't shrink slabs when reclaiming memory from over limit cgroups
-	 * but do shrink slab at least once when aborting reclaim for
-	 * compaction to avoid unevenly scanning file/anon LRU pages over slab
-	 * pages.
+	 * Shrink slabs at least once when aborting reclaim for compaction
+	 * to avoid unevenly scanning file/anon LRU pages over slab pages.
 	 */
-	if (global_reclaim(sc)) {
+	if (global_reclaim(sc) ||
+	    memcg_kmem_should_reclaim(sc->target_mem_cgroup)) {
 		shrink_slab(&shrink, sc->nr_scanned, lru_pages);
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
@@ -2753,6 +2799,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
 	int nid;
+	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2773,6 +2820,10 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = NODE_DATA(nid)->node_zonelists;
 
+	lockdep_set_current_reclaim_state(sc.gfp_mask);
+	reclaim_state.reclaimed_slab = 0;
+	current->reclaim_state = &reclaim_state;
+
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,
 					    sc.gfp_mask);
@@ -2781,6 +2832,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
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
