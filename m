Date: Mon, 11 Feb 2008 08:18:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-ID: <20080211071828.GD8717@wotan.suse.de>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com> <20080209143518.ced71a48.akpm@linux-foundation.org> <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com> <20080210024517.GA32721@wotan.suse.de> <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 09, 2008 at 07:39:17PM -0800, Christoph Lameter wrote:
> On Sun, 10 Feb 2008, Nick Piggin wrote:
> 
> > What kind of allocating and freeing of pages are you talking about? Are
> > you just measuring single threaded performance?
> 
> What I did was (on an 8p, may want to tune this to the # procs you have):
> 
> 1. Run tbench_srv on console
> 
> 2. run tbench 8 from an ssh session

OK, it's a bit variable, so I used 20 10 second runs and took the average.
With this patch, I got a 1% increase of that average (with 2.6.25-rc1 and
slub).

It avoids some branches and tests; doesn't check the watermarks if there
are pcp pages; avoids atomic refcounting operations in the caller requests
it (this is really annoying because it adds another branch -- I don't think
we should be funneling all these options through flags, rather provide a
few helpers or something for it).

I don't know if this will get back all the regression, but it should help
(although I guess we should do the same refcounting for slab, so that
might speed up a bit too).

BTW. could you please make kmalloc-2048 just use order-0 allocations by
default, like kmalloc-1024 and kmalloc-4096, and kmalloc-2048 with slub.

Thanks,
Nick

---
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2008-02-11 10:06:36.000000000 +1100
+++ linux-2.6/include/linux/gfp.h	2008-02-11 11:08:00.000000000 +1100
@@ -50,8 +50,9 @@
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)0x80000u) /* Page is reclaimable */
 #define __GFP_MOVABLE	((__force gfp_t)0x100000u)  /* Page is movable */
+#define __GFP_NOREFS	((__force gfp_t)0x200000u)  /* Page is not refcounted */
 
-#define __GFP_BITS_SHIFT 21	/* Room for 21 __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 24	/* Room for 24 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
@@ -218,6 +219,7 @@
 #define __get_dma_pages(gfp_mask, order) \
 		__get_free_pages((gfp_mask) | GFP_DMA,(order))
 
+extern void FASTCALL(__free_pages_noref(struct page *page, unsigned int order));
 extern void FASTCALL(__free_pages(struct page *page, unsigned int order));
 extern void FASTCALL(free_pages(unsigned long addr, unsigned int order));
 extern void FASTCALL(free_hot_page(struct page *page));
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2008-02-11 10:06:36.000000000 +1100
+++ linux-2.6/mm/page_alloc.c	2008-02-11 11:08:00.000000000 +1100
@@ -449,7 +449,7 @@
 	zone->free_area[order].nr_free++;
 }
 
-static inline int free_pages_check(struct page *page)
+static inline void free_pages_check(struct page *page)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
@@ -467,12 +467,6 @@
 		bad_page(page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not free the page.  But we shall soon need
-	 * to do more, for when the ZERO_PAGE count wraps negative.
-	 */
-	return PageReserved(page);
 }
 
 /*
@@ -517,12 +511,9 @@
 {
 	unsigned long flags;
 	int i;
-	int reserved = 0;
 
 	for (i = 0 ; i < (1 << order) ; ++i)
-		reserved += free_pages_check(page + i);
-	if (reserved)
-		return;
+		free_pages_check(page + i);
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page),PAGE_SIZE<<order);
@@ -598,7 +589,7 @@
 /*
  * This page is about to be returned from the page allocator
  */
-static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
+static void prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
 	if (unlikely(page_mapcount(page) |
 		(page->mapping != NULL)  |
@@ -616,18 +607,12 @@
 			1 << PG_buddy ))))
 		bad_page(page);
 
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not allocate the page: as a safety net.
-	 */
-	if (PageReserved(page))
-		return 1;
-
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
 			1 << PG_referenced | 1 << PG_arch_1 |
 			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
 	set_page_private(page, 0);
-	set_page_refcounted(page);
+	if (!(gfp_flags & __GFP_NOREFS))
+		set_page_refcounted(page);
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
@@ -637,8 +622,6 @@
 
 	if (order && (gfp_flags & __GFP_COMP))
 		prep_compound_page(page, order);
