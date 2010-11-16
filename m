Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D08828D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 01:07:30 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAG67Qna030052
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Nov 2010 15:07:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 44F5A45DE79
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:07:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AEE7C45DE6F
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:07:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EBE2A1DB8043
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:07:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A0E01DB803B
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:07:23 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH v3] factor out kswapd sleeping logic from kswapd()
In-Reply-To: <20101115094239.GH27362@csn.ul.ie>
References: <20101114180505.BEE2.A69D9226@jp.fujitsu.com> <20101115094239.GH27362@csn.ul.ie>
Message-Id: <20101116144709.BF26.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 16 Nov 2010 15:07:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > +void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> > +{
>=20
> As pointed out elsewhere, this should be static.

Fixed.


> > +	long remaining =3D 0;
> > +	DEFINE_WAIT(wait);
> > +
> > +	if (freezing(current) || kthread_should_stop())
> > +		return;
> > +
> > +	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > +
> > +	/* Try to sleep for a short interval */
> > +	if (!sleeping_prematurely(pgdat, order, remaining)) {
> > +		remaining =3D schedule_timeout(HZ/10);
> > +		finish_wait(&pgdat->kswapd_wait, &wait);
> > +		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> > +	}
> > +
> > +	/*
> > +	 * After a short sleep, check if it was a
> > +	 * premature sleep. If not, then go fully
> > +	 * to sleep until explicitly woken up
> > +	 */
>=20
> Very minor but that comment should now fit on fewer lines.

Thanks, fixed.


> > +	if (!sleeping_prematurely(pgdat, order, remaining)) {
> > +		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
> > +		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
> > +		schedule();
> > +		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
>=20
> I posted a patch adding a comment on why set_pgdat_percpu_threshold() is
> called. I do not believe it has been picked up by Andrew but it if is,
> the patches will conflict. The resolution will be obvious but you may
> need to respin this patch if the comment patch gets picked up in mmotm.
>=20
> Otherwise, I see no problems.

OK, I've rebased the patch on top your comment patch.=20



=46rom 1bd232713d55f033676f80cc7451ff83d4483884 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 6 Dec 2010 20:44:27 +0900
Subject: [PATCH] factor out kswapd sleeping logic from kswapd()

Currently, kswapd() function has deeper nest and it slightly harder to
read. cleanup it.

Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   92 +++++++++++++++++++++++++++++--------------------------=
---
 1 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 33994b7..cd07b97 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2364,6 +2364,50 @@ out:
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
+	 * After a short sleep, check if it was a premature sleep. If not, then
+	 * go fully to sleep until explicitly woken up.
+	 */
+	if (!sleeping_prematurely(pgdat, order, remaining)) {
+		trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
+
+		/*
+		 * vmstat counters are not perfectly accurate and the estimated
+		 * value for counters such as NR_FREE_PAGES can deviate from the
+		 * true value by nr_online_cpus * threshold. To avoid the zone
+		 * watermarks being breached while under pressure, we reduce the
+		 * per-cpu vmstat threshold while kswapd is awake and restore
+		 * them before going back to sleep.
+		 */
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
@@ -2382,7 +2426,7 @@ static int kswapd(void *p)
 	unsigned long order;
 	pg_data_t *pgdat =3D (pg_data_t*)p;
 	struct task_struct *tsk =3D current;
-	DEFINE_WAIT(wait);
+
 	struct reclaim_state reclaim_state =3D {
 		.reclaimed_slab =3D 0,
 	};
@@ -2414,7 +2458,6 @@ static int kswapd(void *p)
 		unsigned long new_order;
 		int ret;
=20
-		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 		new_order =3D pgdat->kswapd_max_order;
 		pgdat->kswapd_max_order =3D 0;
 		if (order < new_order) {
@@ -2424,52 +2467,9 @@ static int kswapd(void *p)
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
-
-					/*
-					 * vmstat counters are not perfectly
-					 * accurate and the estimated value
-					 * for counters such as NR_FREE_PAGES
-					 * can deviate from the true value by
-					 * nr_online_cpus * threshold. To
-					 * avoid the zone watermarks being
-					 * breached while under pressure, we
-					 * reduce the per-cpu vmstat threshold
-					 * while kswapd is awake and restore
-					 * them before going back to sleep.
-					 */
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
