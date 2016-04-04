Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id EB06C828E5
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 19:58:25 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id zm5so154317981pac.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 16:58:25 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 12si29518100pfm.92.2016.04.04.16.58.24
        for <linux-mm@kvack.org>;
        Mon, 04 Apr 2016 16:58:25 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: keep huge zero pinned until tlb flush
Date: Tue,  5 Apr 2016 02:57:27 +0300
Message-Id: <1459814247-45614-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Andrea has found[1] a race condition on MMU-gather based TLB flush vs
split_huge_page() or shrinker which frees huge zero under us (patch 1/2
and 2/2 respectively).

With new THP refcounting, we don't patch 1/2: mmu_gather keeps the page
page pinned until flush is complete and the pin prevent the page from
being split under us.

We sill need patch 2/2. This is simplified version of Andrea's patch.
We don't need fancy encoding.

[1] http://lkml.kernel.org/r/1447938052-22165-1-git-send-email-aarcange@redhat.com

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h | 1 +
 mm/huge_memory.c        | 6 +++---
 mm/swap.c               | 5 +++++
 3 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7008623e24b1..8232e0b8a04f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -152,6 +152,7 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 }
 
 struct page *get_huge_zero_page(void);
+void put_huge_zero_page(void);
 
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 820214137bc5..860c7dec197e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -235,7 +235,7 @@ retry:
 	return READ_ONCE(huge_zero_page);
 }
 
-static void put_huge_zero_page(void)
+void put_huge_zero_page(void)
 {
 	/*
 	 * Counter should never go to zero here. Only shrinker can put
@@ -1715,12 +1715,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (vma_is_dax(vma)) {
 		spin_unlock(ptl);
 		if (is_huge_zero_pmd(orig_pmd))
-			put_huge_zero_page();
+			tlb_remove_page(tlb, pmd_page(orig_pmd));
 	} else if (is_huge_zero_pmd(orig_pmd)) {
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		spin_unlock(ptl);
-		put_huge_zero_page();
+		tlb_remove_page(tlb, pmd_page(orig_pmd));
 	} else {
 		struct page *page = pmd_page(orig_pmd);
 		page_remove_rmap(page, true);
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..11915bd0f047 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -728,6 +728,11 @@ void release_pages(struct page **pages, int nr, bool cold)
 			zone = NULL;
 		}
 
+		if (is_huge_zero_page(page)) {
+			put_huge_zero_page();
+			continue;
+		}
+
 		page = compound_head(page);
 		if (!put_page_testzero(page))
 			continue;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