-
-	return 0;
 }
 
 /*
@@ -983,8 +966,7 @@
 
 	if (PageAnon(page))
 		page->mapping = NULL;
-	if (free_pages_check(page))
-		return;
+	free_pages_check(page);
 
 	if (!PageHighMem(page))
 		debug_check_no_locks_freed(page_address(page), PAGE_SIZE);
@@ -1037,13 +1019,43 @@
 		set_page_refcounted(page + i);
 }
 
+#define ALLOC_NO_WATERMARKS	0x01 /* don't check watermarks at all */
+#define ALLOC_WMARK_MIN		0x02 /* use pages_min watermark */
+#define ALLOC_WMARK_LOW		0x04 /* use pages_low watermark */
+#define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
+#define ALLOC_HARDER		0x10 /* try to alloc harder */
+#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
+#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+
+static int alloc_watermarks_ok(struct zonelist *zonelist, struct zone *zone,
+			int order, gfp_t gfp_mask, int alloc_flags)
+{
+	int classzone_idx = zone_idx(zonelist->zones[0]);
+	if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
+		unsigned long mark;
+		if (alloc_flags & ALLOC_WMARK_MIN)
+			mark = zone->pages_min;
+		else if (alloc_flags & ALLOC_WMARK_LOW)
+			mark = zone->pages_low;
+		else
+			mark = zone->pages_high;
+		if (!zone_watermark_ok(zone, order, mark,
+			    classzone_idx, alloc_flags)) {
+			if (!zone_reclaim_mode ||
+			    !zone_reclaim(zone, gfp_mask, order))
+				return 0;
+		}
+	}
+	return 1;
+}
+
 /*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
  * or two.
  */
 static struct page *buffered_rmqueue(struct zonelist *zonelist,
-			struct zone *zone, int order, gfp_t gfp_flags)
+		struct zone *zone, int order, gfp_t gfp_flags, int alloc_flags)
 {
 	unsigned long flags;
 	struct page *page;
@@ -1051,14 +1063,15 @@
 	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
-again:
-	cpu  = get_cpu();
+	local_irq_save(flags);
 	if (likely(order == 0)) {
 		struct per_cpu_pages *pcp;
 
+		cpu  = smp_processor_id();
 		pcp = &zone_pcp(zone, cpu)->pcp;
-		local_irq_save(flags);
 		if (!pcp->count) {
+			if (!alloc_watermarks_ok(zonelist, zone, order, gfp_flags, alloc_flags))
+				goto failed;
 			pcp->count = rmqueue_bulk(zone, 0,
 					pcp->batch, &pcp->list, migratetype);
 			if (unlikely(!pcp->count))
@@ -1078,7 +1091,8 @@
 
 		/* Allocate more to the pcp list if necessary */
 		if (unlikely(&page->lru == &pcp->list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
+			if (alloc_watermarks_ok(zonelist, zone, order, gfp_flags, alloc_flags))
+				pcp->count += rmqueue_bulk(zone, 0,
 					pcp->batch, &pcp->list, migratetype);
 			page = list_entry(pcp->list.next, struct page, lru);
 		}
@@ -1086,7 +1100,9 @@
 		list_del(&page->lru);
 		pcp->count--;
 	} else {
-		spin_lock_irqsave(&zone->lock, flags);
+		if (!alloc_watermarks_ok(zonelist, zone, order, gfp_flags, alloc_flags))
+			goto failed;
+		spin_lock(&zone->lock);
 		page = __rmqueue(zone, order, migratetype);
 		spin_unlock(&zone->lock);
 		if (!page)
@@ -1096,27 +1112,16 @@
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(zonelist, zone);
 	local_irq_restore(flags);
-	put_cpu();
 
 	VM_BUG_ON(bad_range(zone, page));
-	if (prep_new_page(page, order, gfp_flags))
-		goto again;
+	prep_new_page(page, order, gfp_flags);
 	return page;
 
 failed:
 	local_irq_restore(flags);
-	put_cpu();
 	return NULL;
 }
 
-#define ALLOC_NO_WATERMARKS	0x01 /* don't check watermarks at all */
-#define ALLOC_WMARK_MIN		0x02 /* use pages_min watermark */
-#define ALLOC_WMARK_LOW		0x04 /* use pages_low watermark */
-#define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
-#define ALLOC_HARDER		0x10 /* try to alloc harder */
-#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
-#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
 static struct fail_page_alloc_attr {
@@ -1374,7 +1379,6 @@
 {
 	struct zone **z;
 	struct page *page = NULL;
-	int classzone_idx = zone_idx(zonelist->zones[0]);
 	struct zone *zone;
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
@@ -1409,26 +1413,10 @@
 			!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;
 
-		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
-			unsigned long mark;
-			if (alloc_flags & ALLOC_WMARK_MIN)
-				mark = zone->pages_min;
-			else if (alloc_flags & ALLOC_WMARK_LOW)
-				mark = zone->pages_low;
-			else
-				mark = zone->pages_high;
-			if (!zone_watermark_ok(zone, order, mark,
-				    classzone_idx, alloc_flags)) {
-				if (!zone_reclaim_mode ||
-				    !zone_reclaim(zone, gfp_mask, order))
-					goto this_zone_full;
-			}
-		}
-
-		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
+		page = buffered_rmqueue(zonelist, zone, order, gfp_mask, alloc_flags);
 		if (page)
 			break;
-this_zone_full:
+
 		if (NUMA_BUILD)
 			zlc_mark_zone_full(zonelist, z);
 try_next_zone:
@@ -1669,7 +1657,6 @@
 		return (unsigned long) page_address(page);
 	return 0;
 }
-
 EXPORT_SYMBOL(get_zeroed_page);
 
 void __pagevec_free(struct pagevec *pvec)
@@ -1680,16 +1667,20 @@
 		free_hot_cold_page(pvec->pages[i], pvec->cold);
 }
 
-void __free_pages(struct page *page, unsigned int order)
+void __free_pages_noref(struct page *page, unsigned int order)
 {
-	if (put_page_testzero(page)) {
-		if (order == 0)
-			free_hot_page(page);
-		else
-			__free_pages_ok(page, order);
-	}
+	if (likely(order == 0))
+		free_hot_page(page);
+	else
+		__free_pages_ok(page, order);
 }
+EXPORT_SYMBOL(__free_pages_noref);
 
+void __free_pages(struct page *page, unsigned int order)
+{
+	if (put_page_testzero(page))
+		__free_pages_noref(page, order);
+}
 EXPORT_SYMBOL(__free_pages);
 
 void free_pages(unsigned long addr, unsigned int order)
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-11 10:06:36.000000000 +1100
+++ linux-2.6/mm/slub.c	2008-02-11 11:08:00.000000000 +1100
@@ -1078,6 +1078,7 @@
 	struct page *page;
 	int pages = 1 << s->order;
 
+	flags |= __GFP_NOREFS;
 	if (s->order)
 		flags |= __GFP_COMP;
 
@@ -1175,7 +1176,7 @@
 		-pages);
 
 	page->mapping = NULL;
-	__free_pages(page, s->order);
+	__free_pages_noref(page, s->order);
 }
 
 static void rcu_free_slab(struct rcu_head *h)
