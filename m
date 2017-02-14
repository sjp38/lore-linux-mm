Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA298680FCF
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:36:18 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id h190so231030976ybb.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:18 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t5si1338732pgj.171.2017.02.14.11.36.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:36:17 -0800 (PST)
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EJY9So029993
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:17 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28kre63sdt-4
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:17 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.222.219.45) with ESMTP	id
 d8828d86f2ec11e69c8624be05904660-72bf9a00 for <linux-mm@kvack.org>;	Tue, 14
 Feb 2017 11:36:14 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Date: Tue, 14 Feb 2017 11:36:09 -0800
Message-ID: <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
In-Reply-To: <cover.1487100204.git.shli@fb.com>
References: <cover.1487100204.git.shli@fb.com>
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
 mm/huge_memory.c |  2 ++
 mm/madvise.c     |  1 +
 mm/rmap.c        | 17 ++++++++++++-----
 mm/vmscan.c      | 30 +++++++++++++++++++++---------
 4 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4ddda58..3bb5ad5 100644
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
index 639c476..2faed38 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -412,6 +412,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 			set_pte_at(mm, addr, pte, ptent);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
+		mark_page_lazyfree(page);
 	}
 out:
 	if (nr_swap) {
diff --git a/mm/rmap.c b/mm/rmap.c
index af50eae..2cbdada 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1419,11 +1419,18 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
 				page);
 
-			if (!PageDirty(page) && (flags & TTU_LZFREE)) {
-				/* It's a freeable page by MADV_FREE */
-				dec_mm_counter(mm, MM_ANONPAGES);
-				rp->lazyfreed++;
-				goto discard;
+			if (flags & TTU_LZFREE) {
+				if (!PageDirty(page)) {
+					/* It's a freeable page by MADV_FREE */
+					dec_mm_counter(mm, MM_ANONPAGES);
+					rp->lazyfreed++;
+					goto discard;
+				} else {
+					set_pte_at(mm, address, pvmw.pte, pteval);
+					ret = SWAP_FAIL;
+					page_vma_mapped_walk_done(&pvmw);
+					break;
+				}
 			}
 
 			if (swap_duplicate(entry) < 0) {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 26c3b40..435149c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
 	 * Anonymous pages are not handled by flushers and must be written
 	 * from reclaim context. Do not stall reclaim based on them
 	 */
-	if (!page_is_file_cache(page)) {
+	if (!page_is_file_cache(page) || page_is_lazyfree(page)) {
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
@@ -1119,13 +1121,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
+		 * Lazyfree page could be freed directly
 		 */
-		if (PageAnon(page) && !PageSwapCache(page)) {
+		if (PageAnon(page) && !PageSwapCache(page) && !lazyfree) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
 				goto activate_locked;
-			lazyfree = true;
 			may_enter_fs = 1;
 
 			/* Adding to swap updated mapping */
@@ -1142,7 +1144,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page_mapped(page) && mapping) {
+		if (page_mapped(page) && (mapping || lazyfree)) {
 			switch (ret = try_to_unmap(page, lazyfree ?
 				(ttu_flags | TTU_BATCH_FLUSH | TTU_LZFREE) :
 				(ttu_flags | TTU_BATCH_FLUSH))) {
@@ -1154,7 +1156,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -1266,10 +1275,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
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
@@ -1294,6 +1302,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 cull_mlocked:
 		if (PageSwapCache(page))
 			try_to_free_swap(page);
+		if (lazyfree)
+			clear_page_lazyfree(page);
 		unlock_page(page);
 		list_add(&page->lru, &ret_pages);
 		continue;
@@ -1303,6 +1313,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (PageSwapCache(page) && mem_cgroup_swap_full(page))
 			try_to_free_swap(page);
 		VM_BUG_ON_PAGE(PageActive(page), page);
+		if (lazyfree)
+			clear_page_lazyfree(page);
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
