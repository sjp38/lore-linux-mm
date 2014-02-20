Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id D0E036B0072
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 02:22:16 -0500 (EST)
Received: by mail-lb0-f178.google.com with SMTP id u14so1050614lbd.9
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 23:22:16 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id qn8si2900220lbb.63.2014.02.19.23.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 23:22:14 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 3/7] memcg, slab: separate memcg vs root cache creation paths
Date: Thu, 20 Feb 2014 11:22:05 +0400
Message-ID: <5aac3e1a327549c4a67d58af4f9ee193efd64131.1392879001.git.vdavydov@parallels.com>
In-Reply-To: <cover.1392879001.git.vdavydov@parallels.com>
References: <cover.1392879001.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

Memcg-awareness turned kmem_cache_create() into a dirty interweaving of
memcg-only and except-for-memcg calls. To clean this up, let's move
the code responsible for memcg cache creation to a separate function.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    6 --
 include/linux/slab.h       |    6 +-
 mm/memcontrol.c            |    7 +-
 mm/slab_common.c           |  187 +++++++++++++++++++++++++-------------------
 4 files changed, 111 insertions(+), 95 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 4d6b481d11db..01a506a9e57b 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -644,12 +644,6 @@ static inline int memcg_cache_id(struct mem_cgroup *memcg)
 	return -1;
 }
 
-static inline char *memcg_create_cache_name(struct mem_cgroup *memcg,
-					    struct kmem_cache *root_cache)
-{
-	return NULL;
-}
-
 static inline int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 		struct kmem_cache *s, struct kmem_cache *root_cache)
 {
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9260abdd67df..67f10f31f4fb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -115,9 +115,9 @@ int slab_is_available(void);
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
 			void (*)(void *));
-struct kmem_cache *
-kmem_cache_create_memcg(struct mem_cgroup *, const char *, size_t, size_t,
-			unsigned long, void (*)(void *), struct kmem_cache *);
+#ifdef CONFIG_MEMCG_KMEM
+void kmem_cache_create_memcg(struct mem_cgroup *, struct kmem_cache *);
+#endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
 void kmem_cache_free(struct kmem_cache *, void *);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 62db588a8ca6..0e11c72047d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3460,13 +3460,8 @@ static void memcg_create_cache_work_func(struct work_struct *w)
 	struct create_work *cw = container_of(w, struct create_work, work);
 	struct mem_cgroup *memcg = cw->memcg;
 	struct kmem_cache *cachep = cw->cachep;
-	struct kmem_cache *new;
 
-	new = kmem_cache_create_memcg(memcg, cachep->name,
-			cachep->object_size, cachep->align,
-			cachep->flags & ~SLAB_PANIC, cachep->ctor, cachep);
-	if (new)
-		new->allocflags |= __GFP_KMEMCG;
+	kmem_cache_create_memcg(memcg, cachep);
 	css_put(&memcg->css);
 	kfree(cw);
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 11857abf7057..ccc012f00126 100644
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
@@ -139,6 +131,46 @@ unsigned long calculate_alignment(unsigned long flags,
 	return ALIGN(align, sizeof(void *));
 }
 
+static struct kmem_cache *
+do_kmem_cache_create(char *name, size_t object_size, size_t size, size_t align,
+		     unsigned long flags, void (*ctor)(void *),
+		     struct mem_cgroup *memcg, struct kmem_cache *root_cache)
+{
+	struct kmem_cache *s;
+	int err;
+
+	err = -ENOMEM;
+	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
+	if (!s)
+		goto out;
+
+	s->name = name;
+	s->object_size = object_size;
+	s->size = size;
+	s->align = align;
+	s->ctor = ctor;
+
+	err = memcg_alloc_cache_params(memcg, s, root_cache);
+	if (err)
+		goto out_free_cache;
+
+	err = __kmem_cache_create(s, flags);
+	if (err)
+		goto out_free_cache;
+
+	s->refcount = 1;
+	list_add(&s->list, &slab_caches);
+	memcg_register_cache(s);
+out:
+	if (err)
+		return ERR_PTR(err);
+	return s;
+
+out_free_cache:
+	memcg_free_cache_params(s);
+	kfree(s);
+	goto out;
+}
 
 /*
  * kmem_cache_create - Create a cache.
@@ -164,34 +196,21 @@ unsigned long calculate_alignment(unsigned long flags,
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
-	struct kmem_cache *s = NULL;
+	struct kmem_cache *s;
+	char *cache_name;
 	int err;
 
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
@@ -200,55 +219,29 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
 	 */
 	flags &= CACHE_CREATE_MASK;
 
