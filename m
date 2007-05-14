Message-Id: <20070514133212.399158218@chello.nl>
References: <20070514131904.440041502@chello.nl>
Date: Mon, 14 May 2007 15:19:06 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 2/5] mm: slab allocation fairness
Content-Disposition: inline; filename=mm-slab-ranking.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>
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

[netperf results]

TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 127.0.0.1 (127.0.0.1) port 0 AF_INET

Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

v2.6.21

114688 114688   4096    60.00    5424.17
114688 114688   4096    60.00    5486.54
114688 114688   4096    60.00    6460.20
114688 114688   4096    60.00    6457.82
114688 114688   4096    60.00    6468.99
114688 114688   4096    60.00    6326.81
114688 114688   4096    60.00    6476.74
114688 114688   4096    60.00    6473.61

                                 6196.86        460.58

v2.6.21-slab CONFIG_SLAB_FAIR=n

114688 114688   4096    60.00    6987.93
114688 114688   4096    60.00    6214.82
114688 114688   4096    60.00    5539.82
114688 114688   4096    60.00    5597.57
114688 114688   4096    60.00    6192.22
114688 114688   4096    60.00    6306.76
114688 114688   4096    60.00    5492.49
114688 114688   4096    60.00    5607.24

                                 5992.36        526.21

v2.6.21-slab CONFIG_SLAB_FAIR=y

114688 114688   4096    60.00    5475.34
114688 114688   4096    60.00    6464.61
114688 114688   4096    60.00    6457.15
114688 114688   4096    60.00    6465.70
114688 114688   4096    60.00    6404.30
114688 114688   4096    60.00    6474.61
114688 114688   4096    60.00    6461.68
114688 114688   4096    60.00    6453.63

                                 6332.13        346.86

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>
---
 mm/Kconfig    |    4 +++
 mm/internal.h |    8 ++++++
 mm/slab.c     |   70 +++++++++++++++++++++++++++++++++++-----------------------
 3 files changed, 55 insertions(+), 27 deletions(-)

