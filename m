Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B8B226B00EE
	for <linux-mm@kvack.org>; Fri, 22 May 2015 01:18:52 -0400 (EDT)
Received: by paza2 with SMTP id a2so903353paz.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 22:18:52 -0700 (PDT)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id gm10si1706996pbd.98.2015.05.21.22.18.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Thu, 21 May 2015 22:18:49 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 22 May 2015 15:18:44 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 728FB2BB0051
	for <linux-mm@kvack.org>; Fri, 22 May 2015 15:18:40 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4M5IVDQ22347858
	for <linux-mm@kvack.org>; Fri, 22 May 2015 15:18:40 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4M5I7bA023319
	for <linux-mm@kvack.org>; Fri, 22 May 2015 15:18:07 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V6 1/3] mm/thp: Split out pmd collpase flush into a separate functions
Date: Fri, 22 May 2015 10:47:30 +0530
Message-Id: <1432271852-12949-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1432271852-12949-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1432271852-12949-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Architectures like ppc64 [1] need to do special things while clearing
pmd before a collapse. For them this operation is largely different
from a normal hugepage pte clear. Hence add a separate function
to clear pmd before collapse. After this patch pmdp_* functions
operate only on hugepage pte, and not on regular pmd_t values
pointing to page table.

[1] ppc64 needs to invalidate all the normal page pte mappings we
already have inserted in the hardware hash page table. But before
doing that we need to make sure there are no parallel hash page
table insert going on. So we need to do a kick_all_cpus_sync()
before flushing the older hash table entries. By moving this to
a separate function we capture these details and mention how it
is different from a hugepage pte clear.

This patch is a cleanup and only does code movement for clarity.
There should not be any change in functionality.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h |  4 ++
 arch/powerpc/mm/pgtable_64.c             | 76 +++++++++++++++++---------------
 include/asm-generic/pgtable.h            | 21 +++++++++
 mm/huge_memory.c                         |  2 +-
 4 files changed, 67 insertions(+), 36 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index 43e6ad424c7f..129c67ebc81a 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -576,6 +576,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 extern void pmdp_splitting_flush(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp);
 
+extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp);
+#define pmdp_collapse_flush pmdp_collapse_flush
+
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 59daa5eeec25..9171c1a37290 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -560,41 +560,47 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 	pmd_t pmd;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
-	if (pmd_trans_huge(*pmdp)) {
-		pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
-	} else {
-		/*
-		 * khugepaged calls this for normal pmd
-		 */
-		pmd = *pmdp;
-		pmd_clear(pmdp);
-		/*
-		 * Wait for all pending hash_page to finish. This is needed
-		 * in case of subpage collapse. When we collapse normal pages
-		 * to hugepage, we first clear the pmd, then invalidate all
-		 * the PTE entries. The assumption here is that any low level
-		 * page fault will see a none pmd and take the slow path that
-		 * will wait on mmap_sem. But we could very well be in a
-		 * hash_page with local ptep pointer value. Such a hash page
-		 * can result in adding new HPTE entries for normal subpages.
-		 * That means we could be modifying the page content as we
-		 * copy them to a huge page. So wait for parallel hash_page
-		 * to finish before invalidating HPTE entries. We can do this
-		 * by sending an IPI to all the cpus and executing a dummy
-		 * function there.
-		 */
-		kick_all_cpus_sync();
-		/*
-		 * Now invalidate the hpte entries in the range
-		 * covered by pmd. This make sure we take a
-		 * fault and will find the pmd as none, which will
-		 * result in a major fault which takes mmap_sem and
-		 * hence wait for collapse to complete. Without this
-		 * the __collapse_huge_page_copy can result in copying
-		 * the old content.
-		 */
-		flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
-	}
+	VM_BUG_ON(!pmd_trans_huge(*pmdp));
+	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
+	return pmd;
+}
+
+pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	pmd_t pmd;
+
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+	VM_BUG_ON(pmd_trans_huge(*pmdp));
+
+	pmd = *pmdp;
+	pmd_clear(pmdp);
+	/*
+	 * Wait for all pending hash_page to finish. This is needed
+	 * in case of subpage collapse. When we collapse normal pages
+	 * to hugepage, we first clear the pmd, then invalidate all
+	 * the PTE entries. The assumption here is that any low level
+	 * page fault will see a none pmd and take the slow path that
+	 * will wait on mmap_sem. But we could very well be in a
+	 * hash_page with local ptep pointer value. Such a hash page
+	 * can result in adding new HPTE entries for normal subpages.
+	 * That means we could be modifying the page content as we
+	 * copy them to a huge page. So wait for parallel hash_page
+	 * to finish before invalidating HPTE entries. We can do this
+	 * by sending an IPI to all the cpus and executing a dummy
+	 * function there.
+	 */
+	kick_all_cpus_sync();
+	/*
+	 * Now invalidate the hpte entries in the range
+	 * covered by pmd. This make sure we take a
+	 * fault and will find the pmd as none, which will
+	 * result in a major fault which takes mmap_sem and
+	 * hence wait for collapse to complete. Without this
+	 * the __collapse_huge_page_copy can result in copying
+	 * the old content.
+	 */
+	flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
 	return pmd;
 }
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 39f1d6a2b04d..2c3ca89e9aee 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -189,6 +189,27 @@ extern void pmdp_splitting_flush(struct vm_area_struct *vma,
 				 unsigned long address, pmd_t *pmdp);
 #endif
 
+#ifndef pmdp_collapse_flush
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+					unsigned long address,
+					pmd_t *pmdp)
+{
+	return pmdp_clear_flush(vma, address, pmdp);
+}
+#define pmdp_collapse_flush pmdp_collapse_flush
+#else
+static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+					unsigned long address,
+					pmd_t *pmdp)
+{
+	BUILD_BUG();
+	return *pmdp;
+}
+#define pmdp_collapse_flush pmdp_collapse_flush
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 078832cf3636..88f695a4e38b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2499,7 +2499,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * huge and small TLB entries for the same virtual address
 	 * to avoid the risk of CPU bugs in that area.
 	 */
-	_pmd = pmdp_clear_flush(vma, address, pmd);
+	_pmd = pmdp_collapse_flush(vma, address, pmd);
 	spin_unlock(pmd_ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
