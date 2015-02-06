Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 23F756B006E
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:51:17 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lf10so10167163pab.12
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:51:16 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id nk3si10543661pdb.169.2015.02.06.06.51.13
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:14 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 02/19] arm64: expose number of page table levels on Kconfig level
Date: Fri,  6 Feb 2015 16:50:47 +0200
Message-Id: <1423234264-197684-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

ARM64_PGTABLE_LEVELS is renamed to PGTABLE_LEVELS and defined before
sourcing init/Kconfig: arch/Kconfig will define default value and it's
sourced from init/Kconfig.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
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
 arch/arm64/Kconfig                     | 14 +++++++-------
 arch/arm64/include/asm/kvm_mmu.h       |  4 ++--
 arch/arm64/include/asm/page.h          |  4 ++--
 arch/arm64/include/asm/pgalloc.h       |  8 ++++----
 arch/arm64/include/asm/pgtable-hwdef.h |  6 +++---
 arch/arm64/include/asm/pgtable-types.h | 12 ++++++------
 arch/arm64/include/asm/pgtable.h       |  8 ++++----
 arch/arm64/include/asm/tlb.h           |  4 ++--
 arch/arm64/mm/mmu.c                    |  4 ++--
 9 files changed, 32 insertions(+), 32 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 1b8e97331ffb..3f2fba996bc2 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -143,6 +143,13 @@ config KERNEL_MODE_NEON
 config FIX_EARLYCON_MEM
 	def_bool y
 
+config PGTABLE_LEVELS
+	int
+	default 2 if ARM64_64K_PAGES && ARM64_VA_BITS_42
+	default 3 if ARM64_64K_PAGES && ARM64_VA_BITS_48
+	default 3 if ARM64_4K_PAGES && ARM64_VA_BITS_39
+	default 4 if ARM64_4K_PAGES && ARM64_VA_BITS_48
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
@@ -413,13 +420,6 @@ config ARM64_VA_BITS
 	default 42 if ARM64_VA_BITS_42
 	default 48 if ARM64_VA_BITS_48
 
-config ARM64_PGTABLE_LEVELS
-	int
-	default 2 if ARM64_64K_PAGES && ARM64_VA_BITS_42
-	default 3 if ARM64_64K_PAGES && ARM64_VA_BITS_48
-	default 3 if ARM64_4K_PAGES && ARM64_VA_BITS_39
-	default 4 if ARM64_4K_PAGES && ARM64_VA_BITS_48
-
 config CPU_BIG_ENDIAN
        bool "Build big-endian kernel"
        help
diff --git a/arch/arm64/include/asm/kvm_mmu.h b/arch/arm64/include/asm/kvm_mmu.h
index 6458b5373142..19660692efec 100644
--- a/arch/arm64/include/asm/kvm_mmu.h
+++ b/arch/arm64/include/asm/kvm_mmu.h
@@ -161,12 +161,12 @@ static inline bool kvm_s2pmd_readonly(pmd_t *pmd)
 /*
  * If we are concatenating first level stage-2 page tables, we would have less
  * than or equal to 16 pointers in the fake PGD, because that's what the
- * architecture allows.  In this case, (4 - CONFIG_ARM64_PGTABLE_LEVELS)
+ * architecture allows.  In this case, (4 - CONFIG_PGTABLE_LEVELS)
  * represents the first level for the host, and we add 1 to go to the next
  * level (which uses contatenation) for the stage-2 tables.
  */
 #if PTRS_PER_S2_PGD <= 16
-#define KVM_PREALLOC_LEVEL	(4 - CONFIG_ARM64_PGTABLE_LEVELS + 1)
+#define KVM_PREALLOC_LEVEL	(4 - CONFIG_PGTABLE_LEVELS + 1)
 #else
 #define KVM_PREALLOC_LEVEL	(0)
 #endif
