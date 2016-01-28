Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7B96B0254
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 16:42:51 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p63so43768950wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 13:42:51 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id mo12si17805665wjc.138.2016.01.28.13.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 13:42:49 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id p63so6301018wmp.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 13:42:49 -0800 (PST)
Date: Thu, 28 Jan 2016 22:42:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20160128214247.GD621@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452094975-551-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 27-01-16 17:28:10, David Rientjes wrote:
> On Wed, 6 Jan 2016, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> > independently brought up by Oleg Nesterov.
> > 
> 
> Suggested-bys?

Sure, why not.
 
> > The OOM killer currently allows to kill only a single task in a good
> > hope that the task will terminate in a reasonable time and frees up its
> > memory.  Such a task (oom victim) will get an access to memory reserves
> > via mark_oom_victim to allow a forward progress should there be a need
> > for additional memory during exit path.
> > 
> > It has been shown (e.g. by Tetsuo Handa) that it is not that hard to
> > construct workloads which break the core assumption mentioned above and
> > the OOM victim might take unbounded amount of time to exit because it
> > might be blocked in the uninterruptible state waiting for on an event
> > (e.g. lock) which is blocked by another task looping in the page
> > allocator.
> > 
> 
> s/for on/for/

fixed
 
> I think it would be good to note in either of the two paragraphs above 
> that each victim is per-memcg hierarchy or system-wide and the oom reaper 
> is used for memcg oom conditions as well.  Otherwise, there's no mention 
> of the memcg usecase.

I didn't mention memcg usecase because that doesn't suffer from the
deadlock issue because the OOM is invoked from the lockless context. I
think this would just make the wording more confusing.

[...]
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
> > +		 * mlocked VMAs require explicit munlocking before unmap.
> > +		 * Let's keep it simple here and skip such VMAs.
> > +		 */
> > +		if (vma->vm_flags & VM_LOCKED)
> > +			continue;
> 
> Shouldn't there be VM_PFNMAP handling here?

What would be the reason to exclude them?

> I'm wondering why zap_page_range() for vma->vm_start to vma->vm_end wasn't 
> used here for simplicity?

I didn't use zap_page_range because I wanted to have a full control over
what and how gets torn down. E.g. it is much more easier to skip over
hugetlb pages than relying on i_mmap_lock_write which might be blocked
and the whole oom_reaper will get stuck.

[...]
> > +static void wake_oom_reaper(struct mm_struct *mm)
> > +{
> > +	struct mm_struct *old_mm;
> > +
> > +	if (!oom_reaper_th)
> > +		return;
> > +
> > +	/*
> > +	 * Pin the given mm. Use mm_count instead of mm_users because
> > +	 * we do not want to delay the address space tear down.
> > +	 */
> > +	atomic_inc(&mm->mm_count);
> > +
> > +	/*
> > +	 * Make sure that only a single mm is ever queued for the reaper
> > +	 * because multiple are not necessary and the operation might be
> > +	 * disruptive so better reduce it to the bare minimum.
> > +	 */
> > +	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
> > +	if (!old_mm)
> > +		wake_up(&oom_reaper_wait);
> > +	else
> > +		mmdrop(mm);
> 
> This behavior is probably the only really significant concern I have about 
> the patch: we just drop the mm and don't try any reaping if there is 
> already reaping in progress.

This is based on the assumption that OOM killer will not select another
task to kill until the previous one drops its TIF_MEMDIE. Should this
change in the future we will have to come up with a queuing mechanism. I
didn't want to do it right away to make the change as simple as
possible.

> We don't always have control over the amount of memory that can be reaped 
> from the victim, either because of oom kill prioritization through 
> /proc/pid/oom_score_adj or because the memory of the victim is not 
> eligible.
> 
> I'm imagining a scenario where the oom reaper has raced with a follow-up 
> oom kill before mm_to_reap has been set to NULL so there's no subsequent 
> reaping.  It's also possible that oom reaping of the first victim actually 
> freed little memory.
> 
> Would it really be difficult to queue mm's to reap from?  If memory has 
> already been freed before the reaper can get to it, the 
> find_lock_task_mm() should just fail and we're done.  I'm not sure why 
> this is being limited to a single mm system-wide.

It is not that complicated but I believe we can implement it on top once
we see this is really needed. So unless this is a strong requirement I
would rather go with a simpler way.

> > +}
> > +
> > +static int __init oom_init(void)
> > +{
> > +	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> > +	if (IS_ERR(oom_reaper_th)) {
> > +		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> > +				PTR_ERR(oom_reaper_th));
> > +		oom_reaper_th = NULL;
> > +	} else {
> > +		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
> > +
> > +		/*
> > +		 * Make sure our oom reaper thread will get scheduled when
> > +		 * ASAP and that it won't get preempted by malicious userspace.
> > +		 */
> > +		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
> 
> Eeek, do you really show this is necessary?  I would imagine that we would 
> want to limit high priority processes system-wide and that we wouldn't 
> want to be interferred with by memcg oom conditions that trigger the oom 
> reaper, for example.

The idea was that we do not want to allow a high priority userspace to
preempt this important operation. I do understand your concern about the
memcg oom interference but I find it more important that oom_reaper is
runnable when needed. I guess that memcg oom heavy loads can change the
priority from userspace if necessary?

[...]
> > @@ -607,17 +748,25 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  			continue;
> >  		if (same_thread_group(p, victim))
> >  			continue;
> > -		if (unlikely(p->flags & PF_KTHREAD))
> > -			continue;
> >  		if (is_global_init(p))
> >  			continue;
> > -		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +		if (unlikely(p->flags & PF_KTHREAD) ||
> > +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +			/*
> > +			 * We cannot use oom_reaper for the mm shared by this
> > +			 * process because it wouldn't get killed and so the
> > +			 * memory might be still used.
> > +			 */
> > +			can_oom_reap = false;
> >  			continue;
> > -
> > +		}
> >  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> 
> Is it possible to just do wake_oom_reaper(mm) here and eliminate 
> can_oom_reap with a little bit of moving around?

I am not sure how do you mean it. We have to check all processes before
we can tell that reaping is safe. Care to elaborate some more? I am all
for making the code easier to follow and understand.

> 
> >  	}
> >  	rcu_read_unlock();
> >  
> > +	if (can_oom_reap)
> > +		wake_oom_reaper(mm);
> > +
> >  	mmdrop(mm);
> >  	put_task_struct(victim);
> >  }

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
