Message-Id: <20061130101921.113055000@chello.nl>>
References: <20061130101451.495412000@chello.nl>>
Date: Thu, 30 Nov 2006 11:14:52 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 1/6] mm: slab allocation fairness
Content-Disposition: inline; filename=slab-ranking.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

The slab has some unfairness wrt gfp flags; when the slab is grown the gfp 
flags are used to allocate more memory, however when there is slab space 
available, gfp flags are ignored. Thus it is possible for less critical 
slab allocations to succeed and gobble up precious memory.

This patch avoids this by keeping track of the allocation hardness when 
growing. This is then compared to the current slab alloc's gfp flags.

[AIM9 results go here]

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/internal.h   |   89 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |   58 ++++++++++--------------------------
 mm/slab.c       |   57 ++++++++++++++++++++++-------------
 3 files changed, 142 insertions(+), 62 deletions(-)

Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2006-11-29 16:15:54.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2006-11-29 16:23:02.000000000 +0100
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/hardirq.h>
 
 static inline void set_page_count(struct page *page, int v)
 {
@@ -37,4 +38,92 @@ static inline void __put_page(struct pag
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+#define ALLOC_HARDER		0x01 /* try to alloc harder */
+#define ALLOC_HIGH		0x02 /* __GFP_HIGH set */
+#define ALLOC_WMARK_MIN		0x04 /* use pages_min watermark */
+#define ALLOC_WMARK_LOW		0x08 /* use pages_low watermark */
+#define ALLOC_WMARK_HIGH	0x10 /* use pages_high watermark */
+#define ALLOC_NO_WATERMARKS	0x20 /* don't check watermarks at all */
+#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+
+/*
+ * get the deepest reaching allocation flags for the given gfp_mask
+ */
+static int inline gfp_to_alloc_flags(gfp_t gfp_mask)
+{
+	struct task_struct *p = current;
+	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
+	const gfp_t wait = gfp_mask & __GFP_WAIT;
+
+	/*
+	 * The caller may dip into page reserves a bit more if the caller
+	 * cannot run direct reclaim, or if the caller has realtime scheduling
+	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
+	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
+	 */
+	if (gfp_mask & __GFP_HIGH)
+		alloc_flags |= ALLOC_HIGH;
+
+	if (!wait) {
+		alloc_flags |= ALLOC_HARDER;
+		/*
+		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
+		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
+		 */
+		alloc_flags &= ~ALLOC_CPUSET;
+	} else if (unlikely(rt_task(p)) && !in_interrupt())
+		alloc_flags |= ALLOC_HARDER;
+
+	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
+		if (!in_interrupt() &&
+		    ((p->flags & PF_MEMALLOC) ||
+		     unlikely(test_thread_flag(TIF_MEMDIE))))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+	}
+
+	return alloc_flags;
+}
+
+#define MAX_ALLOC_RANK	16
+
+/*
+ * classify the allocation: 0 is hardest, 16 is easiest.
+ */
+static inline int alloc_flags_to_rank(int alloc_flags)
+{
+	int rank;
+
+	if (alloc_flags & ALLOC_NO_WATERMARKS)
+		return 0;
+
+	rank = alloc_flags & (ALLOC_WMARK_MIN|ALLOC_WMARK_LOW|ALLOC_WMARK_HIGH);
+	rank -= alloc_flags & (ALLOC_HARDER|ALLOC_HIGH);
+
+	return rank;
+}
+
+static inline int gfp_to_rank(gfp_t gfp_mask)
+{
+	/*
+	 * Although correct this full version takes a ~3% performance
+	 * hit on the network tests in aim9.
+	 *
+
+	return alloc_flags_to_rank(gfp_to_alloc_flags(gfp_mask));
+
+	 *
+	 * Just check the bare essential ALLOC_NO_WATERMARKS case this keeps
+	 * the aim9 results within the error margin.
+	 */
+
+	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
+		if (!in_interrupt() &&
+		    ((current->flags & PF_MEMALLOC) ||
+		     unlikely(test_thread_flag(TIF_MEMDIE))))
+			return 0;
+	}
+
+	return 1;
+}
+
 #endif
