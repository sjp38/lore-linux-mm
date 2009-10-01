Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B9D4D600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:25:22 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 05/31] mm: sl[au]b: add knowledge of reserve pages
Date: Thu,  1 Oct 2009 19:35:31 +0530
Message-Id: <1254405931-15832-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
contexts that are entitled to it. This is done to ensure reserve pages don't
leak out and get consumed.

The basic pattern used for all # allocators is the following, for each active
slab page we store if it came from an emergency allocation. When we find it
did, make sure the current allocation context would have been able to allocate
page from the emergency reserves as well. In that case allow the allocation. If
not, force a new slab allocation. When that works the memory pressure has
lifted enough to allow this context to get an object, otherwise fail the
allocation.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 include/linux/slub_def.h |    1 
 mm/slab.c                |   61 ++++++++++++++++++++++++++++++++++++++++-------
 mm/slob.c                |   16 +++++++++++-
 mm/slub.c                |   43 +++++++++++++++++++++++++++------
 4 files changed, 104 insertions(+), 17 deletions(-)

Index: mmotm/mm/slub.c
===================================================================
--- mmotm.orig/mm/slub.c
+++ mmotm/mm/slub.c
@@ -28,6 +28,8 @@
 #include <linux/memory.h>
 #include <linux/math64.h>
 #include <linux/fault-inject.h>
+#include "internal.h"
+
 
 /*
  * Lock order:
@@ -1142,7 +1144,8 @@ static void setup_object(struct kmem_cac
 		s->ctor(object);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static
+struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *reserve)
 {
 	struct page *page;
 	void *start;
@@ -1156,6 +1159,8 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
 
+	*reserve = page->reserve;
+
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
 	page->flags |= 1 << PG_slab;
@@ -1602,10 +1607,20 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	struct page *new;
+	int reserve;
 
 	/* We handle __GFP_ZERO in the caller */
 	gfpflags &= ~__GFP_ZERO;
 
+	if (unlikely(c->reserve)) {
+		/*
+		 * If the current slab is a reserve slab and the current
+		 * allocation context does not allow access to the reserves we
+		 * must force an allocation to test the current levels.
+		 */
+		if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
+			goto grow_slab;
+	}
 	if (!c->page)
 		goto new_slab;
 
@@ -1619,8 +1634,8 @@ load_freelist:
 	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
-		goto debug;
+	if (unlikely(PageSlubDebug(c->page) || c->reserve))
+		goto slow_path;
 
 	c->freelist = object[c->offset];
 	c->page->inuse = c->page->objects;
@@ -1642,16 +1657,18 @@ new_slab:
 		goto load_freelist;
 	}
 
