Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE246B02F3
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:46:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e131so217602650pfh.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:46:56 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u69si26530689pgb.168.2017.05.24.23.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 23:46:55 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm 03/13] mm, THP, swap: Make reuse_swap_page() works for THP swapped out
Date: Thu, 25 May 2017 14:46:25 +0800
Message-Id: <20170525064635.2832-4-ying.huang@intel.com>
In-Reply-To: <20170525064635.2832-1-ying.huang@intel.com>
References: <20170525064635.2832-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

After supporting to delay THP (Transparent Huge Page) splitting after
swapped out, it is possible that some page table mappings of the THP
are turned into swap entries.  So reuse_swap_page() need to check the
swap count in addition to the map count as before.  This patch done
that.

In the huge PMD write protect fault handler, in addition to the page
map count, the swap count need to be checked too, so the page lock
need to be acquired too when calling reuse_swap_page() in addition to
the page table lock.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
---
 include/linux/swap.h |   4 +-
 mm/huge_memory.c     |  16 +++++++-
 mm/memory.c          |   6 +--
 mm/swapfile.c        | 102 ++++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 113 insertions(+), 15 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c563c45b30b4..ed51d5e699e0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -508,8 +508,8 @@ static inline int swp_swapcount(swp_entry_t entry)
 	return 0;
 }
 
-#define reuse_swap_page(page, total_mapcount) \
-	(page_trans_huge_mapcount(page, total_mapcount) == 1)
+#define reuse_swap_page(page, total_map_swapcount) \
+	(page_trans_huge_mapcount(page, total_map_swapcount) == 1)
 
 static inline int try_to_free_swap(struct page *page)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3a14c77fcce7..0eb1251f924a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1226,15 +1226,29 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	 * We can only reuse the page if nobody else maps the huge page or it's
 	 * part.
 	 */
-	if (page_trans_huge_mapcount(page, NULL) == 1) {
+	if (!trylock_page(page)) {
+		get_page(page);
+		spin_unlock(vmf->ptl);
+		lock_page(page);
+		spin_lock(vmf->ptl);
+		if (unlikely(!pmd_same(*vmf->pmd, orig_pmd))) {
+			unlock_page(page);
+			put_page(page);
+			goto out_unlock;
+		}
+		put_page(page);
+	}
+	if (reuse_swap_page(page, NULL)) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		if (pmdp_set_access_flags(vma, haddr, vmf->pmd, entry,  1))
 			update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		ret |= VM_FAULT_WRITE;
+		unlock_page(page);
 		goto out_unlock;
 	}
+	unlock_page(page);
 	get_page(page);
 	spin_unlock(vmf->ptl);
 alloc:
diff --git a/mm/memory.c b/mm/memory.c
index d320b4e16826..ac780fc619cd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2541,7 +2541,7 @@ static int do_wp_page(struct vm_fault *vmf)
 	 * not dirty accountable.
 	 */
 	if (PageAnon(vmf->page) && !PageKsm(vmf->page)) {
-		int total_mapcount;
+		int total_map_swapcount;
 		if (!trylock_page(vmf->page)) {
 			get_page(vmf->page);
 			pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2556,8 +2556,8 @@ static int do_wp_page(struct vm_fault *vmf)
 			}
 			put_page(vmf->page);
 		}
