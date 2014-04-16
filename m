Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 20ED56B007B
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 07:46:58 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id z2so1227706wiv.0
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:57 -0700 (PDT)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
        by mx.google.com with ESMTPS id mc8si7804126wic.27.2014.04.16.04.46.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 04:46:56 -0700 (PDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so11046019wgh.16
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:56 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH V2 4/5] arm: mm: HugeTLB support for non-LPAE systems
Date: Wed, 16 Apr 2014 12:46:42 +0100
Message-Id: <1397648803-15961-5-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, akpm@linux-foundation.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, robherring2@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, gerald.schaefer@de.ibm.com, Steve Capper <steve.capper@linaro.org>

Add huge page support for systems with short descriptors. Rather than
store separate linux/hardware huge ptes, we work directly with the
hardware descriptors at the pmd level.

As we work directly with the pmd and need to store information that
doesn't directly correspond to hardware bits (such as the accessed
flag and dirty bit); we re-purporse the domain bits of the short
section descriptor. In order to use these domain bits for storage,
we need to make ourselves a client for all 16 domains and this is
done in head.S.

Storing extra information in the domain bits also makes it a lot
easier to implement Transparent Huge Pages, and some of the code in
pgtable-2level.h is arranged to facilitate THP support in a later
patch.

Non-LPAE HugeTLB pages are incompatible with the huge page migration
code (enabled when CONFIG_MEMORY_FAILURE is selected) as that code
dereferences PTEs directly, rather than calling huge_ptep_get and
set_huge_pte_at.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/Kconfig                      |   2 +-
 arch/arm/include/asm/hugetlb-2level.h | 136 ++++++++++++++++++++++++++++++++++
 arch/arm/include/asm/hugetlb-3level.h |   6 ++
 arch/arm/include/asm/hugetlb.h        |  10 +--
 arch/arm/include/asm/pgtable-2level.h |  97 +++++++++++++++++++++++-
 arch/arm/include/asm/pgtable-3level.h |   2 +-
 arch/arm/include/asm/pgtable.h        |   1 +
 arch/arm/kernel/head.S                |  10 ++-
 arch/arm/mm/fault.c                   |  13 ----
 arch/arm/mm/fsr-2level.c              |   4 +-
 arch/arm/mm/hugetlbpage.c             |   2 +-
 arch/arm/mm/mmu.c                     |  51 +++++++++++++
 12 files changed, 305 insertions(+), 29 deletions(-)
 create mode 100644 arch/arm/include/asm/hugetlb-2level.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index ab438cb..5e80fad 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -1832,7 +1832,7 @@ config HW_PERF_EVENTS
 
 config SYS_SUPPORTS_HUGETLBFS
        def_bool y
-       depends on ARM_LPAE
+       depends on ARM_LPAE || (!CPU_USE_DOMAINS && !MEMORY_FAILURE)
 
 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
        def_bool y
