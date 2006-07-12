From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:42:29 +0200
Message-Id: <20060712144229.16998.32478.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 28/39] mm: clockpro: re-introduce page_referenced() ignore_token
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Re-introduce the ignore_token argument to page_referenced(); hand hot
rotation will make use of this feature.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_use_once_policy.h |    2 +-
 include/linux/rmap.h               |    4 ++--
 mm/rmap.c                          |   26 ++++++++++++++++----------
 mm/useonce.c                       |    2 +-
 4 files changed, 20 insertions(+), 14 deletions(-)

Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h	2006-07-12 16:07:30.000000000 +0200
+++ linux-2.6/include/linux/rmap.h	2006-07-12 16:09:19.000000000 +0200
@@ -90,7 +90,7 @@ static inline void page_dup_rmap(struct 
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked);
+int page_referenced(struct page *, int is_locked, int ignore_token);
 int try_to_unmap(struct page *, int ignore_refs);
 void remove_from_swap(struct page *page);
 
@@ -111,7 +111,7 @@ unsigned long page_address_in_vma(struct
 #define anon_vma_prepare(vma)	(0)
 #define anon_vma_link(vma)	do {} while (0)
 
-#define page_referenced(page,l) TestClearPageReferenced(page)
+#define page_referenced(page,l,i) TestClearPageReferenced(page)
 #define try_to_unmap(page, refs) SWAP_FAIL
 
 #endif	/* CONFIG_MMU */
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2006-07-12 16:07:32.000000000 +0200
+++ linux-2.6/mm/rmap.c	2006-07-12 16:09:19.000000000 +0200
@@ -328,7 +328,7 @@ pte_t *page_check_address(struct page *p
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
 static int page_referenced_one(struct page *page,
-	struct vm_area_struct *vma, unsigned int *mapcount)
+	struct vm_area_struct *vma, unsigned int *mapcount, int ignore_token)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -349,7 +349,7 @@ static int page_referenced_one(struct pa
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
-	if (mm != current->mm && has_swap_token(mm) &&
+	if (mm != current->mm && !ignore_token && has_swap_token(mm) &&
 			rwsem_is_locked(&mm->mmap_sem))
 		referenced++;
 
@@ -359,7 +359,7 @@ out:
 	return referenced;
 }
 
-static int page_referenced_anon(struct page *page)
+static int page_referenced_anon(struct page *page, int ignore_token)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -372,7 +372,8 @@ static int page_referenced_anon(struct p
 
 	mapcount = page_mapcount(page);
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		referenced += page_referenced_one(page, vma, &mapcount);
+		referenced += page_referenced_one(page, vma, &mapcount,
+							ignore_token);
 		if (!mapcount)
 			break;
 	}
@@ -391,7 +392,7 @@ static int page_referenced_anon(struct p
  *
  * This function is only called from page_referenced for object-based pages.
  */
-static int page_referenced_file(struct page *page)
+static int page_referenced_file(struct page *page, int ignore_token)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -429,7 +430,8 @@ static int page_referenced_file(struct p
 			referenced++;
 			break;
 		}
-		referenced += page_referenced_one(page, vma, &mapcount);
+		referenced += page_referenced_one(page, vma, &mapcount,
+							ignore_token);
 		if (!mapcount)
 			break;
 	}
@@ -446,10 +448,13 @@ static int page_referenced_file(struct p
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
  */
-int page_referenced(struct page *page, int is_locked)
+int page_referenced(struct page *page, int is_locked, int ignore_token)
 {
 	int referenced = 0;
 
+	if (!swap_token_default_timeout)
+		ignore_token = 1;
+
 	if (page_test_and_clear_young(page))
 		referenced++;
 
@@ -458,14 +463,15 @@ int page_referenced(struct page *page, i
 
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
-			referenced += page_referenced_anon(page);
+			referenced += page_referenced_anon(page, ignore_token);
 		else if (is_locked)
-			referenced += page_referenced_file(page);
+			referenced += page_referenced_file(page, ignore_token);
 		else if (TestSetPageLocked(page))
 			referenced++;
 		else {
 			if (page->mapping)
-				referenced += page_referenced_file(page);
+				referenced += page_referenced_file(page,
+								ignore_token);
 			unlock_page(page);
 		}
 	}
Index: linux-2.6/mm/useonce.c
===================================================================
--- linux-2.6.orig/mm/useonce.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/useonce.c	2006-07-12 16:11:20.000000000 +0200
@@ -189,7 +189,7 @@ static void shrink_active_list(unsigned 
 		if (page_mapped(page)) {
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0)) {
+			    page_referenced(page, 0, 0)) {
 				list_add(&page->lru, &l_active);
 				continue;
 			}
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:20.000000000 +0200
@@ -114,7 +114,7 @@ static inline reclaim_t pgrep_reclaimabl
 	if (PageActive(page))
 		BUG();
 
-	referenced = page_referenced(page, 1);
+	referenced = page_referenced(page, 1, 0);
 	/* In active use or really unfreeable?  Activate it. */
 	if (referenced && page_mapping_inuse(page))
 		return RECLAIM_ACTIVATE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
