Received: from localhost (riel@localhost)
	by duckman.conectiva (8.9.3/8.8.7) with ESMTP id XAA02018
	for <linux-mm@kvack.org>; Sun, 23 Apr 2000 23:38:53 -0300
Date: Sun, 23 Apr 2000 23:38:53 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: [patch] memory hog protection
Message-ID: <Pine.LNX.4.21.0004232255530.1852-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

the patch below changes the mm->swap_cnt assignment to put
memory hogs at a disadvantage to programs with a smaller
RSS. In combination with my other patch (that still needs
some tuning) it has the property that memory pressure on
a task is proportional to the task's size.

If process A is 4 times smaller than process B, it's
memory pages will receive half the memory pressure the
pages of process B will receive. Or, put another way,
we'll spend 8 times as much effort trying to swap out
part of B as we'll spend on swapping out part of A.

It more or less preserves interactive response of the
machine and performance of smaller programs. It doesn't
work well with the standard agressiveness of shrink_mmap(),
but it seems to be quite decent with my shrink_mmap()
modifications ... but those need some tuning to deal well
with some specific situations :)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux/linux-2.3.99-pre6-3/mm/vmscan.c.orig	Mon Apr 17 12:21:46 2000
+++ linux/linux-2.3.99-pre6-3/mm/vmscan.c	Sun Apr 23 16:49:16 2000
@@ -34,7 +34,7 @@
  * using a process that no longer actually exists (it might
  * have died while we slept).
  */
-static int try_to_swap_out(struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask)
+static int try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask)
 {
 	pte_t pte;
 	swp_entry_t entry;
@@ -48,6 +48,7 @@
 	if ((page-mem_map >= max_mapnr) || PageReserved(page))
 		goto out_failed;
 
+	mm->swap_cnt--;
 	/* Don't look at this pte if it's been accessed recently. */
 	if (pte_young(pte)) {
 		/*
@@ -194,7 +195,7 @@
  * (C) 1993 Kai Petzke, wpp@marie.physik.tu-berlin.de
  */
 
-static inline int swap_out_pmd(struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
@@ -216,16 +217,18 @@
 	do {
 		int result;
 		vma->vm_mm->swap_address = address + PAGE_SIZE;
-		result = try_to_swap_out(vma, address, pte, gfp_mask);
+		result = try_to_swap_out(mm, vma, address, pte, gfp_mask);
 		if (result)
 			return result;
+		if (!mm->swap_cnt)
+			return 0;
 		address += PAGE_SIZE;
 		pte++;
 	} while (address && (address < end));
 	return 0;
 }
 
-static inline int swap_out_pgd(struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
@@ -245,16 +248,18 @@
 		end = pgd_end;
 	
 	do {
-		int result = swap_out_pmd(vma, pmd, address, end, gfp_mask);
+		int result = swap_out_pmd(mm, vma, pmd, address, end, gfp_mask);
 		if (result)
 			return result;
+		if (!mm->swap_cnt)
+			return 0;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
 	return 0;
 }
 
-static int swap_out_vma(struct vm_area_struct * vma, unsigned long address, int gfp_mask)
+static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int gfp_mask)
 {
 	pgd_t *pgdir;
 	unsigned long end;
@@ -269,9 +274,11 @@
 	if (address >= end)
 		BUG();
 	do {
-		int result = swap_out_pgd(vma, pgdir, address, end, gfp_mask);
+		int result = swap_out_pgd(mm, vma, pgdir, address, end, gfp_mask);
 		if (result)
 			return result;
+		if (!mm->swap_cnt)
+			return 0;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	} while (address && (address < end));
@@ -299,7 +306,7 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			int result = swap_out_vma(vma, address, gfp_mask);
+			int result = swap_out_vma(mm, vma, address, gfp_mask);
 			if (result)
 				return result;
 			vma = vma->vm_next;
@@ -369,9 +376,23 @@
 				pid = p->pid;
 			}
 		}
-		read_unlock(&tasklist_lock);
-		if (assign == 1)
+		if (assign == 1) {
+			/* we just assigned swap_cnt, normalise values */
 			assign = 2;
+			p = init_task.next_task;
+			for (; p != &init_task; p = p->next_task) {
+				int i = 0;
+				struct mm_struct *mm = p->mm;
+				if (!p->swappable || !mm || mm->rss <= 0)
+					continue;
+				/* small processes are swapped out less */
+				while ((mm->swap_cnt << 2 * i) < max_cnt)
+					i++;
+				mm->swap_cnt >>= i;
+				mm->swap_cnt += i; /* in case we reach 0 */
+			}
+		}
+		read_unlock(&tasklist_lock);
 		if (!best) {
 			if (!assign) {
 				assign = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
