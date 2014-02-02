Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7B76B0036
	for <linux-mm@kvack.org>; Sun,  2 Feb 2014 11:33:59 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id b8so4696368lan.5
        for <linux-mm@kvack.org>; Sun, 02 Feb 2014 08:33:59 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id b8si8927395lah.98.2014.02.02.08.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Feb 2014 08:33:57 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 4/8] memcg, slab: separate memcg vs root cache creation paths
Date: Sun, 2 Feb 2014 20:33:49 +0400
Message-ID: <160d882d1582475ce6303253b7b3e56553423d9c.1391356789.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391356789.git.vdavydov@parallels.com>
References: <cover.1391356789.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Memcg-awareness turned kmem_cache_create() into a dirty interweaving of
memcg-only and except-for-memcg calls. To clean this up, let's create a
separate function handling memcg caches creation. Although this will
result in the two functions having several hunks of practically the same
code, I guess this is the case when readability fully covers the cost of
code duplication.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    8 +--
 include/linux/slab.h       |    9 ++-
 mm/memcontrol.c            |   16 ++----
 mm/slab_common.c           |  133 ++++++++++++++++++++++++++------------------
 4 files changed, 92 insertions(+), 74 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index abd0113b6620..87b8c614798f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -497,8 +497,8 @@ void __memcg_kmem_commit_charge(struct page *page,
 void __memcg_kmem_uncharge_pages(struct page *page, int order);
 
 int memcg_cache_id(struct mem_cgroup *memcg);
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache);
+int memcg_alloc_cache_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
 void memcg_register_cache(struct kmem_cache *s);
 void memcg_unregister_cache(struct kmem_cache *s);
@@ -641,8 +641,8 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
-static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
-		struct kmem_cache *s, struct kmem_cache *root_cache)
+static inline int memcg_alloc_cache_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	return 0;
 }
diff --git a/include/linux/slab.h b/include/linux/slab.h
index a060142aa5f5..b8a4bad71f57 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -113,11 +113,10 @@ void __init kmem_cache_init(void);
 int slab_is_available(void);
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
-			unsigned long,
-			void (*)(void *));
-struct kmem_cache *
-kmem_cache_create_memcg(struct mem_cgroup *, const char *, size_t, size_t,
-			unsigned long, void (*)(void *), struct kmem_cache *);
+				     unsigned long, void (*)(void *));
+#ifdef CONFIG_MEMCG_KMEM
+int kmem_cache_create_memcg(struct mem_cgroup *, struct kmem_cache *);
+#endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3351c5b5486d..d69c427e106b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3201,8 +3201,8 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
 	return 0;
 }
 
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache)
+int memcg_alloc_cache_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	size_t size;
 
