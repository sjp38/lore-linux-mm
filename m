Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 653F56B0254
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 11:34:59 -0500 (EST)
Received: by wmuu63 with SMTP id u63so27773828wmu.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 08:34:58 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id w2si4546837wme.80.2015.11.26.08.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 08:34:58 -0800 (PST)
Received: by wmvv187 with SMTP id v187so38697608wmv.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 08:34:57 -0800 (PST)
Date: Thu, 26 Nov 2015 17:34:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: introduce oom reaper
Message-ID: <20151126163456.GM7953@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <20151125200806.GA13388@cmpxchg.org>
 <20151126110849.GC7953@dhcp22.suse.cz>
 <201511270024.DFJ57385.OFtJQSMOFFLOHV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511270024.DFJ57385.OFtJQSMOFFLOHV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

On Fri 27-11-15 00:24:43, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 25-11-15 15:08:06, Johannes Weiner wrote:
> > > Hi Michal,
> > > 
> > > I think whatever we end up doing to smoothen things for the "common
> > > case" (as much as OOM kills can be considered common), we need a plan
> > > to resolve the memory deadlock situations in a finite amount of time.
> > > 
> > > Eventually we have to attempt killing another task. Or kill all of
> > > them to save the kernel.
> > > 
> > > It just strikes me as odd to start with smoothening the common case,
> > > rather than making it functionally correct first.
> > 
> 
> Me too.
> 
> > I believe there is not an universally correct solution for this
> > problem. OOM killer is a heuristic and a destructive one so I think we
> > should limit it as much as possible. I do agree that we should allow an
> > administrator to define a policy when things go terribly wrong - e.g.
> > panic/emerg. reboot after the system is trashing on OOM for more than
> > a defined amount of time. But I think that this is orthogonal to this
> > patch. This patch should remove one large class of potential deadlocks
> > and corner cases without too much cost or maintenance burden. It doesn't
> > remove a need for the last resort solution though.
> >  
> 
>  From the point of view of a technical staff at support center, offering
> the last resort solution has higher priority than smoothening the common
> case. We cannot test all memory pressure patterns before distributor's
> kernel is released. We are too late to workaround unhandled patterns
> after distributor's kernel is deployed to customer's systems.

This has been posted months ago without any additional tracktion.
 
