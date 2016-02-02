Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 903D26B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 03:58:01 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p63so107039583wmp.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 00:58:01 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ew3si562384wjd.140.2016.02.02.00.57.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 00:58:00 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id l66so1363935wml.2
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 00:57:59 -0800 (PST)
Date: Tue, 2 Feb 2016 09:57:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20160202085758.GE19910@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452094975-551-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com>
 <20160128214247.GD621@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602011843250.31751@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602011843250.31751@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 01-02-16 19:02:06, David Rientjes wrote:
> On Thu, 28 Jan 2016, Michal Hocko wrote:
> 
> > [...]
> > > > +static bool __oom_reap_vmas(struct mm_struct *mm)
> > > > +{
> > > > +	struct mmu_gather tlb;
> > > > +	struct vm_area_struct *vma;
> > > > +	struct zap_details details = {.check_swap_entries = true,
> > > > +				      .ignore_dirty = true};
> > > > +	bool ret = true;
> > > > +
> > > > +	/* We might have raced with exit path */
> > > > +	if (!atomic_inc_not_zero(&mm->mm_users))
> > > > +		return true;
> > > > +
> > > > +	if (!down_read_trylock(&mm->mmap_sem)) {
> > > > +		ret = false;
> > > > +		goto out;
> > > > +	}
> > > > +
> > > > +	tlb_gather_mmu(&tlb, mm, 0, -1);
> > > > +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > > > +		if (is_vm_hugetlb_page(vma))
> > > > +			continue;
> > > > +
> > > > +		/*
> > > > +		 * mlocked VMAs require explicit munlocking before unmap.
> > > > +		 * Let's keep it simple here and skip such VMAs.
> > > > +		 */
> > > > +		if (vma->vm_flags & VM_LOCKED)
> > > > +			continue;
> > > 
> > > Shouldn't there be VM_PFNMAP handling here?
> > 
> > What would be the reason to exclude them?
> > 
> 
> Not exclude them, but I would have expected untrack_pfn().

My understanding is that vm_normal_page will do the right thing for
those mappings - especially for CoW VM_PFNMAP which are normal pages
AFAIU. Wrt. to untrack_pfn I was relying that the victim will eventually
enter exit_mmap and do the remaining house keepining. Maybe I am missing
something but untrack_pfn shouldn't lead to releasing a considerable
amount of memory. So is this really necessary or we can wait for
exit_mmap?

> > > I'm wondering why zap_page_range() for vma->vm_start to vma->vm_end wasn't 
> > > used here for simplicity?
> > 
> > I didn't use zap_page_range because I wanted to have a full control over
> > what and how gets torn down. E.g. it is much more easier to skip over
> > hugetlb pages than relying on i_mmap_lock_write which might be blocked
> > and the whole oom_reaper will get stuck.
> > 
> 
> Let me be clear that I think the implementation is fine, minus the missing 
> handling for VM_PFNMAP.  However, I think this implementation is better 
> placed into mm/memory.c to do the iteration, selection criteria, and then 
> unmap_page_range().  I don't think we should be exposing 
> unmap_page_range() globally, but rather add a new function to do the 
> iteration in mm/memory.c with the others.

I do not have any objections to moving the code but I felt this is a
single purpose thingy which doesn't need a wider exposure. The exclusion
criteria is tightly coupled to what oom reaper is allowed to do. In
other words such a function wouldn't be reusable for say MADV_DONTNEED
because it has different criteria. Having all the selection criteria
close to __oom_reap_task on the other hand makes it easier to evaluate
their relevance. So I am not really convinced. I can move it if you feel
strongly about that, though.

> > [...]
> > > > +static void wake_oom_reaper(struct mm_struct *mm)
> > > > +{
> > > > +	struct mm_struct *old_mm;
> > > > +
> > > > +	if (!oom_reaper_th)
> > > > +		return;
> > > > +
> > > > +	/*
> > > > +	 * Pin the given mm. Use mm_count instead of mm_users because
> > > > +	 * we do not want to delay the address space tear down.
> > > > +	 */
> > > > +	atomic_inc(&mm->mm_count);
> > > > +
> > > > +	/*
> > > > +	 * Make sure that only a single mm is ever queued for the reaper
> > > > +	 * because multiple are not necessary and the operation might be
> > > > +	 * disruptive so better reduce it to the bare minimum.
> > > > +	 */
> > > > +	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
> > > > +	if (!old_mm)
> > > > +		wake_up(&oom_reaper_wait);
> > > > +	else
> > > > +		mmdrop(mm);
> > > 
> > > This behavior is probably the only really significant concern I have about 
> > > the patch: we just drop the mm and don't try any reaping if there is 
> > > already reaping in progress.
> > 
> > This is based on the assumption that OOM killer will not select another
> > task to kill until the previous one drops its TIF_MEMDIE. Should this
> > change in the future we will have to come up with a queuing mechanism. I
> > didn't want to do it right away to make the change as simple as
> > possible.
> > 
> 
> The problem is that this is racy and quite easy to trigger: imagine if 
> __oom_reap_vmas() finds mm->mm_users == 0, because the memory of the 
> victim has been freed, and then another system-wide oom condition occurs 
> before the oom reaper's mm_to_reap has been set to NULL.

Yes I realize this is potentially racy. I just didn't consider the race
important enough to justify task queuing in the first submission. Tetsuo
was pushing for this already and I tried to push back for simplicity in
the first submission. But ohh well... I will queue up a patch to do this
on top. I plan to repost the full patchset shortly.

> No synchronization prevents that from happening (not sure what the
> reference to TIF_MEMDIE is about).

Now that I am reading my response again I see how it could be
misleading. I was referring to possibility of choosing multiple oom
victims which was discussed recently. I didn't mean TIF_MEMDIE to exclude
oom reaper vs. exit exclusion.

> In this case, the oom reaper has ignored the next victim and doesn't do 
> anything; the simple race has prevented it from zapping memory and does 
> not reduce the livelock probability.
> 
> This can be solved either by queueing mm's to reap or involving the oom 
> reaper into the oom killer synchronization itself.

as we have already discussed previously oom reaper is really tricky to
be called from the direct OOM context. I will go with queuing. 
 
> > > > +static int __init oom_init(void)
> > > > +{
> > > > +	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> > > > +	if (IS_ERR(oom_reaper_th)) {
> > > > +		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> > > > +				PTR_ERR(oom_reaper_th));
> > > > +		oom_reaper_th = NULL;
> > > > +	} else {
> > > > +		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
> > > > +
> > > > +		/*
> > > > +		 * Make sure our oom reaper thread will get scheduled when
> > > > +		 * ASAP and that it won't get preempted by malicious userspace.
> > > > +		 */
> > > > +		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
> > > 
> > > Eeek, do you really show this is necessary?  I would imagine that we would 
> > > want to limit high priority processes system-wide and that we wouldn't 
> > > want to be interferred with by memcg oom conditions that trigger the oom 
> > > reaper, for example.
> > 
> > The idea was that we do not want to allow a high priority userspace to
> > preempt this important operation. I do understand your concern about the
> > memcg oom interference but I find it more important that oom_reaper is
> > runnable when needed. I guess that memcg oom heavy loads can change the
> > priority from userspace if necessary?
> > 
> 
> I'm baffled by any reference to "memcg oom heavy loads", I don't 
> understand this paragraph, sorry.  If a memcg is oom, we shouldn't be
> disrupting the global runqueue by running oom_reaper at a high priority.  
> The disruption itself is not only in first wakeup but also in how long the 
> reaper can run and when it is rescheduled: for a lot of memory this is 
> potentially long.  The reaper is best-effort, as the changelog indicates, 
> and we shouldn't have a reliance on this high priority: oom kill exiting 
> can't possibly be expected to be immediate.  This high priority should be 
> removed so memcg oom conditions are isolated and don't affect other loads.

If this is a concern then I would be tempted to simply disable oom
reaper for memcg oom altogether. For me it is much more important that
the reaper, even though a best effort, is guaranteed to schedule if
something goes terribly wrong on the machine.

Is this acceptable?

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
