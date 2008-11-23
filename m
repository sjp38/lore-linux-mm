Date: Sun, 23 Nov 2008 21:51:26 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 8/7] mm: further cleanup page_add_new_anon_rmap
In-Reply-To: <Pine.LNX.4.64.0811200120160.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811232148430.3617@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
 <Pine.LNX.4.64.0811200120160.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Moving lru_cache_add_active_or_unevictable() into page_add_new_anon_rmap()
was good but done stupidly: we should SetPageSwapBacked() there too; and
we know for sure that this anonymous, swap-backed page is not file cache.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
I suspect Nick might like to change it to __SetPageSwapBacked later.

 mm/memory.c |    3 ---
 mm/rmap.c   |    6 +++---
 2 files changed, 3 insertions(+), 6 deletions(-)

--- mmclean7/mm/memory.c	2008-11-19 15:26:28.000000000 +0000
+++ mmclean8/mm/memory.c	2008-11-22 19:02:35.000000000 +0000
@@ -1919,7 +1919,6 @@ gotten:
 		 * thread doing COW.
 		 */
 		ptep_clear_flush_notify(vma, address, page_table);
-		SetPageSwapBacked(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
@@ -2415,7 +2414,6 @@ static int do_anonymous_page(struct mm_s
 	if (!pte_none(*page_table))
 		goto release;
 	inc_mm_counter(mm, anon_rss);
-	SetPageSwapBacked(page);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
@@ -2563,7 +2561,6 @@ static int __do_fault(struct mm_struct *
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
-			SetPageSwapBacked(page);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
--- mmclean7/mm/rmap.c	2008-11-19 15:26:33.000000000 +0000
+++ mmclean8/mm/rmap.c	2008-11-22 19:02:35.000000000 +0000
@@ -47,7 +47,6 @@
 #include <linux/rmap.h>
 #include <linux/rcupdate.h>
 #include <linux/module.h>
-#include <linux/mm_inline.h>
 #include <linux/kallsyms.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
@@ -673,10 +672,11 @@ void page_add_new_anon_rmap(struct page 
 	struct vm_area_struct *vma, unsigned long address)
 {
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-	atomic_set(&page->_mapcount, 0); /* elevate count by 1 (starts at -1) */
+	SetPageSwapBacked(page);
+	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	__page_set_anon_rmap(page, vma, address);
 	if (page_evictable(page, vma))
-		lru_cache_add_lru(page, LRU_ACTIVE + page_is_file_cache(page));
+		lru_cache_add_lru(page, LRU_ACTIVE);
 	else
 		add_page_to_unevictable_list(page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
