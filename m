Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B3FD06B007B
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 10:33:44 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so1951634wgh.36
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 07:33:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sb19si12681145wjb.6.2014.12.18.07.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 07:33:43 -0800 (PST)
Date: Thu, 18 Dec 2014 16:33:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141218153341.GB832@dhcp22.suse.cz>
References: <201412122254.AJJ57896.OLFOOJQHSMtFVF@I-love.SAKURA.ne.jp>
 <20141216124714.GF22914@dhcp22.suse.cz>
 <201412172054.CFJ78687.HFFLtVMOOJSQFO@I-love.SAKURA.ne.jp>
 <20141217130807.GB24704@dhcp22.suse.cz>
 <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Thu 18-12-14 21:11:26, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 17-12-14 20:54:53, Tetsuo Handa wrote:
> > [...]
> > > I'm not familiar with memcg.
> >
> > This check doesn't make any sense for this path because the task is part
> > of the memcg, otherwise it wouldn't trigger charge for it and couldn't
> > cause the OOM killer. Kernel threads do not have their address space
> > they cannot trigger memcg OOM killer. As you provide NULL nodemask then
> > this is basically a check for task being part of the memcg.
> 
> So !oom_unkillable_task(current, memcg, NULL) is always true for
> mem_cgroup_out_of_memory() case, isn't it?

yes, unless the task has moved away from the memcg since the charge
happened but that is not important because the charge happened for the
given memcg and so the OOM should happen there.

> >                                                             The check
> > for current->mm is not needed as well because task will not trigger a
> > charge after exit_mm.
> 
> So current->mm != NULL is always true for mem_cgroup_out_of_memory()
> case, isn't it?

yes

> > > But I think the condition whether TIF_MEMDIE
> > > flag should be set or not should be same between the memcg OOM killer and
> > > the global OOM killer, for a thread inside some memcg with TIF_MEMDIE flag
> > > can prevent the global OOM killer from killing other threads when the memcg
> > > OOM killer and the global OOM killer run concurrently (the worst corner case).
> > > When a malicious user runs a memory consumer program which triggers memcg OOM
> > > killer deadlock inside some memcg, it will result in the global OOM killer
> > > deadlock when the global OOM killer is triggered by other user's tasks.
> >
> > Hope that the above exaplains your concerns here.
> >
> 
> Thread1 in memcg1 asks for memory, and thread1 gets requested amount of
> memory without triggering the global OOM killer, and requested amount of
> memory is charged to memcg1, and the memcg OOM killer is triggered.
> While the memcg OOM killer is searching for a victim from threads in
> memcg1, thread2 in memcg2 asks for the memory. Thread2 fails to get
> requested amount of memory without triggering the global OOM killer.
> Now the global OOM killer starts searching for a victim from all threads
> whereas the memcg OOM killer chooses thread1 in memcg1 and sets TIF_MEMDIE
> flag on thread1 in memcg1. Then, the global OOM killer finds that thread1
> in memcg1 already has TIF_MEMDIE flag set, and waits for thread1 in memcg1
> to terminate than chooses another victim from all threads. However, when
> thread1 in memcg1 cannot be terminated immediately for some reason, thread2
> in memcg2 is blocked by thread1 in memcg1.

Sigh... T1 triggers memcg OOM killer _only_ from the page fault path and so it
will get to signal processing right away and eventually gets to exit_mm
where it releases its memory. If that doesn't suffice to release enough
memory then we are back to the original problem. So I do not think memcg
adds anything new to the problem.

[...]
> I think focusing on only mm-less case makes no sense, for with-mm case
> ruins efforts made for mm-less case.

No. It is quite opposite. Excluding mm less current from PF_EXITING
resp. fatal_signal_pending heuristics makes perfect sense from the OOM
killer POV. The reasons are described in the changelog.

