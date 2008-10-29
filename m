Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id m9T4NDnq122072
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 15:23:14 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9T48M4f216440
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 15:08:25 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9T48M6c023019
	for <linux-mm@kvack.org>; Wed, 29 Oct 2008 15:08:22 +1100
Message-ID: <4907E1B4.6000406@linux.vnet.ibm.com>
Date: Wed, 29 Oct 2008 09:38:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [discuss][memcg] oom-kill extension
References: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081029113826.cc773e21.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Under memory resource controller(memcg), oom-killer can be invoked when it
> reaches limit and no memory can be reclaimed.
> 
> In general, not under memcg, oom-kill(or panic) is an only chance to recover
> the system because there is no available memory. But when oom occurs under
> memcg, it just reaches limit and it seems we can do something else.
> 
> Does anyone have plan to enhance oom-kill ?
> 
> What I can think of now is
>   - add an notifier to user-land.
>     - receiver of notify should work in another cgroup.

The discussion at the mini-summit was to notify a FIFO in the cgroup and any
application can listen in for events.

>     - automatically extend the limit as emergency

No.. I don't like this

>     - trigger fail-over process.

I had suggested memrlimits for the ability to fail application allocations, but
no-one liked the idea. We can still implement overcommit functionality if needed
and catch failures at allocation time.

>     - automatically create a precise report of OOM.
>       - record snapshot of 'ps -elf' and so on of memcg which triggers oom.
> 
>   - freeze processes under cgroup.
>     - maybe freezer cgroup should be mounted at the same time.
>     - can we add memcg-oom-freezing-point in somewhere we can sleep ?
>   
> Is there a chance to add oom_notifier to memcg ? (netlink ?)
> 

Yes, we should add the oom-notifier. We already have cgroupstats if you want to
make use of it.

> But the real problem is that what we can do in the kernel is limited
> and we need proper userland, anyway ;)
> 

Agreed.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
