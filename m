From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 12/26] SLUB: Slab reclaim through Lumpy reclaim
Date: Fri, 31 Aug 2007 18:41:19 -0700
Message-ID: <20070901014222.073887169@sgi.com>
References: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0012-slab_defrag_lumpy_reclaim.patch
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Creates a special function kmem_cache_isolate_slab() and kmem_cache_reclaim()
to support lumpy reclaim.

In order to isolate pages we will have to handle slab page allocations in
such a way that we can determine if a slab is valid whenever we access it
regardless of its time in life.

A valid slab that can be freed has PageSlab(page) and page->inuse > 0 set.
So we need to make sure in allocate_slab that page->inuse is zero before
PageSlab is set otherwise kmem_cache_vacate may operate on a slab that
has not been properly setup yet.

kmem_cache_isolate_page() is called from lumpy reclaim to isolate pages
neighboring a page cache page that is being reclaimed. Lumpy reclaim will
gather the slabs and call kmem_cache_reclaim() on the list.

This means that we can remove a slab that is in the way of coalescing
together a higher order page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/slab.h |    2 +
 mm/slab.c            |   13 +++++++
 mm/slub.c            |   88 +++++++++++++++++++++++++++++++++++++++++++++++----
 mm/vmscan.c          |   15 ++++++--
 4 files changed, 109 insertions(+), 9 deletions(-)

Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2007-08-28 20:05:42.000000000 -0700
+++ linux-2.6/include/linux/slab.h	2007-08-28 20:06:22.000000000 -0700
@@ -62,6 +62,8 @@ unsigned int kmem_cache_size(struct kmem
 const char *kmem_cache_name(struct kmem_cache *);
 int kmem_ptr_validate(struct kmem_cache *cachep, const void *ptr);
 int kmem_cache_defrag(int node);
+int kmem_cache_isolate_slab(struct page *);
+int kmem_cache_reclaim(struct list_head *);
 
 /*
  * Please use this macro to create slab caches. Simply specify the
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c	2007-08-28 20:04:54.000000000 -0700
+++ linux-2.6/mm/slab.c	2007-08-28 20:06:22.000000000 -0700
@@ -2532,6 +2532,19 @@ int kmem_cache_defrag(int node)
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
--- linux-2.6.orig/mm/slub.c	2007-08-28 20:04:54.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-28 20:10:37.000000000 -0700
@@ -1006,6 +1006,7 @@ static inline int slab_pad_check(struct 
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, int active) { return 1; }
 static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
+static inline void remove_full(struct kmem_cache *s, struct page *page) {}
 static inline void kmem_cache_open_debug_check(struct kmem_cache *s) {}
 #define slub_debug 0
 #endif
@@ -1068,11 +1069,9 @@ static struct page *new_slab(struct kmem
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
+
+	page->inuse = 0;
 	page->slab = s;
-	page->flags |= 1 << PG_slab;
-	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
-			SLAB_STORE_USER | SLAB_TRACE))
-		SetSlabDebug(page);
 
 	start = page_address(page);
 	end = start + s->objects * s->size;
@@ -1090,8 +1089,18 @@ static struct page *new_slab(struct kmem
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
-	page->inuse = 0;
-out:
+
+	/*
+	 * page->inuse must be 0 when PageSlab(page) becomes
+	 * true so that defrag knows that this slab is not in use.
+	 */
+	smp_wmb();
+	__SetPageSlab(page);
+	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
+			SLAB_STORE_USER | SLAB_TRACE))
+		SetSlabDebug(page);
+
+ out:
 	if (flags & __GFP_WAIT)
 		local_irq_disable();
 	return page;
@@ -2638,6 +2647,73 @@ static unsigned long count_partial(struc
 	return x;
 }
 
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
+
+	if (!PageSlab(page) || SlabFrozen(page))
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
+	slab_lock(page);
+
+	/*
+	 * Check a variety of conditions to insure that the page was not
+	 *  1. Freed
+	 *  2. Frozen
+	 *  3. Is in the process of being freed (min one remaining object)
+	 */
+	if (!PageSlab(page) || SlabFrozen(page) || !page->inuse) {
+		slab_unlock(page);
+		put_page(page);
+		goto out;
+	}
+
+	/*
+	 * Drop reference. There are object remaining and therefore
+	 * the slab lock will be taken before the last objects can
+	 * be removed. So we cannot be in the process of freeing the
+	 * object.
+	 *
+	 * We set the slab frozen before releasing the lock. This means
+	 * that no free action will be performed. If it becomes empty
+	 * then we will free it during kmem_cache_reclaim().
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
+	SetSlabFrozen(page);
+	slab_unlock(page);
+	rc = 0;
+out:
+	local_irq_restore(flags);
+	return rc;
+}
+
 /*
  * Vacate all objects in the given slab.
  *
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-08-28 20:05:42.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-08-28 20:06:22.000000000 -0700
@@ -657,6 +657,7 @@ static int __isolate_lru_page(struct pag
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
+		struct list_head *slab_pages,
 		unsigned long *scanned, int order, int mode)
 {
 	unsigned long nr_taken = 0;
@@ -730,7 +731,13 @@ static unsigned long isolate_lru_pages(u
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
@@ -766,6 +773,7 @@ static unsigned long shrink_inactive_lis
 				struct zone *zone, struct scan_control *sc)
 {
 	LIST_HEAD(page_list);
+	LIST_HEAD(slab_list);
 	struct pagevec pvec;
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
@@ -783,7 +791,7 @@ static unsigned long shrink_inactive_lis
 
 		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
 			     &zone->inactive_list,
-			     &page_list, &nr_scan, sc->order,
+			     &page_list, &slab_list, &nr_scan, sc->order,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
 					     ISOLATE_BOTH : ISOLATE_INACTIVE);
 		nr_active = clear_active_flags(&page_list);
@@ -793,6 +801,7 @@ static unsigned long shrink_inactive_lis
 						-(nr_taken - nr_active));
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
+		kmem_cache_reclaim(&slab_list);
 
 		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc);
@@ -934,8 +943,8 @@ force_reclaim_mapped:
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
-			    &l_hold, &pgscanned, sc->order, ISOLATE_ACTIVE);
+	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list, &l_hold,
+			NULL, &pgscanned, sc->order, ISOLATE_ACTIVE);
 	zone->pages_scanned += pgscanned;
 	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);

-- 
