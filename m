Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E984E6B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 04:44:34 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB19iVAm025025
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 18:44:31 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4694045DE55
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:44:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 21A8745DE69
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:44:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 12B941DB803A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:44:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C4713E18005
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 18:44:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
In-Reply-To: <1291172911.12777.58.camel@sli10-conroe>
References: <1291172911.12777.58.camel@sli10-conroe>
Message-Id: <20101201132730.ABC2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed,  1 Dec 2010 18:44:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

> T0: Task1 wakeup_kswapd(order=3D3)
> T1: kswapd enters balance_pgdat
> T2: Task2 wakeup_kswapd(order=3D2), because pages reclaimed by kswapd are=
 used
> quickly
> T3: kswapd exits balance_pgdat. kswapd will do check. Now new order=3D2,
> pgdat->kswapd_max_order will become 0, but order=3D3, if sleeping_prematu=
rely,
> then order will become pgdat->kswapd_max_order(0), while at this time the
> order should 2
> This isn't a big deal, but we do have a small window the order is wrong.
>=20
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>=20
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d31d7ce..15cd0d2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2450,7 +2450,7 @@ static int kswapd(void *p)
>  				}
>  			}
> =20
> -			order =3D pgdat->kswapd_max_order;
> +			order =3D max_t(unsigned long, new_order, pgdat->kswapd_max_order);
>  		}
>  		finish_wait(&pgdat->kswapd_wait, &wait);

Good catch!

But unfortunatelly, the code is not correct. At least, don't fit corrent
design.

1) if "order < new_order" condition is false, we already decided to don't
   use new_order. So, we shouldn't use new_order after kswapd_try_to_sleep(=
)
2) if sleeping_prematurely() return false, it probably mean
   zone_watermark_ok_safe(zone, order, high_wmark) return false.
   therefore, we have to retry reclaim by using old 'order' parameter.


new patch is here.



=46rom 8f436224219a1da01985fd9644e1307e7c4cb8c3 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sun, 26 Dec 2010 21:10:55 +0900
Subject: [PATCH] vmscan: make kswapd use a correct order

If sleeping_prematurely() return false, It's a sign of retrying reclaim.
So, we don't have to drop old order value.

Reported-by: Shaohua Li <shaohua.li@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1fcadaf..f052a1a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2364,13 +2364,13 @@ out:
 	return sc.nr_reclaimed;
 }
=20
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
+static int kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 {
 	long remaining =3D 0;
 	DEFINE_WAIT(wait);
=20
 	if (freezing(current) || kthread_should_stop())
-		return;
+		return 0;
=20
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
=20
@@ -2399,13 +2399,17 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, i=
nt order)
 		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
 		schedule();
 		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
+		order =3D pgdat->kswapd_max_order;
 	} else {
 		if (remaining)
 			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
 		else
 			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
+		order =3D max(order, pgdat->kswapd_max_order);
 	}
 	finish_wait(&pgdat->kswapd_wait, &wait);
+
+	return order;
 }
=20
 /*
@@ -2467,8 +2471,7 @@ static int kswapd(void *p)
 			 */
 			order =3D new_order;
 		} else {
-			kswapd_try_to_sleep(pgdat, order);
-			order =3D pgdat->kswapd_max_order;
+			order =3D kswapd_try_to_sleep(pgdat, order);
 		}
=20
 		ret =3D try_to_freeze();
--=20
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
