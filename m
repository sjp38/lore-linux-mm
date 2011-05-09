Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5823C6B0012
	for <linux-mm@kvack.org>; Sun,  8 May 2011 20:28:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 255103EE0C5
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:27:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF92545DF4D
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:27:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C77F145DF4A
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:27:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B6DCAE08007
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:27:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 770971DB8038
	for <linux-mm@kvack.org>; Mon,  9 May 2011 09:27:56 +0900 (JST)
Date: Mon, 9 May 2011 09:21:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
Message-Id: <20110509092112.7d8ae017.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110506142257.GI10278@cmpxchg.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Fri, 6 May 2011 16:22:57 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, May 06, 2011 at 02:28:34PM +0900, KAMEZAWA Hiroyuki wrote:
> > Hmm, so, the interface should be
> > 
> >   memory.watermark  --- the total usage which kernel's memory shrinker starts.
> > 
> > ?
> > 
> > I'm okay with this. And I think this parameter should be fully independent from
> > the limit.
> > 
> > Memcg can work without watermark reclaim. I think my patch just adds a new
> > _limit_ which a user can shrink usage of memory on deamand with kernel's help.
> > Memory reclaim works in background but this is not a kswapd, at all.
> > 
> > I guess performance benefit of using watermark under a cgroup which has limit
> > is very small and I think this is not for a performance tuning parameter. 
> > This is just a new limit.
> > 
> > Comparing 2 cases,
> > 
> >  cgroup A)
> >    - has limit of 300M, no watermaks.
> >  cgroup B)
> >    - has limit of UNLIMITED, watermarks=300M
> > 
> > A) has hard limit and memory reclaim cost is paid by user threads, and have
> > risks of OOM under memcg.
> > B) has no hard limit and memory reclaim cost is paid by kernel threads, and
> > will not have risk of OOM under memcg, but can be CPU burning.
> > 
> > I think this should be called as soft-limit ;) But we have another soft-limit now.
> > Then, I call this as watermark. This will be useful to resize usage of memory
> > in online because application will not hit limit and get big latency even while
> > an admin makes watermark smaller.
> 
> I have two thoughts to this:
> 
> 1. Even though the memcg will not hit the limit and the application
> will not be forced to do memcg target reclaim, the watermark reclaim
> will steal pages from the memcg and the application will suffer the
> page faults, so it's not an unconditional win.
> 

Considering the whole system, I never think this watermark can be a performance
help. This consumes the same amount of cpu as a memory freeing thread uses.
In realistic situaion, in busy memcy, several threads hits limit at the same
time and a help by a thread will not be much help.

> 2. I understand how the feature is supposed to work, but I don't
> understand or see a use case for the watermark being configurable.
> Don't get me wrong, I completely agree with watermark reclaim, it's a
> good latency optimization.  But I don't see why you would want to
> manually push back a memcg by changing the watermark.
> 

For keeping free memory, when the system is not busy.

> Ying wrote in another email that she wants to do this to make room fro,
> another job that is about to get launched.  My reply to that was that
> you should just launch the job and let global memory pressure push
> back that memcg instead.  So instead of lowering the watermark, you
> could lower the soft limit and don't do any reclaim at all until real
> pressure arises.  You said yourself that the new feature should be
> called soft limit.  And I think it is because it is a reimplementation
> of the soft limit!
> 

Soft limit works only when the system is in memory shortage. It means the
system need to use cpu for memory reclaim when the system is very busy.
This works always an admin wants. This difference will affects page allocation
latency and execution time of application. In some customer, when he wants to
start up an application in 1 sec, it must be in 1 sec. As you know, kswapd's
memory reclaim itself is too slow against rapid big allocation or burst of
network packet allocation and direct reclaim runs always. Then, it's not
avoidable to reclaim/scan memory when the system is busy.  This feature allows
admins to schedule memory reclaim when the systen is calm. It's like control of
scheduling GC.

IIRC, there was a trial to free memory when idle() runs....but it doesn't meet
current system requirement as idle() should be idle. What I think is a feature
like a that with a help of memcg. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
