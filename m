Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36D6D6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:56:55 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f21so178382246pgi.4
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 05:56:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s9si15197828pgo.309.2017.02.27.05.56.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 05:56:54 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1RDumau058636
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:56:53 -0500
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28u6atu1nu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:56:49 -0500
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 27 Feb 2017 06:56:47 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/2] powerpc/mm: Handle protnone ptes on fork
Date: Mon, 27 Feb 2017 19:26:26 +0530
Message-Id: <1488203787-17849-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org, Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We need mark pages of parent process read only on fork. Numa fault pte
needs a protnone ptes variant with saved write flag set. On fork we need to
make sure we remove the saved write bit. Instead of adding the protnone check
in the caller update ptep_set_wrprotect variants to clear savedwrite bit.

Without this we see random segfaults in application on fork.

Fixes: c137a2757b886 ("powerpc/mm/autonuma: switch ppc64 to its own
implementation of saved write")

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 73 ++++++++++++++++------------
 1 file changed, 42 insertions(+), 31 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 1eeeb72c7015..f0b08acda5eb 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -347,23 +347,53 @@ static inline int __ptep_test_and_clear_young(struct mm_struct *mm,
 	__r;							\
 })
 
+static inline int pte_write(pte_t pte)
+{
+	return !!(pte_raw(pte) & cpu_to_be64(_PAGE_WRITE));
+}
+
+#ifdef CONFIG_NUMA_BALANCING
+#define pte_savedwrite pte_savedwrite
+static inline bool pte_savedwrite(pte_t pte)
+{
+	/*
+	 * Saved write ptes are prot none ptes that doesn't have
+	 * privileged bit sit. We mark prot none as one which has
+	 * present and pviliged bit set and RWX cleared. To mark
+	 * protnone which used to have _PAGE_WRITE set we clear
+	 * the privileged bit.
+	 */
+	return !(pte_raw(pte) & cpu_to_be64(_PAGE_RWX | _PAGE_PRIVILEGED));
+}
+#else
+#define pte_savedwrite pte_savedwrite
+static inline bool pte_savedwrite(pte_t pte)
+{
+	return false;
+}
+#endif
+
 #define __HAVE_ARCH_PTEP_SET_WRPROTECT
 static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pte_t *ptep)
 {
-	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_WRITE)) == 0)
-		return;
-
-	pte_update(mm, addr, ptep, _PAGE_WRITE, 0, 0);
+	if (pte_write(*ptep))
+		pte_update(mm, addr, ptep, _PAGE_WRITE, 0, 0);
+	else if (unlikely(pte_savedwrite(*ptep)))
+		pte_update(mm, addr, ptep, 0, _PAGE_PRIVILEGED, 0);
 }
 
 static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 					   unsigned long addr, pte_t *ptep)
 {
-	if ((pte_raw(*ptep) & cpu_to_be64(_PAGE_WRITE)) == 0)
-		return;
-
-	pte_update(mm, addr, ptep, _PAGE_WRITE, 0, 1);
+	/*
+	 * We should not find protnone for hugetlb, but this complete the
+	 * interface.
+	 */
+	if (pte_write(*ptep))
+		pte_update(mm, addr, ptep, _PAGE_WRITE, 0, 1);
+	else if (unlikely(pte_savedwrite(*ptep)))
+		pte_update(mm, addr, ptep, 0, _PAGE_PRIVILEGED, 1);
 }
 
 #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
@@ -397,11 +427,6 @@ static inline void pte_clear(struct mm_struct *mm, unsigned long addr,
 	pte_update(mm, addr, ptep, ~0UL, 0, 0);
 }
 
-static inline int pte_write(pte_t pte)
-{
-	return !!(pte_raw(pte) & cpu_to_be64(_PAGE_WRITE));
-}
-
 static inline int pte_dirty(pte_t pte)
 {
 	return !!(pte_raw(pte) & cpu_to_be64(_PAGE_DIRTY));
@@ -466,19 +491,6 @@ static inline pte_t pte_clear_savedwrite(pte_t pte)
 	return __pte(pte_val(pte) | _PAGE_PRIVILEGED);
 }
 
-#define pte_savedwrite pte_savedwrite
-static inline bool pte_savedwrite(pte_t pte)
-{
-	/*
-	 * Saved write ptes are prot none ptes that doesn't have
-	 * privileged bit sit. We mark prot none as one which has
-	 * present and pviliged bit set and RWX cleared. To mark
-	 * protnone which used to have _PAGE_WRITE set we clear
-	 * the privileged bit.
-	 */
-	VM_BUG_ON(!pte_protnone(pte));
-	return !(pte_raw(pte) & cpu_to_be64(_PAGE_RWX | _PAGE_PRIVILEGED));
-}
 #endif /* CONFIG_NUMA_BALANCING */
 
 static inline int pte_present(pte_t pte)
@@ -982,11 +994,10 @@ static inline int __pmdp_test_and_clear_young(struct mm_struct *mm,
 static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
 				      pmd_t *pmdp)
 {
-
-	if ((pmd_raw(*pmdp) & cpu_to_be64(_PAGE_WRITE)) == 0)
-		return;
-
-	pmd_hugepage_update(mm, addr, pmdp, _PAGE_WRITE, 0);
+	if (pmd_write((*pmdp)))
+		pmd_hugepage_update(mm, addr, pmdp, _PAGE_WRITE, 0);
+	else if (unlikely(pmd_savedwrite(*pmdp)))
+		pmd_hugepage_update(mm, addr, pmdp, 0, _PAGE_PRIVILEGED);
 }
 
 static inline int pmd_trans_huge(pmd_t pmd)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
