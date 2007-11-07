From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 22/23] SLUB: Slab reclaim through Lumpy reclaim
Date: Tue, 06 Nov 2007 17:11:52 -0800
Message-ID: <20071107011231.907368704@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758416AbXKGBTt@vger.kernel.org>
Content-Disposition: inline; filename=0012-slab_defrag_lumpy_reclaim.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Creates a special function kmem_cache_isolate_slab() and kmem_cache_reclaim()
to support lumpy reclaim.

In order to isolate pages we will have to handle slab page allocations in
such a way that we can determine if a slab is valid whenever we access it
regardless of its time in life.

A valid slab that can be freed has PageSlab(page) and page->inuse > 0 set.
So we need to make sure in allocate_slab() that page->inuse is zero before
PageSlab is set.

kmem_cache_isolate_page() is called from lumpy reclaim to isolate pages
neighboring a page cache page that is being reclaimed. Lumpy reclaim will
gather the slabs and call kmem_cache_reclaim() on the list.

This means that we can remove a slab in order to be able to coalesce
a higher order page.

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slab.h |    2 +
 mm/slab.c            |   13 ++++++
 mm/slub.c            |  102 ++++++++++++++++++++++++++++++++++++++++++++++++---
 mm/vmscan.c          |   13 +++++-
 4 files changed, 123 insertions(+), 7 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2007-11-06 13:50:47.000000000 -0800
+++ linux-2.6/include/linux/slab.h	2007-11-06 13:50:54.000000000 -0800
@@ -64,6 +64,8 @@ unsigned int kmem_cache_size(struct kmem
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 int kmem_cache_defrag(int node);
+int kmem_cache_isolate_slab(struct page *);
+int kmem_cache_reclaim(struct list_head *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2007-11-06 13:50:33.000000000 -0800
+++ linux-2.6/mm/slab.c	2007-11-06 13:50:54.000000000 -0800
@@ -2559,6 +2559,19 @@ int kmem_cache_defrag(int node)
 	return 0;
 }
 
+/*
+ * SLAB does not support slab defragmentation
+ */
+int kmem_cache_isolate_slab(struct page *page)
+{
+	return -ENOSYS;
+}
+
+int kmem_cache_reclaim(struct list_head *zaplist)
+{
+	return 0;
+}
+
 /**
  * kmem_cache_destroy - delete a cache
  * @cachep: the cache to destroy
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-11-06 13:50:40.000000000 -0800
+++ linux-2.6/mm/slub.c	2007-11-06 13:50:54.000000000 -0800
@@ -1088,18 +1088,19 @@ static noinline struct page *new_slab(st
 	page = allocate_slab(s,
 		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
 	if (!page)
-		goto out;
+		return NULL;
 
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
+
+	page->inuse = 0;
 	page->slab = s;
-	state = 1 << PG_slab;
+	state = page->flags | (1 << PG_slab);
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
 			SLAB_STORE_USER | SLAB_TRACE))
 		state |= SLABDEBUG;
 
-	page->flags |= state;
 	start = page_address(page);
 	page->end = start + 1;
 
@@ -1116,8 +1117,13 @@ static noinline struct page *new_slab(st
 	set_freepointer(s, last, page->end);
 
 	page->freelist = start;
-	page->inuse = 0;
-out:
+
+	/*
+	 * page->inuse must be 0 when PageSlab(page) becomes
+	 * true so that defrag knows that this slab is not in use.
+	 */
+	smp_wmb();
+	page->flags = state;
 	return page;
 }
 
@@ -2622,6 +2628,92 @@ out:
 }
 #endif
 
