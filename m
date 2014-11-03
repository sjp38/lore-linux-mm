Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1A9C6B00F5
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 16:00:12 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so12812088pab.24
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 13:00:12 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id so6si16145367pac.164.2014.11.03.13.00.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 13:00:11 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 3/8] memcg: decouple per memcg kmem cache from the owner memcg
Date: Mon, 3 Nov 2014 23:59:41 +0300
Message-ID: <b5bac77e0bcb0132d68ae3ad648c0b8cefff0fd1.1415046910.git.vdavydov@parallels.com>
In-Reply-To: <cover.1415046910.git.vdavydov@parallels.com>
References: <cover.1415046910.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Basically, we substitute the reference to the owner memory cgroup in
memcg_cache_params with the index in the memcg_caches array. This
decouples kmem cache from the memcg it was created for and will allow to
reuse it for another cgroup after css offline.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/slab.h |    7 +++----
 mm/memcontrol.c      |   18 +++++-------------
 mm/slab_common.c     |   12 +++++-------
 3 files changed, 13 insertions(+), 24 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 390341d30b2d..293c04df7953 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -117,8 +117,7 @@ struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			void (*)(void *));
 #ifdef CONFIG_MEMCG_KMEM
 struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *,
-					   struct kmem_cache *,
-					   const char *);
+					   struct kmem_cache *);
 #endif
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
@@ -490,7 +489,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
  *
  * Child caches will hold extra metadata needed for its operation. Fields are:
  *
- * @memcg: pointer to the memcg this cache belongs to
+ * @id: the index in the root_cache's memcg_caches array.
  * @root_cache: pointer to the global, root cache, this cache was derived from
  */
 struct memcg_cache_params {
@@ -501,7 +500,7 @@ struct memcg_cache_params {
 			struct kmem_cache *memcg_caches[0];
 		};
 		struct {
-			struct mem_cgroup *memcg;
+			int id;
 			struct kmem_cache *root_cache;
 		};
 	};
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c60d7a30f4f..78d12076b01d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2603,8 +2603,6 @@ void memcg_update_array_size(int num)
 static void memcg_register_cache(struct mem_cgroup *memcg,
 				 struct kmem_cache *root_cache)
 {
-	static char memcg_name_buf[NAME_MAX + 1]; /* protected by
-						     memcg_slab_mutex */
 	struct kmem_cache *cachep;
 	int id;
 
@@ -2620,8 +2618,7 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	if (cache_from_memcg_idx(root_cache, id))
 		return;
 
-	cgroup_name(memcg->css.cgroup, memcg_name_buf, NAME_MAX + 1);
-	cachep = memcg_create_kmem_cache(memcg, root_cache, memcg_name_buf);
+	cachep = memcg_create_kmem_cache(memcg, root_cache);
 	/*
 	 * If we could not create a memcg cache, do not complain, because
 	 * that's not critical at all as we can always proceed with the root
@@ -2630,8 +2627,6 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 	if (!cachep)
 		return;
 
-	css_get(&memcg->css);
-
 	/*
 	 * Since readers won't lock (see cache_from_memcg_idx()), we need a
 	 * barrier here to ensure nobody will see the kmem_cache partially
@@ -2646,7 +2641,6 @@ static void memcg_register_cache(struct mem_cgroup *memcg,
 static void memcg_unregister_cache(struct kmem_cache *cachep)
 {
 	struct kmem_cache *root_cache;
-	struct mem_cgroup *memcg;
 	int id;
 
 	lockdep_assert_held(&memcg_slab_mutex);
@@ -2654,16 +2648,12 @@ static void memcg_unregister_cache(struct kmem_cache *cachep)
 	BUG_ON(is_root_cache(cachep));
 
 	root_cache = cachep->memcg_params->root_cache;
-	memcg = cachep->memcg_params->memcg;
-	id = memcg_cache_id(memcg);
+	id = cachep->memcg_params->id;
 
 	BUG_ON(root_cache->memcg_params->memcg_caches[id] != cachep);
 	root_cache->memcg_params->memcg_caches[id] = NULL;
 
 	kmem_cache_destroy(cachep);
-
-	/* drop the reference taken in memcg_register_cache */
-	css_put(&memcg->css);
 }
 
 /*
@@ -4198,7 +4188,6 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
 
-	memcg->kmemcg_id = -1;
 	ret = memcg_propagate_kmem(memcg);
 	if (ret)
 		return ret;
@@ -4743,6 +4732,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	vmpressure_init(&memcg->vmpressure);
 	INIT_LIST_HEAD(&memcg->event_list);
 	spin_lock_init(&memcg->event_list_lock);
+#ifdef CONFIG_MEMCG_KMEM
+	memcg->kmemcg_id = -1;
+#endif
 
 	return &memcg->css;
 
diff --git a/mm/slab_common.c b/mm/slab_common.c
index d5e9e050a3ec..974d77db1b39 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -125,7 +125,7 @@ static int memcg_alloc_cache_params(struct mem_cgroup *memcg,
 		return -ENOMEM;
 
 	if (memcg) {
-		s->memcg_params->memcg = memcg;
+		s->memcg_params->id = memcg_cache_id(memcg);
 		s->memcg_params->root_cache = root_cache;
 	} else
 		s->memcg_params->is_root_cache = true;
@@ -426,15 +426,13 @@ EXPORT_SYMBOL(kmem_cache_create);
  * memcg_create_kmem_cache - Create a cache for a memory cgroup.
  * @memcg: The memory cgroup the new cache is for.
  * @root_cache: The parent of the new cache.
- * @memcg_name: The name of the memory cgroup (used for naming the new cache).
  *
  * This function attempts to create a kmem cache that will serve allocation
  * requests going from @memcg to @root_cache. The new cache inherits properties
  * from its parent.
  */
 struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
-					   struct kmem_cache *root_cache,
-					   const char *memcg_name)
+					   struct kmem_cache *root_cache)
 {
 	struct kmem_cache *s = NULL;
 	char *cache_name;
@@ -444,8 +442,8 @@ struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
 
 	mutex_lock(&slab_mutex);
 
-	cache_name = kasprintf(GFP_KERNEL, "%s(%d:%s)", root_cache->name,
-			       memcg_cache_id(memcg), memcg_name);
+	cache_name = kasprintf(GFP_KERNEL, "%s(%d)", root_cache->name,
+			       memcg_cache_id(memcg));
 	if (!cache_name)
 		goto out_unlock;
 
@@ -912,7 +910,7 @@ int memcg_slab_show(struct seq_file *m, void *p)
 
 	if (p == slab_caches.next)
 		print_slabinfo_header(m);
-	if (!is_root_cache(s) && s->memcg_params->memcg == memcg)
+	if (!is_root_cache(s) && s->memcg_params->id == memcg_cache_id(memcg))
 		cache_show(s, m);
 	return 0;
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
