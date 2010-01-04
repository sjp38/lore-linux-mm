Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D0E13600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 19:50:41 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id o040oZoU021838
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 06:20:35 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o040oZle2850952
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 06:20:35 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o040oZVh017605
	for <linux-mm@kvack.org>; Mon, 4 Jan 2010 11:50:35 +1100
Date: Mon, 4 Jan 2010 06:20:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-ID: <20100104005030.GG16187@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091229182743.GB12533@balbir.in.ibm.com>
 <20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
 <20100104000752.GC16187@balbir.in.ibm.com>
 <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-04 09:35:28]:

> On Mon, 4 Jan 2010 05:37:52 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-04 08:51:08]:
> > 
> > > On Tue, 29 Dec 2009 23:57:43 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > Hi, Everyone,
> > > > 
> > > > I've been working on heuristics for shared page accounting for the
> > > > memory cgroup. I've tested the patches by creating multiple cgroups
> > > > and running programs that share memory and observed the output.
> > > > 
> > > > Comments?
> > > 
> > > Hmm? Why we have to do this in the kernel ?
> > >
> > 
> > For several reasons that I can think of
> > 
> > 1. With task migration changes coming in, getting consistent data free of races
> > is going to be hard.
> 
> Hmm, Let's see real-worlds's "ps" or "top" command. Even when there are no guarantee
> of error range of data, it's still useful.

Yes, my concern is this

1. I iterate through tasks and calculate RSS
2. I look at memory.usage_in_bytes

If the time in user space between 1 and 2 is large I get very wrong
results, specifically if the workload is changing its memory usage
drastically.. no?

> 
> > 2. The cost of doing it in the kernel is not high, it does not impact
> > the memcg runtime, it is a request-response sort of cost.
> >
> > 3. The cost in user space is going to be high and the implementation
> > cumbersome to get right.
> >  
> I don't like moving a cost in the userland to the kernel.

Me neither, but I don't think it is a fixed overhead.

 Considering 
> real-time kernel or full-preemptive kernel, this very long read_lock() in the
> kernel is not good, IMHO. (I think css_set_lock should be mutex/rw-sem...)

I agree, we should discuss converting the lock to a mutex or a
semaphore, but there might be a good reason for keeping it as a
spin_lock.

> cgroup_iter_xxx can block cgroup_post_fork() and this may cause critical
> system delay of milli-seconds.
> 

Agreed, but then that can happen, even while attaching a task, seeing
cgroup tasks file (list of tasks).

> BTW, if you really want to calculate somthing in atomic, I think following
> interface may be welcomed for freezing.
> 
>   cgroup.lock
>   # echo 1 > /...../cgroup.lock 
>     All task move, mkdir, rmdir to this cgroup will be blocked by mutex.
>     (But fork/exit will not be blocked.)
> 
>   # echo 0 > /...../cgroup.lock
>     Unlock.
> 
>   # cat /...../cgroup.lock
>     show lock status and lock history (for debug).
> 
> Maybe good for some kinds of middleware.
> But this may be difficult if we have to consider hierarchy.
>

I don't like the idea of providing an interface that can control
kernel locks from user space, user space can tangle up and get it
wrong. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
