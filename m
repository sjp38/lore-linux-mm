Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 66C0B6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 15:15:39 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id g62so123806150wme.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:15:39 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id r76si4289606wmg.70.2016.02.15.12.15.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 12:15:38 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id b205so10031841wmb.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 12:15:38 -0800 (PST)
Date: Mon, 15 Feb 2016 21:15:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/5] mm, oom_reaper: implement OOM victims queuing
Message-ID: <20160215201535.GB9223@dhcp22.suse.cz>
References: <1454505240-23446-6-git-send-email-mhocko@kernel.org>
 <201602041949.BIG30715.QVFLFOOOHMtSFJ@I-love.SAKURA.ne.jp>
 <20160204145357.GE14425@dhcp22.suse.cz>
 <201602061454.GDG43774.LSHtOOMFOFVJQF@I-love.SAKURA.ne.jp>
 <20160206083757.GB25220@dhcp22.suse.cz>
 <201602070033.GFC13307.MOJQtFHOFOVLFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602070033.GFC13307.MOJQtFHOFOVLFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 07-02-16 00:33:38, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 06-02-16 14:54:24, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > But if we consider non system-wide OOM events, it is not very unlikely to hit
> > > > > this race. This queue is useful for situations where memcg1 and memcg2 hit
> > > > > memcg OOM at the same time and victim1 in memcg1 cannot terminate immediately.
> > > > 
> > > > This can happen of course but the likelihood is _much_ smaller without
> > > > the global OOM because the memcg OOM killer is invoked from a lockless
> > > > context so the oom context cannot block the victim to proceed.
> > > 
> > > Suppose mem_cgroup_out_of_memory() is called from a lockless context via
> > > mem_cgroup_oom_synchronize() called from pagefault_out_of_memory(), that
> > > "lockless" is talking about only current thread, doesn't it?
> > 
> > Yes and you need the OOM context to sit on the same lock as the victim
> > to form a deadlock. So while the victim might be blocked somewhere it is
> > much less likely it would be deadlocked.
> > 
> > > Since oom_kill_process() sets TIF_MEMDIE on first mm!=NULL thread of a
> > > victim process, it is possible that non-first mm!=NULL thread triggers
> > > pagefault_out_of_memory() and first mm!=NULL thread gets TIF_MEMDIE,
> > > isn't it?
> > 
> > I got lost here completely. Maybe it is your usage of thread terminology
> > again.
> 
> I'm using "process" == "thread group" which contains at least one "thread",
> and "thread" == "struct task_struct".
> My assumption is
> 
>    (1) app1 process has two threads named app1t1 and app1t2
>    (2) app2 process has two threads named app2t1 and app2t2
>    (3) app1t1->mm == app1t2->mm != NULL and app2t1->mm == app2t2->mm != NULL
>    (4) app1 is in memcg1 and app2 is in memcg2
> 
> and sequence is
> 
>    (1) app1t2 triggers pagefault_out_of_memory()
>    (2) app1t2 calls mem_cgroup_out_of_memory() via mem_cgroup_oom_synchronize()
>    (3) oom_scan_process_thread() selects app1 as an OOM victim process
>    (4) find_lock_task_mm() selects app1t1 as an OOM victim thread
>    (5) app1t1 gets TIF_MEMDIE

OK so we have a victim in memcg1 and app1t2 will get to do_exit right away
because we are in the page fault path...

>    (6) app2t2 triggers pagefault_out_of_memory()
>    (7) app2t2 calls mem_cgroup_out_of_memory() via mem_cgroup_oom_synchronize()
>    (8) oom_scan_process_thread() selects app2 as an OOM victim process
>    (9) find_lock_task_mm() selects app2t1 as an OOM victim thread
>    (10) app2t1 gets TIF_MEMDIE
> 
> .
> 
> I'm talking about situation where app1t1 is blocked at down_write(&app1t1->mm->mmap_sem)
> because somebody else is already waiting at down_read(&app1t1->mm->mmap_sem) or is
> doing memory allocation between down_read(&app1t1->mm->mmap_sem) and
> up_read(&app1t1->mm->mmap_sem).

Unless we are under global OOM then this doesn't matter much because the
allocation request should succeed at some point in time and memcg
charges are bypassed for tasks with pending fatal signals. So we can
make a forward progress.

> In this case, this [PATCH 5/5] helps the OOM reaper to reap app2t1->mm
> after giving up waiting for down_read(&app1t1->mm->mmap_sem) to
> succeed.

Why does that matter at all?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
