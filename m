Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0F930828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 20:36:45 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 65so71929358pff.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 17:36:45 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id pz7si11423605pab.216.2016.01.12.17.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 17:36:44 -0800 (PST)
Received: by mail-pa0-x22e.google.com with SMTP id yy13so256323374pab.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 17:36:44 -0800 (PST)
Date: Tue, 12 Jan 2016 17:36:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
In-Reply-To: <201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601121717220.17063@chino.kir.corp.google.com>
References: <201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Thu, 7 Jan 2016, Tetsuo Handa wrote:

> This patch introduces two timers ( holdoff timer and victim wait timer)
> and sysctl variables for changing timeout ( oomkiller_holdoff_ms and
> oomkiller_victim_wait_ms ) for respectively handling collateral OOM
> victim problem and OOM livelock problem. When you are trying to analyze
> problems under OOM condition, you can set holdoff timer's timeout to 0
> and victim wait timer's timeout to very large value for emulating
> current behavior.
> 
> 
> About collateral OOM victim problem:
> 
> We can observe collateral victim being OOM-killed immediately after
> the memory hog process is OOM-killed. This is caused by a race:
> 
>    (1) The process which called oom_kill_process() releases the oom_lock
>        mutex before the memory reclaimed by OOM-killing the memory hog
>        process becomes allocatable for others.
> 
>    (2) Another process acquires the oom_lock mutex and checks for
>        get_page_from_freelist() before the memory reclaimed by OOM-killing
>        the memory hog process becomes allocatable for others.
>        get_page_from_freelist() fails and thus the process proceeds
>        calling out_of_memory().
> 
>    (3) The memory hog process exits and clears TIF_MEMDIE flag.
> 
>    (4) select_bad_process() in out_of_memory() fails to find a task with
>        TIF_MEMDIE pending. Thus the process proceeds choosing next OOM
>        victim.
> 
>    (5) The memory reclaimed by OOM-killing the memory hog process becomes
>        allocatable for others. But get_page_from_freelist() is no longer
>        called by somebody which held the oom_lock mutex.
> 
>    (6) oom_kill_process() is called although get_page_from_freelist()
>        could now succeed. If get_page_from_freelist() can succeed, this
>        is a collateral victim.
> 
> We cannot completely avoid this race because we cannot predict when the
> memory reclaimed by OOM-killing the memory hog process becomes allocatable
> for others. But we can reduce possibility of hitting this race by keeping
> the OOM killer disabled for some administrator controlled period, instead
> of relying on a sleep with oom_lock mutex held.
> 
> This patch adds /proc/sys/vm/oomkiller_holdoff_ms for that purpose.
> Since the OOM reaper retries for 10 times with 0.1 second interval,
> this timeout can be relatively short (e.g. between 0.1 second and few
> seconds). Longer the period is, more unlikely to hit this race but more
> likely to stall longer when the OOM reaper failed to reclaim memory.
> 
> 
> About OOM livelock problem:
> 
> We are trying to reduce the possibility of hitting OOM livelock by
> introducing the OOM reaper, but we can still observe OOM livelock
> when the OOM reaper failed to reclaim enough memory.
> 
> When the OOM reaper failed, we need to take some action for making forward
> progress. Possible candidates are: choose next OOM victim, allow access to
> memory reserves, trigger kernel panic.
> 
> Allowing access to memory reserves might help, but on rare occasions
> we are already observing depletion of the memory reserves with current
> behavior. Thus, this is not a reliable candidate.
> 
> Triggering kernel panic upon timeout might help, but can be overkilling
> for those who use with /proc/sys/vm/panic_on_oom = 0. At least some of
> them prefer choosing next OOM victim because it is very likely that the
> OOM reaper can eventually reclaim memory if we continue choosing
> subsequent OOM victims.
> 
> Therefore, this patch adds /proc/sys/vm/oomkiller_victim_wait_ms for
> ignoring current behavior in order to choose subsequent OOM victims.
> Since wait victim timer should expire after the OOM reaper fails,
> this timeout should be longer than holdoff timer's timeout (e.g.
> between few seconds and a minute).
> 
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>   include/linux/oom.h |  2 ++
>   kernel/sysctl.c     | 14 ++++++++++++++
>   mm/oom_kill.c       | 31 ++++++++++++++++++++++++++++++-
>   3 files changed, 46 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 03e6257..633e92a 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -117,4 +117,6 @@ static inline bool task_will_free_mem(struct task_struct *task)
>   extern int sysctl_oom_dump_tasks;
>   extern int sysctl_oom_kill_allocating_task;
>   extern int sysctl_panic_on_oom;
> +extern unsigned int sysctl_oomkiller_holdoff_ms;
> +extern unsigned int sysctl_oomkiller_victim_wait_ms;
>   #endif /* _INCLUDE_LINUX_OOM_H */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 9142036..7102212 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1209,6 +1209,20 @@ static struct ctl_table vm_table[] = {
>   		.proc_handler	= proc_dointvec,
>   	},
>   	{
> +		.procname       = "oomkiller_holdoff_ms",
> +		.data           = &sysctl_oomkiller_holdoff_ms,
> +		.maxlen         = sizeof(sysctl_oomkiller_holdoff_ms),
> +		.mode           = 0644,
> +		.proc_handler   = proc_dointvec_minmax,
> +	},
> +	{
> +		.procname       = "oomkiller_victim_wait_ms",
> +		.data           = &sysctl_oomkiller_victim_wait_ms,
> +		.maxlen         = sizeof(sysctl_oomkiller_victim_wait_ms),
> +		.mode           = 0644,
> +		.proc_handler   = proc_dointvec_minmax,
> +	},
> +	{
>   		.procname	= "overcommit_ratio",
>   		.data		= &sysctl_overcommit_ratio,
>   		.maxlen		= sizeof(sysctl_overcommit_ratio),

I'm not sure why you are proposing adding both of these in the same patch; 
they have very different usecases and semantics.

oomkiller_holdoff_ms, as indicated by the changelog, seems to be 
correcting some deficiency in the oom reaper.  I haven't reviewed that, 
but it seems like something that wouldn't need to be fixed with a 
timeout-based solution.  We either know if we have completed oom reaping 
or we haven't, it is something we should easily be able to figure out and 
not require heuristics such as this.

This does not seem to have anything to do with current upstream code that 
does not have the oom reaper since the oom killer clearly has 
synchronization through oom_lock and we carefully defer for TIF_MEMDIE 
processes and abort for those that have not yet fully exited to free its 
memory.  If patches are going to be proposed on top of the oom reaper, 
please explicitly state that.

I believe any such race described in the changelog could be corrected by 
deferring the oom killer entirely until the oom reaper has been able to 
free memory or the oom victim has fully exited.  I haven't reviewed that, 
so I can't speak definitively, but I think we should avoid _any_ timeout 
based solution if possible and there's no indication this is the only way 
to solve such a problem.

oomkiller_victim_wait_ms seems to be another manifestation of the same 
patch which has been nack'd over and over again.  It does not address the 
situation where there are no additional eligible processes to kill and we 
end up panicking the machine when additional access to memory reserves may 
have allowed the victim to exit.  Randomly killing additional processes 
makes that problem worse since if they cannot exit (which may become more 
likely than not if all victims are waiting on a mutex held by an 
allocating thread).

My solution for that has always been to grant allocating threads temporary 
access to memory reserves in the hope that the mutex be dropped and the 
victim may make forward progress.  We have this implemented internally and 
I've posted a test module that easily exhibits the problem and how it is 
fixed.

The reality that we must confront, however, is very stark: if the system 
is out of memory and we have killed processes to free memory, we do not 
have the ability to recover from this situation in all cases.  We make a 
trade-off: either allow processes waiting for memory to have access to 
reserves so that the livelock hopefully gets worked out, or we randomly 
kill additional processes.  Neither of these work 100% of the time and 
you can easily create test modules which exhibit both.  We cannot do both 
solutions because memory reserves is a finite resource and we can't spread 
it to every process on the system and reasonably expect recovery.

The ability to recover from these situations is going to have a direct 
correlation to the size of your memory reserves, although even 
min_free_kbytes being very large will also not solve the problem 100% of 
the time.  Complaining that the oom reaper can be shown to not free enough 
memory, and that you can show that memory reserves can be fully depleted 
isn't interesting.  I could easily change my module that allocates while 
holding a mutex to have the lowest oom priority on the system and show 
that this timeout-based solution also doesn't work because reserves are 
finite.

We can make a best-effort to improve the situation: things like the oom 
reaper and access to memory reserves for processes looping forever due to 
a deferred oom killer.  It doesn't help to randomly oom kill processes 
that may be waiting on the same mutex itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
