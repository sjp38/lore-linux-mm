Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.8/8.13.8) with ESMTP id m4TE1EIO172472
	for <linux-mm@kvack.org>; Thu, 29 May 2008 14:01:14 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4TE1DDP3158058
	for <linux-mm@kvack.org>; Thu, 29 May 2008 16:01:14 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4TE1DAa020903
	for <linux-mm@kvack.org>; Thu, 29 May 2008 16:01:13 +0200
Subject: [PATCH] Optimize page_remove_rmap for anon pages
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
Content-Type: text/plain
Date: Thu, 29 May 2008 15:56:32 +0200
Message-Id: <1212069392.16984.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Greetings,
with a recent performance analysis we discovered something interesting
in regard to the physical dirty bits found on s390. The page_remove_rmap
function stands out when areas of anonymous memory gets unmapped. The
reason is the transfer of the dirty bit from the page storage key to the
struct page when the last mapper of a page is removed. For anonymous
pages that cease to exist this is superfluous. Without the storage key
operations process termination is noticable faster, e.g. for a gcc test
case we got a speedup of 2%.
To get this done page_remove_rmap needs to know if the page dirty bit
can be ignored. The page_test_dirty / page_clear_dirty call can only be
avoided if page_remove_rmap is called from zap_pte_range or do_wp_page.
If it is called from any other place - in particular try_to_unmap_one -
the page dirty bit may not be ignored.
The patch below introduces a new function to do that, in lack of a
better name I called it page_zap_rmap. Comments ?

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.

--- 
Subject: [PATCH] Optimize page_remove_rmap for anon pages

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

For anonymous pages the check for the physical dirty bit in page_remove_rmap
is unnecessary if page_remove_rmap is called from zap_pte_range or do_wp_page.
The instruction that are used to check and reset the dirty bit are expensive.
Removing the check noticably speeds up process exit. The micro benchmark which
repeatedly executes an empty shell script gets about 4% faster.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 include/linux/rmap.h |    5 +++
 mm/memory.c          |    9 +++---
 mm/rmap.c            |   73 ++++++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 68 insertions(+), 19 deletions(-)

diff -urpN linux-2.6/include/linux/rmap.h linux-2.6-patched/include/linux/rmap.h
--- linux-2.6/include/linux/rmap.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6-patched/include/linux/rmap.h	2008-05-29 14:17:06.000000000 +0200
@@ -74,6 +74,11 @@ void page_add_anon_rmap(struct page *, s
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
 void page_remove_rmap(struct page *, struct vm_area_struct *);
+#ifdef __HAVE_ARCH_PAGE_TEST_DIRTY
+void page_zap_rmap(struct page *, struct vm_area_struct *);
+#else
+#define page_zap_rmap page_remove_rmap
+#endif
 
 #ifdef CONFIG_DEBUG_VM
 void page_dup_rmap(struct page *page, struct vm_area_struct *vma, unsigned long address);
diff -urpN linux-2.6/mm/memory.c linux-2.6-patched/mm/memory.c
--- linux-2.6/mm/memory.c	2008-05-29 14:16:48.000000000 +0200
+++ linux-2.6-patched/mm/memory.c	2008-05-29 14:17:06.000000000 +0200
@@ -731,16 +731,17 @@ static unsigned long zap_pte_range(struc
 						addr) != page->index)
 				set_pte_at(mm, addr, pte,
 					   pgoff_to_pte(page->index));
-			if (PageAnon(page))
+			if (PageAnon(page)) {
 				anon_rss--;
-			else {
+				page_zap_rmap(page, vma);
+			} else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent))
 					SetPageReferenced(page);
 				file_rss--;
+				page_remove_rmap(page, vma);
 			}
