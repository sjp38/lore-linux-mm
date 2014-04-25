Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 507956B0037
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 08:33:23 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id u14so64832lbd.30
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 05:33:22 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id tv3si3467660lbb.154.2014.04.25.05.33.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Apr 2014 05:33:21 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/6] memcg: get rid of memcg_{alloc,free}_cache_params
Date: Fri, 25 Apr 2014 16:33:10 +0400
Message-ID: <4ef630979f916f8b066045c4d4034f0f35f778ee.1398428532.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398428532.git.vdavydov@parallels.com>
References: <cover.1398428532.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Let's inline them to memcg_kmem_{create,destroy}_cache to keep the
interface between slab_common.c and memcontrol.c clean.

Note, to properly bail out in memcg_kmem_destroy_cache, I need to know
if the cache was actually destroyed (it won't if it has leaked objects).
That's why I add the return value to kmem_cache_destroy.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   14 ---------
 include/linux/slab.h       |    7 +++--
 mm/memcontrol.c            |   74 +++++++++++++++++++++++---------------------
 mm/slab_common.c           |   41 +++++++++++++++---------
 4 files changed, 69 insertions(+), 67 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6e59393e03f9..3aee79fc7876 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -492,10 +492,6 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
 
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache);
-void memcg_free_cache_params(struct kmem_cache *s);
-
 struct kmem_cache *
 __memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp);
 
@@ -623,16 +619,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
-static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
-		struct kmem_cache *s, struct kmem_cache *root_cache)
-{
-	return 0;
-}
-
-static inline void memcg_free_cache_params(struct kmem_cache *s)
-{
-}
-
 static inline struct kmem_cache *
 memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
diff --git a/include/linux/slab.h b/include/linux/slab.h
index c08c9667a1e8..22cc9cab4279 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -106,6 +106,8 @@
 #include <linux/kmemleak.h>
 
 struct mem_cgroup;
+struct memcg_cache_params;
+
 /*
  * struct kmem_cache related prototypes
  */
@@ -116,13 +118,12 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
-struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
-					   struct kmem_cache *,
+struct kmem_cache *kmem_cache_create_memcg(struct memcg_cache_params *,
 					   const char *);
 int kmem_cache_init_memcg_array(struct kmem_cache *, int);
 int kmem_cache_grow_memcg_arrays(int);
 #endif
-void kmem_cache_destroy(struct kmem_cache *);
+int kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 844258bf0968..b6ddbe8b4364 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3075,31 +3075,6 @@ out_rmid:
 	return err;
 }
 
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache)
-{
-	if (!memcg)
-		return 0;
-
-	s->memcg_params = kzalloc(sizeof(*s->memcg_params), GFP_KERNEL);
-	if (!s->memcg_params)
-		return -ENOMEM;
-
-	s->memcg_params->memcg = memcg;
-	s->memcg_params->root_cache = root_cache;
-	css_get(&memcg->css);
-
-	return 0;
-}
-
-void memcg_free_cache_params(struct kmem_cache *s)
-{
-	if (is_root_cache(s))
-		return;
-	css_put(&s->memcg_params->memcg->css);
-	kfree(s->memcg_params);
-}
-
 /*
  * Prepares the memcg_caches array of the given kmem cache for disposing
  * memcgs' copies.
@@ -3128,6 +3103,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 				    struct kmem_cache *root_cache)
 {
 	static char memcg_name[NAME_MAX + 1];
+	struct memcg_cache_params *params;
 	struct kmem_cache *cachep;
 	int id;
 
@@ -3143,16 +3119,26 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	if (cache_from_memcg_idx(root_cache, id))
 		return;
 
+	params = kzalloc(sizeof(*params), GFP_KERNEL);
+	if (!params)
+		return;
+
+	params->memcg = memcg;
+	params->root_cache = root_cache;
+
 	cgroup_name(memcg->css.cgroup, memcg_name, NAME_MAX + 1);
-	cachep = kmem_cache_create_memcg(memcg, root_cache, memcg_name);
+	cachep = kmem_cache_create_memcg(params, memcg_name);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
 	 * cache.
 	 */
-	if (!cachep)
+	if (!cachep) {
+		kfree(params);
 		return;
+	}
 
+	css_get(&memcg->css);
 	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
@@ -3166,26 +3152,46 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	root_cache->memcg_params->memcg_caches[id] = cachep;
 }
 
-static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+static int memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
+	struct memcg_cache_params *params;
 	int id;
 
 	lockdep_assert_held(&memcg_slab_mutex);
 
 	BUG_ON(is_root_cache(cachep));
 
-	root_cache = cachep->memcg_params->root_cache;
-	memcg = cachep->memcg_params->memcg;
+	params = cachep->memcg_params;
+	root_cache = params->root_cache;
+	memcg = params->memcg;
 	id = memcg_cache_id(memcg);
 
