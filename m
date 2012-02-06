Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 020526B13F3
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:23 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve pages
Date: Mon,  6 Feb 2012 22:56:05 +0000
Message-Id: <1328568978-17553-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1328568978-17553-1-git-send-email-mgorman@suse.de>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Allocations of pages below the min watermark run a risk of the
machine hanging due to a lack of memory.  To prevent this, only
callers who have PF_MEMALLOC or TIF_MEMDIE set and are not processing
an interrupt are allowed to allocate with ALLOC_NO_WATERMARKS. Once
they are allocated to a slab though, nothing prevents other callers
consuming free objects within those slabs. This patch limits access
to slab pages that were alloced from the PFMEMALLOC reserves.

Pages allocated from the reserve are returned with page->pfmemalloc
set and it is up to the caller to determine how the page should be
protected.  SLAB restricts access to any page with page->pfmemalloc set
to callers which are known to able to access the PFMEMALLOC reserve. If
one is not available, an attempt is made to allocate a new page rather
than use a reserve. SLUB is a bit more relaxed in that it only records
if the current per-CPU page was allocated from PFMEMALLOC reserve and
uses another partial slab if the caller does not have the necessary
GFP or process flags. This was found to be sufficient in tests to
avoid hangs due to SLUB generally maintaining smaller lists than SLAB.

In low-memory conditions it does mean that !PFMEMALLOC allocators
can fail a slab allocation even though free objects are available
because they are being preserved for callers that are freeing pages.

