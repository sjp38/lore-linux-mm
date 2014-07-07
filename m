Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB616B004D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:30 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id s7so2781123lbd.18
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:29 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 6si68682003lbk.3.2014.07.07.05.00.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:28 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 2/8] memcg: keep all children of each root cache on a list
Date: Mon, 7 Jul 2014 16:00:07 +0400
Message-ID: <e58c0491eebc594f6e80a91dc0ed6905d65050bd.1404733720.git.vdavydov@parallels.com>
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Sometimes we need to iterate over all child caches of a particular root
cache, e.g. when we are destroying it. Currently each root cache keeps
pointers to its children in its memcg_cache_params::memcg_caches_array
so that we can enumerate all active kmemcg ids dereferencing appropriate
array slots to get a memcg. However, this is going to change when memcg
cache reparenting is introduced - only active (not dead) caches will
reside in this array. So let's organize all child caches of the same
root cache into a list on memcg_cache_params.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    7 ++++++-
 mm/memcontrol.c            |   27 ++++++++++++---------------
 mm/slab.c                  |   40 +++++++++++++++++++++++-----------------
 mm/slab_common.c           |   30 +++++++++++++++++-------------
 mm/slub.c                  |   39 +++++++++++++++++++++++----------------
 6 files changed, 82 insertions(+), 63 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 806b8fa15c5f..5b0fbba00b01 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -461,7 +461,7 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 
-int __memcg_cleanup_cache_params(struct kmem_cache *s);
+void __memcg_cleanup_cache_params(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 8bc62d5ef903..640e6a655d51 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -527,6 +527,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  * @memcg: pointer to the memcg this cache belongs to
  * @list: list_head for the list of all caches in this memcg
  * @root_cache: pointer to the global, root cache, this cache was derived from
+ * @siblings: list_head for the list of all child caches of the root_cache
  * @refcnt: reference counter
  * @dead: set to true when owner memcg is turned offline
  * @unregister_work: worker to destroy the cache
@@ -535,12 +536,16 @@ struct memcg_cache_params {
 	bool is_root_cache;
 	struct rcu_head rcu_head;
 	union {
-		struct kmem_cache *memcg_caches[0];
+		struct {
+			struct list_head children;
+			struct kmem_cache *memcg_caches[0];
+		};
 		struct {
 			struct kmem_cache *cachep;
 			struct mem_cgroup *memcg;
 			struct list_head list;
 			struct kmem_cache *root_cache;
+			struct list_head siblings;
 			atomic_long_t refcnt;
 			bool dead;
 			struct work_struct unregister_work;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 98b43a8125b9..4dedb67787c7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2915,6 +2915,10 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 			return -ENOMEM;
 
 		new_params->is_root_cache = true;
+		INIT_LIST_HEAD(&new_params->children);
+		if (cur_params)
+			list_replace(&cur_params->children,
+				     &new_params->children);
 
 		/*
 		 * There is the chance it will be bigger than
@@ -2976,8 +2980,10 @@ int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
 		INIT_WORK(&s->memcg_params->unregister_work,
 			  memcg_unregister_cache_func);
 		css_get(&memcg->css);
-	} else
+	} else {
 		s->memcg_params->is_root_cache = true;
+		INIT_LIST_HEAD(&s->memcg_params->children);
+	}
 
 	return 0;
 }
@@ -3105,24 +3111,15 @@ static inline void memcg_resume_kmem_account(void)
 	current->memcg_kmem_skip_account--;
 }
 
-int __memcg_cleanup_cache_params(struct kmem_cache *s)
+void __memcg_cleanup_cache_params(struct kmem_cache *s)
 {
-	struct kmem_cache *c;
-	int i, failed = 0;
+	struct memcg_cache_params *params, *tmp;
 
 	mutex_lock(&memcg_slab_mutex);
-	for_each_memcg_cache_index(i) {
-		c = cache_from_memcg_idx(s, i);
-		if (!c)
-			continue;
-
-		memcg_unregister_cache(c);
-
-		if (cache_from_memcg_idx(s, i))
-			failed++;
-	}
+	list_for_each_entry_safe(params, tmp,
+			&s->memcg_params->children, siblings)
+		memcg_unregister_cache(params->cachep);
 	mutex_unlock(&memcg_slab_mutex);
-	return failed;
 }
 
 static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
diff --git a/mm/slab.c b/mm/slab.c
index e7763dba3570..159bddfabaee 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3821,29 +3821,35 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	return alloc_kmem_cache_node(cachep, gfp);
 }
 
+static void memcg_do_tune_cpucache(struct kmem_cache *cachep, int limit,
+				   int batchcount, int shared, gfp_t gfp)
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
+			&cachep->memcg_params->children, siblings) {
+		/* return value determined by the parent cache only */
+		__do_tune_cpucache(params->cachep, limit,
+				   batchcount, shared, gfp);
+	}
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
-	}
-
+	if (!ret)
+		memcg_do_tune_cpucache(cachep, limit,
+				       batchcount, shared, gfp);
 	return ret;
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d31c4bacc6a2..95a8f772b0d1 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -294,8 +294,12 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	if (IS_ERR(s)) {
 		kfree(cache_name);
 		s = NULL;
+		goto out_unlock;
 	}
 
+	list_add(&s->memcg_params->siblings,
+		 &root_cache->memcg_params->children);
+
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
@@ -307,17 +311,15 @@ out_unlock:
 
 static int memcg_cleanup_cache_params(struct kmem_cache *s)
 {
-	int rc;
-
 	if (!s->memcg_params ||
 	    !s->memcg_params->is_root_cache)
 		return 0;
 
 	mutex_unlock(&slab_mutex);
-	rc = __memcg_cleanup_cache_params(s);
+	__memcg_cleanup_cache_params(s);
 	mutex_lock(&slab_mutex);
 
-	return rc;
+	return !list_empty(&s->memcg_params->children);
 }
 #else
 static int memcg_cleanup_cache_params(struct kmem_cache *s)
@@ -354,6 +356,10 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	}
 
 	list_del(&s->list);
+#ifdef CONFIG_MEMCG_KMEM
+	if (!is_root_cache(s))
+		list_del(&s->memcg_params->siblings);
+#endif
 
 	mutex_unlock(&slab_mutex);
 	if (s->flags & SLAB_DESTROY_BY_RCU)
@@ -692,20 +698,17 @@ void slab_stop(struct seq_file *m, void *p)
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
@@ -713,6 +716,7 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 		info->active_objs += sinfo.active_objs;
 		info->num_objs += sinfo.num_objs;
 	}
