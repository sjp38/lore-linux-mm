Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 630F76B13F0
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 05:26:12 -0500 (EST)
Date: Fri, 10 Feb 2012 10:26:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
Message-ID: <20120210102605.GO5938@suse.de>
References: <1328568978-17553-3-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1202071025050.30652@router.home>
 <20120208144506.GI5938@suse.de>
 <alpine.DEB.2.00.1202080907320.30248@router.home>
 <20120208163421.GL5938@suse.de>
 <alpine.DEB.2.00.1202081338210.32060@router.home>
 <20120208212323.GM5938@suse.de>
 <alpine.DEB.2.00.1202081557540.5970@router.home>
 <20120209125018.GN5938@suse.de>
 <alpine.DEB.2.00.1202091345540.4413@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1202091345540.4413@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, Feb 09, 2012 at 01:53:58PM -0600, Christoph Lameter wrote:
> On Thu, 9 Feb 2012, Mel Gorman wrote:
> 
> > Ok, I am working on a solution that does not affect any of the existing
> > slab structures. Between that and the fact we check if there are any
> > memalloc_socks after patch 12, the impact for normal systems is an additional
> > branch in ac_get_obj() and ac_put_obj()
> 
> That sounds good in particular since some other things came up again,
> sigh. Have not had time to see if an alternate approach works.
> 

I have an updated version of this 02/15 patch below. It passed testing
and is a lot less invasive than the previous release. As you suggested,
it uses page flags and the bulk of the complexity is only executed if
someone is using network-backed storage.

> > > We have been down this road too many times. Logic is added to critical
> > > paths and memory structures grow. This is not free. And for NBD swap
> > > support? Pretty exotic use case.
> > >
> >
> > NFS support is the real target. NBD is the logical starting point and
> > NFS needs the same support.
> 
> But this is already a pretty strange use case on multiple levels. Swap is
> really detrimental to performance. Its a kind of emergency outlet that
> gets worse with every new step that increases the differential in
> performance between disk and memory.

Performance is generally not the concern of the users of swap-over-N[FS|BD].
In the cases I am aware of, they just want an emergency overflow. One user
for example had an application with a sparse mapping larger than physical
memory. During the workload execution it would occasionally push small
parts out to swap and needed network-based swap due to the lack of a local
disk. The performance impact was not a concern because swapping was rare.

> On top of that you want to add
> special code in various subsystems to also do that over the network.
> Sigh. I think we agreed a while back that we want to limit the amount of
> I/O triggered from reclaim paths?

Specifically we wanted to reduce or stop page reclaim calling ->writepage()
for file-backed pages because it generated awful IO patterns and deep
call stacks. We still write anonymous pages from page reclaim because we
do not have a dedicated thread for writing to swap. It is expected that
the call stack for writing to network storage would be less than a
filesystem.

> AFAICT many filesystems do not support
> writeout from reclaim anymore because of all the issues that arise at that
> level.
> 

NBD is a block device so filesystem restrictions like you mention do not
apply. In NFS, the direct_IO paths are used to write pages not
->writepage so again the restriction does not apply.

> We have numerous other mechanisms that can compress swap etc and provide
> ways to work around the problem without I/O which has always be
> troublesome and these fixes are likely only to work in a very limited
> way causing a lot of maintenance effort because (given the exotic
> nature) it is highly likely that there are cornercases that only will be
> triggered in rare cases.

Compressing swap only gets you so far. For some workloads, at some point
the anonymous pages have to be written to swap somewhere. If there is a
local disk, great, use it. If there is no disk, then either
hardware-based solutions are needed (HBA that exposes the network as a
block device, works but is expensive), virtualisation is used (the host
os exposes a network-based swapfile as a block device to the guest but
only usable in virtualisation) or you need something like these patches.

Here is the revised 02/15 patch

=== CUT HERE ===
mm: sl[au]b: Add knowledge of PFMEMALLOC reserve pages

Allocations of pages below the min watermark run a risk of the
machine hanging due to a lack of memory.  To prevent this, only
callers who have PF_MEMALLOC or TIF_MEMDIE set and are not processing
an interrupt are allowed to allocate with ALLOC_NO_WATERMARKS. Once
they are allocated to a slab though, nothing prevents other callers
consuming free objects within those slabs. This patch limits access
to slab pages that were alloced from the PFMEMALLOC reserves.

