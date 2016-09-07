Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 328776B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:25:02 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so64592539pab.1
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:25:02 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m5si42224904pfm.117.2016.09.07.10.50.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 10:50:58 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 1/2] mm, swap: Use offset of swap entry as key of swap cache
Date: Wed,  7 Sep 2016 10:50:48 -0700
Message-Id: <1473270649-27229-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>

From: Huang Ying <ying.huang@intel.com>

This patch is to improve the performance of swap cache operations when
the type of the swap device is not 0.  Originally, the whole swap entry
value is used as the key of the swap cache, even though there is one
radix tree for each swap device.  If the type of the swap device is not
0, the height of the radix tree of the swap cache will be increased
unnecessary, especially on 64bit architecture.  For example, for a 1GB
swap device on the x86_64 architecture, the height of the radix tree of
the swap cache is 11.  But if the offset of the swap entry is used as
the key of the swap cache, the height of the radix tree of the swap
cache is 4.  The increased height causes unnecessary radix tree
descending and increased cache footprint.

This patch reduces the height of the radix tree of the swap cache via
using the offset of the swap entry instead of the whole swap entry value
as the key of the swap cache.  In 32 processes sequential swap out test
case on a Xeon E5 v3 system with RAM disk as swap, the lock contention
for the spinlock of the swap cache is reduced from 20.15% to 12.19%,
when the type of the swap device is 1.

Use the whole swap entry as key,

perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list: 10.37,
perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg: 9.78,

Use the swap offset as key,

perf-profile.calltrace.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list: 6.25,
perf-profile.calltrace.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_node_memcg: 5.94,

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Aaron Lu <aaron.lu@intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/mm.h | 8 ++++----
 mm/memcontrol.c    | 5 +++--
 mm/mincore.c       | 5 +++--
 mm/swap_state.c    | 8 ++++----
 mm/swapfile.c      | 4 ++--
 5 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 40eb6cf..b5709fa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1048,19 +1048,19 @@ struct address_space *page_file_mapping(struct page *page)
 	return page->mapping;
 }
 
+extern pgoff_t __page_file_index(struct page *page);
+
 /*
  * Return the pagecache index of the passed page.  Regular pagecache pages
- * use ->index whereas swapcache pages use ->private
+ * use ->index whereas swapcache pages use swp_offset(->private)
  */
 static inline pgoff_t page_index(struct page *page)
 {
 	if (unlikely(PageSwapCache(page)))
-		return page_private(page);
+		return __page_file_index(page);
 	return page->index;
 }
 
-extern pgoff_t __page_file_index(struct page *page);
-
 /*
  * Return the file index of the page. Regular pagecache pages use ->index
  * whereas swapcache pages use swp_offset(->private)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bdb796f..7bff0f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4395,7 +4395,7 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
 	 * Because lookup_swap_cache() updates some statistics counter,
 	 * we call find_get_page() with swapper_space directly.
 	 */
-	page = find_get_page(swap_address_space(ent), ent.val);
+	page = find_get_page(swap_address_space(ent), swp_offset(ent));
 	if (do_memsw_account())
 		entry->val = ent.val;
 
@@ -4433,7 +4433,8 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
 			swp_entry_t swp = radix_to_swp_entry(page);
 			if (do_memsw_account())
 				*entry = swp;
-			page = find_get_page(swap_address_space(swp), swp.val);
+			page = find_get_page(swap_address_space(swp),
+					     swp_offset(swp));
 		}
 	} else
 		page = find_get_page(mapping, pgoff);
diff --git a/mm/mincore.c b/mm/mincore.c
index c0b5ba9..bfb8664 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -66,7 +66,8 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 		 */
 		if (radix_tree_exceptional_entry(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
-			page = find_get_page(swap_address_space(swp), swp.val);
+			page = find_get_page(swap_address_space(swp),
+					     swp_offset(swp));
 		}
 	} else
 		page = find_get_page(mapping, pgoff);
@@ -150,7 +151,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			} else {
 #ifdef CONFIG_SWAP
 				*vec = mincore_page(swap_address_space(entry),
-					entry.val);
+						    swp_offset(entry));
 #else
 				WARN_ON(1);
 				*vec = 1;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 8679c99..35d7e0e 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -94,7 +94,7 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 	address_space = swap_address_space(entry);
 	spin_lock_irq(&address_space->tree_lock);
 	error = radix_tree_insert(&address_space->page_tree,
-					entry.val, page);
+				  swp_offset(entry), page);
 	if (likely(!error)) {
 		address_space->nrpages++;
 		__inc_node_page_state(page, NR_FILE_PAGES);
@@ -145,7 +145,7 @@ void __delete_from_swap_cache(struct page *page)
 
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
-	radix_tree_delete(&address_space->page_tree, page_private(page));
+	radix_tree_delete(&address_space->page_tree, swp_offset(entry));
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
 	address_space->nrpages--;
@@ -283,7 +283,7 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 {
 	struct page *page;
 
-	page = find_get_page(swap_address_space(entry), entry.val);
+	page = find_get_page(swap_address_space(entry), swp_offset(entry));
 
 	if (page) {
 		INC_CACHE_INFO(find_success);
@@ -310,7 +310,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(swapper_space, entry.val);
+		found_page = find_get_page(swapper_space, swp_offset(entry));
 		if (found_page)
 			break;
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8f1b97d..6d375b6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -105,7 +105,7 @@ __try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
 	struct page *page;
 	int ret = 0;
 
-	page = find_get_page(swap_address_space(entry), entry.val);
+	page = find_get_page(swap_address_space(entry), swp_offset(entry));
 	if (!page)
 		return 0;
 	/*
@@ -1005,7 +1005,7 @@ int free_swap_and_cache(swp_entry_t entry)
 	if (p) {
 		if (swap_entry_free(p, entry, 1) == SWAP_HAS_CACHE) {
 			page = find_get_page(swap_address_space(entry),
-						entry.val);
+					     swp_offset(entry));
 			if (page && !trylock_page(page)) {
 				put_page(page);
 				page = NULL;
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
