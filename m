Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id BADA36B0068
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:27 -0500 (EST)
Received: by mail-la0-f54.google.com with SMTP id b8so1297119lan.13
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:27 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 9si3283062lal.42.2013.12.09.00.06.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:26 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 10/16] vmscan: shrink slab on memcg pressure
Date: Mon, 9 Dec 2013 12:05:51 +0400
Message-ID: <24314b9f3b299bac988ea3570f71f9e6919bbc4e.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch makes direct reclaim path shrink slab not only on global
memory pressure, but also when we reach the user memory limit of a
memcg. To achieve that, it makes shrink_slab() walk over the memcg
hierarchy and run shrinkers marked as memcg-aware on the target memcg
and all its descendants. The memcg to scan is passed in a shrink_control
structure; memcg-unaware shrinkers are still called only on global
memory pressure with memcg=NULL. It is up to the shrinker how to
organize the objects it is responsible for to achieve per-memcg reclaim.

The idea lying behind the patch as well as the initial implementation
belong to Glauber Costa.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   22 ++++++++++
 include/linux/shrinker.h   |   10 ++++-
 mm/memcontrol.c            |   37 +++++++++++++++-
 mm/vmscan.c                |  103 +++++++++++++++++++++++++++++++++-----------
 4 files changed, 146 insertions(+), 26 deletions(-)

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
index 220b463..a3f479b 100644
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
index d98f272..1997813 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -311,6 +311,58 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
 	return freed;
 }
 
+static unsigned long
+run_shrinker(struct shrink_control *shrinkctl, struct shrinker *shrinker,
+	     unsigned long nr_pages_scanned, unsigned long lru_pages)
+{
+	unsigned long freed = 0;
+
+	/*
+	 * If we don't have a target mem cgroup, we scan them all. Otherwise
+	 * we will limit our scan to shrinkers marked as memcg aware.
+	 */
+	if (!(shrinker->flags & SHRINKER_MEMCG_AWARE) &&
+	    shrinkctl->target_mem_cgroup != NULL)
+		return 0;
+
+	/*
+	 * In a hierarchical chain, it might be that not all memcgs are kmem
+	 * active. kmemcg design mandates that when one memcg is active, its
+	 * children will be active as well. But it is perfectly possible that
+	 * its parent is not.
+	 *
+	 * We also need to make sure we scan at least once, for the global
+	 * case. So if we don't have a target memcg, we proceed normally and
+	 * expect to break in the next round.
+	 */
+	shrinkctl->memcg = shrinkctl->target_mem_cgroup;
+	do {
+		if (shrinkctl->memcg && !memcg_kmem_is_active(shrinkctl->memcg))
+			goto next;
+
+		if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
+			shrinkctl->nid = 0;
+			freed += shrink_slab_node(shrinkctl, shrinker,
+					nr_pages_scanned, lru_pages);
+			goto next;
+		}
+
+		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
+			if (node_online(shrinkctl->nid))
+				freed += shrink_slab_node(shrinkctl, shrinker,
+						nr_pages_scanned, lru_pages);
+
+		}
+next:
+		if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
+			break;
+		shrinkctl->memcg = mem_cgroup_iter(shrinkctl->target_mem_cgroup,
+						   shrinkctl->memcg, NULL);
+	} while (shrinkctl->memcg);
+
+	return freed;
+}
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -352,20 +404,10 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		if (!(shrinker->flags & SHRINKER_NUMA_AWARE)) {
-			shrinkctl->nid = 0;
-			freed += shrink_slab_node(shrinkctl, shrinker,
-					nr_pages_scanned, lru_pages);
-			continue;
-		}
-
-		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
-			if (node_online(shrinkctl->nid))
-				freed += shrink_slab_node(shrinkctl, shrinker,
-						nr_pages_scanned, lru_pages);
-
-		}
+		freed += run_shrinker(shrinkctl, shrinker,
+				      nr_pages_scanned, lru_pages);
 	}
+
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
@@ -2286,6 +2328,7 @@ static bool shrink_zones(struct zonelist *zonelist,
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct shrink_control shrink = {
 		.gfp_mask = sc->gfp_mask,
+		.target_mem_cgroup = sc->target_mem_cgroup,
 	};
 
 	/*
@@ -2302,17 +2345,22 @@ static bool shrink_zones(struct zonelist *zonelist,
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
@@ -2350,12 +2398,11 @@ static bool shrink_zones(struct zonelist *zonelist,
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
@@ -2649,6 +2696,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
 	int nid;
+	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
@@ -2671,6 +2719,10 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
 	zonelist = NODE_DATA(nid)->node_zonelists;
 
+	lockdep_set_current_reclaim_state(sc.gfp_mask);
+	reclaim_state.reclaimed_slab = 0;
+	current->reclaim_state = &reclaim_state;
+
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,
 					    sc.gfp_mask);
@@ -2679,6 +2731,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 
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
