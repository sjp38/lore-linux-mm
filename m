Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B5ED76B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:04:21 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so19123407pab.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:04:21 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id fm4si2521943pab.148.2015.08.27.02.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 02:04:20 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 04/11] ARCv2: mm: THP support
Date: Thu, 27 Aug 2015 14:33:07 +0530
Message-ID: <1440666194-21478-5-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com, Vineet Gupta <Vineet.Gupta1@synopsys.com>

ARC Linux implements 2 level page walk: PGD:PTE
In THP regime, PTE is folded into PGD (and canonically referred to as PMD)
Thus thp PMD accessors are implemented in terms of PTE (just like sparc)

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/Kconfig                |  4 +++
 arch/arc/include/asm/hugepage.h | 78 +++++++++++++++++++++++++++++++++++++++++
 arch/arc/include/asm/page.h     |  1 +
 arch/arc/include/asm/pgtable.h  | 16 +++++++--
 arch/arc/mm/tlb.c               | 51 +++++++++++++++++++++++++++
 arch/arc/mm/tlbex.S             | 19 +++++++---
 6 files changed, 163 insertions(+), 6 deletions(-)
 create mode 100644 arch/arc/include/asm/hugepage.h

diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index 78c0621d5819..5912006391ed 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -76,6 +76,10 @@ config STACKTRACE_SUPPORT
 config HAVE_LATENCYTOP_SUPPORT
 	def_bool y
 
+config HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	def_bool y
+	depends on ARC_MMU_V4
+
 source "init/Kconfig"
 source "kernel/Kconfig.freezer"
 
diff --git a/arch/arc/include/asm/hugepage.h b/arch/arc/include/asm/hugepage.h
new file mode 100644
index 000000000000..d7614d2af454
--- /dev/null
+++ b/arch/arc/include/asm/hugepage.h
@@ -0,0 +1,78 @@
+/*
+ * Copyright (C) 2013-15 Synopsys, Inc. (www.synopsys.com)
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+
+#ifndef _ASM_ARC_HUGEPAGE_H
+#define _ASM_ARC_HUGEPAGE_H
+
+#include <linux/types.h>
+#include <asm-generic/pgtable-nopmd.h>
+
+/*
+ * ARC Linux implements 2 level page walk: PGD:PTE
+ * In THP regime, PTE is folded into PGD (and canonically referred to as PMD)
+ * Thus thp PMD accessors are implemented in terms of PTE (just like sparc)
+ */
+static inline pte_t pmd_pte(pmd_t pmd)
+{
+	return __pte(pmd_val(pmd));
+}
+
+static inline pmd_t pte_pmd(pte_t pte)
+{
+	return __pmd(pte_val(pte));
+}
+
+#define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
+#define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
+#define pmd_mkdirty(pmd)	pte_pmd(pte_mkdirty(pmd_pte(pmd)))
+#define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
+#define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
+#define pmd_mkhuge(pmd)		pte_pmd(pte_mkhuge(pmd_pte(pmd)))
+#define pmd_mknotpresent(pmd)	pte_pmd(pte_mknotpresent(pmd_pte(pmd)))
+#define pmd_mksplitting(pmd)	pte_pmd(pte_mkspecial(pmd_pte(pmd)))
+#define pmd_mkclean(pmd)	pte_pmd(pte_mkclean(pmd_pte(pmd)))
+
+#define pmd_write(pmd)		pte_write(pmd_pte(pmd))
+#define pmd_young(pmd)		pte_young(pmd_pte(pmd))
+#define pmd_pfn(pmd)		pte_pfn(pmd_pte(pmd))
+#define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
+#define pmd_special(pmd)	pte_special(pmd_pte(pmd))
+
+#define mk_pmd(page, prot)	pte_pmd(mk_pte(page, prot))
+
+#define pmd_trans_huge(pmd)	(pmd_val(pmd) & _PAGE_HW_SZ)
+#define pmd_trans_splitting(pmd)	(pmd_trans_huge(pmd) && pmd_special(pmd))
+
+#define pfn_pmd(pfn, prot)	(__pmd(((pfn) << PAGE_SHIFT) | pgprot_val(prot)))
+
+static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
+{
+	return pte_pmd(pte_modify(pmd_pte(pmd), newprot));
+}
+
+static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
+			      pmd_t *pmdp, pmd_t pmd)
+{
+	*pmdp = pmd;
+}
+
+extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
+				 pmd_t *pmd);
+
+#define has_transparent_hugepage() 1
+
+/* Generic variants assume pgtable_t is struct page *, hence need for these */
+#define __HAVE_ARCH_PGTABLE_DEPOSIT
+extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				       pgtable_t pgtable);
+
+#define __HAVE_ARCH_PGTABLE_WITHDRAW
+extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
+
+#endif
diff --git a/arch/arc/include/asm/page.h b/arch/arc/include/asm/page.h
index 9c8aa41e45c2..e15ccc7940ea 100644
--- a/arch/arc/include/asm/page.h
+++ b/arch/arc/include/asm/page.h
@@ -66,6 +66,7 @@ typedef unsigned long pgtable_t;
 #define pgd_val(x)	(x)
 #define pgprot_val(x)	(x)
 #define __pte(x)	(x)