+
+/*
+ * Check if the given state is that of a reclaimable slab page.
+ *
+ * This is only true if this is indeed a slab page and if
+ * the page has not been frozen.
+ */
+static inline int reclaimable_slab(unsigned long state)
+{
+	if (!(state & (1 << PG_slab)))
+		return 0;
+
+	if (state & FROZEN)
+		return 0;
+
+	return 1;
+}
+
+ /*
+ * Isolate page from the slab partial lists. Return 0 if succesful.
+ *
+ * After isolation the LRU field can be used to put the page onto
+ * a reclaim list.
+ */
+int kmem_cache_isolate_slab(struct page *page)
+{
+	unsigned long flags;
+	struct kmem_cache *s;
+	int rc = -ENOENT;
+	unsigned long state;
+
+	/*
+	 * Avoid attempting to isolate the slab pages if there are
+	 * indications that this will not be successful.
+	 */
+	if (!reclaimable_slab(page->flags) || page_count(page) == 1)
+		return rc;
+
+	/*
+	 * Get a reference to the page. Return if its freed or being freed.
+	 * This is necessary to make sure that the page does not vanish
+	 * from under us before we are able to check the result.
+	 */
+	if (!get_page_unless_zero(page))
+		return rc;
+
+	local_irq_save(flags);
+	state = slab_lock(page);
+
+	/*
+	 * Check the flags again now that we have locked it.
+	 */
+	if (!reclaimable_slab(flags) || !page->inuse) {
+		slab_unlock(page, state);
+		put_page(page);
+		goto out;
+	}
+
+	/*
+	 * Drop reference count. There are object remaining and therefore
+	 * the slab lock will have to be taken before the last object can
+	 * be removed. We hold the slab lock, so no one can free this slab
+	 * now.
+	 *
+	 * We set the slab frozen before releasing the lock. This means
+	 * that no slab free action will be performed. If all objects are
+	 * removed then the slab will be freed during kmem_cache_reclaim().
+	 */
+	BUG_ON(page_count(page) <= 1);
+	put_page(page);
+
+	/*
+	 * Remove the slab from the lists and mark it frozen
+	 */
+	s = page->slab;
+	if (page->inuse < s->objects)
+		remove_partial(s, page);
+	else if (s->flags & SLAB_STORE_USER)
+		remove_full(s, page);
+	slab_unlock(page, state | FROZEN);
+	rc = 0;
+out:
+	local_irq_restore(flags);
+	return rc;
+}
+
 /*
  * Conversion table for small slabs sizes / 8 to the index in the
  * kmalloc array. This is necessary for slabs < 192 since we have non power
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-11-06 13:50:47.000000000 -0800
+++ linux-2.6/mm/vmscan.c	2007-11-06 13:50:54.000000000 -0800
@@ -687,6 +687,7 @@ static int __isolate_lru_page(struct pag
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
+		struct list_head *slab_pages,
 		unsigned long *scanned, int order, int mode)
 {
 	unsigned long nr_taken = 0;
@@ -760,7 +761,13 @@ static unsigned long isolate_lru_pages(u
 			case -EBUSY:
 				/* else it is being freed elsewhere */
 				list_move(&cursor_page->lru, src);
+				break;
+
 			default:
+				if (slab_pages &&
+				    kmem_cache_isolate_slab(cursor_page) == 0)
+						list_add(&cursor_page->lru,
+							slab_pages);
 				break;
 			}
 		}
@@ -796,6 +803,7 @@ static unsigned long shrink_inactive_lis
 				struct zone *zone, struct scan_control *sc)
 {
 	LIST_HEAD(page_list);
+	LIST_HEAD(slab_list);
 	struct pagevec pvec;
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
@@ -813,7 +821,7 @@ static unsigned long shrink_inactive_lis
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
 			     &zone->inactive_list,
-			     &page_list, &nr_scan, sc->order,
+			     &page_list, &slab_list, &nr_scan, sc->order,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
 					     ISOLATE_BOTH : ISOLATE_INACTIVE);
 		nr_active = clear_active_flags(&page_list);
@@ -824,6 +832,7 @@ static unsigned long shrink_inactive_lis
 						-(nr_taken - nr_active));
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
+		kmem_cache_reclaim(&slab_list);
 
 		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
@@ -1029,7 +1038,7 @@ force_reclaim_mapped:
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-			    &l_hold, &pgscanned, sc->order, ISOLATE_ACTIVE);
+			&l_hold, NULL, &pgscanned, sc->order, ISOLATE_ACTIVE);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);

-- 
