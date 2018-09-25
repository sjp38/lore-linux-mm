Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFCDF8E0041
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 03:14:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so11816169pff.12
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 00:14:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z127-v6si1787028pgb.455.2018.09.25.00.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 00:14:04 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V5 RESEND 08/21] swap: Support to read a huge swap cluster for swapin a THP
Date: Tue, 25 Sep 2018 15:13:35 +0800
Message-Id: <20180925071348.31458-9-ying.huang@intel.com>
In-Reply-To: <20180925071348.31458-1-ying.huang@intel.com>
References: <20180925071348.31458-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Daniel Jordan <daniel.m.jordan@oracle.com>

To swapin a THP in one piece, we need to read a huge swap cluster from
the swap device.  This patch revised the __read_swap_cache_async() and
its callers and callees to support this.  If __read_swap_cache_async()
find the swap cluster of the specified swap entry is huge, it will try
to allocate a THP, add it into the swap cache.  So later the contents
of the huge swap cluster can be read into the THP.

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
 include/linux/huge_mm.h | 38 ++++++++++++++++++++++++++
 include/linux/swap.h    |  4 +--
 mm/huge_memory.c        | 26 ------------------
 mm/swap_state.c         | 72 ++++++++++++++++++++++++++++++++++++-------------
 mm/swapfile.c           |  9 ++++---
 5 files changed, 99 insertions(+), 50 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 0f3e1739986f..3fdb29bc250c 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -250,6 +250,39 @@ static inline bool thp_migration_supported(void)
 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
 }
 
+/*
+ * always: directly stall for all thp allocations
+ * defer: wake kswapd and fail if not immediately available
+ * defer+madvise: wake kswapd and directly stall for MADV_HUGEPAGE, otherwise
+ *		  fail if not immediately available
+ * madvise: directly stall for MADV_HUGEPAGE, otherwise fail if not immediately
+ *	    available
+ * never: never stall for any thp allocation
+ */
+static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
+{
+	bool vma_madvised;
+
+	if (!vma)
+		return GFP_TRANSHUGE_LIGHT;
+	vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
+		     &transparent_hugepage_flags))
+		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
+		     &transparent_hugepage_flags))
+		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG,
+		     &transparent_hugepage_flags))
+		return GFP_TRANSHUGE_LIGHT |
+			(vma_madvised ? __GFP_DIRECT_RECLAIM :
+					__GFP_KSWAPD_RECLAIM);
+	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
+		     &transparent_hugepage_flags))
+		return GFP_TRANSHUGE_LIGHT |
+			(vma_madvised ? __GFP_DIRECT_RECLAIM : 0);
+	return GFP_TRANSHUGE_LIGHT;
+}
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -363,6 +396,11 @@ static inline bool thp_migration_supported(void)
 {
 	return false;
 }
+
+static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
+{
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 48c159994438..f0424db46add 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -462,7 +462,7 @@ extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
 extern int __swap_count(swp_entry_t entry);
-extern int __swp_swapcount(swp_entry_t entry);
+extern int __swp_swapcount(swp_entry_t entry, int *entry_size);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
 extern struct swap_info_struct *swp_swap_info(swp_entry_t entry);
@@ -589,7 +589,7 @@ static inline int __swap_count(swp_entry_t entry)
 	return 0;
 }
 
-static inline int __swp_swapcount(swp_entry_t entry)
+static inline int __swp_swapcount(swp_entry_t entry, int *entry_size)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e5d995195fd9..4d4a447c29a8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -620,32 +620,6 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 
 }
 
