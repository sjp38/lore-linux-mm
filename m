Message-ID: <41C3D4C8.1000508@yahoo.com.au>
Date: Sat, 18 Dec 2004 17:57:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 4/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au>
In-Reply-To: <41C3D4AE.7010502@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------010701000307020502060506"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010701000307020502060506
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/10

--------------010701000307020502060506
Content-Type: text/plain;
 name="3level-clear_page_range.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3level-clear_page_range.patch"



Rename clear_page_tables to clear_page_range. clear_page_range takes byte
ranges, and aggressively frees page table pages. Maybe useful to control
page table memory consumption on 4-level architectures (and even 3 level
ones).

Possible downsides are:
- flush_tlb_pgtables gets called more often (only a problem for sparc64
  AFAIKS).
  
- the opportunistic "expand to fill PGDIR_SIZE hole" logic that ensures
  something actually gets done under the old system is still in place.
  This could sometimes make unmapping small regions more inefficient. There
  are some other solutions to look at if this is the case though.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/include/linux/mm.h |    2 
 linux-2.6-npiggin/mm/memory.c        |   80 +++++++++++++++++++++--------------
 linux-2.6-npiggin/mm/mmap.c          |   23 +++-------
 3 files changed, 58 insertions(+), 47 deletions(-)

diff -puN include/linux/mm.h~3level-clear_page_range include/linux/mm.h
--- linux-2.6/include/linux/mm.h~3level-clear_page_range	2004-12-18 16:50:44.000000000 +1100
+++ linux-2.6-npiggin/include/linux/mm.h	2004-12-18 17:07:48.000000000 +1100
@@ -566,7 +566,7 @@ int unmap_vmas(struct mmu_gather **tlbp,
 		struct vm_area_struct *start_vma, unsigned long start_addr,
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
-void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int nr);
+void clear_page_range(struct mmu_gather *tlb, unsigned long addr, unsigned long end);
 int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 			struct vm_area_struct *vma);
 int zeromap_page_range(struct vm_area_struct *vma, unsigned long from,
diff -puN mm/memory.c~3level-clear_page_range mm/memory.c
--- linux-2.6/mm/memory.c~3level-clear_page_range	2004-12-18 16:50:44.000000000 +1100
+++ linux-2.6-npiggin/mm/memory.c	2004-12-18 17:07:48.000000000 +1100
@@ -100,58 +100,76 @@ static inline void copy_cow_page(struct 
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
  */
-static inline void free_one_pmd(struct mmu_gather *tlb, pmd_t * dir)
+static inline void clear_pmd_range(struct mmu_gather *tlb, pmd_t *pmd, unsigned long start, unsigned long end)
 {
 	struct page *page;
 
-	if (pmd_none(*dir))
+	if (pmd_none(*pmd))
 		return;
-	if (unlikely(pmd_bad(*dir))) {
-		pmd_ERROR(*dir);
-		pmd_clear(dir);
+	if (unlikely(pmd_bad(*pmd))) {
+		pmd_ERROR(*pmd);
+		pmd_clear(pmd);
 		return;
 	}
-	page = pmd_page(*dir);
-	pmd_clear(dir);
-	dec_page_state(nr_page_table_pages);
-	tlb->mm->nr_ptes--;
-	pte_free_tlb(tlb, page);
+	if (!(start & ~PMD_MASK) && !(end & ~PMD_MASK)) {
+		page = pmd_page(*pmd);
+		pmd_clear(pmd);
+		dec_page_state(nr_page_table_pages);
+		tlb->mm->nr_ptes--;
+		pte_free_tlb(tlb, page);
+	}
 }
 
-static inline void free_one_pgd(struct mmu_gather *tlb, pgd_t * dir)
+static inline void clear_pgd_range(struct mmu_gather *tlb, pgd_t *pgd, unsigned long start, unsigned long end)
 {
-	int j;
-	pmd_t * pmd;
+	unsigned long addr = start, next;
+	pmd_t *pmd, *__pmd;
 
-	if (pgd_none(*dir))
+	if (pgd_none(*pgd))
 		return;
-	if (unlikely(pgd_bad(*dir))) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
+	if (unlikely(pgd_bad(*pgd))) {
+		pgd_ERROR(*pgd);
+		pgd_clear(pgd);
 		return;
 	}
-	pmd = pmd_offset(dir, 0);
-	pgd_clear(dir);
-	for (j = 0; j < PTRS_PER_PMD ; j++)
-		free_one_pmd(tlb, pmd+j);
-	pmd_free_tlb(tlb, pmd);
+
+	pmd = __pmd = pmd_offset(pgd, start);
+	do {
+		next = (addr + PMD_SIZE) & PMD_MASK;
+		if (next > end || next <= addr)
+			next = end;
+		
+		clear_pmd_range(tlb, pmd, addr, next);
+		pmd++;
+		addr = next;
+	} while (addr && (addr <= end - 1));
+
+	if (!(start & ~PGDIR_MASK) && !(end & ~PGDIR_MASK)) {
+		pgd_clear(pgd);
+		pmd_free_tlb(tlb, __pmd);
+	}
 }
 
 /*
- * This function clears all user-level page tables of a process - this
- * is needed by execve(), so that old pages aren't in the way.
+ * This function clears user-level page tables of a process.
  *
  * Must be called with pagetable lock held.
  */
-void clear_page_tables(struct mmu_gather *tlb, unsigned long first, int nr)
+void clear_page_range(struct mmu_gather *tlb, unsigned long start, unsigned long end)
 {
-	pgd_t * page_dir = tlb->mm->pgd;
+	unsigned long addr = start, next;
+	unsigned long i, nr = pgd_index(end + PGDIR_SIZE-1) - pgd_index(start);
+	pgd_t * pgd = pgd_offset(tlb->mm, start);
 
-	page_dir += first;
-	do {
-		free_one_pgd(tlb, page_dir);
-		page_dir++;
-	} while (--nr);
+	for (i = 0; i < nr; i++) {
+		next = (addr + PGDIR_SIZE) & PGDIR_MASK;
+		if (next > end || next <= addr)
+			next = end;
+		
+		clear_pgd_range(tlb, pgd, addr, next);
+		pgd++;
+		addr = next;
+	}
 }
 
 pte_t fastcall * pte_alloc_map(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
diff -puN mm/mmap.c~3level-clear_page_range mm/mmap.c
--- linux-2.6/mm/mmap.c~3level-clear_page_range	2004-12-18 16:50:44.000000000 +1100
+++ linux-2.6-npiggin/mm/mmap.c	2004-12-18 16:50:44.000000000 +1100
@@ -1474,7 +1474,6 @@ static void free_pgtables(struct mmu_gat
 {
 	unsigned long first = start & PGDIR_MASK;
 	unsigned long last = end + PGDIR_SIZE - 1;
-	unsigned long start_index, end_index;
 	struct mm_struct *mm = tlb->mm;
 
 	if (!prev) {
@@ -1499,24 +1498,16 @@ static void free_pgtables(struct mmu_gat
 				last = next->vm_start;
 		}
 		if (prev->vm_end > first)
-			first = prev->vm_end + PGDIR_SIZE - 1;
+			first = prev->vm_end;
 		break;
 	}
 no_mmaps:
 	if (last < first)	/* for arches with discontiguous pgd indices */
 		return;
-	/*
-	 * If the PGD bits are not consecutive in the virtual address, the
-	 * old method of shifting the VA >> by PGDIR_SHIFT doesn't work.
-	 */
-	start_index = pgd_index(first);
-	if (start_index < FIRST_USER_PGD_NR)
-		start_index = FIRST_USER_PGD_NR;
-	end_index = pgd_index(last);
-	if (end_index > start_index) {
-		clear_page_tables(tlb, start_index, end_index - start_index);
-		flush_tlb_pgtables(mm, first & PGDIR_MASK, last & PGDIR_MASK);
-	}
+	if (first < FIRST_USER_PGD_NR * PGDIR_SIZE)
+		first = FIRST_USER_PGD_NR * PGDIR_SIZE;
+	clear_page_range(tlb, first, last);
+	flush_tlb_pgtables(mm, first, last);
 }
 
 /* Normal function to fix up a mapping
@@ -1844,7 +1835,9 @@ void exit_mmap(struct mm_struct *mm)
 					~0UL, &nr_accounted, NULL);
 	vm_unacct_memory(nr_accounted);
 	BUG_ON(mm->map_count);	/* This is just debugging */
-	clear_page_tables(tlb, FIRST_USER_PGD_NR, USER_PTRS_PER_PGD);
+	clear_page_range(tlb, FIRST_USER_PGD_NR * PGDIR_SIZE,
+			(TASK_SIZE + PGDIR_SIZE - 1) & PGDIR_MASK);
+	
 	tlb_finish_mmu(tlb, 0, MM_VM_SIZE(mm));
 
 	vma = mm->mmap;

_

--------------010701000307020502060506--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
