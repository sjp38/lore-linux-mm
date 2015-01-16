Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA7D6B0038
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:13:25 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so24507296pab.4
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:13:25 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id km8si5451984pbc.254.2015.01.16.06.13.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:13:23 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 1/6] slab: embed memcg_cache_params to kmem_cache
Date: Fri, 16 Jan 2015 17:13:01 +0300
Message-ID: <7607f4a7b9ec0a3a2740855ee07362f742d76893.1421411660.git.vdavydov@parallels.com>
In-Reply-To: <cover.1421411660.git.vdavydov@parallels.com>
References: <cover.1421411660.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, kmem_cache stores a pointer to struct memcg_cache_params
instead of embedding it. The rationale is to save memory when kmem
accounting is disabled. However, the memcg_cache_params has shrivelled
drastically since it was first introduced:

* Initially:

struct memcg_cache_params {
	bool is_root_cache;
	union {
		struct kmem_cache *memcg_caches[0];
		struct {
			struct mem_cgroup *memcg;
			struct list_head list;
			struct kmem_cache *root_cache;
			bool dead;
			atomic_t nr_pages;
			struct work_struct destroy;
		};
	};
};

* Now:

struct memcg_cache_params {
	bool is_root_cache;
	union {
		struct {
			struct rcu_head rcu_head;
			struct kmem_cache *memcg_caches[0];
		};
		struct {
			struct mem_cgroup *memcg;
			struct kmem_cache *root_cache;
		};
	};
};

So the memory saving does not seem to be a clear win anymore.

OTOH, keeping a pointer to memcg_cache_params struct instead of
embedding it results in touching one more cache line on kmem alloc/free
hot paths. Besides, it makes linking kmem caches in a list chained by a
field of struct memcg_cache_params really painful due to a level of
indirection, while I want to make them linked in the following patch.
That said, let us embed it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h     |   17 +++----
 include/linux/slab_def.h |    2 +-
 include/linux/slub_def.h |    2 +-
 mm/memcontrol.c          |   11 ++--
 mm/slab.h                |   48 +++++++++---------
 mm/slab_common.c         |  126 +++++++++++++++++++++++++---------------------
 mm/slub.c                |    5 +-
 7 files changed, 109 insertions(+), 102 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 2e3b448cfa2d..1e03c11bbfbd 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -473,14 +473,14 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 #ifndef ARCH_SLAB_MINALIGN
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
+
+struct memcg_cache_array {
+	struct rcu_head rcu;
+	struct kmem_cache *entries[0];
+};
+
 /*
  * This is the main placeholder for memcg-related information in kmem caches.
- * struct kmem_cache will hold a pointer to it, so the memory cost while
- * disabled is 1 pointer. The runtime cost while enabled, gets bigger than it
- * would otherwise be if that would be bundled in kmem_cache: we'll need an
- * extra pointer chase. But the trade off clearly lays in favor of not
- * penalizing non-users.
- *
  * Both the root cache and the child caches will have it. For the root cache,
  * this will hold a dynamically allocated array large enough to hold
  * information about the currently limited memcgs in the system. To allow the
@@ -495,10 +495,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 struct memcg_cache_params {
 	bool is_root_cache;
 	union {
-		struct {
-			struct rcu_head rcu_head;
-			struct kmem_cache *memcg_caches[0];
-		};
+		struct memcg_cache_array __rcu *memcg_caches;
 		struct {
 			struct mem_cgroup *memcg;
 			struct kmem_cache *root_cache;
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index b869d1662ba3..33d049066c3d 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -70,7 +70,7 @@ struct kmem_cache {
 	int obj_offset;
 #endif /* CONFIG_DEBUG_SLAB */
 #ifdef CONFIG_MEMCG_KMEM
