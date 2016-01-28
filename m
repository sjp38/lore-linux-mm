Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1F56B0254
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 20:28:15 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id x125so14297835pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 17:28:15 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id pz7si6275314pab.216.2016.01.27.17.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 17:28:13 -0800 (PST)
Received: by mail-pa0-x231.google.com with SMTP id ho8so13797059pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 17:28:13 -0800 (PST)
Date: Wed, 27 Jan 2016 17:28:10 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
In-Reply-To: <1452094975-551-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1601271651530.17979@chino.kir.corp.google.com>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org> <1452094975-551-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 6 Jan 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> independently brought up by Oleg Nesterov.
> 

Suggested-bys?

> The OOM killer currently allows to kill only a single task in a good
> hope that the task will terminate in a reasonable time and frees up its
> memory.  Such a task (oom victim) will get an access to memory reserves
> via mark_oom_victim to allow a forward progress should there be a need
> for additional memory during exit path.
> 
> It has been shown (e.g. by Tetsuo Handa) that it is not that hard to
> construct workloads which break the core assumption mentioned above and
> the OOM victim might take unbounded amount of time to exit because it
> might be blocked in the uninterruptible state waiting for on an event
> (e.g. lock) which is blocked by another task looping in the page
> allocator.
> 

s/for on/for/

I think it would be good to note in either of the two paragraphs above 
that each victim is per-memcg hierarchy or system-wide and the oom reaper 
is used for memcg oom conditions as well.  Otherwise, there's no mention 
of the memcg usecase.

> This patch reduces the probability of such a lockup by introducing a
> specialized kernel thread (oom_reaper) which tries to reclaim additional
> memory by preemptively reaping the anonymous or swapped out memory
> owned by the oom victim under an assumption that such a memory won't
> be needed when its owner is killed and kicked from the userspace anyway.
> There is one notable exception to this, though, if the OOM victim was
> in the process of coredumping the result would be incomplete. This is
> considered a reasonable constrain because the overall system health is
> more important than debugability of a particular application.
> 
> A kernel thread has been chosen because we need a reliable way of
> invocation so workqueue context is not appropriate because all the
> workers might be busy (e.g. allocating memory). Kswapd which sounds
> like another good fit is not appropriate as well because it might get
> blocked on locks during reclaim as well.
> 

Very good points.  And I think this makes the case clear that oom_reaper 
is really a best-effort solution.

