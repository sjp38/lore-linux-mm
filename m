Message-Id: <20071114221023.535547035@sgi.com>
References: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:23 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 17/17] SLUB: Add KICKABLE to avoid repeated kick() attempts
Content-Disposition: inline; filename=0064-SLUB-Add-SlabReclaimable-to-avoid-repeated-reclai.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Add a flag KICKABLE to be set on slabs with a defragmentation method

Clear the flag if a kick action is not successful in reducing the
number of objects in a slab.

The KICKABLE flag is set again when all objeccts of the slab have been
allocated and it is removed from the partial lists.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

Index: linux-2.6.24-rc2-mm1/mm/slub.c
===================================================================
--- linux-2.6.24-rc2-mm1.orig/mm/slub.c	2007-11-14 13:39:56.936039109 -0800
+++ linux-2.6.24-rc2-mm1/mm/slub.c	2007-11-14 13:39:57.124538760 -0800
@@ -102,6 +102,7 @@
 
 #define FROZEN (1 << PG_active)
 #define LOCKED (1 << PG_locked)
+#define KICKABLE (1 << PG_dirty)
 
 #ifdef CONFIG_SLUB_DEBUG
 #define SLABDEBUG (1 << PG_error)
@@ -1098,6 +1099,8 @@ static noinline struct page *new_slab(st
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
 			SLAB_STORE_USER | SLAB_TRACE))
 		state |= SLABDEBUG;
+	if (s->kick)
+		state |= KICKABLE;
 
 	page->flags |= state;
 	start = page_address(page);
@@ -1170,6 +1173,7 @@ static void discard_slab(struct kmem_cac
 
 	atomic_long_dec(&n->nr_slabs);
 	reset_page_mapcount(page);
+	page->flags &= ~KICKABLE;
 	__ClearPageSlab(page);
 	free_slab(s, page);
 }
@@ -1402,8 +1406,11 @@ static void unfreeze_slab(struct kmem_ca
 
 		if (page->freelist != page->end)
 			add_partial(s, page, tail);
-		else
+		else {
 			add_full(s, page, state);
+			if (s->kick)
+				state |= KICKABLE;
+		}
 		slab_unlock(page, state);
 
 	} else {
@@ -2829,7 +2836,7 @@ static int kmem_cache_vacate(struct page
 
 	s = page->slab;
 	map = scratch + max_defrag_slab_objects * sizeof(void **);
-	if (!page->inuse || !s->kick)
+	if (!page->inuse || !s->kick || !(state & KICKABLE))
 		goto out;
 
 	/* Determine used objects */
@@ -2866,6 +2873,8 @@ out:
 	 * Check the result and unfreeze the slab
 	 */
 	leftover = page->inuse;
+	if (leftover)
+		state &= ~KICKABLE;
 	unfreeze_slab(s, page, leftover > 0, state);
 	local_irq_restore(flags);
 	return leftover;
@@ -2914,14 +2923,14 @@ static unsigned long __kmem_cache_shrink
 
 	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
-		if (page->inuse > s->objects / 4)
-			continue;
+		if (page->inuse > s->objects / 4 ||
+			(!(page->flags & KICKABLE) && s->kick))
+				continue;
 		state = slab_trylock(page);
 		if (!state)
 			continue;
 
 		if (page->inuse) {
-
 			list_move(&page->lru, &zaplist);
 			if (s->kick) {
 				n->nr_partial--;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
