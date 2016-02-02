Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id B38676B0009
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 22:02:09 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id uo6so94471657pac.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 19:02:09 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id a78si44818465pfj.116.2016.02.01.19.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 19:02:08 -0800 (PST)
Received: by mail-pa0-x231.google.com with SMTP id ho8so92765965pac.2
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 19:02:08 -0800 (PST)
Date: Mon, 1 Feb 2016 19:02:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
In-Reply-To: <20160128214247.GD621@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1602011843250.31751@chino.kir.corp.google.com>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org> <1452094975-551-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com> <20160128214247.GD621@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 28 Jan 2016, Michal Hocko wrote:

> [...]
> > > +static bool __oom_reap_vmas(struct mm_struct *mm)
> > > +{
> > > +	struct mmu_gather tlb;
> > > +	struct vm_area_struct *vma;
> > > +	struct zap_details details = {.check_swap_entries = true,
> > > +				      .ignore_dirty = true};
> > > +	bool ret = true;
> > > +
> > > +	/* We might have raced with exit path */
> > > +	if (!atomic_inc_not_zero(&mm->mm_users))
> > > +		return true;
> > > +
> > > +	if (!down_read_trylock(&mm->mmap_sem)) {
> > > +		ret = false;
> > > +		goto out;
> > > +	}
> > > +
> > > +	tlb_gather_mmu(&tlb, mm, 0, -1);
> > > +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > > +		if (is_vm_hugetlb_page(vma))
> > > +			continue;
> > > +
> > > +		/*
> > > +		 * mlocked VMAs require explicit munlocking before unmap.
> > > +		 * Let's keep it simple here and skip such VMAs.
> > > +		 */
> > > +		if (vma->vm_flags & VM_LOCKED)
> > > +			continue;
> > 
> > Shouldn't there be VM_PFNMAP handling here?
> 
> What would be the reason to exclude them?
> 

Not exclude them, but I would have expected untrack_pfn().

> > I'm wondering why zap_page_range() for vma->vm_start to vma->vm_end wasn't 
> > used here for simplicity?
> 
> I didn't use zap_page_range because I wanted to have a full control over
> what and how gets torn down. E.g. it is much more easier to skip over
> hugetlb pages than relying on i_mmap_lock_write which might be blocked
> and the whole oom_reaper will get stuck.
> 

Let me be clear that I think the implementation is fine, minus the missing 
handling for VM_PFNMAP.  However, I think this implementation is better 
placed into mm/memory.c to do the iteration, selection criteria, and then 
unmap_page_range().  I don't think we should be exposing 
unmap_page_range() globally, but rather add a new function to do the 
iteration in mm/memory.c with the others.

> [...]
> > > +static void wake_oom_reaper(struct mm_struct *mm)
> > > +{
> > > +	struct mm_struct *old_mm;
> > > +
> > > +	if (!oom_reaper_th)
> > > +		return;
> > > +
> > > +	/*
> > > +	 * Pin the given mm. Use mm_count instead of mm_users because
> > > +	 * we do not want to delay the address space tear down.
> > > +	 */
> > > +	atomic_inc(&mm->mm_count);
> > > +
> > > +	/*
> > > +	 * Make sure that only a single mm is ever queued for the reaper
> > > +	 * because multiple are not necessary and the operation might be
> > > +	 * disruptive so better reduce it to the bare minimum.
> > > +	 */
> > > +	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
> > > +	if (!old_mm)
> > > +		wake_up(&oom_reaper_wait);
> > > +	else
> > > +		mmdrop(mm);
> > 
> > This behavior is probably the only really significant concern I have about 
> > the patch: we just drop the mm and don't try any reaping if there is 
> > already reaping in progress.
> 
> This is based on the assumption that OOM killer will not select another
> task to kill until the previous one drops its TIF_MEMDIE. Should this
> change in the future we will have to come up with a queuing mechanism. I
> didn't want to do it right away to make the change as simple as
> possible.
> 

The problem is that this is racy and quite easy to trigger: imagine if 
__oom_reap_vmas() finds mm->mm_users == 0, because the memory of the 
victim has been freed, and then another system-wide oom condition occurs 
before the oom reaper's mm_to_reap has been set to NULL.  No 
synchronization prevents that from happening (not sure what the reference 
to TIF_MEMDIE is about).

In this case, the oom reaper has ignored the next victim and doesn't do 
anything; the simple race has prevented it from zapping memory and does 
not reduce the livelock probability.

This can be solved either by queueing mm's to reap or involving the oom 
reaper into the oom killer synchronization itself.

> > > +static int __init oom_init(void)
> > > +{
> > > +	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> > > +	if (IS_ERR(oom_reaper_th)) {
> > > +		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> > > +				PTR_ERR(oom_reaper_th));
> > > +		oom_reaper_th = NULL;
> > > +	} else {
> > > +		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
> > > +
> > > +		/*
> > > +		 * Make sure our oom reaper thread will get scheduled when
> > > +		 * ASAP and that it won't get preempted by malicious userspace.
> > > +		 */
> > > +		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
> > 
> > Eeek, do you really show this is necessary?  I would imagine that we would 
> > want to limit high priority processes system-wide and that we wouldn't 
> > want to be interferred with by memcg oom conditions that trigger the oom 
> > reaper, for example.
> 
> The idea was that we do not want to allow a high priority userspace to
> preempt this important operation. I do understand your concern about the
> memcg oom interference but I find it more important that oom_reaper is
> runnable when needed. I guess that memcg oom heavy loads can change the
> priority from userspace if necessary?
> 

I'm baffled by any reference to "memcg oom heavy loads", I don't 
understand this paragraph, sorry.  If a memcg is oom, we shouldn't be
disrupting the global runqueue by running oom_reaper at a high priority.  
The disruption itself is not only in first wakeup but also in how long the 
reaper can run and when it is rescheduled: for a lot of memory this is 
potentially long.  The reaper is best-effort, as the changelog indicates, 
and we shouldn't have a reliance on this high priority: oom kill exiting 
can't possibly be expected to be immediate.  This high priority should be 
removed so memcg oom conditions are isolated and don't affect other loads.

"Memcg oom heavy loads" cannot always be determined and the suggested fix 
cannot possibly be to adjust the priority of a global resource.  ??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
