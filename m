From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 08/26] SLUB: Consolidate add_partial and add_partial_tail to one function
Date: Fri, 31 Aug 2007 18:41:15 -0700
Message-ID: <20070901014221.148426921@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0008-slab_defrag_add_partial_tail.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Add a parameter to add_partial instead of having separate functions.
That allows the detailed control from multiple places when putting
slabs back to the partial list. If we put slabs back to the front
then they are likely used immediately for allocations. If they are
put at the end then we can maximize the time that the partial slabs
spent without allocations.

When deactivating slab we can put the slabs that had remote objects freed
to them at the end of the list so that the cachelines can cool down.
Slabs that had objects from the cpu freed to them are put in the front
of the list to be reused ASAP.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-08-28 20:03:16.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-28 20:21:55.000000000 -0700
@@ -1173,19 +1173,15 @@ static __always_inline int slab_trylock(
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
 
@@ -1314,7 +1310,7 @@ static struct page *get_partial(struct k
  *
  * On exit the slab lock will have been dropped.
  */
-static void unfreeze_slab(struct kmem_cache *s, struct page *page)
+static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
@@ -1322,7 +1318,7 @@ static void unfreeze_slab(struct kmem_ca
 	if (page->inuse) {
 
 		if (page->freelist)
-			add_partial(n, page);
+			add_partial(n, page, tail);
 		else if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
 			add_full(n, page);
 		slab_unlock(page);
@@ -1337,7 +1333,7 @@ static void unfreeze_slab(struct kmem_ca
 			 * partial list stays small. kmem_cache_shrink can
 			 * reclaim empty slabs from the partial list.
 			 */
-			add_partial_tail(n, page);
+			add_partial(n, page, 1);
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
@@ -1352,6 +1348,7 @@ static void unfreeze_slab(struct kmem_ca
 static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	struct page *page = c->page;
+	int tail = 1;
 	/*
 	 * Merge cpu freelist into freelist. Typically we get here
 	 * because both freelists are empty. So this is unlikely
@@ -1360,6 +1357,8 @@ static void deactivate_slab(struct kmem_
 	while (unlikely(c->freelist)) {
 		void **object;
 
+		tail = 0;	/* Hot objects. Put the slab first */
+
 		/* Retrieve object from cpu_freelist */
 		object = c->freelist;
 		c->freelist = c->freelist[c->offset];
@@ -1370,7 +1369,7 @@ static void deactivate_slab(struct kmem_
 		page->inuse--;
 	}
 	c->page = NULL;
-	unfreeze_slab(s, page);
+	unfreeze_slab(s, page, tail);
 }
 
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
@@ -1603,7 +1602,7 @@ checks_ok:
 	 * then add it.
 	 */
 	if (unlikely(!prior))
-		add_partial(get_node(s, page_to_nid(page)), page);
+		add_partial(get_node(s, page_to_nid(page)), page, 0);
 
 out_unlock:
 	slab_unlock(page);
@@ -2012,7 +2011,7 @@ static struct kmem_cache_node * __init e
 #endif
 	init_kmem_cache_node(n);
 	atomic_long_inc(&n->nr_slabs);
-	add_partial(n, page);
+	add_partial(n, page, 0);
 
 	/*
 	 * new_slab() disables interupts. If we do not reenable interrupts here

-- 
