Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE836B0280
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:02:54 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fe3so17917221pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:02:54 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id f63si3702317pfj.137.2016.04.05.14.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:02:53 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id fe3so17917025pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:02:53 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:02:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/10] arch: fix has_transparent_hugepage()
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051355280.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Arnd Bergman <arnd@arndb.de>, Ralf Baechle <ralf@linux-mips.org>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@arm.linux.org.uk>, Will Deacon <will.deacon@arm.com>, Michael Ellerman <mpe@ellerman.id.au>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, David Miller <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

I've just discovered that the useful-sounding has_transparent_hugepage()
is actually an architecture-dependent minefield: on some arches it only
builds if CONFIG_TRANSPARENT_HUGEPAGE=y, on others it's also there when
not, but on some of those (arm and arm64) it then gives the wrong answer;
and on mips alone it's marked __init, which would crash if called later
(but so far it has not been called later).

Straighten this out: make it available to all configs, with a sensible
default in asm-generic/pgtable.h, removing its definitions from those
arches (arc, arm, arm64, sparc, tile) which are served by the default,
adding #define has_transparent_hugepage has_transparent_hugepage to those
(mips, powerpc, s390, x86) which need to override the default at runtime,
and removing the __init from mips (but maybe that kind of code should be
avoided after init: set a static variable the first time it's called).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/arc/include/asm/hugepage.h              |    2 -
 arch/arm/include/asm/pgtable-3level.h        |    5 ----
 arch/arm64/include/asm/pgtable.h             |    5 ----
 arch/mips/include/asm/pgtable.h              |    1 
 arch/mips/mm/tlb-r4k.c                       |   21 ++++++++---------
 arch/powerpc/include/asm/book3s/64/pgtable.h |    1 
 arch/powerpc/include/asm/pgtable.h           |    1 
 arch/s390/include/asm/pgtable.h              |    1 
 arch/sparc/include/asm/pgtable_64.h          |    2 -
 arch/tile/include/asm/pgtable.h              |    1 
 arch/x86/include/asm/pgtable.h               |    1 
 include/asm-generic/pgtable.h                |    8 ++++++
 12 files changed, 23 insertions(+), 26 deletions(-)

--- a/arch/arc/include/asm/hugepage.h
+++ b/arch/arc/include/asm/hugepage.h
@@ -61,8 +61,6 @@ static inline void set_pmd_at(struct mm_
 extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 				 pmd_t *pmd);
 
-#define has_transparent_hugepage() 1
-
 /* Generic variants assume pgtable_t is struct page *, hence need for these */
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -281,11 +281,6 @@ static inline void set_pmd_at(struct mm_
 	flush_pmd_entry(pmdp);
 }
 
-static inline int has_transparent_hugepage(void)
-{
-	return 1;
-}
-
 #endif /* __ASSEMBLY__ */
 
 #endif /* _ASM_PGTABLE_3LEVEL_H */
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -304,11 +304,6 @@ static inline pgprot_t mk_sect_prot(pgpr
 
 #define set_pmd_at(mm, addr, pmdp, pmd)	set_pte_at(mm, addr, (pte_t *)pmdp, pmd_pte(pmd))
 
-static inline int has_transparent_hugepage(void)
-{
-	return 1;
-}
-
 #define __pgprot_modify(prot,mask,bits) \
 	__pgprot((pgprot_val(prot) & ~(mask)) | (bits))
 
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -468,6 +468,7 @@ static inline int io_remap_pfn_range(str
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
+#define has_transparent_hugepage has_transparent_hugepage
 extern int has_transparent_hugepage(void);
 
 static inline int pmd_trans_huge(pmd_t pmd)
--- a/arch/mips/mm/tlb-r4k.c
+++ b/arch/mips/mm/tlb-r4k.c
@@ -399,19 +399,20 @@ void add_wired_entry(unsigned long entry
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-int __init has_transparent_hugepage(void)
+int has_transparent_hugepage(void)
 {
-	unsigned int mask;
-	unsigned long flags;
+	static unsigned int mask = -1;
 
-	local_irq_save(flags);
-	write_c0_pagemask(PM_HUGE_MASK);
-	back_to_back_c0_hazard();
-	mask = read_c0_pagemask();
-	write_c0_pagemask(PM_DEFAULT_MASK);
-
-	local_irq_restore(flags);
+	if (mask == -1) {	/* first call comes during __init */
+		unsigned long flags;
 
+		local_irq_save(flags);
+		write_c0_pagemask(PM_HUGE_MASK);
+		back_to_back_c0_hazard();
+		mask = read_c0_pagemask();
+		write_c0_pagemask(PM_DEFAULT_MASK);
+		local_irq_restore(flags);
+	}
 	return mask == PM_HUGE_MASK;
 }
 
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -219,6 +219,7 @@ extern void set_pmd_at(struct mm_struct
 		       pmd_t *pmdp, pmd_t pmd);
 extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 				 pmd_t *pmd);
+#define has_transparent_hugepage has_transparent_hugepage
 extern int has_transparent_hugepage(void);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -65,7 +65,6 @@ extern int gup_hugepte(pte_t *ptep, unsi
 		       struct page **pages, int *nr);
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_large(pmd)		0
-#define has_transparent_hugepage() 0
 #endif
 pte_t *__find_linux_pte_or_hugepte(pgd_t *pgdir, unsigned long ea,
 				   bool *is_thp, unsigned *shift);
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1223,6 +1223,7 @@ static inline int pmd_trans_huge(pmd_t p
 	return pmd_val(pmd) & _SEGMENT_ENTRY_LARGE;
 }
 
+#define has_transparent_hugepage has_transparent_hugepage
 static inline int has_transparent_hugepage(void)
 {
 	return MACHINE_HAS_HPAGE ? 1 : 0;
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -681,8 +681,6 @@ static inline unsigned long pmd_trans_hu
 	return pte_val(pte) & _PAGE_PMD_HUGE;
 }
 
-#define has_transparent_hugepage() 1
-
 static inline pmd_t pmd_mkold(pmd_t pmd)
 {
 	pte_t pte = __pte(pmd_val(pmd));
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -487,7 +487,6 @@ static inline pmd_t pmd_modify(pmd_t pmd
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-#define has_transparent_hugepage() 1
 #define pmd_trans_huge pmd_huge_page
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -181,6 +181,7 @@ static inline int pmd_trans_huge(pmd_t p
 	return (pmd_val(pmd) & (_PAGE_PSE|_PAGE_DEVMAP)) == _PAGE_PSE;
 }
 
+#define has_transparent_hugepage has_transparent_hugepage
 static inline int has_transparent_hugepage(void)
 {
 	return cpu_has_pse;
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -806,4 +806,12 @@ static inline int pmd_clear_huge(pmd_t *
 #define io_remap_pfn_range remap_pfn_range
 #endif
 
+#ifndef has_transparent_hugepage
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define has_transparent_hugepage() 1
+#else
+#define has_transparent_hugepage() 0
+#endif
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
