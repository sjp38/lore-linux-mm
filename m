Message-ID: <41C3D57C.5020005@yahoo.com.au>
Date: Sat, 18 Dec 2004 18:00:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 8/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au> <41C3D548.6080209@yahoo.com.au>
In-Reply-To: <41C3D548.6080209@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------030809010400030706060306"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030809010400030706060306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

8/10

--------------030809010400030706060306
Content-Type: text/plain;
 name="4level-ia64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-ia64.patch"



Convert ia64 architecture over to handle 4 level pagetables.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/arch/ia64/mm/fault.c       |    7 ++++-
 linux-2.6-npiggin/arch/ia64/mm/hugetlbpage.c |   35 ++++++++++++---------------
 linux-2.6-npiggin/arch/ia64/mm/init.c        |   14 +++++++++-
 linux-2.6-npiggin/include/asm-ia64/pgalloc.h |    5 +--
 linux-2.6-npiggin/include/asm-ia64/pgtable.h |   14 ++++++----
 linux-2.6-npiggin/include/asm-ia64/tlb.h     |    6 ++++
 6 files changed, 50 insertions(+), 31 deletions(-)

diff -puN include/asm-ia64/pgtable.h~4level-ia64 include/asm-ia64/pgtable.h
--- linux-2.6/include/asm-ia64/pgtable.h~4level-ia64	2004-12-18 17:03:12.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ia64/pgtable.h	2004-12-18 17:03:12.000000000 +1100
@@ -254,11 +254,12 @@ ia64_phys_addr_valid (unsigned long addr
 #define pmd_page_kernel(pmd)		((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
 #define pmd_page(pmd)			virt_to_page((pmd_val(pmd) + PAGE_OFFSET))
 
-#define pgd_none(pgd)			(!pgd_val(pgd))
-#define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
-#define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
-#define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
-#define pgd_page(pgd)			((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
+#define pud_none(pud)			(!pud_val(pud))
+#define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
+#define pud_present(pud)		(pud_val(pud) != 0UL)
+#define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
+
+#define pud_page(pud)			((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 
 /*
  * The following have defined behavior only work if pte_present() is true.
@@ -328,7 +329,7 @@ pgd_offset (struct mm_struct *mm, unsign
 
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir,addr) \
-	((pmd_t *) pgd_page(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
+	((pmd_t *) pud_page(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
 
 /*
  * Find an entry in the third-level page table.  This looks more complicated than it
@@ -561,5 +562,6 @@ do {											\
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #include <asm-generic/pgtable.h>
+#include <asm-generic/pgtable-nopud.h>
 
 #endif /* _ASM_IA64_PGTABLE_H */
diff -puN arch/ia64/mm/fault.c~4level-ia64 arch/ia64/mm/fault.c
--- linux-2.6/arch/ia64/mm/fault.c~4level-ia64	2004-12-18 17:03:12.000000000 +1100
+++ linux-2.6-npiggin/arch/ia64/mm/fault.c	2004-12-18 17:03:12.000000000 +1100
@@ -51,6 +51,7 @@ static int
 mapped_kernel_page_is_present (unsigned long address)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *ptep, pte;
 
@@ -58,7 +59,11 @@ mapped_kernel_page_is_present (unsigned 
 	if (pgd_none(*pgd) || pgd_bad(*pgd))
 		return 0;
 
-	pmd = pmd_offset(pgd, address);
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud) || pud_bad(*pud))
+		return 0;
+
+	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd) || pmd_bad(*pmd))
 		return 0;
 
diff -puN arch/ia64/mm/hugetlbpage.c~4level-ia64 arch/ia64/mm/hugetlbpage.c
--- linux-2.6/arch/ia64/mm/hugetlbpage.c~4level-ia64	2004-12-18 17:03:12.000000000 +1100
+++ linux-2.6-npiggin/arch/ia64/mm/hugetlbpage.c	2004-12-18 17:03:12.000000000 +1100
@@ -29,13 +29,17 @@ huge_pte_alloc (struct mm_struct *mm, un
 {
 	unsigned long taddr = htlbpage_to_page(addr);
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, taddr);
-	pmd = pmd_alloc(mm, pgd, taddr);
-	if (pmd)
-		pte = pte_alloc_map(mm, pmd, taddr);
+	pud = pud_alloc(mm, pgd, taddr);
+	if (pud) {
+		pmd = pmd_alloc(mm, pud, taddr);
+		if (pmd)
+			pte = pte_alloc_map(mm, pmd, taddr);
+	}
 	return pte;
 }
 
