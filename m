Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF06C6B0260
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 08:53:32 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so9301795lbb.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 05:53:32 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id f66si20607243wma.11.2016.06.01.05.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 05:53:31 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id z87so28219046wmh.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 05:53:31 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] mm: kasan: don't touch metadata in kasan_[un]poison_element()
Date: Wed,  1 Jun 2016 14:53:26 +0200
Message-Id: <1464785606-20349-1-git-send-email-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com, aryabinin@virtuozzo.com, kuthonuzo.luruo@hpe.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To avoid draining the mempools, KASAN shouldn't put the mempool elements
into the quarantine upon mempool_free(). It shouldn't store
allocation/deallocation stacks upon mempool_alloc()/mempool_free() either.
Therefore make kasan_[un]poison_element() just change the shadow memory,
not the metadata.

Signed-off-by: Alexander Potapenko <glider@google.com>
Reported-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
---
 include/linux/kasan.h |  8 ++++++--
 mm/kasan/kasan.c      | 48 +++++++++++++++++++++++++++++++++++++++++++++---
 mm/mempool.c          |  5 +++--
 mm/slab.c             |  4 ++--
 mm/slab.h             |  2 +-
 5 files changed, 57 insertions(+), 10 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 611927f..bafc13a 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -63,8 +63,10 @@ void kasan_kfree(void *ptr);
 void kasan_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		  gfp_t flags);
 void kasan_krealloc(const void *object, size_t new_size, gfp_t flags);
+void kasan_unpoison_kmalloc(const void *object, size_t size, gfp_t flags);
 
-void kasan_slab_alloc(struct kmem_cache *s, void *object, gfp_t flags);
+void kasan_slab_alloc(struct kmem_cache *s, void *object, bool just_unpoison,
+			gfp_t flags);
 bool kasan_slab_free(struct kmem_cache *s, void *object);
 void kasan_poison_slab_free(struct kmem_cache *s, void *object);
 
@@ -107,9 +109,11 @@ static inline void kasan_kmalloc(struct kmem_cache *s, const void *object,
 				size_t size, gfp_t flags) {}
 static inline void kasan_krealloc(const void *object, size_t new_size,
 				 gfp_t flags) {}
+static inline void kasan_unpoison_kmalloc(const void *object, size_t size,
+					gfp_t flags) {}
 
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object,
-				   gfp_t flags) {}
+				   bool just_unpoison, gfp_t flags) {}
 static inline bool kasan_slab_free(struct kmem_cache *s, void *object)
 {
 	return false;
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 18b6a2b..8820f22 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -503,9 +503,13 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 }
 #endif
 
-void kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
+void kasan_slab_alloc(struct kmem_cache *cache, void *object,
+			bool just_unpoison, gfp_t flags)
 {
-	kasan_kmalloc(cache, object, cache->object_size, flags);
+	if (just_unpoison)
+		kasan_unpoison_shadow(object, cache->object_size);
+	else
+		kasan_kmalloc(cache, object, cache->object_size, flags);
 }
 
 void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
@@ -611,6 +615,31 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 		KASAN_PAGE_REDZONE);
 }
 
+void kasan_unpoison_kmalloc(const void *object, size_t size, gfp_t flags)
+{
+	struct page *page;
+	unsigned long redzone_start;
+	unsigned long redzone_end;
+
+	if (unlikely(object == ZERO_SIZE_PTR) || (object == NULL))
+		return;
+
+	page = virt_to_head_page(object);
+	redzone_start = round_up((unsigned long)(object + size),
+				KASAN_SHADOW_SCALE_SIZE);
+
+	if (unlikely(!PageSlab(page)))
+		redzone_end = (unsigned long)object +
+			(PAGE_SIZE << compound_order(page));
+	else
+		redzone_end = round_up(
+			(unsigned long)object + page->slab_cache->object_size,
+			KASAN_SHADOW_SCALE_SIZE);
+	kasan_unpoison_shadow(object, size);
+	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
+		KASAN_KMALLOC_REDZONE);
+}
+
 void kasan_krealloc(const void *object, size_t size, gfp_t flags)
 {
 	struct page *page;
@@ -636,7 +665,20 @@ void kasan_kfree(void *ptr)
 		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
 				KASAN_FREE_PAGE);
 	else
-		kasan_slab_free(page->slab_cache, ptr);
+		kasan_poison_slab_free(page->slab_cache, ptr);
+}
+
+void kasan_poison_kfree(void *ptr)
+{
+	struct page *page;
+
+	page = virt_to_head_page(ptr);
+
+	if (unlikely(!PageSlab(page)))
+		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
+				KASAN_FREE_PAGE);
+	else
+		kasan_poison_slab_free(page->slab_cache, ptr);
 }
 
 void kasan_kfree_large(const void *ptr)
diff --git a/mm/mempool.c b/mm/mempool.c
index 9e075f8..bcd48c6 100644
--- a/mm/mempool.c
+++ b/mm/mempool.c
@@ -115,9 +115,10 @@ static void kasan_poison_element(mempool_t *pool, void *element)
 static void kasan_unpoison_element(mempool_t *pool, void *element, gfp_t flags)
 {
 	if (pool->alloc == mempool_alloc_slab)
-		kasan_slab_alloc(pool->pool_data, element, flags);
+		kasan_slab_alloc(pool->pool_data, element,
+				/*just_unpoison*/ false, flags);
 	if (pool->alloc == mempool_kmalloc)
-		kasan_krealloc(element, (size_t)pool->pool_data, flags);
+		kasan_unpoison_kmalloc(element, (size_t)pool->pool_data, flags);
 	if (pool->alloc == mempool_alloc_pages)
 		kasan_alloc_pages(element, (unsigned long)pool->pool_data);
 }
diff --git a/mm/slab.c b/mm/slab.c
index cc8bbc1..b42ae23 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3606,7 +3606,7 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *ret = slab_alloc(cachep, flags, _RET_IP_);
 
-	kasan_slab_alloc(cachep, ret, flags);
+	kasan_slab_alloc(cachep, ret, /*just_unpoison*/ false, flags);
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
 
@@ -3696,7 +3696,7 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 {
 	void *ret = slab_alloc_node(cachep, flags, nodeid, _RET_IP_);
 
-	kasan_slab_alloc(cachep, ret, flags);
+	kasan_slab_alloc(cachep, ret, /*just_unpoison*/ false, flags);
 	trace_kmem_cache_alloc_node(_RET_IP_, ret,
 				    cachep->object_size, cachep->size,
 				    flags, nodeid);
diff --git a/mm/slab.h b/mm/slab.h
index dedb1a9..d56c042 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -405,7 +405,7 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
 		kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 		kmemleak_alloc_recursive(object, s->object_size, 1,
 					 s->flags, flags);
-		kasan_slab_alloc(s, object, flags);
+		kasan_slab_alloc(s, object, /*just_unpoison*/false, flags);
 	}
 	memcg_kmem_put_cache(s);
 }
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
