Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8A60B6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 10:30:24 -0400 (EDT)
Received: by oibi136 with SMTP id i136so6247101oib.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 07:30:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id cn8si1200866oec.61.2015.09.22.07.30.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Sep 2015 07:30:23 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150921134414.GA15974@redhat.com>
	<20150921142423.GC19811@dhcp22.suse.cz>
	<20150921153252.GA21988@redhat.com>
	<201509220151.CHF17629.LFFJSHQVOMtOFO@I-love.SAKURA.ne.jp>
	<20150922124303.GA24570@redhat.com>
In-Reply-To: <20150922124303.GA24570@redhat.com>
Message-Id: <201509222330.JDI64510.FOLOFQStMVFJOH@I-love.SAKURA.ne.jp>
Date: Tue, 22 Sep 2015 23:30:06 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: mhocko@kernel.org, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Oleg Nesterov wrote:
> On 09/22, Tetsuo Handa wrote:
> >
> > I imagined a dedicated kernel thread doing something like shown below.
> > (I don't know about mm->mmap management.)
> > mm->mmap_zapped corresponds to MMF_MEMDIE.
> 
> No, it doesn't, please see below.
> 
> > bool has_sigkill_task;
> > wait_queue_head_t kick_mm_zapper;
> 
> OK, if this kthread is kicked by oom this makes more sense, but still
> doesn't look right at least initially.

Yes, I meant this kthread is kicked upon sending SIGKILL. But I forgot that

> 
> Let me repeat, I do think we need MMF_MEMDIE or something like it before
> we do something more clever. And in fact I think this flag makes sense
> regardless.
> 
> > static void mm_zapper(void *unused)
> > {
> > 	struct task_struct *g, *p;
> > 	struct mm_struct *mm;
> >
> > sleep:
> > 	wait_event(kick_remover, has_sigkill_task);
> > 	has_sigkill_task = false;
> > restart:
> > 	rcu_read_lock();
> > 	for_each_process_thread(g, p) {
> > 		if (likely(!fatal_signal_pending(p)))
> > 			continue;
> > 		task_lock(p);
> > 		mm = p->mm;
> > 		if (mm && mm->mmap && !mm->mmap_zapped && down_read_trylock(&mm->mmap_sem)) {
>                                        ^^^^^^^^^^^^^^^
> 
> We do not want mm->mmap_zapped, it can't work. We need mm->needs_zap
> set by oom_kill_process() and cleared after zap_page_range().
> 
> Because otherwise we can not handle CLONE_VM correctly. Suppose that
> an innocent process P does vfork() and the child is killed but not
> exited yet. mm_zapper() can find the child, do zap_page_range(), and
> surprise its alive parent P which uses the same ->mm.

kill(P's-child, SIGKILL) does not kill P sharing the same ->mm.
Thus, mm_zapper() can be used for only OOM-kill case and
test_tsk_thread_flag(p, TIF_MEMDIE) should be used than
fatal_signal_pending(p).

> 
> And if we rely on MMF_MEMDIE or mm->needs_zap or whaveter then
> for_each_process_thread() doesn't really make sense. And if we have
> a single MMF_MEMDIE process (likely case) then the unconditional
> _trylock is suboptimal.

I guess the more likely case is that the OOM victim successfully exits
before mm_zapper() finds it.

I thought that a dedicated kernel thread which scans the task list can do
deferred zapping by automatically retrying (in a few seconds interval ?)
when down_read_trylock() failed. 

> 
> Tetsuo, can't we do something simple which "obviously can't hurt at
> least" and then discuss the potential improvements?

No problem. I can wait for your version.

> 
> And yes, yes, the "Kill all user processes sharing victim->mm" logic
> in oom_kill_process() doesn't 100% look right, at least wrt the change
> we discuss.

If we use test_tsk_thread_flag(p, TIF_MEMDIE), we will need to set
TIF_MEMDIE to the victim after sending SIGKILL to all processes sharing
the victim's mm. Well, the likely case that the OOM victim exits before
mm_zapper() finds it becomes not-so-likely case? Then, MMF_MEMDIE is
better than test_tsk_thread_flag(p, TIF_MEMDIE)...

> 
> Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
