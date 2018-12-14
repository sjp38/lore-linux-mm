Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B96DD8E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 01:28:02 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h11so3564609pfj.13
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 22:28:02 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v19si3555849pfa.80.2018.12.13.22.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 22:28:01 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V9 07/21] swap: Support PMD swap mapping when splitting huge PMD
Date: Fri, 14 Dec 2018 14:27:40 +0800
Message-Id: <20181214062754.13723-8-ying.huang@intel.com>
In-Reply-To: <20181214062754.13723-1-ying.huang@intel.com>
References: <20181214062754.13723-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

A huge PMD need to be split when zap a part of the PMD mapping etc.
If the PMD mapping is a swap mapping, we need to split it too.  This
patch implemented the support for this.  This is similar as splitting
the PMD page mapping, except we need to decrease the PMD swap mapping
count for the huge swap cluster too.  If the PMD swap mapping count
becomes 0, the huge swap cluster will be split.

Notice: is_huge_zero_pmd() and pmd_page() doesn't work well with swap
PMD, so pmd_present() check is called before them.

Thanks Daniel Jordan for testing and reporting a data corruption bug
caused by misaligned address processing issue in __split_huge_swap_pmd().

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/huge_mm.h |  4 ++++
 include/linux/swap.h    |  6 +++++
 mm/huge_memory.c        | 49 ++++++++++++++++++++++++++++++++++++-----
 mm/swapfile.c           | 32 +++++++++++++++++++++++++++
 4 files changed, 86 insertions(+), 5 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 4663ee96cf59..1c0fda003d6a 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -226,6 +226,10 @@ static inline bool is_huge_zero_page(struct page *page)
 	return READ_ONCE(huge_zero_page) == page;
 }
 
+/*
+ * is_huge_zero_pmd() must be called after checking pmd_present(),
+ * otherwise, it may report false positive for PMD swap entry.
+ */
 static inline bool is_huge_zero_pmd(pmd_t pmd)
 {
 	return is_huge_zero_page(pmd_page(pmd));
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 24c3014894dd..a24d101b131d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -619,11 +619,17 @@ static inline swp_entry_t get_swap_page(struct page *page)
 
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
index bd2543e10938..49df3e7c96c7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1617,6 +1617,41 @@ vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 	return 0;
 }
 
+/* Convert a PMD swap mapping to a set of PTE swap mappings */
+static void __split_huge_swap_pmd(struct vm_area_struct *vma,
+				  unsigned long addr,
+				  pmd_t *pmd)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgtable_t pgtable;
+	pmd_t _pmd;
+	swp_entry_t entry;
+	int i, soft_dirty;
+
+	addr &= HPAGE_PMD_MASK;
+	entry = pmd_to_swp_entry(*pmd);
+	soft_dirty = pmd_soft_dirty(*pmd);
+
+	split_swap_cluster_map(entry);
+
+	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
+	pmd_populate(mm, &_pmd, pgtable);
+
+	for (i = 0; i < HPAGE_PMD_NR; i++, addr += PAGE_SIZE, entry.val++) {
+		pte_t *pte, ptent;
+
+		pte = pte_offset_map(&_pmd, addr);
+		VM_BUG_ON(!pte_none(*pte));
+		ptent = swp_entry_to_pte(entry);
+		if (soft_dirty)
+			ptent = pte_swp_mksoft_dirty(ptent);
+		set_pte_at(mm, addr, pte, ptent);
+		pte_unmap(pte);
+	}
+	smp_wmb(); /* make pte visible before pmd */
+	pmd_populate(mm, pmd, pgtable);
+}
+
 /*
  * Return true if we do MADV_FREE successfully on entire pmd page.
  * Otherwise, return false.
@@ -2082,7 +2117,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	VM_BUG_ON(haddr & ~HPAGE_PMD_MASK);
 	VM_BUG_ON_VMA(vma->vm_start > haddr, vma);
 	VM_BUG_ON_VMA(vma->vm_end < haddr + HPAGE_PMD_SIZE, vma);
-	VM_BUG_ON(!is_pmd_migration_entry(*pmd) && !pmd_trans_huge(*pmd)
+	VM_BUG_ON(!is_swap_pmd(*pmd) && !pmd_trans_huge(*pmd)
 				&& !pmd_devmap(*pmd));
 
 	count_vm_event(THP_SPLIT_PMD);
@@ -2106,7 +2141,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		put_page(page);
 		add_mm_counter(mm, mm_counter_file(page), -HPAGE_PMD_NR);
 		return;
-	} else if (is_huge_zero_pmd(*pmd)) {
+	} else if (pmd_present(*pmd) && is_huge_zero_pmd(*pmd)) {
 		/*
 		 * FIXME: Do we want to invalidate secondary mmu by calling
 		 * mmu_notifier_invalidate_range() see comments below inside
@@ -2150,6 +2185,9 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 		page = pfn_to_page(swp_offset(entry));
 	} else
 #endif
+	if (IS_ENABLED(CONFIG_THP_SWAP) && is_swap_pmd(old_pmd))
+		return __split_huge_swap_pmd(vma, haddr, pmd);
+	else
 		page = pmd_page(old_pmd);
 	VM_BUG_ON_PAGE(!page_count(page), page);
 	page_ref_add(page, HPAGE_PMD_NR - 1);
@@ -2243,14 +2281,15 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
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
 	__split_huge_pmd_locked(vma, pmd, range.start, freeze);
 out:
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 243131253238..d38760b6d495 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3942,6 +3942,38 @@ void mem_cgroup_throttle_swaprate(struct mem_cgroup *memcg, int node,
 }
 #endif
 
+#ifdef CONFIG_THP_SWAP
+/*
+ * The corresponding page table shouldn't be changed under us, that
+ * is, the page table lock should be held.
+ */
+int split_swap_cluster_map(swp_entry_t entry)
+{
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci;
+	unsigned long offset = swp_offset(entry);
+
+	VM_BUG_ON(!IS_ALIGNED(offset, SWAPFILE_CLUSTER));
+	si = _swap_info_get(entry);
+	if (!si)
+		return -EBUSY;
+	ci = lock_cluster(si, offset);
+	/* The swap cluster has been split by someone else, we are done */
+	if (!cluster_is_huge(ci))
+		goto out;
+	cluster_add_swapcount(ci, -1);
+	/*
+	 * If the last PMD swap mapping has gone and the THP isn't in
+	 * swap cache, the huge swap cluster will be split.
+	 */
+	if (!cluster_swapcount(ci) && !(si->swap_map[offset] & SWAP_HAS_CACHE))
+		cluster_clear_huge(ci);
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
2.18.1
