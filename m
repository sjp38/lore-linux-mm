Message-ID: <3D73AF73.C8FE455@zip.com.au>
Date: Mon, 02 Sep 2002 11:35:31 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: slablru for 2.5.32-mm1
References: <200208261809.45568.tomlins@cam.org> <200208281306.58776.tomlins@cam.org> <3D72F675.920DC976@zip.com.au> <200209021100.47508.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> On September 2, 2002 01:26 am, Andrew Morton wrote:
> > Ed, this code can be sped up a bit, I think.  We can make
> > kmem_count_page() return a boolean back to shrink_cache(), telling it
> > whether it needs to call kmem_do_prunes() at all.  Often, there won't
> > be any work to do in there, and taking that semaphore can be quite
> > costly.
> >
> > The code as-is will even run kmem_do_prunes() when we're examining
> > ZONE_HIGHMEM, which certainly won't have any slab pages.  This boolean
> > will fix that too.
> 
> How about this?  I have modified things so we only try for the sem if there
> is work to do.  It also always uses a down_trylock - if we cannot do the prune
> now later is ok too...
> 

well...   Using a global like that is a bit un-linuxy.  (bitops
are only defined on longs, btw...)

How about this one?  It does both:  tells the caller whether or
not to perform the shrink, and defers the pruning until we
have at least a page's worth of objects to be pruned.

Also, make sure that only the CPU which was responsible for
the transition-past-threshold is told to do some pruning.  Reduces
the possibility of two CPUs running the prune.

Also, when we make the sweep across the to-be-pruned caches, only
prune the ones which are over threshold.

Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=396, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=66, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=429, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=66, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=264, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=198, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=66, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=429, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=66, gfp_mask=464) at dcache.c:585
Breakpoint 1, age_dcache_memory (cachep=0xc189f66c, entries=66, gfp_mask=464) at dcache.c:585

It'll make things a bit lumpier.  Under high internal fragmentation
we'll suddenly release great gobs of pages, but I think it'll average
out OK.

What sayest thou?

 include/linux/slab.h |    2 +-
 mm/slab.c            |   23 +++++++++++++++++++----
 mm/vmscan.c          |   22 ++++++++++++----------
 3 files changed, 32 insertions(+), 15 deletions(-)

--- 2.5.33/mm/vmscan.c~slablru-speedup	Mon Sep  2 11:07:33 2002
+++ 2.5.33-akpm/mm/vmscan.c	Mon Sep  2 11:07:33 2002
@@ -95,8 +95,8 @@ static inline int is_page_cache_freeable
 }
 
 static /* inline */ int
