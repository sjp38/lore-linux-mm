Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id E8DB56B0258
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:01:06 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l65so121053143wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:01:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b9si4069127wjf.184.2016.01.26.13.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 13:01:05 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 5/5] mm: workingset: per-cgroup cache thrash detection
Date: Tue, 26 Jan 2016 16:00:06 -0500
Message-Id: <1453842006-29265-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
References: <1453842006-29265-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Cache thrash detection (see a528910e12ec "mm: thrash detection-based
file cache sizing" for details) currently only works on the system
level, not inside cgroups. Worse, as the refaults are compared to the
global number of active cache, cgroups might wrongfully get all their
refaults activated when their pages are hotter than those of others.

Move the refault machinery from the zone to the lruvec, and then tag
eviction entries with the memcg ID. This makes the thrash detection
work correctly inside cgroups.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 39 ++++++++++++++++++++++++++
 include/linux/mmzone.h     | 11 ++++----
 include/linux/swap.h       |  1 +
 mm/memcontrol.c            | 25 -----------------
 mm/vmscan.c                | 18 ++++++------
 mm/workingset.c            | 69 +++++++++++++++++++++++++++++++++++++++-------
 6 files changed, 113 insertions(+), 50 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2685aaf91511..845b40905bf3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -89,6 +89,10 @@ enum mem_cgroup_events_target {
 };
 
 #ifdef CONFIG_MEMCG
+
+#define MEM_CGROUP_ID_SHIFT	16
+#define MEM_CGROUP_ID_MAX	USHRT_MAX
+
 struct mem_cgroup_stat_cpu {
 	long count[MEMCG_NR_STAT];
 	unsigned long events[MEMCG_NR_EVENTS];
@@ -312,6 +316,25 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *,
 				   struct mem_cgroup_reclaim_cookie *);
 void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
 
+static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
+{
+	return memcg->css.id;
+}
+
+/**
+ * mem_cgroup_from_id - look up a memcg from an id
+ * @id: the id to look up
+ *
+ * Caller must hold rcu_read_lock() and use css_tryget() as necessary.
+ */
+static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
+{
+	struct cgroup_subsys_state *css;
+
+	css = css_from_id(id, &memory_cgrp_subsys);
+	return mem_cgroup_from_css(css);
+}
+
 /**
  * parent_mem_cgroup - find the accounting parent of a memcg
  * @memcg: memcg whose parent to find
@@ -502,6 +525,10 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
 #else /* CONFIG_MEMCG */
+
+#define MEM_CGROUP_ID_SHIFT	0
+#define MEM_CGROUP_ID_MAX	0
+
 struct mem_cgroup;
 
 static inline void mem_cgroup_events(struct mem_cgroup *memcg,
@@ -586,6 +613,18 @@ static inline void mem_cgroup_iter_break(struct mem_cgroup *root,
 {
 }
 
+static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
+static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
+{
+	WARN_ON_ONCE(id);
+	/* XXX: This should always return root_mem_cgroup */
+	return NULL;
+}
+
 static inline bool mem_cgroup_disabled(void)
 {
 	return true;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7b6c2cfee390..f58e61315982 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -209,10 +209,12 @@ struct zone_reclaim_stat {
 };
 
 struct lruvec {
-	struct list_head lists[NR_LRU_LISTS];
-	struct zone_reclaim_stat reclaim_stat;
+	struct list_head		lists[NR_LRU_LISTS];
+	struct zone_reclaim_stat	reclaim_stat;
+	/* Evictions & activations on the inactive file list */
+	atomic_long_t			inactive_age;
 #ifdef CONFIG_MEMCG
-	struct zone *zone;
+	struct zone			*zone;
 #endif
 };
 
@@ -487,9 +489,6 @@ struct zone {
 	spinlock_t		lru_lock;
 	struct lruvec		lruvec;
 
-	/* Evictions & activations on the inactive file list */
-	atomic_long_t		inactive_age;
-
 	/*
 	 * When free pages are below this point, additional steps are taken
 	 * when reading the number of free pages to avoid per-cpu counter
diff --git a/include/linux/swap.h b/include/linux/swap.h
index b14a2bb33514..1cf3065c143b 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -317,6 +317,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 
 /* linux/mm/vmscan.c */
 extern unsigned long zone_reclaimable_pages(struct zone *zone);
+extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 953f0f984392..864e237f32d9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -268,31 +268,6 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 	return (memcg == root_mem_cgroup);
 }
 
-/*
- * We restrict the id in the range of [1, 65535], so it can fit into
- * an unsigned short.
- */
-#define MEM_CGROUP_ID_MAX	USHRT_MAX
-
-static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
-{
-	return memcg->css.id;
-}
-
-/*
- * A helper function to get mem_cgroup from ID. must be called under
- * rcu_read_lock().  The caller is responsible for calling
- * css_tryget_online() if the mem_cgroup is used for charging. (dropping
- * refcnt from swap can be called against removed memcg.)
- */
-static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
-{
-	struct cgroup_subsys_state *css;
-
-	css = css_from_id(id, &memory_cgrp_subsys);
-	return mem_cgroup_from_css(css);
-}
-
 #ifndef CONFIG_SLOB
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 45771323e863..9342a0fe8836 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -213,7 +213,7 @@ bool zone_reclaimable(struct zone *zone)
 		zone_reclaimable_pages(zone) * 6;
 }
 
-static unsigned long get_lru_size(struct lruvec *lruvec, enum lru_list lru)
+unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_lru_size(lruvec, lru);
@@ -1931,8 +1931,8 @@ static bool inactive_file_is_low(struct lruvec *lruvec)
 	unsigned long inactive;
 	unsigned long active;
 
-	inactive = get_lru_size(lruvec, LRU_INACTIVE_FILE);
-	active = get_lru_size(lruvec, LRU_ACTIVE_FILE);
+	inactive = lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
+	active = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
 
 	return active > inactive;
 }
@@ -2071,7 +2071,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_file_is_low(lruvec) &&
-	    get_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2097,10 +2097,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * anon in [0], file in [1]
 	 */
 
-	anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
-		get_lru_size(lruvec, LRU_INACTIVE_ANON);
-	file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
-		get_lru_size(lruvec, LRU_INACTIVE_FILE);
+	anon  = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_ANON);
+	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
 
 	spin_lock_irq(&zone->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
@@ -2138,7 +2138,7 @@ out:
 			unsigned long size;
 			unsigned long scan;
 
-			size = get_lru_size(lruvec, lru);
+			size = lruvec_lru_size(lruvec, lru);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
diff --git a/mm/workingset.c b/mm/workingset.c
index c5e77c3e3dca..bdc5a0f62ad8 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -153,7 +153,8 @@
  */
 
 #define EVICTION_SHIFT	(RADIX_TREE_EXCEPTIONAL_ENTRY + \
-			 ZONES_SHIFT + NODES_SHIFT)
+			 ZONES_SHIFT + NODES_SHIFT +	\
+			 MEM_CGROUP_ID_SHIFT)
 #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
 
 /*
@@ -166,9 +167,10 @@
  */
 static unsigned int bucket_order;
 
