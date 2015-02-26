Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4965B6B0082
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:59 -0500 (EST)
Received: by pdev10 with SMTP id v10so12423105pde.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:59 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id h7si79548pdn.131.2015.02.26.03.35.39
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 05/17] ia64: expose number of page table levels on Kconfig level
Date: Thu, 26 Feb 2015 13:35:08 +0200
Message-Id: <1424950520-90188-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

We need to define PGTABLE_LEVELS before sourcing init/Kconfig:
arch/Kconfig will define default value and it's sourced from init/Kconfig.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/ia64/Kconfig                | 18 +++++-------------
 arch/ia64/include/asm/page.h     |  4 ++--
 arch/ia64/include/asm/pgalloc.h  |  4 ++--
 arch/ia64/include/asm/pgtable.h  | 12 ++++++------
 arch/ia64/kernel/ivt.S           | 12 ++++++------
 arch/ia64/kernel/machine_kexec.c |  4 ++--
 6 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 074e52bf815c..4f9a6661491b 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -1,3 +1,8 @@
+config PGTABLE_LEVELS
+	int "Page Table Levels" if !IA64_PAGE_SIZE_64KB
+	range 3 4 if !IA64_PAGE_SIZE_64KB
+	default 3
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
@@ -286,19 +291,6 @@ config IA64_PAGE_SIZE_64KB
 
 endchoice
 
-choice
-	prompt "Page Table Levels"
-	default PGTABLE_3
-
-config PGTABLE_3
-	bool "3 Levels"
-
-config PGTABLE_4
-	depends on !IA64_PAGE_SIZE_64KB
-	bool "4 Levels"
-
-endchoice
-
 if IA64_HP_SIM
 config HZ
 	default 32
diff --git a/arch/ia64/include/asm/page.h b/arch/ia64/include/asm/page.h
index 1f1bf144fe62..ec48bb9f95e1 100644
--- a/arch/ia64/include/asm/page.h
+++ b/arch/ia64/include/asm/page.h
@@ -173,7 +173,7 @@ get_order (unsigned long size)
    */
   typedef struct { unsigned long pte; } pte_t;
   typedef struct { unsigned long pmd; } pmd_t;
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
   typedef struct { unsigned long pud; } pud_t;
 #endif
   typedef struct { unsigned long pgd; } pgd_t;
@@ -182,7 +182,7 @@ get_order (unsigned long size)
 
 # define pte_val(x)	((x).pte)
 # define pmd_val(x)	((x).pmd)
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 # define pud_val(x)	((x).pud)
 #endif
 # define pgd_val(x)	((x).pgd)
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index 5767cdfc08db..f5e70e961948 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -32,7 +32,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	quicklist_free(0, NULL, pgd);
 }
 
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 static inline void
 pgd_populate(struct mm_struct *mm, pgd_t * pgd_entry, pud_t * pud)
 {
@@ -49,7 +49,7 @@ static inline void pud_free(struct mm_struct *mm, pud_t *pud)
 	quicklist_free(0, NULL, pud);
 }
 #define __pud_free_tlb(tlb, pud, address)	pud_free((tlb)->mm, pud)
-#endif /* CONFIG_PGTABLE_4 */
+#endif /* CONFIG_PGTABLE_LEVELS == 4 */
 
 static inline void
 pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 7b6f8801df57..9f3ed9ee8f13 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -99,7 +99,7 @@
 #define PMD_MASK	(~(PMD_SIZE-1))
 #define PTRS_PER_PMD	(1UL << (PTRS_PER_PTD_SHIFT))
 
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 /*
  * Definitions for second level:
  *
@@ -117,7 +117,7 @@
  *
  * PGDIR_SHIFT determines what a first-level page table entry can map.
  */
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 #define PGDIR_SHIFT		(PUD_SHIFT + (PTRS_PER_PTD_SHIFT))
 #else
 #define PGDIR_SHIFT		(PMD_SHIFT + (PTRS_PER_PTD_SHIFT))
@@ -180,7 +180,7 @@
 #define __S111	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RWX)
 
 #define pgd_ERROR(e)	printk("%s:%d: bad pgd %016lx.\n", __FILE__, __LINE__, pgd_val(e))
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 #define pud_ERROR(e)	printk("%s:%d: bad pud %016lx.\n", __FILE__, __LINE__, pud_val(e))
 #endif
 #define pmd_ERROR(e)	printk("%s:%d: bad pmd %016lx.\n", __FILE__, __LINE__, pmd_val(e))