+#define __pgd(x)	(x)
 #define __pgprot(x)	(x)
 #define pte_pgprot(x)	(x)
 
diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 431a83329324..336267f2e9d9 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -83,11 +83,13 @@
 #define _PAGE_PRESENT       (1<<9)	/* TLB entry is valid (H) */
 
 #if (CONFIG_ARC_MMU_VER >= 4)
-#define _PAGE_SZ            (1<<10)	/* Page Size indicator (H) */
+#define _PAGE_HW_SZ         (1<<10)	/* Page Size indicator (H): 0 normal, 1 super */
 #endif
 
 #define _PAGE_SHARED_CODE   (1<<11)	/* Shared Code page with cmn vaddr
 					   usable for shared TLB entries (H) */
+
+#define _PAGE_UNUSED_BIT    (1<<12)
 #endif
 
 /* vmalloc permissions */
@@ -99,6 +101,10 @@
 #define _PAGE_CACHEABLE 0
 #endif
 
+#ifndef _PAGE_HW_SZ
+#define _PAGE_HW_SZ	0
+#endif
+
 /* Defaults for every user page */
 #define ___DEF (_PAGE_PRESENT | _PAGE_CACHEABLE)
 
@@ -125,7 +131,7 @@
 #define PAGE_KERNEL_NO_CACHE __pgprot(_K_PAGE_PERMS)
 
 /* Masks for actual TLB "PD"s */
-#define PTE_BITS_IN_PD0		(_PAGE_GLOBAL | _PAGE_PRESENT)
+#define PTE_BITS_IN_PD0		(_PAGE_GLOBAL | _PAGE_PRESENT | _PAGE_HW_SZ)
 #define PTE_BITS_RWX		(_PAGE_EXECUTE | _PAGE_WRITE | _PAGE_READ)
 #define PTE_BITS_NON_RWX_IN_PD1	(PAGE_MASK | _PAGE_CACHEABLE)
 
@@ -299,6 +305,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define PTE_BIT_FUNC(fn, op) \
 	static inline pte_t pte_##fn(pte_t pte) { pte_val(pte) op; return pte; }
 
+PTE_BIT_FUNC(mknotpresent,	&= ~(_PAGE_PRESENT));
 PTE_BIT_FUNC(wrprotect,	&= ~(_PAGE_WRITE));
 PTE_BIT_FUNC(mkwrite,	|= (_PAGE_WRITE));
 PTE_BIT_FUNC(mkclean,	&= ~(_PAGE_DIRTY));
@@ -308,6 +315,7 @@ PTE_BIT_FUNC(mkyoung,	|= (_PAGE_ACCESSED));
 PTE_BIT_FUNC(exprotect,	&= ~(_PAGE_EXECUTE));
 PTE_BIT_FUNC(mkexec,	|= (_PAGE_EXECUTE));
 PTE_BIT_FUNC(mkspecial,	|= (_PAGE_SPECIAL));
+PTE_BIT_FUNC(mkhuge,	|= (_PAGE_HW_SZ));
 
 #define __HAVE_ARCH_PTE_SPECIAL
 
