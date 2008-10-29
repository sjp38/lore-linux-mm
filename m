Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9T50fOM032651
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 29 Oct 2008 14:00:41 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6006445DE3E
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:00:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32EA845DE38
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:00:41 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1614D1DB8043
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:00:41 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF8631DB8040
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 14:00:40 +0900 (JST)
Date: Wed, 29 Oct 2008 14:00:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [discuss][memcg] oom-kill extension
Message-Id: <20081029140012.fff30bce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4907E1B4.6000406@linux.vnet.ibm.com>
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
	<4907E1B4.6000406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Oct 2008 09:38:20 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Under memory resource controller(memcg), oom-killer can be invoked when it
> > reaches limit and no memory can be reclaimed.
> > 
> > In general, not under memcg, oom-kill(or panic) is an only chance to recover
> > the system because there is no available memory. But when oom occurs under
> > memcg, it just reaches limit and it seems we can do something else.
> > 
> > Does anyone have plan to enhance oom-kill ?
> > 
> > What I can think of now is
> >   - add an notifier to user-land.
> >     - receiver of notify should work in another cgroup.
> 
> The discussion at the mini-summit was to notify a FIFO in the cgroup and any
> application can listen in for events.
> 
add FIFO rather than netlink or user mode helper ?

> >     - automatically extend the limit as emergency
> 
> No.. I don't like this
> 
Oh, I should write as
 "automatically extend the limit as emergency via userland daemon
  which receives notify"

> >     - trigger fail-over process.
> 
> I had suggested memrlimits for the ability to fail application allocations, but
> no-one liked the idea. We can still implement overcommit functionality if needed
> and catch failures at allocation time.
> 
Difficult point of memrlimit is that system engineer cannot guarantee 
"your application will do proper fail over process when malloc() returns NULL".

Important applications have emergency-fail-over method via signal(SIGTERM or some..
(if not killed by SIGKILL.)

I wonder adding an "moderate oom kill mode" to memcg and send SIGTERM rather
than SIGKILL may help many? applications.
(But to do fail over, the apps may use more memory....)

> >     - automatically create a precise report of OOM.
> >       - record snapshot of 'ps -elf' and so on of memcg which triggers oom.
> > 
> >   - freeze processes under cgroup.
> >     - maybe freezer cgroup should be mounted at the same time.
> >     - can we add memcg-oom-freezing-point in somewhere we can sleep ?
> >   
> > Is there a chance to add oom_notifier to memcg ? (netlink ?)
> > 
> 
> Yes, we should add the oom-notifier. We already have cgroupstats if you want to
> make use of it.
> 
ok, look into that.

> > But the real problem is that what we can do in the kernel is limited
> > and we need proper userland, anyway ;)
> > 
> 
> Agreed.
> 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