Pages allocated from the reserve are returned with page->pfmemalloc
set and it is up to the caller to determine how the page should be
protected. SLAB restricts access to any page with page->pfmemalloc set
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
 include/linux/mm_types.h   |    9 ++
 include/linux/page-flags.h |   28 +++++++
 mm/internal.h              |    3 +
 mm/page_alloc.c            |   27 +++++-
 mm/slab.c                  |  190 +++++++++++++++++++++++++++++++++++++++-----
 mm/slub.c                  |   27 ++++++-
 6 files changed, 258 insertions(+), 26 deletions(-)

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
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e90a673..0c42973 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -432,6 +432,34 @@ static inline int PageTransCompound(struct page *page)
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
index f0bd785..f322dc2 100644
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
+static bool pfmemalloc_active;
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
@@ -951,6 +980,98 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	return nc;
 }
 
+static inline bool is_slab_pfmemalloc(struct slab *slabp)
+{
+	struct page *page = virt_to_page(slabp->s_mem);
+
+	return PageSlabPfmemalloc(page);
+}
+
+/* Clears ac->pfmemalloc if no slabs have pfmalloc set */
+static void check_ac_pfmemalloc(struct kmem_cache *cachep,
+						struct array_cache *ac)
+{
+	struct kmem_list3 *l3 = cachep->nodelists[numa_mem_id()];
+	struct slab *slabp;
+
+	if (!pfmemalloc_active)
+		return;
+
+	list_for_each_entry(slabp, &l3->slabs_full, list)
+		if (is_slab_pfmemalloc(slabp))
+			return;
+
+	list_for_each_entry(slabp, &l3->slabs_partial, list)
+		if (is_slab_pfmemalloc(slabp))
+			return;
+
+	list_for_each_entry(slabp, &l3->slabs_free, list)
+		if (is_slab_pfmemalloc(slabp))
+			return;
+
+	pfmemalloc_active = false;
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
@@ -1127,7 +1248,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 			STATS_INC_ACOVERFLOW(cachep);
 			__drain_alien_cache(cachep, alien, nodeid);
 		}
-		alien->entry[alien->avail++] = objp;
+		ac_put_obj(cachep, alien, objp);
 		spin_unlock(&alien->lock);
 	} else {
 		spin_lock(&(cachep->nodelists[nodeid])->list_lock);
@@ -1760,6 +1881,10 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	if (!page)
 		return NULL;
 
+	/* Record if ALLOC_PFMEMALLOC was set when allocating the slab */
+	if (unlikely(page->pfmemalloc))
+		pfmemalloc_active = true;
+
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -1767,9 +1892,13 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
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
 
@@ -1802,6 +1931,7 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
 	while (i--) {
 		BUG_ON(!PageSlab(page));
 		__ClearPageSlab(page);
+		__ClearPageSlabPfmemalloc(page);
 		page++;
 	}
 	if (current->reclaim_state)
@@ -3071,16 +3201,19 @@ bad:
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
@@ -3130,8 +3263,8 @@ retry:
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
 
-			ac->entry[ac->avail++] = slab_get_obj(cachep, slabp,
-							    node);
+			ac_put_obj(cachep, ac, slab_get_obj(cachep, slabp,
+									node));
 		}
 		check_slabp(cachep, slabp);
 
@@ -3150,18 +3283,22 @@ alloc_done:
 
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
@@ -3243,23 +3380,35 @@ static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
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
@@ -3578,9 +3727,12 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
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
@@ -3693,12 +3845,12 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 
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
 
diff --git a/mm/slub.c b/mm/slub.c
index 4907563..8eed0de 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -32,6 +32,8 @@
 
 #include <trace/events/kmem.h>
 
+#include "internal.h"
+
 /*
  * Lock order:
  *   1. slub_lock (Global Semaphore)
@@ -1364,6 +1366,8 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
+	if (page->pfmemalloc)
+		SetPageSlabPfmemalloc(page);
 
 	start = page_address(page);
 
@@ -1408,6 +1412,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 		-pages);
 
 	__ClearPageSlab(page);
+	__ClearPageSlabPfmemalloc(page);
 	reset_page_mapcount(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
@@ -2128,6 +2133,14 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 	return object;
 }
 
+static inline bool pfmemalloc_match(struct kmem_cache_cpu *c, gfp_t gfpflags)
+{
+	if (unlikely(PageSlabPfmemalloc(c->page)))
+		return gfp_pfmemalloc_allowed(gfpflags);
+
+	return true;
+}
+
 /*
  * Check the page->freelist of a page and either transfer the freelist to the per cpu freelist
  * or deactivate the page.
@@ -2200,6 +2213,16 @@ redo:
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
@@ -2304,8 +2327,8 @@ redo:
 	barrier();
 
 	object = c->freelist;
-	if (unlikely(!object || !node_match(c, node)))
-
+	if (unlikely(!object || !node_match(c, node) ||
+					!pfmemalloc_match(c, gfpflags)))
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 
 	else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
