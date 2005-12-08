From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208113005.6309.22155.sendpatchset@cherry.local>
In-Reply-To: <20051208112940.6309.39428.sendpatchset@cherry.local>
References: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 05/07] Remove reset_page_mapcount
Date: Thu,  8 Dec 2005 20:27:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Remove reset_page_mapcount.

This patch simply removes reset_page_mapcount(). It is not needed anymore.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 include/linux/mm.h |   10 ----------
 mm/page_alloc.c    |    5 ++---
 2 files changed, 2 insertions(+), 13 deletions(-)

--- from-0006/include/linux/mm.h
+++ to-work/include/linux/mm.h	2005-12-08 18:03:42.000000000 +0900
@@ -573,16 +573,6 @@ static inline pgoff_t page_index(struct 
 }
 
 /*
- * The atomic page->_mapcount, like _count, starts from -1:
- * so that transitions both from it and to it can be tracked,
- * using atomic_inc_and_test and atomic_add_negative(-1).
- */
-static inline void reset_page_mapcount(struct page *page)
-{
-	ClearPageMapped(page);
-}
-
-/*
  * Return true if this page is mapped into pagetables.
  */
 static inline int page_mapped(struct page *page)
--- from-0005/mm/page_alloc.c
+++ to-work/mm/page_alloc.c	2005-12-08 18:06:43.000000000 +0900
@@ -141,9 +141,9 @@ static void bad_page(const char *functio
 			1 << PG_reclaim |
 			1 << PG_slab    |
 			1 << PG_swapcache |
-			1 << PG_writeback );
+			1 << PG_writeback |
+			1 << PG_mapped );
 	set_page_count(page, 0);
-	reset_page_mapcount(page);
 	page->mapping = NULL;
 	add_taint(TAINT_BAD_PAGE);
 }
@@ -1716,7 +1716,6 @@ void __devinit memmap_init_zone(unsigned
 		page = pfn_to_page(pfn);
 		set_page_links(page, zone, nid, pfn);
 		set_page_count(page, 1);
-		reset_page_mapcount(page);
 		SetPageReserved(page);
 		INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
