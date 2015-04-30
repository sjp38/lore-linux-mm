Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0496B006C
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 04:25:58 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so53130009pac.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 01:25:58 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id cd8si2495539pdb.6.2015.04.30.01.25.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 01:25:57 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 30 Apr 2015 13:55:53 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 04A963940063
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:52 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3U8PpnE58982562
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:51 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3U8PotF029926
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 13:55:50 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 3/3] mm/thp: Add new function to clear pmd on collapse
Date: Thu, 30 Apr 2015 13:55:41 +0530
Message-Id: <1430382341-8316-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1430382341-8316-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Some arch may need an explicit IPI when clearing pmd
on collapse. Add new function which arch can override.
After this pmdp_clear_flush is used only for THP case
to invalidate a huge page pte.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64.h |  4 ++
 arch/powerpc/mm/pgtable_64.c             | 77 ++++++++++++++++----------------
 include/asm-generic/pgtable.h            |  9 ++++
 mm/huge_memory.c                         |  2 +-
 4 files changed, 53 insertions(+), 39 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index ff275443a040..655dde8e9683 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -562,6 +562,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 extern void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmdp);
 
+#define __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
+extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmdp);
+
 #define __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 89b356250be3..fa49e2ff042b 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -558,45 +558,9 @@ unsigned long pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
 pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
 		       pmd_t *pmdp)
 {
-	pmd_t pmd;
-
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
-	return pmd;
+	VM_BUG_ON(!pmd_trans_huge(*pmdp));
+	return pmdp_get_and_clear(vma->vm_mm, address, pmdp);
 }
 
 int pmdp_test_and_clear_young(struct vm_area_struct *vma,
@@ -641,6 +605,43 @@ void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
 	kick_all_cpus_sync();
 }
 
+pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
+			  pmd_t *pmdp)
+{
+	pmd_t pmd;
+
+	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
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
+	return pmd;
+}
+
 /*
  * We want to put the pgtable in pmd and use pgtable for tracking
  * the base page size hptes
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index d091a666f5b1..2e1e4653ae7c 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -189,6 +189,15 @@ extern void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
 					unsigned long address, pmd_t *pmdp);
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
+static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+				       unsigned long address,
+				       pmd_t *pmdp)
+{
+	return pmdp_clear_flush(vma, address, pmdp);
+}
+#endif
+
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 81e9578bf43a..30c1b46fcf6d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2187,7 +2187,7 @@ static void collapse_huge_page(struct mm_struct *mm,
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
