Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 469DB6B00D5
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 08:44:07 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id z10so14619729pdj.1
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 05:44:07 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id hf4si13524476pac.80.2014.11.13.05.44.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 05:44:05 -0800 (PST)
Subject: [PATCH] drm/ttm: Avoid memory allocation from shrinker functions.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141111170243.c24ce5fdb5efaf0814071847@linux-foundation.org>
	<20141112012244.GA21576@js1304-P5Q-DELUXE>
	<20141111174412.ba0ac86f.akpm@linux-foundation.org>
	<201411120408.sAC48tTa029031@www262.sakura.ne.jp>
	<20141111203859.3c578f5d.akpm@linux-foundation.org>
In-Reply-To: <20141111203859.3c578f5d.akpm@linux-foundation.org>
Message-Id: <201411132243.IJE39049.OtFFVLSMOFHQOJ@I-love.SAKURA.ne.jp>
Date: Thu, 13 Nov 2014 22:43:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: luke@dashjr.org, cl@linux.com, ming.lei@canonical.com, penberg@kernel.org, rientjes@google.com, mel@csn.ul.ie, hannes@cmpxchg.org, suokkos@gmail.com, airlied@linux.ie, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com

Andrew Morton wrote:
> On Wed, 12 Nov 2014 13:08:55 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> 
> > Andrew Morton wrote:
> > > Poor ttm guys - this is a bit of a trap we set for them.
> > 
> > Commit a91576d7916f6cce ("drm/ttm: Pass GFP flags in order to avoid deadlock.")
> > changed to use sc->gfp_mask rather than GFP_KERNEL.
> > 
> > -       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
> > -                       GFP_KERNEL);
> > +       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
> > 
> > But this bug is caused by sc->gfp_mask containing some flags which are not
> > in GFP_KERNEL, right? Then, I think
> > 
> > -       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
> > +       pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp & GFP_KERNEL);
> > 
> > would hide this bug.
> > 
> > But I think we should use GFP_ATOMIC (or drop __GFP_WAIT flag)
> 
> Well no - ttm_page_pool_free() should stop calling kmalloc altogether. 
> Just do
> 
> 	struct page *pages_to_free[16];
> 
> and rework the code to free 16 pages at a time.  Easy.

Well, ttm code wants to process 512 pages at a time for performance.
Memory footprint increased by 512 * sizeof(struct page *) buffer is
only 4096 bytes. What about using static buffer like below?
----------
>From d3cb5393c9c8099d6b37e769f78c31af1541fe8c Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 13 Nov 2014 22:21:54 +0900
Subject: [PATCH] drm/ttm: Avoid memory allocation from shrinker functions.

Commit a91576d7916f6cce ("drm/ttm: Pass GFP flags in order to avoid
deadlock.") caused BUG_ON() due to sc->gfp_mask containing flags
which are not in GFP_KERNEL.

  https://bugzilla.kernel.org/show_bug.cgi?id=87891

Changing from sc->gfp_mask to (sc->gfp_mask & GFP_KERNEL) would
avoid the BUG_ON(), but avoiding memory allocation from shrinker
function is better and reliable fix.

Shrinker function is already serialized by global lock, and
clean up function is called after shrinker function is unregistered.
Thus, we can use static buffer when called from shrinker function
and clean up function.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [2.6.35+]
---
 drivers/gpu/drm/ttm/ttm_page_alloc.c     | 26 +++++++++++++++-----------
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c | 25 +++++++++++++++----------
 2 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
index 09874d6..025c429 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -297,11 +297,12 @@ static void ttm_pool_update_free_locked(struct ttm_page_pool *pool,
  *
  * @pool: to free the pages from
  * @free_all: If set to true will free all pages in pool
- * @gfp: GFP flags.
+ * @use_static: Safe to use static buffer
  **/
 static int ttm_page_pool_free(struct ttm_page_pool *pool, unsigned nr_free,
-			      gfp_t gfp)
+			      bool use_static)
 {
+	static struct page *static_buf[NUM_PAGES_TO_ALLOC];
 	unsigned long irq_flags;
 	struct page *p;
 	struct page **pages_to_free;
@@ -311,7 +312,11 @@ static int ttm_page_pool_free(struct ttm_page_pool *pool, unsigned nr_free,
 	if (NUM_PAGES_TO_ALLOC < nr_free)
 		npages_to_free = NUM_PAGES_TO_ALLOC;
 
-	pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
+	if (use_static)
+		pages_to_free = static_buf;
+	else
+		pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
+					GFP_KERNEL);
 	if (!pages_to_free) {
 		pr_err("Failed to allocate memory for pool free operation\n");
 		return 0;
@@ -374,7 +379,8 @@ restart:
 	if (freed_pages)
 		ttm_pages_put(pages_to_free, freed_pages);
 out:
-	kfree(pages_to_free);
+	if (pages_to_free != static_buf)
+		kfree(pages_to_free);
 	return nr_free;
 }
 
@@ -383,8 +389,6 @@ out:
  *
  * XXX: (dchinner) Deadlock warning!
  *
- * We need to pass sc->gfp_mask to ttm_page_pool_free().
- *
  * This code is crying out for a shrinker per pool....
  */
 static unsigned long
@@ -407,8 +411,8 @@ ttm_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		if (shrink_pages == 0)
 			break;
 		pool = &_manager->pools[(i + pool_offset)%NUM_POOLS];
-		shrink_pages = ttm_page_pool_free(pool, nr_free,
-						  sc->gfp_mask);
+		/* OK to use static buffer since global mutex is held. */
+		shrink_pages = ttm_page_pool_free(pool, nr_free, true);
 		freed += nr_free - shrink_pages;
 	}
 	mutex_unlock(&lock);
@@ -710,7 +714,7 @@ static void ttm_put_pages(struct page **pages, unsigned npages, int flags,
 	}
 	spin_unlock_irqrestore(&pool->lock, irq_flags);
 	if (npages)
-		ttm_page_pool_free(pool, npages, GFP_KERNEL);
+		ttm_page_pool_free(pool, npages, false);
 }
 
 /*
@@ -849,9 +853,9 @@ void ttm_page_alloc_fini(void)
 	pr_info("Finalizing pool allocator\n");
 	ttm_pool_mm_shrink_fini(_manager);
 
+	/* OK to use static buffer since global mutex is no longer used. */
 	for (i = 0; i < NUM_POOLS; ++i)
