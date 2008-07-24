Message-Id: <20080724141529.560025894@chello.nl>
References: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:00:46 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 04/30] mm: slub: trivial cleanups
Content-Disposition: inline; filename=cleanup-slub.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Some cleanups....

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slub_def.h |    7 ++++++-
 mm/slub.c                |   40 ++++++++++++++++++----------------------
 2 files changed, 24 insertions(+), 23 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -27,7 +27,7 @@
 /*
  * Lock order:
  *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   2. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -163,11 +163,11 @@ static struct notifier_block slab_notifi
 #endif
 
 static enum {
-	DOWN,		/* No slab functionality available */
+	DOWN = 0,	/* No slab functionality available */
 	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
 	UP,		/* Everything works but does not show up in sysfs */
 	SYSFS		/* Sysfs up */
-} slab_state = DOWN;
+} slab_state;
 
 /* A list of all slab caches on the system */
 static DECLARE_RWSEM(slub_lock);
@@ -288,21 +288,22 @@ static inline int slab_index(void *p, st
 static inline struct kmem_cache_order_objects oo_make(int order,
 						unsigned long size)
 {
-	struct kmem_cache_order_objects x = {
-		(order << 16) + (PAGE_SIZE << order) / size
-	};
+	struct kmem_cache_order_objects x;
+
+	x.order = order;
+	x.objects = (PAGE_SIZE << order) / size;
 
 	return x;
 }
 
 static inline int oo_order(struct kmem_cache_order_objects x)
 {
-	return x.x >> 16;
+	return x.order;
 }
 
 static inline int oo_objects(struct kmem_cache_order_objects x)
 {
-	return x.x & ((1 << 16) - 1);
+	return x.objects;
 }
 
 #ifdef CONFIG_SLUB_DEBUG
@@ -1076,8 +1077,7 @@ static struct page *allocate_slab(struct
 
 	flags |= s->allocflags;
 
-	page = alloc_slab_page(flags | __GFP_NOWARN | __GFP_NORETRY, node,
-									oo);
+	page = alloc_slab_page(flags | __GFP_NOWARN | __GFP_NORETRY, node, oo);
 	if (unlikely(!page)) {
 		oo = s->min;
 		/*
@@ -1099,8 +1099,7 @@ static struct page *allocate_slab(struct
 	return page;
 }
 
-static void setup_object(struct kmem_cache *s, struct page *page,
-				void *object)
+static void setup_object(struct kmem_cache *s, struct page *page, void *object)
 {
 	setup_object_debug(s, page, object);
 	if (unlikely(s->ctor))
@@ -1157,8 +1156,7 @@ static void __free_slab(struct kmem_cach
 		void *p;
 
 		slab_pad_check(s, page);
-		for_each_object(p, s, page_address(page),
-						page->objects)
+		for_each_object(p, s, page_address(page), page->objects)
 			check_object(s, page, p, 0);
 		__ClearPageSlubDebug(page);
 	}
@@ -1224,8 +1222,7 @@ static __always_inline int slab_trylock(
 /*
  * Management of partially allocated slabs
  */
-static void add_partial(struct kmem_cache_node *n,
-				struct page *page, int tail)
+static void add_partial(struct kmem_cache_node *n, struct page *page, int tail)
 {
 	spin_lock(&n->list_lock);
 	n->nr_partial++;
@@ -1251,8 +1248,8 @@ static void remove_partial(struct kmem_c
  *
  * Must hold list_lock.
  */
-static inline int lock_and_freeze_slab(struct kmem_cache_node *n,
-							struct page *page)
+static inline
+int lock_and_freeze_slab(struct kmem_cache_node *n, struct page *page)
 {
 	if (slab_trylock(page)) {
 		list_del(&page->lru);
@@ -1799,11 +1796,11 @@ static int slub_nomerge;
  * slub_max_order specifies the order where we begin to stop considering the
  * number of objects in a slab as critical. If we reach slub_max_order then
  * we try to keep the page order as low as possible. So we accept more waste
- * of space in favor of a small page order.
+ * of space in favour of a small page order.
  *
  * Higher order allocations also allow the placement of more objects in a
  * slab and thereby reduce object handling overhead. If the user has
- * requested a higher mininum order then we start with that one instead of
+ * requested a higher minimum order then we start with that one instead of
  * the smallest order which will fit the object.
  */
 static inline int slab_order(int size, int min_objects,
@@ -1816,8 +1813,7 @@ static inline int slab_order(int size, i
 	if ((PAGE_SIZE << min_order) / size > 65535)
 		return get_order(size * 65535) - 1;
 
-	for (order = max(min_order,
-				fls(min_objects * size - 1) - PAGE_SHIFT);
+	for (order = max(min_order, fls(min_objects * size - 1) - PAGE_SHIFT);
 			order <= max_order; order++) {
 
 		unsigned long slab_size = PAGE_SIZE << order;
Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h
+++ linux-2.6/include/linux/slub_def.h
@@ -60,7 +60,12 @@ struct kmem_cache_node {
  * given order would contain.
  */
 struct kmem_cache_order_objects {
-	unsigned long x;
+	union {
+		u32 x;
+		struct {
+			u16 order, objects;
+		};
+	};
 };
 
 /*

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