diff --git a/arch/arm64/include/asm/page.h b/arch/arm64/include/asm/page.h
index 22b16232bd60..8fc8fa280e92 100644
--- a/arch/arm64/include/asm/page.h
+++ b/arch/arm64/include/asm/page.h
@@ -36,9 +36,9 @@
  * for more information).
  */
 #ifdef CONFIG_ARM64_64K_PAGES
-#define SWAPPER_PGTABLE_LEVELS	(CONFIG_ARM64_PGTABLE_LEVELS)
+#define SWAPPER_PGTABLE_LEVELS	(CONFIG_PGTABLE_LEVELS)
 #else
-#define SWAPPER_PGTABLE_LEVELS	(CONFIG_ARM64_PGTABLE_LEVELS - 1)
+#define SWAPPER_PGTABLE_LEVELS	(CONFIG_PGTABLE_LEVELS - 1)
 #endif
 
 #define SWAPPER_DIR_SIZE	(SWAPPER_PGTABLE_LEVELS * PAGE_SIZE)
diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index e20df38a8ff3..76420568d66a 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -28,7 +28,7 @@
 
 #define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
@@ -46,9 +46,9 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 	set_pud(pud, __pud(__pa(pmd) | PMD_TYPE_TABLE));
 }
 
-#endif	/* CONFIG_ARM64_PGTABLE_LEVELS > 2 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
@@ -66,7 +66,7 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 	set_pgd(pgd, __pgd(__pa(pud) | PUD_TYPE_TABLE));
 }
 
-#endif	/* CONFIG_ARM64_PGTABLE_LEVELS > 3 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 3 */
 
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
diff --git a/arch/arm64/include/asm/pgtable-hwdef.h b/arch/arm64/include/asm/pgtable-hwdef.h
index 5f930cc9ea83..80f3d241cff8 100644
--- a/arch/arm64/include/asm/pgtable-hwdef.h
+++ b/arch/arm64/include/asm/pgtable-hwdef.h
@@ -21,7 +21,7 @@
 /*
  * PMD_SHIFT determines the size a level 2 page table entry can map.
  */
-#if CONFIG_ARM64_PGTABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 #define PMD_SHIFT		((PAGE_SHIFT - 3) * 2 + 3)
 #define PMD_SIZE		(_AC(1, UL) << PMD_SHIFT)
 #define PMD_MASK		(~(PMD_SIZE-1))
@@ -31,7 +31,7 @@
 /*
  * PUD_SHIFT determines the size a level 1 page table entry can map.
  */
-#if CONFIG_ARM64_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 #define PUD_SHIFT		((PAGE_SHIFT - 3) * 3 + 3)
 #define PUD_SIZE		(_AC(1, UL) << PUD_SHIFT)
 #define PUD_MASK		(~(PUD_SIZE-1))
@@ -42,7 +42,7 @@
  * PGDIR_SHIFT determines the size a top-level page table entry can map
  * (depending on the configuration, this level can be 0, 1 or 2).
  */
-#define PGDIR_SHIFT		((PAGE_SHIFT - 3) * CONFIG_ARM64_PGTABLE_LEVELS + 3)
+#define PGDIR_SHIFT		((PAGE_SHIFT - 3) * CONFIG_PGTABLE_LEVELS + 3)
 #define PGDIR_SIZE		(_AC(1, UL) << PGDIR_SHIFT)
 #define PGDIR_MASK		(~(PGDIR_SIZE-1))
 #define PTRS_PER_PGD		(1 << (VA_BITS - PGDIR_SHIFT))
