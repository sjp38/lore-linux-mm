Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 32FF56B0023
	for <linux-mm@kvack.org>; Mon,  9 May 2011 01:47:07 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p495l5XR020083
	for <linux-mm@kvack.org>; Sun, 8 May 2011 22:47:05 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by wpaz5.hot.corp.google.com with ESMTP id p495l3NN019533
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 8 May 2011 22:47:04 -0700
Received: by qyk2 with SMTP id 2so849923qyk.14
        for <linux-mm@kvack.org>; Sun, 08 May 2011 22:47:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110509092112.7d8ae017.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110429133313.GB306@tiehlicka.suse.cz>
	<20110501150410.75D2.A69D9226@jp.fujitsu.com>
	<20110503064945.GA18927@tiehlicka.suse.cz>
	<BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
	<20110503082550.GD18927@tiehlicka.suse.cz>
	<BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
	<20110504085851.GC1375@tiehlicka.suse.cz>
	<BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
	<20110505065901.GC11529@tiehlicka.suse.cz>
	<20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
	<20110506142257.GI10278@cmpxchg.org>
	<20110509092112.7d8ae017.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sun, 8 May 2011 22:47:03 -0700
Message-ID: <BANLkTikmOY=WodDjytantOQ6fwfUAXaQ-Q@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Sun, May 8, 2011 at 5:21 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 6 May 2011 16:22:57 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
>
>> On Fri, May 06, 2011 at 02:28:34PM +0900, KAMEZAWA Hiroyuki wrote:
>> > Hmm, so, the interface should be
>> >
>> > =A0 memory.watermark =A0--- the total usage which kernel's memory shri=
nker starts.
>> >
>> > ?
>> >
>> > I'm okay with this. And I think this parameter should be fully indepen=
dent from
>> > the limit.
>> >
>> > Memcg can work without watermark reclaim. I think my patch just adds a=
 new
>> > _limit_ which a user can shrink usage of memory on deamand with kernel=
's help.
>> > Memory reclaim works in background but this is not a kswapd, at all.
>> >
>> > I guess performance benefit of using watermark under a cgroup which ha=
s limit
>> > is very small and I think this is not for a performance tuning paramet=
er.
>> > This is just a new limit.
>> >
>> > Comparing 2 cases,
>> >
>> > =A0cgroup A)
>> > =A0 =A0- has limit of 300M, no watermaks.
>> > =A0cgroup B)
>> > =A0 =A0- has limit of UNLIMITED, watermarks=3D300M
>> >
>> > A) has hard limit and memory reclaim cost is paid by user threads, and=
 have
>> > risks of OOM under memcg.
>> > B) has no hard limit and memory reclaim cost is paid by kernel threads=
, and
>> > will not have risk of OOM under memcg, but can be CPU burning.
>> >
>> > I think this should be called as soft-limit ;) But we have another sof=
t-limit now.
>> > Then, I call this as watermark. This will be useful to resize usage of=
 memory
>> > in online because application will not hit limit and get big latency e=
ven while
>> > an admin makes watermark smaller.
>>
>> I have two thoughts to this:
>>
>> 1. Even though the memcg will not hit the limit and the application
>> will not be forced to do memcg target reclaim, the watermark reclaim
>> will steal pages from the memcg and the application will suffer the
>> page faults, so it's not an unconditional win.
>>
>
> Considering the whole system, I never think this watermark can be a perfo=
rmance
> help. This consumes the same amount of cpu as a memory freeing thread use=
s.
> In realistic situaion, in busy memcy, several threads hits limit at the s=
ame
> time and a help by a thread will not be much help.
>
>> 2. I understand how the feature is supposed to work, but I don't
>> understand or see a use case for the watermark being configurable.
>> Don't get me wrong, I completely agree with watermark reclaim, it's a
>> good latency optimization. =A0But I don't see why you would want to
>> manually push back a memcg by changing the watermark.
>>
>
> For keeping free memory, when the system is not busy.
>
>> Ying wrote in another email that she wants to do this to make room fro,
>> another job that is about to get launched. =A0My reply to that was that
>> you should just launch the job and let global memory pressure push
>> back that memcg instead. =A0So instead of lowering the watermark, you
>> could lower the soft limit and don't do any reclaim at all until real
>> pressure arises. =A0You said yourself that the new feature should be
>> called soft limit. =A0And I think it is because it is a reimplementation
>> of the soft limit!
>>
>
> Soft limit works only when the system is in memory shortage. It means the
> system need to use cpu for memory reclaim when the system is very busy.
> This works always an admin wants. This difference will affects page alloc=
ation
> latency and execution time of application. In some customer, when he want=
s to
> start up an application in 1 sec, it must be in 1 sec. As you know, kswap=
d's
> memory reclaim itself is too slow against rapid big allocation or burst o=
f
> network packet allocation and direct reclaim runs always. Then, it's not
> avoidable to reclaim/scan memory when the system is busy. =A0This feature=
 allows
> admins to schedule memory reclaim when the systen is calm. It's like cont=
rol of
> scheduling GC.

Agree on this. For the configurable per-memcg wmarks, one of the
difference from adjusting
soft_limit since we would like to trigger the per-memcg bg reclaim
before the whole system
under memory pressure. The concept of soft_limit is quite different
from the wmarks, where
the first one can be used to over-committing the system efficiently
which has nothing to do
with per-memcg background reclaim.

--Ying


--Ying

>
> IIRC, there was a trial to free memory when idle() runs....but it doesn't=
 meet
> current system requirement as idle() should be idle. What I think is a fe=
ature
> like a that with a help of memcg.
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
