Date: Mon, 7 May 2007 18:49:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: Regression with SLUB on Netperf and Volanomark
In-Reply-To: <1178584834.15701.18.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0705071848300.1378@schroedinger.engr.sgi.com>
References: <9D2C22909C6E774EBFB8B5583AE5291C02786032@fmsmsx414.amr.corp.intel.com>
  <Pine.LNX.4.64.0705031839480.16296@schroedinger.engr.sgi.com>
 <1178322083.23795.217.camel@localhost.localdomain>
 <Pine.LNX.4.64.0705041800070.28492@schroedinger.engr.sgi.com>
 <1178584834.15701.18.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, "Siddha, Suresh B" <suresh.b.siddha@intel.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "Wang, Peter Xihong" <peter.xihong.wang@intel.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 May 2007, Tim Chen wrote:

> However, the output from TCP_STREAM is quite stable.  
> I am still seeing a 4% difference between the SLAB and SLUB kernel.
> Looking at the L2 cache miss rate with emon, I saw 6% more cache miss on
> the client side with SLUB.  The server side has the same amount of cache
> miss.  This is test under SMP mode with client and server bound to
> different core on separate package.

Could you try the following patch on top of 2.6.21-mm1 with the patches
from http://ftp.kernel.org/pub/linux/kernel/people/christoph/slub-patches?

I sent it to you before. This is one is an updated version



Avoid atomic overhead in slab_alloc and slab_free

SLUB needs to use the slab_lock for the per cpu slabs to synchronize
with potential kfree operations. This patch avoids that need by moving
all free objects onto a lockless_freelist. The regular freelist
continues to exist and will be used to free objects. So while we consume
the lockless_freelist the regular freelist may build up objects.
If we are out of objects on the lockless_freelist then we may check
the regular freelist. If it has objects then we move those over to the
lockless_freelist and do this again. There is a significant savings
in terms of atomic operations that have to be performed.

We can even free directly to the lockless_freelist if we know that we
are running on the same processor. So this speeds up short lived
objects. The may be allocated and frees without taking the slab_lock.
This is particular good for netperf.

In order to maximize the effect of the new faster hotpath we extract the
hottest performance pieces into inlined functions. These are then inlined
into kmem_cache_alloc and kmem_cache_free. So the hotpath allocation and
freeing no longer requires a subroutine call within SLUB.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm_types.h |    7 +-
 mm/slub.c                |  154 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 123 insertions(+), 38 deletions(-)

Index: slub/include/linux/mm_types.h
===================================================================
--- slub.orig/include/linux/mm_types.h	2007-05-07 17:31:11.000000000 -0700
+++ slub/include/linux/mm_types.h	2007-05-07 17:33:54.000000000 -0700
@@ -50,13 +50,16 @@ struct page {
 	    spinlock_t ptl;
 #endif
 	    struct {			/* SLUB uses */
-		struct page *first_page;	/* Compound pages */
+	    	void **lockless_freelist;
 		struct kmem_cache *slab;	/* Pointer to slab */
 	    };
+	    struct {
+		struct page *first_page;	/* Compound pages */
+	    };
 	};
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
-		void *freelist;		/* SLUB: pointer to free object */
+		void *freelist;		/* SLUB: freelist req. slab lock */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 17:31:11.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 17:33:54.000000000 -0700
@@ -81,10 +81,14 @@
  * PageActive 		The slab is used as a cpu cache. Allocations
  * 			may be performed from the slab. The slab is not
  * 			on any slab list and cannot be moved onto one.
+ * 			The cpu slab may be equipped with an additioanl
+ * 			lockless_freelist that allows lockless access to
+ * 			free objects in addition to the regular freelist
+ * 			that requires the slab lock.
  *
  * PageError		Slab requires special handling due to debug
  * 			options set. This moves	slab handling out of
- * 			the fast path.
+ * 			the fast path and disables lockless freelists.
  */
 
 static inline int SlabDebug(struct page *page)
