Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1342E8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 20:37:25 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAF1bM7E028772
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Nov 2010 10:37:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D9C145DE6F
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 10:37:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BA5A45DE60
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 10:37:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EA51E1DB803B
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 10:37:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 962BB1DB8037
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 10:37:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] cleanup kswapd()
In-Reply-To: <20101115092712.BEF4.A69D9226@jp.fujitsu.com>
References: <alpine.LNX.2.00.1011141202430.3460@swampdragon.chaosbits.net> <20101115092712.BEF4.A69D9226@jp.fujitsu.com>
Message-Id: <20101115103623.BF03.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 15 Nov 2010 10:37:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jesper Juhl <jj@chaosbits.net>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Right. thank you.
> I'll respin.

Done.



=46rom a29f0f5b780170fc26eb9210df03ed974aad8362 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 3 Dec 2010 10:48:41 +0900
Subject: [PATCH] factor out kswapd sleeping logic from kswapd()

Currently, kswapd() function has deeper nest and it slightly harder to
read. cleanup it.

Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   71 +++++++++++++++++++++++++++++++------------------------=
---
 1 files changed, 38 insertions(+), 33 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8cc90d5..3ee33a8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2364,6 +2364,42 @@ out:
 	return sc.nr_reclaimed;
 }
=20
+static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
+{
+	long remaining =3D 0;
+	DEFINE_WAIT(wait);
+
+	if (freezing(current) || kthread_should_stop())
+		return;
+
+	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+
+	/* Try to sleep for a short interval */
+	if (!sleeping_prematurely(pgdat, order, remaining)) {
+		remaining =3D schedule_timeout(HZ/10);
+		finish_wait(&pgdat->kswapd_wait, &wait);
+		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
+	}
+
+	/*
+	 * After a short sleep, check if it was a
+	 * premature sleep. If not, then go fully
+	 * to sleep until explicitly woken up
+	 */
+	if (!sleeping_prematurely(pgdat, order, remaining)) {
+		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
+		schedule();
+		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
+	} else {
+		if (remaining)
+			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
+		else
+			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
+	}
+	finish_wait(&pgdat->kswapd_wait, &wait);
+}
+
 /*
  * The background pageout daemon, started as a kernel thread
  * from the init process.
@@ -2382,7 +2418,7 @@ static int kswapd(void *p)
 	unsigned long order;
 	pg_data_t *pgdat =3D (pg_data_t*)p;
 	struct task_struct *tsk =3D current;
-	DEFINE_WAIT(wait);
+
 	struct reclaim_state reclaim_state =3D {
 		.reclaimed_slab =3D 0,
 	};
@@ -2414,7 +2450,6 @@ static int kswapd(void *p)
 		unsigned long new_order;
 		int ret;
=20
-		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		new_order =3D pgdat->kswapd_max_order;
 		pgdat->kswapd_max_order =3D 0;
 		if (order < new_order) {
@@ -2424,39 +2459,9 @@ static int kswapd(void *p)
 			 */
 			order =3D new_order;
 		} else {
-			if (!freezing(current) && !kthread_should_stop()) {
-				long remaining =3D 0;
-
-				/* Try to sleep for a short interval */
-				if (!sleeping_prematurely(pgdat, order, remaining)) {
-					remaining =3D schedule_timeout(HZ/10);
-					finish_wait(&pgdat->kswapd_wait, &wait);
-					prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-				}
-
-				/*
-				 * After a short sleep, check if it was a
-				 * premature sleep. If not, then go fully
-				 * to sleep until explicitly woken up
-				 */
-				if (!sleeping_prematurely(pgdat, order, remaining)) {
-					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
-					set_pgdat_percpu_threshold(pgdat,
-						calculate_normal_threshold);
-					schedule();
-					set_pgdat_percpu_threshold(pgdat,
-						calculate_pressure_threshold);
-				} else {
-					if (remaining)
-						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
-					else
-						count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
-				}
-			}
-
+			kswapd_try_to_sleep(pgdat, order);
 			order =3D pgdat->kswapd_max_order;
 		}
-		finish_wait(&pgdat->kswapd_wait, &wait);
=20
 		ret =3D try_to_freeze();
 		if (kthread_should_stop())
--=20
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
