Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3B466B0010
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 22:03:01 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so11342787plh.7
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 19:03:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b7si2783831pfh.257.2018.04.16.19.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 19:03:00 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 08/21] mm, THP, swap: Support to read a huge swap cluster for swapin a THP
Date: Tue, 17 Apr 2018 10:02:17 +0800
Message-Id: <20180417020230.26412-9-ying.huang@intel.com>
In-Reply-To: <20180417020230.26412-1-ying.huang@intel.com>
References: <20180417020230.26412-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

From: Huang Ying <ying.huang@intel.com>

To swapin a THP as a whole, we need to read a huge swap cluster from
the swap device.  This patch revised the __read_swap_cache_async() and
its callee to support this.  If __read_swap_cache_async() find the
swap cluster of the specified swap entry is huge, it will try to
allocate a THP, add it into the swap cache.  So later the contents of
the huge swap cluster can be read into the THP.

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
 include/linux/huge_mm.h | 38 ++++++++++++++++++++++++
 include/linux/swap.h    |  4 +--
 mm/huge_memory.c        | 26 ----------------
 mm/swap_state.c         | 66 +++++++++++++++++++++++++++++------------
 mm/swapfile.c           | 11 ++++---
 5 files changed, 94 insertions(+), 51 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 0d0cfddbf4b7..0dbfbe34b01a 100644
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
@@ -362,6 +395,11 @@ static inline bool thp_migration_supported(void)
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
index 42e962b9ad3c..c42e7edcf141 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -462,7 +462,7 @@ extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
 extern int page_swapcount(struct page *);
 extern int __swap_count(swp_entry_t entry);
-extern int __swp_swapcount(swp_entry_t entry);
+extern int __swp_swapcount(swp_entry_t entry, bool *huge_cluster);
 extern int swp_swapcount(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
 extern struct swap_info_struct *swp_swap_info(swp_entry_t entry);
@@ -589,7 +589,7 @@ static inline int __swap_count(swp_entry_t entry)
 	return 0;
 }
 
-static inline int __swp_swapcount(swp_entry_t entry)
+static inline int __swp_swapcount(swp_entry_t entry, bool *huge_cluster)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a2124f0a0454..a40e27447cac 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -623,32 +623,6 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
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
index fe079756bb18..53e807a24ec5 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -389,6 +389,9 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	struct page *found_page = NULL, *new_page = NULL;
 	struct swap_info_struct *si;
 	int err;
+	bool huge_cluster = false;
+	swp_entry_t hentry;
+
 	*new_page_allocated = false;
 
 	do {
@@ -414,14 +417,32 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * as SWAP_HAS_CACHE.  That's done in later part of code or
 		 * else swap_off will be aborted if we return NULL.
 		 */
-		if (!__swp_swapcount(entry) && swap_slot_cache_enabled)
+		if (!__swp_swapcount(entry, &huge_cluster) &&
+		    swap_slot_cache_enabled)
 			break;
 
 		/*
 		 * Get a new page to read into from swap.
 		 */
-		if (!new_page) {
-			new_page = alloc_page_vma(gfp_mask, vma, addr);
+		if (!new_page ||
+		    (thp_swap_supported() &&
+		     !!PageTransCompound(new_page) != huge_cluster)) {
+			if (new_page)
+				put_page(new_page);
+			if (thp_swap_supported() && huge_cluster) {
+				gfp_t gfp = alloc_hugepage_direct_gfpmask(vma);
+
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
@@ -429,33 +450,37 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
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
-		err = swapcache_prepare(entry);
-		if (err == -EEXIST) {
-			radix_tree_preload_end();
-			/*
-			 * We might race against get_swap_page() and stumble
-			 * across a SWAP_HAS_CACHE swap_map entry whose page
-			 * has not been brought into the swapcache yet.
-			 */
-			cond_resched();
-			continue;
-		}
-		if (err) {		/* swp entry is obsolete ? */
+		err = swapcache_prepare(hentry, huge_cluster);
+		if (err) {
 			radix_tree_preload_end();
-			break;
+			if (err == -EEXIST) {
+				/*
+				 * We might race against get_swap_page() and
+				 * stumble across a SWAP_HAS_CACHE swap_map
+				 * entry whose page has not been brought into
+				 * the swapcache yet.
+				 */
+				cond_resched();
+				continue;
+			} else if (err == -ENOTDIR) {
+				/* huge swap cluster is split under us */
+				continue;
+			} else		/* swp entry is obsolete ? */
+				break;
 		}
 
 		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
 		__SetPageLocked(new_page);
 		__SetPageSwapBacked(new_page);
-		err = __add_to_swap_cache(new_page, entry);
+		err = __add_to_swap_cache(new_page, hentry);
 		if (likely(!err)) {
 			radix_tree_preload_end();
 			/*
@@ -463,6 +488,9 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			 */
 			lru_cache_add_anon(new_page);
 			*new_page_allocated = true;
+			if (thp_swap_supported() && huge_cluster)
+				new_page += swp_offset(entry) &
+					(HPAGE_PMD_NR - 1);
 			return new_page;
 		}
 		radix_tree_preload_end();
@@ -471,7 +499,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		put_swap_page(new_page, entry);
+		put_swap_page(new_page, hentry);
 	} while (err != -ENOMEM);
 
 	if (new_page)
diff --git a/mm/swapfile.c b/mm/swapfile.c
index cad3f416cb0a..3bac299a1b25 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1501,7 +1501,8 @@ int __swap_count(swp_entry_t entry)
 	return count;
 }
 
-static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
+static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry,
+			  bool *huge_cluster)
 {
 	int count = 0;
 	pgoff_t offset = swp_offset(entry);
@@ -1509,6 +1510,8 @@ static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
 
 	ci = lock_cluster_or_swap_info(si, offset);
 	count = swap_count(si->swap_map[offset]);
+	if (huge_cluster && ci)
+		*huge_cluster = cluster_is_huge(ci);
 	unlock_cluster_or_swap_info(si, ci);
 	return count;
 }
@@ -1518,14 +1521,14 @@ static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
  * This does not give an exact answer when swap count is continued,
  * but does include the high COUNT_CONTINUED flag to allow for that.
  */
-int __swp_swapcount(swp_entry_t entry)
+int __swp_swapcount(swp_entry_t entry, bool *huge_cluster)
 {
 	int count = 0;
 	struct swap_info_struct *si;
 
 	si = get_swap_device(entry);
 	if (si) {
-		count = swap_swapcount(si, entry);
+		count = swap_swapcount(si, entry, huge_cluster);
 		put_swap_device(si);
 	}
 	return count;
@@ -1685,7 +1688,7 @@ static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
 	return map_swapcount;
 }
 #else
-#define swap_page_trans_huge_swapped(si, entry)	swap_swapcount(si, entry)
+#define swap_page_trans_huge_swapped(si, entry)	swap_swapcount(si, entry, NULL)
 #define page_swapped(page)			(page_swapcount(page) != 0)
 
 static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
-- 
2.17.0