-		ttm_page_pool_free(&_manager->pools[i], FREE_ALL_PAGES,
-				   GFP_KERNEL);
+		ttm_page_pool_free(&_manager->pools[i], FREE_ALL_PAGES, true);
 
 	kobject_put(&_manager->kobj);
 	_manager = NULL;
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
index c96db43..01e1d27 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
@@ -411,11 +411,12 @@ static void ttm_dma_page_put(struct dma_pool *pool, struct dma_page *d_page)
  *
  * @pool: to free the pages from
  * @nr_free: If set to true will free all pages in pool
- * @gfp: GFP flags.
+ * @use_static: Safe to use static buffer
  **/
 static unsigned ttm_dma_page_pool_free(struct dma_pool *pool, unsigned nr_free,
-				       gfp_t gfp)
+				       bool use_static)
 {
+	static struct page *static_buf[NUM_PAGES_TO_ALLOC];
 	unsigned long irq_flags;
 	struct dma_page *dma_p, *tmp;
 	struct page **pages_to_free;
@@ -432,7 +433,11 @@ static unsigned ttm_dma_page_pool_free(struct dma_pool *pool, unsigned nr_free,
 			 npages_to_free, nr_free);
 	}
 #endif
-	pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
+	if (use_static)
+		pages_to_free = static_buf;
+	else
+		pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
+					GFP_KERNEL);
 
 	if (!pages_to_free) {
 		pr_err("%s: Failed to allocate memory for pool free operation\n",
@@ -502,7 +507,8 @@ restart:
 	if (freed_pages)
 		ttm_dma_pages_put(pool, &d_pages, pages_to_free, freed_pages);
 out:
-	kfree(pages_to_free);
+	if (pages_to_free != static_buf)
+		kfree(pages_to_free);
 	return nr_free;
 }
 
@@ -531,7 +537,8 @@ static void ttm_dma_free_pool(struct device *dev, enum pool_type type)
 		if (pool->type != type)
 			continue;
 		/* Takes a spinlock.. */
-		ttm_dma_page_pool_free(pool, FREE_ALL_PAGES, GFP_KERNEL);
+		/* OK to use static buffer since global mutex is held. */
+		ttm_dma_page_pool_free(pool, FREE_ALL_PAGES, true);
 		WARN_ON(((pool->npages_in_use + pool->npages_free) != 0));
 		/* This code path is called after _all_ references to the
 		 * struct device has been dropped - so nobody should be
@@ -986,7 +993,7 @@ void ttm_dma_unpopulate(struct ttm_dma_tt *ttm_dma, struct device *dev)
 
 	/* shrink pool if necessary (only on !is_cached pools)*/
 	if (npages)
-		ttm_dma_page_pool_free(pool, npages, GFP_KERNEL);
+		ttm_dma_page_pool_free(pool, npages, false);
 	ttm->state = tt_unpopulated;
 }
 EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
@@ -996,8 +1003,6 @@ EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
  *
  * XXX: (dchinner) Deadlock warning!
  *
- * We need to pass sc->gfp_mask to ttm_dma_page_pool_free().
- *
  * I'm getting sadder as I hear more pathetical whimpers about needing per-pool
  * shrinkers
  */
@@ -1030,8 +1035,8 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		if (++idx < pool_offset)
 			continue;
 		nr_free = shrink_pages;
-		shrink_pages = ttm_dma_page_pool_free(p->pool, nr_free,
-						      sc->gfp_mask);
+		/* OK to use static buffer since global mutex is held. */
+		shrink_pages = ttm_dma_page_pool_free(p->pool, nr_free, true);
 		freed += nr_free - shrink_pages;
 
 		pr_debug("%s: (%s:%d) Asked to shrink %d, have %d more to go\n",
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