@@ -381,6 +389,10 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
  * remap a physical page `pfn' of size `size' with page protection `prot'
  * into virtual address `from'
  */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#include <asm/hugepage.h>
+#endif
+
 #include <asm-generic/pgtable.h>
 
 /* to cope with aliasing VIPT cache */
diff --git a/arch/arc/mm/tlb.c b/arch/arc/mm/tlb.c
index 2c7ce8bb7475..337eebf0d6cf 100644
--- a/arch/arc/mm/tlb.c
+++ b/arch/arc/mm/tlb.c
@@ -580,6 +580,57 @@ void update_mmu_cache(struct vm_area_struct *vma, unsigned long vaddr_unaligned,
 	}
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
+void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
+				 pmd_t *pmd)
+{
+	pte_t pte = __pte(pmd_val(*pmd));
+	update_mmu_cache(vma, addr, &pte);
+}
+
+void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
+				pgtable_t pgtable)
+{
+	struct list_head *lh = (struct list_head *) pgtable;
+
+	assert_spin_locked(&mm->page_table_lock);
+
+	/* FIFO */
+	if (!pmd_huge_pte(mm, pmdp))
+		INIT_LIST_HEAD(lh);
+	else
+		list_add(lh, (struct list_head *) pmd_huge_pte(mm, pmdp));
+	pmd_huge_pte(mm, pmdp) = pgtable;
+}
+
+pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
+{
+	struct list_head *lh;
+	pgtable_t pgtable;
+	pte_t *ptep;
+
+	assert_spin_locked(&mm->page_table_lock);
+
+	pgtable = pmd_huge_pte(mm, pmdp);
+	lh = (struct list_head *) pgtable;
+	if (list_empty(lh))
+		pmd_huge_pte(mm, pmdp) = (pgtable_t) NULL;
+	else {
+		pmd_huge_pte(mm, pmdp) = (pgtable_t) lh->next;
+		list_del(lh);
+	}
+
+	ptep = (pte_t *) pgtable;
+	pte_val(*ptep) = 0;
+	ptep++;
+	pte_val(*ptep) = 0;
+
+	return pgtable;
+}
+
+#endif
+
 /* Read the Cache Build Confuration Registers, Decode them and save into
  * the cpuinfo structure for later use.
  * No Validation is done here, simply read/convert the BCRs
diff --git a/arch/arc/mm/tlbex.S b/arch/arc/mm/tlbex.S
index b8b014c6904d..552594897655 100644
--- a/arch/arc/mm/tlbex.S
+++ b/arch/arc/mm/tlbex.S
@@ -205,10 +205,18 @@ ex_saved_reg1:
 #endif
 
 	lsr     r0, r2, PGDIR_SHIFT     ; Bits for indexing into PGD
-	ld.as   r1, [r1, r0]            ; PGD entry corresp to faulting addr
-	and.f   r1, r1, PAGE_MASK       ; Ignoring protection and other flags
-	;   contains Ptr to Page Table
-	bz.d    do_slow_path_pf         ; if no Page Table, do page fault
+	ld.as   r3, [r1, r0]            ; PGD entry corresp to faulting addr
+	tst	r3, r3
+	bz	do_slow_path_pf         ; if no Page Table, do page fault
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	and.f	0, r3, _PAGE_HW_SZ	; Is this Huge PMD (thp)
+	add2.nz	r1, r1, r0
+	bnz.d	2f		; YES: PGD == PMD has THP PTE: stop pgd walk
+	mov.nz	r0, r3
+
+#endif
+	and	r1, r3, PAGE_MASK
 
 	; Get the PTE entry: The idea is
 	; (1) x = addr >> PAGE_SHIFT 	-> masks page-off bits from @fault-addr
@@ -219,6 +227,9 @@ ex_saved_reg1:
 	lsr     r0, r2, (PAGE_SHIFT - 2)
 	and     r0, r0, ( (PTRS_PER_PTE - 1) << 2)
 	ld.aw   r0, [r1, r0]            ; get PTE and PTE ptr for fault addr
+
+2:
+
 #ifdef CONFIG_ARC_DBG_TLB_MISS_COUNT
 	and.f 0, r0, _PAGE_PRESENT
 	bz   1f
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
