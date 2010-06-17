Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE296B01D0
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 23:33:39 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o5H3XXMj031030
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:33:34 -0700
Received: from pxi18 (pxi18.prod.google.com [10.243.27.18])
	by hpaq2.eem.corp.google.com with ESMTP id o5H3XVgh029132
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:33:32 -0700
Received: by pxi18 with SMTP id 18so1070844pxi.26
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 20:33:31 -0700 (PDT)
Date: Wed, 16 Jun 2010 20:33:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same
 cpuset
In-Reply-To: <20100613180405.6178.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006162028410.21446@chino.kir.corp.google.com>
References: <20100606170713.8718.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006081135510.18848@chino.kir.corp.google.com> <20100613180405.6178.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jun 2010, KOSAKI Motohiro wrote:

> I have no objection because it's policy matter. but if so, dump_tasks()
> should display mem_allowed mask too, probably.

You could, but we'd want to do that all under cpuset_buffer_lock so we 
don't have to allocate it on the stack, which can be particularly lengthy 
when the page allocator is called.

> > >   (3) oom_kill_task (when oom_kill_allocating_task==1 only)
> > > 
> > 
> > Why would care about cpuset attachment in oom_kill_task()?  You mean 
> > oom_kill_process() to filter the children list?
> 
> Ah, intersting question. OK, we have to discuss oom_kill_allocating_task
> design at first.
> 
> First of All, oom_kill_process() to filter the children list and this issue
> are independent and unrelated. My patch was not correct too.
> 
> Now, oom_kill_allocating_task basic logic is here. It mean, if oom_kill_process()
> return 0, oom kill finished successfully. but if oom_kill_process() return 1,
> fallback to normall __out_of_memory().
> 

Right.

> 
> 	===================================================
> 	static void __out_of_memory(gfp_t gfp_mask, int order, nodemask_t *nodemask)
> 	{
> 	        struct task_struct *p;
> 	        unsigned long points;
> 	
> 	        if (sysctl_oom_kill_allocating_task)
> 	                if (!oom_kill_process(current, gfp_mask, order, 0, NULL, nodemask,
> 	                                      "Out of memory (oom_kill_allocating_task)"))
> 	                        return;
> 	retry:
> 
> When oom_kill_process() return 1?
> I think It should be
> 	- current is OOM_DISABLE

In this case, oom_kill_task() returns 1, which causes oom_kill_process() 
to return 1 if current (and not one of its children) is actually selected 
to die.

> 	- current have no intersected CPUSET

current will always intersect its own cpuset's mems.

> 	- current is KTHREAD

find_lock_task_mm() should take care of that in oom_kill_task() just like 
it does for OOM_DISABLE, although we can still race with use_mm(), in 
which case this would be a good chance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
