Message-ID: <4196F199.3030708@yahoo.com.au>
Date: Sun, 14 Nov 2004 16:48:09 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Possible alternate 4 level pagetables?
References: <4196F12D.20005@yahoo.com.au> <4196F151.50805@yahoo.com.au> <4196F16E.4060107@yahoo.com.au>
In-Reply-To: <4196F16E.4060107@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090601030403010401010600"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090601030403010401010600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/4 - 4level arch changes for i386

--------------090601030403010401010600
Content-Type: text/x-patch;
 name="4level-architecture-changes-for-i386.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-architecture-changes-for-i386.patch"



i386		works with 2 and 3 levels

Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---



---

 linux-2.6-npiggin/arch/i386/kernel/acpi/sleep.c |    3 ++-
 linux-2.6-npiggin/arch/i386/kernel/vm86.c       |   11 ++++++++++-
 linux-2.6-npiggin/arch/i386/mm/fault.c          |   13 ++++++++++---
 linux-2.6-npiggin/arch/i386/mm/hugetlbpage.c    |    8 ++++++--
 linux-2.6-npiggin/arch/i386/mm/init.c           |    2 +-
 linux-2.6-npiggin/arch/i386/mm/ioremap.c        |    7 ++++++-
 linux-2.6-npiggin/arch/i386/mm/pageattr.c       |   10 +++++++---
 linux-2.6-npiggin/include/asm-i386/pgalloc.h    |    1 -
 linux-2.6-npiggin/include/asm-i386/pgtable.h    |    1 +
 9 files changed, 43 insertions(+), 13 deletions(-)

diff -puN arch/i386/kernel/acpi/sleep.c~4level-architecture-changes-for-i386 arch/i386/kernel/acpi/sleep.c
--- linux-2.6/arch/i386/kernel/acpi/sleep.c~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/kernel/acpi/sleep.c	2004-11-14 12:33:58.000000000 +1100
@@ -7,6 +7,7 @@
 
 #include <linux/acpi.h>
 #include <linux/bootmem.h>
+#include <asm/current.h> /* XXX remove me */
 #include <asm/smp.h>
 
 
@@ -24,7 +25,7 @@ static void init_low_mapping(pgd_t *pgd,
 	int pgd_ofs = 0;
 
 	while ((pgd_ofs < pgd_limit) && (pgd_ofs + USER_PTRS_PER_PGD < PTRS_PER_PGD)) {
-		set_pgd(pgd, *(pgd+USER_PTRS_PER_PGD));
+		set_pgd(pgd, (*(pgd+USER_PTRS_PER_PGD)));
 		pgd_ofs++, pgd++;
 	}
 }
diff -puN arch/i386/kernel/vm86.c~4level-architecture-changes-for-i386 arch/i386/kernel/vm86.c
--- linux-2.6/arch/i386/kernel/vm86.c~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/kernel/vm86.c	2004-11-14 12:33:58.000000000 +1100
@@ -137,6 +137,7 @@ struct pt_regs * fastcall save_v86_state
 static void mark_screen_rdonly(struct task_struct * tsk)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte, *mapped;
 	int i;
@@ -151,7 +152,15 @@ static void mark_screen_rdonly(struct ta
 		pgd_clear(pgd);
 		goto out;
 	}
-	pmd = pmd_offset(pgd, 0xA0000);
+	pud = pud_offset(pgd, 0xA0000);
+	if (pud_none(*pud))
+		goto out;
+	if (pud_bad(*pud)) {
+		pud_ERROR(*pud);
+		pud_clear(pud);
+		goto out;
+	}
+	pmd = pmd_offset(pud, 0xA0000);
 	if (pmd_none(*pmd))
 		goto out;
 	if (pmd_bad(*pmd)) {
diff -puN arch/i386/mm/fault.c~4level-architecture-changes-for-i386 arch/i386/mm/fault.c
--- linux-2.6/arch/i386/mm/fault.c~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/fault.c	2004-11-14 12:33:58.000000000 +1100
@@ -518,6 +518,7 @@ vmalloc_fault:
 		int index = pgd_index(address);
 		unsigned long pgd_paddr;
 		pgd_t *pgd, *pgd_k;
+		pud_t *pud, *pud_k;
 		pmd_t *pmd, *pmd_k;
 		pte_t *pte_k;
 
@@ -530,11 +531,17 @@ vmalloc_fault:
 
 		/*
 		 * set_pgd(pgd, *pgd_k); here would be useless on PAE
-		 * and redundant with the set_pmd() on non-PAE.
+		 * and redundant with the set_pmd() on non-PAE. As would
+		 * set_pud.
 		 */
 
-		pmd = pmd_offset(pgd, address);
-		pmd_k = pmd_offset(pgd_k, address);
+		pud = pud_offset(pgd, address);
+		pud_k = pud_offset(pgd_k, address);
+		if (!pud_present(*pud_k))
+			goto no_context;
+		
+		pmd = pmd_offset(pud, address);
+		pmd_k = pmd_offset(pud_k, address);
 		if (!pmd_present(*pmd_k))
 			goto no_context;
 		set_pmd(pmd, *pmd_k);
diff -puN arch/i386/mm/hugetlbpage.c~4level-architecture-changes-for-i386 arch/i386/mm/hugetlbpage.c
--- linux-2.6/arch/i386/mm/hugetlbpage.c~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/hugetlbpage.c	2004-11-14 12:33:58.000000000 +1100
@@ -21,20 +21,24 @@
 static pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd = NULL;
 
 	pgd = pgd_offset(mm, addr);
-	pmd = pmd_alloc(mm, pgd, addr);
+	pud = pud_alloc(mm, pgd, addr);
+	pmd = pmd_alloc(mm, pud, addr);
 	return (pte_t *) pmd;
 }
 
 static pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd = NULL;
 
 	pgd = pgd_offset(mm, addr);
