Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 438708309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 01:41:16 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wb13so142381476obb.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 22:41:16 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id px4si14658806oec.72.2016.02.07.22.41.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 07 Feb 2016 22:41:15 -0800 (PST)
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 7 Feb 2016 23:41:15 -0700
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9EF0319D803F
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 23:29:11 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u186fC3K24838240
	for <linux-mm@kvack.org>; Sun, 7 Feb 2016 23:41:12 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u186fCIA006004
	for <linux-mm@kvack.org>; Sun, 7 Feb 2016 23:41:12 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm: Some arch may want to use HPAGE_PMD related values as variables
Date: Mon,  8 Feb 2016 12:11:00 +0530
Message-Id: <1454913660-27031-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454913660-27031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454913660-27031-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With next generation power processor, we are having a new mmu model
[1] that require us to maintain a different linux page table format.

Inorder to support both current and future ppc64 systems with a single
kernel we need to make sure kernel can select between different page
table format at runtime. With the new MMU (radix MMU) added, we will
have two different pmd hugepage size 16MB for hash model and 2MB for
Radix model. Hence make HPAGE_PMD related values as a variable.

[1] http://ibm.biz/power-isa3 (Needs registration).

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/arm/include/asm/pgtable-3level.h | 8 ++++++++
 arch/arm64/include/asm/pgtable.h      | 7 +++++++
 arch/mips/include/asm/pgtable.h       | 8 ++++++++
 arch/powerpc/mm/pgtable_64.c          | 7 +++++++
 arch/s390/include/asm/pgtable.h       | 8 ++++++++
 arch/sparc/include/asm/pgtable_64.h   | 7 +++++++
 arch/tile/include/asm/pgtable.h       | 9 +++++++++
 arch/x86/include/asm/pgtable.h        | 8 ++++++++
 include/linux/huge_mm.h               | 3 ---
 mm/huge_memory.c                      | 8 +++++---
 10 files changed, 67 insertions(+), 6 deletions(-)

diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index dc46398bc3a5..4b934de4d088 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -281,6 +281,14 @@ static inline void set_pmd_at(struct mm_struct *mm, unsigned long addr,
 	flush_pmd_entry(pmdp);
 }
 
