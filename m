Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D9F688308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:25:03 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id q63so96349010pfb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:03 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id v63si6857640pfa.245.2016.01.13.21.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:25:03 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id n128so6915493pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:03 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 11/16] mm/slab: clean-up cache type determination
Date: Thu, 14 Jan 2016 14:24:24 +0900
Message-Id: <1452749069-15334-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Current cache type determination code is open-code and
looks not understandable. Following patch will introduce
one more cache type and it would make code more complex.
So, before it happens, this patch abstracts these codes.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 105 ++++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 71 insertions(+), 34 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 3a319f5..7a253a9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2024,6 +2024,64 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 	return cachep;
 }
 
+static bool set_off_slab_cache(struct kmem_cache *cachep,
+			size_t size, unsigned long flags)
+{
+	size_t left;
+
+	cachep->num = 0;
+
+	/*
+	 * Determine if the slab management is 'on' or 'off' slab.
+	 * (bootstrapping cannot cope with offslab caches so don't do
+	 * it too early on. Always use on-slab management when
+	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
+	 */
+	if (size < OFF_SLAB_MIN_SIZE)
+		return false;
+
+	if (slab_early_init)
+		return false;
+
+	if (flags & SLAB_NOLEAKTRACE)
+		return false;
+
+	/*
+	 * Size is large, assume best to place the slab management obj
+	 * off-slab (should allow better packing of objs).
+	 */
+	left = calculate_slab_order(cachep, size, flags | CFLGS_OFF_SLAB);
+	if (!cachep->num)
+		return false;
+
+	/*
+	 * If the slab has been placed off-slab, and we have enough space then
+	 * move it on-slab. This is at the expense of any extra colouring.
+	 */
+	if (left >= cachep->num * sizeof(freelist_idx_t))
+		return false;
+
+	cachep->colour = left / cachep->colour_off;
+
+	return true;
+}
+
+static bool set_on_slab_cache(struct kmem_cache *cachep,
+			size_t size, unsigned long flags)
+{
+	size_t left;
+
+	cachep->num = 0;
+
+	left = calculate_slab_order(cachep, size, flags);
+	if (!cachep->num)
+		return false;
+
+	cachep->colour = left / cachep->colour_off;
+
+	return true;
+}
+
 /**
  * __kmem_cache_create - Create a cache.
  * @cachep: cache management descriptor
@@ -2048,7 +2106,6 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 int
 __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 {
-	size_t left_over, freelist_size;
 	size_t ralign = BYTES_PER_WORD;
 	gfp_t gfp;
 	int err;
@@ -2099,6 +2156,10 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * 4) Store it.
 	 */
 	cachep->align = ralign;
+	cachep->colour_off = cache_line_size();
+	/* Offset must be a multiple of the alignment. */
+	if (cachep->colour_off < cachep->align)
+		cachep->colour_off = cachep->align;
 
 	if (slab_is_available())
 		gfp = GFP_KERNEL;
@@ -2153,43 +2214,18 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	}
 #endif
 
-	/*
-	 * Determine if the slab management is 'on' or 'off' slab.
-	 * (bootstrapping cannot cope with offslab caches so don't do
-	 * it too early on. Always use on-slab management when
-	 * SLAB_NOLEAKTRACE to avoid recursive calls into kmemleak)
-	 */
-	if (size >= OFF_SLAB_MIN_SIZE && !slab_early_init &&
-	    !(flags & SLAB_NOLEAKTRACE)) {
-		/*
-		 * Size is large, assume best to place the slab management obj
-		 * off-slab (should allow better packing of objs).
-		 */
+	if (set_off_slab_cache(cachep, size, flags)) {
 		flags |= CFLGS_OFF_SLAB;
+		goto done;
 	}
 
-	left_over = calculate_slab_order(cachep, size, flags);
-
-	if (!cachep->num)
-		return -E2BIG;
+	if (set_on_slab_cache(cachep, size, flags))
+		goto done;
 
-	freelist_size = cachep->num * sizeof(freelist_idx_t);
+	return -E2BIG;
 
-	/*
-	 * If the slab has been placed off-slab, and we have enough space then
-	 * move it on-slab. This is at the expense of any extra colouring.
-	 */
-	if (flags & CFLGS_OFF_SLAB && left_over >= freelist_size) {
-		flags &= ~CFLGS_OFF_SLAB;
-		left_over -= freelist_size;
-	}
-
-	cachep->colour_off = cache_line_size();
-	/* Offset must be a multiple of the alignment. */
-	if (cachep->colour_off < cachep->align)
-		cachep->colour_off = cachep->align;
-	cachep->colour = left_over / cachep->colour_off;
-	cachep->freelist_size = freelist_size;
+done:
+	cachep->freelist_size = cachep->num * sizeof(freelist_idx_t);
 	cachep->flags = flags;
 	cachep->allocflags = __GFP_COMP;
 	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
@@ -2210,7 +2246,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 #endif
 
 	if (OFF_SLAB(cachep)) {
-		cachep->freelist_cache = kmalloc_slab(freelist_size, 0u);
+		cachep->freelist_cache =
+			kmalloc_slab(cachep->freelist_size, 0u);
 		/*
 		 * This is a possibility for one of the kmalloc_{dma,}_caches.
 		 * But since we go off slab only for object size greater than
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
