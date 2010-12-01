Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 86D7C6B0089
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 10:59:14 -0500 (EST)
Received: by ywj3 with SMTP id 3so725829ywj.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 07:59:12 -0800 (PST)
Date: Thu, 2 Dec 2010 00:58:54 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
Message-ID: <20101201155854.GA3372@barrios-desktop>
References: <1291172911.12777.58.camel@sli10-conroe>
 <20101201132730.ABC2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101201132730.ABC2.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 01, 2010 at 06:44:27PM +0900, KOSAKI Motohiro wrote:
> > T0: Task1 wakeup_kswapd(order=3)
> > T1: kswapd enters balance_pgdat
> > T2: Task2 wakeup_kswapd(order=2), because pages reclaimed by kswapd are used
> > quickly
> > T3: kswapd exits balance_pgdat. kswapd will do check. Now new order=2,
> > pgdat->kswapd_max_order will become 0, but order=3, if sleeping_prematurely,
> > then order will become pgdat->kswapd_max_order(0), while at this time the
> > order should 2
> > This isn't a big deal, but we do have a small window the order is wrong.
> > 
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d31d7ce..15cd0d2 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2450,7 +2450,7 @@ static int kswapd(void *p)
> >  				}
> >  			}
> >  
> > -			order = pgdat->kswapd_max_order;
> > +			order = max_t(unsigned long, new_order, pgdat->kswapd_max_order);
> >  		}
> >  		finish_wait(&pgdat->kswapd_wait, &wait);
> 
> Good catch!
> 
> But unfortunatelly, the code is not correct. At least, don't fit corrent
> design.
> 
> 1) if "order < new_order" condition is false, we already decided to don't
>    use new_order. So, we shouldn't use new_order after kswapd_try_to_sleep()
> 2) if sleeping_prematurely() return false, it probably mean
>    zone_watermark_ok_safe(zone, order, high_wmark) return false.
>    therefore, we have to retry reclaim by using old 'order' parameter.

Good catch, too.

In Shaohua's scenario, if Task1 gets the order-3 page after kswapd's reclaiming,
it's no problem.
But if Task1 doesn't get the order-3 page and others used the order-3 page for Task1,
Kswapd have to reclaim order-3 for Task1, again.
In addtion, new order is always less than old order in that context. 
so big order page reclaim makes much safe for low order pages.

> 
> new patch is here.
> 
> 
> 
> From 8f436224219a1da01985fd9644e1307e7c4cb8c3 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Sun, 26 Dec 2010 21:10:55 +0900
> Subject: [PATCH] vmscan: make kswapd use a correct order
> 
> If sleeping_prematurely() return false, It's a sign of retrying reclaim.
> So, we don't have to drop old order value.

I think this description isn't enough.

> 
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
But could you see my below suggestion?

> ---
>  mm/vmscan.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 1fcadaf..f052a1a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2364,13 +2364,13 @@ out:
>  	return sc.nr_reclaimed;
>  }
>  
> -static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
> +static int kswapd_try_to_sleep(pg_data_t *pgdat, int order)
>  {
>  	long remaining = 0;
>  	DEFINE_WAIT(wait);
>  
>  	if (freezing(current) || kthread_should_stop())
> -		return;
> +		return 0;
>  
>  	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  
> @@ -2399,13 +2399,17 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
>  		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
>  		schedule();
>  		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
> +		order = pgdat->kswapd_max_order;
>  	} else {
>  		if (remaining)
>  			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
>  		else
>  			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
> +		order = max(order, pgdat->kswapd_max_order);
>  	}
>  	finish_wait(&pgdat->kswapd_wait, &wait);
> +
> +	return order;
>  }
>  
>  /*
> @@ -2467,8 +2471,7 @@ static int kswapd(void *p)
>  			 */
>  			order = new_order;
>  		} else {
> -			kswapd_try_to_sleep(pgdat, order);
> -			order = pgdat->kswapd_max_order;
> +			order = kswapd_try_to_sleep(pgdat, order);
>  		}
>  
>  		ret = try_to_freeze();
> -- 
> 1.6.5.2
> 
> 

It might work well. but I don't like such a coding that kswapd_try_to_sleep's
eturn value is order. It doesn't look good to me and even no comment. Hmm..

How about this?
If you want it, feel free to use it.
If you insist on your coding style, I don't have any objection.
Then add My Reviewed-by.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 42a4859..e48a612 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2447,13 +2447,18 @@ out:
 	return sc.nr_reclaimed;
 }
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
+/*
+ * Return true if we sleep enough. Othrewise, return false
+ */
+static bool kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 {
 	long remaining = 0;
+	bool sleep = 0;
+
 	DEFINE_WAIT(wait);
 
 	if (freezing(current) || kthread_should_stop())
-		return;
+		return sleep;
 
 	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
 
@@ -2482,6 +2487,7 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
 		schedule();
 		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
+		sleep = 1;
 	} else {
 		if (remaining)
 			count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
@@ -2489,6 +2495,8 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int order)
 			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
 	}
 	finish_wait(&pgdat->kswapd_wait, &wait);
+
+	return sleep;
 }
 
 /*
@@ -2550,8 +2558,13 @@ static int kswapd(void *p)
 			 */
 			order = new_order;
 		} else {
-			kswapd_try_to_sleep(pgdat, order);
-			order = pgdat->kswapd_max_order;
+			/*
+			 * If we wake up after enough sleeping, let's
+			 * start new order. Otherwise, it was a premature
+			 * sleep so we keep going on.
+			 */
+			if (kswapd_try_to_sleep(pgdat, order))
+				order = pgdat->kswapd_max_order;
 		}
 
 		ret = try_to_freeze();
-- 
1.7.0.4

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
