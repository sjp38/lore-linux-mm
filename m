Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 10D1A6B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 23:54:18 -0400 (EDT)
Received: by qady1 with SMTP id y1so745388qad.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2012 20:54:17 -0700 (PDT)
Date: Tue, 18 Sep 2012 20:53:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/4] mm: remove vma arg from page_evictable
In-Reply-To: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1209182052030.11632@eggly.anvils>
References: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

page_evictable(page, vma) is an irritant: almost all its callers pass
NULL for vma.  Remove the vma arg and use mlocked_vma_newpage(vma, page)
explicitly in the couple of places it's needed.  But in those places we
don't even need page_evictable() itself!  They're dealing with a freshly
allocated anonymous page, which has no "mapping" and cannot be mlocked yet.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Ying Han <yinghan@google.com>
---
 Documentation/vm/unevictable-lru.txt |   10 ++-------
 include/linux/swap.h                 |    2 -
 mm/internal.h                        |    5 +---
 mm/ksm.c                             |    2 -
 mm/rmap.c                            |    2 -
 mm/swap.c                            |    2 -
 mm/vmscan.c                          |   27 ++++++++-----------------
 7 files changed, 18 insertions(+), 32 deletions(-)

--- 3.6-rc6.orig/Documentation/vm/unevictable-lru.txt	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/Documentation/vm/unevictable-lru.txt	2012-09-18 16:39:50.878992976 -0700
@@ -197,12 +197,8 @@ the pages are also "rescued" from the un
 freeing them.
 
 page_evictable() also checks for mlocked pages by testing an additional page
-flag, PG_mlocked (as wrapped by PageMlocked()).  If the page is NOT mlocked,
-and a non-NULL VMA is supplied, page_evictable() will check whether the VMA is
-VM_LOCKED via is_mlocked_vma().  is_mlocked_vma() will SetPageMlocked() and
-update the appropriate statistics if the vma is VM_LOCKED.  This method allows
-efficient "culling" of pages in the fault path that are being faulted in to
-VM_LOCKED VMAs.
+flag, PG_mlocked (as wrapped by PageMlocked()), which is set when a page is
+faulted into a VM_LOCKED vma, or found in a vma being VM_LOCKED.
 
 
 VMSCAN'S HANDLING OF UNEVICTABLE PAGES
@@ -651,7 +647,7 @@ PAGE RECLAIM IN shrink_*_list()
 -------------------------------
 
 shrink_active_list() culls any obviously unevictable pages - i.e.
-!page_evictable(page, NULL) - diverting these to the unevictable list.
+!page_evictable(page) - diverting these to the unevictable list.
 However, shrink_active_list() only sees unevictable pages that made it onto the
 active/inactive lru lists.  Note that these pages do not have PageUnevictable
 set - otherwise they would be on the unevictable list and shrink_active_list
--- 3.6-rc6.orig/include/linux/swap.h	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/include/linux/swap.h	2012-09-18 16:39:50.878992976 -0700
@@ -281,7 +281,7 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
-extern int page_evictable(struct page *page, struct vm_area_struct *vma);
+extern int page_evictable(struct page *page);
 extern void check_move_unevictable_pages(struct page **, int nr_pages);
 
 extern unsigned long scan_unevictable_pages;
--- 3.6-rc6.orig/mm/internal.h	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/internal.h	2012-09-18 16:39:50.882992906 -0700
@@ -167,9 +167,8 @@ static inline void munlock_vma_pages_all
 }
 
 /*
- * Called only in fault path via page_evictable() for a new page
- * to determine if it's being mapped into a LOCKED vma.
- * If so, mark page as mlocked.
+ * Called only in fault path, to determine if a new page is being
+ * mapped into a LOCKED vma.  If it is, mark page as mlocked.
  */
 static inline int mlocked_vma_newpage(struct vm_area_struct *vma,
 				    struct page *page)
