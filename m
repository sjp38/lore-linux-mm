Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 13AF76B0070
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:24:28 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fa1so25528163pad.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 05:24:27 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id uq4si5701477pbc.165.2015.01.28.05.24.24
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 05:24:25 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/4] mm: define __PAGETABLE_{PMD,PUD}_FOLDED to zero or one
Date: Wed, 28 Jan 2015 15:17:43 +0200
Message-Id: <1422451064-109023-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently, we define __PAGETABLE_PMD_FOLDED and __PAGETABLE_PUD_FOLDED
to empty value if the page table level is folded. The patch changes it
to define the macros to one if the page level is folded and zero
otherwise.

This would help to detect situation when include <asm/pgtable.h> is
missed or we have circular like <asm/pgtable.h> -> <linux/mm_struct.h>
-> <asm/pgtable.h>.

We still use #ifdef inside <asm/pgtables.h> since we only define macros
to zero at the end of header in <asm-generic/pgtable.h>.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/arm/include/asm/pgtable-2level.h | 2 +-
 arch/arm64/include/asm/kvm_mmu.h      | 4 ++--
 arch/arm64/mm/hugetlbpage.c           | 6 +++---
 arch/microblaze/include/asm/pgtable.h | 2 +-
 arch/mips/include/asm/pgalloc.h       | 4 ++--
 arch/mips/kernel/asm-offsets.c        | 4 ++--
 arch/mips/mm/init.c                   | 2 +-
 arch/mips/mm/pgtable-64.c             | 6 +++---
 arch/mips/mm/tlbex.c                  | 8 ++++----
 arch/powerpc/mm/pgtable_64.c          | 2 +-
 arch/sh/mm/init.c                     | 2 +-
 arch/tile/mm/hugetlbpage.c            | 4 ++--
 arch/tile/mm/pgtable.c                | 4 ++--
 arch/x86/include/asm/xen/page.h       | 2 +-
 include/asm-generic/4level-fixup.h    | 2 +-
 include/asm-generic/pgtable-nopmd.h   | 2 +-
 include/asm-generic/pgtable-nopud.h   | 2 +-
 include/asm-generic/pgtable.h         | 8 ++++++++
 include/linux/mm.h                    | 4 ++--
 kernel/fork.c                         | 2 +-
 mm/memory.c                           | 4 ++--
 21 files changed, 42 insertions(+), 34 deletions(-)

diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index bfd662e49a25..7d77adce17ae 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -10,7 +10,7 @@
 #ifndef _ASM_PGTABLE_2LEVEL_H
 #define _ASM_PGTABLE_2LEVEL_H
 
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 
 /*
  * Hardware-wise, we have a two level page table structure, where the first
diff --git a/arch/arm64/include/asm/kvm_mmu.h b/arch/arm64/include/asm/kvm_mmu.h
index 66577581ce68..a14a14323cb6 100644
--- a/arch/arm64/include/asm/kvm_mmu.h
+++ b/arch/arm64/include/asm/kvm_mmu.h
@@ -240,14 +240,14 @@ static inline bool kvm_page_empty(void *ptr)
 
 #define kvm_pte_table_empty(kvm, ptep) kvm_page_empty(ptep)
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if __PAGETABLE_PMD_FOLDED
 #define kvm_pmd_table_empty(kvm, pmdp) (0)
 #else
 #define kvm_pmd_table_empty(kvm, pmdp) \
 	(kvm_page_empty(pmdp) && (!(kvm) || KVM_PREALLOC_LEVEL < 2))
 #endif
 
-#ifdef __PAGETABLE_PUD_FOLDED
+#if __PAGETABLE_PUD_FOLDED
 #define kvm_pud_table_empty(kvm, pudp) (0)
 #else
 #define kvm_pud_table_empty(kvm, pudp) \
diff --git a/arch/arm64/mm/hugetlbpage.c b/arch/arm64/mm/hugetlbpage.c
index 2de9d2e59d96..f37dadacc4cd 100644
--- a/arch/arm64/mm/hugetlbpage.c
+++ b/arch/arm64/mm/hugetlbpage.c
@@ -45,10 +45,10 @@ int pmd_huge(pmd_t pmd)
 
 int pud_huge(pud_t pud)
 {
-#ifndef __PAGETABLE_PMD_FOLDED
-	return !(pud_val(pud) & PUD_TABLE_BIT);
-#else
+#if __PAGETABLE_PMD_FOLDED
 	return 0;
+#else
+	return !(pud_val(pud) & PUD_TABLE_BIT);
 #endif
 }
 
diff --git a/arch/microblaze/include/asm/pgtable.h b/arch/microblaze/include/asm/pgtable.h
index e53b8532353c..2789da060229 100644
--- a/arch/microblaze/include/asm/pgtable.h
+++ b/arch/microblaze/include/asm/pgtable.h
@@ -61,7 +61,7 @@ extern int mem_init_done;
 
 #include <asm-generic/4level-fixup.h>
 
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index b336037e8768..5b0164ba93d9 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -31,7 +31,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
  */
 extern void pmd_init(unsigned long page, unsigned long pagetable);
 
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 
 static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 {
@@ -107,7 +107,7 @@ do {							\
 	tlb_remove_page((tlb), pte);			\
 } while (0)
 
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
diff --git a/arch/mips/kernel/asm-offsets.c b/arch/mips/kernel/asm-offsets.c
index 3b2dfdb4865f..1b2c5f8653aa 100644
--- a/arch/mips/kernel/asm-offsets.c
+++ b/arch/mips/kernel/asm-offsets.c
@@ -252,13 +252,13 @@ void output_mm_defines(void)
 	DEFINE(_PTE_T_SIZE, sizeof(pte_t));
 	BLANK();
 	DEFINE(_PGD_T_LOG2, PGD_T_LOG2);
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 	DEFINE(_PMD_T_LOG2, PMD_T_LOG2);
 #endif
 	DEFINE(_PTE_T_LOG2, PTE_T_LOG2);
 	BLANK();
 	DEFINE(_PGD_ORDER, PGD_ORDER);
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 	DEFINE(_PMD_ORDER, PMD_ORDER);
 #endif
 	DEFINE(_PTE_ORDER, PTE_ORDER);
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 448cde372af0..838838b05d1c 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -440,7 +440,7 @@ unsigned long pgd_current[NR_CPUS];
  * it in the linker script.
  */
 pgd_t swapper_pg_dir[_PTRS_PER_PGD] __section(.bss..swapper_pg_dir);
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 pmd_t invalid_pmd_table[PTRS_PER_PMD] __page_aligned_bss;
 #endif
 pte_t invalid_pte_table[PTRS_PER_PTE] __page_aligned_bss;
diff --git a/arch/mips/mm/pgtable-64.c b/arch/mips/mm/pgtable-64.c
index e8adc0069d66..379b8390f059 100644
--- a/arch/mips/mm/pgtable-64.c
+++ b/arch/mips/mm/pgtable-64.c
@@ -18,7 +18,7 @@ void pgd_init(unsigned long page)
 	unsigned long *p, *end;
 	unsigned long entry;
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if __PAGETABLE_PMD_FOLDED
 	entry = (unsigned long)invalid_pte_table;
 #else
 	entry = (unsigned long)invalid_pmd_table;
@@ -40,7 +40,7 @@ void pgd_init(unsigned long page)
 	} while (p != end);
 }
 
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 void pmd_init(unsigned long addr, unsigned long pagetable)
 {
 	unsigned long *p, *end;
@@ -99,7 +99,7 @@ void __init pagetable_init(void)
 
 	/* Initialize the entire pgd.  */
 	pgd_init((unsigned long)swapper_pg_dir);
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 	pmd_init((unsigned long)invalid_pmd_table, (unsigned long)invalid_pte_table);
 #endif
 	pgd_base = swapper_pg_dir;
diff --git a/arch/mips/mm/tlbex.c b/arch/mips/mm/tlbex.c
index 3978a3d81366..afbadec7d595 100644
--- a/arch/mips/mm/tlbex.c
+++ b/arch/mips/mm/tlbex.c
@@ -840,7 +840,7 @@ build_get_pmde64(u32 **p, struct uasm_label **l, struct uasm_reloc **r,
 
 	uasm_i_andi(p, tmp, tmp, (PTRS_PER_PGD - 1)<<3);
 	uasm_i_daddu(p, ptr, ptr, tmp); /* add in pgd offset */
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 	uasm_i_dmfc0(p, tmp, C0_BADVADDR); /* get faulting address */
 	uasm_i_ld(p, ptr, 0, ptr); /* get pmd pointer */
 	uasm_i_dsrl_safe(p, tmp, tmp, PMD_SHIFT-3); /* get pmd offset in bytes */
@@ -1128,7 +1128,7 @@ build_fast_tlb_refill_handler (u32 **p, struct uasm_label **l,
 		uasm_i_drotr(p, ptr, ptr, 11);
 	}
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if __PAGETABLE_PMD_FOLDED
 #define LOC_PTEP scratch
 #else
 #define LOC_PTEP ptr
@@ -1150,7 +1150,7 @@ build_fast_tlb_refill_handler (u32 **p, struct uasm_label **l,
 		/* get pgd offset in bytes */
 		uasm_i_dsrl_safe(p, scratch, tmp, PGDIR_SHIFT - 3);
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if __PAGETABLE_PMD_FOLDED
 	GET_CONTEXT(p, tmp); /* get context reg */
 #endif
 	uasm_i_andi(p, scratch, scratch, (PTRS_PER_PGD - 1) << 3);
@@ -1162,7 +1162,7 @@ build_fast_tlb_refill_handler (u32 **p, struct uasm_label **l,
 		uasm_i_ld(p, LOC_PTEP, 0, ptr); /* get pmd pointer */
 	}
 
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 	/* get pmd offset in bytes */
 	uasm_i_dsrl_safe(p, scratch, tmp, PMD_SHIFT - 3);
 	uasm_i_andi(p, scratch, scratch, (PTRS_PER_PMD - 1) << 3);
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 6957cc1ca0a7..727832cad640 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -345,7 +345,7 @@ EXPORT_SYMBOL(iounmap);
 EXPORT_SYMBOL(__iounmap);
 EXPORT_SYMBOL(__iounmap_at);
 
-#ifndef __PAGETABLE_PUD_FOLDED
+#if !__PAGETABLE_PUD_FOLDED
 /* 4 level page table */
 struct page *pgd_page(pgd_t pgd)
 {
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 2790b6a64157..1e611d71301c 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -175,7 +175,7 @@ void __init page_table_range_init(unsigned long start, unsigned long end,
 		pud = (pud_t *)pgd;
 		for ( ; (j < PTRS_PER_PUD) && (vaddr != end); pud++, j++) {
 			pmd = one_md_table_init(pud);
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 			pmd += k;
 #endif
 			for (; (k < PTRS_PER_PMD) && (vaddr != end); pmd++, k++) {
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 8416240c322c..97c4ccecd0ed 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -115,14 +115,14 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 
 	/* We don't have four levels. */
 	pud = pud_offset(pgd, addr);
-#ifndef __PAGETABLE_PUD_FOLDED
+#if !__PAGETABLE_PUD_FOLDED
 # error support fourth page table level
 #endif
 	if (!pud_present(*pud))
 		return NULL;
 
 	/* Check for an L0 huge PTE, if we have three levels. */
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 	if (pud_huge(*pud))
 		return (pte_t *)pud;
 
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 7bf2491a9c1f..e37081d62ca9 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -101,7 +101,7 @@ void shatter_huge_page(unsigned long addr)
 	pud_t *pud;
 	pmd_t *pmd;
 	unsigned long flags = 0;  /* happy compiler */
-#ifdef __PAGETABLE_PMD_FOLDED
+#if __PAGETABLE_PMD_FOLDED
 	struct list_head *pos;
 #endif
 
@@ -127,7 +127,7 @@ void shatter_huge_page(unsigned long addr)
 	/* Shatter the huge page into the preallocated L2 page table. */
 	pmd_populate_kernel(&init_mm, pmd, get_prealloc_pte(pmd_pfn(*pmd)));
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if __PAGETABLE_PMD_FOLDED
 	/* Walk every pgd on the system and update the pmd there. */
 	spin_lock(&pgd_lock);
 	list_for_each(pos, &pgd_list) {
diff --git a/arch/x86/include/asm/xen/page.h b/arch/x86/include/asm/xen/page.h
index 5eea09915a15..49fc452d4899 100644
--- a/arch/x86/include/asm/xen/page.h
+++ b/arch/x86/include/asm/xen/page.h
@@ -253,7 +253,7 @@ static inline pte_t __pte_ma(pteval_t x)
 }
 
 #define pmd_val_ma(v) ((v).pmd)
-#ifdef __PAGETABLE_PUD_FOLDED
+#if __PAGETABLE_PUD_FOLDED
 #define pud_val_ma(v) ((v).pgd.pgd)
 #else
 #define pud_val_ma(v) ((v).pud)
diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index 5bdab6bffd23..c6a349d459e5 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -2,7 +2,7 @@
 #define _4LEVEL_FIXUP_H
 
 #define __ARCH_HAS_4LEVEL_HACK
-#define __PAGETABLE_PUD_FOLDED
+#define __PAGETABLE_PUD_FOLDED 1
 
 #define PUD_SHIFT			PGDIR_SHIFT
 #define PUD_SIZE			PGDIR_SIZE
diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index 725612b793ce..6373f61824a0 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -7,7 +7,7 @@
 
 struct mm_struct;
 
-#define __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 1
 
 /*
  * Having the pmd type consist of a pud gets the size right, and allows
diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
index 810431d8351b..8bc0a92c0764 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -3,7 +3,7 @@
 
 #ifndef __ASSEMBLY__
 
-#define __PAGETABLE_PUD_FOLDED
+#define __PAGETABLE_PUD_FOLDED 1
 
 /*
  * Having the pud type consist of a pgd gets the size right, and allows
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 4d46085c1b90..22bffcb2e96b 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -17,6 +17,14 @@
 #define USER_PGTABLES_CEILING	0UL
 #endif
 
+#ifndef __PAGETABLE_PUD_FOLDED
+#define __PAGETABLE_PUD_FOLDED 0
+#endif
+
+#ifndef __PAGETABLE_PMD_FOLDED
+#define __PAGETABLE_PMD_FOLDED 0
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 extern int ptep_set_access_flags(struct vm_area_struct *vma,
 				 unsigned long address, pte_t *ptep,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 543e9723d441..98bde6d48640 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1435,7 +1435,7 @@ static inline pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
 	return ptep;
 }
 
-#ifdef __PAGETABLE_PUD_FOLDED
+#if __PAGETABLE_PUD_FOLDED
 static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
 						unsigned long address)
 {
@@ -1445,7 +1445,7 @@ static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
 int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
 #endif
 
-#ifdef __PAGETABLE_PMD_FOLDED
+#if __PAGETABLE_PMD_FOLDED
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
 						unsigned long address)
 {
diff --git a/kernel/fork.c b/kernel/fork.c
index 76d6f292274c..da94fa59b96a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -555,7 +555,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_state = NULL;
 	atomic_long_set(&mm->nr_ptes, 0);
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 	atomic_long_set(&mm->nr_pmds, 0);
 #endif
 	mm->map_count = 0;
diff --git a/mm/memory.c b/mm/memory.c
index ed697e9a5e5b..27eb05ddadb9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3311,7 +3311,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 EXPORT_SYMBOL_GPL(handle_mm_fault);
 
-#ifndef __PAGETABLE_PUD_FOLDED
+#if !__PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
  * We've already handled the fast-path in-line.
@@ -3334,7 +3334,7 @@ int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 }
 #endif /* __PAGETABLE_PUD_FOLDED */
 
-#ifndef __PAGETABLE_PMD_FOLDED
+#if !__PAGETABLE_PMD_FOLDED
 /*
  * Allocate page middle directory.
  * We've already handled the fast-path in-line.
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
