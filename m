Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id E03406B00A8
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 10:05:39 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id gf5so704344lab.7
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 07:05:39 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id am3si1829421lac.82.2014.02.26.07.05.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 07:05:37 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 06/12] memcg: keep all children of each root cache on a list
Date: Wed, 26 Feb 2014 19:05:11 +0400
Message-ID: <dd50a45cc763881b01dc67b9b4bbbe603fdfd945.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
References: <cover.1393423762.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Sometimes we need to iterate over all child caches of a particular root
cache, e.g. when we are destroying it. Currently each root cache keeps
pointers to its children in its memcg_cache_params::memcg_caches_array
so that we can enumerate all active kmemcg ids dereferencing appropriate
array slots to get a memcg. However, this is going to change when memcg
cache reparenting is introduced - only active (not dead) caches will
reside in this array. So let's organize all child caches of the same
root cache into a list on memcg_cache_params.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>
---
 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    3 +++
 mm/memcontrol.c            |   36 +++++++++++++++++++-----------------
 mm/slab.c                  |   38 ++++++++++++++++++++++----------------
 mm/slab_common.c           |   19 +++++++++----------
 mm/slub.c                  |   41 +++++++++++++++++++++++++----------------
 6 files changed, 79 insertions(+), 60 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6128323ea453..b38b52ce59fb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -512,7 +512,7 @@ void memcg_update_array_size(int num_groups);
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
-int kmem_cache_destroy_memcg_children(struct kmem_cache *s);
+void kmem_cache_destroy_memcg_children(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index f2fd4212976e..8091d009cd72 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -524,6 +524,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
+ * @siblings: list_head for the list of all child caches of the root_cache
  * @refcount: the reference counter; cache destruction will be scheduled when
  *            it reaches zero
  * @destroy: worker to be called whenever we are ready, or believe we may be
@@ -533,6 +534,7 @@ struct memcg_cache_params {
 	bool is_root_cache;
 	union {
 		struct {
+			struct list_head children;
 			struct rcu_head rcu_head;
 			struct kmem_cache *memcg_caches[0];
 		};
@@ -541,6 +543,7 @@ struct memcg_cache_params {
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
+			struct list_head siblings;
 			atomic_t refcount;
 			struct work_struct destroy;
 		};
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5eb629ed28d6..6af3c062dfb1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3114,6 +3114,10 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 			return -ENOMEM;
 
 		new_params->is_root_cache = true;
+		INIT_LIST_HEAD(&new_params->children);
+		if (cur_params)
+			list_splice(&cur_params->children,
+				    &new_params->children);
 
 		/*
 		 * There is the chance it will be bigger than
@@ -3196,8 +3200,10 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 				kmem_cache_destroy_work_func);
 		atomic_set(&s->memcg_params->refcount, 1);
 		css_get(&memcg->css);
-	} else
+	} else {
 		s->memcg_params->is_root_cache = true;
+		INIT_LIST_HEAD(&s->memcg_params->children);
+	}
 
 	return 0;
 }
@@ -3237,6 +3243,8 @@ void memcg_register_cache(struct kmem_cache *s)
 	 */
 	smp_wmb();
 
+	list_add(&s->memcg_params->siblings, &root->memcg_params->children);
+
 	VM_BUG_ON(root->memcg_params->memcg_caches[id]);
 	root->memcg_params->memcg_caches[id] = s;
 
@@ -3264,6 +3272,8 @@ void memcg_unregister_cache(struct kmem_cache *s)
 	memcg = s->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
+	list_del(&s->memcg_params->siblings);
+
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_del(&s->memcg_params->list);
 	mutex_unlock(&memcg->slab_caches_mutex);
@@ -3326,10 +3336,9 @@ static void kmem_cache_destroy_work_func(struct work_struct *w)
 	kmem_cache_destroy_memcg(cachep, false);
 }
 
-int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
+void kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 {
-	struct kmem_cache *c;
-	int i, failed = 0;
+	struct memcg_cache_params *params, *tmp;
 
 	/*
 	 * Since the cache is being destroyed, it shouldn't be allocated from
@@ -3341,9 +3350,9 @@ int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	flush_workqueue(memcg_cache_create_wq);
 
 	/*
-	 * If the cache is being destroyed, we trust that there is no one else
-	 * requesting objects from it. Even if there are, the sanity checks in
-	 * kmem_cache_destroy should caught this ill-case.
+	 * At this point nobody except us is allowed to create or destroy child
+	 * caches so we don't need to take the slab_mutex for iterating over
+	 * the children list.
 	 *
 	 * Still, we don't want anyone else freeing memcg_caches under our
 	 * noses, which can happen if a new memcg comes to life. As usual,
@@ -3351,17 +3360,10 @@ int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 	 * this.
 	 */
 	mutex_lock(&activate_kmem_mutex);
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(s, i);
-		if (!c)
-			continue;
-
-		kmem_cache_destroy_memcg(c, true);
-		if (cache_from_memcg_idx(s, i))
-			failed++;
-	}
+	list_for_each_entry_safe(params, tmp,
+			&s->memcg_params->children, siblings)
+		kmem_cache_destroy_memcg(params->cachep, true);
 	mutex_unlock(&activate_kmem_mutex);
-	return failed;
 }
 
 static void mem_cgroup_destroy_all_caches(struct mem_cgroup *memcg)
diff --git a/mm/slab.c b/mm/slab.c
index 9b8950cb64dd..eae95847cdef 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3816,29 +3816,35 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	return alloc_kmemlist(cachep, gfp);
 }
 