-/*
- * always: directly stall for all thp allocations
- * defer: wake kswapd and fail if not immediately available
- * defer+madvise: wake kswapd and directly stall for MADV_HUGEPAGE, otherwise
- *		  fail if not immediately available
- * madvise: directly stall for MADV_HUGEPAGE, otherwise fail if not immediately
- *	    available
- * never: never stall for any thp allocation
- */
-static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
-{
-	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
-
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY);
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM;
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     __GFP_KSWAPD_RECLAIM);
-	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     0);
-	return GFP_TRANSHUGE_LIGHT;
-}
-
 /* Caller must hold page table lock. */
 static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 376327b7b442..06f1b39e2fa8 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -385,7 +385,9 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 {
 	struct page *found_page = NULL, *new_page = NULL;
 	struct swap_info_struct *si;
-	int err;
+	int err, entry_size = 1;
+	swp_entry_t hentry;
+
 	*new_page_allocated = false;
 
 	do {
@@ -411,14 +413,40 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * as SWAP_HAS_CACHE.  That's done in later part of code or
 		 * else swap_off will be aborted if we return NULL.
 		 */
-		if (!__swp_swapcount(entry) && swap_slot_cache_enabled)
+		if (!__swp_swapcount(entry, &entry_size) &&
+		    swap_slot_cache_enabled)
 			break;
 
 		/*
 		 * Get a new page to read into from swap.
 		 */
-		if (!new_page) {
-			new_page = alloc_page_vma(gfp_mask, vma, addr);
+		if (!new_page ||
+		    (IS_ENABLED(CONFIG_THP_SWAP) &&
+		     hpage_nr_pages(new_page) != entry_size)) {
+			if (new_page)
+				put_page(new_page);
+			if (IS_ENABLED(CONFIG_THP_SWAP) &&
+			    entry_size == HPAGE_PMD_NR) {
+				gfp_t gfp = alloc_hugepage_direct_gfpmask(vma);
+
+				/*
+				 * Make sure huge page allocation flags are
+				 * compatible with that of normal page
+				 */
+				VM_WARN_ONCE(gfp_mask & ~(gfp | __GFP_RECLAIM),
+					     "ignoring gfp_mask bits: %x",
+					     gfp_mask & ~(gfp | __GFP_RECLAIM));
+				new_page = alloc_hugepage_vma(gfp, vma,
+						addr, HPAGE_PMD_ORDER);
+				if (new_page)
+					prep_transhuge_page(new_page);
+				hentry = swp_entry(swp_type(entry),
+						   round_down(swp_offset(entry),
+							      HPAGE_PMD_NR));
+			} else {
+				new_page = alloc_page_vma(gfp_mask, vma, addr);
+				hentry = entry;
+			}
 			if (!new_page)
 				break;		/* Out of memory */
 		}
@@ -426,16 +454,18 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		/*
 		 * call radix_tree_preload() while we can wait.
 		 */
-		err = radix_tree_maybe_preload(gfp_mask & GFP_KERNEL);
+		err = radix_tree_maybe_preload_order(gfp_mask & GFP_KERNEL,
+						     compound_order(new_page));
 		if (err)
 			break;
 
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
-		err = swapcache_prepare(entry, 1);
-		if (err == -EEXIST) {
+		err = swapcache_prepare(hentry, entry_size);
+		if (err)
 			radix_tree_preload_end();
+		if (err == -EEXIST) {
 			/*
 			 * We might race against get_swap_page() and stumble
 			 * across a SWAP_HAS_CACHE swap_map entry whose page
@@ -443,33 +473,36 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			 */
 			cond_resched();
 			continue;
-		}
-		if (err) {		/* swp entry is obsolete ? */
-			radix_tree_preload_end();
+		} else if (err == -ENOTDIR) {
+			/* huge swap cluster has been split under us */
+			continue;
+		} else if (err) {	/* swp entry is obsolete ? */
 			break;
 		}
 
 		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
 		__SetPageLocked(new_page);
 		__SetPageSwapBacked(new_page);
-		err = __add_to_swap_cache(new_page, entry);
+		err = __add_to_swap_cache(new_page, hentry);
+		radix_tree_preload_end();
 		if (likely(!err)) {
-			radix_tree_preload_end();
 			/*
 			 * Initiate read into locked page and return.
 			 */
 			SetPageWorkingset(new_page);
 			lru_cache_add_anon(new_page);
 			*new_page_allocated = true;
+			if (IS_ENABLED(CONFIG_THP_SWAP))
+				new_page += swp_offset(entry) &
+					(entry_size - 1);
 			return new_page;
 		}
-		radix_tree_preload_end();
 		__ClearPageLocked(new_page);
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		put_swap_page(new_page, entry);
+		put_swap_page(new_page, hentry);
 	} while (err != -ENOMEM);
 
 	if (new_page)
@@ -491,7 +524,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			vma, addr, &page_was_allocated);
 
 	if (page_was_allocated)
-		swap_readpage(retpage, do_poll);
+		swap_readpage(compound_head(retpage), do_poll);
 
 	return retpage;
 }
@@ -610,8 +643,9 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 		if (!page)
 			continue;
 		if (page_allocated) {
-			swap_readpage(page, false);
-			if (offset != entry_offset) {
+			swap_readpage(compound_head(page), false);
+			if (offset != entry_offset &&
+			    !PageTransCompound(page)) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
 			}
@@ -772,8 +806,8 @@ static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 		if (!page)
 			continue;
 		if (page_allocated) {
-			swap_readpage(page, false);
-			if (i != ra_info.offset) {
+			swap_readpage(compound_head(page), false);
+			if (i != ra_info.offset && !PageTransCompound(page)) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
 			}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index ef2b42c199c0..3fe50f1da0a0 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1542,7 +1542,8 @@ int __swap_count(swp_entry_t entry)
 	return count;
 }
 
-static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
+static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry,
+			  int *entry_size)
 {
 	int count = 0;
 	pgoff_t offset = swp_offset(entry);
@@ -1550,6 +1551,8 @@ static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
 
 	ci = lock_cluster_or_swap_info(si, offset);
 	count = swap_count(si->swap_map[offset]);
+	if (entry_size)
+		*entry_size = ci && cluster_is_huge(ci) ? SWAPFILE_CLUSTER : 1;
 	unlock_cluster_or_swap_info(si, ci);
 	return count;
 }
@@ -1559,14 +1562,14 @@ static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
  * This does not give an exact answer when swap count is continued,
  * but does include the high COUNT_CONTINUED flag to allow for that.
  */
-int __swp_swapcount(swp_entry_t entry)
+int __swp_swapcount(swp_entry_t entry, int *entry_size)
 {
 	int count = 0;
 	struct swap_info_struct *si;
 
 	si = get_swap_device(entry);
 	if (si) {
-		count = swap_swapcount(si, entry);
+		count = swap_swapcount(si, entry, entry_size);
 		put_swap_device(si);
 	}
 	return count;
-- 
2.16.4
