Message-Id: <200405222202.i4MM2Tr11718@mail.osdl.org>
Subject: [patch 04/57] vmscan: revert may_enter_fs changes
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:01:50 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


Fix up the "may we call writepage" logic for the swapcache changes.


---

 25-akpm/mm/vmscan.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff -puN mm/vmscan.c~vmscan-revert-may_enter_fs-changes mm/vmscan.c
--- 25/mm/vmscan.c~vmscan-revert-may_enter_fs-changes	2004-05-22 14:56:21.707791440 -0700
+++ 25-akpm/mm/vmscan.c	2004-05-22 14:56:21.711790832 -0700
@@ -247,7 +247,6 @@ static int
 shrink_list(struct list_head *page_list, unsigned int gfp_mask,
 		int *nr_scanned, int do_writepage)
 {
-	struct address_space *mapping;
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
@@ -257,6 +256,7 @@ shrink_list(struct list_head *page_list,
 
 	pagevec_init(&freed_pvec, 1);
 	while (!list_empty(page_list)) {
+		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
 		int referenced;
@@ -284,9 +284,6 @@ shrink_list(struct list_head *page_list,
 			goto activate_locked;
 		}
 
-		mapping = page_mapping(page);
-		may_enter_fs = (gfp_mask & __GFP_FS);
-
 #ifdef CONFIG_SWAP
 		/*
 		 * Anonymous process memory has backing store?
@@ -300,12 +297,12 @@ shrink_list(struct list_head *page_list,
 				goto activate_locked;
 			page_map_lock(page);
 		}
-		if (PageSwapCache(page)) {
-			mapping = &swapper_space;
-			may_enter_fs = (gfp_mask & __GFP_IO);
-		}
 #endif /* CONFIG_SWAP */
 
+		mapping = page_mapping(page);
+		may_enter_fs = (gfp_mask & __GFP_FS) ||
+			(PageSwapCache(page) && (gfp_mask & __GFP_IO));
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
