Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AE690900015
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:57:17 -0500 (EST)
Received: by pdjy10 with SMTP id y10so15195873pdj.7
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:57:17 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fh3si10492894pbb.187.2015.02.06.06.51.18
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:19 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 17/19] x86: expose number of page table levels on Kconfig level
Date: Fri,  6 Feb 2015 16:51:02 +0200
Message-Id: <1423234264-197684-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---

I've implemented accounting for pmd page tables as we have for pte (see
mm->nr_ptes). It's requires a new counter in mm_struct: mm->nr_pmds.

But the feature doesn't make any sense if an architecture has PMD level
folded and it would be nice get rid of the counter in this case.

The problem is that we cannot use __PAGETABLE_PMD_FOLDED in
<linux/mm_types.h> due to circular dependencies:

<linux/mm_types> -> <asm/pgtable.h> -> <linux/mm_types.h>

In most cases <asm/pgtable.h> wants <linux/mm_types.h> to get definition
of struct page and struct vm_area_struct. I've tried to split mm_struct
into separate header file to be able to user <asm/pgtable.h> there.

But it doesn't fly on some architectures, like ARM: it wants mm_struct
<asm/pgtable.h> to implement tlb flushing. I don't see how to fix it without
massive de-inlining or coverting a lot for inline functions to macros.

This is other approach: expose number of page tables in use via Kconfig
and use it in <linux/mm_types.h> instead of __PAGETABLE_PMD_FOLDED from
<asm/pgtable.h>.

---
 arch/x86/Kconfig                            |  6 ++++++
 arch/x86/include/asm/paravirt.h             |  8 ++++----
 arch/x86/include/asm/paravirt_types.h       |  8 ++++----
 arch/x86/include/asm/pgalloc.h              |  8 ++++----
 arch/x86/include/asm/pgtable-2level_types.h |  1 -
 arch/x86/include/asm/pgtable-3level_types.h |  2 --
 arch/x86/include/asm/pgtable.h              |  8 ++++----
 arch/x86/include/asm/pgtable_64_types.h     |  1 -
 arch/x86/include/asm/pgtable_types.h        |  4 ++--
 arch/x86/kernel/paravirt.c                  |  6 +++---
 arch/x86/mm/pgtable.c                       | 14 +++++++-------
 arch/x86/xen/mmu.c                          | 14 +++++++-------
 include/trace/events/xen.h                  |  2 +-
 13 files changed, 42 insertions(+), 40 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e5c87b21658e..d4327c71d64f 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -279,6 +279,12 @@ config ARCH_SUPPORTS_UPROBES
 config FIX_EARLYCON_MEM
 	def_bool y
 
+config PGTABLE_LEVELS
+	int
+	default 4 if X86_64
+	default 3 if X86_PAE
+	default 2
+
 source "init/Kconfig"
 source "kernel/Kconfig.freezer"
 
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 32444ae939ca..7ced2aaab829 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -545,7 +545,7 @@ static inline void set_pmd(pmd_t *pmdp, pmd_t pmd)
 		PVOP_VCALL2(pv_mmu_ops.set_pmd, pmdp, val);
 }
 
-#if PAGETABLE_LEVELS >= 3
+#if CONFIG_PGTABLE_LEVELS >= 3
 static inline pmd_t __pmd(pmdval_t val)
 {
 	pmdval_t ret;
@@ -585,7 +585,7 @@ static inline void set_pud(pud_t *pudp, pud_t pud)
 		PVOP_VCALL2(pv_mmu_ops.set_pud, pudp,
 			    val);
 }
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 static inline pud_t __pud(pudval_t val)
 {
 	pudval_t ret;
@@ -636,9 +636,9 @@ static inline void pud_clear(pud_t *pudp)
 	set_pud(pudp, __pud(0));
 }
 
-#endif	/* PAGETABLE_LEVELS == 4 */
+#endif	/* CONFIG_PGTABLE_LEVELS == 4 */
 