@@ -3477,15 +3477,9 @@ struct create_work {
 static void memcg_create_cache_work_func(struct work_struct *w)
 {
 	struct create_work *cw = container_of(w, struct create_work, work);
-	struct mem_cgroup *memcg = cw->memcg;
-	struct kmem_cache *s = cw->cachep;
-	struct kmem_cache *new;
-
-	new = kmem_cache_create_memcg(memcg, s->name, s->object_size, s->align,
-				      (s->flags & ~SLAB_PANIC), s->ctor, s);
-	if (new)
-		new->allocflags |= __GFP_KMEMCG;
-	css_put(&memcg->css);
+
+	kmem_cache_create_memcg(cw->memcg, cw->cachep);
+	css_put(&cw->memcg->css);
 	kfree(cw);
 }
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index a75834bb966d..ade86bcddab9 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -29,8 +29,7 @@ DEFINE_MUTEX(slab_mutex);
 struct kmem_cache *kmem_cache;
 
 #ifdef CONFIG_DEBUG_VM
-static int kmem_cache_sanity_check(struct mem_cgroup *memcg, const char *name,
-				   size_t size)
+static int kmem_cache_sanity_check(const char *name, size_t size)
 {
 	struct kmem_cache *s = NULL;
 
@@ -57,13 +56,7 @@ static int kmem_cache_sanity_check(struct mem_cgroup *memcg, const char *name,
 		}
 
 #if !defined(CONFIG_SLUB) || !defined(CONFIG_SLUB_DEBUG_ON)
-		/*
-		 * For simplicity, we won't check this in the list of memcg
-		 * caches. We have control over memcg naming, and if there
-		 * aren't duplicates in the global list, there won't be any
-		 * duplicates in the memcg lists as well.
-		 */
-		if (!memcg && !strcmp(s->name, name)) {
+		if (!strcmp(s->name, name)) {
 			pr_err("%s (%s): Cache name already exists.\n",
 			       __func__, name);
 			dump_stack();
@@ -77,8 +70,7 @@ static int kmem_cache_sanity_check(struct mem_cgroup *memcg, const char *name,
 	return 0;
 }
 #else
-static inline int kmem_cache_sanity_check(struct mem_cgroup *memcg,
-					  const char *name, size_t size)
+static inline int kmem_cache_sanity_check(const char *name, size_t size)
 {
 	return 0;
 }
@@ -164,11 +156,9 @@ unsigned long calculate_alignment(unsigned long flags,
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
  */
-
 struct kmem_cache *
-kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
-			size_t align, unsigned long flags, void (*ctor)(void *),
-			struct kmem_cache *parent_cache)
+kmem_cache_create(const char *name, size_t size, size_t align,
+		  unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
 	int err;
@@ -176,22 +166,10 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	get_online_cpus();
 	mutex_lock(&slab_mutex);
 
-	err = kmem_cache_sanity_check(memcg, name, size);
+	err = kmem_cache_sanity_check(name, size);
 	if (err)
 		goto out_unlock;
 
-	if (memcg) {
-		/*
-		 * Since per-memcg caches are created asynchronously on first
-		 * allocation (see memcg_kmem_get_cache()), several threads can
-		 * try to create the same cache, but only one of them may
-		 * succeed. Therefore if we get here and see the cache has
-		 * already been created, we silently return NULL.
-		 */
-		if (cache_from_memcg_idx(parent_cache, memcg_cache_id(memcg)))
-			goto out_unlock;
-	}
-
 	/*
 	 * Some allocators will constraint the set of valid flags to a subset
 	 * of all flags. We expect them to define CACHE_CREATE_MASK in this
@@ -200,11 +178,9 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	 */
 	flags &= CACHE_CREATE_MASK;
 
-	if (!memcg) {
-		s = __kmem_cache_alias(name, size, align, flags, ctor);
-		if (s)
-			goto out_unlock;
-	}
+	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	if (s)
+		goto out_unlock;
 
 	err = -ENOMEM;
 	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
@@ -215,15 +191,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	s->align = calculate_alignment(flags, align, size);
 	s->ctor = ctor;
 
-	if (!memcg)
-		s->name = kstrdup(name, GFP_KERNEL);
-	else
-		s->name = kasprintf(GFP_KERNEL, "%s:%d",
-				    name, memcg_cache_id(memcg));
+	s->name = kstrdup(name, GFP_KERNEL);
 	if (!s->name)
 		goto out_free_cache;
 
-	err = memcg_alloc_cache_params(memcg, s, parent_cache);
+	err = memcg_alloc_cache_params(s, NULL, NULL);
 	if (err)
 		goto out_free_cache;
 
@@ -240,16 +212,6 @@ out_unlock:
 	put_online_cpus();
 
 	if (err) {
-		/*
-		 * There is no point in flooding logs with warnings or
-		 * especially crashing the system if we fail to create a cache
-		 * for a memcg. In this case we will be accounting the memcg
-		 * allocation to the root cgroup until we succeed to create its
-		 * own cache, but it isn't that critical.
-		 */
-		if (!memcg)
-			return NULL;
-
 		if (flags & SLAB_PANIC)
 			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
 				name, err);
@@ -268,14 +230,77 @@ out_free_cache:
 	kmem_cache_free(kmem_cache, s);
 	goto out_unlock;
 }
+EXPORT_SYMBOL(kmem_cache_create);
 
-struct kmem_cache *
-kmem_cache_create(const char *name, size_t size, size_t align,
-		  unsigned long flags, void (*ctor)(void *))
+#ifdef CONFIG_MEMCG_KMEM
+/*
+ * kmem_cache_create_memcg - Create a cache for a memory cgroup.
+ * @memcg: The memory cgroup the new cache is for.
+ * @cachep: The parent of the new cache.
+ *
+ * This function creates a kmem cache that will serve allocation requests going
+ * from @memcg to @cachep. The new cache inherits properties from its parent.
+ *
+ * Returns 0 on success, -errno on failure.
+ */
+int kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *cachep)
 {
-	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor, NULL);
+	struct kmem_cache *s;
+	int err;
+
+	get_online_cpus();
+	mutex_lock(&slab_mutex);
+
+	/*
+	 * Since per-memcg caches are created asynchronously on first
+	 * allocation (see memcg_kmem_get_cache()), several threads can try to
+	 * create the same cache, but only one of them may succeed.
+	 */
+	err = -EEXIST;
+	if (cache_from_memcg_idx(cachep, memcg_cache_id(memcg)))
+		goto out_unlock;
+
+	err = -ENOMEM;
+	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
+	if (!s)
+		goto out_unlock;
+
+	s->object_size = cachep->object_size;
+	s->size = cachep->size;
+	s->align = cachep->align;
+	s->ctor = cachep->ctor;
+
+	s->name = kasprintf(GFP_KERNEL, "%s:%d",
+			    cachep->name, memcg_cache_id(memcg));
+	if (!s->name)
+		goto out_free_cache;
+
+	err = memcg_alloc_cache_params(s, memcg, cachep);
+	if (err)
+		goto out_free_cache;
+
+	err = __kmem_cache_create(s, cachep->flags & ~SLAB_PANIC);
+	if (err)
+		goto out_free_cache;
+
+	s->refcount = 1;
+	s->allocflags |= __GFP_KMEMCG;
+	list_add(&s->list, &slab_caches);
+	memcg_register_cache(s);
+
+out_unlock:
+	mutex_unlock(&slab_mutex);
+	put_online_cpus();
+
+	return err;
+
+out_free_cache:
+	memcg_free_cache_params(s);
+	kfree(s->name);
+	kmem_cache_free(kmem_cache, s);
+	goto out_unlock;
 }
-EXPORT_SYMBOL(kmem_cache_create);
+#endif /* CONFIG_MEMCG_KMEM */
 
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
