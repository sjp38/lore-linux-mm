Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C39646B0260
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:17:09 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id jz4so28133949wjb.5
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 10:17:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d21si19719942wrc.113.2017.01.23.10.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 10:17:08 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 4/5] mm: vmscan: only write dirty pages that the scanner has seen twice
Date: Mon, 23 Jan 2017 13:16:40 -0500
Message-Id: <20170123181641.23938-5-hannes@cmpxchg.org>
In-Reply-To: <20170123181641.23938-1-hannes@cmpxchg.org>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Dirty pages can easily reach the end of the LRU while there are still
clean pages to reclaim around. Don't let kswapd write them back just
because there are a lot of them. It costs more CPU to find the clean
pages, but that's almost certainly better than to disrupt writeback
from the flushers with LRU-order single-page writes from reclaim. And
the flushers have been woken up by that point, so we spend IO capacity
on flushing and CPU capacity on finding the clean cache.

Only start writing dirty pages if they have cycled around the LRU
twice now and STILL haven't been queued on the IO device. It's
possible that the dirty pages are so sparsely distributed across
different bdis, inodes, memory cgroups, that the flushers take forever
to get to the ones we want reclaimed. Once we see them twice on the
LRU, we know that's the quicker way to find them, so do LRU writeback.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 915fc658de41..df0fe0cc438e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1153,13 +1153,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		if (PageDirty(page)) {
 			/*
-			 * Only kswapd can writeback filesystem pages to
-			 * avoid risk of stack overflow but only writeback
-			 * if many dirty pages have been encountered.
+			 * Only kswapd can writeback filesystem pages
+			 * to avoid risk of stack overflow. But avoid
+			 * injecting inefficient single-page IO into
+			 * flusher writeback as much as possible: only
+			 * write pages when we've encountered many
+			 * dirty pages, and when we've already scanned
+			 * the rest of the LRU for clean pages and see
+			 * the same dirty pages again (PageReclaim).
 			 */
 			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() ||
-					 !test_bit(PGDAT_DIRTY, &pgdat->flags))) {
+			    (!current_is_kswapd() || !PageReclaim(page) ||
+			     !test_bit(PGDAT_DIRTY, &pgdat->flags))) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
