Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDD538E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 01:28:19 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id h10so2933692plk.12
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 22:28:19 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v19si3555849pfa.80.2018.12.13.22.28.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 22:28:18 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V9 13/21] swap: Support PMD swap mapping in swapoff
Date: Fri, 14 Dec 2018 14:27:46 +0800
Message-Id: <20181214062754.13723-14-ying.huang@intel.com>
In-Reply-To: <20181214062754.13723-1-ying.huang@intel.com>
References: <20181214062754.13723-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

During swapoff, for each PMD swap mapping, we will allocate a THP,
read the contents of the huge swap cluster into the THP and change the
PMD swap mapping to the PMD page mapping to the THP, then try to free
the huge swap cluster.  If failed to allocate a THP, the huge swap
cluster will be split.

If the swap cluster mapped by a PMD swap mapping has been split
already, we will split the PMD swap mapping and unuse the PTEs.

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
 include/asm-generic/pgtable.h |  14 +----
 include/linux/huge_mm.h       |   8 +++
 mm/huge_memory.c              |   4 +-
 mm/swapfile.c                 | 108 +++++++++++++++++++++++++++++++++-
 4 files changed, 119 insertions(+), 15 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 2a619f378297..d2d4d520e2e7 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -931,22 +931,12 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
 	barrier();
 #endif
 	/*
-	 * !pmd_present() checks for pmd migration entries
-	 *
-	 * The complete check uses is_pmd_migration_entry() in linux/swapops.h
-	 * But using that requires moving current function and pmd_trans_unstable()
-	 * to linux/swapops.h to resovle dependency, which is too much code move.
-	 *
-	 * !pmd_present() is equivalent to is_pmd_migration_entry() currently,
-	 * because !pmd_present() pages can only be under migration not swapped
-	 * out.
-	 *
-	 * pmd_none() is preseved for future condition checks on pmd migration
+	 * pmd_none() is preseved for future condition checks on pmd swap
 	 * entries and not confusing with this function name, although it is
 	 * redundant with !pmd_present().
 	 */
 	if (pmd_none(pmdval) || pmd_trans_huge(pmdval) ||
-		(IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION) && !pmd_present(pmdval)))
+	    (IS_ENABLED(CONFIG_HAVE_PMD_SWAP_ENTRY) && !pmd_present(pmdval)))
 		return 1;
 	if (unlikely(pmd_bad(pmdval))) {
 		pmd_clear_bad(pmd);
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 06dbbcf6a6dd..7c72e63757af 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -374,6 +374,8 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #ifdef CONFIG_THP_SWAP
+extern int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+			       unsigned long address, pmd_t orig_pmd);
 extern int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 static inline bool transparent_hugepage_swapin_enabled(
@@ -399,6 +401,12 @@ static inline bool transparent_hugepage_swapin_enabled(
 	return false;
 }
 #else /* CONFIG_THP_SWAP */
+static inline int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+				      unsigned long address, pmd_t orig_pmd)
+{
+	return 0;
+}
+
 static inline int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	return 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8e8952938c25..fdffa07bff98 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1706,8 +1706,8 @@ static void __split_huge_swap_pmd(struct vm_area_struct *vma,
 }
 
 #ifdef CONFIG_THP_SWAP
-static int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-			       unsigned long address, pmd_t orig_pmd)
+int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+			unsigned long address, pmd_t orig_pmd)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	spinlock_t *ptl;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index e27fe24a1f41..454e993bc32f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1931,6 +1931,11 @@ static inline int pte_same_as_swp(pte_t pte, pte_t swp_pte)
 	return pte_same(pte_swp_clear_soft_dirty(pte), swp_pte);
 }
 