> My question is quite simple. How can we avoid memory allocation stalls when
> 
>   System has 2048MB of RAM and no swap.
>   Memcg1 for task1 has quota 512MB and 400MB in use.
>   Memcg2 for task2 has quota 512MB and 400MB in use.
>   Memcg3 for task3 has quota 512MB and 400MB in use.
>   Memcg4 for task4 has quota 512MB and 400MB in use.
>   Memcg5 for task5 has quota 512MB and 1MB in use.
> 
> and task5 launches below memory consumption program which would trigger
> the global OOM killer before triggering the memcg OOM killer?
> 
[...]
> The global OOM killer will try to kill this program because this program
> will be using 400MB+ of RAM by the time the global OOM killer is triggered.
> But sometimes this program cannot be terminated by the global OOM killer
> due to XFS lock dependency.
> 
> You can see what is happening from OOM traces after uptime > 320 seconds of
> http://I-love.SAKURA.ne.jp/tmp/serial-20141213.txt.xz though memcg is not
> configured on this program.

This is clearly a separate issue. It is a lock dependency and that alone
_cannot_ be handled from OOM killer as it doesn't understand lock
dependencies. This should be addressed from the xfs point of view IMHO
but I am not familiar with this filesystem to tell you how or whether it
is possible.

[...]
> > >     if (!task->mm && test_tsk_thread_flag(task, TIF_MEMDIE))
> > >         return true;
> > >
> > > check should be added to oom_unkillable_task() because mm-less thread can
> > > release little memory (except invisible memory if any).
> >
> > Why do you think this makes more sense than handling this very special
> > case in out_of_memory? I really do not see any reason to to make
> > oom_unkillable_task more complicated.
> 
> Because everyone can safely skip victim threads who don't have mm.

And that is handled already. Check oom_badness and its find_lock_task_mm
oom_scan_process_thread and its task->mm and out_of_memory and the
complete sysctl_oom_kill_allocating_task check.

> Handling setting of TIF_MEMDIE in the caller is racy.

Any operation on another task is racy, that's why I prefer current->mm
check in out_of_memory.

> Somebody may set
> TIF_MEMDIE at oom_kill_process() even if we avoided setting TIF_MEMDIE at
> out_of_memory(). There will be more locations where TIF_MEMDIE is set; even
> out-of-tree modules might set TIF_MEMDIE.

TIF_MEMDIE should be set only when we _know_ the task will free _some_
memory and when we are killing the OOM victim. The only place I can see
that would break the first condition is out_of_memory for the current
which passed exit_mm(). That is the point why I've suggested you this
patch and it would be much more easier if we could simply finished that
one without pulling other things in.

Out-of-tree and even in-tree modules have no bussines in setting the
flag. lowmemory killer is doing that but that is an abuse and should be
fixed in other way. TIF_MEMDIE is not a flag anybody can touch.

> Nonetheless, I don't think
> 
>     if (!task->mm && test_tsk_thread_flag(task, TIF_MEMDIE))
>         return true;
> 
> check is perfect because we anyway need to prepare for both mm-less and
> with-mm cases.
> 
> My concern is not "whether TIF_MEMDIE flag should be set or not". My concern
> is not "whether task->mm is NULL or not". My concern is "whether threads with
> TIF_MEMDIE flag retard other process' memory allocation or not".
> Above-mentioned program is an example of with-mm threads retarding
> other process' memory allocation.

There is no way you can guarantee something like that. OOM is the _last_
resort. Things are in a pretty bad state already when it hits. It is the
last attempt to reclaim some memory. System might be in an arbitrary
state at this time.
I really hate to repeat myself but you are trying to "fix" your problem
at a wrong level.

> I know you don't like timeout approach, but adding
> 
>     if (sysctl_memdie_timeout_secs && test_tsk_thread_flag(task, TIF_MEMDIE) &&
>         time_after(jiffies, task->memdie_start + sysctl_memdie_timeout_secs * HZ))
>         return true;
> 
> check to oom_unkillable_task() will take care of both mm-less and with-mm
> cases because everyone can safely skip the TIF_MEMDIE victim threads who
> cannot be terminated immediately for some reason.

It will not take care of anything. It will start shooting to more
processes after some timeout, which is hard to get right, and there
wouldn't be any guaratee multiple victims will help because they might
end up blocking on the very same or other lock on the way out. Jeez are
you even reading feedback you are getting?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
