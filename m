Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4EBC6B0030
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:03:39 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id h32-v6so11352520pld.15
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:03:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d9si10676630pgc.609.2018.04.16.19.03.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:03:38 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 20/21] mm, THP, swap: create PMD swap mapping when unmap the THP
Date: Tue, 17 Apr 2018 10:02:29 +0800
Message-Id: <20180417020230.26412-21-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

This is the final step of the THP swapin support.  When reclaiming a
anonymous THP, after allocating the huge swap cluster and add the THP
into swap cache, the PMD page mapping will be changed to the mapping
to the swap space.  Previously, the PMD page mapping will be split
before being changed.  In this patch, the unmap code is enhanced not
to split the PMD mapping, but create a PMD swap mapping to replace it
instead.  So later when clear the SWAP_HAS_CACHE flag in the last step
of swapout, the huge swap cluster will be kept instead of being split,
and when swapin, the huge swap cluster will be read as a whole into a
THP.  That is, the THP will not be split during swapout/swapin.  This
can eliminate the overhead of splitting/collapsing, and reduce the
page fault count, etc.  But more important, the utilization of THP is
improved greatly, that is, much more THP will be kept when swapping is
used, so that we can take full advantage of THP including its high
performance for swapout/swapin.

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
 include/linux/huge_mm.h | 11 +++++++++++
 mm/huge_memory.c        | 30 ++++++++++++++++++++++++++++++
 mm/rmap.c               | 41 +++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c             |  6 +-----
 4 files changed, 81 insertions(+), 7 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 5001c28b3d18..d03fcddcc42d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -404,6 +404,8 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+struct page_vma_mapped_walk;
+
 #ifdef CONFIG_THP_SWAP
 extern void __split_huge_swap_pmd(struct vm_area_struct *vma,
 				  unsigned long haddr,
@@ -411,6 +413,8 @@ extern void __split_huge_swap_pmd(struct vm_area_struct *vma,
 extern int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			       unsigned long address, pmd_t orig_pmd);
 extern int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd);
+extern bool set_pmd_swap_entry(struct page_vma_mapped_walk *pvmw,
+	struct page *page, unsigned long address, pmd_t pmdval);
 
 static inline bool transparent_hugepage_swapin_enabled(
 	struct vm_area_struct *vma)
@@ -452,6 +456,13 @@ static inline int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	return 0;
 }
 
+static inline bool set_pmd_swap_entry(struct page_vma_mapped_walk *pvmw,
+				      struct page *page, unsigned long address,
+				      pmd_t pmdval)
+{
+	return false;
+}
+
 static inline bool transparent_hugepage_swapin_enabled(
 	struct vm_area_struct *vma)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 51cc71ef4b83..8f2a4022d211 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1880,6 +1880,36 @@ int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	count_vm_event(THP_SWPIN_FALLBACK);
 	goto fallback;
 }
+
+bool set_pmd_swap_entry(struct page_vma_mapped_walk *pvmw, struct page *page,
+			unsigned long address, pmd_t pmdval)
+{
+	struct vm_area_struct *vma = pvmw->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	pmd_t swp_pmd;
+	swp_entry_t entry = { .val = page_private(page) };
+
+	if (swap_duplicate(&entry, true) < 0) {
+		set_pmd_at(mm, address, pvmw->pmd, pmdval);
+		return false;
+	}
+	if (list_empty(&mm->mmlist)) {
+		spin_lock(&mmlist_lock);
+		if (list_empty(&mm->mmlist))
+			list_add(&mm->mmlist, &init_mm.mmlist);
+		spin_unlock(&mmlist_lock);
+	}
+	add_mm_counter(mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+	add_mm_counter(mm, MM_SWAPENTS, HPAGE_PMD_NR);
+	swp_pmd = swp_entry_to_pmd(entry);
+	if (pmd_soft_dirty(pmdval))
+		swp_pmd = pmd_swp_mksoft_dirty(swp_pmd);
+	set_pmd_at(mm, address, pvmw->pmd, swp_pmd);
+
+	page_remove_rmap(page, true);
+	put_page(page);
+	return true;
+}
 #endif
 
 static inline void zap_deposited_table(struct mm_struct *mm, pmd_t *pmd)
diff --git a/mm/rmap.c b/mm/rmap.c
index 7eb948e1b966..4117562bc24f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1402,12 +1402,49 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				continue;
 		}
 
+		address = pvmw.address;
+
+		/* PMD-mapped THP swap entry */
+		if (thp_swap_supported() && !pvmw.pte && PageAnon(page)) {
+			pmd_t pmdval;
+
+			VM_BUG_ON_PAGE(PageHuge(page) ||
+				       !PageTransCompound(page), page);
+
+			flush_cache_range(vma, address,
+					  address + HPAGE_PMD_SIZE);
+			mmu_notifier_invalidate_range_start(mm, address,
+					address + HPAGE_PMD_SIZE);
+			if (should_defer_flush(mm, flags)) {
+				/* check comments for PTE below */
+				pmdval = pmdp_huge_get_and_clear(mm, address,
+								 pvmw.pmd);
+				set_tlb_ubc_flush_pending(mm,
+							  pmd_dirty(pmdval));
+			} else
+				pmdval = pmdp_huge_clear_flush(vma, address,
+							       pvmw.pmd);
+
+			/*
+			 * Move the dirty bit to the page. Now the pmd
+			 * is gone.
+			 */
+			if (pmd_dirty(pmdval))
+				set_page_dirty(page);
+
+			/* Update high watermark before we lower rss */
+			update_hiwater_rss(mm);
+
+			ret = set_pmd_swap_entry(&pvmw, page, address, pmdval);
+			mmu_notifier_invalidate_range_end(mm, address,
+					address + HPAGE_PMD_SIZE);
+			continue;
+		}
+
 		/* Unexpected PMD-mapped THP? */
 		VM_BUG_ON_PAGE(!pvmw.pte, page);
 
 		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
-		address = pvmw.address;
-
 
 		if (IS_ENABLED(CONFIG_MIGRATION) &&
 		    (flags & TTU_MIGRATION) &&
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8b920ce3ae02..e4ec579a11a2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1129,11 +1129,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page)) {
-			enum ttu_flags flags = ttu_flags | TTU_BATCH_FLUSH;
-
-			if (unlikely(PageTransHuge(page)))
-				flags |= TTU_SPLIT_HUGE_PMD;
-			if (!try_to_unmap(page, flags)) {
+			if (!try_to_unmap(page, ttu_flags | TTU_BATCH_FLUSH)) {
 				nr_unmap_fail++;
 				goto activate_locked;
 			}
-- 
2.17.0
