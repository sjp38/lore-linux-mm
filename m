Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 264AF6B003C
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:15:33 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id y13so2816929pdi.15
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:15:32 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id rs7si12016767pbc.51.2014.09.21.08.15.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:15:32 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 06/14] memcg: keep all children of each root cache on a list
Date: Sun, 21 Sep 2014 19:14:38 +0400
Message-ID: <845297d2cf1cd35867011a092a4d281f2e98b6e1.1411301245.git.vdavydov@parallels.com>
In-Reply-To: <cover.1411301245.git.vdavydov@parallels.com>
References: <cover.1411301245.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Sometimes we need to iterate over all child caches of a particular root
cache, e.g. when we are destroying it. Currently each root cache keeps
pointers to its children in its memcg_cache_params->memcg_caches_array
so that we can enumerate all active kmemcg ids dereferencing appropriate
array slots to get a memcg.

However, I'm going to make memcg clear the slots on offline to avoid
uncontrollable memcg_caches arrays growth. Hence to iterate over all
memcg caches of a particular root cache we have to link all memcg caches
to per root cache lists.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   13 +------------
 include/linux/slab.h       |    1 +
 mm/memcontrol.c            |   20 ++++++--------------
 mm/slab.c                  |   40 +++++++++++++++++++++++-----------------
 mm/slab.h                  |    6 ------
 mm/slab_common.c           |   37 +++++++++++++++++++++++--------------
 mm/slub.c                  |   41 +++++++++++++++++++++++++----------------
 7 files changed, 79 insertions(+), 79 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c4e64d0e318d..e57a097cf393 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -417,14 +417,6 @@ extern struct static_key memcg_kmem_enabled_key;
 
 extern int memcg_limited_groups_array_size;
 
-/*
- * Helper macro to loop through all memcg-specific caches. Callers must still
- * check if the cache is valid (it is either valid or NULL).
- * the slab_mutex must be held when looping through those caches
- */
-#define for_each_memcg_cache_index(_idx)	\
-	for ((_idx) = 0; (_idx) < memcg_limited_groups_array_size; (_idx)++)
-
 static inline bool memcg_kmem_enabled(void)
 {
 	return static_key_false(&memcg_kmem_enabled_key);
@@ -460,7 +452,7 @@ __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 int __memcg_charge_slab(struct kmem_cache *cachep, gfp_t gfp, int order);
 void __memcg_uncharge_slab(struct kmem_cache *cachep, int order);
 
-int __memcg_cleanup_cache_params(struct kmem_cache *s);
+void __memcg_cleanup_cache_params(struct kmem_cache *s);
 
 /**
  * memcg_kmem_newpage_charge: verify if a new kmem allocation is allowed.
@@ -553,9 +545,6 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return __memcg_kmem_get_cache(cachep, gfp);
 }
 #else
-#define for_each_memcg_cache_index(_idx)	\
-	for (; NULL; )
-
 static inline bool memcg_kmem_enabled(void)
 {
 	return false;
diff --git a/include/linux/slab.h b/include/linux/slab.h
index c61344074c11..22388b4c6b88 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -498,6 +498,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  */
 struct memcg_cache_params {
 	bool is_root_cache;
+	struct list_head memcg_caches_list;
 	union {
 		struct {
 			struct rcu_head rcu_head;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9cb311c199be..412fa220b9aa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3085,24 +3085,16 @@ static inline void memcg_resume_kmem_account(void)
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
+				 &s->memcg_params->memcg_caches_list,
+				 memcg_caches_list)
+		memcg_unregister_cache(params->cachep);
 	mutex_unlock(&memcg_slab_mutex);
-	return failed;
 }
 
 static void memcg_unregister_all_caches(struct mem_cgroup *memcg)
diff --git a/mm/slab.c b/mm/slab.c
index 56116acedacf..be10cad44969 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3769,29 +3769,35 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
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
+	list_for_each_entry(params, &cachep->memcg_params->memcg_caches_list,
+			    memcg_caches_list) {
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
 
diff --git a/mm/slab.h b/mm/slab.h
index 026e7c393f0b..52b570932ba0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -249,12 +249,6 @@ static inline const char *cache_name(struct kmem_cache *s)
 	return s->name;
 }
 
-static inline struct kmem_cache *
-cache_from_memcg_idx(struct kmem_cache *s, int idx)
-{
-	return NULL;
-}
-
 static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 {
 	return s;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index b5c9d90535af..d4add958843c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -106,6 +106,7 @@ static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 	if (!s->memcg_params)
 		return -ENOMEM;
 
+	INIT_LIST_HEAD(&s->memcg_params->memcg_caches_list);
 	if (memcg) {
 		s->memcg_params->cachep = s;
 		s->memcg_params->memcg = memcg;
@@ -140,6 +141,10 @@ static int memcg_update_cache_params(struct kmem_cache *s, int num_memcgs)
 	       memcg_limited_groups_array_size * sizeof(void *));
 
 	new_params->is_root_cache = true;
+	INIT_LIST_HEAD(&new_params->memcg_caches_list);
+	if (cur_params)
+		list_replace(&cur_params->memcg_caches_list,
+			     &new_params->memcg_caches_list);
 
 	rcu_assign_pointer(s->memcg_params, new_params);
 	if (cur_params)
@@ -367,7 +372,10 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
 				 memcg, root_cache);
-	if (IS_ERR(s))
+	if (!IS_ERR(s))
+		list_add(&s->memcg_params->memcg_caches_list,
+			 &root_cache->memcg_params->memcg_caches_list);
+	else
 		s = NULL;
 
 	mutex_unlock(&slab_mutex);
@@ -380,17 +388,15 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
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
+	return !list_empty(&s->memcg_params->memcg_caches_list);
 }
 #else
 static int memcg_cleanup_cache_params(struct kmem_cache *s)
@@ -427,6 +433,10 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	}
 
 	list_del(&s->list);
