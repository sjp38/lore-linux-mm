Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C141C6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 09:53:51 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so51235658pfb.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 06:53:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id qg4si26393293pac.339.2016.11.07.06.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 06:46:56 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA7Ehuq7103048
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 09:46:55 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26js2k9nfp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Nov 2016 09:46:55 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 7 Nov 2016 07:46:53 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2] mm: move vma_is_anonymous check within pmd_move_must_withdraw
Date: Mon,  7 Nov 2016 20:16:39 +0530
In-Reply-To: <201611071732.njM40txT%fengguang.wu@intel.com>
References: <201611071732.njM40txT%fengguang.wu@intel.com>
Message-Id: <20161107144639.24048-1-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Architectures like ppc64 want to use page table deposit/withraw
even with huge pmd dax entries. Allow arch to override the
vma_is_anonymous check by moving that to pmd_move_must_withdraw
function

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
* Changes from V1:
  Fix build error with x86 config

 arch/powerpc/include/asm/book3s/64/pgtable.h |  3 ++-
 include/asm-generic/pgtable.h                | 12 ------------
 mm/huge_memory.c                             | 18 ++++++++++++++++--
 3 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 9fd77f8794a0..700301bc5190 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -1009,7 +1009,8 @@ static inline void pmdp_huge_split_prepare(struct vm_area_struct *vma,
 #define pmd_move_must_withdraw pmd_move_must_withdraw
 struct spinlock;
 static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
-					 struct spinlock *old_pmd_ptl)
+					 struct spinlock *old_pmd_ptl,
+					 struct vm_area_struct *vma)
 {
 	if (radix_enabled())
 		return false;
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index c4f8fd2fd384..324990273ad2 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -653,18 +653,6 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 }
 #endif
 
-#ifndef pmd_move_must_withdraw
-static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
-					 spinlock_t *old_pmd_ptl)
-{
-	/*
-	 * With split pmd lock we also need to move preallocated
-	 * PTE page table if new_pmd is on different PMD page table.
-	 */
-	return new_pmd_ptl != old_pmd_ptl;
-}
-#endif
-
 /*
  * This function is meant to be used by sites walking pagetables with
  * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cdcd25cb30fe..54f265ec902e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1424,6 +1424,21 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	return 1;
 }
 
+#ifndef pmd_move_must_withdraw
+static inline int pmd_move_must_withdraw(spinlock_t *new_pmd_ptl,
+					 spinlock_t *old_pmd_ptl,
+					 struct vm_area_struct *vma)
+{
+	/*
+	 * With split pmd lock we also need to move preallocated
+	 * PTE page table if new_pmd is on different PMD page table.
+	 *
+	 * We also don't deposit and withdraw tables for file pages.
+	 */
+	return (new_pmd_ptl != old_pmd_ptl) && vma_is_anonymous(vma);
+}
+#endif
+
 bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		  unsigned long new_addr, unsigned long old_end,
 		  pmd_t *old_pmd, pmd_t *new_pmd)
@@ -1458,8 +1473,7 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 		pmd = pmdp_huge_get_and_clear(mm, old_addr, old_pmd);
 		VM_BUG_ON(!pmd_none(*new_pmd));
 
-		if (pmd_move_must_withdraw(new_ptl, old_ptl) &&
-				vma_is_anonymous(vma)) {
+		if (pmd_move_must_withdraw(new_ptl, old_ptl, vma)) {
 			pgtable_t pgtable;
 			pgtable = pgtable_trans_huge_withdraw(mm, old_pmd);
 			pgtable_trans_huge_deposit(mm, new_pmd, pgtable);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
