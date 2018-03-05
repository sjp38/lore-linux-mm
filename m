Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1D26B002A
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:13 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z14so11995945wrh.1
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a6sor6545934wrh.51.2018.03.05.12.08.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:12 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 20/25] kasan: make kasan_cache_create() work with 32-bit slab cache sizes
Date: Mon,  5 Mar 2018 23:07:25 +0300
Message-Id: <20180305200730.15812-20-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

If SLAB doesn't support 4GB+ kmem caches (it never did), KASAN should not
do it as well.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/kasan.h |  4 ++--
 mm/kasan/kasan.c      | 12 ++++++------
 mm/slab.c             |  2 +-
 mm/slub.c             |  2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index adc13474a53b..024d4219b953 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -43,7 +43,7 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark);
 void kasan_alloc_pages(struct page *page, unsigned int order);
 void kasan_free_pages(struct page *page, unsigned int order);
 
-void kasan_cache_create(struct kmem_cache *cache, size_t *size,
+void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 			slab_flags_t *flags);
 void kasan_cache_shrink(struct kmem_cache *cache);
 void kasan_cache_shutdown(struct kmem_cache *cache);
@@ -92,7 +92,7 @@ static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
 static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 
 static inline void kasan_cache_create(struct kmem_cache *cache,
-				      size_t *size,
+				      unsigned int *size,
 				      slab_flags_t *flags) {}
 static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
 static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index e13d911251e7..f7a5e1d1ba87 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -323,9 +323,9 @@ void kasan_free_pages(struct page *page, unsigned int order)
  * Adaptive redzone policy taken from the userspace AddressSanitizer runtime.
  * For larger allocations larger redzones are used.
  */
-static size_t optimal_redzone(size_t object_size)
+static unsigned int optimal_redzone(unsigned int object_size)
 {
-	int rz =
+	return
 		object_size <= 64        - 16   ? 16 :
 		object_size <= 128       - 32   ? 32 :
 		object_size <= 512       - 64   ? 64 :
@@ -333,14 +333,13 @@ static size_t optimal_redzone(size_t object_size)
 		object_size <= (1 << 14) - 256  ? 256 :
 		object_size <= (1 << 15) - 512  ? 512 :
 		object_size <= (1 << 16) - 1024 ? 1024 : 2048;
-	return rz;
 }
 
-void kasan_cache_create(struct kmem_cache *cache, size_t *size,
+void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 			slab_flags_t *flags)
 {
+	unsigned int orig_size = *size;
 	int redzone_adjust;
-	int orig_size = *size;
 
 	/* Add alloc meta. */
 	cache->kasan_info.alloc_meta_offset = *size;
@@ -358,7 +357,8 @@ void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 	if (redzone_adjust > 0)
 		*size += redzone_adjust;
 
-	*size = min(KMALLOC_MAX_SIZE, max(*size, cache->object_size +
+	*size = min_t(unsigned int, KMALLOC_MAX_SIZE,
+			max(*size, cache->object_size +
 					optimal_redzone(cache->object_size)));
 
 	/*
diff --git a/mm/slab.c b/mm/slab.c
index 7d17206dd574..5988f9a1cca8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1993,7 +1993,7 @@ int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 	size_t ralign = BYTES_PER_WORD;
 	gfp_t gfp;
 	int err;
-	size_t size = cachep->size;
+	unsigned int size = cachep->size;
 
 #if DEBUG
 #if FORCED_DEBUG
diff --git a/mm/slub.c b/mm/slub.c
index e82a6b50b3ef..87a7a947f2c9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3457,7 +3457,7 @@ static void set_cpu_partial(struct kmem_cache *s)
 static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
 	slab_flags_t flags = s->flags;
-	size_t size = s->object_size;
+	unsigned int size = s->object_size;
 	int order;
 
 	/*
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
