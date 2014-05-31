From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 5/5] gpu/drm/ttm: Pass GFP flags in order to avoid deadlock.
Date: Sat, 31 May 2014 12:02:19 +0900
Message-ID: <201405311202.FJB95834.FOVtMQSFOLJFHO@I-love.SAKURA.ne.jp>
References: <20140530160824.GD3621@localhost.localdomain>
	<201405311158.DGE64002.QLOOHJSFFMVFOt@I-love.SAKURA.ne.jp>
	<201405311159.CHG64048.SOFLQHVtFOMFJO@I-love.SAKURA.ne.jp>
	<201405311200.III57894.MLFOOFStQVHJFO@I-love.SAKURA.ne.jp>
	<201405311201.FEG92893.FQSJOFFVOLOtHM@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201405311201.FEG92893.FQSJOFFVOLOtHM@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
To: konrad.wilk@oracle.com
Cc: dchinner@redhat.com, airlied@linux.ie, glommer@openvz.org, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, penguin-kernel@I-love.SAKURA.ne.jp
List-Id: linux-mm.kvack.org

>From 357d4ba36284eee4c2a99085450a9039735767c6 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 31 May 2014 10:22:17 +0900
Subject: [PATCH 5/5] gpu/drm/ttm: Pass GFP flags in order to avoid deadlock.

Commit 7dc19d5a "drivers: convert shrinkers to new count/scan API" added
deadlock warnings that ttm_page_pool_free() and ttm_dma_page_pool_free()
are currently doing GFP_KERNEL allocation.

But these functions did not get updated to receive gfp_t argument.
This patch explicitly passes sc->gfp_mask or GFP_KERNEL to these functions,
and removes the deadlock warning.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: stable <stable@kernel.org> [2.6.35+]
---
 drivers/gpu/drm/ttm/ttm_page_alloc.c     |   19 ++++++++++---------
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c |   19 +++++++++----------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc.c b/drivers/gpu/drm/ttm/ttm_page_alloc.c
index deba59b..cf4bad2 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc.c
@@ -297,8 +297,10 @@ static void ttm_pool_update_free_locked(struct ttm_page_pool *pool,
  *
  * @pool: to free the pages from
  * @free_all: If set to true will free all pages in pool
+ * @gfp: GFP flags.
  **/
-static int ttm_page_pool_free(struct ttm_page_pool *pool, unsigned nr_free)
+static int ttm_page_pool_free(struct ttm_page_pool *pool, unsigned nr_free,
+			      gfp_t gfp)
 {
 	unsigned long irq_flags;
 	struct page *p;
@@ -309,8 +311,7 @@ static int ttm_page_pool_free(struct ttm_page_pool *pool, unsigned nr_free)
 	if (NUM_PAGES_TO_ALLOC < nr_free)
 		npages_to_free = NUM_PAGES_TO_ALLOC;
 
-	pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
-			GFP_KERNEL);
+	pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
 	if (!pages_to_free) {
 		pr_err("Failed to allocate memory for pool free operation\n");
 		return 0;
@@ -382,9 +383,7 @@ out:
  *
  * XXX: (dchinner) Deadlock warning!
  *
- * ttm_page_pool_free() does memory allocation using GFP_KERNEL.  that means
- * this can deadlock when called a sc->gfp_mask that is not equal to
- * GFP_KERNEL.
+ * We need to pass sc->gfp_mask to ttm_page_pool_free().
  *
  * This code is crying out for a shrinker per pool....
  */
@@ -408,7 +407,8 @@ ttm_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		if (shrink_pages == 0)
 			break;
 		pool = &_manager->pools[(i + pool_offset)%NUM_POOLS];
-		shrink_pages = ttm_page_pool_free(pool, nr_free);
+		shrink_pages = ttm_page_pool_free(pool, nr_free,
+						  sc->gfp_mask);
 		freed += nr_free - shrink_pages;
 	}
 	mutex_unlock(&lock);
@@ -710,7 +710,7 @@ static void ttm_put_pages(struct page **pages, unsigned npages, int flags,
 	}
 	spin_unlock_irqrestore(&pool->lock, irq_flags);
 	if (npages)
-		ttm_page_pool_free(pool, npages);
+		ttm_page_pool_free(pool, npages, GFP_KERNEL);
 }
 
 /*
@@ -850,7 +850,8 @@ void ttm_page_alloc_fini(void)
 	ttm_pool_mm_shrink_fini(_manager);
 
 	for (i = 0; i < NUM_POOLS; ++i)
-		ttm_page_pool_free(&_manager->pools[i], FREE_ALL_PAGES);
+		ttm_page_pool_free(&_manager->pools[i], FREE_ALL_PAGES,
+				   GFP_KERNEL);
 
 	kobject_put(&_manager->kobj);
 	_manager = NULL;
diff --git a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
index 620da39..d008cf4 100644
--- a/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
+++ b/drivers/gpu/drm/ttm/ttm_page_alloc_dma.c
@@ -411,8 +411,10 @@ static void ttm_dma_page_put(struct dma_pool *pool, struct dma_page *d_page)
  *
  * @pool: to free the pages from
  * @nr_free: If set to true will free all pages in pool
+ * @gfp: GFP flags.
  **/
