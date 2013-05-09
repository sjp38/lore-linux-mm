Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6B2B56B0095
	for <linux-mm@kvack.org>; Thu,  9 May 2013 02:07:19 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v5 21/31] vmscan: also shrink slab in memcg pressure
Date: Thu,  9 May 2013 10:06:38 +0400
Message-Id: <1368079608-5611-22-git-send-email-glommer@openvz.org>
In-Reply-To: <1368079608-5611-1-git-send-email-glommer@openvz.org>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

Without the surrounding infrastructure, this patch is a bit of a hammer:
it will basically shrink objects from all memcgs under memcg pressure.
At least, however, we will keep the scan limited to the shrinkers marked
as per-memcg.

Future patches will implement the in-shrinker logic to filter objects
based on its memcg association.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h | 17 +++++++++++++++++
 include/linux/shrinker.h   |  4 ++++
 mm/memcontrol.c            | 16 +++++++++++++++-
 mm/vmscan.c                | 46 +++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 79 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d6183f0..4c24249 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -199,6 +199,9 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 bool mem_cgroup_bad_page_check(struct page *page);
 void mem_cgroup_print_bad_page(struct page *page);
 #endif
+
+unsigned long
+memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
@@ -377,6 +380,12 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
 				struct page *newpage)
 {
 }
+
+static inline unsigned long
+memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
+{
+	return 0;
+}
 #endif /* CONFIG_MEMCG */
 
 #if !defined(CONFIG_MEMCG) || !defined(CONFIG_DEBUG_VM)
@@ -429,6 +438,8 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
+bool memcg_kmem_is_active(struct mem_cgroup *memcg);
+
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -562,6 +573,12 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
 #else
+
+static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
 
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 00a3e57..3b08869 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -20,6 +20,9 @@ struct shrink_control {
 
 	/* shrink from these nodes */
 	nodemask_t nodes_to_scan;
+
+	/* reclaim from this memcg only (if not NULL) */
+	struct mem_cgroup *target_mem_cgroup;
 };
 
 /*
@@ -45,6 +48,7 @@ struct shrinker {
 
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
+	bool memcg_shrinker; /* memcg-aware shrinker */
 
 	/* These are for internal use */
 	struct list_head list;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a8a69b4..ef420e1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -397,7 +397,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
 	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
-static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
@@ -971,6 +971,20 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 	return ret;
 }
 
+unsigned long
+memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone)
+{
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+	unsigned long val;
+
+	val = mem_cgroup_zone_nr_lru_pages(memcg, nid, zid, LRU_ALL_FILE);
+	if (do_swap_account)
+		val += mem_cgroup_zone_nr_lru_pages(memcg, nid, zid,
+						    LRU_ALL_ANON);
+	return val;
+}
+
 static unsigned long
 mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 			int nid, unsigned int lru_mask)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 024e9c9..295f128 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -139,11 +139,42 @@ static bool global_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup;
 }
+
+/*
+ * kmem reclaim should usually not be triggered when we are doing targetted
+ * reclaim. It is only valid when global reclaim is triggered, or when the
+ * underlying memcg has kmem objects.
+ */
+static bool has_kmem_reclaim(struct scan_control *sc)
+{
+	return !sc->target_mem_cgroup ||
+		memcg_kmem_is_active(sc->target_mem_cgroup);
+}
+
+static unsigned long
+zone_nr_reclaimable_pages(struct scan_control *sc, struct zone *zone)
+{
+	if (global_reclaim(sc))
+		return zone_reclaimable_pages(zone);
+	return memcg_zone_reclaimable_pages(sc->target_mem_cgroup, zone);
+}
+
 #else
 static bool global_reclaim(struct scan_control *sc)
 {
 	return true;
 }
+
+static bool has_kmem_reclaim(struct scan_control *sc)
+{
+	return true;
+}
+
+static unsigned long
+zone_nr_reclaimable_pages(struct scan_control *sc, struct zone *zone)
+{
+	return zone_reclaimable_pages(zone);
+}
 #endif
 
 static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
@@ -222,6 +253,14 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 		long batch_size = shrinker->batch ? shrinker->batch
 						  : SHRINK_BATCH;
 
+		/*
+		 * If we don't have a target mem cgroup, we scan them all.
+		 * Otherwise we will limit our scan to shrinkers marked as
+		 * memcg aware
+		 */
+		if (shrinkctl->target_mem_cgroup && !shrinker->memcg_shrinker)
+			continue;
+
 		max_pass = shrinker->count_objects(shrinker, shrinkctl);
 		WARN_ON(max_pass < 0);
 		if (max_pass <= 0)
@@ -2189,9 +2228,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 		/*
 		 * Don't shrink slabs when reclaiming memory from
-		 * over limit cgroups
+		 * over limit cgroups, unless we know they have kmem objects
 		 */
-		if (global_reclaim(sc)) {
+		if (has_kmem_reclaim(sc)) {
 			unsigned long lru_pages = 0;
 
 			nodes_clear(shrink->nodes_to_scan);
@@ -2200,7 +2239,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 					continue;
 
-				lru_pages += zone_reclaimable_pages(zone);
+				lru_pages += zone_nr_reclaimable_pages(sc, zone);
 				node_set(zone_to_nid(zone),
 					 shrink->nodes_to_scan);
 			}
@@ -2469,6 +2508,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
+		.target_mem_cgroup = memcg,
 	};
 
 	/*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