+grow_slab:
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
-	new = new_slab(s, gfpflags, node);
+	new = new_slab(s, gfpflags, node, &reserve);
 
 	if (gfpflags & __GFP_WAIT)
 		local_irq_disable();
 
 	if (new) {
 		c = get_cpu_slab(s, smp_processor_id());
+		c->reserve = reserve;
 		stat(c, ALLOC_SLAB);
 		if (c->page)
 			flush_slab(s, c);
@@ -1663,10 +1680,21 @@ new_slab:
 	if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
 		slab_out_of_memory(s, gfpflags, node);
 	return NULL;
-debug:
-	if (!alloc_debug_processing(s, c->page, object, addr))
+
+slow_path:
+	if (PageSlubDebug(c->page) &&
+			!alloc_debug_processing(s, c->page, object, addr))
 		goto another_slab;
 
+	/*
+	 * Avoid the slub fast path in slab_alloc() by not setting
+	 * c->freelist and the fast path in slab_free() by making
+	 * node_match() fail by setting c->node to -1.
+	 *
+	 * We use this for for debug and reserve checks which need
+	 * to be done for each allocation.
+	 */
+
 	c->page->inuse++;
 	c->page->freelist = object[c->offset];
 	c->node = -1;
@@ -2213,10 +2241,11 @@ static void early_kmem_cache_node_alloc(
 	struct page *page;
 	struct kmem_cache_node *n;
 	unsigned long flags;
+	int reserve;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags, node);
+	page = new_slab(kmalloc_caches, gfpflags, node, &reserve);
 
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
Index: mmotm/include/linux/slub_def.h
===================================================================
--- mmotm.orig/include/linux/slub_def.h
+++ mmotm/include/linux/slub_def.h
@@ -40,6 +40,7 @@ struct kmem_cache_cpu {
 	int node;		/* The node of the page (or -1 for debug) */
 	unsigned int offset;	/* Freepointer offset (in word units) */
 	unsigned int objsize;	/* Size of an object (from kmem_cache) */
+	int reserve;		/* Did the current page come from the reserve */
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
Index: mmotm/mm/slab.c
===================================================================
--- mmotm.orig/mm/slab.c
+++ mmotm/mm/slab.c
@@ -120,6 +120,8 @@
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
 
+#include 	"internal.h"
+
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_RED_ZONE & SLAB_POISON.
  *		  0 for faster, smaller code (especially in the critical paths).
@@ -268,7 +270,8 @@ struct array_cache {
 	unsigned int avail;
 	unsigned int limit;
 	unsigned int batchcount;
-	unsigned int touched;
+	unsigned int touched:1,
+		     reserve:1;
 	spinlock_t lock;
 	void *entry[];	/*
 			 * Must have this definition in here for the proper
@@ -692,6 +695,27 @@ static inline struct array_cache *cpu_ca
 	return cachep->array[smp_processor_id()];
 }
 
+/*
+ * If the last page came from the reserves, and the current allocation context
+ * does not have access to them, force an allocation to test the watermarks.
+ */
+static inline int slab_force_alloc(struct kmem_cache *cachep, gfp_t flags)
+{
+	if (unlikely(cpu_cache_get(cachep)->reserve) &&
+			!(gfp_to_alloc_flags(flags) & ALLOC_NO_WATERMARKS))
+		return 1;
+
+	return 0;
+}
+
+static inline void slab_set_reserve(struct kmem_cache *cachep, int reserve)
+{
+	struct array_cache *ac = cpu_cache_get(cachep);
+
+	if (unlikely(ac->reserve != reserve))
+		ac->reserve = reserve;
+}
+
 static inline struct kmem_cache *__find_general_cachep(size_t size,
 							gfp_t gfpflags)
 {
@@ -898,6 +922,7 @@ static struct array_cache *alloc_arrayca
 		nc->limit = entries;
 		nc->batchcount = batchcount;
 		nc->touched = 0;
+		nc->reserve = 0;
 		spin_lock_init(&nc->lock);
 	}
 	return nc;
@@ -1595,7 +1620,8 @@ __initcall(cpucache_init);
  * did not request dmaable memory, we might get it, but that
  * would be relatively rare and ignorable.
  */
-static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid,
+		int *reserve)
 {
 	struct page *page;
 	int nr_pages;
@@ -1617,6 +1643,7 @@ static void *kmem_getpages(struct kmem_c
 	if (!page)
 		return NULL;
 
+	*reserve = page->reserve;
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -2049,6 +2076,7 @@ static int __init_refok setup_cpu_cache(
 	cpu_cache_get(cachep)->limit = BOOT_CPUCACHE_ENTRIES;
 	cpu_cache_get(cachep)->batchcount = 1;
 	cpu_cache_get(cachep)->touched = 0;
+	cpu_cache_get(cachep)->reserve = 0;
 	cachep->batchcount = 1;
 	cachep->limit = BOOT_CPUCACHE_ENTRIES;
 	return 0;
@@ -2732,6 +2760,7 @@ static int cache_grow(struct kmem_cache
 	size_t offset;
 	gfp_t local_flags;
 	struct kmem_list3 *l3;
+	int reserve;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2770,7 +2799,7 @@ static int cache_grow(struct kmem_cache
 	 * 'nodeid'.
 	 */
 	if (!objp)
-		objp = kmem_getpages(cachep, local_flags, nodeid);
+		objp = kmem_getpages(cachep, local_flags, nodeid, &reserve);
 	if (!objp)
 		goto failed;
 
@@ -2787,6 +2816,7 @@ static int cache_grow(struct kmem_cache
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	check_irq_off();
+	slab_set_reserve(cachep, reserve);
 	spin_lock(&l3->list_lock);
 
 	/* Make slab active. */
@@ -2921,7 +2951,8 @@ bad:
 #define check_slabp(x,y) do { } while(0)
 #endif
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
+static void *cache_alloc_refill(struct kmem_cache *cachep,
+		gfp_t flags, int must_refill)
 {
 	int batchcount;
 	struct kmem_list3 *l3;
@@ -2931,6 +2962,8 @@ static void *cache_alloc_refill(struct k
 retry:
 	check_irq_off();
 	node = numa_node_id();
+	if (unlikely(must_refill))
+		goto force_grow;
 	ac = cpu_cache_get(cachep);
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
@@ -2998,11 +3031,14 @@ alloc_done:
 
 	if (unlikely(!ac->avail)) {
 		int x;
+force_grow:
 		x = cache_grow(cachep, flags | GFP_THISNODE, node, NULL);
 
 		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = cpu_cache_get(cachep);
-		if (!x && ac->avail == 0)	/* no objects in sight? abort */
+
+		/* no objects in sight? abort */
+		if (!x && (ac->avail == 0 || must_refill))
 			return NULL;
 
 		if (!ac->avail)		/* objects refilled by interrupt? */
@@ -3092,17 +3128,18 @@ static inline void *____cache_alloc(stru
 {
 	void *objp;
 	struct array_cache *ac;
+	int must_refill = slab_force_alloc(cachep, flags);
 
 	check_irq_off();
 
 	ac = cpu_cache_get(cachep);
-	if (likely(ac->avail)) {
+	if (likely(ac->avail && !must_refill)) {
 		STATS_INC_ALLOCHIT(cachep);
 		ac->touched = 1;
 		objp = ac->entry[--ac->avail];
 	} else {
 		STATS_INC_ALLOCMISS(cachep);
-		objp = cache_alloc_refill(cachep, flags);
+		objp = cache_alloc_refill(cachep, flags, must_refill);
 	}
 	/*
 	 * To avoid a false negative, if an object that is in one of the
@@ -3152,7 +3189,7 @@ static void *fallback_alloc(struct kmem_
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
-	int nid;
+	int nid, reserve;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
@@ -3188,10 +3225,12 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, local_flags, numa_node_id());
+		obj = kmem_getpages(cache, local_flags, numa_node_id(),
+				    &reserve);
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {
+			slab_set_reserve(cache, reserve);
 			/*
 			 * Insert into the appropriate per node queues
 			 */
@@ -3230,6 +3269,9 @@ static void *____cache_alloc_node(struct
 	l3 = cachep->nodelists[nodeid];
 	BUG_ON(!l3);
 
+	if (unlikely(slab_force_alloc(cachep, flags)))
+		goto force_grow;
+
 retry:
 	check_irq_off();
 	spin_lock(&l3->list_lock);
@@ -3267,6 +3309,7 @@ retry:
 
 must_grow:
 	spin_unlock(&l3->list_lock);
+force_grow:
 	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
 	if (x)
 		goto retry;
Index: mmotm/mm/slob.c
===================================================================
--- mmotm.orig/mm/slob.c
+++ mmotm/mm/slob.c
@@ -69,6 +69,7 @@
 #include <linux/kmemtrace.h>
 #include <linux/kmemleak.h>
 #include <asm/atomic.h>
+#include "internal.h"
 
 /*
  * slob_block has a field 'units', which indicates size of block if +ve,
@@ -191,6 +192,11 @@ struct slob_rcu {
 static DEFINE_SPINLOCK(slob_lock);
 
 /*
+ * tracks the reserve state for the allocator.
+ */
+static int slob_reserve;
+
+/*
  * Encode the given size and next info into a free slob block s.
  */
 static void set_slob(slob_t *s, slobidx_t size, slob_t *next)
@@ -240,7 +246,7 @@ static int slob_last(slob_t *s)
 
 static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
-	void *page;
+	struct page *page;
 
 #ifdef CONFIG_NUMA
 	if (node != -1)
@@ -252,6 +258,8 @@ static void *slob_new_pages(gfp_t gfp, i
 	if (!page)
 		return NULL;
 
+	slob_reserve = page->reserve;
+
 	return page_address(page);
 }
 
@@ -324,6 +332,11 @@ static void *slob_alloc(size_t size, gfp
 	slob_t *b = NULL;
 	unsigned long flags;
 
+	if (unlikely(slob_reserve)) {
+		if (!(gfp_to_alloc_flags(gfp) & ALLOC_NO_WATERMARKS))
+			goto grow;
+	}
+
 	if (size < SLOB_BREAK1)
 		slob_list = &free_slob_small;
 	else if (size < SLOB_BREAK2)
@@ -362,6 +375,7 @@ static void *slob_alloc(size_t size, gfp
 	}
 	spin_unlock_irqrestore(&slob_lock, flags);
 
+grow:
 	/* Not enough space: must allocate a new page */
 	if (!b) {
 		b = slob_new_pages(gfp & ~__GFP_ZERO, 0, node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