-	if (!memcg) {
-		s = __kmem_cache_alias(name, size, align, flags, ctor);
-		if (s)
-			goto out_unlock;
-	}
-
-	err = -ENOMEM;
-	s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
-	if (!s)
+	s = __kmem_cache_alias(name, size, align, flags, ctor);
+	if (s)
 		goto out_unlock;
 
-	s->object_size = s->size = size;
-	s->align = calculate_alignment(flags, align, size);
-	s->ctor = ctor;
-
-	if (memcg)
-		s->name = memcg_create_cache_name(memcg, parent_cache);
-	else
-		s->name = kstrdup(name, GFP_KERNEL);
-	if (!s->name)
-		goto out_free_cache;
-
-	err = memcg_alloc_cache_params(memcg, s, parent_cache);
-	if (err)
-		goto out_free_cache;
-
-	err = __kmem_cache_create(s, flags);
-	if (err)
-		goto out_free_cache;
+	cache_name = kstrdup(name, GFP_KERNEL);
+	if (!cache_name) {
+		err = -ENOMEM;
+		goto out_unlock;
+	}
 
-	s->refcount = 1;
-	list_add(&s->list, &slab_caches);
-	memcg_register_cache(s);
+	s = do_kmem_cache_create(cache_name, size, size,
+				 calculate_alignment(flags, align, size),
+				 flags, ctor, NULL, NULL);
+	if (IS_ERR(s)) {
+		err = PTR_ERR(s);
+		kfree(cache_name);
+	}
 
 out_unlock:
 	mutex_unlock(&slab_mutex);
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
@@ -260,21 +253,55 @@ out_unlock:
 		return NULL;
 	}
 	return s;
-
-out_free_cache:
-	memcg_free_cache_params(s);
-	kfree(s->name);
-	kmem_cache_free(kmem_cache, s);
-	goto out_unlock;
 }
+EXPORT_SYMBOL(kmem_cache_create);
 
-struct kmem_cache *
-kmem_cache_create(const char *name, size_t size, size_t align,
-		  unsigned long flags, void (*ctor)(void *))
+#ifdef CONFIG_MEMCG_KMEM
+/*
+ * kmem_cache_create_memcg - Create a cache for a memory cgroup.
+ * @memcg: The memory cgroup the new cache is for.
+ * @root_cache: The parent of the new cache.
+ *
+ * This function attempts to create a kmem cache that will serve allocation
+ * requests going from @memcg to @root_cache. The new cache inherits properties
+ * from its parent.
+ */
+void kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
-	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor, NULL);
+	struct kmem_cache *s;
+	char *cache_name;
+
+	get_online_cpus();
+	mutex_lock(&slab_mutex);
+
+	/*
+	 * Since per-memcg caches are created asynchronously on first
+	 * allocation (see memcg_kmem_get_cache()), several threads can try to
+	 * create the same cache, but only one of them may succeed.
+	 */
+	if (cache_from_memcg_idx(root_cache, memcg_cache_id(memcg)))
+		goto out_unlock;
+
+	cache_name = memcg_create_cache_name(memcg, root_cache);
+	if (!cache_name)
+		goto out_unlock;
+
+	s = do_kmem_cache_create(cache_name, root_cache->object_size,
+				 root_cache->size, root_cache->align,
+				 root_cache->flags, root_cache->ctor,
+				 memcg, root_cache);
+	if (IS_ERR(s)) {
+		kfree(cache_name);
+		goto out_unlock;
+	}
+
+	s->allocflags |= __GFP_KMEMCG;
+
+out_unlock:
+	mutex_unlock(&slab_mutex);
+	put_online_cpus();
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
