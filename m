Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 765C66B0261
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:46:27 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so94793125lbb.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:46:27 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id y19si49034975wjw.14.2016.05.31.00.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 00:46:26 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a136so29927780wme.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:46:26 -0700 (PDT)
Date: Tue, 31 May 2016 09:46:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Message-ID: <20160531074624.GE26128@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-7-git-send-email-mhocko@kernel.org>
 <20160530173505.GA25287@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160530173505.GA25287@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 30-05-16 19:35:05, Oleg Nesterov wrote:
> On 05/30, Michal Hocko wrote:
> >
> > task_will_free_mem is rather weak.
> 
> I was thinking about the similar change because I noticed that try_oom_reaper()
> is very, very wrong.
> 
> To the point I think that we need another change for stable which simply removes
> spin_lock_irq(sighand->siglock) from try_oom_reaper(). It buys nothing, we can
> check signal_group_exit() (which is wrong too ;) lockless, and at the same time
> the kernel can crash because we can hit ->siglock == NULL.

OK, I have sent a separate patch
http://lkml.kernel.org/r/1464679423-30218-1-git-send-email-mhocko@kernel.org
and rebase the series on top. This would be 4.7 material. Thanks for
catching that!

> So I do think this change is good in general.
> 
> I think that task_will_free_mem() should be un-inlined, and __task_will_free_mem()
> should go into mm/oom-kill.c... but this is minor.

I was thinking about it as well but then thought that this would be
harder to review. But OK, I will do that.
 
> > -static inline bool task_will_free_mem(struct task_struct *task)
> > +static inline bool __task_will_free_mem(struct task_struct *task)
> >  {
> >  	struct signal_struct *sig = task->signal;
> >  
> > @@ -119,16 +119,69 @@ static inline bool task_will_free_mem(struct task_struct *task)
> >  	if (sig->flags & SIGNAL_GROUP_COREDUMP)
> >  		return false;
> >  
> > -	if (!(task->flags & PF_EXITING))
> > +	if (!(task->flags & PF_EXITING || fatal_signal_pending(task)))
> >  		return false;
> >  
> >  	/* Make sure that the whole thread group is going down */
> > -	if (!thread_group_empty(task) && !(sig->flags & SIGNAL_GROUP_EXIT))
> > +	if (!thread_group_empty(task) &&
> > +		!(sig->flags & SIGNAL_GROUP_EXIT || fatal_signal_pending(task)))
> >  		return false;
> >  
> >  	return true;
> >  }
> 
> Well, let me suggest this again. I think it should do
> 
> 
> 	if (SIGNAL_GROUP_COREDUMP)
> 		return false;
> 
> 	if (SIGNAL_GROUP_EXIT)
> 		return true;
> 
> 	if (thread_group_empty() && PF_EXITING)
> 		return true;
> 
> 	return false;
> 
> we do not need fatal_signal_pending(), in this case SIGNAL_GROUP_EXIT should
> be set (ignoring some bugs with sub-namespaces which we need to fix anyway).

OK, so we shouldn't care about race when the fatal_signal is set on the
task until it reaches do_group_exit?

> At the same time, we do not want to return false if PF_EXITING is not set
> if SIGNAL_GROUP_EXIT is set.

makes sense.

> > +static inline bool task_will_free_mem(struct task_struct *task)
> > +{
> > +	struct mm_struct *mm = NULL;
> > +	struct task_struct *p;
> > +	bool ret;
> > +
> > +	/*
> > +	 * If the process has passed exit_mm we have to skip it because
> > +	 * we have lost a link to other tasks sharing this mm, we do not
> > +	 * have anything to reap and the task might then get stuck waiting
> > +	 * for parent as zombie and we do not want it to hold TIF_MEMDIE
> > +	 */
> > +	p = find_lock_task_mm(task);
> > +	if (!p)
> > +		return false;
> > +
> > +	if (!__task_will_free_mem(p)) {
> > +		task_unlock(p);
> > +		return false;
> > +	}
> > +
> > +	mm = p->mm;
> > +	if (atomic_read(&mm->mm_users) <= 1) {
> 
> this is sub-optimal, we should probably take signal->live or ->nr_threads
> into account... but OK, we can do this later.

Yes I would prefer to add a more complex checks later. We want
mm_has_external_refs for other purposes as well.
 
> > +	rcu_read_lock();
> > +	for_each_process(p) {
> > +		ret = __task_will_free_mem(p);
> > +		if (!ret)
> > +			break;
> > +	}
> > +	rcu_read_unlock();
> 
> Yes, I agree very much.
> 
> But it seems you forgot to add the process_shares_mm() check into this loop?

Yes. Dunno where it got lost but it surely wasn't in the previous
version either. I definitely screwed somewhere...

> and perhaps it also makes sense to add
> 
> 	if (same_thread_group(tsk, p))
> 		continue;
> 
> This should not really matter, we know that __task_will_free_mem(p) should return
> true. Just to make it more clear.

ok

> And. I think this needs smp_rmb() at the end of the loop (assuming we have the
> process_shares_mm() check here). We need it to ensure that we read p->mm before
> we read next_task(), to avoid the race with exit() + clone(CLONE_VM).

Why don't we need the same barrier in oom_kill_process? Which barrier it
would pair with? Anyway I think this would deserve it's own patch.
Barriers are always tricky and it is better to have them in a small
patch with a full explanation.

Thanks for your review. It was really helpful!

The whole pile is currently in my k.org git tree in
attempts/process-share-mm-oom-sanitization branch if somebody wants to
see the full series.

My current diff on top of the patch
---