+	/*
+	 * Since memcg_caches arrays can be accessed using only slab_mutex for
+	 * protection (e.g. by slabinfo readers), we must clear the cache's
+	 * entry before trying to destroy it.
+	 */
 	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
 	root_cache->memcg_params->memcg_caches[id] = NULL;
 
-	list_del(&cachep->memcg_params->list);
+	if (kmem_cache_destroy(cachep) != 0) {
+		root_cache->memcg_params->memcg_caches[id] = cachep;
+		return -EBUSY;
+	}
+
+	/*
+	 * We delete the cache's memcg params from the memcg's slab caches list
+	 * after the cache was destroyed, but that's OK, because the list can
+	 * only be accessed under memcg_slab_mutex, which is held during the
+	 * whole operation.
+	 */
+	list_del(&params->list);
+	css_put(&memcg->css);
+	kfree(params);
 
-	kmem_cache_destroy(cachep);
+	return 0;
 }
 
 /*
@@ -3230,9 +3236,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 		if (!c)
 			continue;
 
-		memcg_kmem_destroy_cache(c);
-
-		if (cache_from_memcg_idx(s, i))
+		if (memcg_kmem_destroy_cache(c) != 0)
 			failed++;
 	}
 	mutex_unlock(&memcg_slab_mutex);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a98922acfdc6..cb4e2293ec46 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -179,7 +179,7 @@ unsigned long calculate_alignment(unsigned long flags,
 static struct kmem_cache *
 do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
 		     unsigned long flags, void (*ctor)(void *),
-		     struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+		     struct memcg_cache_params *memcg_params)
 {
 	struct kmem_cache *s;
 	int err;
@@ -194,10 +194,9 @@ do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
 	s->size = size;
 	s->align = align;
 	s->ctor = ctor;
-
-	err = memcg_alloc_cache_params(memcg, s, root_cache);
-	if (err)
-		goto out_free_cache;
+#ifdef CONFIG_MEMCG_KMEM
+	s->memcg_params = memcg_params;
+#endif
 
 	err = __kmem_cache_create(s, flags);
 	if (err)
@@ -211,7 +210,6 @@ out:
 	return s;
 
 out_free_cache:
-	memcg_free_cache_params(s);
 	kfree(s);
 	goto out;
 }
@@ -277,7 +275,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	s = do_kmem_cache_create(cache_name, size, size,
 				 calculate_alignment(flags, align, size),
-				 flags, ctor, NULL, NULL);
+				 flags, ctor, NULL);
 	if (IS_ERR(s)) {
 		err = PTR_ERR(s);
 		kfree(cache_name);
@@ -307,18 +305,19 @@ EXPORT_SYMBOL(kmem_cache_create);
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * kmem_cache_create_memcg - Create a cache for a memory cgroup.
- * @memcg: The memory cgroup the new cache is for.
- * @root_cache: The parent of the new cache.
+ * @memcg_params: The memcg params to initialize the cache with.
  * @memcg_name: The name of the memory cgroup.
  *
  * This function attempts to create a kmem cache that will serve allocation
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
-struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
-					   struct kmem_cache *root_cache,
-					   const char *memcg_name)
+struct kmem_cache *
+kmem_cache_create_memcg(struct memcg_cache_params *memcg_params,
+			const char *memcg_name)
 {
+	struct mem_cgroup *memcg = memcg_params->memcg;
+	struct kmem_cache *root_cache = memcg_params->root_cache;
 	struct kmem_cache *s = NULL;
 	char *cache_name;
 
@@ -335,7 +334,7 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
 	s = do_kmem_cache_create(cache_name, root_cache->object_size,
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
-				 memcg, root_cache);
+				 memcg_params);
 	if (IS_ERR(s)) {
 		kfree(cache_name);
 		s = NULL;
@@ -373,8 +372,17 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
-void kmem_cache_destroy(struct kmem_cache *s)
+/*
+ * kmem_cache_destroy - Destroy a cache.
+ * @s: The cache to destroy.
+ *
+ * Returns 0 on success. If the cache still has objects, -EBUSY is returned and
+ * a warning is printed to the log.
+ */
+int kmem_cache_destroy(struct kmem_cache *s)
 {
+	int ret = 0;
+
 	get_online_cpus();
 	get_online_mems();
 
@@ -384,6 +392,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
+	ret = -EBUSY;
 	if (kmem_cache_destroy_memcg_children(s) != 0)
 		goto out_unlock;
 
@@ -400,9 +409,9 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->flags & SLAB_DESTROY_BY_RCU)
 		rcu_barrier();
 
-	memcg_free_cache_params(s);
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
+	ret = 0;
 	goto out;
 
 out_unlock:
@@ -410,6 +419,8 @@ out_unlock:
 out:
 	put_online_mems();
 	put_online_cpus();
+
+	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