diff --git a/arch/arm64/include/asm/pgtable-types.h b/arch/arm64/include/asm/pgtable-types.h
index ca9df80af896..2b1bd7e52c3b 100644
--- a/arch/arm64/include/asm/pgtable-types.h
+++ b/arch/arm64/include/asm/pgtable-types.h
@@ -38,13 +38,13 @@ typedef struct { pteval_t pte; } pte_t;
 #define pte_val(x)	((x).pte)
 #define __pte(x)	((pte_t) { (x) } )
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 typedef struct { pmdval_t pmd; } pmd_t;
 #define pmd_val(x)	((x).pmd)
 #define __pmd(x)	((pmd_t) { (x) } )
 #endif
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 typedef struct { pudval_t pud; } pud_t;
 #define pud_val(x)	((x).pud)
 #define __pud(x)	((pud_t) { (x) } )
@@ -64,13 +64,13 @@ typedef pteval_t pte_t;
 #define pte_val(x)	(x)
 #define __pte(x)	(x)
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 typedef pmdval_t pmd_t;
 #define pmd_val(x)	(x)
 #define __pmd(x)	(x)
 #endif
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 typedef pudval_t pud_t;
 #define pud_val(x)	(x)
 #define __pud(x)	(x)
@@ -86,9 +86,9 @@ typedef pteval_t pgprot_t;
 
 #endif /* STRICT_MM_TYPECHECKS */
 
-#if CONFIG_ARM64_PGTABLE_LEVELS == 2
+#if CONFIG_PGTABLE_LEVELS == 2
 #include <asm-generic/pgtable-nopmd.h>
-#elif CONFIG_ARM64_PGTABLE_LEVELS == 3
+#elif CONFIG_PGTABLE_LEVELS == 3
 #include <asm-generic/pgtable-nopud.h>
 #endif
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index a26a5740afc4..9fb699405eb9 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -376,7 +376,7 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
  */
 #define mk_pte(page,prot)	pfn_pte(page_to_pfn(page),prot)
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 
 #define pmd_ERROR(pmd)		__pmd_error(__FILE__, __LINE__, pmd_val(pmd))
 
@@ -411,9 +411,9 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 
 #define pud_page(pud)		pfn_to_page(__phys_to_pfn(pud_val(pud) & PHYS_MASK))
 
-#endif	/* CONFIG_ARM64_PGTABLE_LEVELS > 2 */
+#endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 
 #define pud_ERROR(pud)		__pud_error(__FILE__, __LINE__, pud_val(pud))
 
@@ -447,7 +447,7 @@ static inline pud_t *pud_offset(pgd_t *pgd, unsigned long addr)
 
 #define pgd_page(pgd)		pfn_to_page(__phys_to_pfn(pgd_val(pgd) & PHYS_MASK))
 
-#endif  /* CONFIG_ARM64_PGTABLE_LEVELS > 3 */
+#endif  /* CONFIG_PGTABLE_LEVELS > 3 */
 
 #define pgd_ERROR(pgd)		__pgd_error(__FILE__, __LINE__, pgd_val(pgd))
 
diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
index c028fe37456f..66399cf6b490 100644
--- a/arch/arm64/include/asm/tlb.h
+++ b/arch/arm64/include/asm/tlb.h
@@ -52,7 +52,7 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 	tlb_remove_entry(tlb, pte);
 }
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 				  unsigned long addr)
 {
@@ -60,7 +60,7 @@ static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
 }
 #endif
 
-#if CONFIG_ARM64_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 static inline void __pud_free_tlb(struct mmu_gather *tlb, pud_t *pudp,
 				  unsigned long addr)
 {
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index c6daaf6c6f97..79e01163a981 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -550,10 +550,10 @@ void vmemmap_free(unsigned long start, unsigned long end)
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
 
 static pte_t bm_pte[PTRS_PER_PTE] __page_aligned_bss;
-#if CONFIG_ARM64_PGTABLE_LEVELS > 2
+#if CONFIG_PGTABLE_LEVELS > 2
 static pmd_t bm_pmd[PTRS_PER_PMD] __page_aligned_bss;
 #endif
-#if CONFIG_ARM64_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 3
 static pud_t bm_pud[PTRS_PER_PUD] __page_aligned_bss;
 #endif
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