+#ifdef CONFIG_MEMCG_KMEM
+	if (!is_root_cache(s))
+		list_del(&s->memcg_params->memcg_caches_list);
+#endif
 
 	mutex_unlock(&slab_mutex);
 	if (s->flags & SLAB_DESTROY_BY_RCU)
@@ -765,20 +775,18 @@ void slab_stop(struct seq_file *m, void *p)
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
+	list_for_each_entry(params, &s->memcg_params->memcg_caches_list,
+			    memcg_caches_list) {
 		memset(&sinfo, 0, sizeof(sinfo));
-		get_slabinfo(c, &sinfo);
+		get_slabinfo(params->cachep, &sinfo);
 
 		info->active_slabs += sinfo.active_slabs;
 		info->num_slabs += sinfo.num_slabs;
@@ -786,6 +794,7 @@ memcg_accumulate_slabinfo(struct kmem_cache *s, struct slabinfo *info)
 		info->active_objs += sinfo.active_objs;
 		info->num_objs += sinfo.num_objs;
 	}
+#endif
 }
 
 int cache_show(struct kmem_cache *s, struct seq_file *m)
diff --git a/mm/slub.c b/mm/slub.c
index fa86e5845093..1a1b85c585b3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3688,6 +3688,24 @@ static struct kmem_cache *find_mergeable(size_t size, size_t align,
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
+	list_for_each_entry(params, &s->memcg_params->memcg_caches_list,
+			    memcg_caches_list) {
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
@@ -3696,9 +3714,6 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
-		int i;
-		struct kmem_cache *c;
-
 		s->refcount++;
 
 		/*
@@ -3708,14 +3723,7 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
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
@@ -4977,7 +4985,7 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 	err = attribute->store(s, buf, len);
 #ifdef CONFIG_MEMCG_KMEM
 	if (slab_state >= FULL && err >= 0 && is_root_cache(s)) {
-		int i;
+		struct memcg_cache_params *params;
 
 		mutex_lock(&slab_mutex);
 		if (s->max_attr_size < len)
@@ -5000,10 +5008,11 @@ static ssize_t slab_attr_store(struct kobject *kobj,
 		 * directly either failed or succeeded, in which case we loop
 		 * through the descendants with best-effort propagation.
 		 */
-		for_each_memcg_cache_index(i) {
-			struct kmem_cache *c = cache_from_memcg_idx(s, i);
-			if (c)
-				attribute->store(c, buf, len);
+		if (s->memcg_params) {
+			list_for_each_entry(params,
+					    &s->memcg_params->memcg_caches_list,
+					    memcg_caches_list)
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
