Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 35DAC6B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 03:09:35 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p4A79V6r008916
	for <linux-mm@kvack.org>; Tue, 10 May 2011 00:09:32 -0700
Received: from qwf6 (qwf6.prod.google.com [10.241.194.70])
	by kpbe19.cbf.corp.google.com with ESMTP id p4A79RZ4021614
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 May 2011 00:09:30 -0700
Received: by qwf6 with SMTP id 6so4343576qwf.30
        for <linux-mm@kvack.org>; Tue, 10 May 2011 00:09:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110510062731.GE16531@cmpxchg.org>
References: <20110503082550.GD18927@tiehlicka.suse.cz>
	<BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
	<20110504085851.GC1375@tiehlicka.suse.cz>
	<BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
	<20110505065901.GC11529@tiehlicka.suse.cz>
	<20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinEEzkpBeTdK9nP2DAxRZbH8Ve=xw@mail.gmail.com>
	<20110509161047.eb674346.kamezawa.hiroyu@jp.fujitsu.com>
	<20110509101817.GB16531@cmpxchg.org>
	<BANLkTikeHA9fd89jerV7VB2kg3kh=aeHMA@mail.gmail.com>
	<20110510062731.GE16531@cmpxchg.org>
Date: Tue, 10 May 2011 00:09:27 -0700
Message-ID: <BANLkTi=n+R021tqEztKWJyE5q51kRa=epg@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon, May 9, 2011 at 11:27 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Mon, May 09, 2011 at 09:51:43PM -0700, Ying Han wrote:
>> On Mon, May 9, 2011 at 3:18 AM, Johannes Weiner <hannes@cmpxchg.org> wro=
te:
>> > On Mon, May 09, 2011 at 04:10:47PM +0900, KAMEZAWA Hiroyuki wrote:
>> >> On Sun, 8 May 2011 22:40:47 -0700
>> >> Ying Han <yinghan@google.com> wrote:
>> >> > Using the
>> >> > limit to calculate the wmarks is straight-forward since doing
>> >> > background reclaim reduces the latency spikes under direct reclaim.
>> >> > The direct reclaim is triggered while the usage is hitting the limi=
t.
>> >> >
>> >> > This is different from the "soft_limit" which is based on the usage
>> >> > and we don't want to reinvent the soft_limit implementation.
>> >> >
>> >> Yes, this is a different feature.
>> >>
>> >>
>> >> The discussion here is how to make APIs for "shrink_to" and "shrink_o=
ver", ok ?
>> >>
>> >> I think there are 3 candidates.
>> >>
>> >> =A0 1. using distance to limit.
>> >> =A0 =A0 =A0memory.shrink_to_distance
>> >> =A0 =A0 =A0 =A0 =A0 =A0- memory will be freed to 'limit - shrink_to_d=
istance'.
>> >> =A0 =A0 =A0memory.shrink_over_distance
>> >> =A0 =A0 =A0 =A0 =A0 =A0- memory will be freed when usage > 'limit - s=
hrink_over_distance'
>> >>
>> >> =A0 =A0 =A0Pros.
>> >> =A0 =A0 =A0 - Both of shrink_over and shirnk_to can be determined by =
users.
>> >> =A0 =A0 =A0 - Can keep stable distance to limit even when limit is ch=
anged.
>> >> =A0 =A0 =A0Cons.
>> >> =A0 =A0 =A0 - complicated and seems not natural.
>> >> =A0 =A0 =A0 - hierarchy support will be very difficult.
>> >>
>> >> =A0 2. using bare value
>> >> =A0 =A0 =A0memory.shrink_to
>> >> =A0 =A0 =A0 =A0 =A0 =A0- memory will be freed to this 'shirnk_to'
>> >> =A0 =A0 =A0memory.shrink_from
>> >> =A0 =A0 =A0 =A0 =A0 =A0- memory will be freed when usage over this va=
lue.
>> >> =A0 =A0 =A0Pros.
>> >> =A0 =A0 =A0 - Both of shrink_over and shrink)to can be determined by =
users.
>> >> =A0 =A0 =A0 - easy to understand, straightforward.
>> >> =A0 =A0 =A0 - hierarchy support will be easy.
>> >> =A0 =A0 =A0Cons.
>> >> =A0 =A0 =A0 - The user may need to change this value when he changes =
the limit.
>> >>
>> >>
>> >> =A0 3. using only 'shrink_to'
>> >> =A0 =A0 =A0memory.shrink_to
>> >> =A0 =A0 =A0 =A0 =A0 =A0- memory will be freed to this value when the =
usage goes over this vaue
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0to some extent (determined by the system.)
>> >>
>> >> =A0 =A0 =A0Pros.
>> >> =A0 =A0 =A0 - easy interface.
>> >> =A0 =A0 =A0 - hierarchy support will be easy.
>> >> =A0 =A0 =A0 - bad configuration check is very easy.
>> >> =A0 =A0 =A0Cons.
>> >> =A0 =A0 =A0 - The user may beed to change this value when he changes =
the limit.
>> >>
>> >>
>> >> Then, I now vote for 3 because hierarchy support is easiest and enoug=
h handy for
>> >> real use.
>> >
>> > 3. looks best to me as well.
>> >
>> > What I am wondering, though: we already have a limit to push back
>> > memcgs when we need memory, the soft limit. =A0The 'need for memory' i=
s
>> > currently defined as global memory pressure, which we know may be too
>> > late. =A0The problem is not having no limit, the problem is that we wa=
nt
>> > to control the time of when this limit is enforced. =A0So instead of
>> > adding another limit, could we instead add a knob like
>> >
>> > =A0 =A0 =A0 =A0memory.force_async_soft_reclaim
>> >
>> > that asynchroneously pushes back to the soft limit instead of having
>> > another, separate limit to configure?
>> >
>> > Pros:
>> > - easy interface
>> > - limit already existing
>> > - hierarchy support already existing
>> > - bad configuration check already existing
>> > Cons:
>> > - ?
>>
>> Are we proposing to set the target of per-memcg background reclaim to
>> be the soft_limit?
>
> Yes, if memory.force_async_soft_reclaim is set.
>
>> If so, i would highly doubt for that. The
>> logic of background reclaim is to start reclaiming memory before
>> reaching the hard_limit, and stops whence
>> it makes enough progress. The motivation is to reduce the times for
>> memcg hitting direct reclaim and that is quite different from
>> the design of soft_limit. The soft_limit is designed to serve the
>> over-commit environment where memory can be shared across memcgs
>> until the global memory pressure. There is no correlation between that
>> to the watermark based background reclaim.
>
> Your whole argument for the knob so far has been that you want to use
> it to proactively reduce memory usage, and I argued that it has
> nothing to do with watermark reclaim. =A0This is exactly why I have been
> fighting making the watermark configurable and abuse it for that.



>
>> Making the soft_limit as target for background reclaim will make extra
>> memory pressure when not necessary. So I don't have issue to have
>> the tunable later and set the watermark equal to the soft_limit, but
>> using it as alternative to the watermarks is not straight-forward to
>> me at
>> this point.
>
> Please read my above proposal again, noone suggested to replace the
> watermark with the soft limit.
>
> 1. The watermark is always in place, computed by the kernel alone, and
> triggers background targetted reclaim when breached.

>
> 2. The soft limit is enforced as usual upon memory pressure.

>
> 3. In addition, the soft limit is enforced by background reclaim if
> memory.force_async_soft_reclaim is set.
>
> Thus, you can use 3. if you foresee memory pressure and want to
> proactively push back a memcg to the soft limit.

Ok, thanks a lot for the clarification. I was confused at the
beginning of using the force_async_soft_reclaim as the alternatives to
background reclaim watermarks. So, the proposal looks good to me and
the computed watermarks based on the hard_limit by default
should work most of the time w/o the configurable tunable.

--Ying

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
