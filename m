From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [4/13] Prepare page_alloc for the maskable allocator
Message-Id: <20080307090714.9493F1B419C@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:14 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The maskable allocator needs some functions from page_alloc.c exported;
in particular free_pages_check and prep_new_page. Do that using mm/internal.h

Also extend free_pages_check to support custom flags and allow prep_new_page
to ignore the Reserved bit.

No behaviour change itself; just some code movement.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 mm/internal.h   |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |   63 +++-------------------------------------------------
 2 files changed, 71 insertions(+), 59 deletions(-)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -44,7 +44,6 @@
 #include <linux/backing-dev.h>
 #include <linux/fault-inject.h>
 #include <linux/page-isolation.h>
-#include <linux/memcontrol.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -220,7 +219,7 @@ static inline int bad_range(struct zone 
 }
 #endif
 
-static void bad_page(struct page *page)
+void bad_page(struct page *page)
 {
 	void *pc = page_get_page_cgroup(page);
 
@@ -456,33 +455,6 @@ static inline void __free_one_page(struc
 	zone->free_area[order].nr_free++;
 }
 
-static inline int free_pages_check(struct page *page)
-{
-	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
-		(page_count(page) != 0)  |
-		(page->flags & (
-			1 << PG_lru	|
-			1 << PG_private |
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_slab	|
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_reserved |
-			1 << PG_buddy ))))
-		bad_page(page);
-	if (PageDirty(page))
-		__ClearPageDirty(page);
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not free the page.  But we shall soon need
-	 * to do more, for when the ZERO_PAGE count wraps negative.
-	 */
-	return PageReserved(page);
-}
-
 /*
  * Frees a list of pages. 
  * Assumes all pages on list are in same zone, and of same order.
@@ -528,7 +500,7 @@ static void __free_pages_ok(struct page 
 	int reserved = 0;
 
 	for (i = 0 ; i < (1 << order) ; ++i)
-		reserved += free_pages_check(page + i);
+		reserved += free_pages_check(page + i, 0);
 	if (reserved)
 		return;
 
@@ -608,36 +580,9 @@ static inline void expand(struct zone *z
  */
 static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
-	if (unlikely(page_mapcount(page) |
-		(page->mapping != NULL)  |
-		(page_get_page_cgroup(page) != NULL) |
-		(page_count(page) != 0)  |
-		(page->flags & (
-			1 << PG_lru	|
-			1 << PG_private	|
-			1 << PG_locked	|
-			1 << PG_active	|
-			1 << PG_dirty	|
-			1 << PG_slab    |
-			1 << PG_swapcache |
-			1 << PG_writeback |
-			1 << PG_reserved |
-			1 << PG_buddy ))))
-		bad_page(page);
-
-	/*
-	 * For now, we report if PG_reserved was found set, but do not
-	 * clear it, and do not allocate the page: as a safety net.
-	 */
-	if (PageReserved(page))
+	if (page_prep_struct(page))
 		return 1;
 
-	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
-			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
-	set_page_private(page, 0);
-	set_page_refcounted(page);
-
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
 
@@ -992,7 +937,7 @@ static void free_hot_cold_page(struct pa
 
 	if (PageAnon(page))
 		page->mapping = NULL;
-	if (free_pages_check(page))
+	if (free_pages_check(page, 0))
 		return;
 
 	if (!PageHighMem(page))
Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
 
 static inline void set_page_count(struct page *page, int v)
 {
@@ -48,6 +49,72 @@ static inline unsigned long page_order(s
 	return page_private(page);
 }
 
+extern void bad_page(struct page *page);
+
+static inline int free_pages_check(struct page *page, unsigned long addflags)
+{
+	if (unlikely(page_mapcount(page) |
+		(page->mapping != NULL)  |
+		(page_get_page_cgroup(page) != NULL) |
+		(page_count(page) != 0)  |
+		(page->flags & (
+			addflags |
+			1 << PG_lru	|
+			1 << PG_private |
+			1 << PG_locked	|
+			1 << PG_active	|
+			1 << PG_slab	|
+			1 << PG_swapcache |
+			1 << PG_writeback |
+			1 << PG_reserved |
+			1 << PG_buddy))))
+		bad_page(page);
+	if (PageDirty(page))
+		__ClearPageDirty(page);
+	/*
+	 * For now, we report if PG_reserved was found set, but do not
+	 * clear it, and do not free the page.  But we shall soon need
+	 * to do more, for when the ZERO_PAGE count wraps negative.
+	 */
+	return PageReserved(page);
+}
+
+/* Set up a struc page for business during allocation */
+static inline int page_prep_struct(struct page *page)
+{
+	if (unlikely(page_mapcount(page) |
+		(page->mapping != NULL)  |
+		(page_get_page_cgroup(page) != NULL) |
+		(page_count(page) != 0)  |
+		(page->flags & (
+			1 << PG_lru	|
+			1 << PG_private	|
+			1 << PG_locked	|
+			1 << PG_active	|
+			1 << PG_dirty	|
+			1 << PG_slab    |
+			1 << PG_swapcache |
+			1 << PG_writeback |
+			1 << PG_reserved |
+			1 << PG_buddy))))
+		bad_page(page);
+
+	/*
+	 * For now, we report if PG_reserved was found set, but do not
+	 * clear it, and do not allocate the page: as a safety net.
+	 */
+	if (PageReserved(page))
+		return 1;
+
+	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_readahead |
+			1 << PG_referenced | 1 << PG_arch_1 |
+			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk);
+	set_page_private(page, 0);
+	set_page_refcounted(page);
+
+	return 0;
+}
+
 /*
  * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
  * so all functions starting at paging_init should be marked __init

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
