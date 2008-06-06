Message-Id: <20080606202859.767782358@redhat.com>
References: <20080606202838.390050172@redhat.com>
Date: Fri, 06 Jun 2008 16:28:59 -0400
From: Rik van Riel <riel@redhat.com>
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 21/25] Cull non-reclaimable pages in fault path
Content-Disposition: inline; filename=rvr-21-lts-noreclaim-optional-scan-noreclaim-list-for-reclaimable-pages.patch
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Against:  2.6.26-rc2-mm1

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split lru series.

V1 -> V2:
+  no changes

"Optional" part of "noreclaim infrastructure"

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

2) The 'vma' argument to page_reclaimable() is require to notice that
   we're faulting a page into an mlock()ed vma w/o having to scan the
   page's rmap in the fault path.   Culling mlock()ed anon pages is
   currently the only reason for this patch.

3) We can't cull swap pages in read_swap_cache_async() because the
   vma argument doesn't necessarily correspond to the swap cache
   offset passed in by swapin_readahead().  This could [did!] result
   in mlocking pages in non-VM_LOCKED vmas if [when] we tried to
   cull in this path.

4) Move set_pte_at() to after where we add page to lru to keep it
   hidden from other tasks that might walk the page table.
   We already do it in this order in do_anonymous() page.  And,
   these are COW'd anon pages.  Is this safe?


Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>

 include/linux/swap.h |    2 ++
 mm/memory.c          |   20 ++++++++++++--------
 mm/swap.c            |   21 +++++++++++++++++++++
 3 files changed, 35 insertions(+), 8 deletions(-)

Index: linux-2.6.26-rc2-mm1/mm/memory.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/memory.c	2008-06-06 16:06:28.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/memory.c	2008-06-06 16:06:44.000000000 -0400
@@ -1774,12 +1774,15 @@ gotten:
 		 * thread doing COW.
 		 */
 		ptep_clear_flush(vma, address, page_table);
-		set_pte_at(mm, address, page_table, entry);
-		update_mmu_cache(vma, address, entry);
+
 		SetPageSwapBacked(new_page);
-		lru_cache_add_active_anon(new_page);
+		lru_cache_add_active_or_noreclaim(new_page, vma);
 		page_add_new_anon_rmap(new_page, vma, address);
 
+//TODO:  is this safe?  do_anonymous_page() does it this way.
+		set_pte_at(mm, address, page_table, entry);
+		update_mmu_cache(vma, address, entry);
+
 		/* Free the old page.. */
 		new_page = old_page;
 		ret |= VM_FAULT_WRITE;
@@ -2246,7 +2249,7 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 	inc_mm_counter(mm, anon_rss);
 	SetPageSwapBacked(page);
-	lru_cache_add_active_anon(page);
+	lru_cache_add_active_or_noreclaim(page, vma);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
@@ -2390,12 +2393,11 @@ static int __do_fault(struct mm_struct *
 		entry = mk_pte(page, vma->vm_page_prot);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		set_pte_at(mm, address, page_table, entry);
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
@@ -2404,6 +2406,8 @@ static int __do_fault(struct mm_struct *
 				get_page(dirty_page);
 			}
 		}
+//TODO:  is this safe?  do_anonymous_page() does it this way.
+		set_pte_at(mm, address, page_table, entry);
 
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
Index: linux-2.6.26-rc2-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/swap.h	2008-06-06 16:06:24.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/swap.h	2008-06-06 16:06:44.000000000 -0400
@@ -173,6 +173,8 @@ extern unsigned int nr_free_pagecache_pa
 /* linux/mm/swap.c */
 extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
+extern void lru_cache_add_active_or_noreclaim(struct page *,
+					struct vm_area_struct *);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
Index: linux-2.6.26-rc2-mm1/mm/swap.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/swap.c	2008-06-06 16:06:28.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/swap.c	2008-06-06 16:06:44.000000000 -0400
@@ -31,6 +31,8 @@
 #include <linux/backing-dev.h>
 #include <linux/memcontrol.h>
 
+#include "internal.h"
+
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
@@ -273,6 +275,25 @@ void add_page_to_noreclaim_list(struct p
 	spin_unlock_irq(&zone->lru_lock);
 }
 
+/**
+ * lru_cache_add_active_or_noreclaim
+ * @page:  the page to be added to LRU
+ * @vma:   vma in which page is mapped for determining reclaimability
+ *
+ * place @page on active or noreclaim LRU list, depending on
+ * page_reclaimable().  Note that if the page is not reclaimable,
+ * it goes directly back onto it's zone's noreclaim list.  It does
+ * NOT use a per cpu pagevec.
+ */
+void lru_cache_add_active_or_noreclaim(struct page *page,
+					struct vm_area_struct *vma)
+{
+	if (page_reclaimable(page, vma))
+		lru_cache_add_lru(page, LRU_ACTIVE + page_file_cache(page));
+	else
+		add_page_to_noreclaim_list(page);
+}
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
