From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20051208113010.6309.65348.sendpatchset@cherry.local>
In-Reply-To: <20051208112940.6309.39428.sendpatchset@cherry.local>
References: <20051208112940.6309.39428.sendpatchset@cherry.local>
Subject: [PATCH 06/07] Remove page_remove_rmap
Date: Thu,  8 Dec 2005 20:27:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>, andrea@suse.de
List-ID: <linux-mm.kvack.org>

Remove page_remove_rmap.

This patch simply removes page_remove_rmap(). It is not needed anymore.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 include/linux/rmap.h |    1 -
 mm/fremap.c          |    1 -
 mm/memory.c          |    2 --
 mm/rmap.c            |    2 --
 4 files changed, 6 deletions(-)

--- from-0006/include/linux/rmap.h
+++ to-work/include/linux/rmap.h	2005-12-08 18:09:00.000000000 +0900
@@ -75,7 +75,6 @@ void __anon_vma_link(struct vm_area_stru
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
 
-static inline void page_remove_rmap(struct page *page) {}
 static inline void page_dup_rmap(struct page *page) {}
 
 int update_page_mapped(struct page *);
--- from-0006/mm/fremap.c
+++ to-work/mm/fremap.c	2005-12-08 18:10:07.000000000 +0900
@@ -33,7 +33,6 @@ static int zap_pte(struct mm_struct *mm,
 		if (page) {
 			if (pte_dirty(pte))
 				set_page_dirty(page);
-			page_remove_rmap(page);
 			page_cache_release(page);
 		}
 	} else {
--- from-0002/mm/memory.c
+++ to-work/mm/memory.c	2005-12-08 18:10:17.000000000 +0900
@@ -649,7 +649,6 @@ static unsigned long zap_pte_range(struc
 					mark_page_accessed(page);
 				file_rss--;
 			}
-			page_remove_rmap(page);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
@@ -1514,7 +1513,6 @@ gotten:
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
-			page_remove_rmap(old_page);
 			if (!PageAnon(old_page)) {
 				dec_mm_counter(mm, file_rss);
 				inc_mm_counter(mm, anon_rss);
--- from-0006/mm/rmap.c
+++ to-work/mm/rmap.c	2005-12-08 18:10:28.000000000 +0900
@@ -640,7 +640,6 @@ static int try_to_unmap_one(struct page 
 	} else
 		dec_mm_counter(mm, file_rss);
 
-	page_remove_rmap(page);
 	page_cache_release(page);
 
 out_unmap:
@@ -730,7 +729,6 @@ static void try_to_unmap_cluster(unsigne
 		if (pte_dirty(pteval))
 			set_page_dirty(page);
 
-		page_remove_rmap(page);
 		page_cache_release(page);
 		dec_mm_counter(mm, file_rss);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
