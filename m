Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 273846B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 11:42:23 -0400 (EDT)
Received: by ywm13 with SMTP id 13so777365ywm.14
        for <linux-mm@kvack.org>; Wed, 31 Aug 2011 08:42:14 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] vmscan: Do reclaim stall in case of mlocked page.
Date: Tue, 15 Nov 2011 00:37:23 +0900
Message-Id: <1321285043-3470-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
