Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 653F36B00A1
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 02:14:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3M6F9qg019994
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 22 Apr 2009 15:15:09 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C0E945DE51
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:15:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2090345DD79
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:15:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F340FE18006
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:15:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4B601DB803E
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:15:08 +0900 (JST)
Date: Wed, 22 Apr 2009 15:13:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove trylock_page_cgroup
Message-Id: <20090422151337.27eecb11.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090421230147.eecfe82c.akpm@linux-foundation.org>
References: <20090416120316.GG7082@balbir.in.ibm.com>
	<20090417091459.dac2cc39.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417014042.GB18558@balbir.in.ibm.com>
	<20090417110350.3144183d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417034539.GD18558@balbir.in.ibm.com>
	<20090417124951.a8472c86.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417045623.GA3896@balbir.in.ibm.com>
	<20090417141726.a69ebdcc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417064726.GB3896@balbir.in.ibm.com>
	<20090417155608.eeed1f02.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417141837.GD3896@balbir.in.ibm.com>
	<20090421132551.38e9960a.akpm@linux-foundation.org>
	<20090422090218.6d451a08.kamezawa.hiroyu@jp.fujitsu.com>
	<20090422121641.eb84a07e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090421204104.faf9fc56.akpm@linux-foundation.org>
	<20090422134108.f21e5bba.kamezawa.hiroyu@jp.fujitsu.com>
	<20090421230147.eecfe82c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009 23:01:47 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 22 Apr 2009 13:41:08 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > I expect that it will reliably fail if the caller is running as
> > > SCHED_FIFO and the machine is single-CPU, or if we're trying to yield
> > > to a SCHED_OTHER task which is pinned to this CPU, etc.  The cond_resched()
> > > won't work.
> > > 
> > Hm, signal_pending() is supported now (so special user scan use alaram())
> > I used yield() before cond_resched() but I was told don't use it.
> > Should I replace cond_resched() with congestion_wait(HZ/10) or some ?
> 
> msleep(1) would be typical.  That can also be used to give a
> predictable number of seconds for the timeout.
> 
> If 1 millisecond is too coarse then it's possible to sleep for much
> shorter intervals if the platform implements hi-res timers.  We don't
> appear to have a handy interface to that (usleep, microsleep,
> nanosleep, etc?).
> 
> And an attempt to sleep for 1us will fall back to 1/HZ if the platform
> doesn't implement hi-res timers, so that loop will need to be turned
> into a do {} while(!timer_after(jiffies, start))) thing.  Probably it
> should be converted to that anyway, to be better behaved/predictable,
> etc.
> 
I'm now consdiering to make this loop _short_ and call lru_add_drain_all()
when the loop finds a page is busy. (lru_add_drain_all() will sleep until
the end of keventd.) And yes, checking jiffies and do sleep if it seems
necessary.


I'll write some RFC today.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
