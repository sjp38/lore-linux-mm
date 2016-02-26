Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D162F828E6
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:02:10 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id q63so46298056pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:10 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id eq6si2137861pad.188.2016.02.25.22.02.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:02:10 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id fy10so45381171pac.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:02:10 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 11/17] mm/slab: clean up cache type determination
Date: Fri, 26 Feb 2016 15:01:18 +0900
Message-Id: <1456466484-3442-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current cache type determination code is open-code and looks not
understandable.  Following patch will introduce one more cache type and it
would make code more complex.  So, before it happens, this patch abstracts
these codes.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 105 ++++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 71 insertions(+), 34 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d5dffc8..9b56685 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2023,6 +2023,64 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
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
@@ -2047,7 +2105,6 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 int
 __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 {
-	size_t left_over, freelist_size;
 	size_t ralign = BYTES_PER_WORD;
 	gfp_t gfp;
 	int err;
@@ -2098,6 +2155,10 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * 4) Store it.
 	 */
 	cachep->align = ralign;
+	cachep->colour_off = cache_line_size();
+	/* Offset must be a multiple of the alignment. */
+	if (cachep->colour_off < cachep->align)
+		cachep->colour_off = cachep->align;
 
 	if (slab_is_available())
 		gfp = GFP_KERNEL;
@@ -2152,43 +2213,18 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
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
-
-	freelist_size = cachep->num * sizeof(freelist_idx_t);
+	if (set_on_slab_cache(cachep, size, flags))
+		goto done;
 
-	/*
-	 * If the slab has been placed off-slab, and we have enough space then
-	 * move it on-slab. This is at the expense of any extra colouring.
-	 */
-	if (flags & CFLGS_OFF_SLAB && left_over >= freelist_size) {
-		flags &= ~CFLGS_OFF_SLAB;
-		left_over -= freelist_size;
-	}
+	return -E2BIG;
 
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
@@ -2209,7 +2245,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
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
