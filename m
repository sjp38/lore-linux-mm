From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] 9/4  -ac to newer rmap
Message-Id: <20021113145002Z80365-18062+19@imladris.surriel.com>
Date: Wed, 13 Nov 2002 12:50:02 -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

No need to check PageSwapCache(page) twice in a row.

(ObWork: my patches are sponsored by Conectiva, Inc)
--- linux-2.4.19/mm/page_io.c	2002-11-13 08:48:31.000000000 -0200
+++ linux-2.4-rmap/mm/page_io.c	2002-11-13 12:10:46.000000000 -0200
@@ -87,7 +87,6 @@ static int rw_swap_page_base(int rw, swp
  *  - it's marked as being swap-cache
  *  - it's associated with the swap inode
  */
-
 void rw_swap_page(int rw, struct page *page)
 {
 	swp_entry_t entry;
@@ -98,8 +97,6 @@ void rw_swap_page(int rw, struct page *p
 		PAGE_BUG(page);
 	if (!PageSwapCache(page))
 		PAGE_BUG(page);
-	if (page->mapping != &swapper_space)
-		PAGE_BUG(page);
 	if (!rw_swap_page_base(rw, entry, page))
 		UnlockPage(page);
 }
@@ -115,8 +112,6 @@ void rw_swap_page_nolock(int rw, swp_ent
 	
 	if (!PageLocked(page))
 		PAGE_BUG(page);
-	if (PageSwapCache(page))
-		PAGE_BUG(page);
 	if (page->mapping)
 		PAGE_BUG(page);
 	/* needs sync_page to wait I/O completation */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
