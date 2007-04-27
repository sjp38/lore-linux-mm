Message-Id: <20070427202859.886953367@sgi.com>
References: <20070427202137.613097336@sgi.com>
Date: Fri, 27 Apr 2007 13:21:39 -0700
From: clameter@sgi.com
Subject: [patch 2/8] SLUB: Fixes to kmem_cache_shrink()
Content-Disposition: inline; filename=slub_shrink_race_fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

1. Reclaim all empty slabs even if we are below MIN_PARTIAL partial slabs.
   The point here is to recover all possible memory.

2. Fix race condition vs. slab_free. If we want to free a slab then
   we need to acquire the slab lock since slab_free may have freed
   an object and is waiting to acquire the lock to remove the slab.
   We do a trylock. If its unsuccessful then we are racing with
   slab_free. Simply keep the empty slab on the partial lists.
   slab_free will remove the slab as soon as we drop the list_lock.

3. #2 may have the result that we end up with empty slabs on the
   slabs_by_inuse array. So make sure that we also splice in the
   zeroeth element.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-27 13:05:17.000000000 -0700
+++ slub/mm/slub.c	2007-04-27 13:05:24.000000000 -0700
@@ -2220,7 +2220,7 @@ int kmem_cache_shrink(struct kmem_cache 
 	for_each_online_node(node) {
 		n = get_node(s, node);
 
-		if (n->nr_partial <= MIN_PARTIAL)
+		if (!n->nr_partial)
 			continue;
 
 		for (i = 0; i < s->objects; i++)
@@ -2237,14 +2237,21 @@ int kmem_cache_shrink(struct kmem_cache 
 		 * the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			if (!page->inuse) {
+			if (!page->inuse && slab_trylock(page)) {
+				/*
+				 * Must hold slab lock here because slab_free
+				 * may have freed the last object and be
+				 * waiting to release the slab.
+				 */
 				list_del(&page->lru);
 				n->nr_partial--;
+				slab_unlock(page);
 				discard_slab(s, page);
-			} else
-			if (n->nr_partial > MAX_PARTIAL)
-				list_move(&page->lru,
+			} else {
+				if (n->nr_partial > MAX_PARTIAL)
+					list_move(&page->lru,
 					slabs_by_inuse + page->inuse);
+			}
 		}
 
 		if (n->nr_partial <= MAX_PARTIAL)
@@ -2254,7 +2261,7 @@ int kmem_cache_shrink(struct kmem_cache 
 		 * Rebuild the partial list with the slabs filled up
 		 * most first and the least used slabs at the end.
 		 */
-		for (i = s->objects - 1; i > 0; i--)
+		for (i = s->objects - 1; i >= 0; i--)
 			list_splice(slabs_by_inuse + i, n->partial.prev);
 
 	out:

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