+#endif
 }
 
 int cache_show(struct kmem_cache *s, struct seq_file *m)
diff --git a/mm/slub.c b/mm/slub.c
index 6641a8fc63d1..1821e2096cbb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3706,6 +3706,23 @@ static struct kmem_cache *find_mergeable(size_t size, size_t align,
 	return NULL;
 }
 
+static void memcg_slab_merge(struct kmem_cache *s, size_t size)
+{
+#ifdef CONFIG_MEMCG_KMEM
+	struct kmem_cache *c;
+	struct memcg_cache_params *params;
+
+	if (!s->memcg_params)
+		return;
+
+	list_for_each_entry(params, &s->memcg_params->children, siblings) {
+		c = params->cachep;
+		c->object_size = s->object_size;
+		c->inuse = max_t(int, c->inuse, ALIGN(size, sizeof(void *)));
+	}
+#endif
+}
+
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
 		   unsigned long flags, void (*ctor)(void *))
@@ -3714,9 +3731,6 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
-		int i;
-		struct kmem_cache *c;
-
 		s->refcount++;
 
 		/*
@@ -3726,14 +3740,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
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
@@ -4984,7 +4991,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 	err = attribute->store(s, buf, len);
 #ifdef CONFIG_MEMCG_KMEM
 	if (slab_state >= FULL && err >= 0 && is_root_cache(s)) {
-		int i;
+		struct memcg_cache_params *params;
 
 		mutex_lock(&slab_mutex);
 		if (s->max_attr_size < len)
@@ -5007,10 +5014,10 @@ static ssize_t slab_attr_store(struct kobject *kobj,
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
