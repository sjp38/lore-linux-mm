Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id F14886B006E
	for <linux-mm@kvack.org>; Fri,  1 May 2015 01:43:58 -0400 (EDT)
Received: by pdea3 with SMTP id a3so83143085pde.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 22:43:58 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id y2si6594792pas.55.2015.04.30.22.43.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Apr 2015 22:43:55 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 1 May 2015 11:13:52 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id DCA8CE0067
	for <linux-mm@kvack.org>; Fri,  1 May 2015 11:16:34 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t415hkvH49021152
	for <linux-mm@kvack.org>; Fri, 1 May 2015 11:13:47 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t415hjW8005940
	for <linux-mm@kvack.org>; Fri, 1 May 2015 11:13:46 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 1/2] mm/thp: Use new functions to clear pmd on splitting and collapse
Date: Fri,  1 May 2015 11:13:25 +0530
Message-Id: <1430459006-18142-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1430459006-18142-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1430459006-18142-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Some arch may require an explicit IPI before a THP PMD split or
collapse. This enable us to use local_irq_disable to prevent
a parallel THP PMD split or collapse.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/asm-generic/pgtable.h | 32 ++++++++++++++++++++++++++++++++
 mm/huge_memory.c              |  9 +++++----
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index fe617b7e4be6..e95c697bef25 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -184,6 +184,38 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH_NOTIFY
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmdp_splitting_flush_notify pmdp_clear_flush_notify
+#else
+static inline void pmdp_splitting_flush_notify(struct vm_area_struct *vma,
+					       unsigned long address,
+					       pmd_t *pmdp)
+{
+	BUILD_BUG();
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
+#ifndef __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+				       unsigned long address,
+				       pmd_t *pmdp)
+{
+	return pmdp_clear_flush(vma, address, pmdp);
+}
+#else
+static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
+				       unsigned long address,
+				       pmd_t *pmdp)
+{
+	BUILD_BUG();
+	return __pmd(0);
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
 extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 				       pgtable_t pgtable);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cce4604c192f..30c1b46fcf6d 100644
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
 
@@ -2606,9 +2606,10 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
-
-	/* leave pmd empty until pte is filled */
-	pmdp_clear_flush_notify(vma, haddr, pmd);
+	/*
+	 * leave pmd empty until pte is filled.
+	 */
+	pmdp_splitting_flush_notify(vma, haddr, pmd);
 
 	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
 	pmd_populate(mm, &_pmd, pgtable);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
