Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 893966B0039
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 10:54:47 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id mc6so5550032lab.14
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 07:54:46 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id m9si10651307laf.88.2014.02.03.07.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Feb 2014 07:54:45 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v2 3/7] memcg, slab: separate memcg vs root cache creation paths
Date: Mon, 3 Feb 2014 19:54:38 +0400
Message-ID: <81a403327163facea2b4c7b720fdc0ef62dd1dbf.1391441746.git.vdavydov@parallels.com>
In-Reply-To: <cover.1391441746.git.vdavydov@parallels.com>
References: <cover.1391441746.git.vdavydov@parallels.com>
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
 include/linux/memcontrol.h |   14 ++---
 include/linux/slab.h       |    9 ++-
 mm/memcontrol.c            |   16 ++----
 mm/slab_common.c           |  130 ++++++++++++++++++++++++++------------------
 4 files changed, 90 insertions(+), 79 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 84e4801fc36c..de79a9617e09 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -500,8 +500,8 @@ int memcg_cache_id(struct mem_cgroup *memcg);
 
 char *memcg_create_cache_name(struct mem_cgroup *memcg,
 			      struct kmem_cache *root_cache);
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache);
+int memcg_alloc_cache_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache);
 void memcg_free_cache_params(struct kmem_cache *s);
 void memcg_register_cache(struct kmem_cache *s);
 void memcg_unregister_cache(struct kmem_cache *s);
@@ -644,14 +644,8 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
-static inline char *memcg_create_cache_name(struct mem_cgroup *memcg,
-					    struct kmem_cache *root_cache)
-{
-	return NULL;
-}
-
-static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
-		struct kmem_cache *s, struct kmem_cache *root_cache)
+static inline int memcg_alloc_cache_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	return 0;
 }
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9260abdd67df..e8c95d0bb879 100644
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
index 9e321650efb2..b94d9917707c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3224,8 +3224,8 @@ char *memcg_create_cache_name(struct mem_cgroup *memcg,
 	return name;
 }
 
-int memcg_alloc_cache_params(struct mem_cgroup *memcg, struct kmem_cache *s,
-			     struct kmem_cache *root_cache)
+int memcg_alloc_cache_params(struct kmem_cache *s,
+		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	size_t size;
 
@@ -3500,15 +3500,9 @@ struct create_work {
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
index 11857abf7057..3314fb3ead7f 100644
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
@@ -215,14 +191,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	s->align = calculate_alignment(flags, align, size);
 	s->ctor = ctor;
 
-	if (memcg)
-		s->name = memcg_create_cache_name(memcg, parent_cache);
-	else
-		s->name = kstrdup(name, GFP_KERNEL);
+	s->name = kstrdup(name, GFP_KERNEL);
 	if (!s->name)
 		goto out_free_cache;
 
-	err = memcg_alloc_cache_params(memcg, s, parent_cache);
+	err = memcg_alloc_cache_params(s, NULL, NULL);
 	if (err)
 		goto out_free_cache;
 
@@ -239,16 +212,6 @@ out_unlock:
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
@@ -267,14 +230,75 @@ out_free_cache:
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
+	s->name = memcg_create_cache_name(memcg, cachep);
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
