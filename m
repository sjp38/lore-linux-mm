Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 18A4A6B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 02:43:48 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB37hj65008841
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 3 Dec 2009 16:43:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B0E0D45DE54
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 16:43:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7901145DE51
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 16:43:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 503611DB8042
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 16:43:44 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F09C91DB803C
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 16:43:43 +0900 (JST)
Date: Thu, 3 Dec 2009 16:40:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 4/5] memcg: avoid oom during recharge at task
 move
Message-Id: <20091203164050.cc9678b1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091203150033.18dd293f.nishimura@mxp.nes.nec.co.jp>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
	<20091119133030.8ef46be0.nishimura@mxp.nes.nec.co.jp>
	<20091123051041.GQ31961@balbir.in.ibm.com>
	<20091124114358.80e0cafe.nishimura@mxp.nes.nec.co.jp>
	<20091127135810.ef5fee0b.nishimura@mxp.nes.nec.co.jp>
	<20091203135805.23a8b0f7.nishimura@mxp.nes.nec.co.jp>
	<20091203142243.5222d7bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20091203150033.18dd293f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Dec 2009 15:00:33 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 3 Dec 2009 14:22:43 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 3 Dec 2009 13:58:05 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > I'm now trying to decrease these overhead as much as possible, and the current
> > > status is bellow.
> > > 
> > thanks.
> > 
> > > (support for moving swap charge has not been pushed yet in my tree, so I tested
> > > only (1) and (2) cases.)
> > > 
> > >        |  252M  |  512M  |   1G
> > >   -----+--------+--------+--------
> > >    (1) |  0.20  |  0.40  |  0.81
> > >   -----+--------+--------+--------
> > >    (2) |  0.20  |  0.40  |  0.81
> > > 
> > What is the unit of each numbers ? seconds ? And migration of a process with 1G bytes
> > requires 0.8sec ? But, hmm, speed up twice! sounds nice.
> > 
> Ah, these numbers mean "seconds".
> I agree they are big yet...
> 
But maybe reducing this will requires big efforts (or impossible).
So, this number is not very bad I think.


> > 
> > > What I've done are are:
> > > - Instead of calling res_counter_uncharge() against the old cgroup in __mem_cgroup_move_account()
> > >   evrytime, call res_counter_uncharge(PAGE_SIZE * moved) at the end of task migration once.
> > sounds reasonable.
> > 
> > > - Instead of calling try_charge repeatedly, call res_counter_charge(PAGE_SIZE * necessary)
> > >   in can_attach() if possible.
> > sounds reasonable, too.
> > 
> > > - Not only res_counter_charge/uncharge, consolidate css_get()/put() too.
> > > 
> > please do. But, hmm, I'd like to remove css_put/get per pages ;) But I put it aside now.
> > 
> I do agree with you, but removing them would be a big change..
> This change reduced about 0.2sec in 1GB case, so it's a workaround for now.
> 
please go ahead with coalesced css_put()/get().
I agree that workaround is necessary now.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