diff --git a/arch/arm/include/asm/hugetlb-2level.h b/arch/arm/include/asm/hugetlb-2level.h
new file mode 100644
index 0000000..f8d701f
--- /dev/null
+++ b/arch/arm/include/asm/hugetlb-2level.h
@@ -0,0 +1,136 @@
+/*
+ * arch/arm/include/asm/hugetlb-2level.h
+ *
+ * Copyright (C) 2014 Linaro Ltd.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _ASM_ARM_HUGETLB_2LEVEL_H
+#define _ASM_ARM_HUGETLB_2LEVEL_H
+
+
+static inline pte_t huge_ptep_get(pte_t *ptep)
+{
+	return *ptep;
+}
+
+static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
+				   pte_t *ptep, pte_t pte)
+{
+	set_pmd_at(mm, addr, (pmd_t *) ptep, __pmd(pte_val(pte)));
+}
+
+static inline pte_t pte_mkhuge(pte_t pte) { return pte; }
+
+static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
+					 unsigned long addr, pte_t *ptep)
+{
+	pmd_t *pmdp = (pmd_t *)ptep;
+	pmd_clear(pmdp);
+	flush_tlb_range(vma, addr, addr + HPAGE_SIZE);
+}
+
+static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
+					   unsigned long addr, pte_t *ptep)
+{
+	pmd_t *pmdp = (pmd_t *) ptep;
+	set_pmd_at(mm, addr, pmdp, pmd_wrprotect(*pmdp));
+}
+
+
+static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+					    unsigned long addr, pte_t *ptep)
+{
+	pmd_t *pmdp = (pmd_t *)ptep;
+	pte_t pte = huge_ptep_get(ptep);
+	pmd_clear(pmdp);
+
+	return pte;
+}
+
+static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
+					     unsigned long addr, pte_t *ptep,
+					     pte_t pte, int dirty)
+{
+	int changed = !pte_same(huge_ptep_get(ptep), pte);
+	if (changed) {
+		set_huge_pte_at(vma->vm_mm, addr, ptep, pte);
+		flush_tlb_range(vma, addr, addr + HPAGE_SIZE);
+	}
+
+	return changed;
+}
+
+static inline pte_t huge_pte_mkwrite(pte_t pte)
+{
+	pmd_t pmd = __pmd(pte_val(pte));
+	pmd = pmd_mkwrite(pmd);
+	return __pte(pmd_val(pmd));
+}
+
+static inline pte_t huge_pte_mkdirty(pte_t pte)
+{
+	pmd_t pmd = __pmd(pte_val(pte));
+	pmd = pmd_mkdirty(pmd);
+	return __pte(pmd_val(pmd));
+}
+
+static inline unsigned long huge_pte_dirty(pte_t pte)
+{
+	return pmd_dirty(__pmd(pte_val(pte)));
+}
+
+static inline unsigned long huge_pte_write(pte_t pte)
+{
+	return pmd_write(__pmd(pte_val(pte)));
+}
+
+static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
+				  pte_t *ptep)
+{
+	pmd_t *pmdp = (pmd_t *)ptep;
+	pmd_clear(pmdp);
+}
+
+static inline pte_t mk_huge_pte(struct page *page, pgprot_t pgprot)
+{
+	pmd_t pmd = mk_pmd(page,pgprot);
+	return __pte(pmd_val(pmd));
+}
+
+static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
+{
+	pmd_t pmd = pmd_modify(__pmd(pte_val(pte)), newprot);
+	return __pte(pmd_val(pmd));
+}
+
+static inline pte_t huge_pte_wrprotect(pte_t pte)
+{
+	pmd_t pmd = pmd_wrprotect(__pmd(pte_val(pte)));
+	return __pte(pmd_val(pmd));
+}
+
+static inline struct page *huge_pte_page(pte_t pte)
+{
+	return pfn_to_page((pte_val(pte) & HPAGE_MASK) >> PAGE_SHIFT);
+}
+
+static inline unsigned long huge_pte_present(pte_t pte)
+{
+	return 1;
+}
+
+static inline pte_t huge_pte_mkyoung(pte_t pte)
+{
+	return __pte(pmd_val(pmd_mkyoung(__pmd(pte_val(pte)))));
+}
+
+#endif /* _ASM_ARM_HUGETLB_2LEVEL_H */
diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
index d4014fb..c633119 100644
--- a/arch/arm/include/asm/hugetlb-3level.h
+++ b/arch/arm/include/asm/hugetlb-3level.h
@@ -22,6 +22,7 @@
 #ifndef _ASM_ARM_HUGETLB_3LEVEL_H
 #define _ASM_ARM_HUGETLB_3LEVEL_H
 
+#include <asm-generic/hugetlb.h>
 
 /*
  * If our huge pte is non-zero then mark the valid bit.
@@ -68,4 +69,9 @@ static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
 }
 
+static inline pte_t huge_pte_wrprotect(pte_t pte)
+{
+	return pte_wrprotect(pte);
+}
+
 #endif /* _ASM_ARM_HUGETLB_3LEVEL_H */
diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
index 1f1b1cd..1d7f7b7 100644
--- a/arch/arm/include/asm/hugetlb.h
+++ b/arch/arm/include/asm/hugetlb.h
@@ -23,9 +23,12 @@
 #define _ASM_ARM_HUGETLB_H
 
 #include <asm/page.h>
-#include <asm-generic/hugetlb.h>
 
+#ifdef CONFIG_ARM_LPAE
 #include <asm/hugetlb-3level.h>
+#else
+#include <asm/hugetlb-2level.h>
+#endif
 
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr, unsigned long end,
@@ -62,11 +65,6 @@ static inline int huge_pte_none(pte_t pte)
 	return pte_none(pte);
 }
 
