From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070412103234.5564.75180.sendpatchset@linux.site>
In-Reply-To: <20070412103151.5564.16127.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
Subject: [patch 4/9] mm: __add_to_swap_cache stuff
Date: Thu, 12 Apr 2007 14:45:23 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

__add_to_swap_cache unconditionally sets the page locked. Instead, just
ensure that the page is locked (which is a usual invariant for manipulating
swapcache).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -74,6 +74,7 @@ static int __add_to_swap_cache(struct pa
 {
 	int error;
 
+	BUG_ON(!PageLocked(page));
 	BUG_ON(PageSwapCache(page));
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
@@ -83,7 +84,6 @@ static int __add_to_swap_cache(struct pa
 						entry.val, page);
 		if (!error) {
 			page_cache_get(page);
-			SetPageLocked(page);
 			SetPageSwapCache(page);
 			set_page_private(page, entry.val);
 			total_swapcache_pages++;
@@ -337,6 +337,7 @@ struct page *read_swap_cache_async(swp_e
 			new_page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
+			SetPageLocked(new_page);/* could be non-atomic op */
 		}
 
 		/*
@@ -360,7 +361,9 @@ struct page *read_swap_cache_async(swp_e
 		}
 	} while (err != -ENOENT && err != -ENOMEM);
 
-	if (new_page)
+	if (new_page) {
+		ClearPageLocked(new_page);
 		page_cache_release(new_page);
+	}
 	return found_page;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
