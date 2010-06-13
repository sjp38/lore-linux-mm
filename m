Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 851B96B01B8
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:58 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOsWp007416
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:54 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 722A545DE51
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 36EF745DD77
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1932B1DB803B
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF8FF1DB803A
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1006081135510.18848@chino.kir.corp.google.com>
References: <20100606170713.8718.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006081135510.18848@chino.kir.corp.google.com>
Message-Id: <20100613180405.6178.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:
> 
> > > @@ -267,6 +259,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
> > >  			continue;
> > >  		if (mem && !task_in_mem_cgroup(p, mem))
> > >  			continue;
> > > +		if (!has_intersects_mems_allowed(p))
> > > +			continue;
> > >  
> > >  		/*
> > >  		 * This task already has access to memory reserves and is
> > 
> > now we have three places of oom filtering
> >   (1) select_bad_process
> 
> Done.
> 
> >   (2) dump_tasks
> 
> dump_tasks() has never filtered on this, it's possible for tasks is other 
> cpusets to allocate memory on our nodes.

I have no objection because it's policy matter. but if so, dump_tasks()
should display mem_allowed mask too, probably.
otherwise, end-user can't understand why badness but not mem intersected task
didn't killed.


> >   (3) oom_kill_task (when oom_kill_allocating_task==1 only)
> > 
> 
> Why would care about cpuset attachment in oom_kill_task()?  You mean 
> oom_kill_process() to filter the children list?

Ah, intersting question. OK, we have to discuss oom_kill_allocating_task
design at first.

First of All, oom_kill_process() to filter the children list and this issue
are independent and unrelated. My patch was not correct too.

Now, oom_kill_allocating_task basic logic is here. It mean, if oom_kill_process()
return 0, oom kill finished successfully. but if oom_kill_process() return 1,
fallback to normall __out_of_memory().


	===================================================
	static void __out_of_memory(gfp_t gfp_mask, int order, nodemask_t *nodemask)
	{
	        struct task_struct *p;
	        unsigned long points;
	
	        if (sysctl_oom_kill_allocating_task)
	                if (!oom_kill_process(current, gfp_mask, order, 0, NULL, nodemask,
	                                      "Out of memory (oom_kill_allocating_task)"))
	                        return;
	retry:

When oom_kill_process() return 1?
I think It should be
	- current is OOM_DISABLE
	- current have no intersected CPUSET
	- current is KTHREAD
	- etc etc..

It mean, consist rule of !oom_kill_allocating_task case.

So, my previous patch didn't care to conflict "oom: sacrifice child with 
highest badness score for parent" patch. Probably right way is

static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
                            unsigned long points, struct mem_cgroup *mem,
                            nodemask_t *nodemask, const char *message)
{
        struct task_struct *c;
        struct task_struct *t = p;
        struct task_struct *victim = p;
        unsigned long victim_points = 0;
        struct timespec uptime;

+	/* This process is not oom killable, we need to retry to select
+	   bad process */
+	if (oom_unkillable(c, mem, nodemask))
+		return 1;

        if (printk_ratelimit())
                dump_header(p, gfp_mask, order, mem, nodemask);

        pr_err("%s: Kill process %d (%s) with score %lu or sacrifice child\n",
               message, task_pid_nr(p), p->comm, points);


or something else.

What do you think?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
