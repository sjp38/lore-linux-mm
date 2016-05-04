Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 977466B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 13:28:12 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so81576625pac.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 10:28:12 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id w127si5792920pfb.38.2016.05.04.10.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 10:28:11 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id xk12so26521470pac.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 10:28:11 -0700 (PDT)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] mm: slab: remove ZONE_DMA_FLAG
Date: Wed,  4 May 2016 10:01:37 -0700
Message-Id: <1462381297-11009-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

Now we have IS_ENABLED helper to check if a Kconfig option is enabled or not,
so ZONE_DMA_FLAG sounds no longer useful.

And, the use of ZONE_DMA_FLAG in slab looks pointless according to the
comment [1] from Johannes Weiner, so remove them and ORing passed in flags with
the cache gfp flags has been done in kmem_getpages().

[1] https://lkml.org/lkml/2014/9/25/553

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
Found the problem when I was reading the slab code for investigating another
issue, and found a similar fix has been sent to review in 2014, but it didn't
get merged into upstream. Rework the patch to adopt the comment from
Johannes Weiner.

 mm/Kconfig |  5 -----
 mm/slab.c  | 24 +-----------------------
 2 files changed, 1 insertion(+), 28 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 989f8f3..d6e9042 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -268,11 +268,6 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
-config ZONE_DMA_FLAG
-	int
-	default "0" if !ZONE_DMA
-	default "1"
-
 config BOUNCE
 	bool "Enable bounce buffers"
 	default y
diff --git a/mm/slab.c b/mm/slab.c
index 17e2848..3bcae12 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2138,7 +2138,7 @@ done:
 	cachep->freelist_size = cachep->num * sizeof(freelist_idx_t);
 	cachep->flags = flags;
 	cachep->allocflags = __GFP_COMP;
-	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
+	if (flags & SLAB_CACHE_DMA)
 		cachep->allocflags |= GFP_DMA;
 	cachep->size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
@@ -2438,16 +2438,6 @@ static void cache_init_objs(struct kmem_cache *cachep,
 	}
 }
 
-static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
-{
-	if (CONFIG_ZONE_DMA_FLAG) {
-		if (flags & GFP_DMA)
-			BUG_ON(!(cachep->allocflags & GFP_DMA));
-		else
-			BUG_ON(cachep->allocflags & GFP_DMA);
-	}
-}
-
 static void *slab_get_obj(struct kmem_cache *cachep, struct page *page)
 {
 	void *objp;
@@ -2538,14 +2528,6 @@ static int cache_grow(struct kmem_cache *cachep,
 		local_irq_enable();
 
 	/*
-	 * The test for missing atomic flag is performed here, rather than
-	 * the more obvious place, simply to reduce the critical path length
-	 * in kmem_cache_alloc(). If a caller is seriously mis-behaving they
-	 * will eventually be caught here (where it matters).
-	 */
-	kmem_flagcheck(cachep, flags);
-
-	/*
 	 * Get mem for the objs.  Attempt to allocate a physical page from
 	 * 'nodeid'.
 	 */
@@ -2884,9 +2866,6 @@ static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
 						gfp_t flags)
 {
 	might_sleep_if(gfpflags_allow_blocking(flags));
-#if DEBUG
-	kmem_flagcheck(cachep, flags);
-#endif
 }
 
 #if DEBUG
@@ -3044,7 +3023,6 @@ retry:
 
 		if (gfpflags_allow_blocking(local_flags))
 			local_irq_enable();
-		kmem_flagcheck(cache, flags);
 		page = kmem_getpages(cache, local_flags, numa_mem_id());
 		if (gfpflags_allow_blocking(local_flags))
 			local_irq_disable();
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
