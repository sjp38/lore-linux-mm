Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 501E96B7E9E
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 00:41:52 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id ay11so1926855plb.20
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 21:41:52 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id cf16si2126256plb.227.2018.12.06.21.41.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 21:41:50 -0800 (PST)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -V8 08/21] swap: Support to read a huge swap cluster for swapin a THP
Date: Fri,  7 Dec 2018 13:41:08 +0800
Message-Id: <20181207054122.27822-9-ying.huang@intel.com>
In-Reply-To: <20181207054122.27822-1-ying.huang@intel.com>
References: <20181207054122.27822-1-ying.huang@intel.com>
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
 include/linux/huge_mm.h |  8 ++++++
 include/linux/swap.h    |  4 +--
 mm/huge_memory.c        |  5 ++--
 mm/swap_state.c         | 61 +++++++++++++++++++++++++++++++++--------
 mm/swapfile.c           |  9 ++++--
 5 files changed, 68 insertions(+), 19 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1c0fda003d6a..f4dbd0662438 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -250,6 +250,8 @@ static inline bool thp_migration_supported(void)
 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);
 }
 
+gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma,
+				    unsigned long addr);
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -363,6 +365,12 @@ static inline bool thp_migration_supported(void)
 {
 	return false;
 }
+
+static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma,
+						  unsigned long addr)
+{
+	return 0;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 441da4a832a6..4bd532c9315e 100644
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
@@ -590,7 +590,7 @@ static inline int __swap_count(swp_entry_t entry)
 	return 0;
 }
 
-static inline int __swp_swapcount(swp_entry_t entry)
+static inline int __swp_swapcount(swp_entry_t entry, int *entry_size)
 {
 	return 0;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d23e18c0c07e..2004d8ae4390 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -630,9 +630,10 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
  *	    available
  * never: never stall for any thp allocation
  */
-static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
+gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma,
+				    unsigned long addr)
 {
-	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
+	const bool vma_madvised = vma ? !!(vma->vm_flags & VM_HUGEPAGE) : false;
 	gfp_t this_node = 0;
 
 #ifdef CONFIG_NUMA
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 97831166994a..1eedbc0aede2 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -361,7 +361,9 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 {
 	struct page *found_page = NULL, *new_page = NULL;
 	struct swap_info_struct *si;
-	int err;
+	int err, entry_size = 1;
+	swp_entry_t hentry;
+
 	*new_page_allocated = false;
 
 	do {
@@ -387,14 +389,42 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
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
+				gfp_t gfp;
+
+				gfp = alloc_hugepage_direct_gfpmask(vma, addr);
+				/*
+				 * Make sure huge page allocation flags are
+				 * compatible with that of normal page
+				 */
+				VM_WARN_ONCE(gfp_mask & ~(gfp | __GFP_RECLAIM),
+					     "ignoring gfp_mask bits: %x",
+					     gfp_mask & ~(gfp | __GFP_RECLAIM));
+				new_page = alloc_pages_vma(gfp, HPAGE_PMD_ORDER,
+							   vma, addr,
+							   numa_node_id());
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
@@ -402,7 +432,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
-		err = swapcache_prepare(entry, 1);
+		err = swapcache_prepare(hentry, entry_size);
 		if (err == -EEXIST) {
 			/*
 			 * We might race against get_swap_page() and stumble
@@ -411,18 +441,24 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			 */
 			cond_resched();
 			continue;
+		} else if (err == -ENOTDIR) {
+			/* huge swap cluster has been split under us */
+			continue;
 		} else if (err)		/* swp entry is obsolete ? */
 			break;
 
 		/* May fail (-ENOMEM) if XArray node allocation failed. */
 		__SetPageLocked(new_page);
 		__SetPageSwapBacked(new_page);
-		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
+		err = add_to_swap_cache(new_page, hentry, gfp_mask & GFP_KERNEL);
 		if (likely(!err)) {
 			/* Initiate read into locked page */
 			SetPageWorkingset(new_page);
 			lru_cache_add_anon(new_page);
 			*new_page_allocated = true;
+			if (IS_ENABLED(CONFIG_THP_SWAP))
+				new_page += swp_offset(entry) &
+					(entry_size - 1);
 			return new_page;
 		}
 		__ClearPageLocked(new_page);
@@ -430,7 +466,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		put_swap_page(new_page, entry);
+		put_swap_page(new_page, hentry);
 	} while (err != -ENOMEM);
 
 	if (new_page)
@@ -452,7 +488,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			vma, addr, &page_was_allocated);
 
 	if (page_was_allocated)
-		swap_readpage(retpage, do_poll);
+		swap_readpage(compound_head(retpage), do_poll);
 
 	return retpage;
 }
@@ -571,8 +607,9 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
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
@@ -733,8 +770,8 @@ static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
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
index a57967292a8d..c22c11b4a879 100644
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
2.18.1