-#endif	/* PAGETABLE_LEVELS >= 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS >= 3 */
 
 #ifdef CONFIG_X86_PAE
 /* Special-case pte-setting operations for PAE, which can't update a
diff --git a/arch/x86/include/asm/paravirt_types.h b/arch/x86/include/asm/paravirt_types.h
index 7549b8b369e4..f7b0b5c112f2 100644
--- a/arch/x86/include/asm/paravirt_types.h
+++ b/arch/x86/include/asm/paravirt_types.h
@@ -294,7 +294,7 @@ struct pv_mmu_ops {
 	struct paravirt_callee_save pgd_val;
 	struct paravirt_callee_save make_pgd;
 
-#if PAGETABLE_LEVELS >= 3
+#if CONFIG_PGTABLE_LEVELS >= 3
 #ifdef CONFIG_X86_PAE
 	void (*set_pte_atomic)(pte_t *ptep, pte_t pteval);
 	void (*pte_clear)(struct mm_struct *mm, unsigned long addr,
@@ -308,13 +308,13 @@ struct pv_mmu_ops {
 	struct paravirt_callee_save pmd_val;
 	struct paravirt_callee_save make_pmd;
 
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 	struct paravirt_callee_save pud_val;
 	struct paravirt_callee_save make_pud;
 
 	void (*set_pgd)(pgd_t *pudp, pgd_t pgdval);
-#endif	/* PAGETABLE_LEVELS == 4 */
-#endif	/* PAGETABLE_LEVELS >= 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS == 4 */
+#endif	/* CONFIG_PGTABLE_LEVELS >= 3 */
 
 	struct pv_lazy_ops lazy_mode;
 
diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index c4412e972bbd..bf7f8b55b0f9 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -77,7 +77,7 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
-#if PAGETABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	struct page *page;
@@ -116,7 +116,7 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 }
 #endif	/* CONFIG_X86_PAE */
 
-#if PAGETABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 {
 	paravirt_alloc_pud(mm, __pa(pud) >> PAGE_SHIFT);
@@ -142,7 +142,7 @@ static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 	___pud_free_tlb(tlb, pud);
 }
 
-#endif	/* PAGETABLE_LEVELS > 3 */
-#endif	/* PAGETABLE_LEVELS > 2 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
 #endif /* _ASM_X86_PGALLOC_H */
diff --git a/arch/x86/include/asm/pgtable-2level_types.h b/arch/x86/include/asm/pgtable-2level_types.h
index daacc23e3fb9..392576433e77 100644
--- a/arch/x86/include/asm/pgtable-2level_types.h
+++ b/arch/x86/include/asm/pgtable-2level_types.h
@@ -17,7 +17,6 @@ typedef union {
 #endif	/* !__ASSEMBLY__ */
 
 #define SHARED_KERNEL_PMD	0
-#define PAGETABLE_LEVELS	2
 
 /*
  * traditional i386 two-level paging structure:
diff --git a/arch/x86/include/asm/pgtable-3level_types.h b/arch/x86/include/asm/pgtable-3level_types.h
index 1bd5876c8649..bcc89625ebe5 100644
--- a/arch/x86/include/asm/pgtable-3level_types.h
+++ b/arch/x86/include/asm/pgtable-3level_types.h
@@ -24,8 +24,6 @@ typedef union {
 #define SHARED_KERNEL_PMD	1
 #endif
 
-#define PAGETABLE_LEVELS	3
-
 /*
  * PGDIR_SHIFT determines what a top-level page table entry can map
  */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 9d0ade00923e..f89d6c9943ea 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -554,7 +554,7 @@ static inline unsigned long pages_to_mb(unsigned long npg)
 	return npg >> (20 - PAGE_SHIFT);
 }
 