-static inline pte_t huge_pte_wrprotect(pte_t pte)
-{
-	return pte_wrprotect(pte);
-}
-
 static inline int arch_prepare_hugepage(struct page *page)
 {
 	return 0;
diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index 219ac88..323e19f 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -156,6 +156,19 @@
 #define pud_clear(pudp)		do { } while (0)
 #define set_pud(pud,pudp)	do { } while (0)
 
+static inline int pmd_thp_or_huge(pmd_t pmd)
+{
+	if ((pmd_val(pmd) & PMD_TYPE_MASK) == PMD_TYPE_FAULT)
+		return pmd_val(pmd);
+
+	return ((pmd_val(pmd) & PMD_TYPE_MASK) == PMD_TYPE_SECT);
+}
+
+static inline int pte_huge(pte_t pte)
+{
+	return pmd_thp_or_huge(__pmd(pte_val(pte)));
+}
+
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 {
 	return (pmd_t *)pud;
@@ -184,11 +197,87 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 #define set_pte_ext(ptep,pte,ext) cpu_set_pte_ext(ptep,pte,ext)
 
 /*
- * We don't have huge page support for short descriptors, for the moment
- * define empty stubs for use by pin_page_for_write.
+ * now follows some of the definitions to allow huge page support, we can't put
+ * these in the hugetlb source files as they are also required for transparent
+ * hugepage support.
  */
-#define pmd_hugewillfault(pmd)	(0)
-#define pmd_thp_or_huge(pmd)	(0)
+
+#define HPAGE_SHIFT             PMD_SHIFT
+#define HPAGE_SIZE              (_AC(1, UL) << HPAGE_SHIFT)
+#define HPAGE_MASK              (~(HPAGE_SIZE - 1))
+#define HUGETLB_PAGE_ORDER      (HPAGE_SHIFT - PAGE_SHIFT)
+
+/*
+ *  We re-purpose the following domain bits in the section descriptor
+ */
+#define PMD_DSECT_DIRTY		(_AT(pmdval_t, 1) << 5)
+#define PMD_DSECT_AF		(_AT(pmdval_t, 1) << 6)
+
+#define PMD_BIT_FUNC(fn,op) \
+static inline pmd_t pmd_##fn(pmd_t pmd) { pmd_val(pmd) op; return pmd; }
+
+static inline unsigned long pmd_pfn(pmd_t pmd)
+{
+	/*
+	 * for a section, we need to mask off more of the pmd
+	 * before looking up the pfn.
+	 */
+	if (pmd_thp_or_huge(pmd))
+		return __phys_to_pfn(pmd_val(pmd) & HPAGE_MASK);
+	else
+		return __phys_to_pfn(pmd_val(pmd) & PHYS_MASK);
+}
+
+extern pgprot_t get_huge_pgprot(pgprot_t newprot);
+
+#define pfn_pmd(pfn,prot) __pmd(__pfn_to_phys(pfn) | pgprot_val(prot));
+#define mk_pmd(page,prot) pfn_pmd(page_to_pfn(page),get_huge_pgprot(prot));
+
+PMD_BIT_FUNC(mkdirty, |= PMD_DSECT_DIRTY);
+PMD_BIT_FUNC(mkwrite, |= PMD_SECT_AP_WRITE);
+PMD_BIT_FUNC(wrprotect,	&= ~PMD_SECT_AP_WRITE);
+PMD_BIT_FUNC(mknexec,	|= PMD_SECT_XN);
+PMD_BIT_FUNC(rmprotnone, |= PMD_TYPE_SECT);
+PMD_BIT_FUNC(mkyoung, |= PMD_DSECT_AF);
+
+#define pmd_young(pmd)			(pmd_val(pmd) & PMD_DSECT_AF)
+#define pmd_write(pmd)			(pmd_val(pmd) & PMD_SECT_AP_WRITE)
+#define pmd_exec(pmd)			(!(pmd_val(pmd) & PMD_SECT_XN))
+#define pmd_dirty(pmd)			(pmd_val(pmd) & PMD_DSECT_DIRTY)
+
+#define pmd_hugewillfault(pmd)		(!pmd_young(pmd) || !pmd_write(pmd))
+
+#define __HAVE_ARCH_PMD_WRITE
+
+extern void __sync_icache_dcache(unsigned long pfn, int exec);
+
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+				pmd_t *pmdp, pmd_t pmd)
+{
+	VM_BUG_ON((pmd_val(pmd) & PMD_TYPE_MASK) == PMD_TYPE_TABLE);
+
+	if (!pmd_val(pmd)) {
+		pmdp[0] = pmdp[1] = pmd;
+	} else {
+		pmdp[0] = __pmd(pmd_val(pmd));
+		pmdp[1] = __pmd(pmd_val(pmd) + SECTION_SIZE);
+
+		__sync_icache_dcache(pmd_pfn(pmd), pmd_exec(pmd));
+	}
+
+	flush_pmd_entry(pmdp);
+}
+
+static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	pgprot_t hugeprot = get_huge_pgprot(newprot);
+	const pmdval_t mask = PMD_SECT_XN | PMD_SECT_AP_WRITE |
+				PMD_TYPE_SECT;
+
+	pmd_val(pmd) = (pmd_val(pmd) & ~mask) | (pgprot_val(hugeprot) & mask);
+
+	return pmd;
+}
 
 #endif /* __ASSEMBLY__ */
 
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 85c60ad..a4b71c1 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -213,7 +213,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 #define pmd_write(pmd)		(!(pmd_val(pmd) & PMD_SECT_RDONLY))
 
 #define pmd_hugewillfault(pmd)	(!pmd_young(pmd) || !pmd_write(pmd))