+#if HPAGE_PMD_ORDER >= MAX_ORDER
+#error "hugepages can't be allocated by the buddy allocator"
+#endif
+
+#if HPAGE_PMD_ORDER < 2
+#error "We need more than 2 pages to do deferred thp split"
+#endif
+
 static inline int has_transparent_hugepage(void)
 {
 	return 1;
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index bf464de33f52..6bc4605d0d58 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -378,6 +378,13 @@ static inline pgprot_t mk_sect_prot(pgprot_t prot)
 
 #define set_pmd_at(mm, addr, pmdp, pmd)	set_pte_at(mm, addr, (pte_t *)pmdp, pmd_pte(pmd))
 
+#if HPAGE_PMD_ORDER >= MAX_ORDER
+#error "hugepages can't be allocated by the buddy allocator"
+#endif
+
+#if HPAGE_PMD_ORDER < 2
+#error "We need more than 2 pages to do deferred thp split"
+#endif
 static inline int has_transparent_hugepage(void)
 {
 	return 1;
diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index 9a4fe0133ff1..005839fd438d 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -468,6 +468,14 @@ static inline int io_remap_pfn_range(struct vm_area_struct *vma,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
+#if HPAGE_PMD_ORDER >= MAX_ORDER
+#error "hugepages can't be allocated by the buddy allocator"
+#endif
+
+#if HPAGE_PMD_ORDER < 2
+#error "We need more than 2 pages to do deferred thp split"
+#endif
+
 extern int has_transparent_hugepage(void);
 
 static inline int pmd_trans_huge(pmd_t pmd)
diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
index e8214b7f2210..8840d31a5586 100644
--- a/arch/powerpc/mm/pgtable_64.c
+++ b/arch/powerpc/mm/pgtable_64.c
@@ -818,6 +818,13 @@ pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 
 int has_transparent_hugepage(void)
 {
+
+	BUILD_BUG_ON_MSG((PMD_SHIFT - PAGE_SHIFT) >= MAX_ORDER,
+		"hugepages can't be allocated by the buddy allocator");
+
+	BUILD_BUG_ON_MSG((PMD_SHIFT - PAGE_SHIFT) < 2,
+			 "We need more than 2 pages to do deferred thp split");
+
 	if (!mmu_has_feature(MMU_FTR_16M_PAGE))
 		return 0;
 	/*
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 64ead8091248..79e7ea6e272c 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1617,6 +1617,14 @@ static inline int pmd_trans_huge(pmd_t pmd)
 	return pmd_val(pmd) & _SEGMENT_ENTRY_LARGE;
 }
 
+#if HPAGE_PMD_ORDER >= MAX_ORDER
+#error "hugepages can't be allocated by the buddy allocator"
+#endif
+
+#if HPAGE_PMD_ORDER < 2
+#error "We need more than 2 pages to do deferred thp split"
+#endif
+
 static inline int has_transparent_hugepage(void)
 {
 	return MACHINE_HAS_HPAGE ? 1 : 0;
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 7a38d6a576c5..1f3884687f80 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -681,6 +681,13 @@ static inline unsigned long pmd_trans_huge(pmd_t pmd)
 	return pte_val(pte) & _PAGE_PMD_HUGE;
 }
 
+#if HPAGE_PMD_ORDER >= MAX_ORDER
+#error "hugepages can't be allocated by the buddy allocator"
+#endif
+
+#if HPAGE_PMD_ORDER < 2
+#error "We need more than 2 pages to do deferred thp split"
+#endif
 #define has_transparent_hugepage() 1
 
 static inline pmd_t pmd_mkold(pmd_t pmd)
diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 96cecf55522e..70c5a44e8909 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -487,6 +487,15 @@ static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+
+#if HPAGE_PMD_ORDER >= MAX_ORDER
+#error "hugepages can't be allocated by the buddy allocator"
+#endif
+
+#if HPAGE_PMD_ORDER < 2
+#error "We need more than 2 pages to do deferred thp split"
+#endif
+
 #define has_transparent_hugepage() 1
 #define pmd_trans_huge pmd_huge_page
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0687c4748b8f..7f3a39d98ad5 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -178,6 +178,14 @@ static inline int pmd_devmap(pmd_t pmd)
 	return !!(pmd_val(pmd) & _PAGE_DEVMAP);
 }
 #endif
+
+#if HPAGE_PMD_ORDER >= MAX_ORDER
+#error "hugepages can't be allocated by the buddy allocator"
+#endif
+
+#if HPAGE_PMD_ORDER < 2
+#error "We need more than 2 pages to do deferred thp split"
+#endif
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 static inline pte_t pte_set_flags(pte_t pte, pteval_t set)
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 459fd25b378e..f12513a20a06 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -111,9 +111,6 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			__split_huge_pmd(__vma, __pmd, __address);	\
 	}  while (0)
 
-#if HPAGE_PMD_ORDER >= MAX_ORDER
-#error "hugepages can't be allocated by the buddy allocator"
-#endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
 			    unsigned long *vm_flags, int advice);
 extern void vma_adjust_trans_huge(struct vm_area_struct *vma,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b52d16a86e91..db1362d015ce 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -83,7 +83,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
 /* default scan 8*512 pte (or vmas) every 30 second */
-static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
+static unsigned int khugepaged_pages_to_scan __read_mostly;
 static unsigned int khugepaged_pages_collapsed;
 static unsigned int khugepaged_full_scans;
 static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
@@ -98,7 +98,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  * it would have happened if the vma was large enough during page
  * fault.
  */
-static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
+static unsigned int khugepaged_max_ptes_none __read_mostly;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
@@ -655,6 +655,9 @@ static int __init hugepage_init(void)
 	int err;
 	struct kobject *hugepage_kobj;
 
+	khugepaged_pages_to_scan = HPAGE_PMD_NR*8;
+	khugepaged_max_ptes_none = HPAGE_PMD_NR-1;
+
 	if (!has_transparent_hugepage()) {
 		transparent_hugepage_flags = 0;
 		return -EINVAL;
@@ -764,7 +767,6 @@ void prep_transhuge_page(struct page *page)
 	 * we use page->mapping and page->indexlru in second tail page
 	 * as list_head: assuming THP order >= 2
 	 */
-	BUILD_BUG_ON(HPAGE_PMD_ORDER < 2);
 
 	INIT_LIST_HEAD(page_deferred_list(page));
 	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
