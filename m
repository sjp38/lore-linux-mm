Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 143046B0258
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:48:59 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so77964279wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:48:59 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id 82si5021718wmu.80.2016.02.26.08.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 08:48:55 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id g62so81000135wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:48:55 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v4 3/7] mm, kasan: Added GFP flags to KASAN API
Date: Fri, 26 Feb 2016 17:48:43 +0100
Message-Id: <494ffa3fd3676f83f5fcf5945c1a55bad740a58d.1456504662.git.glider@google.com>
In-Reply-To: <cover.1456504662.git.glider@google.com>
References: <cover.1456504662.git.glider@google.com>
In-Reply-To: <cover.1456504662.git.glider@google.com>
References: <cover.1456504662.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add GFP flags to KASAN hooks for future patches to use.

This patch is based on the "mm: kasan: unified support for SLUB and
SLAB allocators" patch originally prepared by Dmitry Chernenkov.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v4: - fix kbuild compilation error (missing parameter for kasan_kmalloc())
---
 include/linux/kasan.h | 19 +++++++++++--------
 include/linux/slab.h  |  4 ++--
 mm/kasan/kasan.c      | 15 ++++++++-------
 mm/mempool.c          | 16 ++++++++--------
 mm/slab.c             | 14 +++++++-------
 mm/slab_common.c      |  4 ++--
 mm/slub.c             | 17 +++++++++--------
 7 files changed, 47 insertions(+), 42 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 4405a35..bf71ab0 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -53,13 +53,14 @@ void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
 void kasan_poison_object_data(struct kmem_cache *cache, void *object);
 
-void kasan_kmalloc_large(const void *ptr, size_t size);
+void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags);
 void kasan_kfree_large(const void *ptr);
 void kasan_kfree(void *ptr);
-void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size);
-void kasan_krealloc(const void *object, size_t new_size);
+void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
+		  gfp_t flags);
+void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
 
-void kasan_slab_alloc(struct kmem_cache *s, void *object);
+void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
 void kasan_slab_free(struct kmem_cache *s, void *object);
 
 struct kasan_cache {
@@ -90,14 +91,16 @@ static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
 static inline void kasan_poison_object_data(struct kmem_cache *cache,
 					void *object) {}
 
-static inline void kasan_kmalloc_large(void *ptr, size_t size) {}
+static inline void kasan_kmalloc_large(void *ptr, size_t size, gfp_t flags) {}
 static inline void kasan_kfree_large(const void *ptr) {}
 static inline void kasan_kfree(void *ptr) {}
 static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
-				size_t size) {}
-static inline void kasan_krealloc(const void *object, size_t new_size) {}
+				size_t size, gfp_t flags) {}
+static inline void kasan_krealloc(const void *object, size_t new_size,
+				 gfp_t flags) {}
 
-static inline void kasan_slab_alloc(struct kmem_cache *s, void *object) {}
+static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
+				   gfp_t flags) {}
 static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
 
 static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 840e652..b873343 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -367,7 +367,7 @@ static __always_inline void *kmem_cache_alloc_trace(struct kmem_cache *s,
 {
 	void *ret = kmem_cache_alloc(s, flags);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, flags);
 	return ret;
 }
 
@@ -378,7 +378,7 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
 {
 	void *ret = kmem_cache_alloc_node(s, gfpflags, node);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 #endif /* CONFIG_TRACING */
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index d26ffb4..95b2267 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -414,9 +414,9 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 }
 #endif
 
-void kasan_slab_alloc(struct kmem_cache *cache, void *object)
+void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
-	kasan_kmalloc(cache, object, cache->object_size);
+	kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
 void kasan_slab_free(struct kmem_cache *cache, void *object)
@@ -442,7 +442,8 @@ void kasan_slab_free(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
 }
 
-void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
+void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
+		   gfp_t flags)
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
@@ -471,7 +472,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
-void kasan_kmalloc_large(const void *ptr, size_t size)
+void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 {
 	struct page *page;
 	unsigned long redzone_start;
@@ -490,7 +491,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size)
 		KASAN_PAGE_REDZONE);
 }
 
-void kasan_krealloc(const void *object, size_t size)
+void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 {
 	struct page *page;
 
@@ -500,9 +501,9 @@ void kasan_krealloc(const void *object, size_t size)
 	page = virt_to_head_page(object);
 
 	if (unlikely(!PageSlab(page)))
-		kasan_kmalloc_large(object, size);
+		kasan_kmalloc_large(object, size, flags);
 	else
-		kasan_kmalloc(page->slab_cache, object, size);
+		kasan_kmalloc(page->slab_cache, object, size, flags);
 }
 
 void kasan_kfree(void *ptr)
diff --git a/mm/mempool.c b/mm/mempool.c
index 004d42b..b47c8a7 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -112,12 +112,12 @@ static void kasan_poison_element(mempool_t *pool, void *element)
 		kasan_free_pages(element, (unsigned long)pool->pool_data);
 }
 
-static void kasan_unpoison_element(mempool_t *pool, void *element)
+static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
 {
 	if (pool->alloc == mempool_alloc_slab)
-		kasan_slab_alloc(pool->pool_data, element);
+		kasan_slab_alloc(pool->pool_data, element, flags);
 	if (pool->alloc == mempool_kmalloc)
-		kasan_krealloc(element, (size_t)pool->pool_data);
+		kasan_krealloc(element, (size_t)pool->pool_data, flags);
 	if (pool->alloc == mempool_alloc_pages)
 		kasan_alloc_pages(element, (unsigned long)pool->pool_data);
 }
