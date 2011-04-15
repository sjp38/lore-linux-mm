Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C5F85900096
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:06 -0400 (EDT)
Message-Id: <20110415201303.659996282@linux.com>
Date: Fri, 15 Apr 2011 15:13:01 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: Invert locking and avoid slab lock
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=slab_lock_subsume
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Locking slabs is no longer necesary if the arch supports cmpxchg operations
and if no debuggin features are used on a slab. If the arch does not support
cmpxchg then we fallback to use the slab lock to do a cmpxchg like operation.

The patch also changes the lock order. Slab locks are subsumed to the node lock
now. With that approach slab_trylocking is no longer necessary.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |  131 +++++++++++++++++++++++++-------------------------------------
 1 file changed, 53 insertions(+), 78 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 14:29:57.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 14:30:01.000000000 -0500
@@ -2,10 +2,11 @@
  * SLUB: A slab allocator that limits cache line use instead of queuing
  * objects in per cpu and per node lists.
  *
- * The allocator synchronizes using per slab locks and only
- * uses a centralized lock to manage a pool of partial slabs.
+ * The allocator synchronizes using per slab locks or atomic operatios
+ * and only uses a centralized lock to manage a pool of partial slabs.
  *
  * (C) 2007 SGI, Christoph Lameter
+ * (C) 2011 Linux Foundation, Christoph Lameter
  */
 
 #include <linux/mm.h>
@@ -32,15 +33,27 @@
 
 /*
  * Lock order:
- *   1. slab_lock(page)
- *   2. slab->list_lock
- *
- *   The slab_lock protects operations on the object of a particular
- *   slab and its metadata in the page struct. If the slab lock
- *   has been taken then no allocations nor frees can be performed
- *   on the objects in the slab nor can the slab be added or removed
- *   from the partial or full lists since this would mean modifying
- *   the page_struct of the slab.
+ *   1. slub_lock (Global Semaphore)
+ *   2. node->list_lock
+ *   3. slab_lock(page) (Only on some arches and for debugging)
+ *
+ *   slub_lock
+ *
+ *   The role of the slub_lock is to protect the list of all the slabs
+ *   and to synchronize major metadata changes to slab cache structures.
+ *
+ *   The slab_lock is only used for debugging and on arches that do not
+ *   have the ability to do a cmpxchg_double. It only protects the second
+ *   double word in the page struct. Meaning
+ *	A. page->freelist	-> List of object free in a page
+ *	B. page->counters	-> Counters of objects
+ *	C. page->frozen		-> frozen state
+ *
+ *   If a slab is frozen then it is exempt from list management. It is not
+ *   on any list. The processor that froze the slab is the one who can
+ *   perform list operations on the page. Other processors may put objects
+ *   onto the freelist but the processor that froze the slab is the only
+ *   one that can retrieve the objects from the page's freelist.
  *
  *   The list_lock protects the partial and full list on each node and
  *   the partial slab counter. If taken then no new slabs may be added or
@@ -53,20 +66,6 @@
  *   slabs, operations can continue without any centralized lock. F.e.
  *   allocating a long series of objects that fill up slabs does not require
  *   the list lock.
- *
- *   The lock order is sometimes inverted when we are trying to get a slab
- *   off a list. We take the list_lock and then look for a page on the list
- *   to use. While we do that objects in the slabs may be freed. We can
- *   only operate on the slab if we have also taken the slab_lock. So we use
- *   a slab_trylock() on the slab. If trylock was successful then no frees
- *   can occur anymore and we can use the slab for allocations etc. If the
- *   slab_trylock() does not succeed then frees are in progress in the slab and
- *   we must stay away from it for a while since we may cause a bouncing
- *   cacheline if we try to acquire the lock. So go onto the next slab.
- *   If all pages are busy then we may allocate a new slab instead of reusing
- *   a partial slab. A new slab has no one operating on it and thus there is
- *   no danger of cacheline contention.
- *
  *   Interrupts are disabled during allocation and deallocation in order to
  *   make the slab allocator safe to use in the context of an irq. In addition
  *   interrupts are disabled to ensure that the processor does not change
@@ -330,6 +329,19 @@ static inline int oo_objects(struct kmem
 	return x.x & OO_MASK;
 }
 
+/*
+ * Per slab locking using the pagelock
+ */
+static __always_inline void slab_lock(struct page *page)
+{
+	bit_spin_lock(PG_locked, &page->flags);
+}
+
+static __always_inline void slab_unlock(struct page *page)
+{
+	__bit_spin_unlock(PG_locked, &page->flags);
+}
+
 static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		void *freelist_old, unsigned long counters_old,
 		void *freelist_new, unsigned long counters_new,
@@ -344,11 +356,14 @@ static inline bool cmpxchg_double_slab(s
 	} else
 #endif
 	{
+		slab_lock(page);
 		if (page->freelist == freelist_old && page->counters == counters_old) {
 			page->freelist = freelist_new;
 			page->counters = counters_new;
+			slab_unlock(page);
 			return 1;
 		}
+		slab_unlock(page);
 	}
 
 	cpu_relax();