-	pmd = pmd_offset(pgd, addr);
+	pud = pud_offset(pgd, addr);
+	pmd = pmd_offset(pud, addr);
 	return (pte_t *) pmd;
 }
 
diff -puN arch/i386/mm/init.c~4level-architecture-changes-for-i386 arch/i386/mm/init.c
--- linux-2.6/arch/i386/mm/init.c~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/init.c	2004-11-14 12:33:58.000000000 +1100
@@ -233,7 +233,7 @@ EXPORT_SYMBOL(kmap_prot);
 EXPORT_SYMBOL(kmap_pte);
 
 #define kmap_get_fixmap_pte(vaddr)					\
-	pte_offset_kernel(pmd_offset(pgd_offset_k(vaddr), (vaddr)), (vaddr))
+	pte_offset_kernel(pmd_offset(pud_offset(pgd_offset_k(vaddr), vaddr), (vaddr)), (vaddr))
 
 void __init kmap_init(void)
 {
diff -puN arch/i386/mm/ioremap.c~4level-architecture-changes-for-i386 arch/i386/mm/ioremap.c
--- linux-2.6/arch/i386/mm/ioremap.c~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/ioremap.c	2004-11-14 12:33:58.000000000 +1100
@@ -80,9 +80,14 @@ static int remap_area_pages(unsigned lon
 		BUG();
 	spin_lock(&init_mm.page_table_lock);
 	do {
+		pud_t *pud;
 		pmd_t *pmd;
-		pmd = pmd_alloc(&init_mm, dir, address);
+		
 		error = -ENOMEM;
+		pud = pud_alloc(&init_mm, dir, address);
+		if (!pud)
+			break;
+		pmd = pmd_alloc(&init_mm, pud, address);
 		if (!pmd)
 			break;
 		if (remap_area_pmd(pmd, address, end - address,
diff -puN arch/i386/mm/pageattr.c~4level-architecture-changes-for-i386 arch/i386/mm/pageattr.c
--- linux-2.6/arch/i386/mm/pageattr.c~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/pageattr.c	2004-11-14 12:33:58.000000000 +1100
@@ -19,11 +19,15 @@ static struct list_head df_list = LIST_H
 
 pte_t *lookup_address(unsigned long address) 
 { 
-	pgd_t *pgd = pgd_offset_k(address); 
+	pgd_t *pgd = pgd_offset_k(address);
+	pud_t *pud;
 	pmd_t *pmd;
 	if (pgd_none(*pgd))
 		return NULL;
-	pmd = pmd_offset(pgd, address); 	       
+	pud = pud_offset(pgd, address);
+	if (pud_none(*pud))
+		return NULL;
+	pmd = pmd_offset(pud, address);
 	if (pmd_none(*pmd))
 		return NULL;
 	if (pmd_large(*pmd))
@@ -92,7 +96,7 @@ static void set_pmd_pte(pte_t *kpte, uns
 static inline void revert_page(struct page *kpte_page, unsigned long address)
 {
 	pte_t *linear = (pte_t *) 
-		pmd_offset(pgd_offset(&init_mm, address), address);
+		pmd_offset(pud_offset(pgd_offset_k(address), address), address);
 	set_pmd_pte(linear,  address,
 		    pfn_pte((__pa(address) & LARGE_PAGE_MASK) >> PAGE_SHIFT,
 			    PAGE_KERNEL_LARGE));
diff -puN arch/i386/mm/pgtable.c~4level-architecture-changes-for-i386 arch/i386/mm/pgtable.c
diff -puN include/asm-i386/mmu_context.h~4level-architecture-changes-for-i386 include/asm-i386/mmu_context.h
diff -puN include/asm-i386/page.h~4level-architecture-changes-for-i386 include/asm-i386/page.h
diff -puN include/asm-i386/pgalloc.h~4level-architecture-changes-for-i386 include/asm-i386/pgalloc.h
--- linux-2.6/include/asm-i386/pgalloc.h~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgalloc.h	2004-11-14 12:33:58.000000000 +1100
@@ -19,7 +19,6 @@ static inline void pmd_populate(struct m
 /*
  * Allocate and free page tables.
  */
-
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(pgd_t *pgd);
 
diff -puN include/asm-i386/pgtable.h~4level-architecture-changes-for-i386 include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h~4level-architecture-changes-for-i386	2004-11-14 12:33:58.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable.h	2004-11-14 12:33:58.000000000 +1100
@@ -306,6 +306,7 @@ static inline pte_t pte_modify(pte_t pte
  * control the given virtual address
  */
 #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
+#define pgd_index_k(addr) pgd_index(addr)
 
 /*
  * pgd_offset() returns a (pgd_t *)

_

--------------090601030403010401010600--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
