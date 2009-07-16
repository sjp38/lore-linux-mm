Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2D6696B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 06:49:16 -0400 (EDT)
Received: by pzk41 with SMTP id 41so21014pzk.12
        for <linux-mm@kvack.org>; Thu, 16 Jul 2009 03:49:20 -0700 (PDT)
Date: Thu, 16 Jul 2009 19:49:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] [mmotm] don't attempt to reclaim anon page in lumpy reclaim
 when no swap space is avilable
Message-Id: <20090716194910.602446a4.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


This patch is based on mmotm 2009-07-15-20-57

This version is better than old one.
That's because enough swap space check is done in case of only lumpy reclaim.
so it can't degrade performance in normal case.

== CUT HERE ==

VM already avoids attempting to reclaim anon pages in various places, But
it doesn't avoid it for lumpy reclaim.

It shuffles lru list unnecessary so that it is pointless.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/vmscan.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 543596e..8b1132f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -930,6 +930,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
+
+			/*
+			 * If we don't have enough swap space, reclaiming of anon page
+			 * which don't already have a swap slot is pointless.
+			 */
+			if (nr_swap_pages <= 0 && (PageAnon(cursor_page) &&
+									!PageSwapCache(cursor_page)))
+				continue;
+
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
