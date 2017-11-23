Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1F7C6B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:10 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m78so5591841wma.3
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j13sor7483828wrb.30.2017.11.23.14.17.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:09 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 01/23] slab: make kmalloc_index() return "unsigned int"
Date: Fri, 24 Nov 2017 01:16:06 +0300
Message-Id: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

kmalloc_index() return index into an array of kmalloc kmem caches,
therefore should unsigned.

Space savings:

	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-6 (-6)
	Function                                     old     new   delta
	rtsx_scsi_handler                           9116    9114      -2
	vnic_rq_alloc                                424     420      -4

This patch start a series of converting SLUB (mostly) to "unsigned int".
1) Most integers in the code are in fact unsigned entities: array indexes,
   lengths, buffer sizes, allocation orders. It is therefore better to use
   unsigned variables

2) Some integers in the code are either "size_t" or "unsigned long" for no
   reason.
 
   size_t usually comes from people trying to "maintain" type correctness
   and figuring out that "sizeof" operator returns size_t or that
   memset/memcpy    takes size_t so should everything you pass to it.

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
index 50697a1d6621..e765800d7c9b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -295,7 +295,7 @@ extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
  * 2 = 129 .. 192 bytes
  * n = 2^(n-1)+1 .. 2^n
  */
-static __always_inline int kmalloc_index(size_t size)
+static __always_inline unsigned int kmalloc_index(size_t size)
 {
 	if (!size)
 		return 0;
@@ -491,7 +491,7 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
 			return kmalloc_large(size, flags);
 #ifndef CONFIG_SLOB
 		if (!(flags & GFP_DMA)) {
-			int index = kmalloc_index(size);
+			unsigned int index = kmalloc_index(size);
 
 			if (!index)
 				return ZERO_SIZE_PTR;
@@ -529,7 +529,7 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 #ifndef CONFIG_SLOB
 	if (__builtin_constant_p(size) &&
 		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & GFP_DMA)) {
-		int i = kmalloc_index(size);
+		unsigned int i = kmalloc_index(size);
 
 		if (!i)
 			return ZERO_SIZE_PTR;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
