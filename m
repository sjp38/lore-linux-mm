Message-Id: <20070507212410.145577580@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:52 -0700
From: clameter@sgi.com
Subject: [patch 12/17] SLUB: Introduce DebugSlab(page)
Content-Disposition: inline; filename=define_debugslab
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This replaces the PageError() checking. DebugSlab is clearer and
allows for future changes to the page bit used. We also need
it to support CONFIG_SLUB_DEBUG.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:54:35.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:56:25.000000000 -0700
@@ -87,6 +87,21 @@
  * 			the fast path.
  */
 
+static inline int SlabDebug(struct page *page)
+{
+	return PageError(page);
+}
+
+static inline void SetSlabDebug(struct page *page)
+{
+	SetPageError(page);
+}
+
+static inline void ClearSlabDebug(struct page *page)
+{
+	ClearPageError(page);
+}
+
 /*
  * Issues still to be resolved:
  *
@@ -825,7 +840,7 @@ static struct page *allocate_slab(struct
 static void setup_object(struct kmem_cache *s, struct page *page,
 				void *object)
 {
-	if (PageError(page)) {
+	if (SlabDebug(page)) {
 		init_object(s, object, 0);
 		init_tracking(s, object);
 	}
@@ -860,7 +875,7 @@ static struct page *new_slab(struct kmem
 	page->flags |= 1 << PG_slab;
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
 			SLAB_STORE_USER | SLAB_TRACE))
-		page->flags |= 1 << PG_error;
+		SetSlabDebug(page);
 
 	start = page_address(page);
 	end = start + s->objects * s->size;
@@ -889,7 +904,7 @@ static void __free_slab(struct kmem_cach
 {
 	int pages = 1 << s->order;
 
-	if (unlikely(PageError(page) || s->dtor)) {
+	if (unlikely(SlabDebug(page) || s->dtor)) {
 		void *p;
 
 		slab_pad_check(s, page);
@@ -936,7 +951,8 @@ static void discard_slab(struct kmem_cac
 
 	atomic_long_dec(&n->nr_slabs);
 	reset_page_mapcount(page);
-	page->flags &= ~(1 << PG_slab | 1 << PG_error);
+	ClearSlabDebug(page);
+	__ClearPageSlab(page);
 	free_slab(s, page);
 }
 
@@ -1111,7 +1127,7 @@ static void putback_slab(struct kmem_cac
 
 		if (page->freelist)
 			add_partial(n, page);
-		else if (PageError(page) && (s->flags & SLAB_STORE_USER))
+		else if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
 			add_full(n, page);
 		slab_unlock(page);
 
@@ -1195,7 +1211,7 @@ static void flush_all(struct kmem_cache 
  * per cpu array in the kmem_cache struct.
  *
  * Fastpath is not possible if we need to get a new slab or have
- * debugging enabled (which means all slabs are marked with PageError)
+ * debugging enabled (which means all slabs are marked with SlabDebug)
  */
 static void *slab_alloc(struct kmem_cache *s,
 				gfp_t gfpflags, int node, void *addr)
@@ -1218,7 +1234,7 @@ redo:
 	object = page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(PageError(page)))
+	if (unlikely(SlabDebug(page)))
 		goto debug;
 
 have_object:
@@ -1316,7 +1332,7 @@ static void slab_free(struct kmem_cache 
 	local_irq_save(flags);
 	slab_lock(page);
 
-	if (unlikely(PageError(page)))
+	if (unlikely(SlabDebug(page)))
 		goto debug;
 checks_ok:
 	prior = object[page->offset] = page->freelist;
@@ -2504,12 +2520,12 @@ static void validate_slab_slab(struct km
 			s->name, page);
 
 	if (s->flags & DEBUG_DEFAULT_FLAGS) {
-		if (!PageError(page))
-			printk(KERN_ERR "SLUB %s: PageError not set "
+		if (!SlabDebug(page))
+			printk(KERN_ERR "SLUB %s: SlabDebug not set "
 				"on slab 0x%p\n", s->name, page);
 	} else {
-		if (PageError(page))
-			printk(KERN_ERR "SLUB %s: PageError set on "
+		if (SlabDebug(page))
+			printk(KERN_ERR "SLUB %s: SlabDebug set on "
 				"slab 0x%p\n", s->name, page);
 	}
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
