Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2AD6B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:18:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id c14so140161218pgn.11
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:18:52 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r85si5471938pfb.477.2017.07.23.22.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:18:51 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 02/12] mm, THP, swap: Support to reclaim swap space for THP swapped out
Date: Mon, 24 Jul 2017 13:18:30 +0800
Message-Id: <20170724051840.2309-3-ying.huang@intel.com>
In-Reply-To: <20170724051840.2309-1-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

From: Huang Ying <ying.huang@intel.com>

The normal swap slot reclaiming can be done when the swap count
reaches SWAP_HAS_CACHE.  But for the swap slot which is backing a THP,
all swap slots backing one THP must be reclaimed together, because the
swap slot may be used again when the THP is swapped out again later.
So the swap slots backing one THP can be reclaimed together when the
swap count for all swap slots for the THP reached SWAP_HAS_CACHE.  In
the patch, the functions to check whether the swap count for all swap
slots backing one THP reached SWAP_HAS_CACHE are implemented and used
when checking whether a swap slot can be reclaimed.

To make it easier to determine whether a swap slot is backing a THP, a
new swap cluster flag named CLUSTER_FLAG_HUGE is added to mark a swap
cluster which is backing a THP (Transparent Huge Page).  Because THP
swap in as a whole isn't supported now.  After deleting the THP from
the swap cache (for example, swapping out finished), the
CLUSTER_FLAG_HUGE flag will be cleared.  So that, the normal pages
inside THP can be swapped in individually.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/swap.h |  1 +
 mm/swapfile.c        | 78 +++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 72 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d83d28e53e62..964b4f1fba4a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -188,6 +188,7 @@ struct swap_cluster_info {
 };
 #define CLUSTER_FLAG_FREE 1 /* This cluster is free */
 #define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