@@ -281,7 +281,7 @@ extern unsigned long VMALLOC_END;
 #define pud_page_vaddr(pud)		((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 #define pud_page(pud)			virt_to_page((pud_val(pud) + PAGE_OFFSET))
 
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 #define pgd_none(pgd)			(!pgd_val(pgd))
 #define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
@@ -384,7 +384,7 @@ pgd_offset (const struct mm_struct *mm, unsigned long address)
    here.  */
 #define pgd_offset_gate(mm, addr)	pgd_offset_k(addr)
 
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 /* Find an entry in the second-level page table.. */
 #define pud_offset(dir,addr) \
 	((pud_t *) pgd_page_vaddr(*(dir)) + (((addr) >> PUD_SHIFT) & (PTRS_PER_PUD - 1)))
@@ -586,7 +586,7 @@ extern struct page *zero_page_memmap_ptr;
 #define __HAVE_ARCH_PGD_OFFSET_GATE
 
 
-#ifndef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 3
 #include <asm-generic/pgtable-nopud.h>
 #endif
 #include <asm-generic/pgtable.h>
diff --git a/arch/ia64/kernel/ivt.S b/arch/ia64/kernel/ivt.S
index 18e794a57248..e42bf7a913f3 100644
--- a/arch/ia64/kernel/ivt.S
+++ b/arch/ia64/kernel/ivt.S
@@ -146,7 +146,7 @@ ENTRY(vhpt_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 	shr.u r28=r22,PUD_SHIFT			// shift pud index into position
 #else
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
@@ -155,7 +155,7 @@ ENTRY(vhpt_miss)
 	ld8 r17=[r17]				// get *pgd (may be 0)
 	;;
 (p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) == NULL?
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 	dep r28=r28,r17,3,(PAGE_SHIFT-3)	// r28=pud_offset(pgd,addr)
 	;;
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
@@ -222,13 +222,13 @@ ENTRY(vhpt_miss)
 	 */
 	ld8 r25=[r21]				// read *pte again
 	ld8 r26=[r17]				// read *pmd again
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 	ld8 r19=[r28]				// read *pud again
 #endif
 	cmp.ne p6,p7=r0,r0
 	;;
 	cmp.ne.or.andcm p6,p7=r26,r20		// did *pmd change
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 	cmp.ne.or.andcm p6,p7=r19,r29		// did *pud change
 #endif
 	mov r27=PAGE_SHIFT<<2
@@ -476,7 +476,7 @@ ENTRY(nested_dtlb_miss)
 (p6)	dep r17=r18,r19,3,(PAGE_SHIFT-3)	// r17=pgd_offset for region 5
 (p7)	dep r17=r18,r17,3,(PAGE_SHIFT-6)	// r17=pgd_offset for region[0-4]
 	cmp.eq p7,p6=0,r21			// unused address bits all zeroes?
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 	shr.u r18=r22,PUD_SHIFT			// shift pud index into position
 #else
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
@@ -487,7 +487,7 @@ ENTRY(nested_dtlb_miss)
 (p7)	cmp.eq p6,p7=r17,r0			// was pgd_present(*pgd) == NULL?
 	dep r17=r18,r17,3,(PAGE_SHIFT-3)	// r17=p[u|m]d_offset(pgd,addr)
 	;;
-#ifdef CONFIG_PGTABLE_4
+#if CONFIG_PGTABLE_LEVELS == 4
 (p7)	ld8 r17=[r17]				// get *pud (may be 0)
 	shr.u r18=r22,PMD_SHIFT			// shift pmd index into position
 	;;
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index 5151a649c96b..b72cd7a07222 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -156,9 +156,9 @@ void arch_crash_save_vmcoreinfo(void)
 	VMCOREINFO_OFFSET(node_memblk_s, start_paddr);
 	VMCOREINFO_OFFSET(node_memblk_s, size);
 #endif
-#ifdef CONFIG_PGTABLE_3
+#if CONFIG_PGTABLE_LEVELS == 3
 	VMCOREINFO_CONFIG(PGTABLE_3);
-#elif defined(CONFIG_PGTABLE_4)
+#elif CONFIG_PGTABLE_LEVELS == 4
 	VMCOREINFO_CONFIG(PGTABLE_4);
 #endif
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