-static unsigned ttm_dma_page_pool_free(struct dma_pool *pool, unsigned nr_free)
+static unsigned ttm_dma_page_pool_free(struct dma_pool *pool, unsigned nr_free,
+				       gfp_t gfp)
 {
 	unsigned long irq_flags;
 	struct dma_page *dma_p, *tmp;
@@ -430,8 +432,7 @@ static unsigned ttm_dma_page_pool_free(struct dma_pool *pool, unsigned nr_free)
 			 npages_to_free, nr_free);
 	}
 #endif
-	pages_to_free = kmalloc(npages_to_free * sizeof(struct page *),
-			GFP_KERNEL);
+	pages_to_free = kmalloc(npages_to_free * sizeof(struct page *), gfp);
 
 	if (!pages_to_free) {
 		pr_err("%s: Failed to allocate memory for pool free operation\n",
@@ -530,7 +531,7 @@ static void ttm_dma_free_pool(struct device *dev, enum pool_type type)
 		if (pool->type != type)
 			continue;
 		/* Takes a spinlock.. */
-		ttm_dma_page_pool_free(pool, FREE_ALL_PAGES);
+		ttm_dma_page_pool_free(pool, FREE_ALL_PAGES, GFP_KERNEL);
 		WARN_ON(((pool->npages_in_use + pool->npages_free) != 0));
 		/* This code path is called after _all_ references to the
 		 * struct device has been dropped - so nobody should be
@@ -983,7 +984,7 @@ void ttm_dma_unpopulate(struct ttm_dma_tt *ttm_dma, struct device *dev)
 
 	/* shrink pool if necessary (only on !is_cached pools)*/
 	if (npages)
-		ttm_dma_page_pool_free(pool, npages);
+		ttm_dma_page_pool_free(pool, npages, GFP_KERNEL);
 	ttm->state = tt_unpopulated;
 }
 EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
@@ -993,10 +994,7 @@ EXPORT_SYMBOL_GPL(ttm_dma_unpopulate);
  *
  * XXX: (dchinner) Deadlock warning!
  *
- * ttm_dma_page_pool_free() does GFP_KERNEL memory allocation, and so attention
- * needs to be paid to sc->gfp_mask to determine if this can be done or not.
- * GFP_KERNEL memory allocation in a GFP_ATOMIC reclaim context woul dbe really
- * bad.
+ * We need to pass sc->gfp_mask to ttm_dma_page_pool_free().
  *
  * I'm getting sadder as I hear more pathetical whimpers about needing per-pool
  * shrinkers
@@ -1030,7 +1028,8 @@ ttm_dma_pool_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 		if (++idx < pool_offset)
 			continue;
 		nr_free = shrink_pages;
-		shrink_pages = ttm_dma_page_pool_free(p->pool, nr_free);
+		shrink_pages = ttm_dma_page_pool_free(p->pool, nr_free,
+						      sc->gfp_mask);
 		freed += nr_free - shrink_pages;
 
 		pr_debug("%s: (%s:%d) Asked to shrink %d, have %d more to go\n",
-- 
1.7.1