Index: linux-2.6-git/mm/page_alloc.c
===================================================================
--- linux-2.6-git.orig/mm/page_alloc.c	2006-11-29 16:21:27.000000000 +0100
+++ linux-2.6-git/mm/page_alloc.c	2006-11-29 16:21:55.000000000 +0100
@@ -885,14 +885,6 @@ failed:
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
 /*
  * Return 1 if free pages are above 'mark'. This takes into account the order
  * of the allocation.
@@ -968,6 +960,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
 
 		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
 		if (page) {
+			page->index = alloc_flags_to_rank(alloc_flags);
 			break;
 		}
 	} while (*(++z) != NULL);
@@ -1013,47 +1006,26 @@ restart:
 	 * OK, we're below the kswapd watermark and have kicked background
 	 * reclaim. Now things get more complex, so set up alloc_flags according
 	 * to how we want to proceed.
-	 *
-	 * The caller may dip into page reserves a bit more if the caller
-	 * cannot run direct reclaim, or if the caller has realtime scheduling
-	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
-	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
 	 */
-	alloc_flags = ALLOC_WMARK_MIN;
-	if ((unlikely(rt_task(p)) && !in_interrupt()) || !wait)
-		alloc_flags |= ALLOC_HARDER;
-	if (gfp_mask & __GFP_HIGH)
-		alloc_flags |= ALLOC_HIGH;
-	if (wait)
-		alloc_flags |= ALLOC_CPUSET;
+	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
-	/*
-	 * Go through the zonelist again. Let __GFP_HIGH and allocations
-	 * coming from realtime tasks go deeper into reserves.
-	 *
-	 * This is the last chance, in general, before the goto nopage.
-	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
-	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
-	 */
-	page = get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags);
+	/* This is the last chance, in general, before the goto nopage. */
+	page = get_page_from_freelist(gfp_mask, order, zonelist,
+			alloc_flags & ~ALLOC_NO_WATERMARKS);
 	if (page)
 		goto got_pg;
 
 	/* This allocation should allow future memory freeing. */
