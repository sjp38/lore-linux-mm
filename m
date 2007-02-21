Message-Id: <20070221144841.751839000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:06 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 02/29] mm: slab allocation fairness
Content-Disposition: inline; filename=mm-slab-ranking.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

The slab allocator has some unfairness wrt gfp flags; when the slab cache is
grown the gfp flags are used to allocate more memory, however when there is 
slab cache available (in partial or free slabs, per cpu caches or otherwise)
gfp flags are ignored.

Thus it is possible for less critical slab allocations to succeed and gobble
up precious memory when under memory pressure.

This patch solves that by using the newly introduced page allocation rank.

Page allocation rank is a scalar quantity connecting ALLOC_ and gfp flags which
represents how deep we had to reach into our reserves when allocating a page. 
Rank 0 is the deepest we can reach (ALLOC_NO_WATERMARK) and 16 is the most 
shallow allocation possible (ALLOC_WMARK_HIGH).

When the slab space is grown the rank of the page allocation is stored. For
each slab allocation we test the given gfp flags against this rank. Thereby
asking the question: would these flags have allowed the slab to grow.

If not so, we need to test the current situation. This is done by forcing the
growth of the slab space. (Just testing the free page limits will not work due
to direct reclaim) Failing this we need to fail the slab allocation.

Thus if we grew the slab under great duress while PF_MEMALLOC was set and we 
really did access the memalloc reserve the rank would be set to 0. If the next
allocation to that slab would be GFP_NOFS|__GFP_NOMEMALLOC (which ordinarily
maps to rank 4 and always > 0) we'd want to make sure that memory pressure has
decreased enough to allow an allocation with the given gfp flags.

So in this case we try to force grow the slab cache and on failure we fail the
slab allocation. Thus preserving the available slab cache for more pressing
allocations.

If this newly allocated slab will be trimmed on the next kmem_cache_free
(not unlikely) this is no problem, since 1) it will free memory and 2) the
sole purpose of the allocation was to probe the allocation rank, we didn't
need the space itself.

[AIM9 results go here]

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/Kconfig |    3 ++
 mm/slab.c  |   81 ++++++++++++++++++++++++++++++++++++++++---------------------
 2 files changed, 57 insertions(+), 27 deletions(-)

Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -114,6 +114,7 @@
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
+#include	"internal.h"
 
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_DEBUG_INITIAL,
@@ -380,6 +381,7 @@ static void kmem_list3_init(struct kmem_
 
 struct kmem_cache {
 /* 1) per-cpu data, touched during every alloc/free */
+	int rank;
 	struct array_cache *array[NR_CPUS];
 /* 2) Cache tunables. Protected by cache_chain_mutex */
 	unsigned int batchcount;
@@ -1023,21 +1025,21 @@ static inline int cache_free_alien(struc
 }
 
 static inline void *alternate_node_alloc(struct kmem_cache *cachep,
-		gfp_t flags)
+		gfp_t flags, int rank)
 {
 	return NULL;
 }
 
 static inline void *____cache_alloc_node(struct kmem_cache *cachep,
-		 gfp_t flags, int nodeid)
+		 gfp_t flags, int nodeid, int rank)
 {
 	return NULL;
 }
 
 #else	/* CONFIG_NUMA */
 