@@ -2671,7 +2672,7 @@
 	struct kmem_cache *s;
 
 	if (unlikely(size > PAGE_SIZE / 2))
-		return (void *)__get_free_pages(flags | __GFP_COMP,
+		return (void *)__get_free_pages(flags | __GFP_COMP | __GFP_NOREFS,
 							get_order(size));
 
 	s = get_slab(size, flags);
@@ -2689,7 +2690,7 @@
 	struct kmem_cache *s;
 
 	if (unlikely(size > PAGE_SIZE / 2))
-		return (void *)__get_free_pages(flags | __GFP_COMP,
+		return (void *)__get_free_pages(flags | __GFP_COMP | __GFP_NOREFS,
 							get_order(size));
 
 	s = get_slab(size, flags);
@@ -2752,7 +2753,10 @@
 
 	page = virt_to_head_page(x);
 	if (unlikely(!PageSlab(page))) {
-		put_page(page);
+		unsigned int order = 0;
+		if (unlikely(PageCompound(page)))
+			order = compound_order(page);
+		__free_pages_noref(page, order);
 		return;
 	}
 	slab_free(page->slab, page, object, __builtin_return_address(0));
@@ -3219,7 +3223,7 @@
 	struct kmem_cache *s;
 
 	if (unlikely(size > PAGE_SIZE / 2))
-		return (void *)__get_free_pages(gfpflags | __GFP_COMP,
+		return (void *)__get_free_pages(gfpflags | __GFP_COMP | __GFP_NOREFS,
 							get_order(size));
 	s = get_slab(size, gfpflags);
 
@@ -3235,7 +3239,7 @@
 	struct kmem_cache *s;
 
 	if (unlikely(size > PAGE_SIZE / 2))
-		return (void *)__get_free_pages(gfpflags | __GFP_COMP,
+		return (void *)__get_free_pages(gfpflags | __GFP_COMP | __GFP_NOREFS,
 							get_order(size));
 	s = get_slab(size, gfpflags);
 
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2008-02-11 10:06:36.000000000 +1100
+++ linux-2.6/include/linux/slub_def.h	2008-02-11 11:08:00.000000000 +1100
@@ -192,7 +192,7 @@
 {
 	if (__builtin_constant_p(size)) {
 		if (size > PAGE_SIZE / 2)
-			return (void *)__get_free_pages(flags | __GFP_COMP,
+			return (void *)__get_free_pages(flags | __GFP_COMP | __GFP_NOREFS,
 							get_order(size));
 
 		if (!(flags & SLUB_DMA)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
