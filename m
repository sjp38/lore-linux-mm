Message-Id: <20071214154439.242195000@chello.nl>
References: <20071214153907.770251000@chello.nl>
Date: Fri, 14 Dec 2007 16:39:10 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 03/29] mm: slb: add knowledge of reserve pages
Content-Disposition: inline; filename=reserve-slub.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Restrict objects from reserve slabs (ALLOC_NO_WATERMARKS) to allocation
contexts that are entitled to it. This is done to ensure reserve pages don't
leak out and get consumed.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slub_def.h |    1 
 mm/slab.c                |   59 +++++++++++++++++++++++++++++++++++++++--------
 mm/slub.c                |   27 ++++++++++++++++-----
 3 files changed, 72 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -21,11 +21,12 @@
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
+#include "internal.h"
 
 /*
  * Lock order:
  *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   2. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -1071,7 +1072,7 @@ static void setup_object(struct kmem_cac
 }
 
 static noinline struct page *new_slab(struct kmem_cache *s,
-						gfp_t flags, int node)
+					gfp_t flags, int node, int *reserve)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -1087,6 +1088,7 @@ static noinline struct page *new_slab(st
 	if (!page)
 		goto out;
 
+	*reserve = page->reserve;
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
@@ -1517,11 +1519,12 @@ static noinline unsigned long get_new_sl
 {
 	struct kmem_cache_cpu *c = *pc;
 	struct page *page;
+	int reserve;
 
 	if (gfpflags & __GFP_WAIT)
 		local_irq_enable();
 
-	page = new_slab(s, gfpflags, node);
+	page = new_slab(s, gfpflags, node, &reserve);
 
 	if (gfpflags & __GFP_WAIT)
 		local_irq_disable();
@@ -1530,6 +1533,7 @@ static noinline unsigned long get_new_sl
 		return 0;
 
 	*pc = c = get_cpu_slab(s, smp_processor_id());
+	c->reserve = reserve;
 	if (c->page)
 		flush_slab(s, c);
 	c->page = page;
@@ -1564,6 +1568,16 @@ static void *__slab_alloc(struct kmem_ca
 	local_irq_save(flags);
 	preempt_enable_no_resched();
 #endif
+	if (unlikely(c->reserve)) {
+		/*
+		 * If the current slab is a reserve slab and the current
+		 * allocation context does not allow access to the reserves we
+		 * must force an allocation to test the current levels.
+		 */
+		if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
+			goto grow_slab;
+	}
+
 	if (likely(c->page)) {
 		state = slab_lock(c->page);
 
@@ -1586,7 +1600,7 @@ load_freelist:
 	 */
 	VM_BUG_ON(c->page->freelist == c->page->end);
 
-	if (unlikely(state & SLABDEBUG))
+	if (unlikely((state & SLABDEBUG) || c->reserve))
 		goto debug;
 
 	object = c->page->freelist;
@@ -1615,7 +1629,7 @@ grow_slab:
 /* Perform debugging */
 debug:
 	object = c->page->freelist;
-	if (!alloc_debug_processing(s, c->page, object, addr))
+	if ((state & SLABDEBUG) && !alloc_debug_processing(s, c->page, object, addr))
 		goto another_slab;
 
 	c->page->inuse++;
@@ -2156,10 +2170,11 @@ static struct kmem_cache_node *early_kme
 	struct page *page;
 	struct kmem_cache_node *n;
 	unsigned long flags;
+	int reserve;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags, node);
+	page = new_slab(kmalloc_caches, gfpflags, node, &reserve);
 
 	BUG_ON(!page);
 	if (page_to_nid(page) != node) {
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h
+++ linux-2.6/include/linux/slub_def.h
@@ -18,6 +18,7 @@ struct kmem_cache_cpu {
 	unsigned int offset;	/* Freepointer offset (in word units) */
 	unsigned int objsize;	/* Size of an object (from kmem_cache) */
 	unsigned int objects;	/* Objects per slab (from kmem_cache) */
+	int reserve;		/* Did the current page come from the reserve */
 };
 
 struct kmem_cache_node {
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -115,6 +115,8 @@
 #include	<asm/tlbflush.h>
 #include	<asm/page.h>
 
+#include 	"internal.h"
+
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_RED_ZONE & SLAB_POISON.
  *		  0 for faster, smaller code (especially in the critical paths).
@@ -265,7 +267,8 @@ struct array_cache {
 	unsigned int avail;
 	unsigned int limit;
 	unsigned int batchcount;
-	unsigned int touched;
+	unsigned int touched:1,
+		     reserve:1;
 	spinlock_t lock;
 	void *entry[];	/*
 			 * Must have this definition in here for the proper
@@ -762,6 +765,27 @@ static inline struct array_cache *cpu_ca
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
@@ -961,6 +985,7 @@ static struct array_cache *alloc_arrayca
 		nc->limit = entries;
 		nc->batchcount = batchcount;
 		nc->touched = 0;
+		nc->reserve = 0;
 		spin_lock_init(&nc->lock);
 	}
 	return nc;
@@ -1650,7 +1675,8 @@ __initcall(cpucache_init);
  * did not request dmaable memory, we might get it, but that
  * would be relatively rare and ignorable.
  */
-static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
+static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid,
+		int *reserve)
 {
 	struct page *page;
 	int nr_pages;
@@ -1672,6 +1698,7 @@ static void *kmem_getpages(struct kmem_c
 	if (!page)
 		return NULL;
 
+	*reserve = page->reserve;
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		add_zone_page_state(page_zone(page),
@@ -2116,6 +2143,7 @@ static int __init_refok setup_cpu_cache(
 	cpu_cache_get(cachep)->limit = BOOT_CPUCACHE_ENTRIES;
 	cpu_cache_get(cachep)->batchcount = 1;
 	cpu_cache_get(cachep)->touched = 0;
+	cpu_cache_get(cachep)->reserve = 0;
 	cachep->batchcount = 1;
 	cachep->limit = BOOT_CPUCACHE_ENTRIES;
 	return 0;
@@ -2764,6 +2792,7 @@ static int cache_grow(struct kmem_cache 
 	size_t offset;
 	gfp_t local_flags;
 	struct kmem_list3 *l3;
+	int reserve;
 
 	/*
 	 * Be lazy and only check for valid flags here,  keeping it out of the
@@ -2802,7 +2831,7 @@ static int cache_grow(struct kmem_cache 
 	 * 'nodeid'.
 	 */
 	if (!objp)
-		objp = kmem_getpages(cachep, local_flags, nodeid);
+		objp = kmem_getpages(cachep, local_flags, nodeid, &reserve);
 	if (!objp)
 		goto failed;
 
@@ -2820,6 +2849,7 @@ static int cache_grow(struct kmem_cache 
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	check_irq_off();
+	slab_set_reserve(cachep, reserve);
 	spin_lock(&l3->list_lock);
 
 	/* Make slab active. */
@@ -2954,7 +2984,7 @@ bad:
 #define check_slabp(x,y) do { } while(0)
 #endif
 
-static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
+static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags, int must_refill)
 {
 	int batchcount;
 	struct kmem_list3 *l3;
@@ -2964,6 +2994,8 @@ static void *cache_alloc_refill(struct k
 	node = numa_node_id();
 
 	check_irq_off();
+	if (unlikely(must_refill))
+		goto force_grow;
 	ac = cpu_cache_get(cachep);
 retry:
 	batchcount = ac->batchcount;
@@ -3032,11 +3064,14 @@ alloc_done:
 
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
@@ -3191,17 +3226,18 @@ static inline void *____cache_alloc(stru
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
 	return objp;
 }
@@ -3243,7 +3279,7 @@ static void *fallback_alloc(struct kmem_
 	gfp_t local_flags;
 	struct zone **z;
 	void *obj = NULL;
-	int nid;
+	int nid, reserve;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
@@ -3277,10 +3313,11 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, flags, -1);
+		obj = kmem_getpages(cache, flags, -1, &reserve);
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {
+			slab_set_reserve(cache, reserve);
 			/*
 			 * Insert into the appropriate per node queues
 			 */
@@ -3319,6 +3356,9 @@ static void *____cache_alloc_node(struct
 	l3 = cachep->nodelists[nodeid];
 	BUG_ON(!l3);
 
+	if (unlikely(slab_force_alloc(cachep, flags)))
+		goto force_grow;
+
 retry:
 	check_irq_off();
 	spin_lock(&l3->list_lock);
@@ -3356,6 +3396,7 @@ retry:
 
 must_grow:
 	spin_unlock(&l3->list_lock);
+force_grow:
 	x = cache_grow(cachep, flags | GFP_THISNODE, nodeid, NULL);
 	if (x)
 		goto retry;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