@@ -364,7 +379,7 @@ static inline bool cmpxchg_double_slab(s
 /*
  * Determine a map of object in use on a page.
  *
- * Slab lock or node listlock must be held to guarantee that the page does
+ * Node listlock must be held to guarantee that the page does
  * not vanish from under us.
  */
 static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
@@ -796,10 +811,11 @@ static int check_slab(struct kmem_cache
 static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 {
 	int nr = 0;
-	void *fp = page->freelist;
+	void *fp;
 	void *object = NULL;
 	unsigned long max_objects;
 
+	fp = page->freelist;
 	while (fp && nr <= page->objects) {
 		if (fp == search)
 			return 1;
@@ -1007,6 +1023,8 @@ bad:
 static noinline int free_debug_processing(struct kmem_cache *s,
 		 struct page *page, void *object, unsigned long addr)
 {
+	slab_lock(page);
+
 	if (!check_slab(s, page))
 		goto fail;
 
@@ -1042,10 +1060,12 @@ static noinline int free_debug_processin
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
 	init_object(s, object, SLUB_RED_INACTIVE);
+	slab_unlock(page);
 	return 1;
 
 fail:
 	slab_fix(s, "Object at 0x%p not freed", object);
+	slab_unlock(page);
 	return 0;
 }
 
@@ -1365,27 +1385,6 @@ static void discard_slab(struct kmem_cac
 }
 
 /*
- * Per slab locking using the pagelock
- */
-static __always_inline void slab_lock(struct page *page)
-{
-	bit_spin_lock(PG_locked, &page->flags);
-}
-
-static __always_inline void slab_unlock(struct page *page)
-{
-	__bit_spin_unlock(PG_locked, &page->flags);
-}
-
-static __always_inline int slab_trylock(struct page *page)
-{
-	int rc = 1;
-
-	rc = bit_spin_trylock(PG_locked, &page->flags);
-	return rc;
-}
-
-/*
  * Management of partially allocated slabs
  */
 static inline void add_partial(struct kmem_cache_node *n,
@@ -1411,17 +1410,13 @@ static inline void remove_partial(struct
  *
  * Must hold list_lock.
  */
-static inline int lock_and_freeze_slab(struct kmem_cache *s,
+static inline int acquire_slab(struct kmem_cache *s,
 		struct kmem_cache_node *n, struct page *page)
 {
 	void *freelist;
 	unsigned long counters;
 	struct page new;
 
-
-	if (!slab_trylock(page))
-		return 0;
-
 	/*
 	 * Zap the freelist and set the frozen bit.
 	 * The old freelist is the list of objects for the
@@ -1457,7 +1452,6 @@ static inline int lock_and_freeze_slab(s
 		 */
 		printk(KERN_ERR "SLUB: %s : Page without available objects on"
 			" partial list\n", s->name);
-		slab_unlock(page);
 		return 0;
 	}
 }
@@ -1481,7 +1475,7 @@ static struct page *get_partial_node(str
 
 	spin_lock(&n->list_lock);
 	list_for_each_entry(page, &n->partial, lru)
-		if (lock_and_freeze_slab(s, n, page))
+		if (acquire_slab(s, n, page))
 			goto out;
 	page = NULL;
 out:
@@ -1778,8 +1772,6 @@ redo:
 				"unfreezing slab"))
 		goto redo;
 
-	slab_unlock(page);
-
 	if (lock)
 		spin_unlock(&n->list_lock);
 
@@ -1792,7 +1784,6 @@ redo:
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	stat(s, CPUSLAB_FLUSH);
-	slab_lock(c->page);
 	deactivate_slab(s, c);
 }
 
@@ -1941,7 +1932,6 @@ static void *__slab_alloc(struct kmem_ca
 	if (!page)
 		goto new_slab;
 
-	slab_lock(page);
 	if (unlikely(!node_match(c, node)))
 		goto another_slab;
 
@@ -1970,8 +1960,6 @@ load_freelist:
 	if (unlikely(!object))
 		goto another_slab;
 
-	slab_unlock(page);
-
 	c->freelist = get_freepointer(s, object);
 
 #ifdef CONFIG_CMPXCHG_LOCAL
@@ -2022,7 +2010,6 @@ load_from_page:
 		c->page = page;
 
 		stat(s, ALLOC_SLAB);
-		slab_lock(page);
 
 		goto load_from_page;
 	}
@@ -2235,7 +2222,6 @@ static void __slab_free(struct kmem_cach
 
 	local_irq_save(flags);
 #endif
-	slab_lock(page);
 	stat(s, FREE_SLOWPATH);
 
 	if (kmem_cache_debug(s) && !free_debug_processing(s, page, x, addr))
@@ -2301,7 +2287,6 @@ static void __slab_free(struct kmem_cach
 	spin_unlock(&n->list_lock);
 
 out_unlock:
-	slab_unlock(page);
 #ifdef CONFIG_CMPXCHG_LOCAL
 	local_irq_restore(flags);
 #endif
@@ -2317,7 +2302,6 @@ slab_empty:
 	}
 
 	spin_unlock(&n->list_lock);
-	slab_unlock(page);
 #ifdef CONFIG_CMPXCHG_LOCAL
 	local_irq_restore(flags);
 #endif
@@ -3258,14 +3242,8 @@ int kmem_cache_shrink(struct kmem_cache
 		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse && slab_trylock(page)) {
-				/*
-				 * Must hold slab lock here because slab_free
-				 * may have freed the last object and be
-				 * waiting to release the slab.
-				 */
+			if (!page->inuse) {
 				remove_partial(n, page);
-				slab_unlock(page);
 				discard_slab(s, page);
 			} else {
 				list_move(&page->lru,
@@ -3853,12 +3831,9 @@ static int validate_slab(struct kmem_cac
 static void validate_slab_slab(struct kmem_cache *s, struct page *page,
 						unsigned long *map)
 {
-	if (slab_trylock(page)) {
-		validate_slab(s, page, map);
-		slab_unlock(page);
-	} else
-		printk(KERN_INFO "SLUB %s: Skipped busy slab 0x%p\n",
-			s->name, page);
+	slab_lock(page);
+	validate_slab(s, page, map);
+	slab_unlock(page);
 }
 
 static int validate_slab_node(struct kmem_cache *s,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