-#if PAGETABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 static inline int pud_none(pud_t pud)
 {
 	return native_pud_val(pud) == 0;
@@ -597,9 +597,9 @@ static inline int pud_large(pud_t pud)
 {
 	return 0;
 }
-#endif	/* PAGETABLE_LEVELS > 2 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
-#if PAGETABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 static inline int pgd_present(pgd_t pgd)
 {
 	return pgd_flags(pgd) & _PAGE_PRESENT;
@@ -636,7 +636,7 @@ static inline int pgd_none(pgd_t pgd)
 {
 	return !native_pgd_val(pgd);
 }
-#endif	/* PAGETABLE_LEVELS > 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 3 */
 
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 602b6028c5b6..e6844dfb4471 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -20,7 +20,6 @@ typedef struct { pteval_t pte; } pte_t;
 #endif	/* !__ASSEMBLY__ */
 
 #define SHARED_KERNEL_PMD	0
-#define PAGETABLE_LEVELS	4
 
 /*
  * PGDIR_SHIFT determines what a top-level page table entry can map
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 8c7c10802e9c..78f0c8cbe316 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -234,7 +234,7 @@ static inline pgdval_t pgd_flags(pgd_t pgd)
 	return native_pgd_val(pgd) & PTE_FLAGS_MASK;
 }
 
-#if PAGETABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 typedef struct { pudval_t pud; } pud_t;
 
 static inline pud_t native_make_pud(pmdval_t val)
@@ -255,7 +255,7 @@ static inline pudval_t native_pud_val(pud_t pud)
 }
 #endif
 
-#if PAGETABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 typedef struct { pmdval_t pmd; } pmd_t;
 
 static inline pmd_t native_make_pmd(pmdval_t val)
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index 548d25f00c90..c614dd492f5f 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -443,7 +443,7 @@ struct pv_mmu_ops pv_mmu_ops = {
 	.ptep_modify_prot_start = __ptep_modify_prot_start,
 	.ptep_modify_prot_commit = __ptep_modify_prot_commit,
 
-#if PAGETABLE_LEVELS >= 3
+#if CONFIG_PGTABLE_LEVELS >= 3
 #ifdef CONFIG_X86_PAE
 	.set_pte_atomic = native_set_pte_atomic,
 	.pte_clear = native_pte_clear,
@@ -454,13 +454,13 @@ struct pv_mmu_ops pv_mmu_ops = {
 	.pmd_val = PTE_IDENT,
 	.make_pmd = PTE_IDENT,
 
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 	.pud_val = PTE_IDENT,
 	.make_pud = PTE_IDENT,
 
 	.set_pgd = native_set_pgd,
 #endif
-#endif /* PAGETABLE_LEVELS >= 3 */
+#endif /* CONFIG_PGTABLE_LEVELS >= 3 */
 
 	.pte_val = PTE_IDENT,
 	.pgd_val = PTE_IDENT,
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 7b22adaad4f1..9885592b9fa7 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -58,7 +58,7 @@ void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
 	tlb_remove_page(tlb, pte);
 }
 
-#if PAGETABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 {
 	struct page *page = virt_to_page(pmd);
@@ -74,14 +74,14 @@ void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 	tlb_remove_page(tlb, page);
 }
 
-#if PAGETABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 void ___pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 {
 	paravirt_release_pud(__pa(pud) >> PAGE_SHIFT);
 	tlb_remove_page(tlb, virt_to_page(pud));
 }
