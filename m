Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B86F46B0069
	for <linux-mm@kvack.org>; Fri, 28 Nov 2014 11:17:22 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id h11so19001489wiw.13
        for <linux-mm@kvack.org>; Fri, 28 Nov 2014 08:17:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fl5si18908460wib.10.2014.11.28.08.17.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Nov 2014 08:17:21 -0800 (PST)
Date: Fri, 28 Nov 2014 17:17:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
Message-ID: <20141128161718.GE25054@dhcp22.suse.cz>
References: <20141125103820.GA4607@dhcp22.suse.cz>
 <201411252154.GEF09368.QOLFSFJOFtOMVH@I-love.SAKURA.ne.jp>
 <20141125134558.GA4415@dhcp22.suse.cz>
 <201411262058.GAJ81735.OHFMOLQOSFtVJF@I-love.SAKURA.ne.jp>
 <20141126184316.GA31930@dhcp22.suse.cz>
 <201411272349.JJF21899.OHOFtSQJOFMVFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411272349.JJF21899.OHOFtSQJOFMVFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, linux-mm@kvack.org

On Thu 27-11-14 23:49:38, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 26-11-14 20:58:52, Tetsuo Handa wrote:
> > > Here is an example trace of 3.10.0-121.el7-test. Two of OOM-killed processes
> > > are inside task_work_run() from do_exit() and got stuck at memory allocation.
> > > Processes past exit_mm() in do_exit() contribute OOM deadlock.
> > 
> > If the OOM victim passed exit_mm then it is usually not interesting for
> > the OOM killer as it has already unmapped and freed its memory (assuming
> > that mm_users is not elevated). It also doesn't have TIF_MEMDIE anymore
> > so it doesn't block OOM killer from killing other tasks.
> 
> Then, why did the stall last for many minutes without making any progress?
> I think that some lock held by a process past exit_mm() can prevent another
> process chosen by the OOM killer from holding the lock (and therefore make
> it impossible for another process to terminate).

Now that I am looking closer it seems probable that the victim got
TIF_MEMDIE set again because it is still PF_EXITING so that it can dive
into memory reserves and continue. Which didn't help in your particular
case most probably because the memory seems depleted beyond any hope.

Both of your tasks are blocked on a lock but it is not 100% clear
whether this is just the case at the time of the sysrq or permanent but
I would expect soft lockup watchdog complaining as at least one of them
is spin_lock. Anyway this looks like a live lock due to depleted memory
because even memory reserves didn't help to make any progress.

> > Without OOM report these traces are not useful very much. They are both
> > somewhere in exit_files and deferred fput. I am not sure how much memory
> > the process might hold at that time. I would be quite surprised if this
> > was the majority of the OOM victim's memory.
> 
> I don't mean to attach any OOM reports here because attaching the OOM report
> is equivalent with posting the reproducer program to LKML because the trace
> of a.out will tell how to trigger the OOM deadlock/livelock.

The trace is not really that interesting. The memory counters and the
list of eligible tasks is...

> You already have the source code of a.out and you are free to compile
> it and run a.out in your environment.
> 
> > > > The OOM report was not complete so it is hard to say why the OOM
> > > > condition wasn't resolved by the OOM killer but other OOM report you
> > > > have posted (26 Apr) in that thread suggested that the system doesn't
> > > > have any swap and the page cache is full of shmem. The process list
> > > > didn't contain any large memory consumer so killing somebody wouldn't
> > > > help much. But the OOM victim died normally in that case:
> > > 
> > > The problem is that a.out invoked by a local unprivileged user is the only
> > > and the biggest memory consumer which the OOM killer thinks the least memory
> > > consumer.
> > 
> > Yes, because a.out doesn't consume to much of per-process accounted
> > memory. It's rss, ptes and swapped out memory is negligible to
> > the memory allocated on behalf of processes for in-kernel data
> > structures. This is quite unfortunate but this is basically "an
> > untrusted user on your computer has to be contained" scenario.
> 
> Why do you think about only containing untrusted user?

Because non-malicious users usually do not shoot themselves into foot.
This includes both the configuration of the system and running a load
which doesn't eat up unaccounted kernel memory to death.

> I'm using a.out as a memory stressing tester for finding bugs under
> extreme memory pressure.

And I agree that having an unbounded kernel memory usage on behalf of
an user is a bug which should be fixed properly. I will have a look at
your reproducer again and try to think about a potential fix.

> This is quite unfortunate but this is basically "any unreasonably lasting
> stalls under extreme memory pressure have to be fixed" scenario.
> 
> >                                                                Ulimits
> > should help to a certain degree and kmem accounting from memory cgroup
> > controller should help for dentries, inodes and fork bombs but there
> > might be other resources that might be unrestricted. If this is the case
> > then the OOM killer should be taught to consider them or added a
> > restriction for them. Later is preferable IMO.
> 
> Ulimits does not help at all because a.out consumes kernel memory where only
> kmem accounting can account.

Normally ulimit would cap the user visible end of the resource.

> But the kmem accounting helps little for me because what I want is
> kmem accounting based on UID rather than memory cgroup.
>
> I agree that teaching the OOM killer to consider them is preferable.
> This vulnerability resembles "CVE-2010-4243 kernel: mm: mem allocated invisible
> to oom_kill() when not attached to any threads", but much harder to fix and
> backport. No patches are ever proposed due to performance hit and complexity.
> 
> >                                                But adding a timeout to
> > OOM killer and hope that the next attempt will be more successful is
> > definitely not the right approach.
> 
> I saw a case where an innocent administrator unexpectedly hit
> "CVE-2012-4398 kernel: request_module() OOM local DoS" and his system
> stalled for many hours until he manually issued SysRq-c.
> I fixed request_module() and kthread_create(), but there are dozens of
> memory allocation with locks held which may cause unexpected OOM stalls.
> If below one is available, I will no longer see similar cases even if
> the cause of OOM stall is out-of-tree kernel modules.
> 
>  	/* p may not be terminated within reasonale duration */
> -	if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +	if (sysctl_memdie_timeout_jiffies &&
> +	    test_tsk_thread_flag(p, TIF_MEMDIE)) {
>  		smp_rmb(); /* set_memdie_flag() uses smp_wmb(). */
> -		if (time_after(jiffies, p->memdie_start + 5 * HZ)) {
> -			static unsigned char warn = 255;
> -			char comm[sizeof(p->comm)];
> -
> -			if (warn && warn--)
> -				pr_err("Process %d (%s) was not killed within 5 seconds.\n",
> -				       task_pid_nr(p), get_task_comm(comm, p));
> -			return true;
> -		}
> +		if (time_after(jiffies, p->memdie_start + sysctl_memdie_timeout_jiffies))
> +			panic("Process %d (%s) did not die within %lu jiffies.\n",
> +			      task_pid_nr(p), get_task_comm(comm, p),
> +			      sysctl_memdie_timeout_jiffies);
>  	}
>
> If timeout for next OOM-kill is not acceptable, what about timeout for
> kernel panic (followed by kdump and automatic reboot) like above one?

This is basically same thing and already too late to do anything. Your
machine is DoSed already and the reboot is only marginally better
approach. What would be a safe timeout which wouldn't panic a system
which is struggling but it would eventually make a progress?
Why the admin cannot sysrq+c manually?

I am not saying that this is absolutely no-go but I would _really_ like
to have a fix rather than a workaround.

> If still NACK, what alternatives can you propose for distributions using
> 2.6.18 / 2.6.32 / 3.2 kernels which do not have the kmem accounting?

Feel free to use your specific and out of tree workarounds if you
believe they will suit better your users.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
