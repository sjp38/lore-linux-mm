Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B856E6B025F
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:35:01 -0500 (EST)
Received: by wmvv187 with SMTP id v187so226533062wmv.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:35:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cb2si5931772wjc.79.2015.12.08.10.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 10:35:00 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/8] mm: memcontrol: move kmem accounting code to CONFIG_MEMCG
Date: Tue,  8 Dec 2015 13:34:23 -0500
Message-Id: <1449599665-18047-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The cgroup2 memory controller will account important in-kernel memory
consumers per default. Move all necessary components to CONFIG_MEMCG.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/list_lru.h   |   4 +-
 include/linux/memcontrol.h | 317 ++++++++++++++++++++++-----------------------
 include/linux/sched.h      |   2 -
 include/linux/slab.h       |   2 +-
 include/linux/slab_def.h   |   3 +-
 include/linux/slub_def.h   |   2 +-
 mm/list_lru.c              |  12 +-
 mm/memcontrol.c            |  54 ++++----
 mm/slab.h                  |   6 +-
 mm/slab_common.c           |  10 +-
 mm/slub.c                  |  10 +-
 11 files changed, 206 insertions(+), 216 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 2a6b994..3c66b96 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -40,7 +40,7 @@ struct list_lru_node {
 	spinlock_t		lock;
 	/* global list, used for the root cgroup in cgroup aware lrus */
 	struct list_lru_one	lru;
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	/* for cgroup aware lrus points to per cgroup lists, otherwise NULL */
 	struct list_lru_memcg	*memcg_lrus;
 #endif
@@ -48,7 +48,7 @@ struct list_lru_node {
 
 struct list_lru {
 	struct list_lru_node	*node;
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	struct list_head	list;
 #endif
 };
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 54dab4d..80f38da 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -236,11 +236,10 @@ struct mem_cgroup {
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
 	struct cg_proto tcp_mem;
 #endif
-#if defined(CONFIG_MEMCG_KMEM)
+
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
 	enum memcg_kmem_state kmem_state;
-#endif
 
 	int last_scanned_node;
 #if MAX_NUMNODES > 1
@@ -505,6 +504,117 @@ out:
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
+extern struct static_key_false memcg_kmem_enabled_key;
+
+extern int memcg_nr_cache_ids;
+void memcg_get_cache_ids(void);
+void memcg_put_cache_ids(void);
+
+/*
+ * Helper macro to loop through all memcg-specific caches. Callers must still
+ * check if the cache is valid (it is either valid or NULL).
+ * the slab_mutex must be held when looping through those caches
+ */
+#define for_each_memcg_cache_index(_idx)	\
+	for ((_idx) = 0; (_idx) < memcg_nr_cache_ids; (_idx)++)
+
+static inline bool memcg_kmem_enabled(void)
+{
+	return static_branch_unlikely(&memcg_kmem_enabled_key);
+}
+
+static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
+{
+	return memcg->kmem_state == KMEM_ONLINE;
+}
+
+/*
+ * In general, we'll do everything in our power to not incur in any overhead
+ * for non-memcg users for the kmem functions. Not even a function call, if we
+ * can avoid it.
+ *
+ * Therefore, we'll inline all those functions so that in the best case, we'll
+ * see that kmemcg is off for everybody and proceed quickly.  If it is on,
+ * we'll still do most of the flag checking inline. We check a lot of
+ * conditions, but because they are pretty simple, they are expected to be
+ * fast.
+ */
+int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
+			      struct mem_cgroup *memcg);
+int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
+void __memcg_kmem_uncharge(struct page *page, int order);
+
+/*
+ * helper for acessing a memcg's index. It will be used as an index in the
+ * child cache array in kmem_cache, and also to derive its name. This function
+ * will return -1 when this is not a kmem-limited memcg.
+ */
+static inline int memcg_cache_id(struct mem_cgroup *memcg)
+{
+	return memcg ? memcg->kmemcg_id : -1;
+}
+
+struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
+void __memcg_kmem_put_cache(struct kmem_cache *cachep);
+
+static inline bool __memcg_kmem_bypass(void)
+{
+	if (!memcg_kmem_enabled())
+		return true;
+	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
+		return true;
+	return false;
+}
+
+/**
+ * memcg_kmem_charge: charge a kmem page
+ * @page: page to charge
+ * @gfp: reclaim mode
+ * @order: allocation order
+ *
+ * Returns 0 on success, an error code on failure.
+ */
+static __always_inline int memcg_kmem_charge(struct page *page,
+					     gfp_t gfp, int order)
+{
+	if (__memcg_kmem_bypass())
+		return 0;
+	if (!(gfp & __GFP_ACCOUNT))
+		return 0;
+	return __memcg_kmem_charge(page, gfp, order);
+}
+
+/**
+ * memcg_kmem_uncharge: uncharge a kmem page
+ * @page: page to uncharge
+ * @order: allocation order
+ */
+static __always_inline void memcg_kmem_uncharge(struct page *page, int order)
+{
+	if (memcg_kmem_enabled())
+		__memcg_kmem_uncharge(page, order);
+}
+
+/**
+ * memcg_kmem_get_cache: selects the correct per-memcg cache for allocation
+ * @cachep: the original global kmem cache
+ *
+ * All memory allocated from a per-memcg cache is charged to the owner memcg.
+ */
+static __always_inline struct kmem_cache *
+memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
+{
+	if (__memcg_kmem_bypass())
+		return cachep;
+	return __memcg_kmem_get_cache(cachep, gfp);
+}
+
+static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
+{
+	if (memcg_kmem_enabled())
+		__memcg_kmem_put_cache(cachep);
+}
+
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
@@ -680,6 +790,52 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+#define for_each_memcg_cache_index(_idx)	\
+	for (; NULL; )
+
+static inline bool memcg_kmem_enabled(void)
+{
+	return false;
+}
+
+static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
+static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
+{
+	return 0;
+}
+
+static inline void memcg_kmem_uncharge(struct page *page, int order)
+{
+}
+
+static inline int memcg_cache_id(struct mem_cgroup *memcg)
+{
+	return -1;
+}
+
+static inline void memcg_get_cache_ids(void)
+{
+}
+
+static inline void memcg_put_cache_ids(void)
+{
+}
+
+static inline struct kmem_cache *
+memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
+{
+	return cachep;
+}
+
+static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
+{
+}
+
 #endif /* CONFIG_MEMCG */
 
 #ifdef CONFIG_CGROUP_WRITEBACK
@@ -735,161 +891,4 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 }
 #endif
 
-#ifdef CONFIG_MEMCG_KMEM
-extern struct static_key_false memcg_kmem_enabled_key;
-
-extern int memcg_nr_cache_ids;
-void memcg_get_cache_ids(void);
-void memcg_put_cache_ids(void);
-
-/*
- * Helper macro to loop through all memcg-specific caches. Callers must still
- * check if the cache is valid (it is either valid or NULL).
- * the slab_mutex must be held when looping through those caches
- */
-#define for_each_memcg_cache_index(_idx)	\
-	for ((_idx) = 0; (_idx) < memcg_nr_cache_ids; (_idx)++)
-
-static inline bool memcg_kmem_enabled(void)
-{
-	return static_branch_unlikely(&memcg_kmem_enabled_key);
-}
-
-static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
-{
-	return memcg->kmem_state == KMEM_ONLINE;
-}
-
-/*
- * In general, we'll do everything in our power to not incur in any overhead
- * for non-memcg users for the kmem functions. Not even a function call, if we
- * can avoid it.
- *
- * Therefore, we'll inline all those functions so that in the best case, we'll
- * see that kmemcg is off for everybody and proceed quickly.  If it is on,
- * we'll still do most of the flag checking inline. We check a lot of
- * conditions, but because they are pretty simple, they are expected to be
- * fast.
- */
-int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
-			      struct mem_cgroup *memcg);
-int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
-void __memcg_kmem_uncharge(struct page *page, int order);
-
-/*
- * helper for acessing a memcg's index. It will be used as an index in the
- * child cache array in kmem_cache, and also to derive its name. This function
- * will return -1 when this is not a kmem-limited memcg.
- */
-static inline int memcg_cache_id(struct mem_cgroup *memcg)
-{
-	return memcg ? memcg->kmemcg_id : -1;
-}
-
-struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
-void __memcg_kmem_put_cache(struct kmem_cache *cachep);
-
-static inline bool __memcg_kmem_bypass(void)
-{
-	if (!memcg_kmem_enabled())
-		return true;
-	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
-		return true;
-	return false;
-}
-
-/**
- * memcg_kmem_charge: charge a kmem page
- * @page: page to charge
- * @gfp: reclaim mode
- * @order: allocation order
- *
- * Returns 0 on success, an error code on failure.
- */
-static __always_inline int memcg_kmem_charge(struct page *page,
-					     gfp_t gfp, int order)
-{
-	if (__memcg_kmem_bypass())
-		return 0;
-	if (!(gfp & __GFP_ACCOUNT))
-		return 0;
-	return __memcg_kmem_charge(page, gfp, order);
-}
-
-/**
- * memcg_kmem_uncharge: uncharge a kmem page
- * @page: page to uncharge
- * @order: allocation order
- */
-static __always_inline void memcg_kmem_uncharge(struct page *page, int order)
-{
-	if (memcg_kmem_enabled())
-		__memcg_kmem_uncharge(page, order);
-}
-
-/**
- * memcg_kmem_get_cache: selects the correct per-memcg cache for allocation
- * @cachep: the original global kmem cache
- *
- * All memory allocated from a per-memcg cache is charged to the owner memcg.
- */
-static __always_inline struct kmem_cache *
-memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
-{
-	if (__memcg_kmem_bypass())
-		return cachep;
-	return __memcg_kmem_get_cache(cachep, gfp);
-}
-
-static __always_inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
-{
-	if (memcg_kmem_enabled())
-		__memcg_kmem_put_cache(cachep);
-}
-#else
-#define for_each_memcg_cache_index(_idx)	\
-	for (; NULL; )
-
-static inline bool memcg_kmem_enabled(void)
-{
-	return false;
-}
-
-static inline bool memcg_kmem_online(struct mem_cgroup *memcg)
-{
-	return false;
-}
-
-static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
-{
-	return 0;
-}
-
-static inline void memcg_kmem_uncharge(struct page *page, int order)
-{
-}
-
-static inline int memcg_cache_id(struct mem_cgroup *memcg)
-{
-	return -1;
-}
-
-static inline void memcg_get_cache_ids(void)
-{
-}
-
-static inline void memcg_put_cache_ids(void)
-{
-}
-
-static inline struct kmem_cache *
-memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
-{
-	return cachep;
-}
-
-static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
-{
-}
-#endif /* CONFIG_MEMCG_KMEM */
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index edad7a4..62b5a6e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1465,8 +1465,6 @@ struct task_struct {
 	unsigned sched_migrated:1;
 #ifdef CONFIG_MEMCG
 	unsigned memcg_may_oom:1;
-#endif
-#ifdef CONFIG_MEMCG_KMEM
 	unsigned memcg_kmem_skip_account:1;
 #endif
 #ifdef CONFIG_COMPAT_BRK
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 3ffee74..b0a7034 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -86,7 +86,7 @@
 #else
 # define SLAB_FAILSLAB		0x00000000UL
 #endif
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 # define SLAB_ACCOUNT		0x04000000UL	/* Account to memcg */
 #else
 # define SLAB_ACCOUNT		0x00000000UL
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 33d0490..cf139d3 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -69,7 +69,8 @@ struct kmem_cache {
 	 */
 	int obj_offset;
 #endif /* CONFIG_DEBUG_SLAB */
-#ifdef CONFIG_MEMCG_KMEM
+
+#ifdef CONFIG_MEMCG
 	struct memcg_cache_params memcg_params;
 #endif
 
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3388511..b7e57927 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -84,7 +84,7 @@ struct kmem_cache {
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 #endif
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	struct memcg_cache_params memcg_params;
 	int max_attr_size; /* for propagation, maximum size of a stored attr */
 #ifdef CONFIG_SYSFS
diff --git a/mm/list_lru.c b/mm/list_lru.c
index afc71ea..568267d 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -12,7 +12,7 @@
 #include <linux/mutex.h>
 #include <linux/memcontrol.h>
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 static LIST_HEAD(list_lrus);
 static DEFINE_MUTEX(list_lrus_mutex);
 
@@ -37,9 +37,9 @@ static void list_lru_register(struct list_lru *lru)
 static void list_lru_unregister(struct list_lru *lru)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
 	/*
@@ -104,7 +104,7 @@ list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
 {
 	return &nlru->lru;
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
@@ -292,7 +292,7 @@ static void init_one_lru(struct list_lru_one *l)
 	l->nr_items = 0;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 static void __memcg_destroy_list_lru_node(struct list_lru_memcg *memcg_lrus,
 					  int begin, int end)
 {
@@ -529,7 +529,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 static void memcg_destroy_list_lru(struct list_lru *lru)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 		    struct lock_class_key *key)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 55a3f07..ab72c47 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -297,7 +297,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return mem_cgroup_from_css(css);
 }
 
-#ifdef CONFIG_MEMCG_KMEM
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
  * The main reason for not using cgroup id for this:
@@ -349,8 +348,6 @@ void memcg_put_cache_ids(void)
 DEFINE_STATIC_KEY_FALSE(memcg_kmem_enabled_key);
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
-#endif /* CONFIG_MEMCG_KMEM */
-
 static struct mem_cgroup_per_zone *
 mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
 {
@@ -2182,7 +2179,6 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		unlock_page_lru(page, isolated);
 }
 
-#ifdef CONFIG_MEMCG_KMEM
 static int memcg_alloc_cache_id(void)
 {
 	int id, size;
@@ -2403,7 +2399,6 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 	page->mem_cgroup = NULL;
 	css_put_many(&memcg->css, nr_pages);
 }
-#endif /* CONFIG_MEMCG_KMEM */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
@@ -2839,7 +2834,6 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	}
 }
 
-#ifdef CONFIG_MEMCG_KMEM
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	int err = 0;
@@ -2887,24 +2881,6 @@ out:
 	return err;
 }
 
