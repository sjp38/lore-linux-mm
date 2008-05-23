From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/3] slub: record page flag overlays explicitly
References: <exportbomb.1211560342@pinky>
Date: Fri, 23 May 2008 17:33:22 +0100
Message-Id: <1211560402.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

SLUB reuses two page bits for internal purposes, it overlays PG_active
and PG_error.  This is hidden away in slub.c.  Document these overlays
explicitly in the main page-flags enum along with all the others.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/page-flags.h |    7 +++++
 mm/slub.c                  |   65 +++++++++++--------------------------------
 2 files changed, 24 insertions(+), 48 deletions(-)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 2cc1fb1..dfd0a26 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -103,6 +103,10 @@ enum pageflags {
 
 	/* XEN */
 	PG_pinned = PG_owner_priv_1,
+
+	/* SLUB */
+	PG_slub_frozen = PG_active,
+	PG_slub_debug = PG_error,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -167,6 +171,9 @@ PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)
 
+__PAGEFLAG(SlubFrozen, slub_frozen)
+__PAGEFLAG(SlubDebug, slub_debug)
+
 /*
  * Only test-and-set exist for PG_writeback.  The unconditional operators are
  * risky: they bypass page accounting.
diff --git a/mm/slub.c b/mm/slub.c
index a505a82..c7f5653 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -102,44 +102,12 @@
  * 			the fast path and disables lockless freelists.
  */
 
-#define FROZEN (1 << PG_active)
-
 #ifdef CONFIG_SLUB_DEBUG
-#define SLABDEBUG (1 << PG_error)
+#define SLABDEBUG 1
 #else
 #define SLABDEBUG 0
 #endif
 
-static inline int SlabFrozen(struct page *page)
-{
-	return page->flags & FROZEN;
-}
-
-static inline void SetSlabFrozen(struct page *page)
-{
-	page->flags |= FROZEN;
-}
-
-static inline void ClearSlabFrozen(struct page *page)
-{
-	page->flags &= ~FROZEN;
-}
-
-static inline int SlabDebug(struct page *page)
-{
-	return page->flags & SLABDEBUG;
-}
-
-static inline void SetSlabDebug(struct page *page)
-{
-	page->flags |= SLABDEBUG;
-}
-
-static inline void ClearSlabDebug(struct page *page)
-{
-	page->flags &= ~SLABDEBUG;
-}
-
 /*
  * Issues still to be resolved:
  *
@@ -972,7 +940,7 @@ static int free_debug_processing(struct kmem_cache *s, struct page *page,
 	}
 
 	/* Special debug activities for freeing objects */
-	if (!SlabFrozen(page) && !page->freelist)
+	if (!PageSlubFrozen(page) && !page->freelist)
 		remove_full(s, page);
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
@@ -1158,7 +1126,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 	page->flags |= 1 << PG_slab;
 	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
 			SLAB_STORE_USER | SLAB_TRACE))
-		SetSlabDebug(page);
+		__SetPageSlubDebug(page);
 
 	start = page_address(page);
 
@@ -1185,14 +1153,14 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	int order = compound_order(page);
 	int pages = 1 << order;
 
-	if (unlikely(SlabDebug(page))) {
+	if (unlikely(SLABDEBUG && PageSlubDebug(page))) {
 		void *p;
 
 		slab_pad_check(s, page);
 		for_each_object(p, s, page_address(page),
 						page->objects)
 			check_object(s, page, p, 0);
-		ClearSlabDebug(page);
+		__ClearPageSlubDebug(page);
 	}
 
 	mod_zone_page_state(page_zone(page),
@@ -1289,7 +1257,7 @@ static inline int lock_and_freeze_slab(struct kmem_cache_node *n,
 	if (slab_trylock(page)) {
 		list_del(&page->lru);
 		n->nr_partial--;
-		SetSlabFrozen(page);
+		__SetPageSlubFrozen(page);
 		return 1;
 	}
 	return 0;
@@ -1399,7 +1367,7 @@ static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
 	struct kmem_cache_cpu *c = get_cpu_slab(s, smp_processor_id());
 
-	ClearSlabFrozen(page);
+	__ClearPageSlubFrozen(page);
 	if (page->inuse) {
 
 		if (page->freelist) {
@@ -1407,7 +1375,8 @@ static void unfreeze_slab(struct kmem_cache *s, struct page *page, int tail)
 			stat(c, tail ? DEACTIVATE_TO_TAIL : DEACTIVATE_TO_HEAD);
 		} else {
 			stat(c, DEACTIVATE_FULL);
-			if (SlabDebug(page) && (s->flags & SLAB_STORE_USER))
+			if (SLABDEBUG && PageSlubDebug(page) &&
+						(s->flags & SLAB_STORE_USER))
 				add_full(n, page);
 		}
 		slab_unlock(page);
@@ -1560,7 +1529,7 @@ load_freelist:
 	object = c->page->freelist;
 	if (unlikely(!object))
 		goto another_slab;
-	if (unlikely(SlabDebug(c->page)))
+	if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
 		goto debug;
 
 	c->freelist = object[c->offset];
@@ -1597,7 +1566,7 @@ new_slab:
 		if (c->page)
 			flush_slab(s, c);
 		slab_lock(new);
-		SetSlabFrozen(new);
+		__SetPageSlubFrozen(new);
 		c->page = new;
 		goto load_freelist;
 	}
@@ -1681,7 +1650,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	stat(c, FREE_SLOWPATH);
 	slab_lock(page);
 
-	if (unlikely(SlabDebug(page)))
+	if (unlikely(SLABDEBUG && PageSlubDebug(page)))
 		goto debug;
 
 checks_ok:
@@ -1689,7 +1658,7 @@ checks_ok:
 	page->freelist = object;
 	page->inuse--;
 
-	if (unlikely(SlabFrozen(page))) {
+	if (unlikely(PageSlubFrozen(page))) {
 		stat(c, FREE_FROZEN);
 		goto out_unlock;
 	}
@@ -3314,12 +3283,12 @@ static void validate_slab_slab(struct kmem_cache *s, struct page *page,
 			s->name, page);
 
 	if (s->flags & DEBUG_DEFAULT_FLAGS) {
-		if (!SlabDebug(page))
-			printk(KERN_ERR "SLUB %s: SlabDebug not set "
+		if (!PageSlubDebug(page))
+			printk(KERN_ERR "SLUB %s: SlubDebug not set "
 				"on slab 0x%p\n", s->name, page);
 	} else {
-		if (SlabDebug(page))
-			printk(KERN_ERR "SLUB %s: SlabDebug set on "
+		if (PageSlubDebug(page))
+			printk(KERN_ERR "SLUB %s: SlubDebug set on "
 				"slab 0x%p\n", s->name, page);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
