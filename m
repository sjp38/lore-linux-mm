Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E8138280256
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:22:02 -0400 (EDT)
Received: by pacan13 with SMTP id an13so103115795pac.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:22:02 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id wk5si2174505pab.37.2015.07.20.07.21.56
        for <linux-mm@kvack.org>;
        Mon, 20 Jul 2015 07:21:57 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9 19/36] mips, thp: remove infrastructure for handling splitting PMDs
Date: Mon, 20 Jul 2015 17:20:52 +0300
Message-Id: <1437402069-105900-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1437402069-105900-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With new refcounting we don't need to mark PMDs splitting. Let's drop
code to handle this.

pmdp_splitting_flush() is not needed too: on splitting PMD we will do
pmdp_clear_flush() + set_pte_at(). pmdp_clear_flush() will do IPI as
needed for fast_gup.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/mips/include/asm/pgtable-bits.h |  6 ++----
 arch/mips/include/asm/pgtable.h      | 18 ------------------
 arch/mips/mm/gup.c                   | 13 +------------
 arch/mips/mm/pgtable-64.c            | 14 --------------
 arch/mips/mm/tlbex.c                 |  1 -
 5 files changed, 3 insertions(+), 49 deletions(-)

diff --git a/arch/mips/include/asm/pgtable-bits.h b/arch/mips/include/asm/pgtable-bits.h
index c28a8499aec7..9bf8b2b87364 100644
--- a/arch/mips/include/asm/pgtable-bits.h
+++ b/arch/mips/include/asm/pgtable-bits.h
@@ -131,14 +131,12 @@
 /* Huge TLB page */
 #define _PAGE_HUGE_SHIFT	(_PAGE_MODIFIED_SHIFT + 1)
 #define _PAGE_HUGE		(1 << _PAGE_HUGE_SHIFT)
-#define _PAGE_SPLITTING_SHIFT	(_PAGE_HUGE_SHIFT + 1)
-#define _PAGE_SPLITTING		(1 << _PAGE_SPLITTING_SHIFT)
 
 /* Only R2 or newer cores have the XI bit */
 #if defined(CONFIG_CPU_MIPSR2) || defined(CONFIG_CPU_MIPSR6)
-#define _PAGE_NO_EXEC_SHIFT	(_PAGE_SPLITTING_SHIFT + 1)
+#define _PAGE_NO_EXEC_SHIFT	(_PAGE_HUGE_SHIFT + 1)
 #else
-#define _PAGE_GLOBAL_SHIFT	(_PAGE_SPLITTING_SHIFT + 1)
+#define _PAGE_GLOBAL_SHIFT	(_PAGE_HUGE_SHIFT + 1)
 #define _PAGE_GLOBAL		(1 << _PAGE_GLOBAL_SHIFT)
 #endif	/* CONFIG_CPU_MIPSR2 || CONFIG_CPU_MIPSR6 */
 
diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index 9d8106758142..556c02a0706a 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -449,27 +449,9 @@ static inline pmd_t pmd_mkhuge(pmd_t pmd)
 	return pmd;
 }
 
-static inline int pmd_trans_splitting(pmd_t pmd)
-{
-	return !!(pmd_val(pmd) & _PAGE_SPLITTING);
-}
-
-static inline pmd_t pmd_mksplitting(pmd_t pmd)
-{
-	pmd_val(pmd) |= _PAGE_SPLITTING;
-
-	return pmd;
-}
-
 extern void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 		       pmd_t *pmdp, pmd_t pmd);
 
-#define __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-/* Extern to avoid header file madness */
-extern void pmdp_splitting_flush(struct vm_area_struct *vma,
-					unsigned long address,
-					pmd_t *pmdp);
-
 #define __HAVE_ARCH_PMD_WRITE
 static inline int pmd_write(pmd_t pmd)
 {
diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
index 36a35115dc2e..1afd87c999b0 100644
--- a/arch/mips/mm/gup.c
+++ b/arch/mips/mm/gup.c
@@ -107,18 +107,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		pmd_t pmd = *pmdp;
 
 		next = pmd_addr_end(addr, end);
-		/*
-		 * The pmd_trans_splitting() check below explains why
-		 * pmdp_splitting_flush has to flush the tlb, to stop
-		 * this gup-fast code from running while we set the
-		 * splitting bit in the pmd. Returning zero will take
-		 * the slow path that will call wait_split_huge_page()
-		 * if the pmd is still in splitting state. gup-fast
-		 * can't because it has irq disabled and
-		 * wait_split_huge_page() would never return as the
-		 * tlb flush IPI wouldn't run.
-		 */
-		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+		if (pmd_none(pmd))
 			return 0;
 		if (unlikely(pmd_huge(pmd))) {
 			if (!gup_huge_pmd(pmd, addr, next, write, pages,nr))
diff --git a/arch/mips/mm/pgtable-64.c b/arch/mips/mm/pgtable-64.c
index e8adc0069d66..ce4473e7c0d2 100644
--- a/arch/mips/mm/pgtable-64.c
+++ b/arch/mips/mm/pgtable-64.c
@@ -62,20 +62,6 @@ void pmd_init(unsigned long addr, unsigned long pagetable)
 }
 #endif
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-
-void pmdp_splitting_flush(struct vm_area_struct *vma,
-			 unsigned long address,
-			 pmd_t *pmdp)
-{
-	if (!pmd_trans_splitting(*pmdp)) {
-		pmd_t pmd = pmd_mksplitting(*pmdp);
-		set_pmd_at(vma->vm_mm, address, pmdp, pmd);
-	}
-}
-
-#endif
-
 pmd_t mk_pmd(struct page *page, pgprot_t prot)
 {
 	pmd_t pmd;
diff --git a/arch/mips/mm/tlbex.c b/arch/mips/mm/tlbex.c
index 97c87027c17f..02b53ce7fc2e 100644
--- a/arch/mips/mm/tlbex.c
+++ b/arch/mips/mm/tlbex.c
@@ -240,7 +240,6 @@ static void output_pgtable_bits_defines(void)
 	pr_define("_PAGE_MODIFIED_SHIFT %d\n", _PAGE_MODIFIED_SHIFT);
 #ifdef CONFIG_MIPS_HUGE_TLB_SUPPORT
 	pr_define("_PAGE_HUGE_SHIFT %d\n", _PAGE_HUGE_SHIFT);
-	pr_define("_PAGE_SPLITTING_SHIFT %d\n", _PAGE_SPLITTING_SHIFT);
 #endif
 #ifdef CONFIG_CPU_MIPSR2
 	if (cpu_has_rixi) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
