Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEE696B0069
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 13:31:47 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x79so19023447lff.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 10:31:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id gd1si6163057wjb.55.2016.10.11.10.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 10:31:46 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9BHTUa1091514
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 13:31:45 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2611qur361-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 13:31:44 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 11 Oct 2016 11:31:44 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 4/5] mm: Add tlb_remove_check_page_size_change to track page size change
Date: Tue, 11 Oct 2016 23:01:20 +0530
In-Reply-To: <20161011173121.17545-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161011173121.17545-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161011173121.17545-4-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

With commit e77b0852b551 ("mm/mmu_gather: track page size with mmu gather and force flush if page size change")
we added the ability to force a tlb flush when the page size change in
a mmu_gather loop. We did that by checking for a page size change
every time we added a page to mmu_gather for lazy flush/remove. We can
improve that by moving the page size change check early and not doing
it every time we add a page.

This also help us to do tlb flush when invalidating a range covering
dax mapping. W.r.t dax mapping we don't have a backing struct page and
hence we don't call tlb_remove_page, which earlier forced the tlb flush
on page size change. Moving the page size change check earlier means
we will do the same even for dax mapping.

We also avoid doing this check on architecture other than powerpc.

In the later patch we will remove page size check from tlb_remove_page().

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/arm/include/asm/tlb.h     |  6 ++++++
 arch/ia64/include/asm/tlb.h    |  6 ++++++
 arch/powerpc/include/asm/tlb.h | 16 ++++++++++++++++
 arch/s390/include/asm/tlb.h    |  6 ++++++
 arch/sh/include/asm/tlb.h      |  6 ++++++
 arch/um/include/asm/tlb.h      |  6 ++++++
 include/asm-generic/tlb.h      | 16 ++++++++++++++++
 mm/huge_memory.c               |  4 ++++
 mm/hugetlb.c                   |  5 +++++
 mm/madvise.c                   |  1 +
 mm/memory.c                    |  1 +
 11 files changed, 73 insertions(+)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 82841ba1f51f..a9d6de4746ea 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -286,5 +286,11 @@ tlb_remove_pmd_tlb_entry(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
+#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
+static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+						     unsigned int page_size)
+{
+}
+
 #endif /* CONFIG_MMU */
 #endif
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index b3f369ab844d..bfe6295aa746 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -286,6 +286,12 @@ do {							\
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
+#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
+static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+						     unsigned int page_size)
+{
+}
+
 #define pte_free_tlb(tlb, ptep, address)		\
 do {							\
 	tlb->need_flush = 1;				\
diff --git a/arch/powerpc/include/asm/tlb.h b/arch/powerpc/include/asm/tlb.h
index f6f68f73e858..c54e9f2cec87 100644
--- a/arch/powerpc/include/asm/tlb.h
+++ b/arch/powerpc/include/asm/tlb.h
@@ -28,6 +28,7 @@
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry	__tlb_remove_tlb_entry
+#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
 
 extern void tlb_flush(struct mmu_gather *tlb);
 
@@ -46,6 +47,21 @@ static inline void __tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep,
 #endif
 }
 
+static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+						     unsigned int page_size)
+{
+	if (!tlb->page_size)
+		tlb->page_size = page_size;
+	else if (tlb->page_size != page_size) {
+		tlb_flush_mmu(tlb);
+		/*
+		 * update the page size after flush for the new
+		 * mmu_gather.
+		 */
+		tlb->page_size = page_size;
+	}
+}
+
 #ifdef CONFIG_SMP
 static inline int mm_is_core_local(struct mm_struct *mm)
 {
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 094440b59f9e..28b159c87c38 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -165,4 +165,10 @@ static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud,
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
+#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
+static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+						     unsigned int page_size)
+{
+}
+
 #endif /* _S390_TLB_H */
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index e7d15e8c75c1..0f988b3e484b 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -130,6 +130,12 @@ static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 	return tlb_remove_page(tlb, page);
 }
 
+#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
+static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+						     unsigned int page_size)
+{
+}
+
 #define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
 #define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
 #define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index a4427029c3c8..8258dd4bb13c 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -144,6 +144,12 @@ static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
+#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
+static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+						     unsigned int page_size)
+{
+}
+
 #define pte_free_tlb(tlb, ptep, addr) __pte_free_tlb(tlb, ptep, addr)
 
 #define pud_free_tlb(tlb, pudp, addr) __pud_free_tlb(tlb, pudp, addr)
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 38c2b708df6e..256c9de71fdb 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -182,6 +182,22 @@ static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *pa
 	return __tlb_remove_page(tlb, page);
 }
 
+#ifndef tlb_remove_check_page_size_change
+#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
+static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+						     unsigned int page_size)
+{
+	/*
+	 * We don't care about page size change, just update
+	 * mmu_gather page size here so that debug checks
+	 * doesn't throw false warning.
+	 */
+#ifdef CONFIG_DEBUG_VM
+	tlb->page_size = page_size;
+#endif
+}
+#endif
+
 /*
  * In the case of tlb vma handling, we can optimise these away in the
  * case where we're doing a full MM flush.  When we're doing a munmap,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3c9efdda0893..5144db07837d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1262,6 +1262,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	struct mm_struct *mm = tlb->mm;
 	bool ret = false;
 
+	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
+
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
 		goto out_unlocked;
@@ -1323,6 +1325,8 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	pmd_t orig_pmd;
 	spinlock_t *ptl;
 
+	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
+
 	ptl = __pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
 		return 0;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 58c233a80e6a..52b170a0a616 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3199,6 +3199,11 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	BUG_ON(start & ~huge_page_mask(h));
 	BUG_ON(end & ~huge_page_mask(h));
 
+	/*
+	 * This is a hugetlb vma, all the pte entries should point
+	 * to huge page.
+	 */
+	tlb_remove_check_page_size_change(tlb, sz);
 	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	address = start;
diff --git a/mm/madvise.c b/mm/madvise.c
index 93fb63e88b5e..0e3828eae9f8 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -281,6 +281,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
+	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
 	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
diff --git a/mm/memory.c b/mm/memory.c
index 793fe0f9841c..0ab75fd2514e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1120,6 +1120,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	swp_entry_t entry;
 	struct page *pending_page = NULL;
 
+	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
 again:
 	init_rss_vec(rss);
 	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
