Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD7D6B04B5
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:40:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e3so8624299pfe.15
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:40:16 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z9-v6si21682595plk.94.2018.05.09.01.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 01:40:14 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2 21/21] mm, THP: Avoid to split THP when reclaim MADV_FREE THP
Date: Wed,  9 May 2018 16:38:46 +0800
Message-Id: <20180509083846.14823-22-ying.huang@intel.com>
In-Reply-To: <20180509083846.14823-1-ying.huang@intel.com>
References: <20180509083846.14823-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

Previously, to reclaim MADV_FREE THP, the THP will be split firstly,
then reclaim each sub-pages.  This wastes cycles to split THP and
unmap and free each sub-pages, and split THP even if it has been
written since MADV_FREE.  We have to do this because MADV_FREE THP
reclaiming shares same try_to_unmap() calling with swap, while swap
needs to split the PMD page mapping at that time.  Now swap can
process PMD mapping, this makes it easy to avoid to split THP when
MADV_FREE THP is reclaimed.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
---
 mm/huge_memory.c | 41 ++++++++++++++++++++++++++++++++---------
 mm/vmscan.c      |  3 ++-
 2 files changed, 34 insertions(+), 10 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 982369511bcc..2a20e0aaba48 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1674,6 +1674,15 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	return 0;
 }
 
+static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
+{
+	pgtable_t pgtable;
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pte_free(mm, pgtable);
+	mm_dec_nr_ptes(mm);
+}
+
 #ifdef CONFIG_THP_SWAP
 void __split_huge_swap_pmd(struct vm_area_struct *vma,
 			   unsigned long haddr,
@@ -1888,6 +1897,28 @@ bool set_pmd_swap_entry(struct page_vma_mapped_walk *pvmw, struct page *page,
 	pmd_t swp_pmd;
 	swp_entry_t entry = { .val = page_private(page) };
 
+	if (unlikely(PageSwapBacked(page) != PageSwapCache(page))) {
+		WARN_ON_ONCE(1);
+		return false;
+	}
+
+	/* MADV_FREE page check */
+	if (!PageSwapBacked(page)) {
+		if (!PageDirty(page)) {
+			zap_deposited_table(mm, pvmw->pmd);
+			add_mm_counter(mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			goto out_remove_rmap;
+		}
+
+		/*
+		 * If the page was redirtied, it cannot be
+		 * discarded. Remap the page to page table.
+		 */
+		set_pmd_at(mm, address, pvmw->pmd, pmdval);
+		SetPageSwapBacked(page);
+		return false;
+	}
+
 	if (swap_duplicate(&entry, true) < 0) {
 		set_pmd_at(mm, address, pvmw->pmd, pmdval);
 		return false;
@@ -1905,21 +1936,13 @@ bool set_pmd_swap_entry(struct page_vma_mapped_walk *pvmw, struct page *page,
 		swp_pmd = pmd_swp_mksoft_dirty(swp_pmd);
 	set_pmd_at(mm, address, pvmw->pmd, swp_pmd);
 
+out_remove_rmap:
 	page_remove_rmap(page, true);
 	put_page(page);
 	return true;
 }
 #endif
 
-static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
-{
-	pgtable_t pgtable;
-
-	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
-	pte_free(mm, pgtable);
-	mm_dec_nr_ptes(mm);
-}
-
 /*
  * Return true if we do MADV_FREE successfully on entire pmd page.
  * Otherwise, return false.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b71c1bbad932..7cf5a18da5a2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1137,7 +1137,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				/* Adding to swap updated mapping */
 				mapping = page_mapping(page);
 			}
-		} else if (unlikely(PageTransHuge(page))) {
+		} else if (unlikely(PageTransHuge(page)) &&
+			   (!thp_swap_supported() || !PageAnon(page))) {
 			/* Split file THP */
 			if (split_huge_page_to_list(page, page_list))
 				goto keep_locked;
-- 
2.16.1
