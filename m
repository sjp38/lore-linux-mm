Message-Id: <20071113194025.150641834@polymtl.ca>
References: <20071113193349.214098508@polymtl.ca>
Date: Tue, 13 Nov 2007 14:33:54 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [RFC 5/7] LTTng instrumentation mm
Content-Disposition: inline; filename=lttng-instrumentation-mm.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Memory management core events.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: linux-mm@kvack.org
---
 mm/filemap.c    |    4 ++++
 mm/memory.c     |   34 +++++++++++++++++++++++++---------
 mm/page_alloc.c |    5 +++++
 mm/page_io.c    |    1 +
 4 files changed, 35 insertions(+), 9 deletions(-)

Index: linux-2.6-lttng/mm/filemap.c
===================================================================
--- linux-2.6-lttng.orig/mm/filemap.c	2007-11-13 09:25:26.000000000 -0500
+++ linux-2.6-lttng/mm/filemap.c	2007-11-13 09:49:35.000000000 -0500
@@ -514,9 +514,13 @@ void fastcall wait_on_page_bit(struct pa
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
 
+	trace_mark(mm_filemap_wait_start, "address %p", page_address(page));
+
 	if (test_bit(bit_nr, &page->flags))
 		__wait_on_bit(page_waitqueue(page), &wait, sync_page,
 							TASK_UNINTERRUPTIBLE);
+
+	trace_mark(mm_filemap_wait_end, "address %p", page_address(page));
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
Index: linux-2.6-lttng/mm/memory.c
===================================================================
--- linux-2.6-lttng.orig/mm/memory.c	2007-11-13 09:45:41.000000000 -0500
+++ linux-2.6-lttng/mm/memory.c	2007-11-13 09:49:35.000000000 -0500
@@ -2072,6 +2072,7 @@ static int do_swap_page(struct mm_struct
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry);
 	if (!page) {
+		trace_mark(mm_swap_in, "address #p%lu", address);
 		grab_swap_token(); /* Contend for token _before_ read-in */
  		swapin_readahead(entry, address, vma);
  		page = read_swap_cache_async(entry, vma, address);
@@ -2526,30 +2527,45 @@ unlock:
 int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, int write_access)
 {
+	int res;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
+	trace_mark(mm_handle_fault_entry, "address %lu ip #p%ld",
+		address, KSTK_EIP(current));
+
 	__set_current_state(TASK_RUNNING);
 
 	count_vm_event(PGFAULT);
 
-	if (unlikely(is_vm_hugetlb_page(vma)))
-		return hugetlb_fault(mm, vma, address, write_access);
+	if (unlikely(is_vm_hugetlb_page(vma))) {
+		res = hugetlb_fault(mm, vma, address, write_access);
+		goto end;
+	}
 
 	pgd = pgd_offset(mm, address);
 	pud = pud_alloc(mm, pgd, address);
-	if (!pud)
-		return VM_FAULT_OOM;
+	if (!pud) {
+		res = VM_FAULT_OOM;
+		goto end;
+	}
 	pmd = pmd_alloc(mm, pud, address);
-	if (!pmd)
-		return VM_FAULT_OOM;
+	if (!pmd) {
+		res = VM_FAULT_OOM;
+		goto end;
+	}
 	pte = pte_alloc_map(mm, pmd, address);
-	if (!pte)
-		return VM_FAULT_OOM;
+	if (!pte) {
+		res = VM_FAULT_OOM;
+		goto end;
+	}
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	res = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+end:
+	trace_mark(mm_handle_fault_exit, MARK_NOARGS);
+	return res;
 }
 
 #ifndef __PAGETABLE_PUD_FOLDED
Index: linux-2.6-lttng/mm/page_alloc.c
===================================================================
--- linux-2.6-lttng.orig/mm/page_alloc.c	2007-11-13 09:25:26.000000000 -0500
+++ linux-2.6-lttng/mm/page_alloc.c	2007-11-13 09:49:35.000000000 -0500
@@ -519,6 +519,9 @@ static void __free_pages_ok(struct page 
 	int i;
 	int reserved = 0;
 
+	trace_mark(mm_page_free, "order %u address %p",
+		order, page_address(page));
+
 	for (i = 0 ; i < (1 << order) ; ++i)
 		reserved += free_pages_check(page + i);
 	if (reserved)
@@ -1639,6 +1642,8 @@ fastcall unsigned long __get_free_pages(
 	page = alloc_pages(gfp_mask, order);
 	if (!page)
 		return 0;
+	trace_mark(mm_page_alloc, "order %u address %p",
+		order, page_address(page));
 	return (unsigned long) page_address(page);
 }
 
Index: linux-2.6-lttng/mm/page_io.c
===================================================================
--- linux-2.6-lttng.orig/mm/page_io.c	2007-11-13 09:25:26.000000000 -0500
+++ linux-2.6-lttng/mm/page_io.c	2007-11-13 09:49:35.000000000 -0500
@@ -114,6 +114,7 @@ int swap_writepage(struct page *page, st
 		rw |= (1 << BIO_RW_SYNC);
 	count_vm_event(PSWPOUT);
 	set_page_writeback(page);
+	trace_mark(mm_swap_out, "address %p", page_address(page));
 	unlock_page(page);
 	submit_bio(rw, bio);
 out:

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
