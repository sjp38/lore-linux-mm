Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F25176B009A
	for <linux-mm@kvack.org>; Sat, 27 Jun 2009 00:11:37 -0400 (EDT)
Received: by pxi40 with SMTP id 40so276083pxi.12
        for <linux-mm@kvack.org>; Fri, 26 Jun 2009 21:11:57 -0700 (PDT)
Date: Sat, 27 Jun 2009 13:11:52 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2][mmotm-2009-0625-1549]  prevent to reclaim anon page of
 lumpy reclaim for no swap space
Message-Id: <20090627131152.519b86ed.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Since v1. 
 * fix - prevent anon page which already don't have swap slot
	 (by Rik van Riel suggestion)
 * change some comment

== CUT HERE ==

This patch prevent to reclaim anon page in case of no swap space.

VM already prevent to reclaim anon page in various place.
But it doesnt't prevent it for lumpy reclaim.

It shuffles lru list unnecessary so that it is pointless.

__isolate_lru_page is called on slow path so that some condition
check could be not critical about performance.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--- mm/vmscan.c.orig	2009-06-27 12:30:41.000000000 +0900
+++ mm/vmscan.c	2009-06-27 12:32:00.000000000 +0900
@@ -830,7 +830,13 @@ int __isolate_lru_page(struct page *page
 	 * When this function is being called for lumpy reclaim, we
 	 * initially look into all LRU pages, active, inactive and
 	 * unevictable; only give shrink_page_list evictable pages.
+	 *
+	 * If we don't have enough swap space, reclaiming of anon page
+	 * which don't already have a swap slot is pointless.
 	 */
+	if (nr_swap_pages <= 0 && (PageAnon(page) && !PageSwapCache(page)))
+		return ret;
+
 	if (PageUnevictable(page))
 		return ret;
 

-- 
Kinds Regards,
Minchan Kim 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
