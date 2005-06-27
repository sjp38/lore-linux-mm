Message-ID: <42BF9D67.10509@yahoo.com.au>
Date: Mon, 27 Jun 2005 16:32:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 1] mm: PG_free flag
References: <42BF9CD1.2030102@yahoo.com.au>
In-Reply-To: <42BF9CD1.2030102@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------070608040607080402090805"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070608040607080402090805
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


-- 
SUSE Labs, Novell Inc.

--------------070608040607080402090805
Content-Type: text/plain;
 name="mm-PG_free-flag.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-PG_free-flag.patch"

In a future patch we can no longer rely on page_count being stable at any
time, so we can no longer overload PagePrivate && page_count == 0 to mean
the page is free and on the buddy lists.

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -76,6 +76,8 @@
 #define PG_nosave_free		18	/* Free, should not be written */
 #define PG_uncached		19	/* Page has been mapped as uncached */
 
+#define PG_free			20	/* Page is on the free lists */
+
 /*
  * Global page accounting.  One instance per CPU.  Only unsigned longs are
  * allowed.
@@ -306,6 +308,10 @@ extern void __mod_page_state(unsigned lo
 #define SetPageUncached(page)	set_bit(PG_uncached, &(page)->flags)
 #define ClearPageUncached(page)	clear_bit(PG_uncached, &(page)->flags)
 
+#define PageFree(page)		test_bit(PG_free, &(page)->flags)
+#define __SetPageFree(page)	__set_bit(PG_free, &(page)->flags)
+#define __ClearPageFree(page)	__clear_bit(PG_free, &(page)->flags)
+
 struct page;	/* forward declaration */
 
 int test_clear_page_dirty(struct page *page);
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -114,7 +114,8 @@ static void bad_page(const char *functio
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_reserved );
+			1 << PG_reserved |
+			1 << PG_free );
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -191,12 +192,12 @@ static inline unsigned long page_order(s
 
 static inline void set_page_order(struct page *page, int order) {
 	page->private = order;
-	__SetPagePrivate(page);
+	__SetPageFree(page);
 }
 
 static inline void rmv_page_order(struct page *page)
 {
-	__ClearPagePrivate(page);
+	__ClearPageFree(page);
 	page->private = 0;
 }
 
@@ -242,9 +243,7 @@ __find_combined_index(unsigned long page
  */
 static inline int page_is_buddy(struct page *page, int order)
 {
-       if (PagePrivate(page)           &&
-           (page_order(page) == order) &&
-            page_count(page) == 0)
+       if (PageFree(page) && (page_order(page) == order))
                return 1;
        return 0;
 }
@@ -327,7 +326,8 @@ static inline void free_pages_check(cons
 			1 << PG_slab	|
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_reserved )))
+			1 << PG_reserved |
+			1 << PG_free )))
 		bad_page(function, page);
 	if (PageDirty(page))
 		__ClearPageDirty(page);
@@ -456,7 +456,8 @@ static void prep_new_page(struct page *p
 			1 << PG_slab    |
 			1 << PG_swapcache |
 			1 << PG_writeback |
-			1 << PG_reserved )))
+			1 << PG_reserved |
+			1 << PG_free )))
 		bad_page(__FUNCTION__, page);
 
 	page->flags &= ~(1 << PG_uptodate | 1 << PG_error |

--------------070608040607080402090805--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
