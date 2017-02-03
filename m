Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE1C6B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 18:33:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v184so39820790pgv.6
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:28 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e9si26776480plj.315.2017.02.03.15.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 15:33:27 -0800 (PST)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v13NU3L2013981
	for <linux-mm@kvack.org>; Fri, 3 Feb 2017 15:33:26 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28d33k839x-4
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:26 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 27e4a044ea6911e68d5e24be0593f280-ff9f9a50 for <linux-mm@kvack.org>;	Fri, 03
 Feb 2017 15:33:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V2 3/7] mm: reclaim MADV_FREE pages
Date: Fri, 3 Feb 2017 15:33:19 -0800
Message-ID: <9426fa2cf9fe320a15bfb20744c451eb6af1710a.1486163864.git.shli@fb.com>
In-Reply-To: <cover.1486163864.git.shli@fb.com>
References: <cover.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

When memory pressure is high, we free MADV_FREE pages. If the pages are
not dirty in pte, the pages could be freed immediately. Otherwise we
can't reclaim them. We put the pages back to anonumous LRU list (by
setting SwapBacked flag) and the pages will be reclaimed in normal
swapout way.

We use normal page reclaim policy. Since MADV_FREE pages are put into
inactive file list, such pages and inactive file pages are reclaimed
according to their age. This is expected, because we don't want to
reclaim too many MADV_FREE pages before used once pages.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 mm/rmap.c   |  4 ++++
 mm/vmscan.c | 43 +++++++++++++++++++++++++++++++------------
 2 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index c8d6204..5f05926 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1554,6 +1554,10 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			dec_mm_counter(mm, MM_ANONPAGES);
 			rp->lazyfreed++;
 			goto discard;
+		} else if (flags & TTU_LZFREE) {
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
 		}
 
 		if (swap_duplicate(entry) < 0) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 947ab6f..b304a84 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -864,7 +864,7 @@ static enum page_references page_check_references(struct page *page,
 		return PAGEREF_RECLAIM;
 
 	if (referenced_ptes) {
-		if (PageSwapBacked(page))
+		if (PageSwapBacked(page) || PageAnon(page))
 			return PAGEREF_ACTIVATE;
 		/*
 		 * All mapped pages start out with page table
@@ -903,7 +903,7 @@ static enum page_references page_check_references(struct page *page,
 
 /* Check if a page is dirty or under writeback */
 static void page_check_dirty_writeback(struct page *page,
-				       bool *dirty, bool *writeback)
+			bool *dirty, bool *writeback, bool lazyfree)
 {
 	struct address_space *mapping;
 
@@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
 	 * Anonymous pages are not handled by flushers and must be written
 	 * from reclaim context. Do not stall reclaim based on them
 	 */
-	if (!page_is_file_cache(page)) {
+	if (!page_is_file_cache(page) || lazyfree) {
 		*dirty = false;
 		*writeback = false;
 		return;
@@ -971,7 +971,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
 		bool dirty, writeback;
-		bool lazyfree = false;
+		bool lazyfree;
 		int ret = SWAP_SUCCESS;
 
 		cond_resched();
@@ -986,6 +986,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		sc->nr_scanned++;
 
+		lazyfree = page_is_lazyfree(page);
+
 		if (unlikely(!page_evictable(page)))
 			goto cull_mlocked;
 
@@ -993,7 +995,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep_locked;
 
 		/* Double the slab pressure for mapped and swapcache pages */
-		if (page_mapped(page) || PageSwapCache(page))
+		if ((page_mapped(page) || PageSwapCache(page)) && !lazyfree)
 			sc->nr_scanned++;
 
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
@@ -1005,7 +1007,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * will stall and start writing pages if the tail of the LRU
 		 * is all dirty unqueued pages.
 		 */
-		page_check_dirty_writeback(page, &dirty, &writeback);
+		page_check_dirty_writeback(page, &dirty, &writeback, lazyfree);
 		if (dirty || writeback)
 			nr_dirty++;
 
@@ -1107,6 +1109,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			; /* try to reclaim the page below */
 		}
 
+		/* lazyfree page could be freed directly */
+		if (lazyfree) {
+			if (unlikely(PageTransHuge(page)) &&
+			    split_huge_page_to_list(page, page_list))
+				goto keep_locked;
+			goto unmap_page;
+		}
+
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
@@ -1116,7 +1126,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
 				goto activate_locked;
-			lazyfree = true;
 			may_enter_fs = 1;
 
 			/* Adding to swap updated mapping */
@@ -1128,12 +1137,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		VM_BUG_ON_PAGE(PageTransHuge(page), page);
-
+unmap_page:
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page) && (mapping || lazyfree)) {
 			switch (ret = try_to_unmap(page, lazyfree ?
 				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
 				(ttu_flags | TTU_BATCH_FLUSH))) {
@@ -1145,7 +1154,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			case SWAP_MLOCK:
 				goto cull_mlocked;
 			case SWAP_LZFREE:
-				goto lazyfree;
+				/* follow __remove_mapping for reference */
+				if (page_ref_freeze(page, 1)) {
+					if (!PageDirty(page))
+						goto lazyfree;
+					else
+						page_ref_unfreeze(page, 1);
+				}
+				goto keep_locked;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1257,10 +1273,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-lazyfree:
 		if (!mapping || !__remove_mapping(mapping, page, true))
 			goto keep_locked;
-
+lazyfree:
 		/*
 		 * At this point, we have no other references and there is
 		 * no way to pick any more up (removed from LRU, removed
@@ -1285,6 +1300,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 cull_mlocked:
 		if (PageSwapCache(page))
 			try_to_free_swap(page);
+		if (lazyfree)
+			SetPageSwapBacked(page);
 		unlock_page(page);
 		list_add(&page->lru, &ret_pages);
 		continue;
@@ -1294,6 +1311,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
+		if (lazyfree)
+			SetPageSwapBacked(page);
 		SetPageActive(page);
 		pgactivate++;
 keep_locked:
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
