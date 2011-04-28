Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 43FE96B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 23:55:57 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3S3ttbg004674
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:55:55 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz21.hot.corp.google.com with ESMTP id p3S3sQoG014192
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:55:54 -0700
Received: by qyk7 with SMTP id 7so2509244qyk.5
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:55:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
	<20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
	<20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 20:55:49 -0700
Message-ID: <BANLkTin=VW4kbBbeiipEx0pqByWpSjbi=Q@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue, Apr 26, 2011 at 1:47 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 26 Apr 2011 01:43:17 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Tue, Apr 26, 2011 at 12:43 AM, KAMEZAWA Hiroyuki <
>> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> > On Tue, 26 Apr 2011 00:19:46 -0700
>> > Ying Han <yinghan@google.com> wrote:
>> >
>> > > On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki
>> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > > > On Mon, 25 Apr 2011 15:21:21 -0700
>> > > > Ying Han <yinghan@google.com> wrote:
>
>>
>> > To clarify a bit, my question was meant to account it but not necessar=
y to
>> > limit it. We can use existing cpu cgroup to do the cpu limiting, and I=
 am
>> >
>> just wondering how to configure it for the memcg kswapd thread.
>>
>> =A0 =A0Let's say in the per-memcg-kswapd model, i can echo the kswapd th=
read pid
>> into the cpu cgroup ( the same set of process of memcg, but in a cpu
>> limiting cgroup instead). =A0If the kswapd is shared, we might need extr=
a work
>> to account the cpu cycles correspondingly.
>>
>
> Hm ? statistics of elapsed_time isn't enough ?
>
> Now, I think limiting scan/sec interface is more promissing rather than t=
ime
> or thread controls. It's easier to understand.

I think it will work on the cpu accounting by recording the
elapsed_time per memcg workitem.

But, we might still need the cpu throttling as well. To give one use
cases from google, we'd rather kill a low priority job for running
tight on memory rather than having its reclaim thread affecting the
latency of high priority job. It is quite easy to understand how to
accomplish that in per-memcg-per-kswapd model, but harder in the
shared workqueue model. It is straight-forward to read  the cpu usage
by the cpuacct.usage* and limit the cpu usage by setting cpu.shares.
One concern we have here is the scan/sec implementation will make
things quite complex.

--Ying

>
> BTW, I think it's better to avoid the watermark reclaim work as kswapd.
> It's confusing because we've talked about global reclaim at LSF.
>
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