-#endif	/* PAGETABLE_LEVELS > 3 */
-#endif	/* PAGETABLE_LEVELS > 2 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
 static inline void pgd_list_add(pgd_t *pgd)
 {
@@ -117,9 +117,9 @@ static void pgd_ctor(struct mm_struct *mm, pgd_t *pgd)
 	/* If the pgd points to a shared pagetable level (either the
 	   ptes in non-PAE, or shared PMD in PAE), then just copy the
 	   references from swapper_pg_dir. */
-	if (PAGETABLE_LEVELS == 2 ||
-	    (PAGETABLE_LEVELS == 3 && SHARED_KERNEL_PMD) ||
-	    PAGETABLE_LEVELS == 4) {
+	if (CONFIG_PGTABLE_LEVELS == 2 ||
+	    (CONFIG_PGTABLE_LEVELS == 3 && SHARED_KERNEL_PMD) ||
+	    CONFIG_PGTABLE_LEVELS == 4) {
 		clone_pgd_range(pgd + KERNEL_PGD_BOUNDARY,
 				swapper_pg_dir + KERNEL_PGD_BOUNDARY,
 				KERNEL_PGD_PTRS);
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index adca9e2b6553..65083ad63b6f 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -502,7 +502,7 @@ __visible pmd_t xen_make_pmd(pmdval_t pmd)
 }
 PV_CALLEE_SAVE_REGS_THUNK(xen_make_pmd);
 
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 __visible pudval_t xen_pud_val(pud_t pud)
 {
 	return pte_mfn_to_pfn(pud.pud);
@@ -589,7 +589,7 @@ static void xen_set_pgd(pgd_t *ptr, pgd_t val)
 
 	xen_mc_issue(PARAVIRT_LAZY_MMU);
 }
-#endif	/* PAGETABLE_LEVELS == 4 */
+#endif	/* CONFIG_PGTABLE_LEVELS == 4 */
 
 /*
  * (Yet another) pagetable walker.  This one is intended for pinning a
@@ -1628,7 +1628,7 @@ static void xen_release_pmd(unsigned long pfn)
 	xen_release_ptpage(pfn, PT_PMD);
 }
 
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 static void xen_alloc_pud(struct mm_struct *mm, unsigned long pfn)
 {
 	xen_alloc_ptpage(mm, pfn, PT_PUD);
@@ -2046,7 +2046,7 @@ static void __init xen_post_allocator_init(void)
 	pv_mmu_ops.set_pte = xen_set_pte;
 	pv_mmu_ops.set_pmd = xen_set_pmd;
 	pv_mmu_ops.set_pud = xen_set_pud;
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 	pv_mmu_ops.set_pgd = xen_set_pgd;
 #endif
 
@@ -2056,7 +2056,7 @@ static void __init xen_post_allocator_init(void)
 	pv_mmu_ops.alloc_pmd = xen_alloc_pmd;
 	pv_mmu_ops.release_pte = xen_release_pte;
 	pv_mmu_ops.release_pmd = xen_release_pmd;
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 	pv_mmu_ops.alloc_pud = xen_alloc_pud;
 	pv_mmu_ops.release_pud = xen_release_pud;
 #endif
@@ -2122,14 +2122,14 @@ static const struct pv_mmu_ops xen_mmu_ops __initconst = {
 	.make_pmd = PV_CALLEE_SAVE(xen_make_pmd),
 	.pmd_val = PV_CALLEE_SAVE(xen_pmd_val),
 
-#if PAGETABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS == 4
 	.pud_val = PV_CALLEE_SAVE(xen_pud_val),
 	.make_pud = PV_CALLEE_SAVE(xen_make_pud),
 	.set_pgd = xen_set_pgd_hyper,
 
 	.alloc_pud = xen_alloc_pmd_init,
 	.release_pud = xen_release_pmd_init,
-#endif	/* PAGETABLE_LEVELS == 4 */
+#endif	/* CONFIG_PGTABLE_LEVELS == 4 */
 
 	.activate_mm = xen_activate_mm,
 	.dup_mmap = xen_dup_mmap,
diff --git a/include/trace/events/xen.h b/include/trace/events/xen.h
index d06b6da5c1e3..bce990f5a35d 100644
--- a/include/trace/events/xen.h
+++ b/include/trace/events/xen.h
@@ -224,7 +224,7 @@ TRACE_EVENT(xen_mmu_pmd_clear,
 	    TP_printk("pmdp %p", __entry->pmdp)
 	);
 
-#if PAGETABLE_LEVELS >= 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 
 TRACE_EVENT(xen_mmu_set_pud,
 	    TP_PROTO(pud_t *pudp, pud_t pudval),
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
