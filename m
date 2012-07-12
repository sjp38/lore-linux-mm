Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 8B2746B0062
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 02:40:38 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/16] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve pages
Date: Thu, 12 Jul 2012 07:40:17 +0100
Message-Id: <1342075232-29267-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1342075232-29267-1-git-send-email-mgorman@suse.de>
References: <1342075232-29267-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Mel Gorman <mgorman@suse.de>

Allocations of pages below the min watermark run a risk of the
machine hanging due to a lack of memory. To prevent this, only
callers who have PF_MEMALLOC or TIF_MEMDIE set and are not processing
an interrupt are allowed to allocate with ALLOC_NO_WATERMARKS. Once
they are allocated to a slab though, nothing prevents other callers
consuming free objects within those slabs. This patch limits access
to slab pages that were alloced from the PFMEMALLOC reserves.

When this patch is applied, pages allocated from below the low watermark are
returned with page->pfmemalloc set and it is up to the caller to determine
how the page should be protected. SLAB restricts access to any page with
page->pfmemalloc set to callers which are known to able to access the
PFMEMALLOC reserve. If one is not available, an attempt is made to allocate
a new page rather than use a reserve. SLUB is a bit more relaxed in that
it only records if the current per-CPU page was allocated from PFMEMALLOC
reserve and uses another partial slab if the caller does not have the
necessary GFP or process flags. This was found to be sufficient in tests
to avoid hangs due to SLUB generally maintaining smaller lists than SLAB.

In low-memory conditions it does mean that !PFMEMALLOC allocators
can fail a slab allocation even though free objects are available
because they are being preserved for callers that are freeing pages.

