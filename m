Message-ID: <445B2EBD.4020803@bull.net>
Date: Fri, 05 May 2006 12:53:49 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
MIME-Version: 1.0
Subject: Any reason for passing "tlb" to "free_pgtables()" by address?
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

Apparently, there is no reason for passing "tlb" to "free_pgtables()"
by address, because there is no need for re-scheduling inside this
function => no other "mmu_gather" can / will be used.

Thanks,

Zoltan

--- linux-2.6.16.9-save/include/linux/mm.h	2006-04-19 08:10:14.000000000 +0200
+++ linux-2.6.16.9/include/linux/mm.h	2006-05-05 11:33:56.000000000 +0200
@@ -700,9 +700,9 @@
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
-void free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
+void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *start_vma,
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
--- linux-2.6.16.9-save/mm/mmap.c	2006-04-19 08:10:14.000000000 +0200
+++ linux-2.6.16.9/mm/mmap.c	2006-05-05 11:31:51.000000000 +0200
@@ -1661,7 +1661,7 @@
 	update_hiwater_rss(mm);
 	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
+	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
 				 next? next->vm_start: 0);
 	tlb_finish_mmu(tlb, start, end);
 }
@@ -1944,7 +1944,7 @@
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
+	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
 	tlb_finish_mmu(tlb, 0, end);
 
 	/*
--- linux-2.6.16.9-save/mm/memory.c	2006-04-19 08:10:14.000000000 +0200
+++ linux-2.6.16.9/mm/memory.c	2006-05-05 11:30:27.000000000 +0200
@@ -201,7 +201,7 @@
  *
  * Must be called with pagetable lock held.
  */
-void free_pgd_range(struct mmu_gather **tlb,
+void free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
 {
@@ -252,19 +252,19 @@
 		return;
 
 	start = addr;
-	pgd = pgd_offset((*tlb)->mm, addr);
+	pgd = pgd_offset(tlb->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		free_pud_range(*tlb, pgd, addr, next, floor, ceiling);
+		free_pud_range(tlb, pgd, addr, next, floor, ceiling);
 	} while (pgd++, addr = next, addr != end);
 
-	if (!(*tlb)->fullmm)
-		flush_tlb_pgtables((*tlb)->mm, start, end);
+	if (!tlb->fullmm)
+		flush_tlb_pgtables(tlb->mm, start, end);
 }
 
-void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
+void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
 	while (vma) {
--- linux-2.6.16.9-save/include/asm-ia64/pgtable.h	2006-04-21 09:59:12.000000000 +0200
+++ linux-2.6.16.9/include/asm-ia64/pgtable.h	2006-05-05 11:49:21.000000000 +0200
@@ -506,7 +506,7 @@
 #define HUGETLB_PGDIR_SIZE	(__IA64_UL(1) << HUGETLB_PGDIR_SHIFT)
 #define HUGETLB_PGDIR_MASK	(~(HUGETLB_PGDIR_SIZE-1))
 struct mmu_gather;
-void hugetlb_free_pgd_range(struct mmu_gather **tlb, unsigned long addr,
+void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
 #endif
 
--- linux-2.6.16.9-save/arch/ia64/mm/hugetlbpage.c	2006-04-21 09:58:55.000000000 +0200
+++ linux-2.6.16.9/arch/ia64/mm/hugetlbpage.c	2006-05-05 11:48:46.000000000 +0200
@@ -107,7 +107,7 @@
 	return NULL;
 }
 
-void hugetlb_free_pgd_range(struct mmu_gather **tlb,
+void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
 			unsigned long floor, unsigned long ceiling)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
