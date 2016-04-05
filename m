Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D2DEB6B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 06:13:04 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id e128so8032224pfe.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 03:13:04 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id o65si658708pfo.226.2016.04.05.03.13.03
        for <linux-mm@kvack.org>;
        Tue, 05 Apr 2016 03:13:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2] thp: keep huge zero page pinned until tlb flush
Date: Tue,  5 Apr 2016 13:12:34 +0300
Message-Id: <1459851154-112706-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Andrea has found[1] a race condition on MMU-gather based TLB flush vs
split_huge_page() or shrinker which frees huge zero under us (patch 1/2
and 2/2 respectively).

With new THP refcounting, we don't need patch 1/2: mmu_gather keeps the
page pinned until flush is complete and the pin prevents the page from
being split under us.

We still need patch 2/2. This is simplified version of Andrea's patch.
We don't need fancy encoding.

[1] http://lkml.kernel.org/r/1447938052-22165-1-git-send-email-aarcange@redhat.com

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Andrea Arcangeli <aarcange@redhat.com>
---
 v2:
   - fix build for !THP;
   - typos;
---
 include/linux/huge_mm.h | 5 +++++
 mm/huge_memory.c        | 6 +++---
 mm/swap.c               | 5 +++++
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 7008623e24b1..d7b9e5346fba 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -152,6 +152,7 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 }
 
 struct page *get_huge_zero_page(void);
+void put_huge_zero_page(void);
 
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
@@ -208,6 +209,10 @@ static inline bool is_huge_zero_page(struct page *page)
 	return false;
 }
 
+static inline void put_huge_zero_page(void)
+{
+	BUILD_BUG();
+}
 
 static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
 		unsigned long addr, pmd_t *pmd, int flags)
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
