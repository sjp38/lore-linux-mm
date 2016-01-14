Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 637478308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:57 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id n128so93550745pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:57 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id 7si1576141pfo.0.2016.01.13.21.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:56 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 65so6929285pfd.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:56 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 09/16] mm/slab: put the freelist at the end of slab page
Date: Thu, 14 Jan 2016 14:24:22 +0900
Message-Id: <1452749069-15334-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, the freelist is at the front of slab page. This requires
extra space to meet object alignment requirement. If we put the freelist
at the end of slab page, object could start at page boundary and will
be at correct alignment. This is possible because freelist has
no alignment constraint itself.

This gives us two benefits. It removes extra memory space
for the freelist alignment and remove complex calculation
at cache initialization step. I can't think notable drawback here.

I mentioned that this would reduce extra memory space, but, this benefit
is rather theoretical because it can be applied to very few cases.
Following is the example cache type that can get benefit from this change.

size align num before after
32 8 124 4100 4092
64 8 63 4103 4095
88 8 46 4102 4094
272 8 15 4103 4095
408 8 10 4098 4090
32 16 124 4108 4092
64 16 63 4111 4095
32 32 124 4124 4092
64 32 63 4127 4095
96 32 42 4106 4074

before means whole size for objects and aligned freelist before applying
patch and after shows the result of this patch.

Since before is more than 4096, number of object should decrease and
memory waste happens.

Anyway, this patch removes complex calculation so looks beneficial to me.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 89 ++++++++++++++++-----------------------------------------------
 1 file changed, 22 insertions(+), 67 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 02bdb91..fe17acc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -456,55 +456,12 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 	return this_cpu_ptr(cachep->cpu_cache);
 }
 
-static size_t calculate_freelist_size(int nr_objs, size_t align)
-{
-	size_t freelist_size;
-
-	freelist_size = nr_objs * sizeof(freelist_idx_t);
-	if (align)
-		freelist_size = ALIGN(freelist_size, align);
-
-	return freelist_size;
-}
-
-static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
-				size_t idx_size, size_t align)
-{
-	int nr_objs;
-	size_t remained_size;
-	size_t freelist_size;
-
-	/*
-	 * Ignore padding for the initial guess. The padding
-	 * is at most @align-1 bytes, and @buffer_size is at
-	 * least @align. In the worst case, this result will
-	 * be one greater than the number of objects that fit
-	 * into the memory allocation when taking the padding
-	 * into account.
-	 */
-	nr_objs = slab_size / (buffer_size + idx_size);
-
-	/*
-	 * This calculated number will be either the right
-	 * amount, or one greater than what we want.
-	 */
-	remained_size = slab_size - nr_objs * buffer_size;
-	freelist_size = calculate_freelist_size(nr_objs, align);
-	if (remained_size < freelist_size)
-		nr_objs--;
-
-	return nr_objs;
-}
-
 /*
  * Calculate the number of objects and left-over bytes for a given buffer size.
  */
 static void cache_estimate(unsigned long gfporder, size_t buffer_size,
-			   size_t align, int flags, size_t *left_over,
-			   unsigned int *num)
+		unsigned long flags, size_t *left_over, unsigned int *num)
 {
-	int nr_objs;
-	size_t mgmt_size;
 	size_t slab_size = PAGE_SIZE << gfporder;
 
 	/*
@@ -512,9 +469,12 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * on it. For the latter case, the memory allocated for a
 	 * slab is used for:
 	 *
-	 * - One freelist_idx_t for each object
-	 * - Padding to respect alignment of @align
 	 * - @buffer_size bytes for each object
+	 * - One freelist_idx_t for each object
+	 *
+	 * We don't need to consider alignment of freelist because
+	 * freelist will be at the end of slab page. The objects will be
+	 * at the correct alignment.
 	 *
 	 * If the slab management structure is off the slab, then the
 	 * alignment will already be calculated into the size. Because
@@ -522,16 +482,13 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * correct alignment when allocated.
 	 */
 	if (flags & CFLGS_OFF_SLAB) {
-		mgmt_size = 0;
-		nr_objs = slab_size / buffer_size;
-
+		*num = slab_size / buffer_size;
+		*left_over = slab_size % buffer_size;
 	} else {
-		nr_objs = calculate_nr_objs(slab_size, buffer_size,
-					sizeof(freelist_idx_t), align);
-		mgmt_size = calculate_freelist_size(nr_objs, align);
+		*num = slab_size / (buffer_size + sizeof(freelist_idx_t));
+		*left_over = slab_size %
+			(buffer_size + sizeof(freelist_idx_t));
 	}
-	*num = nr_objs;
-	*left_over = slab_size - nr_objs*buffer_size - mgmt_size;
 }
 
 #if DEBUG
@@ -1921,7 +1878,7 @@ static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
  * towards high-order requests, this should be changed.
  */
 static size_t calculate_slab_order(struct kmem_cache *cachep,
-			size_t size, size_t align, unsigned long flags)
+				size_t size, unsigned long flags)
 {
 	unsigned long offslab_limit;
 	size_t left_over = 0;
@@ -1931,7 +1888,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 		unsigned int num;
 		size_t remainder;
 
-		cache_estimate(gfporder, size, align, flags, &remainder, &num);
+		cache_estimate(gfporder, size, flags, &remainder, &num);
 		if (!num)
 			continue;
 
@@ -2207,12 +2164,12 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (FREELIST_BYTE_INDEX && size < SLAB_OBJ_MIN_SIZE)
 		size = ALIGN(SLAB_OBJ_MIN_SIZE, cachep->align);
 
-	left_over = calculate_slab_order(cachep, size, cachep->align, flags);
+	left_over = calculate_slab_order(cachep, size, flags);
 
 	if (!cachep->num)
 		return -E2BIG;
 
-	freelist_size = calculate_freelist_size(cachep->num, cachep->align);
+	freelist_size = cachep->num * sizeof(freelist_idx_t);
 
 	/*
 	 * If the slab has been placed off-slab, and we have enough space then
@@ -2223,11 +2180,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		left_over -= freelist_size;
 	}
 
-	if (flags & CFLGS_OFF_SLAB) {
-		/* really off slab. No need for manual alignment */
-		freelist_size = calculate_freelist_size(cachep->num, 0);
-	}
-
 	cachep->colour_off = cache_line_size();
 	/* Offset must be a multiple of the alignment. */
 	if (cachep->colour_off < cachep->align)
@@ -2443,6 +2395,9 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 	void *freelist;
 	void *addr = page_address(page);
 
+	page->s_mem = addr + colour_off;
+	page->active = 0;
+
 	if (OFF_SLAB(cachep)) {
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
@@ -2450,11 +2405,11 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 		if (!freelist)
 			return NULL;
 	} else {
-		freelist = addr + colour_off;
-		colour_off += cachep->freelist_size;
+		/* We will use last bytes at the slab for freelist */
+		freelist = addr + (PAGE_SIZE << cachep->gfporder) -
+				cachep->freelist_size;
 	}
-	page->active = 0;
-	page->s_mem = addr + colour_off;
+
 	return freelist;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
