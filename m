Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E16228089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 22:01:23 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so214788829pgc.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 19:01:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c12si8841379pfe.23.2017.02.08.19.01.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 19:01:22 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v192wgAG142093
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 22:01:22 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28g3w8nqay-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 22:01:21 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 20:01:21 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/2] powerpc/mm/autonuma: Switch ppc64 to its own implementeation of saved write
Date: Thu,  9 Feb 2017 08:30:59 +0530
In-Reply-To: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <1486609259-6796-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With this our protnone becomes a present pte with READ/WRITE/EXEC bit cleared.
By default we also set _PAGE_PRIVILEGED on such pte. This is now used to help
us identify a protnone pte that as saved write bit. For such pte, we will clear
the _PAGE_PRIVILEGED bit. The pte still remain non-accessible from both user
and kernel.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu-hash.h |  3 +++
 arch/powerpc/include/asm/book3s/64/pgtable.h  | 32 +++++++++++++++++++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
index 0735d5a8049f..8720a406bbbe 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
@@ -16,6 +16,9 @@
 #include <asm/page.h>
 #include <asm/bug.h>
 
+#ifndef __ASSEMBLY__
+#include <linux/mmdebug.h>
+#endif
 /*
  * This is necessary to get the definition of PGTABLE_RANGE which we
  * need for various slices related matters. Note that this isn't the
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index e91ada786d48..efff910a84b1 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -443,8 +443,8 @@ static inline pte_t pte_clear_soft_dirty(pte_t pte)
  */
 static inline int pte_protnone(pte_t pte)
 {
-	return (pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED)) ==
-		cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED);
+	return (pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_RWX)) ==
+		cpu_to_be64(_PAGE_PRESENT);
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
@@ -514,6 +514,32 @@ static inline pte_t pte_mkhuge(pte_t pte)
 	return pte;
 }
 
+#define pte_mk_savedwrite pte_mk_savedwrite
+static inline pte_t pte_mk_savedwrite(pte_t pte)
+{
+	/*
+	 * Used by Autonuma subsystem to preserve the write bit
+	 * while marking the pte PROT_NONE. Only allow this
+	 * on PROT_NONE pte
+	 */
+	VM_BUG_ON((pte_raw(pte) & cpu_to_be64(_PAGE_PRESENT | _PAGE_RWX | _PAGE_PRIVILEGED)) !=
+		  cpu_to_be64(_PAGE_PRESENT | _PAGE_PRIVILEGED));
+	return __pte(pte_val(pte) & ~_PAGE_PRIVILEGED);
+}
+
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
+
 static inline pte_t pte_mkdevmap(pte_t pte)
 {
 	return __pte(pte_val(pte) | _PAGE_SPECIAL|_PAGE_DEVMAP);
@@ -885,6 +911,7 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
 #define pmd_mkclean(pmd)	pte_pmd(pte_mkclean(pmd_pte(pmd)))
 #define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
 #define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
+#define pmd_mk_savedwrite(pmd)	pte_pmd(pte_mk_savedwrite(pmd_pte(pmd)))
 
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
@@ -901,6 +928,7 @@ static inline int pmd_protnone(pmd_t pmd)
 
 #define __HAVE_ARCH_PMD_WRITE
 #define pmd_write(pmd)		pte_write(pmd_pte(pmd))
+#define pmd_savedwrite(pmd)	pte_savedwrite(pmd_pte(pmd))
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
