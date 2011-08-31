From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] vmscan: Do reclaim stall in case of mlocked page.
Date: Wed, 31 Aug 2011 15:42:38 +0000 (UTC)
Message-ID: <1321285043-3470-1-git-send-email-minchan.kim__44106.3582119115$1314805358$gmane$org@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Date: Tue, 15 Nov 2011 00:37:23 +0900
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

[1] made avoid unnecessary reclaim stall when second shrink_page_list(ie, synchronous
shrink_page_list) try to reclaim page_list which has not-dirty pages.
But it seems rather awkawrd on unevictable page.
The unevictable page in shrink_page_list would be moved into unevictable lru from page_list.
So it would be not on page_list when shrink_page_list returns.
Nevertheless it skips reclaim stall.

This patch fixes it so that it can do reclaim stall in case of mixing mlocked pages
and writeback pages on page_list.

[1] 7d3579e,vmscan: narrow the scenarios in whcih lumpy reclaim uses synchrounous reclaim

CC: Mel Gorman <mgorman@suse.de>
CC: Johannes Weiner <jweiner@redhat.com>
CC: Rik van Riel <riel@redhat.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2300342..23878de 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -987,7 +987,6 @@ cull_mlocked:
 			try_to_free_swap(page);
 		unlock_page(page);
 		putback_lru_page(page);
-		reset_reclaim_mode(sc);
 		continue;
 
 activate_locked:
-- 
1.7.6