> Yet another report was posted in a different thread
> "[PATCH] vmscan: do not throttle kthreads due to too_many_isolated".
> I think I showed you several times including "mm,oom: The reason why
> I continue proposing timeout based approach."
> (uptime > 100 of http://I-love.SAKURA.ne.jp/tmp/serial-20150920.txt.xz )
> that we are already seeing infinite loop at too_many_isolated() even
> without using out of tree drivers. I hope that my patch
> http://lkml.kernel.org/r/201505232339.DAB00557.VFFLHMSOJFOOtQ@I-love.SAKURA.ne.jp
> included all necessary changes for serving as a base of the last resort.
> Please don't loop forever when unexpected memory pressure is given.
> Please don't assume somebody else can make forward progress.
> 
> Please do consider offering the last resort solution first.
> That will help reducing unexplained hangup/reboot troubles.

And the answer alwas has been that the proposed last resort solutions
have their own issues. I am not going repeat them here because I really
do not want to make this thread yet another mess of unrelated topics. I
am suggesting another reclaim technique so please stick to the topic
here.  I do not see any reason why we should convolute this with last
resort solutions.
 
> Given that said, several comments on your patch.
> 
> > @@ -408,6 +413,108 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
> >  
> >  bool oom_killer_disabled __read_mostly;
> >  
> > +/*
> > + * OOM Reaper kernel thread which tries to reap the memory used by the OOM
> > + * victim (if that is possible) to help the OOM killer to move on.
> > + */
> > +static struct task_struct *oom_reaper_th;
> > +static struct mm_struct *mm_to_reap;
> > +static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
> > +
> > +static bool __oom_reap_vmas(struct mm_struct *mm)
> > +{
> > +	struct mmu_gather tlb;
> > +	struct vm_area_struct *vma;
> > +	struct zap_details details = {.check_swap_entries = true,
> > +				      .ignore_dirty = true};
> > +	bool ret = true;
> > +
> > +	/* We might have raced with exit path */
> > +	if (!atomic_inc_not_zero(&mm->mm_users))
> > +		return true;
> > +
> > +	if (!down_read_trylock(&mm->mmap_sem)) {
> > +		ret = false;
> > +		goto out;
> > +	}
> > +
> > +	tlb_gather_mmu(&tlb, mm, 0, -1);
> > +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > +		if (is_vm_hugetlb_page(vma))
> > +			continue;
> > +
> > +		/*
> > +		 * Only anonymous pages have a good chance to be dropped
> > +		 * without additional steps which we cannot afford as we
> > +		 * are OOM already.
> > +		 */
> > +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> > +			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> > +					 &details);
> 
> How do you plan to make sure that reclaimed pages are used by
> fatal_signal_pending() tasks?
> http://lkml.kernel.org/r/201509242050.EHE95837.FVFOOtMQHLJOFS@I-love.SAKURA.ne.jp
> http://lkml.kernel.org/r/201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp

Well the wake_oom_reaper is responsible to hand over mm of the OOM
victim and as such it should be a killed process.  I guess you mean that
the mm might be shared with another process which is hidden from the OOM
killer, right? Well I think this is not something to care about at this
layer. We shouldn't select a tasks which can lead to this situation in
the first place. Such an oom victim is basically selected incorrectly. I
think we can handle that by a flag in mm_struct.

I guess we have never cared too much about this case because it sounds
like a misconfiguration. If you want to shoot your own head the do it.
It is true that this patch will make such a case more prominent because
we can cause a side effect now. I can cook up a patch to help to sort
this out.

Thanks for pointing this out.

> 
> > +	}
> > +	tlb_finish_mmu(&tlb, 0, -1);
> > +	up_read(&mm->mmap_sem);
> > +out:
> > +	mmput(mm);
> > +	return ret;
> > +}
> 
> > +static int oom_reaper(void *unused)
> > +{
> > +	DEFINE_WAIT(wait);
> > +
> > +	while (!kthread_should_stop()) {
> 
> Is there a situation where this kernel thread should stop?

No, but this seems to be a generic kthread pattern so I've reused it.
I thought that every kernel thread is supposed to do that because
they will be torn down on powerdown from somewhere but I cannot seem to
find it right now. So for now I will go with while (true) here.

> I think this kernel thread should not stop because restarting
> this kernel thread might invoke the OOM killer.
> But if there is such situation, leaving this function with
> oom_reaper_th != NULL is not handled by wake_oom_reaper().
>
> 
> > +		struct mm_struct *mm;
> > +
> > +		prepare_to_wait(&oom_reaper_wait, &wait, TASK_UNINTERRUPTIBLE);
> > +		mm = READ_ONCE(mm_to_reap);
> 
> Why not simply mm = xchg(&mm_to_reap, NULL) and free the slot for
> next OOM victim (though xchg() may not be sufficient)?

Because it is not clear whether that is necessary. I wanted to minimize
the effect of the external reaping to bare minumum. oom_reap_vmas will
bail out early when it sees that it is racing with exit_mmap so we would
release mm_to_reap early if we are not going to release anything.

> 
> > +		if (!mm) {
> > +			freezable_schedule();
> > +			finish_wait(&oom_reaper_wait, &wait);
> > +		} else {
> > +			finish_wait(&oom_reaper_wait, &wait);
> > +			oom_reap_vmas(mm);
> > +			WRITE_ONCE(mm_to_reap, NULL);
> > +		}
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static void wake_oom_reaper(struct mm_struct *mm)
> > +{
> > +	struct mm_struct *old_mm;
> > +
> > +	if (!oom_reaper_th)
> > +		return;
> > +
> > +	/*
> > +	 * Make sure that only a single mm is ever queued for the reaper
> > +	 * because multiple are not necessary and the operation might be
> > +	 * disruptive so better reduce it to the bare minimum.
> > +	 */
> > +	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
> 
> I think we should not skip queuing next OOM victim, for it is possible
> that first OOM victim is chosen by one memory cgroup OOM, and next OOM
> victim is chosen by another memory cgroup OOM or system wide OOM before
> oom_reap_vmas() for first OOM victim completes.

Does that matter though. Be it a memcg OOM or a global OOM victim, we
will still release a memory which should help the global case which we
care about the most. Memcg OOM killer handling is easier because we do
not hold any locks while waiting for the OOM to be handled.

> To handle such case, we would need to do something like
> 
>  struct mm_struct {
>      (...snipped...)
> +    struct list_head *memdie; /* Set to non-NULL when chosen by OOM killer */
>  }
> 
> and add to a list of OOM victims.

I really wanted to prevent from additional memory footprint for a highly
unlikely case. Why should everybody pay for a case which is rarely hit?

Also if this turns out to be a real problem then it can be added on top
of the existing code. I would really like this to be as easy as
possible.

[...]
> > @@ -421,6 +528,11 @@ void mark_oom_victim(struct task_struct *tsk)
> >  	/* OOM killer might race with memcg OOM */
> >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> >  		return;
> > +
> > +	/* Kick oom reaper to help us release some memory */
> > +	if (tsk->mm)
> > +		wake_oom_reaper(tsk->mm);
> > +
> 
> We cannot wake up at this moment. It is too early because there may be
> other threads sharing tsk->mm but SIGKILL not yet received.

OK, I can see your point and I was considering that. I have settled with
conclusion that we shouldn't care that much because they would page fault
and get stuck in the allocation because we are OOM. There might be some
corner cases but I guess you are right that this should be as
concervative as possible so I will move the wake up to oom_kill_process.

> Also, there
> may be unkillable threads sharing tsk->mm. I think appropriate location
> to wake the reaper up is

I have commented on this already.

> 
>                   do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>           }
>           rcu_read_unlock();
>           /* here */
>           mmdrop(mm);
>           put_task_struct(victim);
>   }
> 
> in oom_kill_process().

OK I will move it here. We will lose other cases where nobody is killed
because those would have to guarantee the same thing as mentioned above
but that sounds like good for now solution.

> 
> >  	/*
> >  	 * Make sure that the task is woken up from uninterruptible sleep
> >  	 * if it is frozen because OOM killer wouldn't be able to free
> > @@ -767,3 +879,22 @@ void pagefault_out_of_memory(void)
> >  
> >  	mutex_unlock(&oom_lock);
> >  }
> > +
> > +static int __init oom_init(void)
> > +{
> > +	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> > +	if (IS_ERR(oom_reaper_th)) {
> > +		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> > +				PTR_ERR(oom_reaper_th));
> 
> BUG_ON(IS_ERR(oom_reaper_th)) or panic() should be OK.
> Continuing with IS_ERR(oom_reaper_th) is not handled by wake_oom_reaper().

Yes, but we can live without this kernel thread, right? I do not think
this will ever happen but why should we panic the system?

Thanks for the review.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