-static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
-				   unsigned long limit)
-{
-	int ret;
-
-	mutex_lock(&memcg_limit_mutex);
-	/* Top-level cgroup doesn't propagate from root */
-	if (!memcg_kmem_online(memcg)) {
-		ret = memcg_online_kmem(memcg);
-		if (ret)
-			goto out;
-	}
-	ret = page_counter_limit(&memcg->kmem, limit);
-out:
-	mutex_unlock(&memcg_limit_mutex);
-	return ret;
-}
-
 static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 {
 	int ret = 0;
@@ -2978,14 +2954,30 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 		WARN_ON(page_counter_read(&memcg->kmem));
 	}
 }
-#else
+
+#ifdef CONFIG_MEMCG_KMEM
 static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
 				   unsigned long limit)
 {
-	return -EINVAL;
+	int ret;
+
+	mutex_lock(&memcg_limit_mutex);
+	/* Top-level cgroup doesn't propagate from root */
+	if (!memcg_kmem_online(memcg)) {
+		ret = memcg_online_kmem(memcg);
+		if (ret)
+			goto out;
+	}
+	ret = page_counter_limit(&memcg->kmem, limit);
+out:
+	mutex_unlock(&memcg_limit_mutex);
+	return ret;
 }
-static void memcg_offline_kmem(struct mem_cgroup *memcg)
+#else
+static int memcg_update_kmem_limit(struct mem_cgroup *memcg,
+				   unsigned long limit)
 {
+	return -EINVAL;
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
@@ -4160,9 +4152,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	vmpressure_init(&memcg->vmpressure);
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
-#ifdef CONFIG_MEMCG_KMEM
 	memcg->kmemcg_id = -1;
-#endif
 #ifdef CONFIG_CGROUP_WRITEBACK
 	INIT_LIST_HEAD(&memcg->cgwb_list);
 #endif
@@ -4222,10 +4212,11 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	}
 	mutex_unlock(&memcg_create_mutex);
 
