Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 857B66B0284
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:27 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k18so12251503wre.11
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f44sor7336444wra.5.2017.11.23.14.17.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:26 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 19/23] kasan: make kasan_cache_create() work with 32-bit slab caches
Date: Fri, 24 Nov 2017 01:16:24 +0300
Message-Id: <20171123221628.8313-19-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

If SLAB doesn't support 4GB+ kmem caches (it never did), KASAN should not
do it as well.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/kasan.h | 4 ++--
 mm/kasan/kasan.c      | 4 ++--
 mm/slab.c             | 2 +-
 mm/slub.c             | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index e3eb834c9a35..d0a05e0f9e8e 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -45,7 +45,7 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark);
 void kasan_alloc_pages(struct page *page, unsigned int order);
 void kasan_free_pages(struct page *page, unsigned int order);
 
-void kasan_cache_create(struct kmem_cache *cache, size_t *size,
+void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 			slab_flags_t *flags);
 void kasan_cache_shrink(struct kmem_cache *cache);
 void kasan_cache_shutdown(struct kmem_cache *cache);
@@ -94,7 +94,7 @@ static inline void kasan_alloc_pages(struct page *page, unsigned int order) {}
 static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 
 static inline void kasan_cache_create(struct kmem_cache *cache,
-				      size_t *size,
+				      unsigned int *size,
 				      slab_flags_t *flags) {}
 static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
 static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 405bba487df5..0bb95f6a1b7b 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -336,11 +336,11 @@ static size_t optimal_redzone(size_t object_size)
 	return rz;
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
diff --git a/mm/slab.c b/mm/slab.c
index 15da0e177d7b..328b9b705981 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1999,7 +1999,7 @@ int __kmem_cache_create(struct kmem_cache *cachep, slab_flags_t flags)
 	size_t ralign = BYTES_PER_WORD;
 	gfp_t gfp;
 	int err;
-	size_t size = cachep->size;
+	unsigned int size = cachep->size;
 
 #if DEBUG
 #if FORCED_DEBUG
diff --git a/mm/slub.c b/mm/slub.c
index cd09ae2c48e8..ce71665e266c 100644
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
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
