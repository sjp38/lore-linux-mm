Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D702E6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 00:12:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BCB2D3EE0C0
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:12:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A4C1245DE92
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:12:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 855E745DE77
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:12:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 793D91DB803C
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:12:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 324771DB8037
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 13:12:11 +0900 (JST)
Date: Thu, 28 Apr 2011 13:05:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-Id: <20110428130529.41d264d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTin=VW4kbBbeiipEx0pqByWpSjbi=Q@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
	<20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=sSrrQCMXKJor95Cn-JmiQ=XUAkA@mail.gmail.com>
	<20110426174754.07a58f22.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin=VW4kbBbeiipEx0pqByWpSjbi=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Wed, 27 Apr 2011 20:55:49 -0700
Ying Han <yinghan@google.com> wrote:

> On Tue, Apr 26, 2011 at 1:47 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 26 Apr 2011 01:43:17 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Tue, Apr 26, 2011 at 12:43 AM, KAMEZAWA Hiroyuki <
> >> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>
> >> > On Tue, 26 Apr 2011 00:19:46 -0700
> >> > Ying Han <yinghan@google.com> wrote:
> >> >
> >> > > On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki
> >> > > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > > > On Mon, 25 Apr 2011 15:21:21 -0700
> >> > > > Ying Han <yinghan@google.com> wrote:
> >
> >>
> >> > To clarify a bit, my question was meant to account it but not necessary to
> >> > limit it. We can use existing cpu cgroup to do the cpu limiting, and I am
> >> >
> >> just wondering how to configure it for the memcg kswapd thread.
> >>
> >> A  A Let's say in the per-memcg-kswapd model, i can echo the kswapd thread pid
> >> into the cpu cgroup ( the same set of process of memcg, but in a cpu
> >> limiting cgroup instead). A If the kswapd is shared, we might need extra work
> >> to account the cpu cycles correspondingly.
> >>
> >
> > Hm ? statistics of elapsed_time isn't enough ?
> >
> > Now, I think limiting scan/sec interface is more promissing rather than time
> > or thread controls. It's easier to understand.
> 
> I think it will work on the cpu accounting by recording the
> elapsed_time per memcg workitem.
> 
> But, we might still need the cpu throttling as well. To give one use
> cases from google, we'd rather kill a low priority job for running
> tight on memory rather than having its reclaim thread affecting the
> latency of high priority job. It is quite easy to understand how to
> accomplish that in per-memcg-per-kswapd model, but harder in the
> shared workqueue model. It is straight-forward to read  the cpu usage
> by the cpuacct.usage* and limit the cpu usage by setting cpu.shares.
> One concern we have here is the scan/sec implementation will make
> things quite complex.
> 

I think you should check how distance between limit<->hiwater works
before jumping onto cpu scheduler. If you can see a memcg's bgreclaim is
cpu hogging, you can stop it easily by setting limit==hiwat. per-memcg
statistics seems enough for me. I don't like splitting up features
between cgroups, more. "To reduce cpu usage by memcg, please check
cpu cgroup and...." how complex it is! Do you remember what Hugh Dickins
pointed out at LSF ? It's a big concern.

Setting up of combination of cgroup subsys is too complex.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
