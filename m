Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AED4B900092
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:04 -0400 (EDT)
Message-Id: <20110415201301.937368741@linux.com>
Date: Fri, 15 Apr 2011 15:12:58 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: explicit list_lock taking
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=unlock_list_ops
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

The allocator fastpath rework does change the usage of the list_lock.
Remove the list_lock processing from the functions that hide them from the
critical sections and move them into those critical sections.

This is turn simplifies the support functions (no __ variant needed anymore)
and simplifies the lock handling on bootstrap.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   74 ++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 36 insertions(+), 38 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 13:14:51.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 13:14:54.000000000 -0500
@@ -905,25 +905,21 @@ static inline void slab_free_hook(struct
 /*
  * Tracking of fully allocated slabs for debugging purposes.
  */
-static void add_full(struct kmem_cache_node *n, struct page *page)
+static void add_full(struct kmem_cache *s,
+	struct kmem_cache_node *n, struct page *page)
 {
-	spin_lock(&n->list_lock);
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
 	list_add(&page->lru, &n->full);
-	spin_unlock(&n->list_lock);
 }
 
 static void remove_full(struct kmem_cache *s, struct page *page)
 {
-	struct kmem_cache_node *n;
-
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
-	n = get_node(s, page_to_nid(page));
-
-	spin_lock(&n->list_lock);
 	list_del(&page->lru);
-	spin_unlock(&n->list_lock);
 }
 
 /* Tracking of the number of slabs for debugging purposes */
@@ -1048,8 +1044,13 @@ static noinline int free_debug_processin
 	}
 
 	/* Special debug activities for freeing objects */
-	if (!page->frozen && !page->freelist)
+	if (!page->frozen && !page->freelist) {
+		struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
+		spin_lock(&n->list_lock);
 		remove_full(s, page);
+		spin_unlock(&n->list_lock);
+	}
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
@@ -1400,36 +1401,26 @@ static __always_inline int slab_trylock(
 /*
  * Management of partially allocated slabs
  */
-static void add_partial(struct kmem_cache_node *n,
+static inline void add_partial(struct kmem_cache_node *n,
 				struct page *page, int tail)
 {
-	spin_lock(&n->list_lock);
 	n->nr_partial++;
 	if (tail)
 		list_add_tail(&page->lru, &n->partial);
 	else
 		list_add(&page->lru, &n->partial);
-	spin_unlock(&n->list_lock);
 }
 
-static inline void __remove_partial(struct kmem_cache_node *n,
+static inline void remove_partial(struct kmem_cache_node *n,
 					struct page *page)
 {
 	list_del(&page->lru);
 	n->nr_partial--;
 }
 
-static void remove_partial(struct kmem_cache *s, struct page *page)
-{
-	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-
-	spin_lock(&n->list_lock);
-	__remove_partial(n, page);
-	spin_unlock(&n->list_lock);
-}
-
 /*
- * Lock slab and remove from the partial list.
+ * Lock slab, remove from the partial list and put the object into the
+ * per cpu freelist.
  *
  * Must hold list_lock.
  */
@@ -1437,7 +1428,7 @@ static inline int lock_and_freeze_slab(s
 							struct page *page)
 {
 	if (slab_trylock(page)) {
-		__remove_partial(n, page);
+		remove_partial(n, page);
 		return 1;
 	}
 	return 0;
@@ -1554,12 +1545,17 @@ static void unfreeze_slab(struct kmem_ca
 	if (page->inuse) {
 
 		if (page->freelist) {
+			spin_lock(&n->list_lock);
 			add_partial(n, page, tail);
+			spin_unlock(&n->list_lock);
 			stat(s, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
 		} else {
 			stat(s, DEACTIVATE_FULL);
-			if (kmem_cache_debug(s) && (s->flags & SLAB_STORE_USER))
-				add_full(n, page);
+			if (kmem_cache_debug(s) && (s->flags & SLAB_STORE_USER)) {
+				spin_lock(&n->list_lock);
+				add_full(s, n, page);
+				spin_unlock(&n->list_lock);
+			}
 		}
 		slab_unlock(page);
 	} else {
@@ -1575,7 +1571,9 @@ static void unfreeze_slab(struct kmem_ca
 			 * kmem_cache_shrink can reclaim any empty slabs from
 			 * the partial list.
 			 */
+			spin_lock(&n->list_lock);
 			add_partial(n, page, 1);
+			spin_unlock(&n->list_lock);
 			slab_unlock(page);
 		} else {
 			slab_unlock(page);
@@ -2131,7 +2129,11 @@ static void __slab_free(struct kmem_cach
 	 * then add it.
 	 */
 	if (unlikely(!prior)) {
+		struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
+		spin_lock(&n->list_lock);
 		add_partial(get_node(s, page_to_nid(page)), page, 1);
+		spin_unlock(&n->list_lock);
 		stat(s, FREE_ADD_PARTIAL);
 	}
 
@@ -2147,7 +2149,11 @@ slab_empty:
 		/*
 		 * Slab still on the partial list.
 		 */
-		remove_partial(s, page);
+		struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
+		spin_lock(&n->list_lock);
+		remove_partial(n, page);
+		spin_unlock(&n->list_lock);
 		stat(s, FREE_REMOVE_PARTIAL);
 	}
 	slab_unlock(page);
@@ -2449,7 +2455,6 @@ static void early_kmem_cache_node_alloc(
 {
 	struct page *page;
 	struct kmem_cache_node *n;
-	unsigned long flags;
 
 	BUG_ON(kmem_cache_node->size < sizeof(struct kmem_cache_node));
 
@@ -2476,14 +2481,7 @@ static void early_kmem_cache_node_alloc(
 	init_kmem_cache_node(n, kmem_cache_node);
 	inc_slabs_node(kmem_cache_node, node, page->objects);
 
-	/*
-	 * lockdep requires consistent irq usage for each lock
-	 * so even though there cannot be a race this early in
-	 * the boot sequence, we still disable irqs.
-	 */
-	local_irq_save(flags);
 	add_partial(n, page, 0);
-	local_irq_restore(flags);
 }
 
 static void free_kmem_cache_nodes(struct kmem_cache *s)
@@ -2767,7 +2765,7 @@ static void free_partial(struct kmem_cac
 	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
 		if (!page->inuse) {
-			__remove_partial(n, page);
+			remove_partial(n, page);
 			discard_slab(s, page);
 		} else {
 			list_slab_objects(s, page,
@@ -3105,7 +3103,7 @@ int kmem_cache_shrink(struct kmem_cache
 				 * may have freed the last object and be
 				 * waiting to release the slab.
 				 */
-				__remove_partial(n, page);
+				remove_partial(n, page);
 				slab_unlock(page);
 				discard_slab(s, page);
 			} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