-#define pmd_thp_or_huge(pmd)	(pmd_huge(pmd) || pmd_trans_huge(pmd))
+#define pmd_thp_or_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd)	(pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT))
diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 3a9c238..576511f2 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -222,6 +222,7 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
 #define pte_dirty(pte)		(pte_val(pte) & L_PTE_DIRTY)
 #define pte_young(pte)		(pte_val(pte) & L_PTE_YOUNG)
 #define pte_exec(pte)		(!(pte_val(pte) & L_PTE_XN))
+#define pte_protnone(pte)	(pte_val(pte) & L_PTE_NONE)
 #define pte_special(pte)	(0)
 
 #define pte_valid_user(pte)	\
diff --git a/arch/arm/kernel/head.S b/arch/arm/kernel/head.S
index f8c0883..dd9ab4c 100644
--- a/arch/arm/kernel/head.S
+++ b/arch/arm/kernel/head.S
@@ -434,13 +434,21 @@ __enable_mmu:
 	bic	r0, r0, #CR_I
 #endif
 #ifndef CONFIG_ARM_LPAE
+#ifndef	CONFIG_SYS_SUPPORTS_HUGETLBFS
 	mov	r5, #(domain_val(DOMAIN_USER, DOMAIN_MANAGER) | \
 		      domain_val(DOMAIN_KERNEL, DOMAIN_MANAGER) | \
 		      domain_val(DOMAIN_TABLE, DOMAIN_MANAGER) | \
 		      domain_val(DOMAIN_IO, DOMAIN_CLIENT))
+#else
+	@ set ourselves as the client in all domains
+	@ this allows us to then use the 4 domain bits in the
+	@ section descriptors in our transparent huge pages
+	ldr	r5, =0x55555555
+#endif /* CONFIG_SYS_SUPPORTS_HUGETLBFS */
+
 	mcr	p15, 0, r5, c3, c0, 0		@ load domain access register
 	mcr	p15, 0, r4, c2, c0, 0		@ load page table pointer