-			page_remove_rmap(page, vma);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
@@ -1757,7 +1758,7 @@ gotten:
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
-			page_remove_rmap(old_page, vma);
+			page_zap_rmap(old_page, vma);
 			if (!PageAnon(old_page)) {
 				dec_mm_counter(mm, file_rss);
 				inc_mm_counter(mm, anon_rss);
diff -urpN linux-2.6/mm/rmap.c linux-2.6-patched/mm/rmap.c
--- linux-2.6/mm/rmap.c	2008-05-29 14:16:48.000000000 +0200
+++ linux-2.6-patched/mm/rmap.c	2008-05-29 14:17:06.000000000 +0200
@@ -645,6 +645,33 @@ void page_dup_rmap(struct page *page, st
 #endif
 
 /**
+ * page_check_mapcount - check for negative number of page mappers
+ * @page: page to check mapping count
+ * @vma: the vm area in which the mapping is removed
+ */
+static void page_check_mapcount(struct page *page, struct vm_area_struct *vma)
+{
+	if (likely(page_mapcount(page) >= 0))
+		return;
+	printk (KERN_EMERG "Eeek! page_mapcount(page) went negative! (%d)\n",
+		page_mapcount(page));
+	printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
+	printk (KERN_EMERG "  page->flags = %lx\n", page->flags);
+	printk (KERN_EMERG "  page->count = %x\n", page_count(page));
+	printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
+	print_symbol (KERN_EMERG "  vma->vm_ops = %s\n",
+		      (unsigned long)vma->vm_ops);
+	if (vma->vm_ops) {
+		print_symbol (KERN_EMERG "  vma->vm_ops->fault = %s\n",
+			      (unsigned long)vma->vm_ops->fault);
+	}
+	if (vma->vm_file && vma->vm_file->f_op)
+		print_symbol (KERN_EMERG "  vma->vm_file->f_op->mmap = %s\n",
+			      (unsigned long)vma->vm_file->f_op->mmap);
+	BUG();
+}
+
+/**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
  * @vma: the vm area in which the mapping is removed
@@ -654,21 +681,7 @@ void page_dup_rmap(struct page *page, st
 void page_remove_rmap(struct page *page, struct vm_area_struct *vma)
 {
 	if (atomic_add_negative(-1, &page->_mapcount)) {
-		if (unlikely(page_mapcount(page) < 0)) {
-			printk (KERN_EMERG "Eeek! page_mapcount(page) went negative! (%d)\n", page_mapcount(page));
-			printk (KERN_EMERG "  page pfn = %lx\n", page_to_pfn(page));
-			printk (KERN_EMERG "  page->flags = %lx\n", page->flags);
-			printk (KERN_EMERG "  page->count = %x\n", page_count(page));
-			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
-			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
-			if (vma->vm_ops) {
-				print_symbol (KERN_EMERG "  vma->vm_ops->fault = %s\n", (unsigned long)vma->vm_ops->fault);
-			}
-			if (vma->vm_file && vma->vm_file->f_op)
-				print_symbol (KERN_EMERG "  vma->vm_file->f_op->mmap = %s\n", (unsigned long)vma->vm_file->f_op->mmap);
-			BUG();
-		}
-
+		page_check_mapcount(page, vma);
 		/*
 		 * It would be tidy to reset the PageAnon mapping here,
 		 * but that might overwrite a racing page_add_anon_rmap
@@ -689,6 +702,36 @@ void page_remove_rmap(struct page *page,
 	}
 }
 
+#ifdef __HAVE_ARCH_PAGE_TEST_DIRTY
+/**
+ * page_zap_rmap - take down pte mapping from a page without dirty bit check
+ * @page: page to remove mapping from
+ * @vma: the vm area in which the mapping is removed
+ *
+ * The caller needs to hold the pte lock. For s390 page_zap_rmap differs
+ * from page_remove_rmap, it will not check the physical page dirty bit.
+ */
+void page_zap_rmap(struct page *page, struct vm_area_struct *vma)
+{
+	if (atomic_add_negative(-1, &page->_mapcount)) {
+		page_check_mapcount(page, vma);
+		/*
+		 * It would be tidy to reset the PageAnon mapping here,
+		 * but that might overwrite a racing page_add_anon_rmap
+		 * which increments mapcount after us but sets mapping
+		 * before us: so leave the reset to free_hot_cold_page,
+		 * and remember that it's only reliable while mapped.
+		 * Leaving it set also helps swapoff to reinstate ptes
+		 * faster for those pages still in swapcache.
+		 */
+		mem_cgroup_uncharge_page(page);
+
+		__dec_zone_page_state(page,
+				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
+	}
+}
+#endif
+
 /*
  * Subfunctions of try_to_unmap: try_to_unmap_one called
  * repeatedly from either try_to_unmap_anon or try_to_unmap_file.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