-
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt()) {
-		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
+	if (alloc_flags & ALLOC_NO_WATERMARKS) {
 nofail_alloc:
-			/* go through the zonelist yet again, ignoring mins */
-			page = get_page_from_freelist(gfp_mask, order,
+		/* go through the zonelist yet again, ignoring mins */
+		page = get_page_from_freelist(gfp_mask, order,
 				zonelist, ALLOC_NO_WATERMARKS);
-			if (page)
-				goto got_pg;
-			if (gfp_mask & __GFP_NOFAIL) {
-				congestion_wait(WRITE, HZ/50);
-				goto nofail_alloc;
-			}
+		if (page)
+			goto got_pg;
+		if (wait && (gfp_mask & __GFP_NOFAIL)) {
+			congestion_wait(WRITE, HZ/50);
+			goto nofail_alloc;
 		}
 		goto nopage;
 	}
@@ -1062,6 +1034,10 @@ nofail_alloc:
 	if (!wait)
 		goto nopage;
 
+	/* Avoid recursion of direct reclaim */
+	if (p->flags & PF_MEMALLOC)
+		goto nopage;
+
 rebalance:
 	cond_resched();
 
Index: linux-2.6-git/mm/slab.c
===================================================================
--- linux-2.6-git.orig/mm/slab.c	2006-11-29 16:15:55.000000000 +0100
+++ linux-2.6-git/mm/slab.c	2006-11-29 16:21:55.000000000 +0100
@@ -112,6 +112,7 @@
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
+#include	"internal.h"
 
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_DEBUG_INITIAL,
@@ -378,6 +379,7 @@ static void kmem_list3_init(struct kmem_
 
 struct kmem_cache {
 /* 1) per-cpu data, touched during every alloc/free */
+	int rank;
 	struct array_cache *array[NR_CPUS];
 /* 2) Cache tunables. Protected by cache_chain_mutex */
 	unsigned int batchcount;
@@ -991,21 +993,21 @@ static inline int cache_free_alien(struc
 }
 
 static inline void *alternate_node_alloc(struct kmem_cache *cachep,
-		gfp_t flags)
+		gfp_t flags, int rank)
 {
 	return NULL;
 }
 
 static inline void *__cache_alloc_node(struct kmem_cache *cachep,
-		 gfp_t flags, int nodeid)
+		 gfp_t flags, int nodeid, int rank)
 {
 	return NULL;
 }
 
 #else	/* CONFIG_NUMA */
 
-static void *__cache_alloc_node(struct kmem_cache *, gfp_t, int);
-static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
+static void *__cache_alloc_node(struct kmem_cache *, gfp_t, int, int);
+static void *alternate_node_alloc(struct kmem_cache *, gfp_t, int);
 
 static struct array_cache **alloc_alien_cache(int node, int limit)
 {
@@ -1591,6 +1593,7 @@ static void *kmem_getpages(struct kmem_c
 	if (!page)
 		return NULL;
 
+	cachep->rank = page->index;
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -2245,6 +2248,7 @@ kmem_cache_create (const char *name, siz
 	}
 #endif
 #endif
+	cachep->rank = MAX_ALLOC_RANK;
 
 	/*
 	 * Determine if the slab management is 'on' or 'off' slab.
@@ -2917,7 +2921,7 @@ bad:
 #define check_slabp(x,y) do { } while(0)
 #endif
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
+static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags, int rank)
 {
 	int batchcount;
 	struct kmem_list3 *l3;
@@ -2929,6 +2933,8 @@ static void *cache_alloc_refill(struct k
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
 retry:
+	if (unlikely(rank > cachep->rank))
+		goto force_grow;
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
 		/*
@@ -2984,14 +2990,16 @@ must_grow:
 	l3->free_objects -= ac->avail;
 alloc_done:
 	spin_unlock(&l3->list_lock);
-
 	if (unlikely(!ac->avail)) {
 		int x;
+force_grow:
 		x = cache_grow(cachep, flags, node);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
-		if (!x && ac->avail == 0)	/* no objects in sight? abort */
+
+		/* no objects in sight? abort */
+		if (!x && (ac->avail == 0 || rank > cachep->rank))
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -3069,20 +3077,21 @@ static void *cache_alloc_debugcheck_afte
 #define cache_alloc_debugcheck_after(a,b,objp,d) (objp)
 #endif
 
-static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+static inline void *____cache_alloc(struct kmem_cache *cachep,
+		gfp_t flags, int rank)
 {
 	void *objp;
 	struct array_cache *ac;
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
-	if (likely(ac->avail)) {
+	if (likely(ac->avail && rank <= cachep->rank)) {
 		STATS_INC_ALLOCHIT(cachep);
 		ac->touched = 1;
 		objp = ac->entry[--ac->avail];
 	} else {
 		STATS_INC_ALLOCMISS(cachep);
-		objp = cache_alloc_refill(cachep, flags);
+		objp = cache_alloc_refill(cachep, flags, rank);
 	}
 	return objp;
 }
@@ -3092,6 +3101,7 @@ static __always_inline void *__cache_all
 {
 	unsigned long save_flags;
 	void *objp = NULL;
+	int rank = gfp_to_rank(flags);
 
 	cache_alloc_debugcheck_before(cachep, flags);
 
@@ -3099,16 +3109,16 @@ static __always_inline void *__cache_all
 
 	if (unlikely(NUMA_BUILD &&
 			current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY)))
-		objp = alternate_node_alloc(cachep, flags);
+		objp = alternate_node_alloc(cachep, flags, rank);
 
 	if (!objp)
-		objp = ____cache_alloc(cachep, flags);
+		objp = ____cache_alloc(cachep, flags, rank);
 	/*
 	 * We may just have run out of memory on the local node.
 	 * __cache_alloc_node() knows how to locate memory on other nodes
 	 */
  	if (NUMA_BUILD && !objp)
- 		objp = __cache_alloc_node(cachep, flags, numa_node_id());
+ 		objp = __cache_alloc_node(cachep, flags, numa_node_id(), rank);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp,
 					    caller);
@@ -3123,7 +3133,8 @@ static __always_inline void *__cache_all
  * If we are in_interrupt, then process context, including cpusets and
  * mempolicy, may not apply and should not be used for allocation policy.
  */
-static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
+static void *alternate_node_alloc(struct kmem_cache *cachep,
+		gfp_t flags, int rank)
 {
 	int nid_alloc, nid_here;
 
@@ -3135,7 +3146,7 @@ static void *alternate_node_alloc(struct
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
 	if (nid_alloc != nid_here)
-		return __cache_alloc_node(cachep, flags, nid_alloc);
+		return __cache_alloc_node(cachep, flags, nid_alloc, rank);
 	return NULL;
 }
 
@@ -3145,7 +3156,7 @@ static void *alternate_node_alloc(struct
  * the page allocator. We fall back according to a zonelist determined by
  * the policy layer while obeying cpuset constraints.
  */
-void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
+void *fallback_alloc(struct kmem_cache *cache, gfp_t flags, int rank)
 {
 	struct zonelist *zonelist = &NODE_DATA(slab_node(current->mempolicy))
 					->node_zonelists[gfp_zone(flags)];
@@ -3159,7 +3170,7 @@ void *fallback_alloc(struct kmem_cache *
 				cpuset_zone_allowed(*z, flags) &&
 				cache->nodelists[nid])
 			obj = __cache_alloc_node(cache,
-					flags | __GFP_THISNODE, nid);
+					flags | __GFP_THISNODE, nid, rank);
 	}
 	return obj;
 }
@@ -3168,7 +3179,7 @@ void *fallback_alloc(struct kmem_cache *
  * A interface to enable slab creation on nodeid
  */
 static void *__cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
-				int nodeid)
+				int nodeid, int rank)
 {
 	struct list_head *entry;
 	struct slab *slabp;
@@ -3181,6 +3192,8 @@ static void *__cache_alloc_node(struct k
 
 retry:
 	check_irq_off();
+	if (unlikely(rank > cachep->rank))
+		goto force_grow;
 	spin_lock(&l3->list_lock);
 	entry = l3->slabs_partial.next;
 	if (entry == &l3->slabs_partial) {
@@ -3216,13 +3229,14 @@ retry:
 
 must_grow:
 	spin_unlock(&l3->list_lock);
+force_grow:
 	x = cache_grow(cachep, flags, nodeid);
 	if (x)
 		goto retry;
 
 	if (!(flags & __GFP_THISNODE))
 		/* Unable to grow the cache. Fall back to other nodes. */
-		return fallback_alloc(cachep, flags);
+		return fallback_alloc(cachep, flags, rank);
 
 	return NULL;
 
@@ -3444,15 +3458,16 @@ void *kmem_cache_alloc_node(struct kmem_
 {
 	unsigned long save_flags;
 	void *ptr;
+	int rank = gfp_to_rank(flags);
 
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
 
 	if (nodeid == -1 || nodeid == numa_node_id() ||
 			!cachep->nodelists[nodeid])
-		ptr = ____cache_alloc(cachep, flags);
+		ptr = ____cache_alloc(cachep, flags, rank);
 	else
-		ptr = __cache_alloc_node(cachep, flags, nodeid);
+		ptr = __cache_alloc_node(cachep, flags, nodeid, rank);
 	local_irq_restore(save_flags);
 
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr,

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