-	struct memcg_cache_params *memcg_params;
+	struct memcg_cache_params memcg_params;
 #endif
 
 	struct kmem_cache_node *node[MAX_NUMNODES];
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d82abd40a3c0..9abf04ed0999 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -85,7 +85,7 @@ struct kmem_cache {
 	struct kobject kobj;	/* For sysfs */
 #endif
 #ifdef CONFIG_MEMCG_KMEM
-	struct memcg_cache_params *memcg_params;
+	struct memcg_cache_params memcg_params;
 	int max_attr_size; /* for propagation, maximum size of a stored attr */
 #ifdef CONFIG_SYSFS
 	struct kset *memcg_kset;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 825ef6a273e9..f03bd5b2797e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -345,7 +345,7 @@ struct mem_cgroup {
 	struct cg_proto tcp_mem;
 #endif
 #if defined(CONFIG_MEMCG_KMEM)
-        /* Index in the kmem_cache->memcg_params->memcg_caches array */
+        /* Index in the kmem_cache->memcg_params.memcg_caches array */
 	int kmemcg_id;
 #endif
 
@@ -557,7 +557,7 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
 
 #ifdef CONFIG_MEMCG_KMEM
 /*
- * This will be the memcg's index in each cache's ->memcg_params->memcg_caches.
+ * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
  * The main reason for not using cgroup id for this:
  *  this works better in sparse environments, where we have a lot of memcgs,
  *  but only a few kmem-limited. Or also, if we have, for instance, 200
@@ -2676,8 +2676,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep)
 	struct mem_cgroup *memcg;
 	struct kmem_cache *memcg_cachep;
 
-	VM_BUG_ON(!cachep->memcg_params);
-	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
+	VM_BUG_ON(!is_root_cache(cachep));
 
 	if (current->memcg_kmem_skip_account)
 		return cachep;
@@ -2711,7 +2710,7 @@ out:
 void __memcg_kmem_put_cache(struct kmem_cache *cachep)
 {
 	if (!is_root_cache(cachep))
-		css_put(&cachep->memcg_params->memcg->css);
+		css_put(&cachep->memcg_params.memcg->css);
 }
 
 /*
@@ -2787,7 +2786,7 @@ struct mem_cgroup *__mem_cgroup_from_kmem(void *ptr)
 	if (PageSlab(page)) {
 		cachep = page->slab_cache;
 		if (!is_root_cache(cachep))
-			memcg = cachep->memcg_params->memcg;
+			memcg = cachep->memcg_params.memcg;
 	} else
 		/* page allocated by alloc_kmem_pages */
 		memcg = page->mem_cgroup;
diff --git a/mm/slab.h b/mm/slab.h
index 90430d6f665e..53a623f85931 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -86,8 +86,6 @@ extern struct kmem_cache *create_kmalloc_cache(const char *name, size_t size,
 extern void create_boot_cache(struct kmem_cache *, const char *name,
 			size_t size, unsigned long flags);
 
-struct mem_cgroup;
-
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
 		unsigned long flags, const char *name, void (*ctor)(void *));
@@ -167,14 +165,13 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 #ifdef CONFIG_MEMCG_KMEM
 static inline bool is_root_cache(struct kmem_cache *s)
 {
-	return !s->memcg_params || s->memcg_params->is_root_cache;
+	return s->memcg_params.is_root_cache;
 }
 
 static inline bool slab_equal_or_root(struct kmem_cache *s,
-					struct kmem_cache *p)
+				      struct kmem_cache *p)
 {
-	return (p == s) ||
-		(s->memcg_params && (p == s->memcg_params->root_cache));
+	return p == s || p == s->memcg_params.root_cache;
 }
 
 /*
@@ -185,37 +182,30 @@ static inline bool slab_equal_or_root(struct kmem_cache *s,
 static inline const char *cache_name(struct kmem_cache *s)
 {
 	if (!is_root_cache(s))
-		return s->memcg_params->root_cache->name;
+		s = s->memcg_params.root_cache;
 	return s->name;
 }
 
 /*
  * Note, we protect with RCU only the memcg_caches array, not per-memcg caches.
- * That said the caller must assure the memcg's cache won't go away. Since once
- * created a memcg's cache is destroyed only along with the root cache, it is
- * true if we are going to allocate from the cache or hold a reference to the
- * root cache by other means. Otherwise, we should hold either the slab_mutex
- * or the memcg's slab_caches_mutex while calling this function and accessing
- * the returned value.
+ * That said the caller must assure the memcg's cache won't go away by either
+ * taking a css reference to the owner cgroup, or holding the slab_mutex.
  */
 static inline struct kmem_cache *
 cache_from_memcg_idx(struct kmem_cache *s, int idx)
 {
 	struct kmem_cache *cachep;
-	struct memcg_cache_params *params;
-
-	if (!s->memcg_params)
-		return NULL;
+	struct memcg_cache_array *arr;
 
 	rcu_read_lock();
-	params = rcu_dereference(s->memcg_params);
+	arr = rcu_dereference(s->memcg_params.memcg_caches);
 
 	/*
 	 * Make sure we will access the up-to-date value. The code updating
 	 * memcg_caches issues a write barrier to match this (see
-	 * memcg_register_cache()).
+	 * memcg_create_kmem_cache()).
 	 */
-	cachep = lockless_dereference(params->memcg_caches[idx]);
+	cachep = lockless_dereference(arr->entries[idx]);
 	rcu_read_unlock();
 
 	return cachep;
@@ -225,7 +215,7 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	if (is_root_cache(s))
 		return s;
-	return s->memcg_params->root_cache;
+	return s->memcg_params.root_cache;
 }
 
 static __always_inline int memcg_charge_slab(struct kmem_cache *s,
@@ -235,7 +225,7 @@ static __always_inline int memcg_charge_slab(struct kmem_cache *s,
 		return 0;
 	if (is_root_cache(s))
 		return 0;
-	return memcg_charge_kmem(s->memcg_params->memcg, gfp, 1 << order);
+	return memcg_charge_kmem(s->memcg_params.memcg, gfp, 1 << order);
 }
 
 static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
@@ -244,9 +234,13 @@ static __always_inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
 		return;
 	if (is_root_cache(s))
 		return;
-	memcg_uncharge_kmem(s->memcg_params->memcg, 1 << order);
+	memcg_uncharge_kmem(s->memcg_params.memcg, 1 << order);
 }
-#else
+
+extern void slab_init_memcg_params(struct kmem_cache *);
+
+#else /* !CONFIG_MEMCG_KMEM */
+
 static inline bool is_root_cache(struct kmem_cache *s)
 {
 	return true;
@@ -282,7 +276,11 @@ static inline int memcg_charge_slab(struct kmem_cache *s, gfp_t gfp, int order)
 static inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
 {
 }
-#endif
+
+static inline void slab_init_memcg_params(struct kmem_cache *s)
+{
+}
+#endif /* CONFIG_MEMCG_KMEM */
 
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 42bb22cb4219..4f1492a9e2da 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -106,62 +106,65 @@ static inline int kmem_cache_sanity_check(const char *name, size_t size)
 #endif
 
 #ifdef CONFIG_MEMCG_KMEM
-static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
-		struct kmem_cache *s, struct kmem_cache *root_cache)
+void slab_init_memcg_params(struct kmem_cache *s)
 {
-	size_t size;
+	s->memcg_params.is_root_cache = true;
+	RCU_INIT_POINTER(s->memcg_params.memcg_caches, NULL);
+}
+
+static int init_memcg_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+{
+	struct memcg_cache_array *arr;
 
-	if (!memcg_kmem_enabled())
+	if (memcg) {
+		s->memcg_params.is_root_cache = false;
+		s->memcg_params.memcg = memcg;
+		s->memcg_params.root_cache = root_cache;
 		return 0;
+	}
 
-	if (!memcg) {
-		size = offsetof(struct memcg_cache_params, memcg_caches);
-		size += memcg_nr_cache_ids * sizeof(void *);
-	} else
-		size = sizeof(struct memcg_cache_params);
+	slab_init_memcg_params(s);
 
-	s->memcg_params = kzalloc(size, GFP_KERNEL);
-	if (!s->memcg_params)
-		return -ENOMEM;
+	if (!memcg_nr_cache_ids)
+		return 0;
 
-	if (memcg) {
-		s->memcg_params->memcg = memcg;
-		s->memcg_params->root_cache = root_cache;
-	} else
-		s->memcg_params->is_root_cache = true;
+	arr = kzalloc(sizeof(struct memcg_cache_array) +
+		      memcg_nr_cache_ids * sizeof(void *),
+		      GFP_KERNEL);
+	if (!arr)
+		return -ENOMEM;
 
+	RCU_INIT_POINTER(s->memcg_params.memcg_caches, arr);
 	return 0;
 }
 
-static void memcg_free_cache_params(struct kmem_cache *s)
+static void destroy_memcg_params(struct kmem_cache *s)
 {
-	kfree(s->memcg_params);
+	if (is_root_cache(s))
+		kfree(rcu_access_pointer(s->memcg_params.memcg_caches));
 }
 
-static int memcg_update_cache_params(struct kmem_cache *s, int num_memcgs)
+static int update_memcg_params(struct kmem_cache *s, int new_array_size)
 {
-	int size;
-	struct memcg_cache_params *new_params, *cur_params;
+	struct memcg_cache_array *old, *new;
 
-	BUG_ON(!is_root_cache(s));
-
-	size = offsetof(struct memcg_cache_params, memcg_caches);
-	size += num_memcgs * sizeof(void *);
+	if (!is_root_cache(s))
+		return 0;
 
-	new_params = kzalloc(size, GFP_KERNEL);
-	if (!new_params)
+	old = rcu_dereference_protected(s->memcg_params.memcg_caches,
+					lockdep_is_held(&slab_mutex));
+	new = kzalloc(sizeof(struct memcg_cache_array) +
+		      new_array_size * sizeof(void *), GFP_KERNEL);
+	if (!new)
 		return -ENOMEM;
 
-	cur_params = s->memcg_params;
-	memcpy(new_params->memcg_caches, cur_params->memcg_caches,
+	memcpy(new->entries, old->entries,
 	       memcg_nr_cache_ids * sizeof(void *));
 
-	new_params->is_root_cache = true;
-
-	rcu_assign_pointer(s->memcg_params, new_params);
-	if (cur_params)
-		kfree_rcu(cur_params, rcu_head);
-
+	rcu_assign_pointer(s->memcg_params.memcg_caches, new);
+	if (old)
+		kfree_rcu(old, rcu);
 	return 0;
 }
 
@@ -172,10 +175,7 @@ int memcg_update_all_caches(int num_memcgs)
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_caches, list) {
-		if (!is_root_cache(s))
-			continue;
-
-		ret = memcg_update_cache_params(s, num_memcgs);
+		ret = update_memcg_params(s, num_memcgs);
 		/*
 		 * Instead of freeing the memory, we'll just leave the caches
 		 * up to this point in an updated state.
@@ -187,13 +187,13 @@ int memcg_update_all_caches(int num_memcgs)
 	return ret;
 }
 #else
-static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
-		struct kmem_cache *s, struct kmem_cache *root_cache)
+static inline int init_memcg_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	return 0;
 }
 
-static inline void memcg_free_cache_params(struct kmem_cache *s)
+static inline void destroy_memcg_params(struct kmem_cache *s)
 {
 }
 #endif /* CONFIG_MEMCG_KMEM */
@@ -311,7 +311,7 @@ do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
 	s->align = align;
 	s->ctor = ctor;
 
-	err = memcg_alloc_cache_params(memcg, s, root_cache);
+	err = init_memcg_params(s, memcg, root_cache);
 	if (err)
 		goto out_free_cache;
 
@@ -327,7 +327,7 @@ out:
 	return s;
 
 out_free_cache:
-	memcg_free_cache_params(s);
+	destroy_memcg_params(s);
 	kfree(s);
 	goto out;
 }
@@ -439,11 +439,15 @@ static int do_kmem_cache_shutdown(struct kmem_cache *s,
 
 #ifdef CONFIG_MEMCG_KMEM
 	if (!is_root_cache(s)) {
-		struct kmem_cache *root_cache = s->memcg_params->root_cache;
-		int memcg_id = memcg_cache_id(s->memcg_params->memcg);
-
-		BUG_ON(root_cache->memcg_params->memcg_caches[memcg_id] != s);
-		root_cache->memcg_params->memcg_caches[memcg_id] = NULL;
+		int idx;
+		struct memcg_cache_array *arr;
+
+		idx = memcg_cache_id(s->memcg_params.memcg);
+		arr = rcu_dereference_protected(s->memcg_params.root_cache->
+						memcg_params.memcg_caches,
+						lockdep_is_held(&slab_mutex));
+		BUG_ON(arr->entries[idx] != s);
+		arr->entries[idx] = NULL;
 	}
 #endif
 	list_move(&s->list, release);
@@ -481,27 +485,32 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 			     struct kmem_cache *root_cache)
 {
 	static char memcg_name_buf[NAME_MAX + 1]; /* protected by slab_mutex */
-	int memcg_id = memcg_cache_id(memcg);
+	struct memcg_cache_array *arr;
 	struct kmem_cache *s = NULL;
 	char *cache_name;
+	int idx;
 
 	get_online_cpus();
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
+	idx = memcg_cache_id(memcg);
+	arr = rcu_dereference_protected(root_cache->memcg_params.memcg_caches,
+					lockdep_is_held(&slab_mutex));
+
 	/*
 	 * Since per-memcg caches are created asynchronously on first
 	 * allocation (see memcg_kmem_get_cache()), several threads can try to
 	 * create the same cache, but only one of them may succeed.
 	 */
-	if (cache_from_memcg_idx(root_cache, memcg_id))
+	if (arr->entries[idx])
 		goto out_unlock;
 
 	cgroup_name(mem_cgroup_css(memcg)->cgroup,
 		    memcg_name_buf, sizeof(memcg_name_buf));
 	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			       memcg_cache_id(memcg), memcg_name_buf);
+			       idx, memcg_name_buf);
 	if (!cache_name)
 		goto out_unlock;
 