[a.p.zijlstra@chello.nl: Original implementation]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm_types.h |    9 ++
 include/linux/slub_def.h |    1 +
 mm/internal.h            |    3 +
 mm/page_alloc.c          |   27 +++++-
 mm/slab.c                |  211 +++++++++++++++++++++++++++++++++++++++-------
 mm/slub.c                |   36 +++++++--
 6 files changed, 244 insertions(+), 43 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3cc3062..56a465f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -53,6 +53,15 @@ struct page {
 		union {
 			pgoff_t index;		/* Our offset within mapping. */
 			void *freelist;		/* slub first free object */
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
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a32bcfd..1d9ae40 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -46,6 +46,7 @@ struct kmem_cache_cpu {
 	struct page *page;	/* The slab from which we are allocating */
 	struct page *partial;	/* Partially allocated frozen slabs */
 	int node;		/* The node of the page (or -1 for debug) */
+	bool pfmemalloc;	/* Slab page had pfmemalloc set */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
diff --git a/mm/internal.h b/mm/internal.h
index 2189af4..bff60d8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -239,6 +239,9 @@ static inline struct page *mem_map_next(struct page *iter,
 #define __paginginit __init
 #endif
 
+/* Returns true if the gfp_mask allows use of ALLOC_NO_WATERMARK */
+bool gfp_pfmemalloc_allowed(gfp_t gfp_mask);
+
 /* Memory initialisation debug and verification */
 enum mminit_level {
 	MMINIT_WARNING,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8b3b8cf..6a3fa1c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -695,6 +695,7 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	trace_mm_page_free(page, order);
 	kmemcheck_free_shadow(page, order);
 
+	page->pfmemalloc = false;
 	if (PageAnon(page))
 		page->mapping = NULL;
 	for (i = 0; i < (1 << order); i++)
@@ -1221,6 +1222,7 @@ void free_hot_cold_page(struct page *page, int cold)
 
 	migratetype = get_pageblock_migratetype(page);
 	set_page_private(page, migratetype);
+	page->pfmemalloc = false;
 	local_irq_save(flags);
 	if (unlikely(wasMlocked))
 		free_page_mlock(page);
@@ -1427,6 +1429,7 @@ failed:
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+#define ALLOC_PFMEMALLOC	0x80 /* Caller has PF_MEMALLOC set */
 
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
@@ -2170,16 +2173,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
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
@@ -2365,8 +2374,16 @@ nopage:
 got_pg:
 	if (kmemcheck_enabled)
 		kmemcheck_pagealloc_alloc(page, order, gfp_mask);
-	return page;
 
+	/*
+	 * page->pfmemalloc is set when the caller had PFMEMALLOC set or is
+	 * been OOM killed. The expectation is that the caller is taking
+	 * steps that will free more memory. The caller should avoid the
+	 * page being used for !PFMEMALLOC purposes.
+	 */
+	page->pfmemalloc = !!(alloc_flags & ALLOC_PFMEMALLOC);
+
+	return page;
 }
 
 /*
diff --git a/mm/slab.c b/mm/slab.c
index f0bd785..e6a1e3d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -123,6 +123,8 @@
 
 #include <trace/events/kmem.h>
 
+#include	"internal.h"
+
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_RED_ZONE & SLAB_POISON.
  *		  0 for faster, smaller code (especially in the critical paths).
@@ -229,6 +231,7 @@ struct slab {
 			unsigned int inuse;	/* num of objs active in slab */
 			kmem_bufctl_t free;
 			unsigned short nodeid;
+			bool pfmemalloc;	/* Slab had pfmemalloc set */
 		};
 		struct slab_rcu __slab_cover_slab_rcu;
 	};
@@ -250,15 +253,37 @@ struct array_cache {
 	unsigned int avail;
 	unsigned int limit;
 	unsigned int batchcount;
-	unsigned int touched;
+	bool touched;
+	bool pfmemalloc;
 	spinlock_t lock;
 	void *entry[];	/*
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
@@ -945,12 +970,100 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 		nc->avail = 0;
 		nc->limit = entries;
 		nc->batchcount = batchcount;
-		nc->touched = 0;
+		nc->touched = false;
 		spin_lock_init(&nc->lock);
 	}
 	return nc;
 }
 
+/* Clears ac->pfmemalloc if no slabs have pfmalloc set */
+static void check_ac_pfmemalloc(struct kmem_cache *cachep,
+						struct array_cache *ac)
+{
+	struct kmem_list3 *l3 = cachep->nodelists[numa_mem_id()];
+	struct slab *slabp;
+
+	if (!ac->pfmemalloc)
+		return;
+
+	list_for_each_entry(slabp, &l3->slabs_full, list)
+		if (slabp->pfmemalloc)
+			return;
+
+	list_for_each_entry(slabp, &l3->slabs_partial, list)
+		if (slabp->pfmemalloc)
+			return;
+
+	list_for_each_entry(slabp, &l3->slabs_free, list)
+		if (slabp->pfmemalloc)
+			return;
+
+	ac->pfmemalloc = false;
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
+			slabp->pfmemalloc = false;
+			clear_obj_pfmemalloc(&objp);
+			check_ac_pfmemalloc(cachep, ac);
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
+	struct slab *slabp;
+
+	/* If there are pfmemalloc slabs, check if the object is part of one */
+	if (unlikely(ac->pfmemalloc)) {
+		slabp = virt_to_slab(objp);
+
+		if (slabp->pfmemalloc)
+			set_obj_pfmemalloc(&objp);
+	}
+
+	ac->entry[ac->avail++] = objp;
+}
+
 /*
  * Transfer objects in one arraycache to another.
  * Locking must be handled by the caller.
@@ -1127,7 +1240,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 			STATS_INC_ACOVERFLOW(cachep);
 			__drain_alien_cache(cachep, alien, nodeid);
 		}
-		alien->entry[alien->avail++] = objp;
+		ac_put_obj(cachep, alien, objp);
 		spin_unlock(&alien->lock);
 	} else {
 		spin_lock(&(cachep->nodelists[nodeid])->list_lock);
@@ -1738,7 +1851,8 @@ __initcall(cpucache_init);
  * did not request dmaable memory, we might get it, but that
  * would be relatively rare and ignorable.
  */
-static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid,
+		bool *pfmemalloc)
 {
 	struct page *page;
 	int nr_pages;
@@ -1759,6 +1873,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page)
 		return NULL;
+	*pfmemalloc = page->pfmemalloc;
 
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
@@ -2191,7 +2306,7 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 	cpu_cache_get(cachep)->avail = 0;
 	cpu_cache_get(cachep)->limit = BOOT_CPUCACHE_ENTRIES;
 	cpu_cache_get(cachep)->batchcount = 1;
-	cpu_cache_get(cachep)->touched = 0;
+	cpu_cache_get(cachep)->touched = false;
 	cachep->batchcount = 1;
 	cachep->limit = BOOT_CPUCACHE_ENTRIES;
 	return 0;
@@ -2749,6 +2864,7 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep, void *objp,
 	slabp->s_mem = objp + colour_off;
 	slabp->nodeid = nodeid;
 	slabp->free = 0;
+	slabp->pfmemalloc = false;
 	return slabp;
 }
 
@@ -2880,7 +2996,7 @@ static void slab_map_pages(struct kmem_cache *cache, struct slab *slab,
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
 static int cache_grow(struct kmem_cache *cachep,
-		gfp_t flags, int nodeid, void *objp)
+		gfp_t flags, int nodeid, void *objp, bool pfmemalloc)
 {
 	struct slab *slabp;
 	size_t offset;
@@ -2924,7 +3040,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	 * 'nodeid'.
 	 */
 	if (!objp)
-		objp = kmem_getpages(cachep, local_flags, nodeid);
+		objp = kmem_getpages(cachep, local_flags, nodeid, &pfmemalloc);
 	if (!objp)
 		goto failed;
 
@@ -2934,6 +3050,13 @@ static int cache_grow(struct kmem_cache *cachep,
 	if (!slabp)
 		goto opps1;
 
+	/* Record if ALLOC_PFMEMALLOC was set when allocating the slab */
+	if (pfmemalloc) {
+		struct array_cache *ac = cpu_cache_get(cachep);
+		slabp->pfmemalloc = true;
+		ac->pfmemalloc = true;
+	}
+
 	slab_map_pages(cachep, slabp, objp);
 
 	cache_init_objs(cachep, slabp);
@@ -3071,16 +3194,19 @@ bad:
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
@@ -3098,7 +3224,7 @@ retry:
 
 	/* See if we can refill from the shared array */
 	if (l3->shared && transfer_objects(ac, l3->shared, batchcount)) {
-		l3->shared->touched = 1;
+		l3->shared->touched = true;
 		goto alloc_done;
 	}
 
@@ -3130,8 +3256,8 @@ retry:
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
 
-			ac->entry[ac->avail++] = slab_get_obj(cachep, slabp,
-							    node);
+			ac_put_obj(cachep, ac, slab_get_obj(cachep, slabp,
+									node));
 		}
 		check_slabp(cachep, slabp);
 
@@ -3150,18 +3276,22 @@ alloc_done:
 
 	if (unlikely(!ac->avail)) {
 		int x;
-		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
+force_grow:
+		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL, false);
 
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
-	ac->touched = 1;
-	return ac->entry[--ac->avail];
+	ac->touched = true;
+
+	return ac_get_obj(cachep, ac, flags, force_refill);
 }
 
 static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
@@ -3243,23 +3373,35 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *objp;
 	struct array_cache *ac;
+	bool force_refill = false;
 
 	check_irq_off();
 
 	ac = cpu_cache_get(cachep);
 	if (likely(ac->avail)) {
-		STATS_INC_ALLOCHIT(cachep);
-		ac->touched = 1;
-		objp = ac->entry[--ac->avail];
-	} else {
-		STATS_INC_ALLOCMISS(cachep);
-		objp = cache_alloc_refill(cachep, flags);
+		ac->touched = true;
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
@@ -3312,6 +3454,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
+	bool pfmemalloc;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
@@ -3348,7 +3491,8 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, numa_mem_id());
+		obj = kmem_getpages(cache, local_flags, numa_mem_id(),
+							&pfmemalloc);
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {
@@ -3356,7 +3500,7 @@ retry:
 			 * Insert into the appropriate per node queues
 			 */
 			nid = page_to_nid(virt_to_page(obj));
-			if (cache_grow(cache, flags, nid, obj)) {
+			if (cache_grow(cache, flags, nid, obj, pfmemalloc)) {
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
 				if (!obj)
@@ -3428,7 +3572,7 @@ retry:
 
 must_grow:
 	spin_unlock(&l3->list_lock);
-	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
+	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL, false);
 	if (x)
 		goto retry;
 
@@ -3578,9 +3722,12 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
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
@@ -3693,12 +3840,12 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 
 	if (likely(ac->avail < ac->limit)) {
 		STATS_INC_FREEHIT(cachep);
-		ac->entry[ac->avail++] = objp;
+		ac_put_obj(cachep, ac, objp);
 		return;
 	} else {
 		STATS_INC_FREEMISS(cachep);
 		cache_flusharray(cachep, ac);
-		ac->entry[ac->avail++] = objp;
+		ac_put_obj(cachep, ac, objp);
 	}
 }
 
@@ -4125,7 +4272,7 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_list3 *l3,
 	if (!ac || !ac->avail)
 		return;
 	if (ac->touched && !force) {
-		ac->touched = 0;
+		ac->touched = false;
 	} else {
 		spin_lock_irq(&l3->list_lock);
 		if (ac->avail) {
diff --git a/mm/slub.c b/mm/slub.c
index 4907563..ea04994 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -32,6 +32,8 @@
 
 #include <trace/events/kmem.h>
 
+#include "internal.h"
+
 /*
  * Lock order:
  *   1. slub_lock (Global Semaphore)
@@ -1347,7 +1349,8 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 		s->ctor(object);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node,
+							bool *pfmemalloc)
 {
 	struct page *page;
 	void *start;
@@ -1362,6 +1365,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 		goto out;
 
 	inc_slabs_node(s, page_to_nid(page), page->objects);
+	*pfmemalloc = page->pfmemalloc;
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
 
@@ -2104,7 +2108,8 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 {
 	void *object;
 	struct kmem_cache_cpu *c;
-	struct page *page = new_slab(s, flags, node);
+	bool pfmemalloc;
+	struct page *page = new_slab(s, flags, node, &pfmemalloc);
 
 	if (page) {
 		c = __this_cpu_ptr(s->cpu_slab);
@@ -2121,6 +2126,7 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 		stat(s, ALLOC_SLAB);
 		c->node = page_to_nid(page);
 		c->page = page;
+		c->pfmemalloc = pfmemalloc;
 		*pc = c;
 	} else
 		object = NULL;
@@ -2128,6 +2134,14 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 	return object;
 }
 
+static inline bool pfmemalloc_match(struct kmem_cache_cpu *c, gfp_t gfpflags)
+{
+	if (unlikely(c->pfmemalloc))
+		return gfp_pfmemalloc_allowed(gfpflags);
+
+	return true;
+}
+
 /*
  * Check the page->freelist of a page and either transfer the freelist to the per cpu freelist
  * or deactivate the page.
@@ -2200,6 +2214,16 @@ redo:
 		goto new_slab;
 	}
 
+	/*
+	 * By rights, we should be searching for a slab page that was
+	 * PFMEMALLOC but right now, we are losing the pfmemalloc
+	 * information when the page leaves the per-cpu allocator
+	 */
+	if (unlikely(!pfmemalloc_match(c, gfpflags))) {
+		deactivate_slab(s, c);
+		goto new_slab;
+	}
+
 	/* must check again c->freelist in case of cpu migration or IRQ */
 	object = c->freelist;
 	if (object)
@@ -2236,7 +2260,6 @@ new_slab:
 
 	/* Then do expensive stuff like retrieving pages from the partial lists */
 	object = get_partial(s, gfpflags, node, c);
-
 	if (unlikely(!object)) {
 
 		object = new_slab_objects(s, gfpflags, node, &c);
@@ -2304,8 +2327,8 @@ redo:
 	barrier();
 
 	object = c->freelist;
-	if (unlikely(!object || !node_match(c, node)))
-
+	if (unlikely(!object || !node_match(c, node) ||
+					!pfmemalloc_match(c, gfpflags)))
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {
@@ -2784,10 +2807,11 @@ static void early_kmem_cache_node_alloc(int node)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
+	bool pfmemalloc;	/* Ignore this early in boot */
 
 	BUG_ON(kmem_cache_node->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmem_cache_node, GFP_NOWAIT, node);
+	page = new_slab(kmem_cache_node, GFP_NOWAIT, node, &pfmemalloc);
 
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
