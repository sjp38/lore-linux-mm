Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C97AD6B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 06:47:41 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 05/10] vmscan: Synchrounous lumpy reclaim use lock_page() instead trylock_page()
Date: Mon,  6 Sep 2010 11:47:28 +0100
Message-Id: <1283770053-18833-6-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

With synchrounous lumpy reclaim, there is no reason to give up to reclaim
pages even if page is locked. This patch uses lock_page() instead of
trylock_page() in this case.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5979850..79bd812 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -665,7 +665,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (!trylock_page(page))
+		if (sync_writeback == PAGEOUT_IO_SYNC)
+			lock_page(page);
+		else if (!trylock_page(page))
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
