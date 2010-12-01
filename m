Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A1DE86B0088
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 00:42:07 -0500 (EST)
Subject: Re: [patch]vmscan: make kswapd use a correct order
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <AANLkTi=whw86_7T0tVi5S8xmwS+Z3PDE_AbXEJSQFqR4@mail.gmail.com>
References: <1291172911.12777.58.camel@sli10-conroe>
	 <AANLkTi=whw86_7T0tVi5S8xmwS+Z3PDE_AbXEJSQFqR4@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 13:42:05 +0800
Message-ID: <1291182125.12777.69.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-12-01 at 12:21 +0800, Minchan Kim wrote:
> On Wed, Dec 1, 2010 at 12:08 PM, Shaohua Li <shaohua.li@intel.com> wrote:
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
> Reviewed-by: Minchan Kim <minchan.kim@gmai.com>
> 
> But you need the description more easily.
> 
> I try it.
Thanks, changed the description.


T0: Task 1 wakes up kswapd with order-3
T1: So, kswapd starts to reclaim pages using balance_pgdat
T2: Task 2 wakes up kswapd with order-2 because pages reclaimed by T1
are consumed quickly.
T3: kswapd exits balance_pgdat and will do following:
T4-1: In beginning of kswapd's loop, pgdat->kswapd_max_order will be
reset with zero.
T4-2: order will be set to pgdat->kswapd_max_order(0), since it enters the
false branch of 'if (order (3) < new_order (2))'
T4-3: If previous balance_pgdat can't meet requirement of order-2 free
pages by high watermark, it will start reclaiming again. So balance_pgdat will
use order-0 to do reclaim, while at this time it really should use order-2

This isn't a big deal, but we do have a small window the order is wrong.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d31d7ce..c630349 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2450,7 +2450,8 @@ static int kswapd(void *p)
 				}
 			}
 
-			order = pgdat->kswapd_max_order;
+			order = max_t(unsigned long, new_order,
+				pgdat->kswapd_max_order);
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
