Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 75FA96B0070
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 05:53:44 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so11105351pab.4
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 02:53:44 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id oy3si8098088pdb.34.2015.01.08.02.53.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 02:53:42 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 3/9] vmscan: per memory cgroup slab shrinkers
Date: Thu, 8 Jan 2015 13:53:13 +0300
Message-ID: <bf6c9d9596e0437fda8aec441d4e85302c3e7bad.1420711973.git.vdavydov@parallels.com>
In-Reply-To: <cover.1420711973.git.vdavydov@parallels.com>
References: <cover.1420711973.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch adds SHRINKER_MEMCG_AWARE flag. If a shrinker has this flag
set, it will be called per memory cgroup. The memory cgroup to scan
objects from is passed in shrink_control->memcg. If the memory cgroup is
NULL, a memcg aware shrinker is supposed to scan objects from the global
list. Unaware shrinkers are only called on global pressure with
memcg=NULL.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/drop_caches.c           |   14 --------
 include/linux/memcontrol.h |    7 ++++
 include/linux/mm.h         |    5 ++-
 include/linux/shrinker.h   |    6 +++-
 mm/memcontrol.c            |    2 +-
 mm/memory-failure.c        |   11 ++----
 mm/vmscan.c                |   86 ++++++++++++++++++++++++++++++++------------
 7 files changed, 80 insertions(+), 51 deletions(-)

diff --git a/fs/drop_caches.c b/fs/drop_caches.c
index 2bc2c87f35e7..5718cb9f7273 100644
--- a/fs/drop_caches.c
+++ b/fs/drop_caches.c
@@ -37,20 +37,6 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
 	iput(toput_inode);
 }
 
-static void drop_slab(void)
-{
-	int nr_objects;
-
-	do {
-		int nid;
-
-		nr_objects = 0;
-		for_each_online_node(nid)
-			nr_objects += shrink_node_slabs(GFP_KERNEL, nid,
-							1000, 1000);
-	} while (nr_objects > 10);
-}
-
 int drop_caches_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 76b4084b8d08..d555d6533bd0 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -375,6 +375,8 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
+bool memcg_kmem_is_active(struct mem_cgroup *memcg);
+
 /*
  * In general, we'll do everything in our power to not incur in any overhead
  * for non-memcg users for the kmem functions. Not even a function call, if we
@@ -504,6 +506,11 @@ static inline bool memcg_kmem_enabled(void)
 	return false;
 }
 
+static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
 static inline bool
 memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3b829b82e226..28da774850b9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2100,9 +2100,8 @@ int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 #endif
 
-unsigned long shrink_node_slabs(gfp_t gfp_mask, int nid,
-				unsigned long nr_scanned,
-				unsigned long nr_eligible);
+void drop_slab(void);
+void drop_slab_node(int nid);
 
 #ifndef CONFIG_MMU
 #define randomize_va_space 0
diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index f4aee75f00b1..4fcacd915d45 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -20,6 +20,9 @@ struct shrink_control {
 
 	/* current node being shrunk (for NUMA aware shrinkers) */
 	int nid;
+
+	/* current memcg being shrunk (for memcg aware shrinkers) */
+	struct mem_cgroup *memcg;
 };
 
 #define SHRINK_STOP (~0UL)
@@ -61,7 +64,8 @@ struct shrinker {
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 
 /* Flags */
-#define SHRINKER_NUMA_AWARE (1 << 0)
+#define SHRINKER_NUMA_AWARE	(1 << 0)
+#define SHRINKER_MEMCG_AWARE	(1 << 1)
 
 extern int register_shrinker(struct shrinker *);
 extern void unregister_shrinker(struct shrinker *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bfa1a849d113..6c1df48b29f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -365,7 +365,7 @@ struct mem_cgroup {
 };
 
 #ifdef CONFIG_MEMCG_KMEM
-static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
+bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
 	return memcg->kmemcg_id >= 0;
 }
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index feb803bf3443..1a735fad2a13 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -242,15 +242,8 @@ void shake_page(struct page *p, int access)
 	 * Only call shrink_node_slabs here (which would also shrink
 	 * other caches) if access is not potentially fatal.
 	 */
-	if (access) {
-		int nr;
-		int nid = page_to_nid(p);
-		do {
-			nr = shrink_node_slabs(GFP_KERNEL, nid, 1000, 1000);
-			if (page_count(p) == 1)
-				break;
-		} while (nr > 10);
-	}
+	if (access)
+		drop_slab_node(page_to_nid(p));
 }
 EXPORT_SYMBOL_GPL(shake_page);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e29f411b38ac..16f3e45742d6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -229,10 +229,10 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
 
