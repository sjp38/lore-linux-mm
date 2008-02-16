Message-Id: <20080216004633.259062883@sgi.com>
References: <20080216004526.763643520@sgi.com>
Date: Fri, 15 Feb 2008 16:45:33 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 07/17] SLUB: Add KICKABLE to avoid repeated kick() attempts
Content-Disposition: inline; filename=0064-SLUB-Add-SlabReclaimable-to-avoid-repeated-reclai.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org
List-ID: <linux-mm.kvack.org>

Add a flag KICKABLE to be set on slabs with a defragmentation method

Clear the flag if a kick action is not successful in reducing the
number of objects in a slab.

The KICKABLE flag is set again when all objeccts of the slab have been
allocated and it is removed from the partial lists.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-02-15 16:41:07.606611300 -0800
+++ linux-2.6/mm/slub.c	2008-02-15 16:41:42.806805718 -0800
@@ -101,6 +101,7 @@
  */
 
 #define FROZEN (1 << PG_active)
+#define KICKABLE (1 << PG_dirty)
 
 #ifdef CONFIG_SLUB_DEBUG
 #define SLABDEBUG (1 << PG_error)
@@ -138,6 +139,21 @@ static inline void ClearSlabDebug(struct
 	page->flags &= ~SLABDEBUG;
 }
 
+static inline int SlabKickable(struct page *page)
+{
+	return page->flags & KICKABLE;
+}
+
+static inline void SetSlabKickable(struct page *page)
+{
+	page->flags |= KICKABLE;
+}
+
+static inline void ClearSlabKickable(struct page *page)
+{
+	page->flags &= ~KICKABLE;
+}
+
 /*
  * Issues still to be resolved:
  *
@@ -1132,6 +1148,8 @@ static struct page *new_slab(struct kmem
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
 			SLAB_STORE_USER | SLAB_TRACE))
 		SetSlabDebug(page);
+	if (s->kick)
+		SetSlabKickable(page);
 
 	start = page_address(page);
 	page->end = start + 1;
@@ -1203,6 +1221,7 @@ static void discard_slab(struct kmem_cac
 
 	atomic_long_dec(&n->nr_slabs);
 	reset_page_mapcount(page);
+	ClearSlabKickable(page);
 	__ClearPageSlab(page);
 	free_slab(s, page);
 }
@@ -1383,6 +1402,8 @@ static void unfreeze_slab(struct kmem_ca
 			stat(c, DEACTIVATE_FULL);
 			if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
 				add_full(n, page);
+			if (s->kick)
+				SetSlabKickable(page);
 		}
 		slab_unlock(page);
 	} else {
@@ -2861,7 +2882,7 @@ static int kmem_cache_vacate(struct page
 	s = page->slab;
 	objects = s->objects;
 	map = scratch + max_defrag_slab_objects * sizeof(void **);
-	if (!page->inuse || !s->kick)
+	if (!page->inuse || !s->kick || !SlabKickable(page))
 		goto out;
 
 	/* Determine used objects */
@@ -2898,6 +2919,8 @@ out:
 	 * Check the result and unfreeze the slab
 	 */
 	leftover = page->inuse;
+	if (leftover)
+		ClearSlabKickable(page);
 	unfreeze_slab(s, page, leftover > 0);
 	local_irq_restore(flags);
 	return leftover;
@@ -2945,7 +2968,8 @@ static unsigned long __kmem_cache_shrink
 
 	spin_lock_irqsave(&n->list_lock, flags);
 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
-		if (page->inuse > s->objects / 4)
+		if (page->inuse > s->objects / 4 ||
+				(s->kick && !SlabKickable(page)))
 			continue;
 		if (!slab_trylock(page))
 			continue;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
