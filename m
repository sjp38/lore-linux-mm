Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B456F6B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:30:29 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECUK4Q003099
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:30:21 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A4B045DE60
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:30:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 68B0C45DE4D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:30:20 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34CCE1DB803B
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:30:20 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E50C41DB8037
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:30:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/8] Use prepare_to_wait_exclusive() instead prepare_to_wait()
In-Reply-To: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
References: <20091211164651.036f5340@annuminas.surriel.com> <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
Message-Id: <20091214212936.BBBA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Dec 2009 21:30:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

if we don't use exclusive queue, wake_up() function wake _all_ waited
task. This is simply cpu wasting.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0cb834..3562a2d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1618,7 +1618,7 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
 	 * we would just make things slower.
 	 */
 	for (;;) {
-		prepare_to_wait(wq, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait_exclusive(wq, &wait, TASK_UNINTERRUPTIBLE);
 
 		if (atomic_read(&zone->concurrent_reclaimers) <=
 		    max_zone_concurrent_reclaimers)
@@ -1632,7 +1632,7 @@ static int shrink_zone_begin(struct zone *zone, struct scan_control *sc)
                 */
 		if (zone_watermark_ok(zone, sc->order, low_wmark_pages(zone),
 					0, 0)) {
-			wake_up(wq);
+			wake_up_all(wq);
 			finish_wait(wq, &wait);
 			sc->nr_reclaimed += sc->nr_to_reclaim;
 			return -ERESTARTSYS;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