-static unsigned long shrink_slabs(struct shrink_control *shrinkctl,
-				  struct shrinker *shrinker,
-				  unsigned long nr_scanned,
-				  unsigned long nr_eligible)
+static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
+				    struct shrinker *shrinker,
+				    unsigned long nr_scanned,
+				    unsigned long nr_eligible)
 {
 	unsigned long freed = 0;
 	unsigned long long delta;
@@ -341,9 +341,10 @@ static unsigned long shrink_slabs(struct shrink_control *shrinkctl,
 }
 
 /**
- * shrink_node_slabs - shrink slab caches of a given node
+ * shrink_slab - shrink slab caches
  * @gfp_mask: allocation context
  * @nid: node whose slab caches to target
+ * @memcg: memory cgroup whose slab caches to target
  * @nr_scanned: pressure numerator
  * @nr_eligible: pressure denominator
  *
@@ -352,6 +353,12 @@ static unsigned long shrink_slabs(struct shrink_control *shrinkctl,
  * @nid is passed along to shrinkers with SHRINKER_NUMA_AWARE set,
  * unaware shrinkers will receive a node id of 0 instead.
  *
+ * @memcg specifies the memory cgroup to target. If it is not NULL,
+ * only shrinkers with SHRINKER_MEMCG_AWARE set will be called to scan
+ * objects from the memory cgroup specified. Otherwise all shrinkers
+ * are called, and memcg aware shrinkers are supposed to scan the
+ * global list then.
+ *
  * @nr_scanned and @nr_eligible form a ratio that indicate how much of
  * the available objects should be scanned.  Page reclaim for example
  * passes the number of pages scanned and the number of pages on the
@@ -362,13 +369,17 @@ static unsigned long shrink_slabs(struct shrink_control *shrinkctl,
  *
  * Returns the number of reclaimed slab objects.
  */
-unsigned long shrink_node_slabs(gfp_t gfp_mask, int nid,
-				unsigned long nr_scanned,
-				unsigned long nr_eligible)
+static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
+				 struct mem_cgroup *memcg,
+				 unsigned long nr_scanned,
+				 unsigned long nr_eligible)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
+	if (memcg && !memcg_kmem_is_active(memcg))
+		return 0;
+
 	if (nr_scanned == 0)
 		nr_scanned = SWAP_CLUSTER_MAX;
 
@@ -387,12 +398,16 @@ unsigned long shrink_node_slabs(gfp_t gfp_mask, int nid,
 		struct shrink_control sc = {
 			.gfp_mask = gfp_mask,
 			.nid = nid,
+			.memcg = memcg,
 		};
 
+		if (memcg && !(shrinker->flags & SHRINKER_MEMCG_AWARE))
+			continue;
+
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
-		freed += shrink_slabs(&sc, shrinker, nr_scanned, nr_eligible);
+		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
 	}
 
 	up_read(&shrinker_rwsem);
@@ -401,6 +416,29 @@ out:
 	return freed;
 }
 
+void drop_slab_node(int nid)
+{
+	unsigned long freed;
+
+	do {
+		struct mem_cgroup *memcg = NULL;
+
+		freed = 0;
+		do {
+			freed += shrink_slab(GFP_KERNEL, nid, memcg,
+					     1000, 1000);
+		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
+	} while (freed > 10);
+}
+
+void drop_slab(void)
+{
+	int nid;
+
+	for_each_online_node(nid)
+		drop_slab_node(nid);
+}
+
 static inline int is_page_cache_freeable(struct page *page)
 {
 	/*
@@ -2301,6 +2339,7 @@ static inline bool should_continue_reclaim(struct zone *zone,
 static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 			bool is_classzone)
 {
+	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
 
@@ -2318,16 +2357,22 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
-			unsigned long lru_pages;
+			unsigned long lru_pages, scanned;
 			struct lruvec *lruvec;
 			int swappiness;
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 			swappiness = mem_cgroup_swappiness(memcg);
+			scanned = sc->nr_scanned;
 
 			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
 			zone_lru_pages += lru_pages;
 
+			if (memcg && is_classzone)
+				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
+					    memcg, sc->nr_scanned - scanned,
+					    lru_pages);
+
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
 			 * cgroups to fulfill the overall scan target for the
@@ -2350,19 +2395,14 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
 		 * Shrink the slab caches in the same proportion that
 		 * the eligible LRU pages were scanned.
 		 */
-		if (global_reclaim(sc) && is_classzone) {
-			struct reclaim_state *reclaim_state;
-
-			shrink_node_slabs(sc->gfp_mask, zone_to_nid(zone),
-					  sc->nr_scanned - nr_scanned,
-					  zone_lru_pages);
-
-			reclaim_state = current->reclaim_state;
-			if (reclaim_state) {
-				sc->nr_reclaimed +=
-					reclaim_state->reclaimed_slab;
-				reclaim_state->reclaimed_slab = 0;
-			}
+		if (global_reclaim(sc) && is_classzone)
+			shrink_slab(sc->gfp_mask, zone_to_nid(zone), NULL,
+				    sc->nr_scanned - nr_scanned,
+				    zone_lru_pages);
+
+		if (reclaim_state) {
+			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
 		}
 
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
