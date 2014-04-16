Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 77A906B0072
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 07:46:53 -0400 (EDT)
Received: by mail-wg0-f44.google.com with SMTP id m15so10893330wgh.27
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:52 -0700 (PDT)
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
        by mx.google.com with ESMTPS id hg2si7372490wjc.163.2014.04.16.04.46.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 04:46:52 -0700 (PDT)
Received: by mail-we0-f177.google.com with SMTP id u57so10790785wes.36
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:51 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH V2 1/5] mm: hugetlb: Introduce huge_pte_{page,present,young}
Date: Wed, 16 Apr 2014 12:46:39 +0100
Message-Id: <1397648803-15961-2-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, akpm@linux-foundation.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, robherring2@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, gerald.schaefer@de.ibm.com, Steve Capper <steve.capper@linaro.org>

Introduce huge pte versions of pte_page, pte_present and pte_young.

This allows ARM (without LPAE) to use alternative pte processing logic
for huge ptes.

Generic implementations that call the standard pte versions are also
added to asm-generic/hugetlb.h.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
Acked-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 arch/s390/include/asm/hugetlb.h | 15 +++++++++++++++
 include/asm-generic/hugetlb.h   | 15 +++++++++++++++
 mm/hugetlb.c                    | 22 +++++++++++-----------
 3 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 11eae5f..7b13ec0 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -112,4 +112,19 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
 	return pte_modify(pte, newprot);
 }
 
+static inline struct page *huge_pte_page(pte_t pte)
+{
+	return pte_page(pte);
+}
+
+static inline unsigned long huge_pte_present(pte_t pte)
+{
+	return pte_present(pte);
+}
+
+static inline pte_t huge_pte_mkyoung(pte_t pte)
+{
+	return pte_mkyoung(pte);
+}
+
 #endif /* _ASM_S390_HUGETLB_H */
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index 99b490b..2dc68fe 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -37,4 +37,19 @@ static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
 	pte_clear(mm, addr, ptep);
 }
 
+static inline struct page *huge_pte_page(pte_t pte)
+{
+	return pte_page(pte);
+}
+
+static inline unsigned long huge_pte_present(pte_t pte)
+{
+	return pte_present(pte);
+}
+
+static inline pte_t huge_pte_mkyoung(pte_t pte)
+{
+	return pte_mkyoung(pte);
+}
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dd30f22..1e77c07 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2350,7 +2350,7 @@ static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
 		entry = huge_pte_wrprotect(mk_huge_pte(page,
 					   vma->vm_page_prot));
 	}
-	entry = pte_mkyoung(entry);
+	entry = huge_pte_mkyoung(entry);
 	entry = pte_mkhuge(entry);
 	entry = arch_make_huge_pte(entry, vma, page, writable);
 
@@ -2410,7 +2410,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			if (cow)
 				huge_ptep_set_wrprotect(src, addr, src_pte);
 			entry = huge_ptep_get(src_pte);
-			ptepage = pte_page(entry);
+			ptepage = huge_pte_page(entry);
 			get_page(ptepage);
 			page_dup_rmap(ptepage);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
@@ -2429,7 +2429,7 @@ static int is_hugetlb_entry_migration(pte_t pte)
 {
 	swp_entry_t swp;
 
-	if (huge_pte_none(pte) || pte_present(pte))
+	if (huge_pte_none(pte) || huge_pte_present(pte))
 		return 0;
 	swp = pte_to_swp_entry(pte);
 	if (non_swap_entry(swp) && is_migration_entry(swp))
@@ -2442,7 +2442,7 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 {
 	swp_entry_t swp;
 
-	if (huge_pte_none(pte) || pte_present(pte))
+	if (huge_pte_none(pte) || huge_pte_present(pte))
 		return 0;
 	swp = pte_to_swp_entry(pte);
 	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
@@ -2495,7 +2495,7 @@ again:
 			goto unlock;
 		}
 
-		page = pte_page(pte);
+		page = huge_pte_page(pte);
 		/*
 		 * If a reference page is supplied, it is because a specific
 		 * page is being unmapped, not a range. Ensure the page we
@@ -2645,7 +2645,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
-	old_page = pte_page(pte);
+	old_page = huge_pte_page(pte);
 
 retry_avoidcopy:
 	/* If no-one else is actually using this page, avoid the copy
@@ -3033,7 +3033,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Note that locking order is always pagecache_page -> page,
 	 * so no worry about deadlock.
 	 */
-	page = pte_page(entry);
+	page = huge_pte_page(entry);
 	get_page(page);
 	if (page != pagecache_page)
 		lock_page(page);
@@ -3053,7 +3053,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		entry = huge_pte_mkdirty(entry);
 	}
-	entry = pte_mkyoung(entry);
+	entry = huge_pte_mkyoung(entry);
 	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
 						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, ptep);
@@ -3144,7 +3144,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		pfn_offset = (vaddr & ~huge_page_mask(h)) >> PAGE_SHIFT;
-		page = pte_page(huge_ptep_get(pte));
+		page = huge_pte_page(huge_ptep_get(pte));
 same_page:
 		if (pages) {
 			pages[i] = mem_map_offset(page, pfn_offset);
@@ -3501,7 +3501,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 {
 	struct page *page;
 
-	page = pte_page(*(pte_t *)pmd);
+	page = huge_pte_page(*(pte_t *)pmd);
 	if (page)
 		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
 	return page;
@@ -3513,7 +3513,7 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 {
 	struct page *page;
 
-	page = pte_page(*(pte_t *)pud);
+	page = huge_pte_page(*(pte_t *)pud);
 	if (page)
 		page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
 	return page;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
