Message-ID: <41C3D548.6080209@yahoo.com.au>
Date: Sat, 18 Dec 2004 17:59:20 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 7/10] alternate 4-level page tables patches
References: <41C3D453.4040208@yahoo.com.au> <41C3D479.40708@yahoo.com.au> <41C3D48F.8080006@yahoo.com.au> <41C3D4AE.7010502@yahoo.com.au> <41C3D4C8.1000508@yahoo.com.au> <41C3D4F9.9040803@yahoo.com.au> <41C3D516.9060306@yahoo.com.au>
In-Reply-To: <41C3D516.9060306@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040104020003000504020200"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040104020003000504020200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

7/10

--------------040104020003000504020200
Content-Type: text/plain;
 name="4level-architecture-changes-for-i386.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="4level-architecture-changes-for-i386.patch"



i386		works with 2 and 3 levels

Signed-off-by: Andi Kleen <ak@suse.de>

Converted to use pud_t by Nick Piggin

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>

---



---

 linux-2.6-npiggin/arch/i386/kernel/acpi/sleep.c     |    3 +-
 linux-2.6-npiggin/arch/i386/kernel/vm86.c           |   11 ++++++++-
 linux-2.6-npiggin/arch/i386/mm/fault.c              |   13 ++++++++--
 linux-2.6-npiggin/arch/i386/mm/hugetlbpage.c        |    8 +++++-
 linux-2.6-npiggin/arch/i386/mm/init.c               |   18 ++++++++++-----
 linux-2.6-npiggin/arch/i386/mm/ioremap.c            |    7 +++++
 linux-2.6-npiggin/arch/i386/mm/pageattr.c           |   14 ++++++++---
 linux-2.6-npiggin/arch/i386/mm/pgtable.c            |   12 ++++++++--
 linux-2.6-npiggin/include/asm-i386/pgalloc.h        |    3 --
 linux-2.6-npiggin/include/asm-i386/pgtable-3level.h |   24 ++++++++++----------
 linux-2.6-npiggin/include/asm-i386/pgtable.h        |    1 
 11 files changed, 81 insertions(+), 33 deletions(-)

