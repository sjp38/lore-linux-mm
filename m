Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 780FD6B0039
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:15 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id r10so3110186lbi.20
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:13 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 03/16] vmscan: also shrink slab in memcg pressure
Date: Sun,  7 Jul 2013 11:56:43 -0400
Message-Id: <1373212616-11713-4-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

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
 include/linux/memcontrol.h | 17 ++++++++++++++++
 include/linux/shrinker.h   |  6 +++++-
 mm/memcontrol.c            | 16 ++++++++++++++-
 mm/vmscan.c                | 51 +++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 83 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7b4d9d7..489c6d7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -200,6 +200,9 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 bool mem_cgroup_bad_page_check(struct page *page);
 void mem_cgroup_print_bad_page(struct page *page);
 #endif
+
+unsigned long
+memcg_zone_reclaimable_pages(struct mem_cgroup *memcg, struct zone *zone);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
@@ -378,6 +381,12 @@ static inline void mem_cgroup_replace_page_cache(struct page *oldpage,
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
@@ -430,6 +439,8 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
+bool memcg_kmem_is_active(struct mem_cgroup *memcg);
+
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -563,6 +574,12 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
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
index 68c0970..7d462b1 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -22,6 +22,9 @@ struct shrink_control {
 	nodemask_t nodes_to_scan;
 	/* current node being shrunk (for NUMA aware shrinkers) */
 	int nid;
+
+	/* reclaim from this memcg only (if not NULL) */
+	struct mem_cgroup *target_mem_cgroup;
 };
 
 #define SHRINK_STOP (~0UL)
@@ -63,7 +66,8 @@ struct shrinker {
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
 /* Flags */
-#define SHRINKER_NUMA_AWARE (1 << 0)
+#define SHRINKER_NUMA_AWARE	(1 << 0)
+#define SHRINKER_MEMCG_AWARE	(1 << 1)
 
 extern int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f524332..eda075b4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -369,7 +369,7 @@ static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
 	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
 
-static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
 	return test_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
@@ -950,6 +950,20 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
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
index e364542..d2d9823 100644
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
@@ -331,6 +362,15 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
+		/*
+		 * If we don't have a target mem cgroup, we scan them all.
+		 * Otherwise we will limit our scan to shrinkers marked as
+		 * memcg aware
+		 */
+		if (shrinkctl->target_mem_cgroup &&
+		    !(shrinker->flags & SHRINKER_MEMCG_AWARE))
+			continue;
+
 		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
 			if (!node_online(shrinkctl->nid))
 				continue;
@@ -2382,11 +2422,11 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 		/*
 		 * Don't shrink slabs when reclaiming memory from over limit
-		 * cgroups but do shrink slab at least once when aborting
-		 * reclaim for compaction to avoid unevenly scanning file/anon
-		 * LRU pages over slab pages.
+		 * cgroups unless we know they have kmem objects. But do shrink
+		 * slab at least once when aborting reclaim for compaction to
+		 * avoid unevenly scanning file/anon LRU pages over slab pages.
 		 */
-		if (global_reclaim(sc)) {
+		if (has_kmem_reclaim(sc)) {
 			unsigned long lru_pages = 0;
 
 			nodes_clear(shrink->nodes_to_scan);
@@ -2395,7 +2435,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 				if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 					continue;
 
-				lru_pages += zone_reclaimable_pages(zone);
+				lru_pages += zone_nr_reclaimable_pages(sc, zone);
 				node_set(zone_to_nid(zone),
 					 shrink->nodes_to_scan);
 			}
@@ -2652,6 +2692,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
+		.target_mem_cgroup = memcg,
 	};
 
 	/*
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
