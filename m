Date: Mon, 14 May 2007 20:00:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Define functions for cpu slab handling instead of using
 PageActive
Message-ID: <Pine.LNX.4.64.0705141959060.27789@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Use inline functions to access the per cpu bit. Intoduce the notion of 
"freezing" a slab to make things more understandable.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   57 ++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 38 insertions(+), 19 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-14 19:46:56.000000000 -0700
+++ slub/mm/slub.c	2007-05-14 19:56:14.000000000 -0700
@@ -78,10 +78,18 @@
  *
  * Overloading of page flags that are otherwise used for LRU management.
  *
- * PageActive 		The slab is used as a cpu cache. Allocations
- * 			may be performed from the slab. The slab is not
- * 			on any slab list and cannot be moved onto one.
- * 			The cpu slab may be equipped with an additioanl
+ * PageActive 		The slab is frozen and excempt from list processing.
+ * 			This means that the slab is dedicated to a purpose
+ * 			such as satisfying allocations for a specific
+ * 			processor. Objects may be freed in the slab while
+ * 			it is frozen but slab_free will then skip the usual
+ * 			list operations. It is up to the processor holding
+ * 			the slab to integrate the slab into the slab lists
+ * 			when the slab is no longer needed.
+ *
+ * 			One use of this flag is to mark slabs that are
+ * 			used for allocations. Then such a slab becomes a cpu
+ * 			slab. The cpu slab may be equipped with an additional
  * 			lockless_freelist that allows lockless access to
  * 			free objects in addition to the regular freelist
  * 			that requires the slab lock.
@@ -91,6 +99,21 @@
  * 			the fast path and disables lockless freelists.
  */
 
+static inline int SlabFrozen(struct page *page)
+{
+	return PageActive(page);
+}
+
+static inline void SetSlabFrozen(struct page *page)
+{
+	SetPageActive(page);
+}
+
+static inline void ClearSlabFrozen(struct page *page)
+{
+	__ClearPageActive(page);
+}
+
 static inline int SlabDebug(struct page *page)
 {
 #ifdef CONFIG_SLUB_DEBUG
@@ -1142,11 +1165,12 @@ static void remove_partial(struct kmem_c
  *
  * Must hold list_lock.
  */
-static int lock_and_del_slab(struct kmem_cache_node *n, struct page *page)
+static inline int lock_and_freeze_slab(struct kmem_cache_node *n, struct page *page)
 {
 	if (slab_trylock(page)) {
 		list_del(&page->lru);
 		n->nr_partial--;
+		SetSlabFrozen(page);
 		return 1;
 	}
 	return 0;
@@ -1170,7 +1194,7 @@ static struct page *get_partial_node(str
 
 	spin_lock(&n->list_lock);
 	list_for_each_entry(page, &n->partial, lru)
-		if (lock_and_del_slab(n, page))
+		if (lock_and_freeze_slab(n, page))
 			goto out;
 	page = NULL;
 out:
@@ -1249,10 +1273,11 @@ static struct page *get_partial(struct k
  *
  * On exit the slab lock will have been dropped.
  */
-static void putback_slab(struct kmem_cache *s, struct page *page)
+static void unfreeze_slab(struct kmem_cache *s, struct page *page)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 
+	ClearSlabFrozen(page);
 	if (page->inuse) {
 
 		if (page->freelist)
@@ -1303,9 +1328,7 @@ static void deactivate_slab(struct kmem_
 		page->inuse--;
 	}
 	s->cpu_slab[cpu] = NULL;
-	ClearPageActive(page);
-
-	putback_slab(s, page);
+	unfreeze_slab(s, page);
 }
 
 static void flush_slab(struct kmem_cache *s, struct page *page, int cpu)
@@ -1396,9 +1419,7 @@ another_slab:
 new_slab:
 	page = get_partial(s, gfpflags, node);
 	if (page) {
-have_slab:
 		s->cpu_slab[cpu] = page;
-		SetPageActive(page);
 		goto load_freelist;
 	}
 
@@ -1428,7 +1449,9 @@ have_slab:
 			flush_slab(s, s->cpu_slab[cpu], cpu);
 		}
 		slab_lock(page);
-		goto have_slab;
+		SetSlabFrozen(page);
+		s->cpu_slab[cpu] = page;
+		goto load_freelist;
 	}
 	return NULL;
 debug:
@@ -1515,11 +1538,7 @@ checks_ok:
 	page->freelist = object;
 	page->inuse--;
 
-	if (unlikely(PageActive(page)))
-		/*
-		 * Cpu slabs are never on partial lists and are
-		 * never freed.
-		 */
+	if (unlikely(SlabFrozen(page)))
 		goto out_unlock;
 
 	if (unlikely(!page->inuse))
@@ -1551,7 +1570,7 @@ slab_empty:
 debug:
 	if (!free_object_checks(s, page, x))
 		goto out_unlock;
-	if (!PageActive(page) && !page->freelist)
+	if (!SlabFrozen(page) && !page->freelist)
 		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, x, TRACK_FREE, addr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
