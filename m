Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 570446B003B
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 02:04:04 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so6738448pad.35
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 23:04:04 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id hs4si9602404pac.33.2014.07.07.23.04.01
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 23:04:02 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v11 7/7] mm: Don't split THP page when syscall is called
Date: Tue,  8 Jul 2014 15:03:44 +0900
Message-Id: <1404799424-1120-8-git-send-email-minchan@kernel.org>
In-Reply-To: <1404799424-1120-1-git-send-email-minchan@kernel.org>
References: <1404799424-1120-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>

We don't need to split THP page when MADV_FREE syscall is
called. It could be done when VM decide really frees it so
we could avoid unnecessary THP split.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 20 +++++++++++++++++++-
 mm/rmap.c    |  7 +++----
 mm/vmscan.c  | 28 ++++++++++++++++++----------
 3 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index a6aa7d4c4e02..77f13a99584c 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -272,7 +272,25 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	pte_t *pte, ptent;
 	struct page *page;
 
-	split_huge_page_pmd(vma, addr, pmd);
+	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
+		struct page *page;
+		pmd_t orig_pmd;
+
+		orig_pmd = pmdp_get_and_clear(mm, addr, pmd);
+
+		/* No hugepage in swapcache */
+		page = pmd_page(orig_pmd);
+		VM_BUG_ON_PAGE(PageSwapCache(page), page);
+
+		orig_pmd = pmd_mkold(orig_pmd);
+		orig_pmd = pmd_mkclean(orig_pmd);
+
+		set_pmd_at(mm, addr, pmd, orig_pmd);
+		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
+		spin_unlock(ptl);
+		return 0;
+	}
+
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index a8e34596dc97..67e1c1859c1d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -703,10 +703,9 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
 
-		/*
-		 * In this implmentation, MADV_FREE doesn't support THP free
-		 */
-		dirty++;
+		if (pmd_dirty(*pmd))
+			dirty++;
+
 		spin_unlock(ptl);
 	} else {
 		pte_t *pte;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d88413ccadcc..6557f0b36321 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -971,17 +971,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page) && !freeable) {
-			if (!(sc->gfp_mask & __GFP_IO))
-				goto keep_locked;
-			if (!add_to_swap(page, page_list))
-				goto activate_locked;
-			may_enter_fs = 1;
-
-			/* Adding to swap updated mapping */
-			mapping = page_mapping(page);
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			if (!freeable) {
+				if (!(sc->gfp_mask & __GFP_IO))
+					goto keep_locked;
+				if (!add_to_swap(page, page_list))
+					goto activate_locked;
+				may_enter_fs = 1;
+				/* Adding to swap updated mapping */
+				mapping = page_mapping(page);
+			} else {
+				if (likely(!PageTransHuge(page)))
+					goto unmap;
+				/* try_to_unmap isn't aware of THP page */
+				if (unlikely(split_huge_page_to_list(page,
+								page_list)))
+					goto keep_locked;
+			}
 		}
-
+unmap:
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
