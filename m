Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 700166B0274
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:48:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u8-v6so3699239pfn.18
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:48:56 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x18-v6si4948122pll.193.2018.07.19.01.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:48:55 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH v3 2/8] mm/swapfile.c: Replace some #ifdef with IS_ENABLED()
Date: Thu, 19 Jul 2018 16:48:36 +0800
Message-Id: <20180719084842.11385-3-ying.huang@intel.com>
In-Reply-To: <20180719084842.11385-1-ying.huang@intel.com>
References: <20180719084842.11385-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Daniel Jordan <daniel.m.jordan@oracle.com>

In mm/swapfile.c, THP (Transparent Huge Page) swap specific code is
enclosed by #ifdef CONFIG_THP_SWAP/#endif to avoid code dilating when
THP isn't enabled.  But #ifdef/#endif in .c file hurt the code
readability, so Dave suggested to use IS_ENABLED(CONFIG_THP_SWAP)
instead and let compiler to do the dirty job for us.  This has
potential to remove some duplicated code too.  From output of `size`,

		text	   data	    bss	    dec	    hex	filename
THP=y:         26269	   2076	    340	  28685	   700d	mm/swapfile.o
ifdef/endif:   24115	   2028	    340	  26483	   6773	mm/swapfile.o
IS_ENABLED:    24179	   2028	    340	  26547	   67b3	mm/swapfile.o

IS_ENABLED() based solution works quite well, almost as good as that
of #ifdef/#endif.  And from the diffstat, the removed lines are more
than added lines.

One #ifdef for split_swap_cluster() is kept.  Because it is a public
function with a stub implementation for CONFIG_THP_SWAP=n in swap.h.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Suggested-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 mm/swapfile.c | 60 ++++++++++++++++++++---------------------------------------
 1 file changed, 20 insertions(+), 40 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 29da44411734..87c4c3446aed 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -870,7 +870,6 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 	return n_ret;
 }
 
-#ifdef CONFIG_THP_SWAP
 static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
 {
 	unsigned long idx;
@@ -878,6 +877,15 @@ static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
 	unsigned long offset, i;
 	unsigned char *map;
 
+	/*
+	 * Should not even be attempting cluster allocations when huge
+	 * page swap is disabled.  Warn and fail the allocation.
+	 */
+	if (!IS_ENABLED(CONFIG_THP_SWAP)) {
+		VM_WARN_ON_ONCE(1);
+		return 0;
+	}
+
 	if (cluster_list_empty(&si->free_clusters))
 		return 0;
 
@@ -908,13 +916,6 @@ static void swap_free_cluster(struct swap_info_struct *si, unsigned long idx)
 	unlock_cluster(ci);
 	swap_range_free(si, offset, SWAPFILE_CLUSTER);
 }
-#else
-static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
-{
-	VM_WARN_ON_ONCE(1);
-	return 0;
-}
-#endif /* CONFIG_THP_SWAP */
 
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
@@ -1260,7 +1261,6 @@ static void swapcache_free(swp_entry_t entry)
 	}
 }
 
-#ifdef CONFIG_THP_SWAP
 static void swapcache_free_cluster(swp_entry_t entry)
 {
 	unsigned long offset = swp_offset(entry);
@@ -1271,6 +1271,9 @@ static void swapcache_free_cluster(swp_entry_t entry)
 	unsigned int i, free_entries = 0;
 	unsigned char val;
 
+	if (!IS_ENABLED(CONFIG_THP_SWAP))
+		return;
+
 	si = _swap_info_get(entry);
 	if (!si)
 		return;
@@ -1306,6 +1309,7 @@ static void swapcache_free_cluster(swp_entry_t entry)
 	}
 }
 
+#ifdef CONFIG_THP_SWAP
 int split_swap_cluster(swp_entry_t entry)
 {
 	struct swap_info_struct *si;
@@ -1320,11 +1324,7 @@ int split_swap_cluster(swp_entry_t entry)
 	unlock_cluster(ci);
 	return 0;
 }
-#else
-static inline void swapcache_free_cluster(swp_entry_t entry)
-{
-}
-#endif /* CONFIG_THP_SWAP */
+#endif
 
 void put_swap_page(struct page *page, swp_entry_t entry)
 {
@@ -1483,7 +1483,6 @@ int swp_swapcount(swp_entry_t entry)
 	return count;
 }
 
-#ifdef CONFIG_THP_SWAP
 static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
 					 swp_entry_t entry)
 {
@@ -1494,6 +1493,9 @@ static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
 	int i;
 	bool ret = false;
 
+	if (!IS_ENABLED(CONFIG_THP_SWAP))
+		return swap_swapcount(si, entry) != 0;
+
 	ci = lock_cluster_or_swap_info(si, offset);
 	if (!ci || !cluster_is_huge(ci)) {
 		if (map[roffset] != SWAP_HAS_CACHE)
@@ -1516,7 +1518,7 @@ static bool page_swapped(struct page *page)
 	swp_entry_t entry;
 	struct swap_info_struct *si;
 
-	if (likely(!PageTransCompound(page)))
+	if (!IS_ENABLED(CONFIG_THP_SWAP) || likely(!PageTransCompound(page)))
 		return page_swapcount(page) != 0;
 
 	page = compound_head(page);
@@ -1540,10 +1542,8 @@ static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
 	/* hugetlbfs shouldn't call it */
 	VM_BUG_ON_PAGE(PageHuge(page), page);
 
-	if (likely(!PageTransCompound(page))) {
-		mapcount = atomic_read(&page->_mapcount) + 1;
-		if (total_mapcount)
-			*total_mapcount = mapcount;
+	if (!IS_ENABLED(CONFIG_THP_SWAP) || likely(!PageTransCompound(page))) {
+		mapcount = page_trans_huge_mapcount(page, total_mapcount);
 		if (PageSwapCache(page))
 			swapcount = page_swapcount(page);
 		if (total_swapcount)
@@ -1590,26 +1590,6 @@ static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
 
 	return map_swapcount;
 }
-#else
-#define swap_page_trans_huge_swapped(si, entry)	swap_swapcount(si, entry)
-#define page_swapped(page)			(page_swapcount(page) != 0)
-
-static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
-					 int *total_swapcount)
-{
-	int mapcount, swapcount = 0;
-
-	/* hugetlbfs shouldn't call it */
-	VM_BUG_ON_PAGE(PageHuge(page), page);
-
-	mapcount = page_trans_huge_mapcount(page, total_mapcount);
-	if (PageSwapCache(page))
-		swapcount = page_swapcount(page);
-	if (total_swapcount)
-		*total_swapcount = swapcount;
-	return mapcount + swapcount;
-}
-#endif
 
 /*
  * We can write to an anon page without COW if there are no other references
-- 
2.16.4
