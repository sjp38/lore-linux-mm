Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84C696B039F
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 01:19:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v190so135812755pgv.12
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 22:19:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f8si6429674pgr.494.2017.07.23.22.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 22:19:08 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 11/12] mm, THP, swap: Delay splitting THP after swapped out
Date: Mon, 24 Jul 2017 13:18:39 +0800
Message-Id: <20170724051840.2309-12-ying.huang@intel.com>
In-Reply-To: <20170724051840.2309-1-ying.huang@intel.com>
References: <20170724051840.2309-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>

From: Huang Ying <ying.huang@intel.com>

In this patch, splitting transparent huge page (THP) during swapping
out is delayed from after adding the THP into the swap cache to after
swapping out finishes.  After the patch, more operations for the
anonymous THP reclaiming, such as writing the THP to the swap device,
removing the THP from the swap cache could be batched.  So that the
performance of anonymous THP swapping out could be improved.

This is the second step for the THP swap support.  The plan is to
delay splitting the THP step by step and avoid splitting the THP
finally.

With the patchset, the swap out throughput improves 42% (from about
5.81GB/s to about 8.25GB/s) in the vm-scalability swap-w-seq test case
with 16 processes.  At the same time, the IPI (reflect TLB flushing)
reduced about 78.9%.  The test is done on a Xeon E5 v3 system.  The
swap device used is a RAM simulated PMEM (persistent memory) device.
To test the sequential swapping out, the test case creates 8
processes, which sequentially allocate and write to the anonymous
pages until the RAM and part of the swap device is used up.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/vmscan.c | 95 +++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 52 insertions(+), 43 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index efc9da21c5e6..7472ddafc14a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -535,7 +535,9 @@ static inline int is_page_cache_freeable(struct page *page)
 	 * that isolated the page, the page cache radix tree and
 	 * optional buffer heads at page->private.
 	 */
-	return page_count(page) - page_has_private(page) == 2;
+	int radix_pins = PageTransHuge(page) && PageSwapCache(page) ?
+		HPAGE_PMD_NR : 1;
+	return page_count(page) - page_has_private(page) == 1 + radix_pins;
 }
 
 static int may_write_to_inode(struct inode *inode, struct scan_control *sc)
@@ -665,6 +667,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 			    bool reclaimed)
 {
 	unsigned long flags;
+	int refcount;
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
@@ -695,11 +698,15 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
 	 */
-	if (!page_ref_freeze(page, 2))
+	if (unlikely(PageTransHuge(page)) && PageSwapCache(page))
+		refcount = 1 + HPAGE_PMD_NR;
+	else
+		refcount = 2;
+	if (!page_ref_freeze(page, refcount))
 		goto cannot_free;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
 	if (unlikely(PageDirty(page))) {
-		page_ref_unfreeze(page, 2);
+		page_ref_unfreeze(page, refcount);
 		goto cannot_free;
 	}
 
@@ -1121,58 +1128,56 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Try to allocate it some swap space here.
 		 * Lazyfree page could be freed directly
 		 */
-		if (PageAnon(page) && PageSwapBacked(page) &&
-		    !PageSwapCache(page)) {
-			if (!(sc->gfp_mask & __GFP_IO))
-				goto keep_locked;
-			if (PageTransHuge(page)) {
-				/* cannot split THP, skip it */
-				if (!can_split_huge_page(page, NULL))
-					goto activate_locked;
-				/*
-				 * Split pages without a PMD map right
-				 * away. Chances are some or all of the
-				 * tail pages can be freed without IO.
-				 */
-				if (!compound_mapcount(page) &&
-				    split_huge_page_to_list(page, page_list))
-					goto activate_locked;
-			}
-			if (!add_to_swap(page)) {
-				if (!PageTransHuge(page))
-					goto activate_locked;
-				/* Split THP and swap individual base pages */
-				if (split_huge_page_to_list(page, page_list))
-					goto activate_locked;
-				if (!add_to_swap(page))
-					goto activate_locked;
-			}
-
-			/* XXX: We don't support THP writes */
-			if (PageTransHuge(page) &&
-				  split_huge_page_to_list(page, page_list)) {
-				delete_from_swap_cache(page);
-				goto activate_locked;
-			}
+		if (PageAnon(page) && PageSwapBacked(page)) {
+			if (!PageSwapCache(page)) {
+				if (!(sc->gfp_mask & __GFP_IO))
+					goto keep_locked;
+				if (PageTransHuge(page)) {
+					/* cannot split THP, skip it */
+					if (!can_split_huge_page(page, NULL))
+						goto activate_locked;
+					/*
+					 * Split pages without a PMD map right
+					 * away. Chances are some or all of the
+					 * tail pages can be freed without IO.
+					 */
+					if (!compound_mapcount(page) &&
+					    split_huge_page_to_list(page,
+								    page_list))
+						goto activate_locked;
+				}
+				if (!add_to_swap(page)) {
+					if (!PageTransHuge(page))
+						goto activate_locked;
+					/* Fallback to swap normal pages */
+					if (split_huge_page_to_list(page,
+								    page_list))
+						goto activate_locked;
+					if (!add_to_swap(page))
+						goto activate_locked;
+				}
 
-			may_enter_fs = 1;
+				may_enter_fs = 1;
 
-			/* Adding to swap updated mapping */
-			mapping = page_mapping(page);
+				/* Adding to swap updated mapping */
+				mapping = page_mapping(page);
+			}
 		} else if (unlikely(PageTransHuge(page))) {
 			/* Split file THP */
 			if (split_huge_page_to_list(page, page_list))
 				goto keep_locked;
 		}
 
-		VM_BUG_ON_PAGE(PageTransHuge(page), page);
-
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page)) {
-			if (!try_to_unmap(page, ttu_flags | TTU_BATCH_FLUSH)) {
+			enum ttu_flags flags = ttu_flags | TTU_BATCH_FLUSH;
+
+			if (unlikely(PageTransHuge(page)))
+				flags |= TTU_SPLIT_HUGE_PMD;
+			if (!try_to_unmap(page, flags)) {
 				nr_unmap_fail++;
 				goto activate_locked;
 			}
@@ -1312,7 +1317,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
 		 */
-		list_add(&page->lru, &free_pages);
+		if (unlikely(PageTransHuge(page))) {
+			mem_cgroup_uncharge(page);
+			(*get_compound_page_dtor(page))(page);
+		} else
+			list_add(&page->lru, &free_pages);
 		continue;
 
 activate_locked:
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
