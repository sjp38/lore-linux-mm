Message-ID: <4181EF54.6080308@yahoo.com.au>
Date: Fri, 29 Oct 2004 17:20:52 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 1/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au>
In-Reply-To: <4181EF2D.5000407@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------020009030903030505030304"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020009030903030505030304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

1/7

--------------020009030903030505030304
Content-Type: text/x-patch;
 name="vm-free-pgtables-late.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-free-pgtables-late.patch"



Moves page table destruction to after vma destruction. This
makes pinning a vma pin the page tables, which is needed to make
rmap.c safe without the page table lock.


---

 linux-2.6-npiggin/mm/mmap.c |   49 ++++++++++++++++++++++++++++++++++----------
 1 files changed, 38 insertions(+), 11 deletions(-)

diff -puN mm/mmap.c~vm-free-pgtables-late mm/mmap.c
--- linux-2.6/mm/mmap.c~vm-free-pgtables-late	2004-10-23 19:40:06.000000000 +1000
+++ linux-2.6-npiggin/mm/mmap.c	2004-10-23 19:40:16.000000000 +1000
@@ -1559,7 +1559,6 @@ static void unmap_vma_list(struct mm_str
  */
 static void unmap_region(struct mm_struct *mm,
 	struct vm_area_struct *vma,
-	struct vm_area_struct *prev,
 	unsigned long start,
 	unsigned long end)
 {
@@ -1567,15 +1566,31 @@ static void unmap_region(struct mm_struc
 	unsigned long nr_accounted = 0;
 
 	lru_add_drain();
+
+	spin_lock(&mm->page_table_lock);
 	tlb = tlb_gather_mmu(mm, 0);
 	unmap_vmas(&tlb, mm, vma, start, end, &nr_accounted, NULL);
+	tlb_finish_mmu(tlb, start, end);
+	spin_unlock(&mm->page_table_lock);
+
 	vm_unacct_memory(nr_accounted);
+}
 
+static void free_dangling_pgtables_region(struct mm_struct *mm,
+	struct vm_area_struct *prev,
+	unsigned long start,
+	unsigned long end)
+{
+	struct mmu_gather *tlb;
+
+	spin_lock(&mm->page_table_lock);
+	tlb = tlb_gather_mmu(mm, 0);
 	if (is_hugepage_only_range(start, end - start))
 		hugetlb_free_pgtables(tlb, prev, start, end);
 	else
 		free_pgtables(tlb, prev, start, end);
 	tlb_finish_mmu(tlb, start, end);
+	spin_unlock(&mm->page_table_lock);
 }
 
 /*
@@ -1709,13 +1724,18 @@ int do_munmap(struct mm_struct *mm, unsi
 	 * Remove the vma's, and unmap the actual pages
 	 */
 	detach_vmas_to_be_unmapped(mm, mpnt, prev, end);
-	spin_lock(&mm->page_table_lock);
-	unmap_region(mm, mpnt, prev, start, end);
-	spin_unlock(&mm->page_table_lock);
+
+	unmap_region(mm, mpnt, start, end);
 
 	/* Fix up all other VM information */
 	unmap_vma_list(mm, mpnt);
 
+	/*
+	 * Free the page tables. Nothing will reference them at this
+	 * point.
+	 */
+	free_dangling_pgtables_region(mm, prev, start, end);
+
 	return 0;
 }
 
@@ -1833,16 +1853,16 @@ void exit_mmap(struct mm_struct *mm)
 	lru_add_drain();
 
 	spin_lock(&mm->page_table_lock);
-
 	tlb = tlb_gather_mmu(mm, 1);
 	flush_cache_mm(mm);
 	/* Use ~0UL here to ensure all VMAs in the mm are unmapped */
 	mm->map_count -= unmap_vmas(&tlb, mm, mm->mmap, 0,
 					~0UL, &nr_accounted, NULL);
+	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
+	spin_unlock(&mm->page_table_lock);
+
 	vm_unacct_memory(nr_accounted);
 	BUG_ON(mm->map_count);	/* This is just debugging */
-	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
-	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
 
 	vma = mm->mmap;
 	mm->mmap = mm->mmap_cache = NULL;
@@ -1851,17 +1871,24 @@ void exit_mmap(struct mm_struct *mm)
 	mm->total_vm = 0;
 	mm->locked_vm = 0;
 
-	spin_unlock(&mm->page_table_lock);
-
 	/*
-	 * Walk the list again, actually closing and freeing it
-	 * without holding any MM locks.
+	 * Walk the list again, actually closing and freeing it.
 	 */
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
 		remove_vm_struct(vma);
 		vma = next;
 	}
+
+	/*
+	 * Finally, free the pagetables. By this point, nothing should
+	 * refer to them.
+	 */
+	spin_lock(&mm->page_table_lock);
+	tlb = tlb_gather_mmu(mm, 1);
+	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
+	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
+	spin_unlock(&mm->page_table_lock);
 }
 
 /* Insert vm structure into process list sorted by address

_

--------------020009030903030505030304--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
