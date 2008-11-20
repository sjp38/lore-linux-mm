Date: Thu, 20 Nov 2008 01:22:45 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 6/7] mm: add_active_or_unevictable into rmap
In-Reply-To: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811200120160.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

lru_cache_add_active_or_unevictable() and page_add_new_anon_rmap()
always appear together.  Save some symbol table space and some jumping
around by removing lru_cache_add_active_or_unevictable(), folding its
code into page_add_new_anon_rmap(): like how we add file pages to lru
just after adding them to page cache.

Remove the nearby "TODO: is this safe?" comments (yes, it is safe),
and change page_add_new_anon_rmap()'s address BUG_ON to VM_BUG_ON
as originally intended.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/swap.h |    2 --
 mm/memory.c          |    6 ------
 mm/rmap.c            |    7 ++++++-
 mm/swap.c            |   19 -------------------
 4 files changed, 6 insertions(+), 28 deletions(-)

--- mmclean5/include/linux/swap.h	2008-11-19 15:25:12.000000000 +0000
+++ mmclean6/include/linux/swap.h	2008-11-19 15:26:28.000000000 +0000
@@ -174,8 +174,6 @@ extern unsigned int nr_free_pagecache_pa
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
-extern void lru_cache_add_active_or_unevictable(struct page *,
-					struct vm_area_struct *);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
--- mmclean5/mm/memory.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean6/mm/memory.c	2008-11-19 15:26:28.000000000 +0000
@@ -1920,10 +1920,7 @@ gotten:
 		 */
 		ptep_clear_flush_notify(vma, address, page_table);
 		SetPageSwapBacked(new_page);
-		lru_cache_add_active_or_unevictable(new_page, vma);
 		page_add_new_anon_rmap(new_page, vma, address);
-
-//TODO:  is this safe?  do_anonymous_page() does it this way.
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		if (old_page) {
@@ -2419,7 +2416,6 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 	inc_mm_counter(mm, anon_rss);
 	SetPageSwapBacked(page);
-	lru_cache_add_active_or_unevictable(page, vma);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
@@ -2568,7 +2564,6 @@ static int __do_fault(struct mm_struct *
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
 			SetPageSwapBacked(page);
-			lru_cache_add_active_or_unevictable(page, vma);
 			page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
@@ -2578,7 +2573,6 @@ static int __do_fault(struct mm_struct *
 				get_page(dirty_page);
 			}
 		}
-//TODO:  is this safe?  do_anonymous_page() does it this way.
 		set_pte_at(mm, address, page_table, entry);
 
 		/* no need to invalidate: a not-present page won't be cached */
--- mmclean5/mm/rmap.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean6/mm/rmap.c	2008-11-19 15:26:28.000000000 +0000
@@ -47,6 +47,7 @@
 #include <linux/rmap.h>
 #include <linux/rcupdate.h>
 #include <linux/module.h>
+#include <linux/mm_inline.h>
 #include <linux/kallsyms.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
@@ -671,9 +672,13 @@ void page_add_anon_rmap(struct page *pag
 void page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
-	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
+	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	atomic_set(&page->_mapcount, 0); /* elevate count by 1 (starts at -1) */
 	__page_set_anon_rmap(page, vma, address);
+	if (page_evictable(page, vma))
+		lru_cache_add_lru(page, LRU_ACTIVE + page_is_file_cache(page));
+	else
+		add_page_to_unevictable_list(page);
 }
 
 /**
--- mmclean5/mm/swap.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean6/mm/swap.c	2008-11-19 15:26:28.000000000 +0000
@@ -246,25 +246,6 @@ void add_page_to_unevictable_list(struct
 	spin_unlock_irq(&zone->lru_lock);
 }
 
-/**
- * lru_cache_add_active_or_unevictable
- * @page:  the page to be added to LRU
- * @vma:   vma in which page is mapped for determining reclaimability
- *
- * place @page on active or unevictable LRU list, depending on
- * page_evictable().  Note that if the page is not evictable,
- * it goes directly back onto it's zone's unevictable list.  It does
- * NOT use a per cpu pagevec.
- */
-void lru_cache_add_active_or_unevictable(struct page *page,
-					struct vm_area_struct *vma)
-{
-	if (page_evictable(page, vma))
-		lru_cache_add_lru(page, LRU_ACTIVE + page_is_file_cache(page));
-	else
-		add_page_to_unevictable_list(page);
-}
-
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
