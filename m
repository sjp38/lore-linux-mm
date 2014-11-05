Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EEC2A6B0099
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 11:28:51 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so1047237pdi.17
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 08:28:51 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id ek17si3381776pdb.180.2014.11.05.08.28.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 08:28:50 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 6 Nov 2014 02:28:47 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2B8BC2CE8047
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 03:28:41 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sA5GSRKU29032638
	for <linux-mm@kvack.org>; Thu, 6 Nov 2014 03:28:36 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sA5GS7Pk003967
	for <linux-mm@kvack.org>; Thu, 6 Nov 2014 03:28:07 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V5 1/3] powerpc/mm: Add missing pmd accessors
Date: Wed,  5 Nov 2014 21:57:39 +0530
Message-Id: <1415204861-22016-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, benh@kernel.crashing.org, mpe@ellerman.id.au, David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This patch add documentation and missing accessors.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/pgtable-ppc64-4k.h  | 16 ++++++++-
 arch/powerpc/include/asm/pgtable-ppc64-64k.h |  3 ++
 arch/powerpc/include/asm/pgtable-ppc64.h     | 51 +++++++++++++++++++++-------
 arch/powerpc/mm/hugetlbpage.c                |  3 ++
 arch/powerpc/mm/pgtable_64.c                 | 22 ++++++++++--
 5 files changed, 78 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable-ppc64-4k.h b/arch/powerpc/include/asm/pgtable-ppc64-4k.h
index 7b935683f268..132ee1d482c2 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64-4k.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64-4k.h
@@ -57,7 +57,21 @@
 #define pgd_present(pgd)	(pgd_val(pgd) != 0)
 #define pgd_clear(pgdp)		(pgd_val(*(pgdp)) = 0)
 #define pgd_page_vaddr(pgd)	(pgd_val(pgd) & ~PGD_MASKED_BITS)
-#define pgd_page(pgd)		virt_to_page(pgd_page_vaddr(pgd))
+
+#ifndef __ASSEMBLY__
+
+static inline pte_t pgd_pte(pgd_t pgd)
+{
+	return __pte(pgd_val(pgd));
+}
+
+static inline pgd_t pte_pgd(pte_t pte)
+{
+	return __pgd(pte_val(pte));
+}
+extern struct page *pgd_page(pgd_t pgd);
+
+#endif /* !__ASSEMBLY__ */
 
 #define pud_offset(pgdp, addr)	\
   (((pud_t *) pgd_page_vaddr(*(pgdp))) + \
diff --git a/arch/powerpc/include/asm/pgtable-ppc64-64k.h b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
index a56b82fb0609..1de35bbd02a6 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64-64k.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64-64k.h
@@ -38,4 +38,7 @@
 /* Bits to mask out from a PGD/PUD to get to the PMD page */
 #define PUD_MASKED_BITS		0x1ff
 
+#define pgd_pte(pgd)	(pud_pte(((pud_t){ pgd })))
+#define pte_pgd(pte)	((pgd_t)pte_pud(pte))
+
 #endif /* _ASM_POWERPC_PGTABLE_PPC64_64K_H */
diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
index ae153c40ab7c..d12092420560 100644
--- a/arch/powerpc/include/asm/pgtable-ppc64.h
+++ b/arch/powerpc/include/asm/pgtable-ppc64.h
@@ -152,7 +152,7 @@
 #define pmd_none(pmd)		(!pmd_val(pmd))
 #define	pmd_bad(pmd)		(!is_kernel_addr(pmd_val(pmd)) \
 				 || (pmd_val(pmd) & PMD_BAD_BITS))
-#define	pmd_present(pmd)	(pmd_val(pmd) != 0)
+#define	pmd_present(pmd)	(!pmd_none(pmd))
 #define	pmd_clear(pmdp)		(pmd_val(*(pmdp)) = 0)
 #define pmd_page_vaddr(pmd)	(pmd_val(pmd) & ~PMD_MASKED_BITS)
 extern struct page *pmd_page(pmd_t pmd);
@@ -164,9 +164,21 @@ extern struct page *pmd_page(pmd_t pmd);
 #define pud_present(pud)	(pud_val(pud) != 0)
 #define pud_clear(pudp)		(pud_val(*(pudp)) = 0)
 #define pud_page_vaddr(pud)	(pud_val(pud) & ~PUD_MASKED_BITS)
-#define pud_page(pud)		virt_to_page(pud_page_vaddr(pud))
 
+extern struct page *pud_page(pud_t pud);
+
+static inline pte_t pud_pte(pud_t pud)
+{
+	return __pte(pud_val(pud));
+}
+
+static inline pud_t pte_pud(pte_t pte)
+{
+	return __pud(pte_val(pte));
+}
+#define pud_write(pud)		pte_write(pud_pte(pud))
 #define pgd_set(pgdp, pudp)	({pgd_val(*(pgdp)) = (unsigned long)(pudp);})
