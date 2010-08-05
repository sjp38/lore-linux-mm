Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FD546B02A4
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 02:12:55 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o756D5Nr012446
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Aug 2010 15:13:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B7F8845DE51
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BB8745DE52
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:04 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 60A6E1DB8043
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EE3761DB805B
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/7] vmscan: synchronous lumpy reclaim don't call congestion_wait()
In-Reply-To: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
Message-Id: <20100805151229.31BD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Aug 2010 15:13:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

congestion_wait() mean "waiting quueue congestion is cleared".
That said, if the system have plenty dirty pages and flusher thread push
new request to IO queue conteniously, IO queue are not cleared
congestion status for long time. thus, congestion_wait(HZ/10) become
almostly equivalent schedule_timeout(HZ/10).

However, synchronous lumpy reclaim donesn't need this
congestion_wait() at all. shrink_page_list(PAGEOUT_IO_SYNC) are
using wait_on_page_writeback() and it provide sufficient waiting.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index cf51d62..1cdc3db 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1341,7 +1341,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 
 	/* Check if we should syncronously wait for writeback */
 	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
 		/*
 		 * The attempt at page out may have made some
 		 * of the pages active, mark them inactive again.
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