Index: linux-2.6-git/mm/slab.c
===================================================================
--- linux-2.6-git.orig/mm/slab.c
+++ linux-2.6-git/mm/slab.c
@@ -114,6 +114,7 @@
 #include	<asm/cacheflush.h>
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
+#include	"internal.h"
 
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_RED_ZONE & SLAB_POISON.
@@ -380,6 +381,7 @@ static void kmem_list3_init(struct kmem_
 
 struct kmem_cache {
 /* 1) per-cpu data, touched during every alloc/free */
+	int rank;
 	struct array_cache *array[NR_CPUS];
 /* 2) Cache tunables. Protected by cache_chain_mutex */
 	unsigned int batchcount;
@@ -1030,21 +1032,21 @@ static inline int cache_free_alien(struc
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
@@ -1648,6 +1650,7 @@ static void *kmem_getpages(struct kmem_c
 	if (!page)
 		return NULL;
 
+	cachep->rank = page->index;
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -2292,6 +2295,7 @@ kmem_cache_create (const char *name, siz
 	}
 #endif
 #endif
+	cachep->rank = MAX_ALLOC_RANK;
 
 	/*
 	 * Determine if the slab management is 'on' or 'off' slab.
@@ -2941,7 +2945,7 @@ bad:
 #define check_slabp(x,y) do { } while(0)
 #endif
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
+static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags, int rank)
 {
 	int batchcount;
 	struct kmem_list3 *l3;
@@ -2953,6 +2957,8 @@ static void *cache_alloc_refill(struct k
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
 retry:
+	if (slab_insufficient_rank(cachep, rank))
+		goto force_grow;
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
 		/*
@@ -3016,14 +3022,17 @@ must_grow:
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
+		if (!x && (ac->avail == 0 ||
+					slab_insufficient_rank(cachep, rank)))
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -3174,7 +3183,8 @@ static inline int should_failslab(struct
 
 #endif /* CONFIG_FAILSLAB */
 
-static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+static inline void *____cache_alloc(struct kmem_cache *cachep,
+		gfp_t flags, int rank)
 {
 	void *objp;
 	struct array_cache *ac;
@@ -3182,13 +3192,13 @@ static inline void *____cache_alloc(stru
 	check_irq_off();
 
 	ac = cpu_cache_get(cachep);
-	if (likely(ac->avail)) {
+	if (likely(ac->avail) && !slab_insufficient_rank(cachep, rank)) {
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
@@ -3200,7 +3210,8 @@ static inline void *____cache_alloc(stru
  * If we are in_interrupt, then process context, including cpusets and
  * mempolicy, may not apply and should not be used for allocation policy.
  */
-static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
+static void *alternate_node_alloc(struct kmem_cache *cachep,
+		gfp_t flags, int rank)
 {
 	int nid_alloc, nid_here;
 
@@ -3212,7 +3223,7 @@ static void *alternate_node_alloc(struct
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
 	if (nid_alloc != nid_here)
-		return ____cache_alloc_node(cachep, flags, nid_alloc);
+		return ____cache_alloc_node(cachep, flags, nid_alloc, rank);
 	return NULL;
 }
 
@@ -3224,7 +3235,7 @@ static void *alternate_node_alloc(struct
  * allocator to do its reclaim / fallback magic. We then insert the
  * slab into the proper nodelist and then allocate from it.
  */
-static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
+static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags, int rank)
 {
 	struct zonelist *zonelist;
 	gfp_t local_flags;
@@ -3251,7 +3262,7 @@ retry:
 			cache->nodelists[nid] &&
 			cache->nodelists[nid]->free_objects)
 				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
+					flags | GFP_THISNODE, nid, rank);
 	}
 
 	if (!obj) {
@@ -3274,7 +3285,7 @@ retry:
 			nid = page_to_nid(virt_to_page(obj));
 			if (cache_grow(cache, flags, nid, obj)) {
 				obj = ____cache_alloc_node(cache,
-					flags | GFP_THISNODE, nid);
+					flags | GFP_THISNODE, nid, rank);
 				if (!obj)
 					/*
 					 * Another processor may allocate the
@@ -3295,7 +3306,7 @@ retry:
  * A interface to enable slab creation on nodeid
  */
 static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
-				int nodeid)
+				int nodeid, int rank)
 {
 	struct list_head *entry;
 	struct slab *slabp;
@@ -3308,6 +3319,8 @@ static void *____cache_alloc_node(struct
 
 retry:
 	check_irq_off();
+	if (slab_insufficient_rank(cachep, rank))
+		goto force_grow;
 	spin_lock(&l3->list_lock);
 	entry = l3->slabs_partial.next;
 	if (entry == &l3->slabs_partial) {
@@ -3343,11 +3356,12 @@ retry:
 
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
@@ -3371,6 +3385,7 @@ __cache_alloc_node(struct kmem_cache *ca
 {
 	unsigned long save_flags;
 	void *ptr;
+	int rank = slab_alloc_rank(flags);
 
 	if (should_failslab(cachep, flags))
 		return NULL;
@@ -3383,7 +3398,7 @@ __cache_alloc_node(struct kmem_cache *ca
 
 	if (unlikely(!cachep->nodelists[nodeid])) {
 		/* Node not bootstrapped yet */
-		ptr = fallback_alloc(cachep, flags);
+		ptr = fallback_alloc(cachep, flags, rank);
 		goto out;
 	}
 
@@ -3394,12 +3409,12 @@ __cache_alloc_node(struct kmem_cache *ca
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
@@ -3408,23 +3423,23 @@ __cache_alloc_node(struct kmem_cache *ca
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
@@ -3432,9 +3447,9 @@ __do_cache_alloc(struct kmem_cache *cach
 #else
 
 static __always_inline void *
-__do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
+__do_cache_alloc(struct kmem_cache *cachep, gfp_t flags, int rank)
 {
-	return ____cache_alloc(cachep, flags);
+	return ____cache_alloc(cachep, flags, rank);
 }
 
 #endif /* CONFIG_NUMA */
@@ -3444,13 +3459,14 @@ __cache_alloc(struct kmem_cache *cachep,
 {
 	unsigned long save_flags;
 	void *objp;
+	int rank = slab_alloc_rank(flags);
 
 	if (should_failslab(cachep, flags))
 		return NULL;
 
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
-	objp = __do_cache_alloc(cachep, flags);
+	objp = __do_cache_alloc(cachep, flags, rank);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
Index: linux-2.6-git/mm/Kconfig
===================================================================
--- linux-2.6-git.orig/mm/Kconfig
+++ linux-2.6-git/mm/Kconfig
@@ -163,6 +163,10 @@ config ZONE_DMA_FLAG
 	default "0" if !ZONE_DMA
 	default "1"
 
+config SLAB_FAIR
+	def_bool n
+	depends on SLAB
+
 config NR_QUICK
 	int
 	depends on QUICKLIST
Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h
+++ linux-2.6-git/mm/internal.h
@@ -107,4 +107,12 @@ static inline int gfp_to_rank(gfp_t gfp_
 	return alloc_flags_to_rank(gfp_to_alloc_flags(gfp_mask));
 }
 
+#ifdef CONFIG_SLAB_FAIR
+#define slab_alloc_rank(gfp)			gfp_to_rank(gfp)
+#define slab_insufficient_rank(s, _rank) 	unlikely((_rank) > (s)->rank)
+#else
+#define slab_alloc_rank(gfp)			0
+#define slab_insufficient_rank(s, _rank)	false
+#endif
+
 #endif

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
