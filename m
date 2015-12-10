Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 95B3E6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 15:22:59 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id c201so50468080wme.0
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 12:22:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s3si592387wmb.30.2015.12.10.12.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 12:22:58 -0800 (PST)
Date: Thu, 10 Dec 2015 15:22:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 6/8 v2] mm: memcontrol: move kmem accounting code to
 CONFIG_MEMCG
Message-ID: <20151210202244.GA4809@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-7-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449599665-18047-7-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Arnd Bergmann <arnd@arndb.de>

The cgroup2 memory controller will account important in-kernel memory
consumers per default. Move all necessary components to CONFIG_MEMCG.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

Hi Andrew,

here is a drop-in replacement for what's in your tree to make slob
work with memcg again. It guards all the kmem-specific stuff with
CONFIG_MEMCG && !CONFIG_SLOB. A little lame but I figure it's not
worth introducing another level of indirection and go through the
trouble of finding a more meaningful symbol (CONFIG_MEMCG_KMEM is
taken, CONFIG_MEMCG_SLAB is ambiguous with SLAB vs. SLUB etc.).

So there.

The rest of my series applies fine on top, but if this creates fallout
in subsequent patches you have in your tree I'm happy to send refreshs.

Thanks again for your report, Arnd!

 include/linux/list_lru.h   |  4 +--
 include/linux/memcontrol.h |  7 +++--
 include/linux/sched.h      |  4 +--
 include/linux/slab_def.h   |  3 +-
 include/linux/slub_def.h   |  2 +-
 mm/list_lru.c              | 12 ++++----
 mm/memcontrol.c            | 69 +++++++++++++++++++++++++++-------------------
 mm/slab.h                  |  6 ++--
 mm/slab_common.c           | 10 +++----
 mm/slub.c                  | 10 +++----
 10 files changed, 71 insertions(+), 56 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 2a6b994..cb0ba9f 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -40,7 +40,7 @@ struct list_lru_node {
 	spinlock_t		lock;
 	/* global list, used for the root cgroup in cgroup aware lrus */
 	struct list_lru_one	lru;
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 	/* for cgroup aware lrus points to per cgroup lists, otherwise NULL */
 	struct list_lru_memcg	*memcg_lrus;
 #endif
@@ -48,7 +48,7 @@ struct list_lru_node {
 
 struct list_lru {
 	struct list_lru_node	*node;
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 	struct list_head	list;
 #endif
 };
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 54dab4d..a87704e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -236,7 +236,7 @@ struct mem_cgroup {
 #if defined(CONFIG_MEMCG_KMEM) && defined(CONFIG_INET)
 	struct cg_proto tcp_mem;
 #endif
-#if defined(CONFIG_MEMCG_KMEM)
+#ifndef CONFIG_SLOB
         /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
 	enum memcg_kmem_state kmem_state;
@@ -735,7 +735,7 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 }
 #endif
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 extern struct static_key_false memcg_kmem_enabled_key;
 
 extern int memcg_nr_cache_ids;
@@ -891,5 +891,6 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 static inline void memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
+
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index edad7a4..ccf957e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1465,10 +1465,10 @@ struct task_struct {
 	unsigned sched_migrated:1;
 #ifdef CONFIG_MEMCG
 	unsigned memcg_may_oom:1;
-#endif
-#ifdef CONFIG_MEMCG_KMEM
+#ifndef CONFIG_SLOB
 	unsigned memcg_kmem_skip_account:1;
 #endif
+#endif
 #ifdef CONFIG_COMPAT_BRK
 	unsigned brk_randomized:1;
 #endif
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
index afc71ea..1d05cb9 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -12,7 +12,7 @@
 #include <linux/mutex.h>
 #include <linux/memcontrol.h>
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 static LIST_HEAD(list_lrus);
 static DEFINE_MUTEX(list_lrus_mutex);
 
@@ -37,9 +37,9 @@ static void list_lru_register(struct list_lru *lru)
 static void list_lru_unregister(struct list_lru *lru)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 static inline bool list_lru_memcg_aware(struct list_lru *lru)
 {
 	/*
@@ -104,7 +104,7 @@ list_lru_from_kmem(struct list_lru_node *nlru, void *ptr)
 {
 	return &nlru->lru;
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 bool list_lru_add(struct list_lru *lru, struct list_head *item)
 {
@@ -292,7 +292,7 @@ static void init_one_lru(struct list_lru_one *l)
 	l->nr_items = 0;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 static void __memcg_destroy_list_lru_node(struct list_lru_memcg *memcg_lrus,
 					  int begin, int end)
 {
@@ -529,7 +529,7 @@ static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)
 static void memcg_destroy_list_lru(struct list_lru *lru)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 		    struct lock_class_key *key)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 55a3f07..70e6fd1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -297,7 +297,7 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return mem_cgroup_from_css(css);
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifndef CONFIG_SLOB
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
  * The main reason for not using cgroup id for this:
@@ -349,7 +349,7 @@ void memcg_put_cache_ids(void)
 DEFINE_STATIC_KEY_FALSE(memcg_kmem_enabled_key);
 EXPORT_SYMBOL(memcg_kmem_enabled_key);
 
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* !CONFIG_SLOB */
 
 static struct mem_cgroup_per_zone *
 mem_cgroup_zone_zoneinfo(struct mem_cgroup *memcg, struct zone *zone)
@@ -2182,7 +2182,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 		unlock_page_lru(page, isolated);
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifndef CONFIG_SLOB
 static int memcg_alloc_cache_id(void)
 {
 	int id, size;
@@ -2403,7 +2403,7 @@ void __memcg_kmem_uncharge(struct page *page, int order)
 	page->mem_cgroup = NULL;
 	css_put_many(&memcg->css, nr_pages);
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* !CONFIG_SLOB */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
@@ -2839,7 +2839,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 	}
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#ifndef CONFIG_SLOB
 static int memcg_online_kmem(struct mem_cgroup *memcg)
 {
 	int err = 0;
@@ -2887,24 +2887,6 @@ out:
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
@@ -2979,16 +2961,45 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
 	}
 }
 #else
+static int memcg_propagate_kmem(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+static void memcg_offline_kmem(struct mem_cgroup *memcg)
+{
+}
+static void memcg_free_kmem(struct mem_cgroup *memcg)
+{
+}
+#endif /* !CONFIG_SLOB */
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
 
+
 /*
  * The user of this function is...
  * RES_LIMIT.
@@ -4160,7 +4171,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	vmpressure_init(&memcg->vmpressure);
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
-#ifdef CONFIG_MEMCG_KMEM
+#ifndef CONFIG_SLOB
 	memcg->kmemcg_id = -1;
 #endif
 #ifdef CONFIG_CGROUP_WRITEBACK
@@ -4222,10 +4233,11 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
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
@@ -4279,8 +4291,9 @@ static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
 		static_branch_dec(&memcg_sockets_enabled_key);
 #endif
 
-#ifdef CONFIG_MEMCG_KMEM
 	memcg_free_kmem(memcg);
+
+#ifdef CONFIG_MEMCG_KMEM
 	tcp_destroy_cgroup(memcg);
 #endif
 
diff --git a/mm/slab.h b/mm/slab.h
index c63b869..834ad24 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -173,7 +173,7 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int __kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 /*
  * Iterate over all memcg caches of the given root cache. The caller must hold
  * slab_mutex.
@@ -251,7 +251,7 @@ static __always_inline int memcg_charge_slab(struct page *page,
 
 extern void slab_init_memcg_params(struct kmem_cache *);
 
-#else /* !CONFIG_MEMCG_KMEM */
+#else /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 #define for_each_memcg_cache(iter, root) \
 	for ((void)(iter), (void)(root); 0; )
@@ -292,7 +292,7 @@ static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
 static inline void slab_init_memcg_params(struct kmem_cache *s)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8c262e6..b50aef0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -128,7 +128,7 @@ int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
 	return i;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 void slab_init_memcg_params(struct kmem_cache *s)
 {
 	s->memcg_params.is_root_cache = true;
@@ -221,7 +221,7 @@ static inline int init_memcg_params(struct kmem_cache *s,
 static inline void destroy_memcg_params(struct kmem_cache *s)
 {
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 /*
  * Find a mergeable slab cache
@@ -477,7 +477,7 @@ static void release_caches(struct list_head *release, bool need_rcu_barrier)
 	}
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 /*
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
@@ -689,7 +689,7 @@ static inline int shutdown_memcg_caches(struct kmem_cache *s,
 {
 	return 0;
 }
-#endif /* CONFIG_MEMCG_KMEM */
+#endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
@@ -1123,7 +1123,7 @@ static int slab_show(struct seq_file *m, void *p)
 	return 0;
 }
 
-#ifdef CONFIG_MEMCG_KMEM
+#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
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
