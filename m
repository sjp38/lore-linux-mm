Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C04A46B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so5107149wmb.3
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j185sor2200502wma.11.2018.03.05.12.07.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:52 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 02/25] slab: make kmalloc_index() return "unsigned int"
Date: Mon,  5 Mar 2018 23:07:07 +0300
Message-Id: <20180305200730.15812-2-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

kmalloc_index() return index into an array of kmalloc kmem caches,
therefore should be unsigned.

Space savings with SLUB on trimmed down .config:

	add/remove: 0/1 grow/shrink: 6/56 up/down: 85/-557 (-472)
	Function                                     old     new   delta
	calculate_sizes                              924     983     +59
	on_freelist                                  589     604     +15
	init_cache_random_seq                        122     127      +5
	ext4_mb_init                                1206    1210      +4
	slab_pad_check.part                          270     271      +1
	cpu_partial_store                            112     113      +1
	usersize_show                                 28      27      -1
		...
	new_slab                                    1871    1837     -34
	slab_order                                   204       -    -204

This patch start a series of converting SLUB (mostly) to "unsigned int".
1) Most integers in the code are in fact unsigned entities: array indexes,
   lengths, buffer sizes, allocation orders. It is therefore better to use
   unsigned variables

2) Some integers in the code are either "size_t" or "unsigned long"
   for no reason.

   size_t usually comes from people trying to maintain type correctness
   and figuring out that "sizeof" operator returns size_t or memset/memcpy
   takes size_t so should everything passed to it.

   However the number of 4GB+ objects in the kernel is very small.
   Most, if not all, dynamically allocated objects with kmalloc() or
   kmem_cache_create() aren't actually big. Maintaining wide types
   doesn't do anything.

   64-bit ops are bigger than 32-bit on our beloved x86_64,
   so try to not use 64-bit where it isn't necessary
   (read: everywhere where integers are integers not pointers)

3) in case of SLAB allocators, there are additional limitations
   *) page->inuse, page->objects are only 16-/15-bit,
   *) cache size was always 32-bit
   *) slab orders are small, order 20 is needed to go 64-bit on x86_64
      (PAGE_SIZE << order)

Basically everything is 32-bit except kmalloc(1ULL<<32) which gets shortcut
through page allocator.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slab.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 231abc8976c5..296f33a512eb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -308,7 +308,7 @@ extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
  * 2 = 129 .. 192 bytes
  * n = 2^(n-1)+1 .. 2^n
  */
-static __always_inline int kmalloc_index(size_t size)
+static __always_inline unsigned int kmalloc_index(size_t size)
 {
 	if (!size)
 		return 0;
@@ -504,7 +504,7 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 			return kmalloc_large(size, flags);
 #ifndef CONFIG_SLOB
 		if (!(flags & GFP_DMA)) {
-			int index = kmalloc_index(size);
+			unsigned int index = kmalloc_index(size);
 
 			if (!index)
 				return ZERO_SIZE_PTR;
@@ -542,7 +542,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 #ifndef CONFIG_SLOB
 	if (__builtin_constant_p(size) &&
 		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
-		int i = kmalloc_index(size);
+		unsigned int i = kmalloc_index(size);
 
 		if (!i)
 			return ZERO_SIZE_PTR;
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