@@ -525,7 +534,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	 * initialized.
 	 */
 	smp_wmb();
-	root_cache->memcg_params->memcg_caches[memcg_id] = s;
+	arr->entries[idx] = s;
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
@@ -545,7 +554,7 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry_safe(s, s2, &slab_caches, list) {
-		if (is_root_cache(s) || s->memcg_params->memcg != memcg)
+		if (is_root_cache(s) || s->memcg_params.memcg != memcg)
 			continue;
 		/*
 		 * The cgroup is about to be freed and therefore has no charges
@@ -564,7 +573,7 @@ void memcg_destroy_kmem_caches(struct mem_cgroup *memcg)
 
 void slab_kmem_cache_release(struct kmem_cache *s)
 {
-	memcg_free_cache_params(s);
+	destroy_memcg_params(s);
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
 }
@@ -640,6 +649,9 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t siz
 	s->name = name;
 	s->size = s->object_size = size;
 	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
+
+	slab_init_memcg_params(s);
+
 	err = __kmem_cache_create(s, flags);
 
 	if (err)
@@ -980,7 +992,7 @@ int memcg_slab_show(struct seq_file *m, void *p)
 
 	if (p == slab_caches.next)
 		print_slabinfo_header(m);
-	if (!is_root_cache(s) && s->memcg_params->memcg == memcg)
+	if (!is_root_cache(s) && s->memcg_params.memcg == memcg)
 		cache_show(s, m);
 	return 0;
 }
diff --git a/mm/slub.c b/mm/slub.c
index fe376fe1f4fe..84f8b7446558 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3566,6 +3566,7 @@ static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 			p->slab_cache = s;
 #endif
 	}
+	slab_init_memcg_params(s);
 	list_add(&s->list, &slab_caches);
 	return s;
 }
@@ -4953,7 +4954,7 @@ static void memcg_propagate_slab_attrs(struct kmem_cache *s)
 	if (is_root_cache(s))
 		return;
 
-	root_cache = s->memcg_params->root_cache;
+	root_cache = s->memcg_params.root_cache;
 
 	/*
 	 * This mean this cache had no attribute written. Therefore, no point
@@ -5033,7 +5034,7 @@ static inline struct kset *cache_kset(struct kmem_cache *s)
 {
 #ifdef CONFIG_MEMCG_KMEM
 	if (!is_root_cache(s))
-		return s->memcg_params->root_cache->memcg_kset;
+		return s->memcg_params.root_cache->memcg_kset;
 #endif
 	return slab_kset;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
