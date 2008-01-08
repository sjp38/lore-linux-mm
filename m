Message-Id: <20080108210022.149379441@redhat.com>
References: <20080108205939.323955454@redhat.com>
Date: Tue, 08 Jan 2008 15:59:58 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 19/19] cull non-reclaimable anon pages from the LRU at fault time
Content-Disposition: inline; filename=noreclaim-07-cull-nonreclaimable-anon-pages-in-fault-path.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series.

V1 -> V2:
+  no changes

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
Signed-off-by:  Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc6-mm1/mm/memory.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/memory.c	2008-01-02 12:37:38.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/memory.c	2008-01-02 15:14:31.000000000 -0500
@@ -1665,7 +1665,7 @@ gotten:
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		SetPageSwapBacked(new_page);
-		lru_cache_add_active_anon(new_page);
+		lru_cache_add_active_or_noreclaim(new_page, vma);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -2133,7 +2133,7 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 	inc_mm_counter(mm, anon_rss);
 	SetPageSwapBacked(page);
-	lru_cache_add_active_anon(page);
+	lru_cache_add_active_or_noreclaim(page, vma);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
@@ -2285,10 +2285,10 @@ static int __do_fault(struct mm_struct *
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
-                        inc_mm_counter(mm, anon_rss);
+			inc_mm_counter(mm, anon_rss);
 			SetPageSwapBacked(page);
-                        lru_cache_add_active_anon(page);
-                        page_add_new_anon_rmap(page, vma, address);
+			lru_cache_add_active_or_noreclaim(page, vma);
+			page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(page);
Index: linux-2.6.24-rc6-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/swap_state.c	2008-01-02 12:37:52.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/swap_state.c	2008-01-02 15:14:31.000000000 -0500
@@ -300,7 +300,10 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_anon(new_page);
+			if (!page_reclaimable(new_page, vma))
+				lru_cache_add_noreclaim(new_page);
+			else
+				lru_cache_add_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
