Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDDA6B000E
	for <linux-mm@kvack.org>; Wed, 23 May 2018 04:26:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e16-v6so12797020pfn.5
        for <linux-mm@kvack.org>; Wed, 23 May 2018 01:26:49 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id y16-v6si17687140pfm.140.2018.05.23.01.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 01:26:48 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V3 06/21] mm, THP, swap: Support PMD swap mapping when splitting huge PMD
Date: Wed, 23 May 2018 16:26:10 +0800
Message-Id: <20180523082625.6897-7-ying.huang@intel.com>
In-Reply-To: <20180523082625.6897-1-ying.huang@intel.com>
References: <20180523082625.6897-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

A huge PMD need to be split when zap a part of the PMD mapping etc.
If the PMD mapping is a swap mapping, we need to split it too.  This
patch implemented the support for this.  This is similar as splitting
the PMD page mapping, except we need to decrease the PMD swap mapping
count for the huge swap cluster too.  If the PMD swap mapping count
becomes 0, the huge swap cluster will be split.

Notice: is_huge_zero_pmd() and pmd_page() doesn't work well with swap
PMD, so pmd_present() check is called before them.

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
 include/linux/swap.h |  6 ++++++
 mm/huge_memory.c     | 58 +++++++++++++++++++++++++++++++++++++++++++++++-----
 mm/swapfile.c        | 28 +++++++++++++++++++++++++
 3 files changed, 87 insertions(+), 5 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7ed2c727c9b6..bb9de2cb952a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -618,11 +618,17 @@ static inline swp_entry_t get_swap_page(struct page *page)
 
 #ifdef CONFIG_THP_SWAP
 extern int split_swap_cluster(swp_entry_t entry);
+extern int split_swap_cluster_map(swp_entry_t entry);
 #else
 static inline int split_swap_cluster(swp_entry_t entry)
 {
 	return 0;
 }
+
+static inline int split_swap_cluster_map(swp_entry_t entry)
+{
+	return 0;
+}
 #endif
 
 #ifdef CONFIG_MEMCG
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e9177363fe2e..84d5d8ff869e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1602,6 +1602,47 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	return 0;
 }
 
+#ifdef CONFIG_THP_SWAP
+static void __split_huge_swap_pmd(struct vm_area_struct *vma,
+				  unsigned long haddr,
+				  pmd_t *pmd)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	swp_entry_t entry;
+	int i, soft_dirty;
+
+	entry = pmd_to_swp_entry(*pmd);
+	soft_dirty = pmd_soft_dirty(*pmd);
+
+	split_swap_cluster_map(entry);
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE, entry.val++) {
+		pte_t *pte, ptent;
+
+		pte = pte_offset_map(&_pmd, haddr);
+		VM_BUG_ON(!pte_none(*pte));
+		ptent = swp_entry_to_pte(entry);
+		if (soft_dirty)
+			ptent = pte_swp_mksoft_dirty(ptent);
+		set_pte_at(mm, haddr, pte, ptent);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(mm, pmd, pgtable);
+}
+#else
+static inline void __split_huge_swap_pmd(struct vm_area_struct *vma,
+					 unsigned long haddr,
+					 pmd_t *pmd)
+{
+}
+#endif
+
 /*
  * Return true if we do MADV_FREE successfully on entire pmd page.
  * Otherwise, return false.
@@ -2068,7 +2109,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
 	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
-	VM_BUG_ON(!is_pmd_migration_entry(*pmd) && !pmd_trans_huge(*pmd)
+	VM_BUG_ON(!is_swap_pmd(*pmd) && !pmd_trans_huge(*pmd)
 				&& !pmd_devmap(*pmd));
 
 	count_vm_event(THP_SPLIT_PMD);
@@ -2090,8 +2131,11 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		put_page(page);
 		add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
 		return;
-	} else if (is_huge_zero_pmd(*pmd)) {
+	} else if (pmd_present(*pmd) && is_huge_zero_pmd(*pmd)) {
 		/*
+		 * is_huge_zero_pmd() may return true for PMD swap
+		 * entry, so checking pmd_present() firstly.
+		 *
 		 * FIXME: Do we want to invalidate secondary mmu by calling
 		 * mmu_notifier_invalidate_range() see comments below inside
 		 * __split_huge_pmd() ?
@@ -2134,6 +2178,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		page = pfn_to_page(swp_offset(entry));
 	} else
 #endif
+	if (thp_swap_supported() && is_swap_pmd(old_pmd))
+		return __split_huge_swap_pmd(vma, haddr, pmd);
+	else
 		page = pmd_page(old_pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
@@ -2225,14 +2272,15 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 	 * pmd against. Otherwise we can end up replacing wrong page.
 	 */
 	VM_BUG_ON(freeze && !page);
-	if (page && page != pmd_page(*pmd))
-	        goto out;
+	/* pmd_page() should be called only if pmd_present() */
+	if (page && (!pmd_present(*pmd) || page != pmd_page(*pmd)))
+		goto out;
 
 	if (pmd_trans_huge(*pmd)) {
 		page = pmd_page(*pmd);
 		if (PageMlocked(page))
 			clear_page_mlock(page);
-	} else if (!(pmd_devmap(*pmd) || is_pmd_migration_entry(*pmd)))
+	} else if (!(pmd_devmap(*pmd) || is_swap_pmd(*pmd)))
 		goto out;
 	__split_huge_pmd_locked(vma, pmd, haddr, freeze);
 out:
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 46117d6913ad..05f53c4c0cfe 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -4046,6 +4046,34 @@ static void free_swap_count_continuations(struct swap_info_struct *si)
 	}
 }
 
+#ifdef CONFIG_THP_SWAP
+/* The corresponding page table shouldn't be changed under us */
+int split_swap_cluster_map(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+
+	VM_BUG_ON(!is_cluster_offset(offset));
+	si = _swap_info_get(entry);
+	if (!si)
+		return -EBUSY;
+	ci = lock_cluster(si, offset);
+	/* The swap cluster has been split by someone else */
+	if (!cluster_is_huge(ci))
+		goto out;
+	cluster_set_count(ci, cluster_count(ci) - 1);
+	VM_BUG_ON(cluster_count(ci) < SWAPFILE_CLUSTER);
+	if (cluster_count(ci) == SWAPFILE_CLUSTER &&
+	    !(si->swap_map[offset] & SWAP_HAS_CACHE))
+		cluster_clear_huge(ci);
+
+out:
+	unlock_cluster(ci);
+	return 0;
+}
+#endif
+
 static int __init swapfile_init(void)
 {
 	int nid;
-- 
2.16.1
