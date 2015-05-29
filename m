Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E7BA26B006E
	for <linux-mm@kvack.org>; Fri, 29 May 2015 13:20:30 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so58141358pdb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 10:20:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id wt10si9248588pab.236.2015.05.29.10.20.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 May 2015 10:20:29 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150527164505.GD27348@dhcp22.suse.cz>
	<201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
	<20150528180524.GB2321@dhcp22.suse.cz>
	<201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
	<20150529144922.GE22728@dhcp22.suse.cz>
In-Reply-To: <20150529144922.GE22728@dhcp22.suse.cz>
Message-Id: <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
Date: Sat, 30 May 2015 02:20:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Fri 29-05-15 21:40:47, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Thu 28-05-15 06:59:32, Tetsuo Handa wrote:
> > > > I just imagined a case where p is blocked at down_read() in acct_collect() from
> > > > do_exit() when p is sharing mm with other processes, and other process is doing
> > > > blocking operation with mm->mmap_sem held for writing. Is such case impossible?
> > > 
> > > It is very much possible and I have missed this case when proposing
> > > my alternative. The other process could be doing an address space
> > > operation e.g. mmap which requires an allocation.
> > 
> > Are there locations that do memory allocations with mm->mmap_sem held for
> > writing?
> 
> Yes, I've written that in my previous email.
> 
> > Is it possible that thread1 is doing memory allocation between
> > down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem),
> > thread2 sharing the same mm is waiting at down_read(&current->mm->mmap_sem),
> > and the OOM killer invoked by thread3 chooses thread2 as the OOM victim and
> > sets TIF_MEMDIE to thread2?
> 
> Your usage of thread is confusing. Threads are of no concerns because
> those get killed when the group leader is killed. If you refer to
> processes then this is exactly what is handled by:
>         for_each_process(p)
>                 if (p->mm == mm && !same_thread_group(p, victim) &&
>                     !(p->flags & PF_KTHREAD)) {
>                         if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>                                 continue;
> 
>                         task_lock(p);   /* Protect ->comm from prctl() */
>                         pr_err("Kill process %d (%s) sharing same memory\n",
>                                 task_pid_nr(p), p->comm);
>                         task_unlock(p);
>                         do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>                 }

I refer to both "Thread-1 in process-1, thread-2 in process-1" case and
"thread-1 in process-1, thread-2 in process-2" case. Thread-3 can be in
process-1 or process-2 or neither.

When TIF_MEMDIE is set to only thread-2 waiting at down_read(), thread-1
between down_write() and up_write() cannot complete memory allocation.
The group leader is not important here because I'm talking about situations
when individual thread cannot arrive at exit_mm() after receiving SIGKILL
due to lock dependency.

> But this is a real corner case. It would have to be current to trigger
> OOM killer and the userspace would have to be able to send the signal
> at the right moment... So I am even not sure this needs fixing. Are you
> able to trigger it?

I'm not sure whether we are talking about the same problem.
I thought that we could get rid of TIF_MEMDIE like

    for_each_process(p) {
            if (p->mm == thread2->mm && !(p->flags & PF_KTHREAD) &&
                p->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
                        do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
    }
    thread2->mm->chosen_by_oom_killer = true;

if we need to set TIF_MEMDIE to all threads like

    for_each_process(p) {
            if (p->mm == thread2->mm && !(p->flags & PF_KTHREAD) &&
                p->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
                        do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
                        for_each_thread(p, t)
                                mark_oom_victim(t);
            }
    }

in order to make sure that thread-1 can complete memory allocation.

If thread-1 and thread-2 do not share the same mm, setting TIF_MEMDIE to
all threads might not be sufficient because they can contend on e.g.
inode->i_mutex. But that's beyond scope of this suppress message patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