> oom_reaper has to take mmap_sem on the target task for reading so the
> solution is not 100% because the semaphore might be held or blocked for
> write but the probability is reduced considerably wrt. basically any
> lock blocking forward progress as described above. In order to prevent
> from blocking on the lock without any forward progress we are using only
> a trylock and retry 10 times with a short sleep in between.
> Users of mmap_sem which need it for write should be carefully reviewed
> to use _killable waiting as much as possible and reduce allocations
> requests done with the lock held to absolute minimum to reduce the risk
> even further.
> 
> The API between oom killer and oom reaper is quite trivial. wake_oom_reaper
> updates mm_to_reap with cmpxchg to guarantee only NULL->mm transition
> and oom_reaper clear this atomically once it is done with the work. This
> means that only a single mm_struct can be reaped at the time. As the
> operation is potentially disruptive we are trying to limit it to the
> ncessary minimum and the reaper blocks any updates while it operates on
> an mm. mm_struct is pinned by mm_count to allow parallel exit_mmap and a
> race is detected by atomic_inc_not_zero(mm_users).
> 
> Changes since v3
> - many style/compile fixups by Andrew
> - unmap_mapping_range_tree needs full initialization of zap_details
>   to prevent from missing unmaps and follow up BUG_ON during truncate
>   resp. misaccounting - Kirill/Andrew
> - exclude mlocked pages because they need an explicit munlock by Kirill
> - use subsys_initcall instead of module_init - Paul Gortmaker
> Changes since v2
> - fix mm_count refernce leak reported by Tetsuo
> - make sure oom_reaper_th is NULL after kthread_run fails - Tetsuo
> - use wait_event_freezable rather than open coded wait loop - suggested
>   by Tetsuo
> Changes since v1
> - fix the screwed up detail->check_swap_entries - Johannes
> - do not use kthread_should_stop because that would need a cleanup
>   and we do not have anybody to stop us - Tetsuo
> - move wake_oom_reaper to oom_kill_process because we have to wait
>   for all tasks sharing the same mm to get killed - Tetsuo
> - do not reap mm structs which are shared with unkillable tasks - Tetsuo
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mm.h |   2 +
>  mm/internal.h      |   5 ++
>  mm/memory.c        |  17 +++---
>  mm/oom_kill.c      | 157 +++++++++++++++++++++++++++++++++++++++++++++++++++--
>  4 files changed, 170 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 25cdec395f2c..d1ce03569942 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1061,6 +1061,8 @@ struct zap_details {
>  	struct address_space *check_mapping;	/* Check page->mapping if set */
>  	pgoff_t	first_index;			/* Lowest page->index to unmap */
>  	pgoff_t last_index;			/* Highest page->index to unmap */
> +	bool ignore_dirty;			/* Ignore dirty pages */
> +	bool check_swap_entries;		/* Check also swap entries */
>  };
>  
>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/mm/internal.h b/mm/internal.h
> index 4ae7b7c7462b..9006ce1960ff 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -41,6 +41,11 @@ extern int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>  		unsigned long floor, unsigned long ceiling);
>  
> +void unmap_page_range(struct mmu_gather *tlb,
> +			     struct vm_area_struct *vma,
> +			     unsigned long addr, unsigned long end,
> +			     struct zap_details *details);
> +
>  static inline void set_page_count(struct page *page, int v)
>  {
>  	atomic_set(&page->_count, v);
> diff --git a/mm/memory.c b/mm/memory.c
> index f5b8e8c9f4c3..f60c6d6aa633 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1104,6 +1104,12 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  
>  			if (!PageAnon(page)) {
>  				if (pte_dirty(ptent)) {
> +					/*
> +					 * oom_reaper cannot tear down dirty
> +					 * pages
> +					 */
> +					if (unlikely(details && details->ignore_dirty))
> +						continue;
>  					force_flush = 1;
>  					set_page_dirty(page);
>  				}
> @@ -1122,8 +1128,8 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  			}
>  			continue;
>  		}
> -		/* If details->check_mapping, we leave swap entries. */
> -		if (unlikely(details))
> +		/* only check swap_entries if explicitly asked for in details */
> +		if (unlikely(details && !details->check_swap_entries))
>  			continue;
>  
>  		entry = pte_to_swp_entry(ptent);
> @@ -1228,7 +1234,7 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
>  	return addr;
>  }
>  
> -static void unmap_page_range(struct mmu_gather *tlb,
> +void unmap_page_range(struct mmu_gather *tlb,
>  			     struct vm_area_struct *vma,
>  			     unsigned long addr, unsigned long end,
>  			     struct zap_details *details)
> @@ -1236,9 +1242,6 @@ static void unmap_page_range(struct mmu_gather *tlb,
>  	pgd_t *pgd;
>  	unsigned long next;
>  
> -	if (details && !details->check_mapping)
> -		details = NULL;
> -
>  	BUG_ON(addr >= end);
>  	tlb_start_vma(tlb, vma);
>  	pgd = pgd_offset(vma->vm_mm, addr);
> @@ -2393,7 +2396,7 @@ static inline void unmap_mapping_range_tree(struct rb_root *root,
>  void unmap_mapping_range(struct address_space *mapping,
>  		loff_t const holebegin, loff_t const holelen, int even_cows)
>  {
> -	struct zap_details details;
> +	struct zap_details details = { };
>  	pgoff_t hba = holebegin >> PAGE_SHIFT;
>  	pgoff_t hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dc490c06941b..1ece40b94725 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -35,6 +35,11 @@
>  #include <linux/freezer.h>
>  #include <linux/ftrace.h>
>  #include <linux/ratelimit.h>
> +#include <linux/kthread.h>
> +#include <linux/init.h>
> +
> +#include <asm/tlb.h>
> +#include "internal.h"
>  
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/oom.h>
> @@ -408,6 +413,141 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
>  
>  bool oom_killer_disabled __read_mostly;
>  
> +#ifdef CONFIG_MMU
> +/*
> + * OOM Reaper kernel thread which tries to reap the memory used by the OOM
> + * victim (if that is possible) to help the OOM killer to move on.
> + */
> +static struct task_struct *oom_reaper_th;
> +static struct mm_struct *mm_to_reap;
> +static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
> +
> +static bool __oom_reap_vmas(struct mm_struct *mm)
> +{
> +	struct mmu_gather tlb;
> +	struct vm_area_struct *vma;
> +	struct zap_details details = {.check_swap_entries = true,
> +				      .ignore_dirty = true};
> +	bool ret = true;
> +
> +	/* We might have raced with exit path */
> +	if (!atomic_inc_not_zero(&mm->mm_users))
> +		return true;
> +
> +	if (!down_read_trylock(&mm->mmap_sem)) {
> +		ret = false;
> +		goto out;
> +	}
> +
> +	tlb_gather_mmu(&tlb, mm, 0, -1);
> +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> +		if (is_vm_hugetlb_page(vma))
> +			continue;
> +
> +		/*
> +		 * mlocked VMAs require explicit munlocking before unmap.
> +		 * Let's keep it simple here and skip such VMAs.
> +		 */
> +		if (vma->vm_flags & VM_LOCKED)
> +			continue;

Shouldn't there be VM_PFNMAP handling here?

I'm wondering why zap_page_range() for vma->vm_start to vma->vm_end wasn't 
used here for simplicity?  It appears as though what you're doing is an 
MADV_DONTNEED over the length of all anonymous vmas that aren't shared, so 
why not have such an implementation in a single place so any changes don't 
have to be made in two different spots for things such as VM_PFNMAP?

> +
> +		/*
> +		 * Only anonymous pages have a good chance to be dropped
> +		 * without additional steps which we cannot afford as we
> +		 * are OOM already.
> +		 *
> +		 * We do not even care about fs backed pages because all
> +		 * which are reclaimable have already been reclaimed and
> +		 * we do not want to block exit_mmap by keeping mm ref
> +		 * count elevated without a good reason.
> +		 */
> +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> +			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> +					 &details);
> +	}
> +	tlb_finish_mmu(&tlb, 0, -1);
> +	up_read(&mm->mmap_sem);
> +out:
> +	mmput(mm);
> +	return ret;
> +}
> +
> +static void oom_reap_vmas(struct mm_struct *mm)
> +{
> +	int attempts = 0;
> +
> +	/* Retry the down_read_trylock(mmap_sem) a few times */
> +	while (attempts++ < 10 && !__oom_reap_vmas(mm))
> +		schedule_timeout_idle(HZ/10);
> +
> +	/* Drop a reference taken by wake_oom_reaper */
> +	mmdrop(mm);
> +}
> +
> +static int oom_reaper(void *unused)
> +{
> +	while (true) {
> +		struct mm_struct *mm;
> +
> +		wait_event_freezable(oom_reaper_wait,
> +				     (mm = READ_ONCE(mm_to_reap)));
> +		oom_reap_vmas(mm);
> +		WRITE_ONCE(mm_to_reap, NULL);
> +	}
> +
> +	return 0;
> +}
> +
> +static void wake_oom_reaper(struct mm_struct *mm)
> +{
> +	struct mm_struct *old_mm;
> +
> +	if (!oom_reaper_th)
> +		return;
> +
> +	/*
> +	 * Pin the given mm. Use mm_count instead of mm_users because
> +	 * we do not want to delay the address space tear down.
> +	 */
> +	atomic_inc(&mm->mm_count);
> +
> +	/*
> +	 * Make sure that only a single mm is ever queued for the reaper
> +	 * because multiple are not necessary and the operation might be
> +	 * disruptive so better reduce it to the bare minimum.
> +	 */
> +	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
> +	if (!old_mm)
> +		wake_up(&oom_reaper_wait);
> +	else
> +		mmdrop(mm);

This behavior is probably the only really significant concern I have about 
the patch: we just drop the mm and don't try any reaping if there is 
already reaping in progress.

We don't always have control over the amount of memory that can be reaped 
from the victim, either because of oom kill prioritization through 
/proc/pid/oom_score_adj or because the memory of the victim is not 
eligible.

I'm imagining a scenario where the oom reaper has raced with a follow-up 
oom kill before mm_to_reap has been set to NULL so there's no subsequent 
reaping.  It's also possible that oom reaping of the first victim actually 
freed little memory.

Would it really be difficult to queue mm's to reap from?  If memory has 
already been freed before the reaper can get to it, the 
find_lock_task_mm() should just fail and we're done.  I'm not sure why 
this is being limited to a single mm system-wide.

> +}
> +
> +static int __init oom_init(void)
> +{
> +	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> +	if (IS_ERR(oom_reaper_th)) {
> +		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> +				PTR_ERR(oom_reaper_th));
> +		oom_reaper_th = NULL;
> +	} else {
> +		struct sched_param param = { .sched_priority = MAX_RT_PRIO-1 };
> +
> +		/*
> +		 * Make sure our oom reaper thread will get scheduled when
> +		 * ASAP and that it won't get preempted by malicious userspace.
> +		 */
> +		sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);

Eeek, do you really show this is necessary?  I would imagine that we would 
want to limit high priority processes system-wide and that we wouldn't 
want to be interferred with by memcg oom conditions that trigger the oom 
reaper, for example.

> +	}
> +	return 0;
> +}
> +subsys_initcall(oom_init)
> +#else
> +static void wake_oom_reaper(struct mm_struct *mm)
> +{
> +}
> +#endif
> +
>  /**
>   * mark_oom_victim - mark the given task as OOM victim
>   * @tsk: task to mark
> @@ -517,6 +657,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> +	bool can_oom_reap = true;
>  
>  	/*
>  	 * If the task is already exiting, don't alarm the sysadmin or kill
> @@ -607,17 +748,25 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
> -		if (unlikely(p->flags & PF_KTHREAD))
> -			continue;
>  		if (is_global_init(p))
>  			continue;
> -		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +		if (unlikely(p->flags & PF_KTHREAD) ||
> +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +			/*
> +			 * We cannot use oom_reaper for the mm shared by this
> +			 * process because it wouldn't get killed and so the
> +			 * memory might be still used.
> +			 */
> +			can_oom_reap = false;
>  			continue;
> -
> +		}
>  		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);

Is it possible to just do wake_oom_reaper(mm) here and eliminate 
can_oom_reap with a little bit of moving around?

>  	}
>  	rcu_read_unlock();
>  
> +	if (can_oom_reap)
> +		wake_oom_reaper(mm);
> +
>  	mmdrop(mm);
>  	put_task_struct(victim);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
