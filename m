Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 929A1900035
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:20:52 -0400 (EDT)
Received: by pdjp10 with SMTP id p10so6674849pdj.10
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 18:20:52 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id re3si4063363pab.70.2015.03.10.18.20.47
        for <linux-mm@kvack.org>;
        Tue, 10 Mar 2015 18:20:48 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Date: Wed, 11 Mar 2015 10:20:38 +0900
Message-Id: <1426036838-18154-4-git-send-email-minchan@kernel.org>
In-Reply-To: <1426036838-18154-1-git-send-email-minchan@kernel.org>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>, Yalin Wang <yalin.wang@sonymobile.com>

Bascially, MADV_FREE relys on the pte dirty to decide whether
it allows VM to discard the page. However, if there is swap-in,
pte pointed out the page has no pte_dirty. So, MADV_FREE checks
PageDirty and PageSwapCache for those pages to not discard it
because swapped-in page could live on swap cache or PageDirty
when it is removed from swapcache.

The problem in here is that anonymous pages can have PageDirty if
it is removed from swapcache so that VM cannot parse those pages
as freeable even if we did madvise_free. Look at below example.

ptr = malloc();
memset(ptr);
..
heavy memory pressure -> swap-out all of pages
..
out of memory pressure so there are lots of free pages
..
var = *ptr; -> swap-in page/remove the page from swapcache. so pte_clean
               but SetPageDirty

madvise_free(ptr);
..
..
heavy memory pressure -> VM cannot discard the page by PageDirty.

PageDirty for anonymous page aims for avoiding duplicating
swapping out. In other words, if a page have swapped-in but
live swapcache(ie, !PageDirty), we could save swapout if the page
is selected as victim by VM in future because swap device have
kept previous swapped-out contents of the page.

So, rather than relying on the PG_dirty for working madvise_free,
pte_dirty is more straightforward. Inherently, swapped-out page was
pte_dirty so this patch restores the dirtiness when swap-in fault
happens so madvise_free doesn't rely on the PageDirty any more.

Cc: Hugh Dickins <hughd@google.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Reported-by: Yalin Wang <yalin.wang@sonymobile.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/madvise.c | 1 -
 mm/memory.c  | 9 +++++++--
 mm/rmap.c    | 2 +-
 mm/vmscan.c  | 3 +--
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 22e8f0c..a045798 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -325,7 +325,6 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 				continue;
 			}
 
-			ClearPageDirty(page);
 			unlock_page(page);
 		}
 
diff --git a/mm/memory.c b/mm/memory.c
index 0f96a4a..40428a5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2521,9 +2521,14 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	dec_mm_counter_fast(mm, MM_SWAPENTS);
-	pte = mk_pte(page, vma->vm_page_prot);
+
+	/*
+	 * Every page swapped-out was pte_dirty so we make pte dirty again.
+	 * MADV_FREE relies on it.
+	 */
+	pte = pte_mkdirty(mk_pte(page, vma->vm_page_prot));
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
-		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = maybe_mkwrite(pte, vma);
 		flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = 1;
diff --git a/mm/rmap.c b/mm/rmap.c
index 47b3ba8..34c1d66 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1268,7 +1268,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 		if (flags & TTU_FREE) {
 			VM_BUG_ON_PAGE(PageSwapCache(page), page);
-			if (!dirty && !PageDirty(page)) {
+			if (!dirty) {
 				/* It's a freeable page by MADV_FREE */
 				dec_mm_counter(mm, MM_ANONPAGES);
 				goto discard;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 260c413..3357ffa 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -805,8 +805,7 @@ static enum page_references page_check_references(struct page *page,
 		return PAGEREF_KEEP;
 	}
 
-	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page) &&
-			!PageDirty(page))
+	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page))
 		*freeable = true;
 
 	/* Reclaim if clean, defer dirty pages to writeback */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