@@ -44,14 +48,18 @@ huge_pte_offset (struct mm_struct *mm, u
 {
 	unsigned long taddr = htlbpage_to_page(addr);
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, taddr);
 	if (pgd_present(*pgd)) {
-		pmd = pmd_offset(pgd, taddr);
-		if (pmd_present(*pmd))
-			pte = pte_offset_map(pmd, taddr);
+		pud = pud_offset(pgd, taddr);
+		if (pud_present(*pud)) {
+			pmd = pmd_offset(pud, taddr);
+			if (pmd_present(*pmd))
+				pte = pte_offset_map(pmd, taddr);
+		}
 	}
 
 	return pte;
@@ -187,7 +195,6 @@ void hugetlb_free_pgtables(struct mmu_ga
 {
 	unsigned long first = start & HUGETLB_PGDIR_MASK;
 	unsigned long last = end + HUGETLB_PGDIR_SIZE - 1;
-	unsigned long start_index, end_index;
 	struct mm_struct *mm = tlb->mm;
 
 	if (!prev) {
@@ -212,23 +219,13 @@ void hugetlb_free_pgtables(struct mmu_ga
 				last = next->vm_start;
 		}
 		if (prev->vm_end > first)
-			first = prev->vm_end + HUGETLB_PGDIR_SIZE - 1;
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
-
-	start_index = pgd_index(htlbpage_to_page(first));
-	end_index = pgd_index(htlbpage_to_page(last));
-
-	if (end_index > start_index) {
-		clear_page_tables(tlb, start_index, end_index - start_index);
-	}
+	clear_page_range(tlb, first, last);
 }
 
 void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
diff -puN arch/ia64/mm/init.c~4level-ia64 arch/ia64/mm/init.c
--- linux-2.6/arch/ia64/mm/init.c~4level-ia64	2004-12-18 17:03:12.000000000 +1100
+++ linux-2.6-npiggin/arch/ia64/mm/init.c	2004-12-18 17:03:12.000000000 +1100
@@ -237,6 +237,7 @@ struct page *
 put_kernel_page (struct page *page, unsigned long address, pgprot_t pgprot)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
@@ -248,7 +249,11 @@ put_kernel_page (struct page *page, unsi
 
 	spin_lock(&init_mm.page_table_lock);
 	{
-		pmd = pmd_alloc(&init_mm, pgd, address);
+		pud = pud_alloc(&init_mm, pgd, address);
+		if (!pud)
+			goto out;
+
+		pmd = pmd_alloc(&init_mm, pud, address);
 		if (!pmd)
 			goto out;
 		pte = pte_alloc_map(&init_mm, pmd, address);
@@ -381,6 +386,7 @@ create_mem_map_page_table (u64 start, u6
 	struct page *map_start, *map_end;
 	int node;
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
@@ -395,7 +401,11 @@ create_mem_map_page_table (u64 start, u6
 		pgd = pgd_offset_k(address);
 		if (pgd_none(*pgd))
 			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pmd = pmd_offset(pgd, address);
+		pud = pud_offset(pgd, address);
+
+		if (pud_none(*pud))
+			pud_populate(&init_mm, pud, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
+		pmd = pmd_offset(pud, address);
 
 		if (pmd_none(*pmd))
 			pmd_populate_kernel(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
diff -puN include/asm-ia64/pgalloc.h~4level-ia64 include/asm-ia64/pgalloc.h
--- linux-2.6/include/asm-ia64/pgalloc.h~4level-ia64	2004-12-18 17:03:12.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ia64/pgalloc.h	2004-12-18 17:03:12.000000000 +1100
@@ -79,12 +79,11 @@ pgd_free (pgd_t *pgd)
 }
 
 static inline void
-pgd_populate (struct mm_struct *mm, pgd_t *pgd_entry, pmd_t *pmd)
+pud_populate (struct mm_struct *mm, pud_t *pud_entry, pmd_t *pmd)
 {
-	pgd_val(*pgd_entry) = __pa(pmd);
+	pud_val(*pud_entry) = __pa(pmd);
 }
 
-
 static inline pmd_t*
 pmd_alloc_one_fast (struct mm_struct *mm, unsigned long addr)
 {
diff -puN include/asm-ia64/tlb.h~4level-ia64 include/asm-ia64/tlb.h
--- linux-2.6/include/asm-ia64/tlb.h~4level-ia64	2004-12-18 17:03:12.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ia64/tlb.h	2004-12-18 17:03:12.000000000 +1100
@@ -236,4 +236,10 @@ do {							\
 	__pmd_free_tlb(tlb, ptep);			\
 } while (0)
 
+#define pud_free_tlb(tlb, pudp)				\
+do {							\
+	tlb->need_flush = 1;				\
+	__pud_free_tlb(tlb, pudp);			\
+} while (0)
+
 #endif /* _ASM_IA64_TLB_H */

_

--------------030809010400030706060306--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
