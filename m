Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id C298382F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 12:39:27 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so205045495wic.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 09:39:27 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id cj2si34424672wib.40.2015.10.28.09.39.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 09:39:26 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so19515330wic.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 09:39:26 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH 1/2] mm, kasan: Added GFP flags to KASAN API
Date: Wed, 28 Oct 2015 17:39:17 +0100
Message-Id: <1446050357-40105-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add GFP flags to KASAN hooks for future patches to use.
This is the first part of the "mm: kasan: unified support for SLUB and
SLAB allocators" patch originally prepared by Dmitry Chernenkov.

Signed-off-by: Dmitry Chernenkov <dmitryc@google.com>
Signed-off-by: Alexander Potapenko <glider@google.com>
---
 include/linux/kasan.h | 19 +++++++++++--------
 mm/kasan/kasan.c      | 15 ++++++++-------
 mm/mempool.c          | 16 ++++++++--------
 mm/slab_common.c      |  4 ++--
 mm/slub.c             | 17 +++++++++--------
 5 files changed, 38 insertions(+), 33 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 4b9f85c..e1ce960 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -50,13 +50,14 @@ void kasan_poison_slab(struct page *page);
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
 
 int kasan_module_alloc(void *addr, size_t size);
@@ -78,14 +79,16 @@ static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
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
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8da2114..ba0734b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -318,9 +318,9 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 			KASAN_KMALLOC_REDZONE);
 }
 
-void kasan_slab_alloc(struct kmem_cache *cache, void *object)
+void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
-	kasan_kmalloc(cache, object, cache->object_size);
+	kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
 void kasan_slab_free(struct kmem_cache *cache, void *object)
@@ -335,7 +335,8 @@ void kasan_slab_free(struct kmem_cache *cache, void *object)
 	kasan_poison_shadow(object, rounded_up_size, KASAN_KMALLOC_FREE);
 }
 
-void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
+void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
+		   gfp_t flags)
 {
 	unsigned long redzone_start;
 	unsigned long redzone_end;
@@ -354,7 +355,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size)
 }
 EXPORT_SYMBOL(kasan_kmalloc);
 
-void kasan_kmalloc_large(const void *ptr, size_t size)
+void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 {
 	struct page *page;
 	unsigned long redzone_start;
@@ -373,7 +374,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size)
 		KASAN_PAGE_REDZONE);
 }
 
-void kasan_krealloc(const void *object, size_t size)
+void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 {
 	struct page *page;
 
@@ -383,9 +384,9 @@ void kasan_krealloc(const void *object, size_t size)
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
index 4c533bc..31848f4 100644
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
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5ce4fae..a07bfe0 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -945,7 +945,7 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 	page = alloc_kmem_pages(flags, order);
 	ret = page ? page_address(page) : NULL;
 	kmemleak_alloc(ret, size, 1, flags);
-	kasan_kmalloc_large(ret, size);
+	kasan_kmalloc_large(ret, size, flags);
 	return ret;
 }
 EXPORT_SYMBOL(kmalloc_order);
@@ -1126,7 +1126,7 @@ static __always_inline void *__do_krealloc(const void *p, size_t new_size,
 		ks = ksize(p);
 
 	if (ks >= new_size) {
-		kasan_krealloc((void *)p, new_size);
+		kasan_krealloc((void *)p, new_size, flags);
 		return (void *)p;
 	}
 
diff --git a/mm/slub.c b/mm/slub.c
index f614b5d..4e20d66 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1249,7 +1249,7 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
 static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
 {
 	kmemleak_alloc(ptr, size, 1, flags);
-	kasan_kmalloc_large(ptr, size);
+	kasan_kmalloc_large(ptr, size, flags);
 }
 
 static inline void kfree_hook(const void *x)
@@ -1278,7 +1278,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
 	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
 	memcg_kmem_put_cache(s);
-	kasan_slab_alloc(s, object);
+	kasan_slab_alloc(s, object, flags);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
@@ -2528,7 +2528,7 @@ void *kmem_cache_alloc_trace(struct kmem_cache *s, gfp_t gfpflags, size_t size)
 {
 	void *ret = slab_alloc(s, gfpflags, _RET_IP_);
 	trace_kmalloc(_RET_IP_, ret, size, s->size, gfpflags);
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_trace);
@@ -2556,7 +2556,7 @@ void *kmem_cache_alloc_node_trace(struct kmem_cache *s,
 	trace_kmalloc_node(_RET_IP_, ret,
 			   size, s->size, gfpflags, node);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, gfpflags);
 	return ret;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
@@ -3050,7 +3050,8 @@ static void early_kmem_cache_node_alloc(int node)
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
-	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node));
+	kasan_kmalloc(kmem_cache_node, n, sizeof(struct kmem_cache_node),
+		      GFP_KERNEL);
 	init_kmem_cache_node(n);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
@@ -3423,7 +3424,7 @@ void *__kmalloc(size_t size, gfp_t flags)
 
 	trace_kmalloc(_RET_IP_, ret, size, s->size, flags);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
@@ -3468,7 +3469,7 @@ void *__kmalloc_node(size_t size, gfp_t flags, int node)
 
 	trace_kmalloc_node(_RET_IP_, ret, size, s->size, flags, node);
 
-	kasan_kmalloc(s, ret, size);
+	kasan_kmalloc(s, ret, size, flags);
 
 	return ret;
 }
@@ -3497,7 +3498,7 @@ size_t ksize(const void *object)
 	size_t size = __ksize(object);
 	/* We assume that ksize callers could use whole allocated area,
 	   so we need unpoison this area. */
-	kasan_krealloc(object, size);
+	kasan_krealloc(object, size, GFP_NOWAIT);
 	return size;
 }
 EXPORT_SYMBOL(ksize);
-- 
2.6.0.rc2.230.g3dd15c0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