-#endif
+#endif /* CONFIG_ARM_LPAE */
 	b	__turn_mmu_on
 ENDPROC(__enable_mmu)
 
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index eb8830a..faae9bd 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -491,19 +491,6 @@ do_translation_fault(unsigned long addr, unsigned int fsr,
 #endif					/* CONFIG_MMU */
 
 /*
- * Some section permission faults need to be handled gracefully.
- * They can happen due to a __{get,put}_user during an oops.
- */
-#ifndef CONFIG_ARM_LPAE
-static int
-do_sect_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
-{
-	do_bad_area(addr, fsr, regs);
-	return 0;
-}
-#endif /* CONFIG_ARM_LPAE */
-
-/*
  * This abort handler always returns "fault".
  */
 static int
diff --git a/arch/arm/mm/fsr-2level.c b/arch/arm/mm/fsr-2level.c
index 18ca74c..c1a2afc 100644
--- a/arch/arm/mm/fsr-2level.c
+++ b/arch/arm/mm/fsr-2level.c
@@ -16,7 +16,7 @@ static struct fsr_info fsr_info[] = {
 	{ do_bad,		SIGBUS,	 0,		"external abort on non-linefetch"  },
 	{ do_bad,		SIGSEGV, SEGV_ACCERR,	"page domain fault"		   },
 	{ do_bad,		SIGBUS,	 0,		"external abort on translation"	   },
-	{ do_sect_fault,	SIGSEGV, SEGV_ACCERR,	"section permission fault"	   },
+	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"section permission fault"	   },
 	{ do_bad,		SIGBUS,	 0,		"external abort on translation"	   },
 	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"page permission fault"		   },
 	/*
@@ -56,7 +56,7 @@ static struct fsr_info ifsr_info[] = {
 	{ do_bad,		SIGBUS,  0,		"unknown 10"			   },
 	{ do_bad,		SIGSEGV, SEGV_ACCERR,	"page domain fault"		   },
 	{ do_bad,		SIGBUS,	 0,		"external abort on translation"	   },
-	{ do_sect_fault,	SIGSEGV, SEGV_ACCERR,	"section permission fault"	   },
+	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"section permission fault"	   },
 	{ do_bad,		SIGBUS,	 0,		"external abort on translation"	   },
 	{ do_page_fault,	SIGSEGV, SEGV_ACCERR,	"page permission fault"		   },
 	{ do_bad,		SIGBUS,  0,		"unknown 16"			   },
diff --git a/arch/arm/mm/hugetlbpage.c b/arch/arm/mm/hugetlbpage.c
index 54ee616..619b082 100644
--- a/arch/arm/mm/hugetlbpage.c
+++ b/arch/arm/mm/hugetlbpage.c
@@ -54,7 +54,7 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 
 int pmd_huge(pmd_t pmd)
 {
-	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
+	return pmd_thp_or_huge(pmd);
 }
 
 int pmd_huge_support(void)
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index b68c6b2..4799864 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -389,6 +389,44 @@ SET_MEMORY_FN(x, pte_set_x)
 SET_MEMORY_FN(nx, pte_set_nx)
 
 /*
+ * If the system supports huge pages and we are running with short descriptors,
+ * then compute the pgprot values for a huge page. We do not need to do this
+ * with LPAE as there is no software/hardware bit distinction for ptes.
+ *
+ * We are only interested in:
+ * 1) The memory type: huge pages are user pages so a section of type
+ *    MT_MEMORY_RW. This is used to create new huge ptes/thps.
+ *
+ * 2) XN, PROT_NONE, WRITE. These are set/unset through protection changes
+ *    by pte_modify or pmd_modify and are used to make new ptes/thps.
+ *
+ * The other bits: dirty, young, splitting are not modified by pte_modify
+ * or pmd_modify nor are they used to create new ptes or pmds thus they are not
+ * considered here.
+ */
+#if defined(CONFIG_SYS_SUPPORTS_HUGETLBFS) && !defined(CONFIG_ARM_LPAE)
+static pgprot_t _hugepgprotval;
+
+pgprot_t get_huge_pgprot(pgprot_t newprot)
+{
+	pte_t inprot = __pte(pgprot_val(newprot));
+	pmd_t pmdret = __pmd(pgprot_val(_hugepgprotval));
+
+	if (!pte_exec(inprot))
+		pmdret = pmd_mknexec(pmdret);
+
+	if (pte_write(inprot))
+		pmdret = pmd_mkwrite(pmdret);
+
+	if (!pte_protnone(inprot))
+		pmdret = pmd_rmprotnone(pmdret);
+
+	return __pgprot(pmd_val(pmdret));
+}
+#endif
+
+
+/*
  * Adjust the PMD section entries according to the CPU in use.
  */
 static void __init build_mem_type_table(void)
@@ -637,6 +675,19 @@ static void __init build_mem_type_table(void)
 		if (t->prot_sect)
 			t->prot_sect |= PMD_DOMAIN(t->domain);
 	}
+
+#if defined(CONFIG_SYS_SUPPORTS_HUGETLBFS) && !defined(CONFIG_ARM_LPAE)
+	/*
+	 * we assume all huge pages are user pages and that hardware access
+	 * flag updates are disabled (which is the case for short descriptors).
+	 */
+	pgprot_val(_hugepgprotval) = mem_types[MT_MEMORY_RW].prot_sect
+					| PMD_SECT_AP_READ | PMD_SECT_nG;
+
+	pgprot_val(_hugepgprotval) &= ~(PMD_SECT_AP_WRITE | PMD_SECT_XN
+					| PMD_TYPE_SECT);
+#endif
+
 }
 
 #ifdef CONFIG_ARM_DMA_MEM_BUFFERABLE
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