[a.p.zijlstra@chello.nl: Original implementation]
[sebastian@breakpoint.cc: Correct order of page flag clearing]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h   |    9 +++
 include/linux/page-flags.h |   28 +++++++
 mm/internal.h              |    3 +
 mm/page_alloc.c            |   27 +++++--
 mm/slab.c                  |  192 +++++++++++++++++++++++++++++++++++++++-----
 mm/slub.c                  |   29 ++++++-
 6 files changed, 263 insertions(+), 25 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 27c741c..ad0ad6f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -54,6 +54,15 @@ struct page {
 		union {
 			pgoff_t index;		/* Our offset within mapping. */
 			void *freelist;		/* slub/slob first free object */
+			bool pfmemalloc;	/* If set by the page allocator,
+						 * ALLOC_PFMEMALLOC was set
+						 * and the low watermark was not
+						 * met implying that the system
+						 * is under some pressure. The
+						 * caller should try ensure
+						 * this page is only used to
+						 * free other pages.
+						 */
 		};
 
 		union {
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index c88d2a9..e66eb0d 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -453,6 +453,34 @@ static inline int PageTransTail(struct page *page)
 }
 #endif
 
+/*
+ * If network-based swap is enabled, sl*b must keep track of whether pages
+ * were allocated from pfmemalloc reserves.
+ */
+static inline int PageSlabPfmemalloc(struct page *page)
+{
+	VM_BUG_ON(!PageSlab(page));
+	return PageActive(page);
+}
+
+static inline void SetPageSlabPfmemalloc(struct page *page)
+{
+	VM_BUG_ON(!PageSlab(page));
+	SetPageActive(page);
+}
+
+static inline void __ClearPageSlabPfmemalloc(struct page *page)
+{
+	VM_BUG_ON(!PageSlab(page));
+	__ClearPageActive(page);
+}
+
+static inline void ClearPageSlabPfmemalloc(struct page *page)
+{
+	VM_BUG_ON(!PageSlab(page));
+	ClearPageActive(page);
+}
+
 #ifdef CONFIG_MMU
 #define __PG_MLOCKED		(1 << PG_mlocked)
 #else
diff --git a/mm/internal.h b/mm/internal.h
index 0b72461..93ea85b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -275,6 +275,9 @@ static inline struct page *mem_map_next(struct page *iter,
 #define __paginginit __init
 #endif
 
+/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
+bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
+
 /* Memory initialisation debug and verification */
 enum mminit_level {
 	MMINIT_WARNING,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d236e8c..e4e2bb0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1508,6 +1508,7 @@ failed:
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+#define ALLOC_PFMEMALLOC	0x80 /* Caller has PF_MEMALLOC set */
 
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
@@ -2265,16 +2266,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
-	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_interrupt() &&
-		    ((current->flags & PF_MEMALLOC) ||
-		     unlikely(test_thread_flag(TIF_MEMDIE))))
+	if ((current->flags & PF_MEMALLOC) ||
+			unlikely(test_thread_flag(TIF_MEMDIE))) {
+		alloc_flags |= ALLOC_PFMEMALLOC;
+
+		if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 
 	return alloc_flags;
 }
 
+bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
+{
+	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_PFMEMALLOC);
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -2462,10 +2469,18 @@ nopage:
 	warn_alloc_failed(gfp_mask, order, NULL);
 	return page;
 got_pg:
+	/*
+	 * page->pfmemalloc is set when the caller had PFMEMALLOC set or is
+	 * been OOM killed. The expectation is that the caller is taking
+	 * steps that will free more memory. The caller should avoid the
+	 * page being used for !PFMEMALLOC purposes.
+	 */
+	page->pfmemalloc = !!(alloc_flags & ALLOC_PFMEMALLOC);
+
 	if (kmemcheck_enabled)
 		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
-	return page;
 
+	return page;
 }
 
 /*
@@ -2516,6 +2531,8 @@ retry_cpuset:
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
+	else
+		page->pfmemalloc = false;
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 
diff --git a/mm/slab.c b/mm/slab.c
index 4eea480..85e6743 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -123,6 +123,8 @@
 
 #include <trace/events/kmem.h>
 
+#include	"internal.h"
+
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_RED_ZONE & SLAB_POISON.
  *		  0 for faster, smaller code (especially in the critical paths).
@@ -151,6 +153,12 @@
 #define ARCH_KMALLOC_FLAGS SLAB_HWCACHE_ALIGN
 #endif
 
+/*
+ * true if a page was allocated from pfmemalloc reserves for network-based
+ * swap
+ */
+static bool pfmemalloc_active __read_mostly;
+
 /* Legal flag mask for kmem_cache_create(). */
 #if DEBUG
 # define CREATE_MASK	(SLAB_RED_ZONE | \
@@ -256,9 +264,30 @@ struct array_cache {
 			 * Must have this definition in here for the proper
 			 * alignment of array_cache. Also simplifies accessing
 			 * the entries.
+			 *
+			 * Entries should not be directly dereferenced as
+			 * entries belonging to slabs marked pfmemalloc will
+			 * have the lower bits set SLAB_OBJ_PFMEMALLOC
 			 */
 };
 
+#define SLAB_OBJ_PFMEMALLOC	1
+static inline bool is_obj_pfmemalloc(void *objp)
+{
+	return (unsigned long)objp & SLAB_OBJ_PFMEMALLOC;
+}
+
+static inline void set_obj_pfmemalloc(void **objp)
+{
+	*objp = (void *)((unsigned long)*objp | SLAB_OBJ_PFMEMALLOC);
+	return;
+}
+
+static inline void clear_obj_pfmemalloc(void **objp)
+{
+	*objp = (void *)((unsigned long)*objp & ~SLAB_OBJ_PFMEMALLOC);
+}
+
 /*
  * bootstrap: The caches do not work without cpuarrays anymore, but the
  * cpuarrays are allocated from the generic caches...
@@ -925,6 +954,102 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	return nc;
 }
 
+static inline bool is_slab_pfmemalloc(struct slab *slabp)
+{
+	struct page *page = virt_to_page(slabp->s_mem);
+
+	return PageSlabPfmemalloc(page);
+}
+
+/* Clears pfmemalloc_active if no slabs have pfmalloc set */
+static void recheck_pfmemalloc_active(struct kmem_cache *cachep,
+						struct array_cache *ac)
+{
+	struct kmem_list3 *l3 = cachep->nodelists[numa_mem_id()];
+	struct slab *slabp;
+	unsigned long flags;
+
+	if (!pfmemalloc_active)
+		return;
+
+	spin_lock_irqsave(&l3->list_lock, flags);
+	list_for_each_entry(slabp, &l3->slabs_full, list)
+		if (is_slab_pfmemalloc(slabp))
+			goto out;
+
+	list_for_each_entry(slabp, &l3->slabs_partial, list)
+		if (is_slab_pfmemalloc(slabp))
+			goto out;
+
+	list_for_each_entry(slabp, &l3->slabs_free, list)
+		if (is_slab_pfmemalloc(slabp))
+			goto out;
+
+	pfmemalloc_active = false;
+out:
+	spin_unlock_irqrestore(&l3->list_lock, flags);
+}
+
+static void *ac_get_obj(struct kmem_cache *cachep, struct array_cache *ac,
+						gfp_t flags, bool force_refill)
+{
+	int i;
+	void *objp = ac->entry[--ac->avail];
+
+	/* Ensure the caller is allowed to use objects from PFMEMALLOC slab */
+	if (unlikely(is_obj_pfmemalloc(objp))) {
+		struct kmem_list3 *l3;
+
+		if (gfp_pfmemalloc_allowed(flags)) {
+			clear_obj_pfmemalloc(&objp);
+			return objp;
+		}
+
+		/* The caller cannot use PFMEMALLOC objects, find another one */
+		for (i = 1; i < ac->avail; i++) {
+			/* If a !PFMEMALLOC object is found, swap them */
+			if (!is_obj_pfmemalloc(ac->entry[i])) {
+				objp = ac->entry[i];
+				ac->entry[i] = ac->entry[ac->avail];
+				ac->entry[ac->avail] = objp;
+				return objp;
+			}
+		}
+
+		/*
+		 * If there are empty slabs on the slabs_free list and we are
+		 * being forced to refill the cache, mark this one !pfmemalloc.
+		 */
+		l3 = cachep->nodelists[numa_mem_id()];
+		if (!list_empty(&l3->slabs_free) && force_refill) {
+			struct slab *slabp = virt_to_slab(objp);
+			ClearPageSlabPfmemalloc(virt_to_page(slabp->s_mem));
+			clear_obj_pfmemalloc(&objp);
+			recheck_pfmemalloc_active(cachep, ac);
+			return objp;
+		}
+
+		/* No !PFMEMALLOC objects available */
+		ac->avail++;
+		objp = NULL;
+	}
+
+	return objp;
+}
+
+static void ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
+								void *objp)
+{
+	if (unlikely(pfmemalloc_active)) {
+		/* Some pfmemalloc slabs exist, check if this is one */
+		struct page *page = virt_to_page(objp);
+		if (PageSlabPfmemalloc(page))
+			set_obj_pfmemalloc(&objp);
+	}
+
+	ac->entry[ac->avail++] = objp;
+}
+
 /*
  * Transfer objects in one arraycache to another.
  * Locking must be handled by the caller.
@@ -1101,7 +1226,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 			STATS_INC_ACOVERFLOW(cachep);
 			__drain_alien_cache(cachep, alien, nodeid);
 		}
-		alien->entry[alien->avail++] = objp;
+		ac_put_obj(cachep, alien, objp);
 		spin_unlock(&alien->lock);
 	} else {
 		spin_lock(&(cachep->nodelists[nodeid])->list_lock);
@@ -1781,6 +1906,10 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 		return NULL;
 	}
 
+	/* Record if ALLOC_PFMEMALLOC was set when allocating the slab */
+	if (unlikely(page->pfmemalloc))
+		pfmemalloc_active = true;
+
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -1788,9 +1917,13 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	else
 		add_zone_page_state(page_zone(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
-	for (i = 0; i < nr_pages; i++)
+	for (i = 0; i < nr_pages; i++) {
 		__SetPageSlab(page + i);
 
+		if (page->pfmemalloc)
+			SetPageSlabPfmemalloc(page + i);
+	}
+
 	if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
 		kmemcheck_alloc_shadow(page, cachep->gfporder, flags, nodeid);
 
@@ -1822,6 +1955,7 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 				NR_SLAB_UNRECLAIMABLE, nr_freed);
 	while (i--) {
 		BUG_ON(!PageSlab(page));
+		__ClearPageSlabPfmemalloc(page);
 		__ClearPageSlab(page);
 		page++;
 	}
@@ -3093,16 +3227,19 @@ bad:
 #define check_slabp(x,y) do { } while(0)
 #endif
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
+static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
+							bool force_refill)
 {
 	int batchcount;
 	struct kmem_list3 *l3;
 	struct array_cache *ac;
 	int node;
 
-retry:
 	check_irq_off();
 	node = numa_mem_id();
+	if (unlikely(force_refill))
+		goto force_grow;
+retry:
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
@@ -3152,8 +3289,8 @@ retry:
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
 
-			ac->entry[ac->avail++] = slab_get_obj(cachep, slabp,
-							    node);
+			ac_put_obj(cachep, ac, slab_get_obj(cachep, slabp,
+									node));
 		}
 		check_slabp(cachep, slabp);
 
