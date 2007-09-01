From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 13/26] SLUB: Add SlabReclaimable() to avoid repeated reclaim attempts
Date: Fri, 31 Aug 2007 18:41:20 -0700
Message-ID: <20070901014222.303468369@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0013-slab_defrag_reclaim_flag.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Add a flag SlabReclaimable() that is set on slabs with a method
that allows defrag/reclaim. Clear the flag if a reclaim action is not
successful in reducing the number of objects in a slab. The reclaim
flag is set again if all objects have been allocated from it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   42 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 6 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-08-28 20:10:37.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-28 20:10:47.000000000 -0700
@@ -107,6 +107,8 @@
 #define SLABDEBUG 0
 #endif
 
+#define SLABRECLAIMABLE (1 << PG_dirty)
+
 static inline int SlabFrozen(struct page *page)
 {
 	return page->flags & FROZEN;
@@ -137,6 +139,21 @@ static inline void ClearSlabDebug(struct
 	page->flags &= ~SLABDEBUG;
 }
 
+static inline int SlabReclaimable(struct page *page)
+{
+	return page->flags & SLABRECLAIMABLE;
+}
+
+static inline void SetSlabReclaimable(struct page *page)
+{
+	page->flags |= SLABRECLAIMABLE;
+}
+
+static inline void ClearSlabReclaimable(struct page *page)
+{
+	page->flags &= ~SLABRECLAIMABLE;
+}
+
 /*
  * Issues still to be resolved:
  *
@@ -1099,6 +1116,8 @@ static struct page *new_slab(struct kmem
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
 			SLAB_STORE_USER | SLAB_TRACE))
 		SetSlabDebug(page);
+	if (s->kick)
+		SetSlabReclaimable(page);
 
  out:
 	if (flags & __GFP_WAIT)
@@ -1155,6 +1174,7 @@ static void discard_slab(struct kmem_cac
 	atomic_long_dec(&n->nr_slabs);
 	reset_page_mapcount(page);
 	__ClearPageSlab(page);
+	ClearSlabReclaimable(page);
 	free_slab(s, page);
 }
 
@@ -1328,8 +1348,12 @@ static void unfreeze_slab(struct kmem_ca
 
 		if (page->freelist)
 			add_partial(n, page, tail);
-		else if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
-			add_full(n, page);
+		else {
+			if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
+				add_full(n, page);
+			if (s->kick && !SlabReclaimable(page))
+				SetSlabReclaimable(page);
+		}
 		slab_unlock(page);
 
 	} else {
@@ -2659,7 +2683,7 @@ int kmem_cache_isolate_slab(struct page 
 	struct kmem_cache *s;
 	int rc = -ENOENT;
 
-	if (!PageSlab(page) || SlabFrozen(page))
+	if (!PageSlab(page) || SlabFrozen(page) || !SlabReclaimable(page))
 		return rc;
 
 	/*
@@ -2729,7 +2753,7 @@ static int kmem_cache_vacate(struct page
 	struct kmem_cache *s;
 	unsigned long *map;
 	int leftover;
-	int objects;
+	int objects = -1;
 	void *private;
 	unsigned long flags;
 	int tail = 1;
@@ -2739,7 +2763,7 @@ static int kmem_cache_vacate(struct page
 	slab_lock(page);
 
 	s = page->slab;
-	map = scratch + s->objects * sizeof(void **);
+	map = scratch + max_defrag_slab_objects * sizeof(void **);
 	if (!page->inuse || !s->kick)
 		goto out;
 
@@ -2773,10 +2797,13 @@ static int kmem_cache_vacate(struct page
 	local_irq_save(flags);
 	slab_lock(page);
 	tail = 0;
-out:
+
 	/*
 	 * Check the result and unfreeze the slab
 	 */
+	if (page->inuse == objects)
+		ClearSlabReclaimable(page);
+out:
 	leftover = page->inuse;
 	unfreeze_slab(s, page, tail);
 	local_irq_restore(flags);
@@ -2831,6 +2858,9 @@ static unsigned long __kmem_cache_shrink
 		if (inuse > s->objects / 4)
 			continue;
 
+		if (s->kick && !SlabReclaimable(page))
+			continue;
+
 		if (!slab_trylock(page))
 			continue;
 

-- 
