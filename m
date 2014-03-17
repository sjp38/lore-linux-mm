Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C31E46B00AD
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 14:52:12 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id cc10so2658329wib.14
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 11:52:12 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
        by mx.google.com with ESMTPS id s2si5851453wic.51.2014.03.17.11.52.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 11:52:11 -0700 (PDT)
Received: by mail-wi0-f170.google.com with SMTP id bs8so1676960wib.1
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 11:52:11 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RESEND PATCH] mm: hugetlb: Introduce huge_pte_{page,present,young}
Date: Mon, 17 Mar 2014 18:51:58 +0000
Message-Id: <1395082318-7703-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, Steve Capper <steve.capper@linaro.org>

Introduce huge pte versions of pte_page, pte_present and pte_young.
This allows ARM (without LPAE) to use alternative pte processing logic
for huge ptes.

Where these functions are not defined by architectural code they
fallback to the standard functions.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
Hi,
I'm resending this patch to provoke some discussion.

We already have some huge_pte_ style functions, and this patch adds a
few more (that simplify to the pte_ equivalents where unspecified).

Having separate hugetlb versions of pte_page, present and mkyoung
allows for a greatly simplified huge page implementation for ARM with
the classical MMU (which has a different bit layout for huge ptes).

Cheers,
-- 
Steve
---
 include/linux/hugetlb.h | 12 ++++++++++++
 mm/hugetlb.c            | 22 +++++++++++-----------
 2 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8c43cc4..4992487 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -353,6 +353,18 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 }
 #endif
 
+#ifndef huge_pte_page
+#define huge_pte_page(pte)	pte_page(pte)
+#endif
+
+#ifndef huge_pte_present
+#define huge_pte_present(pte)	pte_present(pte)
+#endif
+
+#ifndef huge_pte_mkyoung
+#define huge_pte_mkyoung(pte)	pte_mkyoung(pte)
+#endif
+
 static inline struct hstate *page_hstate(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHuge(page), page);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c01cb9f..d1a38c9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2319,7 +2319,7 @@ static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
 		entry = huge_pte_wrprotect(mk_huge_pte(page,
 					   vma->vm_page_prot));
 	}
-	entry = pte_mkyoung(entry);
+	entry = huge_pte_mkyoung(entry);
 	entry = pte_mkhuge(entry);
 	entry = arch_make_huge_pte(entry, vma, page, writable);
 
@@ -2379,7 +2379,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			if (cow)
 				huge_ptep_set_wrprotect(src, addr, src_pte);
 			entry = huge_ptep_get(src_pte);
-			ptepage = pte_page(entry);
+			ptepage = huge_pte_page(entry);
 			get_page(ptepage);
 			page_dup_rmap(ptepage);
 			set_huge_pte_at(dst, addr, dst_pte, entry);
@@ -2398,7 +2398,7 @@ static int is_hugetlb_entry_migration(pte_t pte)
 {
 	swp_entry_t swp;
 
-	if (huge_pte_none(pte) || pte_present(pte))
+	if (huge_pte_none(pte) || huge_pte_present(pte))
 		return 0;
 	swp = pte_to_swp_entry(pte);
 	if (non_swap_entry(swp) && is_migration_entry(swp))
@@ -2411,7 +2411,7 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 {
 	swp_entry_t swp;
 
-	if (huge_pte_none(pte) || pte_present(pte))
+	if (huge_pte_none(pte) || huge_pte_present(pte))
 		return 0;
 	swp = pte_to_swp_entry(pte);
 	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
@@ -2464,7 +2464,7 @@ again:
 			goto unlock;
 		}
 
-		page = pte_page(pte);
+		page = huge_pte_page(pte);
 		/*
 		 * If a reference page is supplied, it is because a specific
 		 * page is being unmapped, not a range. Ensure the page we
@@ -2614,7 +2614,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
-	old_page = pte_page(pte);
+	old_page = huge_pte_page(pte);
 
 retry_avoidcopy:
 	/* If no-one else is actually using this page, avoid the copy
@@ -2965,7 +2965,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Note that locking order is always pagecache_page -> page,
 	 * so no worry about deadlock.
 	 */
-	page = pte_page(entry);
+	page = huge_pte_page(entry);
 	get_page(page);
 	if (page != pagecache_page)
 		lock_page(page);
@@ -2985,7 +2985,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		entry = huge_pte_mkdirty(entry);
 	}
-	entry = pte_mkyoung(entry);
+	entry = huge_pte_mkyoung(entry);
 	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
 						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, ptep);
@@ -3077,7 +3077,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		pfn_offset = (vaddr & ~huge_page_mask(h)) >> PAGE_SHIFT;
-		page = pte_page(huge_ptep_get(pte));
+		page = huge_pte_page(huge_ptep_get(pte));
 same_page:
 		if (pages) {
 			pages[i] = mem_map_offset(page, pfn_offset);
@@ -3425,7 +3425,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 {
 	struct page *page;
 
-	page = pte_page(*(pte_t *)pmd);
+	page = huge_pte_page(*(pte_t *)pmd);
 	if (page)
 		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
 	return page;
@@ -3437,7 +3437,7 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
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