-static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
-static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
+static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int, int);
+static void *alternate_node_alloc(struct kmem_cache *, gfp_t, int);
 
 static struct array_cache **alloc_alien_cache(int node, int limit)
 {
@@ -1639,6 +1641,7 @@ static void *kmem_getpages(struct kmem_c
 	if (!page)
 		return NULL;
 
+	cachep->rank = page->index;
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -2287,6 +2290,7 @@ kmem_cache_create (const char *name, siz
 	}
 #endif
 #endif
+	cachep->rank = MAX_ALLOC_RANK;
 
 	/*
 	 * Determine if the slab management is 'on' or 'off' slab.
@@ -2953,7 +2957,7 @@ bad:
 #define check_slabp(x,y) do { } while(0)
 #endif
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
+static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags, int rank)
 {
 	int batchcount;
 	struct kmem_list3 *l3;
@@ -2965,6 +2969,8 @@ static void *cache_alloc_refill(struct k
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
 retry:
+	if (unlikely(rank > cachep->rank))
+		goto force_grow;
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
 		/*
@@ -3020,14 +3026,16 @@ must_grow:
 	l3->free_objects -= ac->avail;
 alloc_done:
 	spin_unlock(&l3->list_lock);
-
 	if (unlikely(!ac->avail)) {
 		int x;
+force_grow:
 		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
-		if (!x && ac->avail == 0)	/* no objects in sight? abort */
+
+		/* no objects in sight? abort */
+		if (!x && (ac->avail == 0 || rank > cachep->rank))
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -3184,7 +3192,8 @@ static inline int should_failslab(struct
 
 #endif /* CONFIG_FAILSLAB */
 
-static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+static inline void *____cache_alloc(struct kmem_cache *cachep,
+		gfp_t flags, int rank)
 {
 	void *objp;
 	struct array_cache *ac;
@@ -3195,17 +3204,29 @@ static inline void *____cache_alloc(stru
 		return NULL;
 
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
 
+#ifdef CONFIG_SLAB_FAIR
+static inline int slab_alloc_rank(gfp_t flags)
+{
+	return gfp_to_rank(flags);
+}
+#else
+static inline int slab_alloc_rank(gfp_t flags)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_NUMA
 /*
  * Try allocating on another node if PF_SPREAD_SLAB|PF_MEMPOLICY.
@@ -3213,7 +3234,8 @@ static inline void *____cache_alloc(stru
  * If we are in_interrupt, then process context, including cpusets and
  * mempolicy, may not apply and should not be used for allocation policy.
  */
-static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
+static void *alternate_node_alloc(struct kmem_cache *cachep,
+		gfp_t flags, int rank)
 {
 	int nid_alloc, nid_here;
 
@@ -3225,7 +3247,7 @@ static void *alternate_node_alloc(struct
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
 	if (nid_alloc != nid_here)
-		return ____cache_alloc_node(cachep, flags, nid_alloc);
+		return ____cache_alloc_node(cachep, flags, nid_alloc, rank);
 	return NULL;
 }
 
@@ -3237,7 +3259,7 @@ static void *alternate_node_alloc(struct
  * allocator to do its reclaim / fallback magic. We then insert the
  * slab into the proper nodelist and then allocate from it.
  */
-static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
+static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags, int rank)
 {
 	struct zonelist *zonelist;
 	gfp_t local_flags;
@@ -3264,7 +3286,7 @@ retry:
 			cache->nodelists[nid] &&
 			cache->nodelists[nid]->free_objects)
 				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
+					flags | GFP_THISNODE, nid, rank);
 	}
 
 	if (!obj && !(flags & __GFP_NO_GROW)) {
@@ -3287,7 +3309,7 @@ retry:
 			nid = page_to_nid(virt_to_page(obj));
 			if (cache_grow(cache, flags, nid, obj)) {
 				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
+					flags | GFP_THISNODE, nid, rank);
 				if (!obj)
 					/*
 					 * Another processor may allocate the
@@ -3308,7 +3330,7 @@ retry:
  * A interface to enable slab creation on nodeid
  */
 static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
-				int nodeid)
+				int nodeid, int rank)
 {
 	struct list_head *entry;
 	struct slab *slabp;
@@ -3321,6 +3343,8 @@ static void *____cache_alloc_node(struct
 
 retry:
 	check_irq_off();
+	if (unlikely(rank > cachep->rank))
+		goto force_grow;
 	spin_lock(&l3->list_lock);
 	entry = l3->slabs_partial.next;
 	if (entry == &l3->slabs_partial) {
@@ -3356,11 +3380,12 @@ retry:
 
 must_grow:
 	spin_unlock(&l3->list_lock);
+force_grow:
 	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
 	if (x)
 		goto retry;
 
-	return fallback_alloc(cachep, flags);
+	return fallback_alloc(cachep, flags, rank);
 
 done:
 	return obj;
@@ -3384,6 +3409,7 @@ __cache_alloc_node(struct kmem_cache *ca
 {
 	unsigned long save_flags;
 	void *ptr;
+	int rank = slab_alloc_rank(flags);
 
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
@@ -3393,7 +3419,7 @@ __cache_alloc_node(struct kmem_cache *ca
 
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
-		ptr = fallback_alloc(cachep, flags);
+		ptr = fallback_alloc(cachep, flags, rank);
 		goto out;
 	}
 
@@ -3404,12 +3430,12 @@ __cache_alloc_node(struct kmem_cache *ca
 		 * to other nodes. It may fail while we still have
 		 * objects on other nodes available.
 		 */
-		ptr = ____cache_alloc(cachep, flags);
+		ptr = ____cache_alloc(cachep, flags, rank);
 		if (ptr)
 			goto out;
 	}
 	/* ___cache_alloc_node can fall back to other nodes */
-	ptr = ____cache_alloc_node(cachep, flags, nodeid);
+	ptr = ____cache_alloc_node(cachep, flags, nodeid, rank);
   out:
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
@@ -3418,23 +3444,23 @@ __cache_alloc_node(struct kmem_cache *ca
 }
 
 static __always_inline void *
-__do_cache_alloc(struct kmem_cache *cache, gfp_t flags)
+__do_cache_alloc(struct kmem_cache *cache, gfp_t flags, int rank)
 {
 	void *objp;
 
 	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY))) {
-		objp = alternate_node_alloc(cache, flags);
+		objp = alternate_node_alloc(cache, flags, rank);
 		if (objp)
 			goto out;
 	}
-	objp = ____cache_alloc(cache, flags);
+	objp = ____cache_alloc(cache, flags, rank);
 
 	/*
 	 * We may just have run out of memory on the local node.
 	 * ____cache_alloc_node() knows how to locate memory on other nodes
 	 */
  	if (!objp)
- 		objp = ____cache_alloc_node(cache, flags, numa_node_id());
+ 		objp = ____cache_alloc_node(cache, flags, numa_node_id(), rank);
 
   out:
 	return objp;
@@ -3442,9 +3468,9 @@ __do_cache_alloc(struct kmem_cache *cach
 #else
 
 static __always_inline void *
-__do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+__do_cache_alloc(struct kmem_cache *cachep, gfp_t flags, int rank)
 {
-	return ____cache_alloc(cachep, flags);
+	return ____cache_alloc(cachep, flags, rank);
 }
 
 #endif /* CONFIG_NUMA */
@@ -3454,10 +3480,11 @@ __cache_alloc(struct kmem_cache *cachep,
 {
 	unsigned long save_flags;
 	void *objp;
+	int rank = slab_alloc_rank(flags);
 
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
-	objp = __do_cache_alloc(cachep, flags);
+	objp = __do_cache_alloc(cachep, flags, rank);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -163,6 +163,8 @@ config ZONE_DMA_FLAG
 	default "0" if !ZONE_DMA
 	default "1"
 
+config SLAB_FAIR
+	def_bool n
 #
 # Adaptive file readahead
 #

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
