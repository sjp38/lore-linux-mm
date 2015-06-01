Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id D7C656B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 06:51:10 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so22086184pdj.3
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 03:51:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v5si21069828pdb.7.2015.06.01.03.51.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 03:51:09 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150528180524.GB2321@dhcp22.suse.cz>
	<201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
	<20150529144922.GE22728@dhcp22.suse.cz>
	<201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
	<20150601090341.GA7147@dhcp22.suse.cz>
In-Reply-To: <20150601090341.GA7147@dhcp22.suse.cz>
Message-Id: <201506011951.DCC81216.tMVQHLFOFFOJSO@I-love.SAKURA.ne.jp>
Date: Mon, 1 Jun 2015 19:51:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Sat 30-05-15 02:20:23, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 29-05-15 21:40:47, Tetsuo Handa wrote:
> [...]
> > > > Is it possible that thread1 is doing memory allocation between
> > > > down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem),
> > > > thread2 sharing the same mm is waiting at down_read(&current->mm->mmap_sem),
> > > > and the OOM killer invoked by thread3 chooses thread2 as the OOM victim and
> > > > sets TIF_MEMDIE to thread2?
> > > 
> > > Your usage of thread is confusing. Threads are of no concerns because
> > > those get killed when the group leader is killed. If you refer to
> > > processes then this is exactly what is handled by:
> > >         for_each_process(p)
> > >                 if (p->mm == mm && !same_thread_group(p, victim) &&
> > >                     !(p->flags & PF_KTHREAD)) {
> > >                         if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > >                                 continue;
> > > 
> > >                         task_lock(p);   /* Protect ->comm from prctl() */
> > >                         pr_err("Kill process %d (%s) sharing same memory\n",
> > >                                 task_pid_nr(p), p->comm);
> > >                         task_unlock(p);
> > >                         do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> > >                 }
> > 
> > I refer to both "Thread-1 in process-1, thread-2 in process-1" case and
> > "thread-1 in process-1, thread-2 in process-2" case. Thread-3 can be in
> > process-1 or process-2 or neither.
> 
> And that makes it confusing because threads in the same thread group
> case is not really interesting. All the threads have fatal signal
> pending and they would get access to memory reserves as they hit the oom
> killer.

Excuse me, but I didn't understand it.

TIF_MEMDIE is per a "struct task_struct" attribute which is set on
its corresponding "struct thread_info"->flags member, isn't it?
Two "struct task_struct" can't share the same "struct thread_info"->flags
member, can it?

And the condition which we allow access to memory reserves is not
"whether SIGKILL is pending or not" but "whether TIF_MEMDIE is set or not",
doesn't it?

----------
static inline int
gfp_to_alloc_flags(gfp_t gfp_mask)
{
(...snipped...)
	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
		if (gfp_mask & __GFP_MEMALLOC)
			alloc_flags |= ALLOC_NO_WATERMARKS;
		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
			alloc_flags |= ALLOC_NO_WATERMARKS;
		else if (!in_interrupt() &&
			 ((current->flags & PF_MEMALLOC) ||
			  unlikely(test_thread_flag(TIF_MEMDIE))))
			alloc_flags |= ALLOC_NO_WATERMARKS;
	}
(...snipped...)
}
----------

How can all fatal_signal_pending() "struct task_struct" get access to memory
reserves when only one of fatal_signal_pending() "struct task_struct" has
TIF_MEMDIE ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
