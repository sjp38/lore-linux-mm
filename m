Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 580AB6B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 08:31:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id g26-v6so3616865pfo.7
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 05:31:39 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 12-v6si4146798plb.203.2018.08.03.05.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 05:31:38 -0700 (PDT)
From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH] swap: Use __try_to_reclaim_swap() in free_swap_and_cache()
Date: Fri,  3 Aug 2018 20:30:14 +0800
Message-Id: <20180803123014.15431-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

The code path to reclaim the swap entry in free_swap_and_cache() is
almost same as that of __try_to_reclaim_swap(), the largest difference
is just coding style.  So the support to the additional requirement of
free_swap_and_cache() is added into __try_to_reclaim_swap(), and
__try_to_reclaim_swap() is called in free_swap_and_cache() to delete
the duplicated code.  This will improve code readability and reduce
the potential bugs.

There are 2 functionality differences between __try_to_reclaim_swap()
and swap entry reclaim code of free_swap_and_cache().

- free_swap_and_cache() only reclaims the swap entry if the page is
  unmapped or swap is getting full.  The support has been added into
  __try_to_reclaim_swap().

- try_to_free_swap() (called by __try_to_reclaim_swap()) checks
  pm_suspended_storage(), while free_swap_and_cache() not.  I think
  this is OK.  Because the page and the swap entry can be reclaimed
  later eventually.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/swapfile.c | 57 +++++++++++++++++++++++++--------------------------------
 1 file changed, 25 insertions(+), 32 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8ee4c93e3316..00bb4ed08410 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -104,26 +104,39 @@ static inline unsigned char swap_count(unsigned char ent)
 	return ent & ~SWAP_HAS_CACHE;	/* may include COUNT_CONTINUED flag */
 }
 
+/* Reclaim the swap entry anyway if possible */
+#define TTRS_ANYWAY		0x1
+/*
+ * Reclaim the swap entry if there are no more mappings of the
+ * corresponding page
+ */
+#define TTRS_UNMAPPED		0x2
+/* Reclaim the swap entry if swap is getting full*/
+#define TTRS_FULL		0x4
+
 /* returns 1 if swap entry is freed */
-static int
-__try_to_reclaim_swap(struct swap_info_struct *si, unsigned long offset)
+static int __try_to_reclaim_swap(struct swap_info_struct *si,
+				 unsigned long offset, unsigned long flags)
 {
 	swp_entry_t entry = swp_entry(si->type, offset);
 	struct page *page;
 	int ret = 0;
 
-	page = find_get_page(swap_address_space(entry), swp_offset(entry));
+	page = find_get_page(swap_address_space(entry), offset);
 	if (!page)
 		return 0;
 	/*
-	 * This function is called from scan_swap_map() and it's called
-	 * by vmscan.c at reclaiming pages. So, we hold a lock on a page, here.
-	 * We have to use trylock for avoiding deadlock. This is a special
+	 * When this function is called from scan_swap_map_slots() and it's
+	 * called by vmscan.c at reclaiming pages. So, we hold a lock on a page,
+	 * here. We have to use trylock for avoiding deadlock. This is a special
 	 * case and you should use try_to_free_swap() with explicit lock_page()
 	 * in usual operations.
 	 */
 	if (trylock_page(page)) {
-		ret = try_to_free_swap(page);
+		if ((flags & TTRS_ANYWAY) ||
+		    ((flags & TTRS_UNMAPPED) && !page_mapped(page)) ||
+		    ((flags & TTRS_FULL) && mem_cgroup_swap_full(page)))
+			ret = try_to_free_swap(page);
 		unlock_page(page);
 	}
 	put_page(page);
@@ -781,7 +794,7 @@ static int scan_swap_map_slots(struct swap_info_struct *si,
 		int swap_was_freed;
 		unlock_cluster(ci);
 		spin_unlock(&si->lock);
-		swap_was_freed = __try_to_reclaim_swap(si, offset);
+		swap_was_freed = __try_to_reclaim_swap(si, offset, TTRS_ANYWAY);
 		spin_lock(&si->lock);
 		/* entry was freed successfully, try to use this again */
 		if (swap_was_freed)
@@ -1680,7 +1693,6 @@ int try_to_free_swap(struct page *page)
 int free_swap_and_cache(swp_entry_t entry)
 {
 	struct swap_info_struct *p;
-	struct page *page = NULL;
 	unsigned char count;
 
 	if (non_swap_entry(entry))
@@ -1690,31 +1702,12 @@ int free_swap_and_cache(swp_entry_t entry)
 	if (p) {
 		count = __swap_entry_free(p, entry, 1);
 		if (count == SWAP_HAS_CACHE &&
-		    !swap_page_trans_huge_swapped(p, entry)) {
-			page = find_get_page(swap_address_space(entry),
-					     swp_offset(entry));
-			if (page && !trylock_page(page)) {
-				put_page(page);
-				page = NULL;
-			}
-		} else if (!count)
+		    !swap_page_trans_huge_swapped(p, entry))
+			__try_to_reclaim_swap(p, swp_offset(entry),
+					      TTRS_UNMAPPED | TTRS_FULL);
+		else if (!count)
 			free_swap_slot(entry);
 	}
-	if (page) {
-		/*
-		 * Not mapped elsewhere, or swap space full? Free it!
-		 * Also recheck PageSwapCache now page is locked (above).
-		 */
-		if (PageSwapCache(page) && !PageWriteback(page) &&
-		    (!page_mapped(page) || mem_cgroup_swap_full(page)) &&
-		    !swap_page_trans_huge_swapped(p, entry)) {
-			page = compound_head(page);
-			delete_from_swap_cache(page);
-			SetPageDirty(page);
-		}
-		unlock_page(page);
-		put_page(page);
-	}
 	return p != NULL;
 }
 
-- 
2.16.4
