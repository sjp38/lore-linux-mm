Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4D8E6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:59:17 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 33so910104pll.9
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 02:59:17 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p12si1083549pgn.653.2017.12.13.02.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 02:59:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 12/12] mm/thp: Remove pmd_huge_split_prepare
Date: Wed, 13 Dec 2017 13:57:56 +0300
Message-Id: <20171213105756.69879-13-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Instead of marking the pmd ready for split, invalidate the pmd. This should
take care of powerpc requirement. Only side effect is that we mark the pmd
invalid early. This can result in us blocking access to the page a bit longer
if we race against a thp split.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
[kirill.shutemov@linux.intel.com: rebased, dirty THP once]
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/powerpc/include/asm/book3s/64/hash-4k.h  |  2 -
 arch/powerpc/include/asm/book3s/64/hash-64k.h |  2 -
 arch/powerpc/include/asm/book3s/64/pgtable.h  |  9 ----
 arch/powerpc/include/asm/book3s/64/radix.h    |  6 ---
 arch/powerpc/mm/pgtable-hash64.c              | 22 --------
 include/asm-generic/pgtable.h                 |  8 ---
 mm/huge_memory.c                              | 74 +++++++++++++--------------
 7 files changed, 36 insertions(+), 87 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
index 197ced1eaaa0..2d9df40446f6 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -101,8 +101,6 @@ extern pmd_t hash__pmdp_collapse_flush(struct vm_area_struct *vma,
 extern void hash__pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 					 pgtable_t pgtable);
 extern pgtable_t hash__pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
-extern void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
-				      unsigned long address, pmd_t *pmdp);
 extern pmd_t hash__pmdp_huge_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pmd_t *pmdp);
 extern int hash__has_transparent_hugepage(void);
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index 8d40cf03cb67..cb46d1034f33 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -203,8 +203,6 @@ extern pmd_t hash__pmdp_collapse_flush(struct vm_area_struct *vma,
 extern void hash__pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 					 pgtable_t pgtable);
 extern pgtable_t hash__pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
-extern void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
-				      unsigned long address, pmd_t *pmdp);
 extern pmd_t hash__pmdp_huge_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pmd_t *pmdp);
 extern int hash__has_transparent_hugepage(void);
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index ee19d5bbee06..6ca1208cedcb 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1140,15 +1140,6 @@ static inline pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm,
 extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			     pmd_t *pmdp);
 
-#define __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
-static inline void pmdp_huge_split_prepare(struct vm_area_struct *vma,
-					   unsigned long address, pmd_t *pmdp)
-{
-	if (radix_enabled())
-		return radix__pmdp_huge_split_prepare(vma, address, pmdp);
-	return hash__pmdp_huge_split_prepare(vma, address, pmdp);
-}
-
 #define pmd_move_must_withdraw pmd_move_must_withdraw
 struct spinlock;
 static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
index 19c44e1495ae..365010f66570 100644
--- a/arch/powerpc/include/asm/book3s/64/radix.h
+++ b/arch/powerpc/include/asm/book3s/64/radix.h
@@ -269,12 +269,6 @@ static inline pmd_t radix__pmd_mkhuge(pmd_t pmd)
 		return __pmd(pmd_val(pmd) | _PAGE_PTE | R_PAGE_LARGE);
 	return __pmd(pmd_val(pmd) | _PAGE_PTE);
 }
-static inline void radix__pmdp_huge_split_prepare(struct vm_area_struct *vma,
-					    unsigned long address, pmd_t *pmdp)
-{
-	/* Nothing to do for radix. */
-	return;
-}
 
 extern unsigned long radix__pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 					  pmd_t *pmdp, unsigned long clr,
diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
index ec277913e01b..469808e77e58 100644
--- a/arch/powerpc/mm/pgtable-hash64.c
+++ b/arch/powerpc/mm/pgtable-hash64.c
@@ -296,28 +296,6 @@ pgtable_t hash__pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	return pgtable;
 }
 
