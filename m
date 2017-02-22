Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4416B0388
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 13:50:48 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id v12so786488itv.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:48 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 73si2425352ion.173.2017.02.22.10.50.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 10:50:47 -0800 (PST)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1MIj0uE031425
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:46 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28sa4ghemd-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:46 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 d12780e8f92f11e6938a24be0593f280-8d5fca00 for <linux-mm@kvack.org>;	Wed, 22
 Feb 2017 10:50:45 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V4 4/6] mm: reclaim MADV_FREE pages
Date: Wed, 22 Feb 2017 10:50:42 -0800
Message-ID: <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
In-Reply-To: <cover.1487788131.git.shli@fb.com>
References: <cover.1487788131.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

When memory pressure is high, we free MADV_FREE pages. If the pages are
not dirty in pte, the pages could be freed immediately. Otherwise we
can't reclaim them. We put the pages back to anonumous LRU list (by
setting SwapBacked flag) and the pages will be reclaimed in normal
swapout way.

We use normal page reclaim policy. Since MADV_FREE pages are put into
inactive file list, such pages and inactive file pages are reclaimed
according to their age. This is expected, because we don't want to
reclaim too many MADV_FREE pages before used once pages.

Based on Minchan's original patch

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/linux/rmap.h |  2 +-
 mm/huge_memory.c     |  2 ++
 mm/madvise.c         |  1 +
 mm/rmap.c            | 10 ++++++++--
 mm/vmscan.c          | 34 ++++++++++++++++++++++------------
 5 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index e2cd8f9..2bfd8c6 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -300,6 +300,6 @@ static inline int page_mkclean(struct page *page)
 #define SWAP_AGAIN	1
 #define SWAP_FAIL	2
 #define SWAP_MLOCK	3
-#define SWAP_LZFREE	4
+#define SWAP_DIRTY	4
 
 #endif	/* _LINUX_RMAP_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3b7ee0c..4c7454b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1571,6 +1571,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		set_pmd_at(mm, addr, pmd, orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	}
+
+	mark_page_lazyfree(page);
 	ret = true;
 out:
 	spin_unlock(ptl);
diff --git a/mm/madvise.c b/mm/madvise.c
index 61e10b1..225af7d 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -413,6 +413,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			set_pte_at(mm, addr, pte, ptent);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
+		mark_page_lazyfree(page);
 	}
 out:
 	if (nr_swap) {
diff --git a/mm/rmap.c b/mm/rmap.c
index c621088..083f32e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1424,6 +1424,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				dec_mm_counter(mm, MM_ANONPAGES);
 				rp->lazyfreed++;
 				goto discard;
+			} else if (!PageSwapBacked(page)) {
+				/* dirty MADV_FREE page */
+				set_pte_at(mm, address, pvmw.pte, pteval);
+				ret = SWAP_DIRTY;
+				page_vma_mapped_walk_done(&pvmw);
+				break;
 			}
 
 			if (swap_duplicate(entry) < 0) {
@@ -1525,8 +1531,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
 
 	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
 		ret = SWAP_SUCCESS;
-		if (rp.lazyfreed && !PageDirty(page))
-			ret = SWAP_LZFREE;
+		if (rp.lazyfreed && PageDirty(page))
+			ret = SWAP_DIRTY;
 	}
 	return ret;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 68ea50d..830981a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -911,7 +911,8 @@ static void page_check_dirty_writeback(struct page *page,
 	 * Anonymous pages are not handled by flushers and must be written
 	 * from reclaim context. Do not stall reclaim based on them
 	 */
-	if (!page_is_file_cache(page)) {
+	if (!page_is_file_cache(page) ||
+	    (PageAnon(page) && !PageSwapBacked(page))) {
 		*dirty = false;
 		*writeback = false;
 		return;
@@ -992,7 +993,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			goto keep_locked;
 
 		/* Double the slab pressure for mapped and swapcache pages */
-		if (page_mapped(page) || PageSwapCache(page))
+		if ((page_mapped(page) || PageSwapCache(page)) &&
+		    !(PageAnon(page) && !PageSwapBacked(page)))
 			sc->nr_scanned++;
 
 		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
@@ -1118,8 +1120,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
+		 * Lazyfree page could be freed directly
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (PageAnon(page) && !PageSwapCache(page) &&
+		    PageSwapBacked(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
@@ -1140,9 +1144,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page)) {
 			switch (ret = try_to_unmap(page,
 				ttu_flags | TTU_BATCH_FLUSH)) {
+			case SWAP_DIRTY:
+				SetPageSwapBacked(page);
+				/* fall through */
 			case SWAP_FAIL:
 				nr_unmap_fail++;
 				goto activate_locked;
@@ -1150,8 +1157,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			case SWAP_MLOCK:
 				goto cull_mlocked;
-			case SWAP_LZFREE:
-				goto lazyfree;
 			case SWAP_SUCCESS:
 				; /* try to free the page below */
 			}
@@ -1263,10 +1268,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-lazyfree:
-		if (!mapping || !__remove_mapping(mapping, page, true))
-			goto keep_locked;
+		if (PageAnon(page) && !PageSwapBacked(page)) {
+			/* follow __remove_mapping for reference */
+			if (!page_ref_freeze(page, 1))
+				goto keep_locked;
+			if (PageDirty(page)) {
+				page_ref_unfreeze(page, 1);
+				goto keep_locked;
+			}
 
+			count_vm_event(PGLAZYFREED);
+		} else if (!mapping || !__remove_mapping(mapping, page, true))
+			goto keep_locked;
 		/*
 		 * At this point, we have no other references and there is
 		 * no way to pick any more up (removed from LRU, removed
@@ -1276,9 +1289,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		__ClearPageLocked(page);
 free_it:
-		if (ret == SWAP_LZFREE)
-			count_vm_event(PGLAZYFREED);
-
 		nr_reclaimed++;
 
 		/*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
