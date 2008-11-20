Date: Thu, 20 Nov 2008 01:17:31 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 4/7] mm: add Set,ClearPageSwapCache stubs
In-Reply-To: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811200116270.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If we add NOOP stubs for SetPageSwapCache() and ClearPageSwapCache(),
then we can remove the #ifdef CONFIG_SWAPs from mm/migrate.c.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/page-flags.h |    1 +
 mm/migrate.c               |    4 ----
 2 files changed, 1 insertion(+), 4 deletions(-)

--- mmclean3/include/linux/page-flags.h	2008-11-19 15:25:12.000000000 +0000
+++ mmclean4/include/linux/page-flags.h	2008-11-19 15:26:18.000000000 +0000
@@ -230,6 +230,7 @@ PAGEFLAG_FALSE(HighMem)
 PAGEFLAG(SwapCache, swapcache)
 #else
 PAGEFLAG_FALSE(SwapCache)
+	SETPAGEFLAG_NOOP(SwapCache) CLEARPAGEFLAG_NOOP(SwapCache)
 #endif
 
 #ifdef CONFIG_UNEVICTABLE_LRU
--- mmclean3/mm/migrate.c	2008-11-19 15:26:13.000000000 +0000
+++ mmclean4/mm/migrate.c	2008-11-19 15:26:18.000000000 +0000
@@ -300,12 +300,10 @@ static int migrate_page_move_mapping(str
 	 * Now we know that no one else is looking at the page.
 	 */
 	get_page(newpage);	/* add cache reference */
-#ifdef CONFIG_SWAP
 	if (PageSwapCache(page)) {
 		SetPageSwapCache(newpage);
 		set_page_private(newpage, page_private(page));
 	}
-#endif
 
 	radix_tree_replace_slot(pslot, newpage);
 
@@ -373,9 +371,7 @@ static void migrate_page_copy(struct pag
 
 	mlock_migrate_page(newpage, page);
 
-#ifdef CONFIG_SWAP
 	ClearPageSwapCache(page);
-#endif
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
 	/* page->mapping contains a flag for PageAnon() */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
