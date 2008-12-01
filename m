Date: Mon, 1 Dec 2008 00:40:26 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 1/8] badpage: simplify page_alloc flag check+clear
In-Reply-To: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010038220.11401@blonde.site>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russ Anderson <rja@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Simplify the PAGE_FLAGS checking and clearing when freeing and allocating
a page: check the same flags as before when freeing, clear ALL the flags
(unless PageReserved) when freeing, check ALL flags off when allocating.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/page-flags.h |   25 ++++++++-----------------
 mm/page_alloc.c            |   19 ++++++-------------
 2 files changed, 14 insertions(+), 30 deletions(-)

--- badpage0/include/linux/page-flags.h	2008-11-26 12:18:59.000000000 +0000
+++ badpage1/include/linux/page-flags.h	2008-11-28 20:40:33.000000000 +0000
@@ -375,31 +375,22 @@ static inline void __ClearPageTail(struc
 #define __PG_MLOCKED		0
 #endif
 
-#define PAGE_FLAGS	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
-			 1 << PG_buddy | 1 << PG_writeback | \
-			 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
-			 __PG_UNEVICTABLE | __PG_MLOCKED)
-
-/*
- * Flags checked in bad_page().  Pages on the free list should not have
- * these flags set.  It they are, there is a problem.
- */
-#define PAGE_FLAGS_CLEAR_WHEN_BAD (PAGE_FLAGS | \
-		1 << PG_reclaim | 1 << PG_dirty | 1 << PG_swapbacked)
-
 /*
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
  */
-#define PAGE_FLAGS_CHECK_AT_FREE (PAGE_FLAGS | 1 << PG_reserved)
+#define PAGE_FLAGS_CHECK_AT_FREE \
+	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
+	 1 << PG_buddy | 1 << PG_writeback | 1 << PG_reserved | \
+	 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
+	 __PG_UNEVICTABLE | __PG_MLOCKED)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
- * Pages being prepped should not have these flags set.  It they are, there
- * is a problem.
+ * Pages being prepped should not have any flags set.  It they are set,
+ * there has been a kernel bug or struct page corruption.
  */
-#define PAGE_FLAGS_CHECK_AT_PREP (PAGE_FLAGS | \
-		1 << PG_reserved | 1 << PG_dirty | 1 << PG_swapbacked)
+#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
 
 #endif /* !__GENERATING_BOUNDS_H */
 #endif	/* PAGE_FLAGS_H */
--- badpage0/mm/page_alloc.c	2008-11-26 12:19:00.000000000 +0000
+++ badpage1/mm/page_alloc.c	2008-11-28 20:40:33.000000000 +0000
@@ -231,7 +231,6 @@ static void bad_page(struct page *page)
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n"
 		KERN_EMERG "Backtrace:\n");
 	dump_stack();
-	page->flags &= ~PAGE_FLAGS_CLEAR_WHEN_BAD;
 	set_page_count(page, 0);
 	reset_page_mapcount(page);
 	page->mapping = NULL;
@@ -468,16 +467,16 @@ static inline int free_pages_check(struc
 		(page_count(page) != 0)  |
 		(page->flags & PAGE_FLAGS_CHECK_AT_FREE)))
 		bad_page(page);
-	if (PageDirty(page))
-		__ClearPageDirty(page);
-	if (PageSwapBacked(page))
-		__ClearPageSwapBacked(page);
 	/*
 	 * For now, we report if PG_reserved was found set, but do not
 	 * clear it, and do not free the page.  But we shall soon need
 	 * to do more, for when the ZERO_PAGE count wraps negative.
 	 */
-	return PageReserved(page);
+	if (PageReserved(page))
+		return 1;
+	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
+		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+	return 0;
 }
 
 /*
@@ -621,13 +620,7 @@ static int prep_new_page(struct page *pa
 	if (PageReserved(page))
 		return 1;
 
-	page->flags &= ~(1 << PG_uptodate | 1 << PG_error | 1 << PG_reclaim |
-			1 << PG_referenced | 1 << PG_arch_1 |
-			1 << PG_owner_priv_1 | 1 << PG_mappedtodisk
-#ifdef CONFIG_UNEVICTABLE_LRU
-			| 1 << PG_mlocked
-#endif
-			);
+	page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	set_page_private(page, 0);
 	set_page_refcounted(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