+static void __do_tune_cpucache_memcg(struct kmem_cache *cachep, int limit,
+				     int batchcount, int shared, gfp_t gfp)
+{
+#ifdef CONFIG_MEMCG_KMEM
+	struct memcg_cache_params *params;
+
+	if (!cachep->memcg_params ||
+	    !cachep->memcg_params->is_root_cache)
+		return;
+
+	lockdep_assert_held(&slab_mutex);
+	list_for_each_entry(params,
+			&cachep->memcg_params->children, siblings)
+		__do_tune_cpucache(params->cachep, limit,
+				   batchcount, shared, gfp);
+#endif
+}
+
 static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 				int batchcount, int shared, gfp_t gfp)
 {
 	int ret;
-	struct kmem_cache *c = NULL;
-	int i = 0;
 
 	ret = __do_tune_cpucache(cachep, limit, batchcount, shared, gfp);
-
-	if (slab_state < FULL)
-		return ret;
-
-	if ((ret < 0) || !is_root_cache(cachep))
-		return ret;
-
-	VM_BUG_ON(!mutex_is_locked(&slab_mutex));
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(cachep, i);
-		if (c)
-			/* return value determined by the parent cache only */
-			__do_tune_cpucache(c, limit, batchcount, shared, gfp);
+	if (!ret) {
+		/* return value determined by the parent cache only */
+		__do_tune_cpucache_memcg(cachep, limit,
+					 batchcount, shared, gfp);
 	}
-
 	return ret;
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 05ba3cd1b507..48e472894511 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -335,7 +335,8 @@ static int __kmem_cache_shutdown_memcg(struct kmem_cache *s,
 
 	mutex_unlock(&slab_mutex);
 	if (s->memcg_params->is_root_cache) {
-		rc = kmem_cache_destroy_memcg_children(s);
+		kmem_cache_destroy_memcg_children(s);
+		rc = !list_empty(&s->memcg_params->children);
 	} else {
 		/*
 		 * There might be a destruction work pending, which needs to be
@@ -693,20 +694,17 @@ void slab_stop(struct seq_file *m, void *p)
 static void
 memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 {
-	struct kmem_cache *c;
+#ifdef CONFIG_MEMCG_KMEM
+	struct memcg_cache_params *params;
 	struct slabinfo sinfo;
-	int i;
 
-	if (!is_root_cache(s))
+	if (!s->memcg_params ||
+	    !s->memcg_params->is_root_cache)
 		return;
 
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(s, i);
-		if (!c)
-			continue;
-
+	list_for_each_entry(params, &s->memcg_params->children, siblings) {
 		memset(&sinfo, 0, sizeof(sinfo));
-		get_slabinfo(c, &sinfo);
+		get_slabinfo(params->cachep, &sinfo);
 
 		info->active_slabs += sinfo.active_slabs;
 		info->num_slabs += sinfo.num_slabs;
@@ -714,6 +712,7 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 		info->active_objs += sinfo.active_objs;
 		info->num_objs += sinfo.num_objs;
 	}
+#endif
 }
 
 int cache_show(struct kmem_cache *s, struct seq_file *m)
diff --git a/mm/slub.c b/mm/slub.c
index 4a10126fec3a..52864a6cb681 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3740,6 +3740,25 @@ static struct kmem_cache *find_mergeable(size_t size, size_t align,
 	return NULL;
 }
 
+static void memcg_slab_merge(struct kmem_cache *s, size_t size)
+{
+#ifdef CONFIG_MEMCG_KMEM
+	struct kmem_cache *cachep;
+	struct memcg_cache_params *params;
+
+	if (!s->memcg_params)
+		return;
+	BUG_ON(!s->memcg_params->is_root_cache);
+
+	list_for_each_entry(params, &s->memcg_params->children, siblings) {
+		cachep = params->cachep;
+		cachep->object_size = s->object_size;
+		cachep->inuse = max_t(int, cachep->inuse,
+				      ALIGN(size, sizeof(void *)));
+	}
+#endif
+}
+
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
 		   unsigned long flags, void (*ctor)(void *))
@@ -3748,9 +3767,6 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
-		int i;
-		struct kmem_cache *c;
-
 		s->refcount++;
 
 		/*
@@ -3760,14 +3776,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 		s->object_size = max(s->object_size, (int)size);
 		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
 
-		for_each_memcg_cache_index(i) {
-			c = cache_from_memcg_idx(s, i);
-			if (!c)
-				continue;
-			c->object_size = s->object_size;
-			c->inuse = max_t(int, c->inuse,
-					 ALIGN(size, sizeof(void *)));
-		}
+		memcg_slab_merge(s, size);
 
 		if (sysfs_slab_alias(s, name)) {
 			s->refcount--;
@@ -5027,7 +5036,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 	err = attribute->store(s, buf, len);
 #ifdef CONFIG_MEMCG_KMEM
 	if (slab_state >= FULL && err >= 0 && is_root_cache(s)) {
-		int i;
+		struct memcg_cache_params *params;
 
 		mutex_lock(&slab_mutex);
 		if (s->max_attr_size < len)
@@ -5050,10 +5059,10 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 		 * directly either failed or succeeded, in which case we loop
 		 * through the descendants with best-effort propagation.
 		 */
-		for_each_memcg_cache_index(i) {
-			struct kmem_cache *c = cache_from_memcg_idx(s, i);
-			if (c)
-				attribute->store(c, buf, len);
+		if (s->memcg_params) {
+			list_for_each_entry(params,
+					&s->memcg_params->children, siblings)
+				attribute->store(params->cachep, buf, len);
 		}
 		mutex_unlock(&slab_mutex);
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
