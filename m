Message-ID: <41C945C2.80701@yahoo.com.au>
Date: Wed, 22 Dec 2004 21:00:34 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 10/11] convert ia64 to generic nopud header
References: <41C94361.6070909@yahoo.com.au> <41C943F0.4090006@yahoo.com.au> <41C94427.9020601@yahoo.com.au> <41C94449.20004@yahoo.com.au> <41C94473.7050804@yahoo.com.au> <41C9449A.4020607@yahoo.com.au> <41C944CC.4040801@yahoo.com.au> <41C944F3.1060208@yahoo.com.au> <41C9456A.9040107@yahoo.com.au> <41C945A9.6050202@yahoo.com.au>
In-Reply-To: <41C945A9.6050202@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------080602080003000604070906"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080602080003000604070906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

10/11

--------------080602080003000604070906
Content-Type: text/plain;
 name="4level-ia64.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-ia64.patch"



Convert ia64 architecture over to handle 4 level pagetables.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/arch/ia64/mm/fault.c       |    7 ++++++-
 linux-2.6-npiggin/arch/ia64/mm/hugetlbpage.c |   20 ++++++++++++++------
 linux-2.6-npiggin/arch/ia64/mm/init.c        |   14 ++++++++++++--
 linux-2.6-npiggin/include/asm-ia64/pgalloc.h |    5 ++---
 linux-2.6-npiggin/include/asm-ia64/pgtable.h |   16 ++++++++--------
 linux-2.6-npiggin/include/asm-ia64/tlb.h     |    6 ++++++
 6 files changed, 48 insertions(+), 20 deletions(-)

diff -puN include/asm-ia64/pgtable.h~4level-ia64 include/asm-ia64/pgtable.h
--- linux-2.6/include/asm-ia64/pgtable.h~4level-ia64	2004-12-22 20:31:53.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ia64/pgtable.h	2004-12-22 20:32:20.000000000 +1100
@@ -1,8 +1,6 @@
 #ifndef _ASM_IA64_PGTABLE_H
 #define _ASM_IA64_PGTABLE_H
 
-#include <asm-generic/4level-fixup.h>
-
 /*
  * This file contains the functions and defines necessary to modify and use
  * the IA-64 page table tree.
@@ -256,11 +254,12 @@ ia64_phys_addr_valid (unsigned long addr
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
@@ -330,7 +329,7 @@ pgd_offset (struct mm_struct *mm, unsign
 
 /* Find an entry in the second-level page table.. */
 #define pmd_offset(dir,addr) \
-	((pmd_t *) pgd_page(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
+	((pmd_t *) pud_page(*(dir)) + (((addr) >> PMD_SHIFT) & (PTRS_PER_PMD - 1)))
 
 /*
  * Find an entry in the third-level page table.  This looks more complicated than it
@@ -563,5 +562,6 @@ do {											\
 #define __HAVE_ARCH_PTE_SAME
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 #include <asm-generic/pgtable.h>
+#include <asm-generic/pgtable-nopud.h>
 
 #endif /* _ASM_IA64_PGTABLE_H */
diff -puN arch/ia64/mm/fault.c~4level-ia64 arch/ia64/mm/fault.c
--- linux-2.6/arch/ia64/mm/fault.c~4level-ia64	2004-12-22 20:31:53.000000000 +1100
+++ linux-2.6-npiggin/arch/ia64/mm/fault.c	2004-12-22 20:32:06.000000000 +1100
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
--- linux-2.6/arch/ia64/mm/hugetlbpage.c~4level-ia64	2004-12-22 20:31:53.000000000 +1100
+++ linux-2.6-npiggin/arch/ia64/mm/hugetlbpage.c	2004-12-22 20:32:06.000000000 +1100
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
diff -puN arch/ia64/mm/init.c~4level-ia64 arch/ia64/mm/init.c
--- linux-2.6/arch/ia64/mm/init.c~4level-ia64	2004-12-22 20:31:53.000000000 +1100
+++ linux-2.6-npiggin/arch/ia64/mm/init.c	2004-12-22 20:32:06.000000000 +1100
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
--- linux-2.6/include/asm-ia64/pgalloc.h~4level-ia64	2004-12-22 20:31:53.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ia64/pgalloc.h	2004-12-22 20:32:06.000000000 +1100
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
--- linux-2.6/include/asm-ia64/tlb.h~4level-ia64	2004-12-22 20:31:53.000000000 +1100
+++ linux-2.6-npiggin/include/asm-ia64/tlb.h	2004-12-22 20:32:06.000000000 +1100
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

--------------080602080003000604070906--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