-#ifdef CONFIG_MEMCG_KMEM
 	ret = memcg_propagate_kmem(memcg);
 	if (ret)
 		return ret;
+
+#ifdef CONFIG_MEMCG_KMEM
 	ret = tcp_init_cgroup(memcg);
 	if (ret)
 		return ret;
@@ -4279,8 +4270,9 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 		static_branch_dec(&memcg_sockets_enabled_key);
 #endif
 
-#ifdef CONFIG_MEMCG_KMEM
 	memcg_free_kmem(memcg);
+
+#ifdef CONFIG_MEMCG_KMEM
 	tcp_destroy_cgroup(memcg);
 #endif
 
diff --git a/mm/slab.h b/mm/slab.h
index c63b869..5adec08 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -173,7 +173,7 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 /*
  * Iterate over all memcg caches of the given root cache. The caller must hold
  * slab_mutex.
@@ -251,7 +251,7 @@ static __always_inline int memcg_charge_slab(struct page *page,
 
 extern void slab_init_memcg_params(struct kmem_cache *);
 
-#else /* !CONFIG_MEMCG_KMEM */
+#else /* !CONFIG_MEMCG */
 
 #define for_each_memcg_cache(iter, root) \
 	for ((void)(iter), (void)(root); 0; )
@@ -292,7 +292,7 @@ static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
 static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8c262e6..34103b8 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -128,7 +128,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 	return i;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 void slab_init_memcg_params(struct kmem_cache *s)
 {
 	s->memcg_params.is_root_cache = true;
@@ -221,7 +221,7 @@ static inline int init_memcg_params(struct kmem_cache *s,
 static inline void destroy_memcg_params(struct kmem_cache *s)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 /*
  * Find a mergeable slab cache
@@ -477,7 +477,7 @@ static void release_caches(struct list_head *release, bool need_rcu_barrier)
 	}
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 /*
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
@@ -689,7 +689,7 @@ static inline int shutdown_memcg_caches(struct kmem_cache *s,
 {
 	return 0;
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
@@ -1123,7 +1123,7 @@ static int slab_show(struct seq_file *m, void *p)
 	return 0;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 int memcg_slab_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *s = list_entry(p, struct kmem_cache, list);
diff --git a/mm/slub.c b/mm/slub.c
index b21fd24..2e1355a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5207,7 +5207,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 		return -EIO;
 
 	err = attribute->store(s, buf, len);
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	if (slab_state >= FULL && err >= 0 && is_root_cache(s)) {
 		struct kmem_cache *c;
 
@@ -5242,7 +5242,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 
 static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 {
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	int i;
 	char *buffer = NULL;
 	struct kmem_cache *root_cache;
@@ -5328,7 +5328,7 @@ static struct kset *slab_kset;
 
 static inline struct kset *cache_kset(struct kmem_cache *s)
 {
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	if (!is_root_cache(s))
 		return s->memcg_params.root_cache->memcg_kset;
 #endif
@@ -5405,7 +5405,7 @@ static int sysfs_slab_add(struct kmem_cache *s)
 	if (err)
 		goto out_del_kobj;
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	if (is_root_cache(s)) {
 		s->memcg_kset = kset_create_and_add("cgroup", NULL, &s->kobj);
 		if (!s->memcg_kset) {
@@ -5438,7 +5438,7 @@ void sysfs_slab_remove(struct kmem_cache *s)
 		 */
 		return;
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifdef CONFIG_MEMCG
 	kset_unregister(s->memcg_kset);
 #endif
 	kobject_uevent(&s->kobj, KOBJ_REMOVE);
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