@@ -3172,18 +3309,22 @@ alloc_done:
 
 	if (unlikely(!ac->avail)) {
 		int x;
+force_grow:
 		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
-		if (!x && ac->avail == 0)	/* no objects in sight? abort */
+
+		/* no objects in sight? abort */
+		if (!x && (ac->avail == 0 || force_refill))
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
 			goto retry;
 	}
 	ac->touched = 1;
-	return ac->entry[--ac->avail];
+
+	return ac_get_obj(cachep, ac, flags, force_refill);
 }
 
 static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
@@ -3265,23 +3406,35 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *objp;
 	struct array_cache *ac;
+	bool force_refill = false;
 
 	check_irq_off();
 
 	ac = cpu_cache_get(cachep);
 	if (likely(ac->avail)) {
-		STATS_INC_ALLOCHIT(cachep);
 		ac->touched = 1;
-		objp = ac->entry[--ac->avail];
-	} else {
-		STATS_INC_ALLOCMISS(cachep);
-		objp = cache_alloc_refill(cachep, flags);
+		objp = ac_get_obj(cachep, ac, flags, false);
+
 		/*
-		 * the 'ac' may be updated by cache_alloc_refill(),
-		 * and kmemleak_erase() requires its correct value.
+		 * Allow for the possibility all avail objects are not allowed
+		 * by the current flags
 		 */
-		ac = cpu_cache_get(cachep);
+		if (objp) {
+			STATS_INC_ALLOCHIT(cachep);
+			goto out;
+		}
+		force_refill = true;
 	}
