Received: from saturn.homenet([192.168.225.73]) (5624 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <tigran@veritas.com>)
	id <m13Odpt-0000KPC@megami.veritas.com>
	for <linux-mm@kvack.org>; Tue, 15 Aug 2000 03:20:45 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #4 built 1999-Aug-24)
Date: Tue, 15 Aug 2000 11:27:45 +0100 (BST)
From: Tigran Aivazian <tigran@veritas.com>
Subject: [patch-2.4.0-test6] swapout code optimized (fwd)
Message-ID: <Pine.LNX.4.21.0008151125360.1075-100000@saturn.homenet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

I guess I should have asked you this before - is there something wrong
with my patch below? I removed the 'mm' argument as redundant from all the
mm/vmscan.c:*swap_out* functions. It is visible through vma->vm_mm.

I sent this to Linus last Friday but it didn't make it into any test7-pre*

Regards,
Tigran

---------- Forwarded message ----------
Date: Fri, 11 Aug 2000 13:29:02 +0100 (BST)
From: Tigran Aivazian <tigran@veritas.com>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu
Subject: [patch-2.4.0-test6] swapout code optimized

Hi Linus,

All of the mm/vmscan.c:*swap_out* functions accept 'mm_struct *mm' as an
argument but it is visible internally as vma->vm_mm. So I removed it from
all of them and tested the patch under 2.4.0-test6 (yes, I did cause lots
of things to swapout just in case).

Regards,
Tigran

--- linux/mm/vmscan.c	Thu Aug 10 06:51:12 2000
+++ vmscan/mm/vmscan.c	Fri Aug 11 13:20:00 2000
@@ -34,11 +34,13 @@
  * using a process that no longer actually exists (it might
  * have died while we slept).
  */
-static int try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask)
+static int try_to_swap_out(struct vm_area_struct * vma, unsigned long address,
+	pte_t * page_table, int gfp_mask)
 {
 	pte_t pte;
 	swp_entry_t entry;
 	struct page * page;
+	struct mm_struct * mm = vma->vm_mm;
 	int (*swapout)(struct page *, struct file *);
 
 	pte = *page_table;
@@ -79,7 +81,7 @@
 		set_pte(page_table, swp_entry_to_pte(entry));
 drop_pte:
 		UnlockPage(page);
-		vma->vm_mm->rss--;
+		mm->rss--;
 		flush_tlb_page(vma, address);
 		page_cache_release(page);
 		goto out_failed;
@@ -144,9 +146,9 @@
 		struct file *file = vma->vm_file;
 		if (file) get_file(file);
 		pte_clear(page_table);
-		vma->vm_mm->rss--;
+		mm->rss--;
 		flush_tlb_page(vma, address);
-		vmlist_access_unlock(vma->vm_mm);
+		vmlist_access_unlock(mm);
 		error = swapout(page, file);
 		UnlockPage(page);
 		if (file) fput(file);
@@ -175,10 +177,10 @@
 	add_to_swap_cache(page, entry);
 
 	/* Put the swap entry into the pte after the page is in swapcache */
-	vma->vm_mm->rss--;
+	mm->rss--;
 	set_pte(page_table, swp_entry_to_pte(entry));
 	flush_tlb_page(vma, address);
-	vmlist_access_unlock(vma->vm_mm);
+	vmlist_access_unlock(mm);
 
 	/* OK, do a physical asynchronous write to swap.  */
 	rw_swap_page(WRITE, page, 0);
@@ -209,10 +211,11 @@
  * (C) 1993 Kai Petzke, wpp@marie.physik.tu-berlin.de
  */
 
-static inline int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pmd(struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
+	struct mm_struct * mm = vma->vm_mm;
 
 	if (pmd_none(*dir))
 		return 0;
@@ -230,8 +233,8 @@
 
 	do {
 		int result;
-		vma->vm_mm->swap_address = address + PAGE_SIZE;
-		result = try_to_swap_out(mm, vma, address, pte, gfp_mask);
+		mm->swap_address = address + PAGE_SIZE;
+		result = try_to_swap_out(vma, address, pte, gfp_mask);
 		if (result)
 			return result;
 		if (!mm->swap_cnt)
@@ -242,10 +245,11 @@
 	return 0;
 }
 
-static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pgd(struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
+	struct mm_struct * mm = vma->vm_mm;
 
 	if (pgd_none(*dir))
 		return 0;
@@ -262,7 +266,7 @@
 		end = pgd_end;
 	
 	do {
-		int result = swap_out_pmd(mm, vma, pmd, address, end, gfp_mask);
+		int result = swap_out_pmd(vma, pmd, address, end, gfp_mask);
 		if (result)
 			return result;
 		if (!mm->swap_cnt)
@@ -273,22 +277,23 @@
 	return 0;
 }
 
-static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int gfp_mask)
+static int swap_out_vma(struct vm_area_struct * vma, unsigned long address, int gfp_mask)
 {
 	pgd_t *pgdir;
 	unsigned long end;
+	struct mm_struct * mm = vma->vm_mm;
 
 	/* Don't swap out areas which are locked down */
 	if (vma->vm_flags & VM_LOCKED)
 		return 0;
 
-	pgdir = pgd_offset(vma->vm_mm, address);
+	pgdir = pgd_offset(mm, address);
 
 	end = vma->vm_end;
 	if (address >= end)
 		BUG();
 	do {
-		int result = swap_out_pgd(mm, vma, pgdir, address, end, gfp_mask);
+		int result = swap_out_pgd(vma, pgdir, address, end, gfp_mask);
 		if (result)
 			return result;
 		if (!mm->swap_cnt)
@@ -320,7 +325,7 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			int result = swap_out_vma(mm, vma, address, gfp_mask);
+			int result = swap_out_vma(vma, address, gfp_mask);
 			if (result)
 				return result;
 			vma = vma->vm_next;


-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.rutgers.edu
Please read the FAQ at http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
