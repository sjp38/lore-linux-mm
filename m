Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8296B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 00:43:25 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p4A4hMV0017367
	for <linux-mm@kvack.org>; Mon, 9 May 2011 21:43:23 -0700
Received: from qwc23 (qwc23.prod.google.com [10.241.193.151])
	by hpaq14.eem.corp.google.com with ESMTP id p4A4hK7s006477
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 9 May 2011 21:43:21 -0700
Received: by qwc23 with SMTP id 23so3540998qwc.3
        for <linux-mm@kvack.org>; Mon, 09 May 2011 21:43:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110509095804.GA16531@cmpxchg.org>
References: <20110503064945.GA18927@tiehlicka.suse.cz>
	<BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
	<20110503082550.GD18927@tiehlicka.suse.cz>
	<BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
	<20110504085851.GC1375@tiehlicka.suse.cz>
	<BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
	<20110505065901.GC11529@tiehlicka.suse.cz>
	<20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
	<20110506142257.GI10278@cmpxchg.org>
	<20110509092112.7d8ae017.kamezawa.hiroyu@jp.fujitsu.com>
	<20110509095804.GA16531@cmpxchg.org>
Date: Mon, 9 May 2011 21:43:20 -0700
Message-ID: <BANLkTinxG7E7+ec7LEkgBLWFm8j5pb3opg@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon, May 9, 2011 at 2:58 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Mon, May 09, 2011 at 09:21:12AM +0900, KAMEZAWA Hiroyuki wrote:
>> On Fri, 6 May 2011 16:22:57 +0200
>> Johannes Weiner <hannes@cmpxchg.org> wrote:
>>
>> > On Fri, May 06, 2011 at 02:28:34PM +0900, KAMEZAWA Hiroyuki wrote:
>> > > Hmm, so, the interface should be
>> > >
>> > > =A0 memory.watermark =A0--- the total usage which kernel's memory sh=
rinker starts.
>> > >
>> > > ?
>> > >
>> > > I'm okay with this. And I think this parameter should be fully indep=
endent from
>> > > the limit.
>> > >
>> > > Memcg can work without watermark reclaim. I think my patch just adds=
 a new
>> > > _limit_ which a user can shrink usage of memory on deamand with kern=
el's help.
>> > > Memory reclaim works in background but this is not a kswapd, at all.
>> > >
>> > > I guess performance benefit of using watermark under a cgroup which =
has limit
>> > > is very small and I think this is not for a performance tuning param=
eter.
>> > > This is just a new limit.
>> > >
>> > > Comparing 2 cases,
>> > >
>> > > =A0cgroup A)
>> > > =A0 =A0- has limit of 300M, no watermaks.
>> > > =A0cgroup B)
>> > > =A0 =A0- has limit of UNLIMITED, watermarks=3D300M
>> > >
>> > > A) has hard limit and memory reclaim cost is paid by user threads, a=
nd have
>> > > risks of OOM under memcg.
>> > > B) has no hard limit and memory reclaim cost is paid by kernel threa=
ds, and
>> > > will not have risk of OOM under memcg, but can be CPU burning.
>> > >
>> > > I think this should be called as soft-limit ;) But we have another s=
oft-limit now.
>> > > Then, I call this as watermark. This will be useful to resize usage =
of memory
>> > > in online because application will not hit limit and get big latency=
 even while
>> > > an admin makes watermark smaller.
>> >
>> > I have two thoughts to this:
>> >
>> > 1. Even though the memcg will not hit the limit and the application
>> > will not be forced to do memcg target reclaim, the watermark reclaim
>> > will steal pages from the memcg and the application will suffer the
>> > page faults, so it's not an unconditional win.
>> >
>>
>> Considering the whole system, I never think this watermark can be a perf=
ormance
>> help. This consumes the same amount of cpu as a memory freeing thread us=
es.
>> In realistic situaion, in busy memcy, several threads hits limit at the =
same
>> time and a help by a thread will not be much help.
>>
>> > 2. I understand how the feature is supposed to work, but I don't
>> > understand or see a use case for the watermark being configurable.
>> > Don't get me wrong, I completely agree with watermark reclaim, it's a
>> > good latency optimization. =A0But I don't see why you would want to
>> > manually push back a memcg by changing the watermark.
>> >
>>
>> For keeping free memory, when the system is not busy.
>>
>> > Ying wrote in another email that she wants to do this to make room fro=
,
>> > another job that is about to get launched. =A0My reply to that was tha=
t
>> > you should just launch the job and let global memory pressure push
>> > back that memcg instead. =A0So instead of lowering the watermark, you
>> > could lower the soft limit and don't do any reclaim at all until real
>> > pressure arises. =A0You said yourself that the new feature should be
>> > called soft limit. =A0And I think it is because it is a reimplementati=
on
>> > of the soft limit!
>> >
>>
>> Soft limit works only when the system is in memory shortage. It means th=
e
>> system need to use cpu for memory reclaim when the system is very busy.
>> This works always an admin wants. This difference will affects page allo=
cation
>> latency and execution time of application. In some customer, when he wan=
ts to
>> start up an application in 1 sec, it must be in 1 sec. As you know, kswa=
pd's
>> memory reclaim itself is too slow against rapid big allocation or burst =
of
>> network packet allocation and direct reclaim runs always. Then, it's not
>> avoidable to reclaim/scan memory when the system is busy. =A0This featur=
e allows
>> admins to schedule memory reclaim when the systen is calm. It's like con=
trol of
>> scheduling GC.
>>
>> IIRC, there was a trial to free memory when idle() runs....but it doesn'=
t meet
>> current system requirement as idle() should be idle. What I think is a f=
eature
>> like a that with a help of memcg.
>
> Thanks a lot for the explanation, this certainly makes sense.
>
> How about this: we put in memcg watermark reclaim first, as a pure
> best-effort latency optimization, without the watermark configurable
> from userspace. =A0It's not a new concept, we have it with kswapd on a
> global level.
>
> And on top of that, as a separate changeset, userspace gets a knob to
> kick off async memcg reclaim when the system is idle. =A0With the
> justification you wrote above. =A0We can still discuss the exact
> mechanism, but the async memcg reclaim feature has value in itself and
> should not have to wait until this second step is all figured out.
>
> Would this be acceptable?

Agree on this. Although we have users for the configurable tunable for
the watermarks, in most of the cases the default watermarks
calculated by the kernel should be enough.

--Ying
>
> Thanks again.
>
> =A0 =A0 =A0 =A0Hannes
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