+
+	STATS_INC_ALLOCMISS(cachep);
+	objp = cache_alloc_refill(cachep, flags, force_refill);
+	/*
+	 * the 'ac' may be updated by cache_alloc_refill(),
+	 * and kmemleak_erase() requires its correct value.
+	 */
+	ac = cpu_cache_get(cachep);
+
+out:
 	/*
 	 * To avoid a false negative, if an object that is in one of the
 	 * per-CPU caches is leaked, we need to make sure kmemleak doesn't
@@ -3603,9 +3756,12 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 	struct kmem_list3 *l3;
 
 	for (i = 0; i < nr_objects; i++) {
-		void *objp = objpp[i];
+		void *objp;
 		struct slab *slabp;
 
+		clear_obj_pfmemalloc(&objpp[i]);
+		objp = objpp[i];
+
 		slabp = virt_to_slab(objp);
 		l3 = cachep->nodelists[node];
 		list_del(&slabp->list);
@@ -3723,7 +3879,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 		cache_flusharray(cachep, ac);
 	}
 
-	ac->entry[ac->avail++] = objp;
+	ac_put_obj(cachep, ac, objp);
 }
 
 /**
diff --git a/mm/slub.c b/mm/slub.c
index ef9bf01..98fecc2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -33,6 +33,8 @@
 
 #include <trace/events/kmem.h>
 
+#include "internal.h"
+
 /*
  * Lock order:
  *   1. slub_lock (Global Semaphore)
@@ -1370,6 +1372,8 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	__SetPageSlab(page);
+	if (page->pfmemalloc)
+		SetPageSlabPfmemalloc(page);
 
 	start = page_address(page);
 
@@ -1413,6 +1417,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
 
+	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
 	reset_page_mapcount(page);
 	if (current->reclaim_state)
@@ -2132,6 +2137,14 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 	return freelist;
 }
 
+static inline bool pfmemalloc_match(struct page *page, gfp_t gfpflags)
+{
+	if (unlikely(PageSlabPfmemalloc(page)))
+		return gfp_pfmemalloc_allowed(gfpflags);
+
+	return true;
+}
+
 /*
  * Check the page->freelist of a page and either transfer the freelist to the per cpu freelist
  * or deactivate the page.
@@ -2212,6 +2225,18 @@ redo:
 		goto new_slab;
 	}
 
+	/*
+	 * By rights, we should be searching for a slab page that was
+	 * PFMEMALLOC but right now, we are losing the pfmemalloc
+	 * information when the page leaves the per-cpu allocator
+	 */
+	if (unlikely(!pfmemalloc_match(page, gfpflags))) {
+		deactivate_slab(s, page, c->freelist);
+		c->page = NULL;
+		c->freelist = NULL;
+		goto new_slab;
+	}
+
 	/* must check again c->freelist in case of cpu migration or IRQ */
 	freelist = c->freelist;
 	if (freelist)
@@ -2318,8 +2343,8 @@ redo:
 
 	object = c->freelist;
 	page = c->page;
-	if (unlikely(!object || !node_match(page, node)))
-
+	if (unlikely(!object || !node_match(page, node)
+					!pfmemalloc_match(page, gfpflags)))
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