-shrink_list(struct list_head *page_list, int nr_pages,
-		unsigned int gfp_mask, int priority, int *max_scan)
+shrink_list(struct list_head *page_list, int nr_pages, unsigned int gfp_mask,
+		int priority, int *max_scan, int *prunes_needed)
 {
 	struct address_space *mapping;
 	LIST_HEAD(ret_pages);
@@ -124,7 +124,7 @@ shrink_list(struct list_head *page_list,
 		 */
 		if (PageSlab(page)) {
 			int ref = TestClearPageReferenced(page);
-			if (kmem_count_page(page, ref)) {
+			if (kmem_count_page(page, ref, prunes_needed)) {
 				if (kmem_shrink_slab(page))
 					goto free_ref;
 			}
@@ -292,8 +292,8 @@ keep:
  * in the kernel (apart from the copy_*_user functions).
  */
 static /* inline */ int
-shrink_cache(int nr_pages, struct zone *zone,
-		unsigned int gfp_mask, int priority, int max_scan)
+shrink_cache(int nr_pages, struct zone *zone, unsigned int gfp_mask,
+		int priority, int max_scan, int *prunes_needed)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -342,8 +342,8 @@ shrink_cache(int nr_pages, struct zone *
 
 		max_scan -= n;
 		KERNEL_STAT_ADD(pgscan, n);
-		nr_pages = shrink_list(&page_list, nr_pages,
-					gfp_mask, priority, &max_scan);
+		nr_pages = shrink_list(&page_list, nr_pages, gfp_mask,
+					priority, &max_scan, prunes_needed);
 
 		if (nr_pages <= 0 && list_empty(&page_list))
 			goto done;
@@ -489,6 +489,7 @@ shrink_zone(struct zone *zone, int prior
 {
 	unsigned long ratio;
 	int max_scan;
+	int prunes_needed = 0;
 
 	/*
 	 * Try to keep the active list 2/3 of the size of the cache.  And
@@ -509,9 +510,10 @@ shrink_zone(struct zone *zone, int prior
 	}
 
 	max_scan = zone->nr_inactive / priority;
-	nr_pages = shrink_cache(nr_pages, zone,
-				gfp_mask, priority, max_scan);
-	kmem_do_prunes(gfp_mask);
+	nr_pages = shrink_cache(nr_pages, zone, gfp_mask,
+				priority, max_scan, &prunes_needed);
+	if (prunes_needed)
+		kmem_do_prunes(gfp_mask);
 
 	if (nr_pages <= 0)
 		return 0;
--- 2.5.33/mm/slab.c~slablru-speedup	Mon Sep  2 11:07:33 2002
+++ 2.5.33-akpm/mm/slab.c	Mon Sep  2 11:30:27 2002
@@ -217,7 +217,8 @@ struct kmem_cache_s {
 	unsigned int		growing;
 	unsigned int		dflags;		/* dynamic flags */
 	kmem_pruner_t		pruner;		/* shrink callback */
-	int 			count;		/* count used to trigger shrink */
+	int 			count;		/* nr of objects to be pruned */
+	int			prune_thresh;	/* threshold triggers pruning */
 
 	/* constructor func */
 	void (*ctor)(void *, kmem_cache_t *, unsigned long);
@@ -418,8 +419,11 @@ static void enable_all_cpucaches (void);
  
 /* 
  * Used by shrink_cache to determine caches that need pruning.
+ *
+ * If this particular call to kmem_count_page takes a slab over its to-be-pruned
+ * threshold then we tell the caller that kmem_do_prunes() needs to be called.
  */
-int kmem_count_page(struct page *page, int ref)
+int kmem_count_page(struct page *page, int ref, int *prunes_needed)
 {
 	kmem_cache_t *cachep = GET_PAGE_CACHE(page);
 	slab_t *slabp = GET_PAGE_SLAB(page);
@@ -427,7 +431,12 @@ int kmem_count_page(struct page *page, i
 
 	spin_lock_irq(&cachep->spinlock);
 	if (cachep->pruner != NULL) {
+		int old_count = cachep->count;
+
 		cachep->count += slabp->inuse;
+		if (old_count < cachep->prune_thresh &&
+				cachep->count >= cachep->prune_thresh)
+			*prunes_needed = 1;
 		ret = !slabp->inuse;
 	} else {
 		ret = !ref && !slabp->inuse;
@@ -453,8 +462,11 @@ int kmem_do_prunes(int gfp_mask) 
                 kmem_cache_t *cachep = list_entry(p, kmem_cache_t, next);
 		if (cachep->pruner != NULL) {
 			spin_lock_irq(&cachep->spinlock);
-			nr = cachep->count;
-			cachep->count = 0;
+			nr = 0;
+			if (cachep->count >= cachep->prune_thresh) {
+				nr = cachep->count;
+				cachep->count = 0;
+			}
 			spin_unlock_irq(&cachep->spinlock);
 			if (nr > 0)
 				(*cachep->pruner)(cachep, nr, gfp_mask);
@@ -872,6 +884,9 @@ next:
 	cachep->flags = flags;
 	cachep->pruner = thepruner;
 	cachep->count = 0;
+	cachep->prune_thresh = 0;
+	if (thepruner)
+		cachep->prune_thresh = PAGE_SIZE / size;
 	cachep->gfpflags = 0;
 	if (flags & SLAB_CACHE_DMA)
 		cachep->gfpflags |= GFP_DMA;
--- 2.5.33/include/linux/slab.h~slablru-speedup	Mon Sep  2 11:07:33 2002
+++ 2.5.33-akpm/include/linux/slab.h	Mon Sep  2 11:07:33 2002
@@ -60,7 +60,7 @@ extern int kmem_cache_destroy(kmem_cache
 extern int kmem_cache_shrink(kmem_cache_t *);
 
 extern int kmem_do_prunes(int);
-extern int kmem_count_page(struct page *, int);
+extern int kmem_count_page(struct page *page, int ref, int *prunes_needed);
 #define kmem_touch_page(addr)	SetPageReferenced(virt_to_page(addr));
 
 /* shrink a slab */

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