+#define CLUSTER_FLAG_HUGE 4 /* This cluster is backing a transparent huge page */
 
 /*
  * We assign a cluster to each CPU, so each CPU can allocate swap entry from
diff --git a/mm/swapfile.c b/mm/swapfile.c
index c32e9b23d642..7db19846f8c7 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -265,6 +265,16 @@ static inline void cluster_set_null(struct swap_cluster_info *info)
 	info->data = 0;
 }
 
+static inline bool cluster_is_huge(struct swap_cluster_info *info)
+{
+	return info->flags & CLUSTER_FLAG_HUGE;
+}
+
+static inline void cluster_clear_huge(struct swap_cluster_info *info)
+{
+	info->flags &= ~CLUSTER_FLAG_HUGE;
+}
+
 static inline struct swap_cluster_info *lock_cluster(struct swap_info_struct *si,
 						     unsigned long offset)
 {
@@ -846,7 +856,7 @@ static int swap_alloc_cluster(struct swap_info_struct *si, swp_entry_t *slot)
 	offset = idx * SWAPFILE_CLUSTER;
 	ci = lock_cluster(si, offset);
 	alloc_cluster(si, idx);
-	cluster_set_count_flag(ci, SWAPFILE_CLUSTER, 0);
+	cluster_set_count_flag(ci, SWAPFILE_CLUSTER, CLUSTER_FLAG_HUGE);
 
 	map = si->swap_map + offset;
 	for (i = 0; i < SWAPFILE_CLUSTER; i++)
@@ -1176,6 +1186,7 @@ static void swapcache_free_cluster(swp_entry_t entry)
 		return;
 
 	ci = lock_cluster(si, offset);
+	VM_BUG_ON(!cluster_is_huge(ci));
 	map = si->swap_map + offset;
 	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
 		val = map[i];
@@ -1187,6 +1198,7 @@ static void swapcache_free_cluster(swp_entry_t entry)
 		for (i = 0; i < SWAPFILE_CLUSTER; i++)
 			map[i] &= ~SWAP_HAS_CACHE;
 	}
+	cluster_clear_huge(ci);
 	unlock_cluster(ci);
 	if (free_entries == SWAPFILE_CLUSTER) {
 		spin_lock(&si->lock);
@@ -1350,6 +1362,54 @@ int swp_swapcount(swp_entry_t entry)
 	return count;
 }
 
+#ifdef CONFIG_THP_SWAP
+static bool swap_page_trans_huge_swapped(struct swap_info_struct *si,
+					 swp_entry_t entry)
+{
+	struct swap_cluster_info *ci;
+	unsigned char *map = si->swap_map;
+	unsigned long roffset = swp_offset(entry);
+	unsigned long offset = round_down(roffset, SWAPFILE_CLUSTER);
+	int i;
+	bool ret = false;
+
+	ci = lock_cluster_or_swap_info(si, offset);
+	if (!cluster_is_huge(ci)) {
+		if (map[roffset] != SWAP_HAS_CACHE)
+			ret = true;
+		goto unlock_out;
+	}
+	for (i = 0; i < SWAPFILE_CLUSTER; i++) {
+		if (map[offset + i] != SWAP_HAS_CACHE) {
+			ret = true;
+			break;
+		}
+	}
+unlock_out:
+	unlock_cluster_or_swap_info(si, ci);
+	return ret;
+}
+
+static bool page_swapped(struct page *page)
+{
+	swp_entry_t entry;
+	struct swap_info_struct *si;
+
+	if (likely(!PageTransCompound(page)))
+		return page_swapcount(page) != 0;
+
+	page = compound_head(page);
+	entry.val = page_private(page);
+	si = _swap_info_get(entry);
+	if (si)
+		return swap_page_trans_huge_swapped(si, entry);
+	return false;
+}
+#else
+#define swap_page_trans_huge_swapped(si, entry)	swap_swapcount(si, entry)
+#define page_swapped(page)			(page_swapcount(page) != 0)
+#endif
+
 /*
  * We can write to an anon page without COW if there are no other references
  * to it.  And as a side-effect, free up its swap: because the old content
@@ -1404,7 +1464,7 @@ int try_to_free_swap(struct page *page)
 		return 0;
 	if (PageWriteback(page))
 		return 0;
-	if (page_swapcount(page))
+	if (page_swapped(page))
 		return 0;
 
 	/*
@@ -1425,6 +1485,7 @@ int try_to_free_swap(struct page *page)
 	if (pm_suspended_storage())
 		return 0;
 
+	page = compound_head(page);
 	delete_from_swap_cache(page);
 	SetPageDirty(page);
 	return 1;
@@ -1446,7 +1507,8 @@ int free_swap_and_cache(swp_entry_t entry)
 	p = _swap_info_get(entry);
 	if (p) {
 		count = __swap_entry_free(p, entry, 1);
-		if (count == SWAP_HAS_CACHE) {
+		if (count == SWAP_HAS_CACHE &&
+		    !swap_page_trans_huge_swapped(p, entry)) {
 			page = find_get_page(swap_address_space(entry),
 					     swp_offset(entry));
 			if (page && !trylock_page(page)) {
@@ -1463,7 +1525,8 @@ int free_swap_and_cache(swp_entry_t entry)
 		 */
 		if (PageSwapCache(page) && !PageWriteback(page) &&
 		    (!page_mapped(page) || mem_cgroup_swap_full(page)) &&
-		    !swap_swapcount(p, entry)) {
+		    !swap_page_trans_huge_swapped(p, entry)) {
+			page = compound_head(page);
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		}
@@ -2017,7 +2080,7 @@ int try_to_unuse(unsigned int type, bool frontswap,
 				.sync_mode = WB_SYNC_NONE,
 			};
 
-			swap_writepage(page, &wbc);
+			swap_writepage(compound_head(page), &wbc);
 			lock_page(page);
 			wait_on_page_writeback(page);
 		}
@@ -2030,8 +2093,9 @@ int try_to_unuse(unsigned int type, bool frontswap,
 		 * delete, since it may not have been written out to swap yet.
 		 */
 		if (PageSwapCache(page) &&
-		    likely(page_private(page) == entry.val))
-			delete_from_swap_cache(page);
+		    likely(page_private(page) == entry.val) &&
+		    !page_swapped(page))
+			delete_from_swap_cache(compound_head(page));
 
 		/*
 		 * So we could skip searching mms once swap count went
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
