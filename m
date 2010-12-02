Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 325B26B00B2
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 19:54:09 -0500 (EST)
Received: by iwn41 with SMTP id 41so649711iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 16:54:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291249749.12777.86.camel@sli10-conroe>
References: <1291172911.12777.58.camel@sli10-conroe>
	<20101201132730.ABC2.A69D9226@jp.fujitsu.com>
	<20101201155854.GA3372@barrios-desktop>
	<1291249749.12777.86.camel@sli10-conroe>
Date: Thu, 2 Dec 2010 09:54:07 +0900
Message-ID: <AANLkTi=p9s=2pRNw5fT7Lw_hYbi7GM-hrnQ-X+ETVhNZ@mail.gmail.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 2, 2010 at 9:29 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Wed, 2010-12-01 at 23:58 +0800, Minchan Kim wrote:
>> On Wed, Dec 01, 2010 at 06:44:27PM +0900, KOSAKI Motohiro wrote:
>> > > T0: Task1 wakeup_kswapd(order=3D3)
>> > > T1: kswapd enters balance_pgdat
>> > > T2: Task2 wakeup_kswapd(order=3D2), because pages reclaimed by kswap=
d are used
>> > > quickly
>> > > T3: kswapd exits balance_pgdat. kswapd will do check. Now new order=
=3D2,
>> > > pgdat->kswapd_max_order will become 0, but order=3D3, if sleeping_pr=
ematurely,
>> > > then order will become pgdat->kswapd_max_order(0), while at this tim=
e the
>> > > order should 2
>> > > This isn't a big deal, but we do have a small window the order is wr=
ong.
>> > >
>> > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>> > >
>> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > > index d31d7ce..15cd0d2 100644
>> > > --- a/mm/vmscan.c
>> > > +++ b/mm/vmscan.c
>> > > @@ -2450,7 +2450,7 @@ static int kswapd(void *p)
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> > >
>> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat->kswapd_max_order;
>> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D max_t(unsigned long, new=
_order, pgdat->kswapd_max_order);
>> > > =A0 =A0 =A0 =A0 =A0 }
>> > > =A0 =A0 =A0 =A0 =A0 finish_wait(&pgdat->kswapd_wait, &wait);
>> >
>> > Good catch!
>> >
>> > But unfortunatelly, the code is not correct. At least, don't fit corre=
nt
>> > design.
>> >
>> > 1) if "order < new_order" condition is false, we already decided to do=
n't
>> > =A0 =A0use new_order. So, we shouldn't use new_order after kswapd_try_=
to_sleep()
>> > 2) if sleeping_prematurely() return false, it probably mean
>> > =A0 =A0zone_watermark_ok_safe(zone, order, high_wmark) return false.
>> > =A0 =A0therefore, we have to retry reclaim by using old 'order' parame=
ter.
>>
>> Good catch, too.
>>
>> In Shaohua's scenario, if Task1 gets the order-3 page after kswapd's rec=
laiming,
>> it's no problem.
>> But if Task1 doesn't get the order-3 page and others used the order-3 pa=
ge for Task1,
>> Kswapd have to reclaim order-3 for Task1, again.
> why? it's just a possibility. Task1 might get its pages too. If Task1
> doesn't get its pages, it will wakeup kswapd too with its order.
>
>> In addtion, new order is always less than old order in that context.
>> so big order page reclaim makes much safe for low order pages.
> big order page reclaim makes we have more chances to reclaim useful
> pages by lumpy, why it's safe?

For example, It assume tat Task1 continues to fail get the order-3
page of GFP_ATOMIC since other tasks continues to allocate order-2
pages so that they steal pages. Then, your patch makes continue to
reclaim order-2 page in this scenario. Task1 never get the order-3
pages if it doesn't have a merge luck. It's kind of live lock(But it's
just unlikely theory). But KOSAKI's approach can make sure reclaim
order-3 pages so it can meet requirement about both order-2,3. In this
context, I said _safety_.

Of course, it could discard useful pages if Task1 get a pages. I think
it's a trade-off.
We should determine the policy.
I biased safety of GFP_ATOMIC.

> Thanks,
> Shaohua
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
