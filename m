Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 34C658D0002
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:23:06 -0500 (EST)
Received: by iwn41 with SMTP id 41so678175iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 17:23:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1291251908.12777.94.camel@sli10-conroe>
References: <1291172911.12777.58.camel@sli10-conroe>
	<20101201132730.ABC2.A69D9226@jp.fujitsu.com>
	<20101201155854.GA3372@barrios-desktop>
	<1291249749.12777.86.camel@sli10-conroe>
	<AANLkTi=p9s=2pRNw5fT7Lw_hYbi7GM-hrnQ-X+ETVhNZ@mail.gmail.com>
	<1291251908.12777.94.camel@sli10-conroe>
Date: Thu, 2 Dec 2010 10:23:04 +0900
Message-ID: <AANLkTinE-b41jedk7GRXvwLu7Qvis7+CJVQPJBsEAWLD@mail.gmail.com>
Subject: Re: [patch]vmscan: make kswapd use a correct order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 2, 2010 at 10:05 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Thu, 2010-12-02 at 08:54 +0800, Minchan Kim wrote:
>> On Thu, Dec 2, 2010 at 9:29 AM, Shaohua Li <shaohua.li@intel.com> wrote:
>> > On Wed, 2010-12-01 at 23:58 +0800, Minchan Kim wrote:
>> >> On Wed, Dec 01, 2010 at 06:44:27PM +0900, KOSAKI Motohiro wrote:
>> >> > > T0: Task1 wakeup_kswapd(order=3D3)
>> >> > > T1: kswapd enters balance_pgdat
>> >> > > T2: Task2 wakeup_kswapd(order=3D2), because pages reclaimed by ks=
wapd are used
>> >> > > quickly
>> >> > > T3: kswapd exits balance_pgdat. kswapd will do check. Now new ord=
er=3D2,
>> >> > > pgdat->kswapd_max_order will become 0, but order=3D3, if sleeping=
_prematurely,
>> >> > > then order will become pgdat->kswapd_max_order(0), while at this =
time the
>> >> > > order should 2
>> >> > > This isn't a big deal, but we do have a small window the order is=
 wrong.
>> >> > >
>> >> > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>> >> > >
>> >> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> > > index d31d7ce..15cd0d2 100644
>> >> > > --- a/mm/vmscan.c
>> >> > > +++ b/mm/vmscan.c
>> >> > > @@ -2450,7 +2450,7 @@ static int kswapd(void *p)
>> >> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >> > > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >> > >
>> >> > > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D pgdat->kswapd_max_ord=
er;
>> >> > > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order =3D max_t(unsigned long, =
new_order, pgdat->kswapd_max_order);
>> >> > > =A0 =A0 =A0 =A0 =A0 }
>> >> > > =A0 =A0 =A0 =A0 =A0 finish_wait(&pgdat->kswapd_wait, &wait);
>> >> >
>> >> > Good catch!
>> >> >
>> >> > But unfortunatelly, the code is not correct. At least, don't fit co=
rrent
>> >> > design.
>> >> >
>> >> > 1) if "order < new_order" condition is false, we already decided to=
 don't
>> >> > =A0 =A0use new_order. So, we shouldn't use new_order after kswapd_t=
ry_to_sleep()
>> >> > 2) if sleeping_prematurely() return false, it probably mean
>> >> > =A0 =A0zone_watermark_ok_safe(zone, order, high_wmark) return false=
