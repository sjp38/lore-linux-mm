Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9E4CF6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:29:32 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECTThl002613
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:29:30 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EC4045DE50
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:29:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E91445DE4D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:29:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CE381DB803F
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:29:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A4F71DB8041
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:29:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/8] Don't use sleep_on()
In-Reply-To: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
Message-Id: <20091214212449.BBB7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Dec 2009 21:29:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

sleep_on() is SMP and/or kernel preemption unsafe. This patch
replace it with safe code.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   40 ++++++++++++++++++++++++++++++----------
 1 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 74c36fe..3be5345 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1599,15 +1599,32 @@ static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
 
 static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
 {
-	if (!current_is_kswapd() &&
-	    atomic_read(&zone->concurrent_reclaimers) > max_zone_concurrent_reclaimers &&
-	    (sc->gfp_mask & (__GFP_IO|__GFP_FS)) == (__GFP_IO|__GFP_FS)) {
-		/*
-		 * Do not add to the lock contention if this zone has
-		 * enough processes doing page reclaim already, since
-		 * we would just make things slower.
-		 */
-		sleep_on(&zone->reclaim_wait);
+	DEFINE_WAIT(wait);
+	wait_queue_head_t *wq = &zone->reclaim_wait;
+
+	if (current_is_kswapd())
+		goto out;
+
+	/*
+	 * GFP_NOIO and GFP_NOFS mean caller may have some lock implicitly.
+	 * Thus, we can't wait here. otherwise it might cause deadlock.
+	 */
+	if ((sc->gfp_mask & (__GFP_IO|__GFP_FS)) != (__GFP_IO|__GFP_FS))
+		goto out;
+
+	/*
+	 * Do not add to the lock contention if this zone has
+	 * enough processes doing page reclaim already, since
+	 * we would just make things slower.
+	 */
+	for (;;) {
+		prepare_to_wait(wq, &wait, TASK_UNINTERRUPTIBLE);
+
+		if (atomic_read(&zone->concurrent_reclaimers) <=
+		    max_zone_concurrent_reclaimers)
+			break;
+
+		schedule();
 
 		/*
 		 * If other processes freed enough memory while we waited,
@@ -1615,12 +1632,15 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
 		 */
 		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
 					0, 0)) {
-			wake_up(&zone->reclaim_wait);
+			wake_up(wq);
+			finish_wait(wq, &wait);
 			sc->nr_reclaimed += sc->nr_to_reclaim;
 			return -ERESTARTSYS;
 		}
 	}
+	finish_wait(wq, &wait);
 
+ out:
 	atomic_inc(&zone->concurrent_reclaimers);
 	return 0;
 }
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