-		if (reuse_swap_page(vmf->page, &total_mapcount)) {
-			if (total_mapcount == 1) {
+		if (reuse_swap_page(vmf->page, &total_map_swapcount)) {
+			if (total_map_swapcount == 1) {
 				/*
 				 * The page is all ours. Move it to
 				 * our anon_vma so the rmap code will
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 675afc235de1..bd0f38f31d3d 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1389,9 +1389,89 @@ static bool page_swapped(struct page *page)
 		return swap_page_trans_huge_swapped(si, entry);
 	return false;
 }
+
+static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
+					 int *total_swapcount)
+{
+	int i, map_swapcount, _total_mapcount, _total_swapcount;
+	unsigned long offset;
+	struct swap_info_struct *si;
+	struct swap_cluster_info *ci = NULL;
+	unsigned char *map = NULL;
+	int mapcount, swapcount = 0;
+
+	/* hugetlbfs shouldn't call it */
+	VM_BUG_ON_PAGE(PageHuge(page), page);
+
+	if (likely(!PageTransCompound(page))) {
+		mapcount = atomic_read(&page->_mapcount) + 1;
+		if (total_mapcount)
+			*total_mapcount = mapcount;
+		if (PageSwapCache(page))
+			swapcount = page_swapcount(page);
+		if (total_swapcount)
+			*total_swapcount = swapcount;
+		return mapcount + swapcount;
+	}
+
+	page = compound_head(page);
+
+	_total_mapcount = _total_swapcount = map_swapcount = 0;
+	if (PageSwapCache(page)) {
+		swp_entry_t entry;
+
+		entry.val = page_private(page);
+		si = _swap_info_get(entry);
+		if (si) {
+			map = si->swap_map;
+			offset = swp_offset(entry);
+		}
+	}
+	if (map)
+		ci = lock_cluster(si, offset);
+	for (i = 0; i < HPAGE_PMD_NR; i++) {
+		mapcount = atomic_read(&page[i]._mapcount) + 1;
+		_total_mapcount += mapcount;
+		if (map) {
+			swapcount = swap_count(map[offset + i]);
+			_total_swapcount += swapcount;
+		}
+		map_swapcount = max(map_swapcount, mapcount + swapcount);
+	}
+	unlock_cluster(ci);
+	if (PageDoubleMap(page)) {
+		map_swapcount -= 1;
+		_total_mapcount -= HPAGE_PMD_NR;
+	}
+	mapcount = compound_mapcount(page);
+	map_swapcount += mapcount;
+	_total_mapcount += mapcount;
+	if (total_mapcount)
+		*total_mapcount = _total_mapcount;
+	if (total_swapcount)
+		*total_swapcount = _total_swapcount;
+
+	return map_swapcount;
+}
 #else
 #define swap_page_trans_huge_swapped(si, entry)	swap_swapcount(si, entry)
 #define page_swapped(page)			(page_swapcount(page) != 0)
+
+static int page_trans_huge_map_swapcount(struct page *page, int *total_mapcount,
+					 int *total_swapcount)
+{
+	int mapcount, swapcount = 0;
+
+	/* hugetlbfs shouldn't call it */
+	VM_BUG_ON_PAGE(PageHuge(page), page);
+
+	mapcount = page_trans_huge_mapcount(page, total_mapcount)
+	if (PageSwapCache(page))
+		swapcount = page_swapcount(page);
+	if (total_swapcount)
+		*total_swapcount = swapcount;
+	return mapcount + swapcount;
+}
 #endif
 
 /*
@@ -1400,23 +1480,27 @@ static bool page_swapped(struct page *page)
  * on disk will never be read, and seeking back there to write new content
  * later would only waste time away from clustering.
  *
- * NOTE: total_mapcount should not be relied upon by the caller if
+ * NOTE: total_map_swapcount should not be relied upon by the caller if
  * reuse_swap_page() returns false, but it may be always overwritten
  * (see the other implementation for CONFIG_SWAP=n).
  */
-bool reuse_swap_page(struct page *page, int *total_mapcount)
+bool reuse_swap_page(struct page *page, int *total_map_swapcount)
 {
-	int count;
+	int count, total_mapcount, total_swapcount;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	if (unlikely(PageKsm(page)))
 		return false;
-	count = page_trans_huge_mapcount(page, total_mapcount);
-	if (count <= 1 && PageSwapCache(page)) {
-		count += page_swapcount(page);
-		if (count != 1)
-			goto out;
+	count = page_trans_huge_map_swapcount(page, &total_mapcount,
+					      &total_swapcount);
+	if (total_map_swapcount)
+		*total_map_swapcount = total_mapcount + total_swapcount;
+	if (count == 1 && PageSwapCache(page) &&
+	    (likely(!PageTransCompound(page)) ||
+	     /* The remaining swap count will be freed soon */
+	     total_swapcount == page_swapcount(page))) {
 		if (!PageWriteback(page)) {
+			page = compound_head(page);
 			delete_from_swap_cache(page);
 			SetPageDirty(page);
 		} else {
@@ -1432,7 +1516,7 @@ bool reuse_swap_page(struct page *page, int *total_mapcount)
 			spin_unlock(&p->lock);
 		}
 	}
-out:
+
 	return count <= 1;
 }
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
