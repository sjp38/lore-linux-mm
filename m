Message-Id: <20070925233008.017150472@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:54 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 11/14] SLUB: Consolidate add_partial() and add_partial_tail() to one function
Content-Disposition: inline; filename=0008-slab_defrag_add_partial_tail.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a parameter to add_partial instead of having separate functions.
The parameter allows a more detailed control of where the slab pages
is placed in the partial queues.

If we put slabs back to the front then they are likely immediately used
for allocations. If they are put at the end then we can maximize the time
that the partial slabs spent without being subject to allocations.

When deactivating slab we can put the slabs that had remote objects freed
(we can see that because objects were put on the freelist that requires locks)
to them at the end of the list so that the cachelines of remote processors can
cool down. Slabs that had objects from the local cpu freed to them (objects
exist in the lockless freelist) are put in the front of the list to be reused
ASAP in order to exploit the cache hot state of the local cpu.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

Index: linux-2.6.23-rc8-mm1/mm/slub.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/slub.c	2007-09-25 14:54:43.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/slub.c	2007-09-25 14:55:49.000000000 -0700
@@ -1203,19 +1203,15 @@ static __always_inline int slab_trylock(
 /*
  * Management of partially allocated slabs
  */
-static void add_partial_tail(struct kmem_cache_node *n, struct page *page)
+static void add_partial(struct kmem_cache_node *n,
+				struct page *page, int tail)
 {
 	spin_lock(&n->list_lock);
 	n->nr_partial++;
-	list_add_tail(&page->lru, &n->partial);
-	spin_unlock(&n->list_lock);
-}
-
-static void add_partial(struct kmem_cache_node *n, struct page *page)
-{
-	spin_lock(&n->list_lock);
-	n->nr_partial++;
-	list_add(&page->lru, &n->partial);
+	if (tail)
+		list_add_tail(&page->lru, &n->partial);
+	else
+		list_add(&page->lru, &n->partial);
 	spin_unlock(&n->list_lock);
 }
 
@@ -1344,7 +1340,7 @@ static struct page *get_partial(struct k
  *
  * On exit the slab lock will have been dropped.
  */
-static void unfreeze_slab(struct kmem_cache *s, struct page *page)
+static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
@@ -1352,7 +1348,7 @@ static void unfreeze_slab(struct kmem_ca
 	if (page->inuse) {
 
 		if (page->freelist)
-			add_partial(n, page);
+			add_partial(n, page, tail);
 		else if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
 			add_full(n, page);
 		slab_unlock(page);
@@ -1367,7 +1363,7 @@ static void unfreeze_slab(struct kmem_ca
 			 * partial list stays small. kmem_cache_shrink can
 			 * reclaim empty slabs from the partial list.
 			 */
-			add_partial_tail(n, page);
+			add_partial(n, page, 1);
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
@@ -1382,6 +1378,7 @@ static void unfreeze_slab(struct kmem_ca
 static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	struct page *page = c->page;
+	int tail = 1;
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely
@@ -1390,6 +1387,8 @@ static void deactivate_slab(struct kmem_
 	while (unlikely(c->freelist)) {
 		void **object;
 
+		tail = 0;	/* Hot objects. Put the slab first */
+
 		/* Retrieve object from cpu_freelist */
 		object = c->freelist;
 		c->freelist = c->freelist[c->offset];
@@ -1400,7 +1399,7 @@ static void deactivate_slab(struct kmem_
 		page->inuse--;
 	}
 	c->page = NULL;
-	unfreeze_slab(s, page);
+	unfreeze_slab(s, page, tail);
 }
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
@@ -1640,7 +1639,7 @@ checks_ok:
 	 * then add it.
 	 */
 	if (unlikely(!prior))
-		add_partial(get_node(s, page_to_nid(page)), page);
+		add_partial(get_node(s, page_to_nid(page)), page, 0);
 
 out_unlock:
 	slab_unlock(page);
@@ -2047,7 +2046,7 @@ static struct kmem_cache_node *early_kme
 #endif
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
-	add_partial(n, page);
+	add_partial(n, page, 0);
 	return n;
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