@@ -130,13 +130,13 @@ static void add_element(mempool_t *pool, void *element)
 	pool->elements[pool->curr_nr++] = element;
 }
 
-static void *remove_element(mempool_t *pool)
+static void *remove_element(mempool_t *pool, gfp_t flags)
 {
 	void *element = pool->elements[--pool->curr_nr];
 
 	BUG_ON(pool->curr_nr < 0);
 	check_element(pool, element);
-	kasan_unpoison_element(pool, element);
+	kasan_unpoison_element(pool, element, flags);
 	return element;
 }
 
@@ -154,7 +154,7 @@ void mempool_destroy(mempool_t *pool)
 		return;
 
 	while (pool->curr_nr) {
-		void *element = remove_element(pool);
+		void *element = remove_element(pool, GFP_KERNEL);
 		pool->free(element, pool->pool_data);
 	}
 	kfree(pool->elements);
@@ -250,7 +250,7 @@ int mempool_resize(mempool_t *pool, int new_min_nr)
 	spin_lock_irqsave(&pool->lock, flags);
 	if (new_min_nr <= pool->min_nr) {
 		while (new_min_nr < pool->curr_nr) {
-			element = remove_element(pool);
+			element = remove_element(pool, GFP_KERNEL);
 			spin_unlock_irqrestore(&pool->lock, flags);
 			pool->free(element, pool->pool_data);
 			spin_lock_irqsave(&pool->lock, flags);
@@ -336,7 +336,7 @@ repeat_alloc:
 
 	spin_lock_irqsave(&pool->lock, flags);
 	if (likely(pool->curr_nr)) {
-		element = remove_element(pool);
+		element = remove_element(pool, gfp_temp);
 		spin_unlock_irqrestore(&pool->lock, flags);
 		/* paired with rmb in mempool_free(), read comment there */
 		smp_wmb();
diff --git a/mm/slab.c b/mm/slab.c
index 805b39b..52a7a8d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3417,7 +3417,7 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *ret = slab_alloc(cachep, flags, _RET_IP_);
 	if (ret)
-		kasan_slab_alloc(cachep, ret);
+		kasan_slab_alloc(cachep, ret, flags);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
@@ -3448,7 +3448,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 	ret = slab_alloc(cachep, flags, _RET_IP_);
 
 	if (ret)
-		kasan_kmalloc(cachep, ret, size);
+		kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
 	return ret;
@@ -3473,7 +3473,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
 	if (ret)
-		kasan_slab_alloc(cachep, ret);
+		kasan_slab_alloc(cachep, ret, flags);
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
 				    flags, nodeid);
@@ -3493,7 +3493,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *cachep,
 	ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
 	if (ret)
-		kasan_kmalloc(cachep, ret, size);
+		kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, cachep->size,
 			   flags, nodeid);
@@ -3513,7 +3513,7 @@ __do_kmalloc_node(size_t size, gfp_t flags, int node, unsigned long caller)
 		return cachep;
 	ret = kmem_cache_alloc_node_trace(cachep, flags, node, size);
 	if (ret)
-		kasan_kmalloc(cachep, ret, size);
+		kasan_kmalloc(cachep, ret, size, flags);
 
 	return ret;
 }
@@ -3550,7 +3550,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	ret = slab_alloc(cachep, flags, caller);
 
 	if (ret)
-		kasan_kmalloc(cachep, ret, size);
+		kasan_kmalloc(cachep, ret, size, flags);
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
 
@@ -4278,7 +4278,7 @@ size_t ksize(const void *objp)
 	/* We assume that ksize callers could use whole allocated area,
 	 * so we need to unpoison this area.
 	 */
-	kasan_krealloc(objp, size);
+	kasan_krealloc(objp, size, GFP_NOWAIT);
 
 	return size;
 }
diff --git a/mm/slab_common.c b/mm/slab_common.c
index bf04ec7..538f616 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1009,7 +1009,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_kmem_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	kmemleak_alloc(ret, size, 1, flags);
-	kasan_kmalloc_large(ret, size);
+	kasan_kmalloc_large(ret, size, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
@@ -1190,7 +1190,7 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 		ks = ksize(p);
 
 	if (ks >= new_size) {
-		kasan_krealloc((void *)p, new_size);
+		kasan_krealloc((void *)p, new_size, flags);
 		return (void *)p;
 	}
 
diff --git a/mm/slub.c b/mm/slub.c
index d8fbd4a..2978695 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1272,7 +1272,7 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
 static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
 	kmemleak_alloc(ptr, size, 1, flags);
-	kasan_kmalloc_large(ptr, size);
+	kasan_kmalloc_large(ptr, size, flags);
 }
 
 static inline void kfree_hook(const void *x)
@@ -1306,7 +1306,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 		kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 		kmemleak_alloc_recursive(object, s->object_size, 1,
 					 s->flags, flags);
-		kasan_slab_alloc(s, object);
+		kasan_slab_alloc(s, object, flags);
 	}
 	memcg_kmem_put_cache(s);
 }
@@ -2584,7 +2584,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2612,7 +2612,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -3156,7 +3156,8 @@ static void early_kmem_cache_node_alloc(int node)
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
-	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node));
+	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node),
+		      GFP_KERNEL);
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
@@ -3531,7 +3532,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
@@ -3576,7 +3577,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
@@ -3605,7 +3606,7 @@ size_t ksize(const void *object)
 	size_t size = __ksize(object);
 	/* We assume that ksize callers could use whole allocated area,
 	   so we need unpoison this area. */
-	kasan_krealloc(object, size);
+	kasan_krealloc(object, size, GFP_NOWAIT);
 	return size;
 }
 EXPORT_SYMBOL(ksize);
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