-void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
-			       unsigned long address, pmd_t *pmdp)
-{
-	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	VM_BUG_ON(REGION_ID(address) != USER_REGION_ID);
-	VM_BUG_ON(pmd_devmap(*pmdp));
-
-	/*
-	 * We can't mark the pmd none here, because that will cause a race
-	 * against exit_mmap. We need to continue mark pmd TRANS HUGE, while
-	 * we spilt, but at the same time we wan't rest of the ppc64 code
-	 * not to insert hash pte on this, because we will be modifying
-	 * the deposited pgtable in the caller of this function. Hence
-	 * clear the _PAGE_USER so that we move the fault handling to
-	 * higher level function and that will serialize against ptl.
-	 * We need to flush existing hash pte entries here even though,
-	 * the translation is still valid, because we will withdraw
-	 * pgtable_t after this.
-	 */
-	pmd_hugepage_update(vma->vm_mm, address, pmdp, 0, _PAGE_PRIVILEGED);
-}
-
 /*
  * A linux hugepage PMD was changed and the corresponding hash table entries
  * neesd to be flushed.
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f449c71cbdc0..687d5719d8ee 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -329,14 +329,6 @@ extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
 			    pmd_t *pmdp);
 #endif
 
-#ifndef __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
-static inline void pmdp_huge_split_prepare(struct vm_area_struct *vma,
-					   unsigned long address, pmd_t *pmdp)
-{
-
-}
-#endif
-
 #ifndef __HAVE_ARCH_PTE_SAME
 static inline int pte_same(pte_t pte_a, pte_t pte_b)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 10278d03d60f..10ea2e63ef33 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2063,7 +2063,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	struct mm_struct *mm = vma->vm_mm;
 	struct page *page;
 	pgtable_t pgtable;
-	pmd_t old, _pmd;
+	pmd_t old_pmd, _pmd;
 	bool young, write, soft_dirty, pmd_migration = false;
 	unsigned long addr;
 	int i;
@@ -2106,23 +2106,51 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		return __split_huge_zero_page_pmd(vma, haddr, pmd);
 	}
 
+	/*
+	 * Up to this point the pmd is present and huge and userland has the
+	 * whole access to the hugepage during the split (which happens in
+	 * place). If we overwrite the pmd with the not-huge version pointing
+	 * to the pte here (which of course we could if all CPUs were bug
+	 * free), userland could trigger a small page size TLB miss on the
+	 * small sized TLB while the hugepage TLB entry is still established in
+	 * the huge TLB. Some CPU doesn't like that.
+	 * See http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum
+	 * 383 on page 93. Intel should be safe but is also warns that it's
+	 * only safe if the permission and cache attributes of the two entries
+	 * loaded in the two TLB is identical (which should be the case here).
+	 * But it is generally safer to never allow small and huge TLB entries
+	 * for the same virtual address to be loaded simultaneously. So instead
+	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
+	 * current pmd notpresent (atomically because here the pmd_trans_huge
+	 * and pmd_trans_splitting must remain set at all times on the pmd
+	 * until the split is complete for this pmd), then we flush the SMP TLB
+	 * and finally we write the non-huge version of the pmd entry with
+	 * pmd_populate.
+	 */
+	old_pmd = pmdp_invalidate(vma, haddr, pmd);
+
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
-	pmd_migration = is_pmd_migration_entry(*pmd);
+	pmd_migration = is_pmd_migration_entry(old_pmd);
 	if (pmd_migration) {
 		swp_entry_t entry;
 
-		entry = pmd_to_swp_entry(*pmd);
+		entry = pmd_to_swp_entry(old_pmd);
 		page = pfn_to_page(swp_offset(entry));
 	} else
 #endif
-		page = pmd_page(*pmd);
+		page = pmd_page(old_pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
-	write = pmd_write(*pmd);
-	young = pmd_young(*pmd);
-	soft_dirty = pmd_soft_dirty(*pmd);
+	if (pmd_dirty(old_pmd))
+		SetPageDirty(page);
+	write = pmd_write(old_pmd);
+	young = pmd_young(old_pmd);
+	soft_dirty = pmd_soft_dirty(old_pmd);
 
-	pmdp_huge_split_prepare(vma, haddr, pmd);
+	/*
+	 * Withdraw the table only after we mark the pmd entry invalid.
+	 * This's critical for some architectures (Power).
+	 */
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
 
@@ -2176,36 +2204,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	}
 
 	smp_wmb(); /* make pte visible before pmd */
-	/*
-	 * Up to this point the pmd is present and huge and userland has the
-	 * whole access to the hugepage during the split (which happens in
-	 * place). If we overwrite the pmd with the not-huge version pointing
-	 * to the pte here (which of course we could if all CPUs were bug
-	 * free), userland could trigger a small page size TLB miss on the
-	 * small sized TLB while the hugepage TLB entry is still established in
-	 * the huge TLB. Some CPU doesn't like that.
-	 * See http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum
-	 * 383 on page 93. Intel should be safe but is also warns that it's
-	 * only safe if the permission and cache attributes of the two entries
-	 * loaded in the two TLB is identical (which should be the case here).
-	 * But it is generally safer to never allow small and huge TLB entries
-	 * for the same virtual address to be loaded simultaneously. So instead
-	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
-	 * current pmd notpresent (atomically because here the pmd_trans_huge
-	 * and pmd_trans_splitting must remain set at all times on the pmd
-	 * until the split is complete for this pmd), then we flush the SMP TLB
-	 * and finally we write the non-huge version of the pmd entry with
-	 * pmd_populate.
-	 */
-	old = pmdp_invalidate(vma, haddr, pmd);
-
-	/*
-	 * Transfer dirty bit using value returned by pmd_invalidate() to be
-	 * sure we don't race with CPU that can set the bit under us.
-	 */
-	if (pmd_dirty(old))
-		SetPageDirty(page);
-
 	pmd_populate(mm, pmd, pgtable);
 
 	if (freeze) {
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
