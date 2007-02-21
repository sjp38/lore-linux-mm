Date: Wed, 21 Feb 2007 06:00:41 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: more rmap checking
Message-ID: <20070221050040.GA21997@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

We have seen a bug in SLES9 that only gets picked up with Andrea's extra
rmap checks that were removed from mainline.

Petr Tesarik has got a fix for the problem, which he is planning to send
upstream. The issue is a specific condition that causes an anon page to be
incorrectly inserted into the pagetables, outside a valid vma.

It would be nice to get some of these checks into mainline.

Nick

--

Re-introduce rmap verification patches that Hugh removed when he removed
PG_map_lock. PG_map_lock actually isn't needed to synchronise access to
anonymous pages, because PG_locked and PTL together already do.

These checks were important in discovering and fixing a rare rmap corruption
in SLES9.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -522,19 +522,49 @@ static void __page_set_anon_rmap(struct 
 }
 
 /**
+ * page_set_anon_rmap - sanity check anonymous rmap addition
+ * @page:	the page to add the mapping to
+ * @vma:	the vm area in which the mapping is added
+ * @address:	the user virtual address mapped
+ */
+static void __page_check_anon_rmap(struct page *page,
+	struct vm_area_struct *vma, unsigned long address)
+{
+	/*
+	 * The page's anon-rmap details (mapping and index) are guaranteed to
+	 * be set up correctly at this point.
+	 *
+	 * We have exclusion against page_add_anon_rmap because the caller
+	 * always holds the page locked, except if called from page_dup_rmap,
+	 * in which case the page is already known to be setup.
+	 *
+	 * We have exclusion against page_add_new_anon_rmap because those pages
+	 * are initially only visible via the pagetables, and the pte is locked
+	 * over the call to page_add_new_anon_rmap.
+	 */
+	struct anon_vma *anon_vma = vma->anon_vma;
+	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
+	BUG_ON(page->mapping != (struct address_space *)anon_vma);
+	BUG_ON(page->index != linear_page_index(vma, address));
+}
+
+/**
  * page_add_anon_rmap - add pte mapping to an anonymous page
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
  *
- * The caller needs to hold the pte lock.
+ * The caller needs to hold the pte lock and the page must be locked.
  */
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
+	BUG_ON(!PageLocked(page));
+	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	if (atomic_inc_and_test(&page->_mapcount))
 		__page_set_anon_rmap(page, vma, address);
-	/* else checking page index and mapping is racy */
+	else
+		__page_check_anon_rmap(page, vma, address);
 }
 
 /*
@@ -545,10 +575,12 @@ void page_add_anon_rmap(struct page *pag
  *
  * Same as page_add_anon_rmap but must only be called on *new* pages.
  * This means the inc-and-test can be bypassed.
+ * Page does not have to be locked.
  */
 void page_add_new_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
+	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	atomic_set(&page->_mapcount, 0); /* elevate count by 1 (starts at -1) */
 	__page_set_anon_rmap(page, vma, address);
 }
@@ -566,6 +598,24 @@ void page_add_file_rmap(struct page *pag
 }
 
 /**
+ * page_dup_rmap - duplicate pte mapping to a page
+ * @page:	the page to add the mapping to
+ *
+ * For copy_page_range only: minimal extract from page_add_file_rmap /
+ * page_add_anon_rmap, avoiding unnecessary tests (already checked) so it's
+ * quicker.
+ *
+ * The caller needs to hold the pte lock.
+ */
+void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address)
+{
+	BUG_ON(page_mapcount(page) == 0);
+	if (PageAnon(page))
+		__page_check_anon_rmap(page, vma, address);
+	atomic_inc(&page->_mapcount);
+}
+
+/**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
  *
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h
+++ linux-2.6/include/linux/rmap.h
@@ -72,20 +72,9 @@ void __anon_vma_link(struct vm_area_stru
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
+void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address);
 void page_remove_rmap(struct page *, struct vm_area_struct *);
 
-/**
- * page_dup_rmap - duplicate pte mapping to a page
- * @page:	the page to add the mapping to
- *
- * For copy_page_range only: minimal extract from page_add_rmap,
- * avoiding unnecessary tests (already checked) so it's quicker.
- */
-static inline void page_dup_rmap(struct page *page)
-{
-	atomic_inc(&page->_mapcount);
-}
-
 /*
  * Called from mm/vmscan.c to handle paging out
  */
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -481,7 +481,7 @@ copy_one_pte(struct mm_struct *dst_mm, s
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-		page_dup_rmap(page);
+		page_dup_rmap(page, vma, addr);
 		rss[!!PageAnon(page)]++;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