@@ -1016,6 +1020,7 @@ static struct page *new_slab(struct kmem
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
+	page->lockless_freelist = NULL;
 	page->inuse = 0;
 out:
 	if (flags & __GFP_WAIT)
@@ -1278,6 +1283,23 @@ static void putback_slab(struct kmem_cac
  */
 static void deactivate_slab(struct kmem_cache *s, struct page *page, int cpu)
 {
+	/*
+	 * Merge cpu freelist into freelist. Typically we get here
+	 * because both freelists are empty. So this is unlikely
+	 * to occur.
+	 */
+	while (unlikely(page->lockless_freelist)) {
+		void **object;
+
+		/* Retrieve object from cpu_freelist */
+		object = page->lockless_freelist;
+		page->lockless_freelist = page->lockless_freelist[page->offset];
+
+		/* And put onto the regular freelist */
+		object[page->offset] = page->freelist;
+		page->freelist = object;
+		page->inuse--;
+	}
 	s->cpu_slab[cpu] = NULL;
 	ClearPageActive(page);
 
@@ -1324,47 +1346,46 @@ static void flush_all(struct kmem_cache 
 }
 
 /*
- * slab_alloc is optimized to only modify two cachelines on the fast path
- * (aside from the stack):
+ * Slow path. The lockless freelist is empty or we need to perform
+ * debugging duties.
  *
- * 1. The page struct
- * 2. The first cacheline of the object to be allocated.
+ * Interrupts are disabled.
  *
- * The only other cache lines that are read (apart from code) is the
- * per cpu array in the kmem_cache struct.
+ * Processing is still very fast if new objects have been freed to the
+ * regular freelist. In that case we simply take over the regular freelist
+ * as the lockless freelist and zap the regular freelist.
  *
- * Fastpath is not possible if we need to get a new slab or have
- * debugging enabled (which means all slabs are marked with SlabDebug)
+ * If that is not working then we fall back to the partial lists. We take the
+ * first element of the freelist as the object to allocate now and move the
+ * rest of the freelist to the lockless freelist.
+ *
+ * And if we were unable to get a new slab from the partial slab lists then
+ * we need to allocate a new slab. This is slowest path since we may sleep.
  */
-static void *slab_alloc(struct kmem_cache *s,
-				gfp_t gfpflags, int node, void *addr)
+static void *__slab_alloc(struct kmem_cache *s,
+		gfp_t gfpflags, int node, void *addr, struct page *page)
 {
-	struct page *page;
 	void **object;
-	unsigned long flags;
-	int cpu;
+	int cpu = smp_processor_id();
 
-	local_irq_save(flags);
-	cpu = smp_processor_id();
-	page = s->cpu_slab[cpu];
 	if (!page)
 		goto new_slab;
 
 	slab_lock(page);
 	if (unlikely(node != -1 && page_to_nid(page) != node))
 		goto another_slab;
-redo:
+load_freelist:
 	object = page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
 	if (unlikely(SlabDebug(page)))
 		goto debug;
 
-have_object:
-	page->inuse++;
-	page->freelist = object[page->offset];
+	object = page->freelist;
+	page->lockless_freelist = object[page->offset];
+	page->inuse = s->objects;
+	page->freelist = NULL;
 	slab_unlock(page);
-	local_irq_restore(flags);
 	return object;
 
 another_slab:
@@ -1372,11 +1393,11 @@ another_slab:
 
 new_slab:
 	page = get_partial(s, gfpflags, node);
-	if (likely(page)) {
+	if (page) {
 have_slab:
 		s->cpu_slab[cpu] = page;
 		SetPageActive(page);
-		goto redo;
+		goto load_freelist;
 	}
 
 	page = new_slab(s, gfpflags, node);
@@ -1399,7 +1420,7 @@ have_slab:
 				discard_slab(s, page);
 				page = s->cpu_slab[cpu];
 				slab_lock(page);
-				goto redo;
+				goto load_freelist;
 			}
 			/* New slab does not fit our expectations */
 			flush_slab(s, s->cpu_slab[cpu], cpu);
@@ -1407,16 +1428,52 @@ have_slab:
 		slab_lock(page);
 		goto have_slab;
 	}
-	local_irq_restore(flags);
 	return NULL;
 debug:
+	object = page->freelist;
 	if (!alloc_object_checks(s, page, object))
 		goto another_slab;
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_ALLOC, addr);
 	trace(s, page, object, 1);
 	init_object(s, object, 1);
-	goto have_object;
+
+	page->inuse++;
+	page->freelist = object[page->offset];
+	slab_unlock(page);
+	return object;
+}
+
+/*
+ * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
+ * have the fastpath folded into their functions. So no function call
+ * overhead for requests that can be satisfied on the fastpath.
+ *
+ * The fastpath works by first checking if the lockless freelist can be used.
+ * If not then __slab_alloc is called for slow processing.
+ *
+ * Otherwise we can simply pick the next object from the lockless free list.
+ */
+static void __always_inline *slab_alloc(struct kmem_cache *s,
+				gfp_t gfpflags, int node, void *addr)
+{
+	struct page *page;
+	void **object;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	page = s->cpu_slab[smp_processor_id()];
+	if (unlikely(!page || !page->lockless_freelist ||
+			(node != -1 && page_to_nid(page) != node)))
+
+		object = __slab_alloc(s, gfpflags, node, addr, page);
+
+	else {
+		object = page->lockless_freelist;
+		page->lockless_freelist = object[page->offset];
+	}
+	local_irq_restore(flags);
+	return object;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
@@ -1434,20 +1491,19 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
 
 /*
- * The fastpath only writes the cacheline of the page struct and the first
- * cacheline of the object.
+ * Slow patch handling. This may still be called frequently since objects
+ * have a longer lifetime than the cpu slabs in most processing loads.
  *
- * We read the cpu_slab cacheline to check if the slab is the per cpu
- * slab for this processor.
+ * So we still attempt to reduce cache line usage. Just take the slab
+ * lock and free the item. If there is no additional partial page
+ * handling required then we can return immediately.
  */
-static void slab_free(struct kmem_cache *s, struct page *page,
+static void __slab_free(struct kmem_cache *s, struct page *page,
 					void *x, void *addr)
 {
 	void *prior;
 	void **object = (void *)x;
-	unsigned long flags;
 
-	local_irq_save(flags);
 	slab_lock(page);
 
 	if (unlikely(SlabDebug(page)))
@@ -1477,7 +1533,6 @@ checks_ok:
 
 out_unlock:
 	slab_unlock(page);
-	local_irq_restore(flags);
 	return;
 
 slab_empty:
@@ -1489,7 +1544,6 @@ slab_empty:
 
 	slab_unlock(page);
 	discard_slab(s, page);
-	local_irq_restore(flags);
 	return;
 
 debug:
@@ -1504,6 +1558,34 @@ debug:
 	goto checks_ok;
 }
 
+/*
+ * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
+ * can perform fastpath freeing without additional function calls.
+ *
+ * The fastpath is only possible if we are freeing to the current cpu slab
+ * of this processor. This typically the case if we have just allocated
+ * the item before.
+ *
+ * If fastpath is not possible then fall back to __slab_free where we deal
+ * with all sorts of special processing.
+ */
+static void __always_inline slab_free(struct kmem_cache *s,
+			struct page *page, void *x, void *addr)
+{
+	void **object = (void *)x;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	if (likely(page == s->cpu_slab[smp_processor_id()] &&
+						!SlabDebug(page))) {
+		object[page->offset] = page->lockless_freelist;
+		page->lockless_freelist = object;
+	} else
+		__slab_free(s, page, x, addr);
+
+	local_irq_restore(flags);
+}
+
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
 	struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