-static void *pack_shadow(unsigned long eviction, struct zone *zone)
+static void *pack_shadow(int memcgid, struct zone *zone, unsigned long eviction)
 {
 	eviction >>= bucket_order;
+	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
 	eviction = (eviction << NODES_SHIFT) | zone_to_nid(zone);
 	eviction = (eviction << ZONES_SHIFT) | zone_idx(zone);
 	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
@@ -176,18 +178,21 @@ static void *pack_shadow(unsigned long eviction, struct zone *zone)
 	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
-static void unpack_shadow(void *shadow, struct zone **zonep,
+static void unpack_shadow(void *shadow, int *memcgidp, struct zone **zonep,
 			  unsigned long *evictionp)
 {
 	unsigned long entry = (unsigned long)shadow;
-	int zid, nid;
+	int memcgid, nid, zid;
 
 	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
 	zid = entry & ((1UL << ZONES_SHIFT) - 1);
 	entry >>= ZONES_SHIFT;
 	nid = entry & ((1UL << NODES_SHIFT) - 1);
 	entry >>= NODES_SHIFT;
+	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
+	entry >>= MEM_CGROUP_ID_SHIFT;
 
+	*memcgidp = memcgid;
 	*zonep = NODE_DATA(nid)->node_zones + zid;
 	*evictionp = entry << bucket_order;
 }
@@ -202,11 +207,20 @@ static void unpack_shadow(void *shadow, struct zone **zonep,
  */
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
+	struct mem_cgroup *memcg = page_memcg(page);
 	struct zone *zone = page_zone(page);
+	int memcgid = mem_cgroup_id(memcg);
 	unsigned long eviction;
+	struct lruvec *lruvec;
 
-	eviction = atomic_long_inc_return(&zone->inactive_age);
-	return pack_shadow(eviction, zone);
+	/* Page is fully exclusive and pins page->mem_cgroup */
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+	VM_BUG_ON_PAGE(page_count(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+
+	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	eviction = atomic_long_inc_return(&lruvec->inactive_age);
+	return pack_shadow(memcgid, zone, eviction);
 }
 
 /**
@@ -221,13 +235,42 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 bool workingset_refault(void *shadow)
 {
 	unsigned long refault_distance;
+	unsigned long active_file;
+	struct mem_cgroup *memcg;
 	unsigned long eviction;
+	struct lruvec *lruvec;
 	unsigned long refault;
 	struct zone *zone;
+	int memcgid;
 
-	unpack_shadow(shadow, &zone, &eviction);
+	unpack_shadow(shadow, &memcgid, &zone, &eviction);
 
-	refault = atomic_long_read(&zone->inactive_age);
+	rcu_read_lock();
+	/*
+	 * Look up the memcg associated with the stored ID. It might
+	 * have been deleted since the page's eviction.
+	 *
+	 * Note that in rare events the ID could have been recycled
+	 * for a new cgroup that refaults a shared page. This is
+	 * impossible to tell from the available data. However, this
+	 * should be a rare and limited disturbance, and activations
+	 * are always speculative anyway. Ultimately, it's the aging
+	 * algorithm's job to shake out the minimum access frequency
+	 * for the active cache.
+	 *
+	 * XXX: On !CONFIG_MEMCG, this will always return NULL; it
+	 * would be better if the root_mem_cgroup existed in all
+	 * configurations instead.
+	 */
+	memcg = mem_cgroup_from_id(memcgid);
+	if (!mem_cgroup_disabled() && !memcg) {
+		rcu_read_unlock();
+		return false;
+	}
+	lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	refault = atomic_long_read(&lruvec->inactive_age);
+	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
+	rcu_read_unlock();
 
 	/*
 	 * The unsigned subtraction here gives an accurate distance
@@ -249,7 +292,7 @@ bool workingset_refault(void *shadow)
 
 	inc_zone_state(zone, WORKINGSET_REFAULT);
 
-	if (refault_distance <= zone_page_state(zone, NR_ACTIVE_FILE)) {
+	if (refault_distance <= active_file) {
 		inc_zone_state(zone, WORKINGSET_ACTIVATE);
 		return true;
 	}
@@ -262,7 +305,13 @@ bool workingset_refault(void *shadow)
  */
 void workingset_activation(struct page *page)
 {
-	atomic_long_inc(&page_zone(page)->inactive_age);
+	struct mem_cgroup *memcg;
+	struct lruvec *lruvec;
+
+	memcg = lock_page_memcg(page);
+	lruvec = mem_cgroup_zone_lruvec(page_zone(page), memcg);
+	atomic_long_inc(&lruvec->inactive_age);
+	unlock_page_memcg(memcg);
 }
 
 /*
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