+#define pgd_write(pgd)		pte_write(pgd_pte(pgd))
 
 /*
  * Find an entry in a page-table-directory.  We combine the address region
@@ -422,7 +434,22 @@ extern void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 		       pmd_t *pmdp, pmd_t pmd);
 extern void update_mmu_cache_pmd(struct vm_area_struct *vma, unsigned long addr,
 				 pmd_t *pmd);
-
+/*
+ *
+ * For core kernel code by design pmd_trans_huge is never run on any hugetlbfs
+ * page. The hugetlbfs page table walking and mangling paths are totally
+ * separated form the core VM paths and they're differentiated by
+ *  VM_HUGETLB being set on vm_flags well before any pmd_trans_huge could run.
+ *
+ * pmd_trans_huge() is defined as false at build time if
+ * CONFIG_TRANSPARENT_HUGEPAGE=n to optimize away code blocks at build
+ * time in such case.
+ *
+ * For ppc64 we need to differntiate from explicit hugepages from THP, because
+ * for THP we also track the subpage details at the pmd level. We don't do
+ * that for explicit huge pages.
+ *
+ */
 static inline int pmd_trans_huge(pmd_t pmd)
 {
 	/*
@@ -431,16 +458,6 @@ static inline int pmd_trans_huge(pmd_t pmd)
 	return (pmd_val(pmd) & 0x3) && (pmd_val(pmd) & _PAGE_THP_HUGE);
 }
 
-static inline int pmd_large(pmd_t pmd)
-{
-	/*
-	 * leaf pte for huge page, bottom two bits != 00
-	 */
-	if (pmd_trans_huge(pmd))
-		return pmd_val(pmd) & _PAGE_PRESENT;
-	return 0;
-}
-
 static inline int pmd_trans_splitting(pmd_t pmd)
 {
 	if (pmd_trans_huge(pmd))
@@ -451,6 +468,14 @@ static inline int pmd_trans_splitting(pmd_t pmd)
 extern int has_transparent_hugepage(void);
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static inline int pmd_large(pmd_t pmd)
+{
+	/*
+	 * leaf pte for huge page, bottom two bits != 00
+	 */
+	return ((pmd_val(pmd) & 0x3) != 0x0);
+}
+
 static inline pte_t pmd_pte(pmd_t pmd)
 {
 	return __pte(pmd_val(pmd));
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 7e70ae968e5f..2e35b9a82929 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -62,6 +62,9 @@ static unsigned nr_gpages;
 /*
  * We have PGD_INDEX_SIZ = 12 and PTE_INDEX_SIZE = 8, so that we can have
  * 16GB hugepage pte in PGD and 16MB hugepage pte at PMD;
+ *
+ * Defined in such a way that we can optimize away code block at build time
+ * if CONFIG_HUGETLB_PAGE=n.
  */
 int pmd_huge(pmd_t pmd)
 {
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index c8d709ab489d..e40ca0e3f2bf 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -36,6 +36,7 @@
 #include <linux/bootmem.h>
 #include <linux/memblock.h>
 #include <linux/slab.h>
+#include <linux/hugetlb.h>
 
 #include <asm/pgalloc.h>
 #include <asm/page.h>
@@ -352,16 +353,31 @@ EXPORT_SYMBOL(iounmap);
 EXPORT_SYMBOL(__iounmap);
 EXPORT_SYMBOL(__iounmap_at);
 
+#ifndef __PAGETABLE_PUD_FOLDED
+/* 4 level page table */
+struct page *pgd_page(pgd_t pgd)
+{
+	if (pgd_huge(pgd))
+		return pte_page(pgd_pte(pgd));
+	return virt_to_page(pgd_page_vaddr(pgd));
+}
+#endif
+
+struct page *pud_page(pud_t pud)
+{
+	if (pud_huge(pud))
+		return pte_page(pud_pte(pud));
+	return virt_to_page(pud_page_vaddr(pud));
+}
+
 /*
  * For hugepage we have pfn in the pmd, we use PTE_RPN_SHIFT bits for flags
  * For PTE page, we have a PTE_FRAG_SIZE (4K) aligned virtual address.
  */
 struct page *pmd_page(pmd_t pmd)
 {
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	if (pmd_trans_huge(pmd))
+	if (pmd_trans_huge(pmd) || pmd_huge(pmd))
 		return pfn_to_page(pmd_pfn(pmd));
-#endif
 	return virt_to_page(pmd_page_vaddr(pmd));
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
