Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6B1996B0071
	for <linux-mm@kvack.org>; Thu,  2 Dec 2010 10:25:31 -0500 (EST)
Received: by pvc30 with SMTP id 30so1713241pvc.14
        for <linux-mm@kvack.org>; Thu, 02 Dec 2010 07:25:26 -0800 (PST)
Date: Fri, 3 Dec 2010 00:25:18 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
Message-ID: <20101202152518.GA1735@barrios-desktop>
References: <1291172911.12777.58.camel@sli10-conroe>
 <20101201132730.ABC2.A69D9226@jp.fujitsu.com>
 <20101201155854.GA3372@barrios-desktop>
 <1291249749.12777.86.camel@sli10-conroe>
 <AANLkTi=p9s=2pRNw5fT7Lw_hYbi7GM-hrnQ-X+ETVhNZ@mail.gmail.com>
 <1291251908.12777.94.camel@sli10-conroe>
 <AANLkTinE-b41jedk7GRXvwLu7Qvis7+CJVQPJBsEAWLD@mail.gmail.com>
 <AANLkTi==LkT2gvnox7kjXBfQiDvHGJtHSCahh=_yzKH2@mail.gmail.com>
 <20101202094241.GQ13268@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101202094241.GQ13268@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 02, 2010 at 09:42:42AM +0000, Mel Gorman wrote:
> On Thu, Dec 02, 2010 at 10:36:27AM +0900, Minchan Kim wrote:
> > Where is my mail?
> > I will resend lost content.
> > 
> > On Thu, Dec 2, 2010 at 10:23 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > > On Thu, Dec 2, 2010 at 10:05 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> > >> On Thu, 2010-12-02 at 08:54 +0800, Minchan Kim wrote:
> > >>> On Thu, Dec 2, 2010 at 9:29 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> > >>> > On Wed, 2010-12-01 at 23:58 +0800, Minchan Kim wrote:
> > >>> >> On Wed, Dec 01, 2010 at 06:44:27PM +0900, KOSAKI Motohiro wrote:
> > >>> >> > > T0: Task1 wakeup_kswapd(order=3)
> > >>> >> > > T1: kswapd enters balance_pgdat
> > >>> >> > > T2: Task2 wakeup_kswapd(order=2), because pages reclaimed by kswapd are used
> > >>> >> > > quickly
> > >>> >> > > T3: kswapd exits balance_pgdat. kswapd will do check. Now new order=2,
> > >>> >> > > pgdat->kswapd_max_order will become 0, but order=3, if sleeping_prematurely,
> > >>> >> > > then order will become pgdat->kswapd_max_order(0), while at this time the
> > >>> >> > > order should 2
> > >>> >> > > This isn't a big deal, but we do have a small window the order is wrong.
> > >>> >> > >
> > >>> >> > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > >>> >> > >
> > >>> >> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > >>> >> > > index d31d7ce..15cd0d2 100644
> > >>> >> > > --- a/mm/vmscan.c
> > >>> >> > > +++ b/mm/vmscan.c
> > >>> >> > > @@ -2450,7 +2450,7 @@ static int kswapd(void *p)
> > >>> >> > > ? ? ? ? ? ? ? ? ? ? ? ? ? }
> > >>> >> > > ? ? ? ? ? ? ? ? ? }
> > >>> >> > >
> > >>> >> > > - ? ? ? ? ? ? ? ? order = pgdat->kswapd_max_order;
> > >>> >> > > + ? ? ? ? ? ? ? ? order = max_t(unsigned long, new_order, pgdat->kswapd_max_order);
> > >>> >> > > ? ? ? ? ? }
> > >>> >> > > ? ? ? ? ? finish_wait(&pgdat->kswapd_wait, &wait);
> > >>> >> >
> > >>> >> > Good catch!
> > >>> >> >
> > >>> >> > But unfortunatelly, the code is not correct. At least, don't fit corrent
> > >>> >> > design.
> > >>> >> >
> > >>> >> > 1) if "order < new_order" condition is false, we already decided to don't
> > >>> >> > ? ?use new_order. So, we shouldn't use new_order after kswapd_try_to_sleep()
> > >>> >> > 2) if sleeping_prematurely() return false, it probably mean
> > >>> >> > ? ?zone_watermark_ok_safe(zone, order, high_wmark) return false.
> > >>> >> > ? ?therefore, we have to retry reclaim by using old 'order' parameter.
> > >>> >>
> > >>> >> Good catch, too.
> > >>> >>
> > >>> >> In Shaohua's scenario, if Task1 gets the order-3 page after kswapd's reclaiming,
> > >>> >> it's no problem.
> > >>> >> But if Task1 doesn't get the order-3 page and others used the order-3 page for Task1,
> > >>> >> Kswapd have to reclaim order-3 for Task1, again.
> > >>> > why? it's just a possibility. Task1 might get its pages too. If Task1
> > >>> > doesn't get its pages, it will wakeup kswapd too with its order.
> > >>> >
> > >>> >> In addtion, new order is always less than old order in that context.
> > >>> >> so big order page reclaim makes much safe for low order pages.
> > >>> > big order page reclaim makes we have more chances to reclaim useful
> > >>> > pages by lumpy, why it's safe?
> > >>>
> > >>> For example, It assume tat Task1 continues to fail get the order-3
> > >>> page of GFP_ATOMIC since other tasks continues to allocate order-2
> > >>> pages so that they steal pages.
> > >> but even you reclaim order-3, you can't guarantee task1 can get the
> > >> pages too. order-3 page can be steal by order-2 allocation
> > >
> > > But at least, it has a high possibility to allocate order-3 page than
> > > reclaim order-2 pages.
> > >
> > >>
> > >>> Then, your patch makes continue to
> > >>> reclaim order-2 page in this scenario. Task1 never get the order-3
> > >>> pages if it doesn't have a merge luck.
> > >> Task1 will wakeup kswapd again for order-3, so kswapd will reclaim
> > >> order-3 very soon after the order-2 reclaim.
> > >
> > > GFP_ATOMIC case doesn't wakeup kswapd.
> > > When kswapd wakeup by order-3 depends on caller's retry.
> > > And this situation can be repeated in next turn.
> > >
> 
> GFP_ATOMIC does wakeup kswapd. It just doesn't wait on kswapd to do
> anything.

I mean GFP_ATOMIC doesn't do restart for waking up kswapd again 
in __alloc_pages_slowpath.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
