Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 035D8600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 13:03:17 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 030A282C7DD
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 13:49:43 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fOqyW4pJaHX2 for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 13:49:42 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 837CB82C7E5
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 13:49:32 -0400 (EDT)
Message-Id: <20091001174122.602309040@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:49 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 16/19] SLUB: Get rid of dynamic DMA kmalloc cache allocation
Content-Disposition: inline; filename=this_cpu_slub_static_dma_kmalloc
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Dynamic DMA kmalloc cache allocation is troublesome since the
new percpu allocator does not support allocations in atomic contexts.
Reserve some statically allocated kmalloc_cpu structures instead.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/slub_def.h |   19 +++++++++++--------
 mm/slub.c                |   24 ++++++++++--------------
 2 files changed, 21 insertions(+), 22 deletions(-)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2009-09-29 11:42:06.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2009-09-29 11:43:18.000000000 -0500
@@ -131,11 +131,21 @@ struct kmem_cache {
 
 #define SLUB_PAGE_SHIFT (PAGE_SHIFT + 2)
 
+#ifdef CONFIG_ZONE_DMA
+#define SLUB_DMA __GFP_DMA
+/* Reserve extra caches for potential DMA use */
+#define KMALLOC_CACHES (2 * SLUB_PAGE_SHIFT - 6)
+#else
+/* Disable DMA functionality */
+#define SLUB_DMA (__force gfp_t)0
+#define KMALLOC_CACHES SLUB_PAGE_SHIFT
+#endif
+
 /*
  * We keep the general caches in an array of slab caches that are used for
  * 2^x bytes of allocations.
  */
-extern struct kmem_cache kmalloc_caches[SLUB_PAGE_SHIFT];
+extern struct kmem_cache kmalloc_caches[KMALLOC_CACHES];
 
 /*
  * Sorry that the following has to be that ugly but some versions of GCC
@@ -203,13 +213,6 @@ static __always_inline struct kmem_cache
 	return &kmalloc_caches[index];
 }
 
-#ifdef CONFIG_ZONE_DMA
-#define SLUB_DMA __GFP_DMA
-#else
-/* Disable DMA functionality */
-#define SLUB_DMA (__force gfp_t)0
-#endif
-
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
 void *__kmalloc(size_t size, gfp_t flags);
 
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2009-09-29 11:42:06.000000000 -0500
+++ linux-2.6/mm/slub.c	2009-09-29 11:43:18.000000000 -0500
@@ -2090,7 +2090,7 @@ static inline int alloc_kmem_cache_cpus(
 {
 	int cpu;
 
-	if (s < kmalloc_caches + SLUB_PAGE_SHIFT && s >= kmalloc_caches)
+	if (s < kmalloc_caches + KMALLOC_CACHES && s >= kmalloc_caches)
 		/*
 		 * Boot time creation of the kmalloc array. Use static per cpu data
 		 * since the per cpu allocator is not available yet.
@@ -2537,7 +2537,7 @@ EXPORT_SYMBOL(kmem_cache_destroy);
  *		Kmalloc subsystem
  *******************************************************************/
 
-struct kmem_cache kmalloc_caches[SLUB_PAGE_SHIFT] __cacheline_aligned;
+struct kmem_cache kmalloc_caches[KMALLOC_CACHES] __cacheline_aligned;
 EXPORT_SYMBOL(kmalloc_caches);
 
 static int __init setup_slub_min_order(char *str)
@@ -2627,6 +2627,7 @@ static noinline struct kmem_cache *dma_k
 	char *text;
 	size_t realsize;
 	unsigned long slabflags;
+	int i;
 
 	s = kmalloc_caches_dma[index];
 	if (s)
@@ -2647,18 +2648,13 @@ static noinline struct kmem_cache *dma_k
 	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
 			 (unsigned int)realsize);
 
-	if (flags & __GFP_WAIT)
-		s = kmalloc(kmem_size, flags & ~SLUB_DMA);
-	else {
-		int i;
+	s = NULL;
+	for (i = 0; i < KMALLOC_CACHES; i++)
+		if (kmalloc_caches[i].size)
+			break;
 
-		s = NULL;
-		for (i = 0; i < SLUB_PAGE_SHIFT; i++)
-			if (kmalloc_caches[i].size) {
-				s = kmalloc_caches + i;
-				break;
-			}
-	}
+	BUG_ON(i >= KMALLOC_CACHES);
+	s = kmalloc_caches + i;
 
 	/*
 	 * Must defer sysfs creation to a workqueue because we don't know
@@ -2672,7 +2668,7 @@ static noinline struct kmem_cache *dma_k
 
 	if (!s || !text || !kmem_cache_open(s, flags, text,
 			realsize, ARCH_KMALLOC_MINALIGN, slabflags, NULL)) {
-		kfree(s);
+		s->size = 0;
 		kfree(text);
 		goto unlock_out;
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