+static inline int pmd_same_as_swp(pmd_t pmd, pmd_t swp_pmd)
+{
+	return pmd_same(pmd_swp_clear_soft_dirty(pmd), swp_pmd);
+}
+
 /*
  * No need to decide whether this PTE shares the swap entry with others,
  * just let do_wp_page work it out if a write is requested later - to
@@ -1992,6 +1997,53 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	return ret;
 }
 
+#ifdef CONFIG_THP_SWAP
+static int unuse_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		     unsigned long addr, swp_entry_t entry, struct page *page)
+{
+	struct mem_cgroup *memcg;
+	spinlock_t *ptl;
+	int ret = 1;
+
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL,
+				  &memcg, true)) {
+		ret = -ENOMEM;
+		goto out_nolock;
+	}
+
+	ptl = pmd_lock(vma->vm_mm, pmd);
+	if (unlikely(!pmd_same_as_swp(*pmd, swp_entry_to_pmd(entry)))) {
+		mem_cgroup_cancel_charge(page, memcg, true);
+		ret = 0;
+		goto out;
+	}
+
+	add_mm_counter(vma->vm_mm, MM_SWAPENTS, -HPAGE_PMD_NR);
+	add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
+	get_page(page);
+	set_pmd_at(vma->vm_mm, addr, pmd,
+		   pmd_mkold(mk_huge_pmd(page, vma->vm_page_prot)));
+	page_add_anon_rmap(page, vma, addr, true);
+	mem_cgroup_commit_charge(page, memcg, true, true);
+	swap_free(entry, HPAGE_PMD_NR);
+	/*
+	 * Move the page to the active list so it is not
+	 * immediately swapped out again after swapon.
+	 */
+	activate_page(page);
+out:
+	spin_unlock(ptl);
+out_nolock:
+	return ret;
+}
+#else
+static int unuse_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+		     unsigned long addr, swp_entry_t entry, struct page *page)
+{
+	return 0;
+}
+#endif
+
 /*
  * unuse_pte can return 1. Use a unique return value in this
  * context to denote requested frontswap pages are unused.
@@ -2072,14 +2124,68 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 				unsigned int type,
 				unsigned long *fs_pages_to_unuse)
 {
-	pmd_t *pmd;
+	pmd_t *pmd, orig_pmd;
+	struct page *page;
+	swp_entry_t entry;
+	struct swap_info_struct *si;
 	unsigned long next;
 	int ret;
 
+	si = swap_info[type];
 	pmd = pmd_offset(pud, addr);
 	do {
 		cond_resched();
 		next = pmd_addr_end(addr, end);
+restart:
+		orig_pmd = *pmd;
+		if (IS_ENABLED(CONFIG_THP_SWAP) && !*fs_pages_to_unuse &&
+		    is_swap_pmd(orig_pmd)) {
+			entry = pmd_to_swp_entry(orig_pmd);
+			if (swp_type(entry) != type)
+				continue;
+
+			if (!transparent_hugepage_swapin_enabled(vma))
+				goto split;
+
+swapin:
+			page = read_swap_cache_async(entry, GFP_HIGHUSER_MOVABLE,
+						     vma, addr, false);
+			if (!page) {
+				if (!pmd_same(*pmd, orig_pmd))
+					goto restart;
+				goto split;
+			}
+
+			/*
+			 * Huge cluster has been split already, split
+			 * PMD swap mapping and fallback to unuse PTE
+			 */
+			if (!PageTransCompound(page))
+				goto fallback;
+
+			lock_page(page);
+			wait_on_page_writeback(page);
+			ret = unuse_pmd(vma, pmd, addr, entry, page);
+			if (ret < 0) {
+				unlock_page(page);
+				put_page(page);
+				return ret;
+			}
+
+			try_to_free_swap(page);
+			unlock_page(page);
+			put_page(page);
+
+			continue;
+split:
+			ret = split_swap_cluster(entry, 0);
+			if (ret == -EEXIST)
+				goto swapin;
+fallback:
+			if (split_huge_swap_pmd(vma, pmd,
+						addr, orig_pmd))
+				goto restart;
+		}
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
 		ret = unuse_pte_range(vma, pmd, addr, next, type,
-- 
2.18.1
