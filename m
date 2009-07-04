Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 07BDE6B004F
	for <linux-mm@kvack.org>; Sat,  4 Jul 2009 01:00:23 -0400 (EDT)
Received: by pxi33 with SMTP id 33so2482855pxi.12
        for <linux-mm@kvack.org>; Fri, 03 Jul 2009 22:18:24 -0700 (PDT)
Date: Sat, 4 Jul 2009 14:18:18 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH][mmotm] don't attempt to reclaim anon page in lumpy reclaim
 when no swap space is available
Message-Id: <20090704141818.0afa877a.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This patch is based on mmotm 2009-07-02-19-57 reverted 
'vmscan: don't attempt to reclaim anon page in lumpy reclaim when no swap space is available.'

This verssion is better than old one.
That's because enough swap space check is done in case of only lumpy reclaim. 
so it can't degrade performance in normal case.

== CUT HERE ==

VM already avoids attempting to reclaim anon pages in various places, But
it doesn't avoid it for lumpy reclaim.

It shuffles lru list unnecessary so that it is pointless.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 27558aa..977af15 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -930,6 +930,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
+			/*
+			 * If we don't have enough swap space, reclaiming of anon page
+			 * which don't already have a swap slot is pointless.
+			 */
+			if (nr_swap_pages <= 0 && (PageAnon(cursor_page) &&
+						!PageSwapCache(cursor_page)))
+				continue;
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
-- 
1.5.4.3



-- 
Kind regards,
Minchan Kim 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