--- 3.6-rc6.orig/mm/ksm.c	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/ksm.c	2012-09-18 16:39:50.882992906 -0700
@@ -1582,7 +1582,7 @@ struct page *ksm_does_need_to_copy(struc
 		SetPageSwapBacked(new_page);
 		__set_page_locked(new_page);
 
-		if (page_evictable(new_page, vma))
+		if (!mlocked_vma_newpage(vma, new_page))
 			lru_cache_add_lru(new_page, LRU_ACTIVE_ANON);
 		else
 			add_page_to_unevictable_list(new_page);
--- 3.6-rc6.orig/mm/rmap.c	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/rmap.c	2012-09-18 16:39:50.882992906 -0700
@@ -1128,7 +1128,7 @@ void page_add_new_anon_rmap(struct page
 	else
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__page_set_anon_rmap(page, vma, address, 1);
-	if (page_evictable(page, vma))
+	if (!mlocked_vma_newpage(vma, page))
 		lru_cache_add_lru(page, LRU_ACTIVE_ANON);
 	else
 		add_page_to_unevictable_list(page);
--- 3.6-rc6.orig/mm/swap.c	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/swap.c	2012-09-18 16:39:50.882992906 -0700
@@ -742,7 +742,7 @@ void lru_add_page_tail(struct page *page
 
 	SetPageLRU(page_tail);
 
-	if (page_evictable(page_tail, NULL)) {
+	if (page_evictable(page_tail)) {
 		if (PageActive(page)) {
 			SetPageActive(page_tail);
 			active = 1;
--- 3.6-rc6.orig/mm/vmscan.c	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/vmscan.c	2012-09-18 16:39:50.882992906 -0700
@@ -553,7 +553,7 @@ void putback_lru_page(struct page *page)
 redo:
 	ClearPageUnevictable(page);
 
-	if (page_evictable(page, NULL)) {
+	if (page_evictable(page)) {
 		/*
 		 * For evictable pages, we can use the cache.
 		 * In event of a race, worst case is we end up with an
@@ -587,7 +587,7 @@ redo:
 	 * page is on unevictable list, it never be freed. To avoid that,
 	 * check after we added it to the list, again.
 	 */
-	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
+	if (lru == LRU_UNEVICTABLE && page_evictable(page)) {
 		if (!isolate_lru_page(page)) {
 			put_page(page);
 			goto redo;
@@ -707,7 +707,7 @@ static unsigned long shrink_page_list(st
 
 		sc->nr_scanned++;
 
-		if (unlikely(!page_evictable(page, NULL)))
+		if (unlikely(!page_evictable(page)))
 			goto cull_mlocked;
 
 		if (!sc->may_unmap && page_mapped(page))
@@ -1186,7 +1186,7 @@ putback_inactive_pages(struct lruvec *lr
 
 		VM_BUG_ON(PageLRU(page));
 		list_del(&page->lru);
-		if (unlikely(!page_evictable(page, NULL))) {
+		if (unlikely(!page_evictable(page))) {
 			spin_unlock_irq(&zone->lru_lock);
 			putback_lru_page(page);
 			spin_lock_irq(&zone->lru_lock);
@@ -1439,7 +1439,7 @@ static void shrink_active_list(unsigned
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 
-		if (unlikely(!page_evictable(page, NULL))) {
+		if (unlikely(!page_evictable(page))) {
 			putback_lru_page(page);
 			continue;
 		}
@@ -3349,27 +3349,18 @@ int zone_reclaim(struct zone *zone, gfp_
 /*
  * page_evictable - test whether a page is evictable
  * @page: the page to test
- * @vma: the VMA in which the page is or will be mapped, may be NULL
  *
  * Test whether page is evictable--i.e., should be placed on active/inactive
- * lists vs unevictable list.  The vma argument is !NULL when called from the
- * fault path to determine how to instantate a new page.
+ * lists vs unevictable list.
  *
  * Reasons page might not be evictable:
  * (1) page's mapping marked unevictable
  * (2) page is part of an mlocked VMA
  *
  */
-int page_evictable(struct page *page, struct vm_area_struct *vma)
+int page_evictable(struct page *page)
 {
-
-	if (mapping_unevictable(page_mapping(page)))
-		return 0;
-
-	if (PageMlocked(page) || (vma && mlocked_vma_newpage(vma, page)))
-		return 0;
-
-	return 1;
+	return !mapping_unevictable(page_mapping(page)) && !PageMlocked(page);
 }
 
 #ifdef CONFIG_SHMEM
@@ -3407,7 +3398,7 @@ void check_move_unevictable_pages(struct
 		if (!PageLRU(page) || !PageUnevictable(page))
 			continue;
 
-		if (page_evictable(page, NULL)) {
+		if (page_evictable(page)) {
 			enum lru_list lru = page_lru_base_type(page);
 
 			VM_BUG_ON(PageActive(page));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
