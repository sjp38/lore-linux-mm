Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id DC43C6B0028
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:48:02 -0500 (EST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:15:11 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 028003940055
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:58 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGltwe20643948
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:55 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGlts3011102
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:47:56 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 15/21] mm/THP: support for zerout withdraw.
Date: Thu, 21 Feb 2013 22:17:22 +0530
Message-Id: <1361465248-10867-16-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/s390/include/asm/pgtable.h     |    6 ++++++
 arch/sparc/include/asm/pgtable_64.h |    6 ++++++
 include/asm-generic/pgtable.h       |    9 +++++++++
 mm/huge_memory.c                    |    7 ++++++-
 4 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 883296e..2e8b7fe 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1238,6 +1238,12 @@ extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 #define __HAVE_ARCH_PGTABLE_WITHDRAW
 extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
 
+static inline pgtable_t __pgtable_trans_huge_withdraw(struct mm_struct *mm,
+						      pmd_t *pmdp, int tozero)
+{
+	return pgtable_trans_huge_withdraw(mm, pmdp);
+}
+
 static inline int pmd_trans_splitting(pmd_t pmd)
 {
 	return pmd_val(pmd) & _SEGMENT_ENTRY_SPLIT;
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 4c86de2..0f57c61 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -858,6 +858,12 @@ extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 
 #define __HAVE_ARCH_PGTABLE_WITHDRAW
 extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
+
+static inline pgtable_t __pgtable_trans_huge_withdraw(struct mm_struct *mm,
+						      pmd_t *pmdp, int tozero)
+{
+	return pgtable_trans_huge_withdraw(mm, pmdp);
+}
 #endif
 
 /* Encode and de-code a swap entry */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 6f87e9e..802eccc 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -169,6 +169,15 @@ extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 
 #ifndef __HAVE_ARCH_PGTABLE_WITHDRAW
 extern pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
+/*
+ * Some archs use the deposited huge table internally. Request for a
+ * zeroed/non-zeroed pgtabled when withdrawing
+ */
+static inline pgtable_t __pgtable_trans_huge_withdraw(struct mm_struct *mm,
+						      pmd_t *pmdp, int tozero)
+{
+	return pgtable_trans_huge_withdraw(mm, pmdp);
+}
 #endif
 
 #ifndef __HAVE_ARCH_PMDP_INVALIDATE
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e91b763..2586994 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1380,7 +1380,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		struct page *page;
 		pgtable_t pgtable;
 		pmd_t orig_pmd;
-		pgtable = pgtable_trans_huge_withdraw(tlb->mm, pmd);
+		/*
+		 * Withdraw the pgtable without zero out, because
+		 * the following pmd_get_and_clear will look at
+		 * pgtable contents, in case of architectures like ppc64
+		 */
+		pgtable = __pgtable_trans_huge_withdraw(tlb->mm, pmd, 0);
 		orig_pmd = pmdp_get_and_clear(tlb->mm, addr, pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 		if (is_huge_zero_pmd(orig_pmd)) {
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
