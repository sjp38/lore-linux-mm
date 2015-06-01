Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 53C016B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 05:03:45 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so22384331wib.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 02:03:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ch9si17078818wib.90.2015.06.01.02.03.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 02:03:43 -0700 (PDT)
Date: Mon, 1 Jun 2015 11:03:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150601090341.GA7147@dhcp22.suse.cz>
References: <20150527164505.GD27348@dhcp22.suse.cz>
 <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
 <20150528180524.GB2321@dhcp22.suse.cz>
 <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
 <20150529144922.GE22728@dhcp22.suse.cz>
 <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sat 30-05-15 02:20:23, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 29-05-15 21:40:47, Tetsuo Handa wrote:
[...]
> > > Is it possible that thread1 is doing memory allocation between
> > > down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem),
> > > thread2 sharing the same mm is waiting at down_read(&current->mm->mmap_sem),
> > > and the OOM killer invoked by thread3 chooses thread2 as the OOM victim and
> > > sets TIF_MEMDIE to thread2?
> > 
> > Your usage of thread is confusing. Threads are of no concerns because
> > those get killed when the group leader is killed. If you refer to
> > processes then this is exactly what is handled by:
> >         for_each_process(p)
> >                 if (p->mm == mm && !same_thread_group(p, victim) &&
> >                     !(p->flags & PF_KTHREAD)) {
> >                         if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> >                                 continue;
> > 
> >                         task_lock(p);   /* Protect ->comm from prctl() */
> >                         pr_err("Kill process %d (%s) sharing same memory\n",
> >                                 task_pid_nr(p), p->comm);
> >                         task_unlock(p);
> >                         do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> >                 }
> 
> I refer to both "Thread-1 in process-1, thread-2 in process-1" case and
> "thread-1 in process-1, thread-2 in process-2" case. Thread-3 can be in
> process-1 or process-2 or neither.

And that makes it confusing because threads in the same thread group
case is not really interesting. All the threads have fatal signal
pending and they would get access to memory reserves as they hit the oom
killer.

If the mm sharing tasks are separate processes though we have to emulate
that behavior because they do not share the signal handling. That is
what the above for_each_process does. Again they will get access to
memory reserves once they hit the oom killer due to fatal signal
pending.

See? So the only remaining case is when we do not kill other processes
sharing the mm because as you pointed out, the first task even didn't go
through that for_each_process loop.

> When TIF_MEMDIE is set to only thread-2 waiting at down_read(), thread-1
> between down_write() and up_write() cannot complete memory allocation.

> The group leader is not important here

Yes you are right. I thought that sending SIGKILL to !leader will not
kill the whole group but now that I am looking at complete_signal it
really does (SIGKILL is always a group signal). So group leader really
doesn't play any role here. Sorry about the confusion.

> because I'm talking about situations
> when individual thread cannot arrive at exit_mm() after receiving SIGKILL
> due to lock dependency.
>
> > But this is a real corner case. It would have to be current to trigger
> > OOM killer and the userspace would have to be able to send the signal
> > at the right moment... So I am even not sure this needs fixing. Are you
> > able to trigger it?
> 
> I'm not sure whether we are talking about the same problem.
> I thought that we could get rid of TIF_MEMDIE like
> 
>     for_each_process(p) {
>             if (p->mm == thread2->mm && !(p->flags & PF_KTHREAD) &&
>                 p->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
>                         do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>     }
>     thread2->mm->chosen_by_oom_killer = true;

why would you send SIGKILL to your threads in the same thread group again?

> if we need to set TIF_MEMDIE to all threads like
> 
>     for_each_process(p) {
>             if (p->mm == thread2->mm && !(p->flags & PF_KTHREAD) &&
>                 p->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>                         do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>                         for_each_thread(p, t)
>                                 mark_oom_victim(t);
>             }
>     }
> 
> in order to make sure that thread-1 can complete memory allocation.

No we can't. See the big fat warning above the for_each_process loop.
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
