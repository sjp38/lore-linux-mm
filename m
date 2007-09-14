From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:55:32 -0400
Message-Id: <20070914205532.6536.29592.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 14/14] Reclaim Scalability:  cull non-reclaimable anon pages in fault path
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 14/14 Reclaim Scalability:  cull non-reclaimable anon pages in fault path

Against:  2.6.23-rc4-mm1

Optional part of "noreclaim infrastructure"

In the fault paths that install new anonymous pages, check whether
the page is reclaimable or not using lru_cache_add_active_or_noreclaim().
If the page is reclaimable, just add it to the active lru list [via
the pagevec cache], else add it to the noreclaim list.  

This "proactive" culling in the fault path mimics the handling of
mlocked pages in Nick Piggin's series to keep mlocked pages off
the lru lists.

Notes:

1) This patch is optional--e.g., if one is concerned about the
   additional test in the fault path.  We can defer the moving of
   nonreclaimable pages until when vmscan [shrink_*_list()]
   encounters them.  Vmscan will only need to handle such pages
   once.

2) I moved the call to page_add_new_anon_rmap() to before the test
   for page_reclaimable() and thus before the calls to
   lru_cache_add_{active|noreclaim}(), so that page_reclaimable()
   could recognize the page as anon, thus obviating, I think, the
   vma arg to page_reclaimable() for this purpose.  Still needed for
   culling mlocked pages in fault path [later patch].
   TBD:   I think this reordering is OK, but the previous order may
   have existed to close some obscure race?

3) With this and other patches above installed, any anon pages
   created before swap is added--e.g., init's anonymous memory--
   will be declared non-reclaimable and placed on the noreclaim
   LRU list.  Need to add mechanism to bring such pages back when
   swap becomes available.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/memory.c     |    6 +++---
 mm/swap_state.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: Linux/mm/memory.c
===================================================================
--- Linux.orig/mm/memory.c	2007-09-13 15:43:27.000000000 -0400
+++ Linux/mm/memory.c	2007-09-13 15:51:53.000000000 -0400
@@ -1665,8 +1665,8 @@ gotten:
 		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
-		lru_cache_add_active(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
+		lru_cache_add_active_or_noreclaim(new_page, vma);
 
 		/* Free the old page.. */
 		new_page = old_page;
@@ -2195,8 +2195,8 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 	inc_mm_counter(mm, anon_rss);
-	lru_cache_add_active(page);
 	page_add_new_anon_rmap(page, vma, address);
+	lru_cache_add_active_or_noreclaim(page, vma);
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
@@ -2346,8 +2346,8 @@ static int __do_fault(struct mm_struct *
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
                         inc_mm_counter(mm, anon_rss);
-                        lru_cache_add_active(page);
                         page_add_new_anon_rmap(page, vma, address);
+			lru_cache_add_active_or_noreclaim(page, vma);
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(page);
Index: Linux/mm/swap_state.c
===================================================================
--- Linux.orig/mm/swap_state.c	2007-09-13 15:43:27.000000000 -0400
+++ Linux/mm/swap_state.c	2007-09-13 15:51:53.000000000 -0400
@@ -368,7 +368,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
+			lru_cache_add_active_or_noreclaim(new_page, vma);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
