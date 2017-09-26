Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5852F6B0260
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 13:26:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p5so22550574pgn.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 10:26:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 89si5936109pfj.139.2017.09.26.10.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 10:26:31 -0700 (PDT)
From: Shaohua Li <shli@kernel.org>
Subject: [PATCH V3 2/2] mm: fix data corruption caused by lazyfree page
Date: Tue, 26 Sep 2017 10:26:26 -0700
Message-Id: <08c84256b007bf3f63c91d94383bd9eb6fee2daa.1506446061.git.shli@fb.com>
In-Reply-To: <cover.1506446061.git.shli@fb.com>
References: <cover.1506446061.git.shli@fb.com>
In-Reply-To: <cover.1506446061.git.shli@fb.com>
References: <cover.1506446061.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: asavkov@redhat.com, Kernel-team@fb.com, Shaohua Li <shli@fb.com>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

From: Shaohua Li <shli@fb.com>

MADV_FREE clears pte dirty bit and then marks the page lazyfree (clear
SwapBacked). There is no lock to prevent the page is added to swap cache
between these two steps by page reclaim. If page reclaim finds such
page, it will simply add the page to swap cache without pageout the page
to swap because the page is marked as clean. Next time, page fault will
read data from the swap slot which doesn't have the original data, so we
have a data corruption. To fix issue, we mark the page dirty and pageout
the page.

However, we shouldn't dirty all pages which is clean and in swap cache.
swapin page is swap cache and clean too. So we only dirty page which is
added into swap cache in page reclaim, which shouldn't be swapin page.
As Minchan suggested, simply dirty the page in add_to_swap can do the
job.

Reported-by: Artem Savkov <asavkov@redhat.com>
Fix: 802a3a92ad7a(mm: reclaim MADV_FREE pages)
Signed-off-by: Shaohua Li <shli@fb.com>
Cc: stable@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/swap_state.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 71ce2d1..ed91091 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -242,6 +242,17 @@ int add_to_swap(struct page *page)
 		 * clear SWAP_HAS_CACHE flag.
 		 */
 		goto fail;
+	/*
+	 * Normally the page will be dirtied in unmap because its pte should be
+	 * dirty. A special case is MADV_FREE page. The page'e pte could have
+	 * dirty bit cleared but the page's SwapBacked bit is still set because
+	 * clearing the dirty bit and SwapBacked bit has no lock protected. For
+	 * such page, unmap will not set dirty bit for it, so page reclaim will
+	 * not write the page out. This can cause data corruption when the page
+	 * is swap in later. Always setting the dirty bit for the page solves
+	 * the problem.
+	 */
+	set_page_dirty(page);
 
 	return 1;
 
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
