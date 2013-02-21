Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2AF6E6B002C
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 11:48:07 -0500 (EST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 21 Feb 2013 22:15:03 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 7C2FD394004E
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:18:01 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1LGlvgu30277720
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 22:17:57 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1LGlvBU011344
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 03:47:59 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH -V2 17/21] powerpc/THP: Differentiate THP PMD entries from HUGETLB PMD entries
Date: Thu, 21 Feb 2013 22:17:24 +0530
Message-Id: <1361465248-10867-18-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

HUGETLB clear the top bit of PMD entries and use that to indicate
a HUGETLB page directory. Since we store pfns in PMDs for THP,
we would have the top bit cleared by default. Add the top bit mask
for THP PMD entries and clear that when we are looking for pmd_pfn.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable.h |   15 ++++++++++++---
 arch/powerpc/mm/pgtable.c          |    5 ++++-
 arch/powerpc/mm/pgtable_64.c       |    2 +-
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index ca1848a..5b8e93b 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -31,7 +31,7 @@ struct mm_struct;
 #define PMD_HUGE_EXEC		0x004 /* No execute on POWER4 and newer (we invert) */
 #define PMD_HUGE_SPLITTING	0x008
 #define PMD_HUGE_HASHPTE	0x010
-#define PMD_ISHUGE		0x020
+#define _PMD_ISHUGE		0x020
 #define PMD_HUGE_DIRTY		0x080 /* C: page changed */
 #define PMD_HUGE_ACCESSED	0x100 /* R: page referenced */
 #define PMD_HUGE_RW		0x200 /* software: user write access allowed */
@@ -44,6 +44,14 @@ struct mm_struct;
 #define PMD_HUGE_RPN_SHIFT	PTE_RPN_SHIFT
 #define HUGE_PAGE_SIZE		(ASM_CONST(1) << 24)
 #define HUGE_PAGE_MASK		(~(HUGE_PAGE_SIZE - 1))
+/*
+ * HugeTLB looks at the top bit of the Linux page table entries to
+ * decide whether it is a huge page directory or not. Mark HUGE
+ * PMD to differentiate
+ */
+#define PMD_HUGE_NOT_HUGETLB	(ASM_CONST(1) << 63)
+#define PMD_ISHUGE		(_PMD_ISHUGE | PMD_HUGE_NOT_HUGETLB)
+#define PMD_HUGE_PROTBITS	(0xfff | PMD_HUGE_NOT_HUGETLB)
 
 #ifndef __ASSEMBLY__
 extern void hpte_need_hugepage_flush(struct mm_struct *mm, unsigned long addr,
@@ -61,7 +69,8 @@ static inline unsigned long pmd_pfn(pmd_t pmd)
 	/*
 	 * Only called for huge page pmd
 	 */
-	return pmd_val(pmd) >> PMD_HUGE_RPN_SHIFT;
+	unsigned long val = pmd_val(pmd) & ~PMD_HUGE_PROTBITS;
+	return val  >> PMD_HUGE_RPN_SHIFT;
 }
 
 static inline int pmd_young(pmd_t pmd)
@@ -95,7 +104,7 @@ static inline int pmd_trans_splitting(pmd_t pmd)
 
 static inline int pmd_trans_huge(pmd_t pmd)
 {
-	return pmd_val(pmd) & PMD_ISHUGE;
+	return ((pmd_val(pmd) & PMD_ISHUGE) ==  PMD_ISHUGE);
 }
 
 /* We will enable it in the last patch */
diff --git a/arch/powerpc/mm/pgtable.c b/arch/powerpc/mm/pgtable.c
index d117982..ef91331 100644
--- a/arch/powerpc/mm/pgtable.c
+++ b/arch/powerpc/mm/pgtable.c
@@ -528,7 +528,10 @@ static pmd_t pmd_set_protbits(pmd_t pmd, pgprot_t pgprot)
 pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot)
 {
 	pmd_t pmd;
-
+	/*
+	 * We cannot support that many PFNs
+	 */
+	VM_BUG_ON(pfn & PMD_HUGE_NOT_HUGETLB);
 	pmd_val(pmd) = pfn << PMD_HUGE_RPN_SHIFT;
 	/*
 	 * pgtable_t is always 4K aligned, even in case where we use the
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index 3dc131d..5f22232 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -346,7 +346,7 @@ EXPORT_SYMBOL(__iounmap_at);
 struct page *pmd_page(pmd_t pmd)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	if (pmd_val(pmd) & PMD_ISHUGE)
+	if ((pmd_val(pmd) & PMD_ISHUGE) == PMD_ISHUGE)
 		return pfn_to_page(pmd_pfn(pmd));
 #endif
 	return virt_to_page(pmd_page_vaddr(pmd));
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
