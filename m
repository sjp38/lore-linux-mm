Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3663E6B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 09:11:00 -0400 (EDT)
Message-Id: <20100928131057.767067382@linux.com>
Date: Tue, 28 Sep 2010 08:10:28 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup5 3/3] slub: extract common code to remove objects from partial list without locking
References: <20100928131025.319846721@linux.com>
Content-Disposition: inline; filename=cleanup_remove_partial
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

There are a couple of places where repeat the same statements when removing
a page from the partial list. Consolidate that into __remove_partial().

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2010-09-28 08:05:49.000000000 -0500
+++ linux-2.6/mm/slub.c	2010-09-28 08:05:50.000000000 -0500
@@ -1312,13 +1312,19 @@ static void add_partial(struct kmem_cach
 	spin_unlock(&n->list_lock);
 }
 
+static inline void __remove_partial(struct kmem_cache_node *n,
+					struct page *page)
+{
+	list_del(&page->lru);
+	n->nr_partial--;
+}
+
 static void remove_partial(struct kmem_cache *s, struct page *page)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
 	spin_lock(&n->list_lock);
-	list_del(&page->lru);
-	n->nr_partial--;
+	__remove_partial(n, page);
 	spin_unlock(&n->list_lock);
 }
 
@@ -1331,8 +1337,7 @@ static inline int lock_and_freeze_slab(s
 							struct page *page)
 {
 	if (slab_trylock(page)) {
-		list_del(&page->lru);
-		n->nr_partial--;
+		__remove_partial(n, page);
 		__SetPageSlubFrozen(page);
 		return 1;
 	}
@@ -2464,9 +2469,8 @@ static void free_partial(struct kmem_cac
 	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
 		if (!page->inuse) {
-			list_del(&page->lru);
+			__remove_partial(n, page);
 			discard_slab(s, page);
-			n->nr_partial--;
 		} else {
 			list_slab_objects(s, page,
 				"Objects remaining on kmem_cache_close()");
@@ -2824,8 +2828,7 @@ int kmem_cache_shrink(struct kmem_cache 
 				 * may have freed the last object and be
 				 * waiting to release the slab.
 				 */
-				list_del(&page->lru);
-				n->nr_partial--;
+				__remove_partial(n, page);
 				slab_unlock(page);
 				discard_slab(s, page);
 			} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
