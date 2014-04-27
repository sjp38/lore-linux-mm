Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id D3C8B6B0062
	for <linux-mm@kvack.org>; Sun, 27 Apr 2014 05:04:18 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id ec20so3861236lab.22
        for <linux-mm@kvack.org>; Sun, 27 Apr 2014 02:04:18 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id tv3si6095947lbb.7.2014.04.27.02.04.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Apr 2014 02:04:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 4/6] memcg: get rid of memcg_{alloc,free}_cache_params
Date: Sun, 27 Apr 2014 13:04:06 +0400
Message-ID: <a638f4f6e13fd4e1e38531daa1bda8513bd671c3.1398587474.git.vdavydov@parallels.com>
In-Reply-To: <cover.1398587474.git.vdavydov@parallels.com>
References: <cover.1398587474.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

The only reason why we have special functions for initializing
memcg_cache_params, memcg_{alloc,free}_cache_params defined at
memcontrol.c, is that we can't do css_{get,put} in slab_common.c.
However, we can move css_{get,put} to memcg_kmem_{create,destroy}_cache,
becuase they are only called when creating/destroying per memcg caches.
Then the rest of memcg_{alloc,free}_cache_params can be inlined in
slab_common.c making the code clearer.

Note, to properly bail out in memcg_kmem_destroy_cache, I need to know
if the cache was actually destroyed (it won't if it has leaked objects).
That's why I add the return value to kmem_cache_destroy.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |   14 ------------
 include/linux/slab.h       |    2 +-
 mm/memcontrol.c            |   48 +++++++++++++++--------------------------
 mm/slab_common.c           |   51 ++++++++++++++++++++++++++++++++------------
 4 files changed, 55 insertions(+), 60 deletions(-)

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
index c437be67917b..d041539b2bfb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -122,7 +122,7 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *,
 int kmem_cache_init_memcg_array(struct kmem_cache *, int);
 int kmem_cache_memcg_arrays_grow(int);
 #endif
-void kmem_cache_destroy(struct kmem_cache *);
+int kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 714d7bd7f140..415c81c2710a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3075,32 +3075,6 @@ out_rmid:
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
-	if (!s->memcg_params)
-		return;
-	if (!s->memcg_params->is_root_cache)
-		css_put(&s->memcg_params->memcg->css);
-	kfree(s->memcg_params);
-}
-
 /*
  * Prepares the memcg_caches array of the given kmem cache for disposing
  * memcgs' copies.
@@ -3154,6 +3128,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	if (!cachep)
 		return;
 
+	css_get(&memcg->css);
 	list_add(&cachep->memcg_params->list, &memcg->memcg_slab_caches);
 
 	/*
@@ -3167,7 +3142,7 @@ static void memcg_kmem_create_cache(struct mem_cgroup *memcg,
 	root_cache->memcg_params->memcg_caches[id] = cachep;
 }
 
-static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
+static int memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
 	struct mem_cgroup *memcg;
@@ -3181,12 +3156,25 @@ static void memcg_kmem_destroy_cache(struct kmem_cache *cachep)
 	memcg = cachep->memcg_params->memcg;
 	id = memcg_cache_id(memcg);
 
+	/*
+	 * Since memcg_caches arrays can be accessed using only slab_mutex for
+	 * protection (e.g. by slabinfo readers), we must clear the cache's
+	 * entry before trying to destroy it.
+	 */
 	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
 	root_cache->memcg_params->memcg_caches[id] = NULL;
 
 	list_del(&cachep->memcg_params->list);
 
-	kmem_cache_destroy(cachep);
+	if (kmem_cache_destroy(cachep) != 0) {
+		root_cache->memcg_params->memcg_caches[id] = cachep;
+		list_add(&cachep->memcg_params->list,
+			 &memcg->memcg_slab_caches);
+		return -EBUSY;
+	}
+
+	css_put(&memcg->css);
+	return 0;
 }
 
 /*
@@ -3231,9 +3219,7 @@ int __kmem_cache_destroy_memcg_children(struct kmem_cache *s)
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
index 801999247619..055506ba6d37 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -177,7 +177,7 @@ unsigned long calculate_alignment(unsigned long flags,
 static struct kmem_cache *
 do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
 		     unsigned long flags, void (*ctor)(void *),
-		     struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+		     struct memcg_cache_params *memcg_params)
 {
 	struct kmem_cache *s;
 	int err;
@@ -192,10 +192,9 @@ do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
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
@@ -209,7 +208,6 @@ out:
 	return s;
 
 out_free_cache:
-	memcg_free_cache_params(s);
 	kfree(s);
 	goto out;
 }
@@ -275,7 +273,7 @@ kmem_cache_create(const char *name, size_t size, size_t align,
 
 	s = do_kmem_cache_create(cache_name, size, size,
 				 calculate_alignment(flags, align, size),
-				 flags, ctor, NULL, NULL);
+				 flags, ctor, NULL);
 	if (IS_ERR(s)) {
 		err = PTR_ERR(s);
 		kfree(cache_name);
@@ -318,13 +316,21 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
 					   const char *memcg_name)
 {
 	struct kmem_cache *s = NULL;
-	char *cache_name;
+	char *cache_name = NULL;
+	struct memcg_cache_params *memcg_params = NULL;
 
 	get_online_cpus();
 	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
+	memcg_params = kzalloc(sizeof(*memcg_params), GFP_KERNEL);
+	if (!memcg_params)
+		goto out_unlock;
+
+	memcg_params->memcg = memcg;
+	memcg_params->root_cache = root_cache;
+
 	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
 			       memcg_cache_id(memcg), memcg_name);
 	if (!cache_name)
@@ -333,11 +339,9 @@ struct kmem_cache *kmem_cache_create_memcg(struct mem_cgroup *memcg,
 	s = do_kmem_cache_create(cache_name, root_cache->object_size,
 				 root_cache->size, root_cache->align,
 				 root_cache->flags, root_cache->ctor,
-				 memcg, root_cache);
-	if (IS_ERR(s)) {
-		kfree(cache_name);
+				 memcg_params);
+	if (IS_ERR(s))
 		s = NULL;
-	}
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
@@ -345,6 +349,10 @@ out_unlock:
 	put_online_mems();
 	put_online_cpus();
 
+	if (!s) {
+		kfree(memcg_params);
+		kfree(cache_name);
+	}
 	return s;
 }
 
@@ -369,8 +377,17 @@ static int kmem_cache_destroy_memcg_children(struct kmem_cache *s)
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
 
@@ -380,6 +397,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->refcount)
 		goto out_unlock;
 
+	ret = -EBUSY;
 	if (kmem_cache_destroy_memcg_children(s) != 0)
 		goto out_unlock;
 
@@ -396,9 +414,12 @@ void kmem_cache_destroy(struct kmem_cache *s)
 	if (s->flags & SLAB_DESTROY_BY_RCU)
 		rcu_barrier();
 
-	memcg_free_cache_params(s);
+#ifdef CONFIG_MEMCG_KMEM
+	kfree(s->memcg_params);
+#endif
 	kfree(s->name);
 	kmem_cache_free(kmem_cache, s);
+	ret = 0;
 	goto out;
 
 out_unlock:
@@ -406,6 +427,8 @@ out_unlock:
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
