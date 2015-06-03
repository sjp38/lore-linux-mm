Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C7C8B900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 02:15:53 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so108213pad.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 23:15:53 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id kq5si29737633pbc.36.2015.06.02.23.15.51
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 23:15:52 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 5/6] mm: decouple PG_dirty from MADV_FREE
Date: Wed,  3 Jun 2015 15:15:44 +0900
Message-Id: <1433312145-19386-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1433312145-19386-1-git-send-email-minchan@kernel.org>
References: <1433312145-19386-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

Basically, MADV_FREE relies on dirty bit in page table entry
to decide whether VM allows to discard the page or not.
IOW, if page table entry includes marked dirty bit, VM shouldn't
discard the page.

However, as a example, if swap-in by read fault happens,
page table entry doesn't have dirty bit so MADV_FREE could discard
the page wrongly.

For avoiding the problem, MADV_FREE did more checks with PageDirty
and PageSwapCache. It worked out because swapped-in page lives on
swap cache and since it is evicted from the swap cache, the page has
PG_dirty flag. So both page flags check effectively prevent
wrong discarding by MADV_FREE.

However, a problem in above logic is that swapped-in page has
PG_dirty since they are removed from swap cache so VM cannot consider
those pages as freeable any more alghouth madvise_free is called in future.
Look at below example for detail.

ptr = malloc();
memset(ptr);
..
..
.. heavy memory pressure so all of pages are swapped out
..
..
var = *ptr; -> a page swapped-in and removed from swapcache.
               page table doesn't mark dirty bit and page
               descriptor includes PG_dirty
..
..
madvise_free(ptr);
..
..
..
.. heavy memory pressure again.
.. In this time, VM cannot discard the page because the page
.. has *PG_dirty*

So, rather than relying on the PG_dirty of page descriptor
for preventing discarding a page, dirty bit in page table is more
straightforward and simple.

Now, every anonymous page handling(ex, anon/swap/cow fault handling,
KSM, THP, Migration) takes care of pte dirty bit to keep it so
we don't need to check PG_dirty to identify MADV_FREE hinted page
so this patch removes PageDirty check.

With this, it removes complicated logic and makes freeable page
checking as well as solving above mentioned problem.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/rmap.c   | 2 +-
 mm/vmscan.c | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 9c045940ed10..a2e4f64c392e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1280,7 +1280,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 
 		if (flags & TTU_FREE) {
 			VM_BUG_ON_PAGE(PageSwapCache(page), page);
-			if (!dirty && !PageDirty(page)) {
+			if (!dirty) {
 				/* It's a freeable page by MADV_FREE */
 				dec_mm_counter(mm, MM_ANONPAGES);
 				goto discard;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 37e90db1520b..c5fbb7c64deb 100644
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