diff -puN arch/i386/kernel/acpi/sleep.c~4level-architecture-changes-for-i386 arch/i386/kernel/acpi/sleep.c
--- linux-2.6/arch/i386/kernel/acpi/sleep.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/kernel/acpi/sleep.c	2004-12-18 17:03:11.000000000 +1100
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
--- linux-2.6/arch/i386/kernel/vm86.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/kernel/vm86.c	2004-12-18 17:03:11.000000000 +1100
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
--- linux-2.6/arch/i386/mm/fault.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/fault.c	2004-12-18 17:03:11.000000000 +1100
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
--- linux-2.6/arch/i386/mm/hugetlbpage.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/hugetlbpage.c	2004-12-18 17:03:11.000000000 +1100
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
--- linux-2.6/arch/i386/mm/init.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/init.c	2004-12-18 17:03:11.000000000 +1100
@@ -54,15 +54,18 @@ static int noinline do_test_wp_bit(void)
  */
 static pmd_t * __init one_md_table_init(pgd_t *pgd)
 {
+	pud_t *pud;
 	pmd_t *pmd_table;
 		
 #ifdef CONFIG_X86_PAE
 	pmd_table = (pmd_t *) alloc_bootmem_low_pages(PAGE_SIZE);
 	set_pgd(pgd, __pgd(__pa(pmd_table) | _PAGE_PRESENT));
-	if (pmd_table != pmd_offset(pgd, 0)) 
+	pud = pud_offset(pgd, 0);
+	if (pmd_table != pmd_offset(pud, 0)) 
 		BUG();
 #else
-	pmd_table = pmd_offset(pgd, 0);
+	pud = pud_offset(pgd, 0);
+	pmd_table = pmd_offset(pud, 0);
 #endif
 
 	return pmd_table;
@@ -100,6 +103,7 @@ static pte_t * __init one_page_table_ini
 static void __init page_table_range_init (unsigned long start, unsigned long end, pgd_t *pgd_base)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	int pgd_idx, pmd_idx;
 	unsigned long vaddr;
@@ -112,8 +116,8 @@ static void __init page_table_range_init
 	for ( ; (pgd_idx < PTRS_PER_PGD) && (vaddr != end); pgd++, pgd_idx++) {
 		if (pgd_none(*pgd)) 
 			one_md_table_init(pgd);
-
-		pmd = pmd_offset(pgd, vaddr);
+		pud = pud_offset(pgd, vaddr);
+		pmd = pmd_offset(pud, vaddr);
 		for (; (pmd_idx < PTRS_PER_PMD) && (vaddr != end); pmd++, pmd_idx++) {
 			if (pmd_none(*pmd)) 
 				one_page_table_init(pmd);
@@ -233,7 +237,7 @@ EXPORT_SYMBOL(kmap_prot);
 EXPORT_SYMBOL(kmap_pte);
 
 #define kmap_get_fixmap_pte(vaddr)					\
-	pte_offset_kernel(pmd_offset(pgd_offset_k(vaddr), (vaddr)), (vaddr))
+	pte_offset_kernel(pmd_offset(pud_offset(pgd_offset_k(vaddr), vaddr), (vaddr)), (vaddr))
 
 void __init kmap_init(void)
 {
@@ -249,6 +253,7 @@ void __init kmap_init(void)
 void __init permanent_kmaps_init(pgd_t *pgd_base)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 	unsigned long vaddr;
@@ -257,7 +262,8 @@ void __init permanent_kmaps_init(pgd_t *
 	page_table_range_init(vaddr, vaddr + PAGE_SIZE*LAST_PKMAP, pgd_base);
 
 	pgd = swapper_pg_dir + pgd_index(vaddr);
-	pmd = pmd_offset(pgd, vaddr);
+	pud = pud_offset(pgd, vaddr);
+	pmd = pmd_offset(pud, vaddr);
 	pte = pte_offset_kernel(pmd, vaddr);
 	pkmap_page_table = pte;	
 }
diff -puN arch/i386/mm/ioremap.c~4level-architecture-changes-for-i386 arch/i386/mm/ioremap.c
--- linux-2.6/arch/i386/mm/ioremap.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/ioremap.c	2004-12-18 17:03:11.000000000 +1100
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
--- linux-2.6/arch/i386/mm/pageattr.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/pageattr.c	2004-12-18 17:03:11.000000000 +1100
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
@@ -77,9 +81,11 @@ static void set_pmd_pte(pte_t *kpte, uns
 	spin_lock_irqsave(&pgd_lock, flags);
 	for (page = pgd_list; page; page = (struct page *)page->index) {
 		pgd_t *pgd;
+		pud_t *pud;
 		pmd_t *pmd;
 		pgd = (pgd_t *)page_address(page) + pgd_index(address);
-		pmd = pmd_offset(pgd, address);
+		pud = pud_offset(pgd, address);
+		pmd = pmd_offset(pud, address);
 		set_pte_atomic((pte_t *)pmd, pte);
 	}
 	spin_unlock_irqrestore(&pgd_lock, flags);
@@ -92,7 +98,7 @@ static void set_pmd_pte(pte_t *kpte, uns
 static inline void revert_page(struct page *kpte_page, unsigned long address)
 {
 	pte_t *linear = (pte_t *) 
-		pmd_offset(pgd_offset(&init_mm, address), address);
+		pmd_offset(pud_offset(pgd_offset_k(address), address), address);
 	set_pmd_pte(linear,  address,
 		    pfn_pte((__pa(address) & LARGE_PAGE_MASK) >> PAGE_SHIFT,
 			    PAGE_KERNEL_LARGE));
diff -puN arch/i386/mm/pgtable.c~4level-architecture-changes-for-i386 arch/i386/mm/pgtable.c
--- linux-2.6/arch/i386/mm/pgtable.c~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/arch/i386/mm/pgtable.c	2004-12-18 17:03:11.000000000 +1100
@@ -62,6 +62,7 @@ void show_mem(void)
 static void set_pte_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
@@ -70,7 +71,12 @@ static void set_pte_pfn(unsigned long va
 		BUG();
 		return;
 	}
-	pmd = pmd_offset(pgd, vaddr);
+	pud = pud_offset(pgd, vaddr);
+	if (pud_none(*pud)) {
+		BUG();
+		return;
+	}
+	pmd = pmd_offset(pud, vaddr);
 	if (pmd_none(*pmd)) {
 		BUG();
 		return;
@@ -95,6 +101,7 @@ static void set_pte_pfn(unsigned long va
 void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
 {
 	pgd_t *pgd;
+	pud_t *pud;
 	pmd_t *pmd;
 
 	if (vaddr & (PMD_SIZE-1)) {		/* vaddr is misaligned */
@@ -110,7 +117,8 @@ void set_pmd_pfn(unsigned long vaddr, un
 		printk ("set_pmd_pfn: pgd_none\n");
 		return; /* BUG(); */
 	}
-	pmd = pmd_offset(pgd, vaddr);
+	pud = pud_offset(pgd, vaddr);
+	pmd = pmd_offset(pud, vaddr);
 	set_pmd(pmd, pfn_pmd(pfn, flags));
 	/*
 	 * It's enough to flush this one mapping.
diff -puN include/asm-i386/mmu_context.h~4level-architecture-changes-for-i386 include/asm-i386/mmu_context.h
diff -puN include/asm-i386/page.h~4level-architecture-changes-for-i386 include/asm-i386/page.h
diff -puN include/asm-i386/pgalloc.h~4level-architecture-changes-for-i386 include/asm-i386/pgalloc.h
--- linux-2.6/include/asm-i386/pgalloc.h~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgalloc.h	2004-12-18 17:03:11.000000000 +1100
@@ -17,7 +17,6 @@
 /*
  * Allocate and free page tables.
  */
-
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(pgd_t *pgd);
 
@@ -44,7 +43,7 @@ static inline void pte_free(struct page 
 #define pmd_alloc_one(mm, addr)		({ BUG(); ((pmd_t *)2); })
 #define pmd_free(x)			do { } while (0)
 #define __pmd_free_tlb(tlb,x)		do { } while (0)
-#define pgd_populate(mm, pmd, pte)	BUG()
+#define pud_populate(mm, pmd, pte)	BUG()
 #endif
 
 #define check_pgt_cache()	do { } while (0)
diff -puN include/asm-i386/pgtable.h~4level-architecture-changes-for-i386 include/asm-i386/pgtable.h
--- linux-2.6/include/asm-i386/pgtable.h~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable.h	2004-12-18 17:03:11.000000000 +1100
@@ -303,6 +303,7 @@ static inline pte_t pte_modify(pte_t pte
  * control the given virtual address
  */
 #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
+#define pgd_index_k(addr) pgd_index(addr)
 
 /*
  * pgd_offset() returns a (pgd_t *)
diff -puN include/asm-i386/pgtable-2level.h~4level-architecture-changes-for-i386 include/asm-i386/pgtable-2level.h
diff -puN include/asm-i386/pgtable-3level.h~4level-architecture-changes-for-i386 include/asm-i386/pgtable-3level.h
--- linux-2.6/include/asm-i386/pgtable-3level.h~4level-architecture-changes-for-i386	2004-12-18 17:03:11.000000000 +1100
+++ linux-2.6-npiggin/include/asm-i386/pgtable-3level.h	2004-12-18 17:03:11.000000000 +1100
@@ -1,6 +1,8 @@
 #ifndef _I386_PGTABLE_3LEVEL_H
 #define _I386_PGTABLE_3LEVEL_H
 
+#include <asm-generic/pgtable-nopud.h>
+
 /*
  * Intel Physical Address Extension (PAE) Mode - three-level page
  * tables on PPro+ CPUs.
@@ -15,9 +17,9 @@
 #define pgd_ERROR(e) \
 	printk("%s:%d: bad pgd %p(%016Lx).\n", __FILE__, __LINE__, &(e), pgd_val(e))
 
-static inline int pgd_none(pgd_t pgd)		{ return 0; }
-static inline int pgd_bad(pgd_t pgd)		{ return 0; }
-static inline int pgd_present(pgd_t pgd)	{ return 1; }
+#define pud_none(pud)				0
+#define pud_bad(pud)				0
+#define pud_present(pud)			1
 
 /*
  * Is the pte executable?
@@ -59,8 +61,8 @@ static inline void set_pte(pte_t *ptep, 
 		set_64bit((unsigned long long *)(pteptr),pte_val(pteval))
 #define set_pmd(pmdptr,pmdval) \
 		set_64bit((unsigned long long *)(pmdptr),pmd_val(pmdval))
-#define set_pgd(pgdptr,pgdval) \
-		set_64bit((unsigned long long *)(pgdptr),pgd_val(pgdval))
+#define set_pud(pudptr,pudval) \
+		set_64bit((unsigned long long *)(pudptr),pud_val(pudval))
 
 /*
  * Pentium-II erratum A13: in PAE mode we explicitly have to flush
@@ -68,22 +70,22 @@ static inline void set_pte(pte_t *ptep, 
  * We do not let the generic code free and clear pgd entries due to
  * this erratum.
  */
-static inline void pgd_clear (pgd_t * pgd) { }
+static inline void pud_clear (pud_t * pud) { }
 
 #define pmd_page(pmd) (pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT))
 
 #define pmd_page_kernel(pmd) \
 ((unsigned long) __va(pmd_val(pmd) & PAGE_MASK))
 
-#define pgd_page(pgd) \
-((struct page *) __va(pgd_val(pgd) & PAGE_MASK))
+#define pud_page(pud) \
+((struct page *) __va(pud_val(pud) & PAGE_MASK))
 
-#define pgd_page_kernel(pgd) \
-((unsigned long) __va(pgd_val(pgd) & PAGE_MASK))
+#define pud_page_kernel(pud) \
+((unsigned long) __va(pud_val(pud) & PAGE_MASK))
 
 
 /* Find an entry in the second-level page table.. */
-#define pmd_offset(dir, address) ((pmd_t *) pgd_page(*(dir)) + \
+#define pmd_offset(pud, address) ((pmd_t *) pud_page(*(pud)) + \
 			pmd_index(address))
 
 static inline pte_t ptep_get_and_clear(pte_t *ptep)

_

--------------040104020003000504020200--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
