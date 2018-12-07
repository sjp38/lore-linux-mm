Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 012206B7EA8
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:42:03 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s14so2381213pfk.16
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:42:02 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cf16si2126256plb.227.2018.12.06.21.42.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 21:42:01 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V8 12/21] swap: Support PMD swap mapping in swapoff
Date: Fri,  7 Dec 2018 13:41:12 +0800
Message-Id: <20181207054122.27822-13-ying.huang@intel.com>
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com>
References: <20181207054122.27822-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

During swapoff, for a huge swap cluster, we need to allocate a THP,
read its contents into the THP and unuse the PMD and PTE swap mappings
to it.  If failed to allocate a THP, the huge swap cluster will be
split.

During unuse, if it is found that the swap cluster mapped by a PMD
swap mapping is split already, we will split the PMD swap mapping and
unuse the PTEs.

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
 include/asm-generic/pgtable.h | 14 +-----
 include/linux/huge_mm.h       |  8 ++++
 mm/huge_memory.c              |  4 +-
 mm/swapfile.c                 | 86 ++++++++++++++++++++++++++++++++++-
 4 files changed, 97 insertions(+), 15 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 20aab7bfd487..5216124ba13c 100644
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
index ea4999a4b6cd..6236f8b1d04b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -376,6 +376,8 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #ifdef CONFIG_THP_SWAP
+extern int split_huge_swap_pmd(struct vm_area_struct *vma, pmd_t *pmd,
+			       unsigned long address, pmd_t orig_pmd);
 extern int do_huge_pmd_swap_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 static inline bool transparent_hugepage_swapin_enabled(
@@ -401,6 +403,12 @@ static inline bool transparent_hugepage_swapin_enabled(
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
index 0ae7f824dbeb..f3c0a9e8fb9a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1721,8 +1721,8 @@ static void __split_huge_swap_pmd(struct vm_area_struct *vma,
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
index c22c11b4a879..b85ec810d941 100644
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
 static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
 				swp_entry_t entry, struct page *page)
@@ -2032,7 +2084,7 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
 				swp_entry_t entry, struct page *page)
 {
-	pmd_t *pmd;
+	pmd_t swp_pmd = swp_entry_to_pmd(entry), *pmd, orig_pmd;
 	unsigned long next;
 	int ret;
 
@@ -2040,6 +2092,27 @@ static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 	do {
 		cond_resched();
 		next = pmd_addr_end(addr, end);
+		orig_pmd = *pmd;
+		if (IS_ENABLED(CONFIG_THP_SWAP) && is_swap_pmd(orig_pmd)) {
+			if (likely(!pmd_same_as_swp(orig_pmd, swp_pmd)))
+				continue;
+			/*
+			 * Huge cluster has been split already, split
+			 * PMD swap mapping and fallback to unuse PTE
+			 */
+			if (!PageTransCompound(page)) {
+				ret = split_huge_swap_pmd(vma, pmd,
+							  addr, orig_pmd);
+				if (ret)
+					return ret;
+				ret = unuse_pte_range(vma, pmd, addr,
+						      next, entry, page);
+			} else
+				ret = unuse_pmd(vma, pmd, addr, entry, page);
+			if (ret)
+				return ret;
+			continue;
+		}
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
 		ret = unuse_pte_range(vma, pmd, addr, next, entry, page);
@@ -2233,6 +2306,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 	 * there are races when an instance of an entry might be missed.
 	 */
 	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
+retry:
 		if (signal_pending(current)) {
 			retval = -EINTR;
 			break;
@@ -2248,6 +2322,8 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		page = read_swap_cache_async(entry,
 					GFP_HIGHUSER_MOVABLE, NULL, 0, false);
 		if (!page) {
+			struct swap_cluster_info *ci = NULL;
+
 			/*
 			 * Either swap_duplicate() failed because entry
 			 * has been freed independently, and will not be
@@ -2264,6 +2340,14 @@ int try_to_unuse(unsigned int type, bool frontswap,
 			 */
 			if (!swcount || swcount == SWAP_MAP_BAD)
 				continue;
+			if (si->cluster_info)
+				ci = si->cluster_info + i / SWAPFILE_CLUSTER;
+			/* Split huge cluster if failed to allocate huge page */
+			if (cluster_is_huge(ci)) {
+				retval = split_swap_cluster(entry, 0);
+				if (!retval || retval == -EEXIST)
+					goto retry;
+			}
 			retval = -ENOMEM;
 			break;
 		}
-- 
2.18.1
