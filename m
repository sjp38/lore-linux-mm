Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9A6416B0062
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:32:24 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECWKiI003985
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:32:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26D4345DE50
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:32:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 014D345DE4D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:32:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DCA8C1DB8041
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:32:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 913B51DB803C
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:32:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 7/8] Use TASK_KILLABLE instead TASK_UNINTERRUPTIBLE
In-Reply-To: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
Message-Id: <20091214213145.BBC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Dec 2009 21:32:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

When fork bomb invoke OOM Killer, almost task might start to reclaim and
sleep on shrink_zone_begin(). if we use TASK_UNINTERRUPTIBLE, OOM killer
can't kill such task. it mean we never recover from fork bomb.

This patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bf229d3..e537361 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1618,7 +1618,10 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
 	 * we would just make things slower.
 	 */
 	for (;;) {
-		prepare_to_wait_exclusive(wq, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait_exclusive(wq, &wait, TASK_KILLABLE);
+
+		if (fatal_signal_pending(current))
+			goto stop_reclaim;
 
 		if (atomic_read(&zone->concurrent_reclaimers) <=
 		    max_zone_concurrent_reclaimers)
@@ -1631,18 +1634,21 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
                 * break out of the loop and go back to the allocator.
                 */
 		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
-					0, 0)) {
-			wake_up_all(wq);
-			finish_wait(wq, &wait);
-			sc->nr_reclaimed += sc->nr_to_reclaim;
-			return -ERESTARTSYS;
-		}
+					0, 0))
+			goto found_lots_memory;
 	}
 	finish_wait(wq, &wait);
 
  out:
 	atomic_inc(&zone->concurrent_reclaimers);
 	return 0;
+
+ found_lots_memory:
+	wake_up_all(wq);
+ stop_reclaim:
+	finish_wait(wq, &wait);
+	sc->nr_reclaimed += sc->nr_to_reclaim;
+	return -ERESTARTSYS;
 }
 
 static void shrink_zone_end(struct zone *zone, struct scan_control *sc)
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
