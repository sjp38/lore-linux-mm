Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6AB5A6B02A9
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 02:15:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o756G9XU009448
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Aug 2010 15:16:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCCD045DE70
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:16:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 948A945DE7B
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:16:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 737BEE08004
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:16:08 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD587E38006
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:16:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 7/7] vmscan: isolated_lru_pages() stop neighbor search if neighbor can't be isolated
In-Reply-To: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
Message-Id: <20100805151525.31CC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Aug 2010 15:16:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

isolate_lru_pages() doesn't only isolate LRU tail pages, but also
isolate neighbor pages of the eviction page.

Now, the neighbor search don't stop even if neighbors can't be isolated.
It is silly. successful higher order allocation need full contenious
memory, even though only one page reclaim failure mean to fail making
enough contenious memory.

Then, isolate_lru_pages() should stop to search PFN neighbor pages and
try to search next page on LRU soon. This patch does it. Also all of
lumpy reclaim failure account nr_lumpy_failed.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e043e97..264addc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1047,14 +1047,18 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				continue;
 
 			/* Avoid holes within the zone. */
-			if (unlikely(!pfn_valid_within(pfn)))
+			if (unlikely(!pfn_valid_within(pfn))) {
+				nr_lumpy_failed++;
 				break;
+			}
 
 			cursor_page = pfn_to_page(pfn);
 
 			/* Check that we have not crossed a zone boundary. */
-			if (unlikely(page_zone_id(cursor_page) != zone_id))
-				continue;
+			if (unlikely(page_zone_id(cursor_page) != zone_id)) {
+				nr_lumpy_failed++;
+				break;
+			}
 
 			/*
 			 * If we don't have enough swap space, reclaiming of
@@ -1062,8 +1066,10 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			 * pointless.
 			 */
 			if (nr_swap_pages <= 0 && PageAnon(cursor_page) &&
-					!PageSwapCache(cursor_page))
-				continue;
+			    !PageSwapCache(cursor_page)) {
+				nr_lumpy_failed++;
+				break;
+			}
 
 			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
 				list_move(&cursor_page->lru, dst);
@@ -1074,9 +1080,11 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 					nr_lumpy_dirty++;
 				scan++;
 			} else {
-				if (mode == ISOLATE_BOTH &&
-						page_count(cursor_page))
-					nr_lumpy_failed++;
+				/* the page is freed already. */
+				if (!page_count(cursor_page))
+					continue;
+				nr_lumpy_failed++;
+				break;
 			}
 		}
 	}
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
