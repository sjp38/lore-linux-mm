Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65FEA6B0005
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 19:19:12 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id d23-v6so2168932uap.19
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 16:19:12 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l128-v6sor2516356vkb.112.2018.06.28.16.19.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 16:19:10 -0700 (PDT)
Date: Thu, 28 Jun 2018 16:19:07 -0700
In-Reply-To: <20180628151101.25307-1-mhocko@kernel.org>
Message-Id: <xr93in62jy8k.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <20180628151101.25307-1-mhocko@kernel.org>
Subject: Re: [PATCH] memcg, oom: move out_of_memory back to the charge path
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
>
> 3812c8c8f395 ("mm: memcg: do not trap chargers with full callstack on OOM")
> has changed the ENOMEM semantic of memcg charges. Rather than invoking
> the oom killer from the charging context it delays the oom killer to the
> page fault path (pagefault_out_of_memory). This in turn means that many
> users (e.g. slab or g-u-p) will get ENOMEM when the corresponding memcg
> hits the hard limit and the memcg is is OOM. This is behavior is
> inconsistent with !memcg case where the oom killer is invoked from the
> allocation context and the allocator keeps retrying until it succeeds.
>
> The difference in the behavior is user visible. mmap(MAP_POPULATE) might
> result in not fully populated ranges while the mmap return code doesn't
> tell that to the userspace. Random syscalls might fail with ENOMEM etc.
>
> The primary motivation of the different memcg oom semantic was the
> deadlock avoidance. Things have changed since then, though. We have
> an async oom teardown by the oom reaper now and so we do not have to
> rely on the victim to tear down its memory anymore. Therefore we can
> return to the original semantic as long as the memcg oom killer is not
> handed over to the users space.
>
> There is still one thing to be careful about here though. If the oom
> killer is not able to make any forward progress - e.g. because there is
> no eligible task to kill - then we have to bail out of the charge path
> to prevent from same class of deadlocks. We have basically two options
> here. Either we fail the charge with ENOMEM or force the charge and
> allow overcharge. The first option has been considered more harmful than
> useful because rare inconsistencies in the ENOMEM behavior is hard to
> test for and error prone. Basically the same reason why the page
> allocator doesn't fail allocations under such conditions. The later
> might allow runaways but those should be really unlikely unless somebody
> misconfigures the system. E.g. allowing to migrate tasks away from the
> memcg to a different unlimited memcg with move_charge_at_immigrate
> disabled.
>
> Changes since rfc v1
> - s@memcg_may_oom@in_user_fault@ suggested by Johannes. It is much more
>   clear what is the purpose of the flag now
> - s@mem_cgroup_oom_enable@mem_cgroup_enter_user_fault@g
>   s@mem_cgroup_oom_disable@mem_cgroup_exit_user_fault@g as per Johannes
> - make oom_kill_disable an exceptional case because it should be rare
>   and the normal oom handling a core of the function - per Johannes
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Greg Thelen <gthelen@google.com>

Thanks!  One comment below.

> ---
>
> Hi,
> I've posted this as an RFC previously [1]. There was no fundamental
> disagreement so I've integrated all the suggested changes and tested it.
> mmap(MAP_POPULATE) hits the oom killer again rather than silently fails
> to populate the mapping on the hard limit excess. On the other hand
> g-u-p and other charge path keep the ENOMEM semantic when the memcg oom
> killer is disabled. All the forward progress guarantee relies on the oom
> reaper.
>
> Unless there are objections I think this is ready to go to mmotm and
> ready for the next merge window
>
> [1] http://lkml.kernel.org/r/20180620103736.13880-1-mhocko@kernel.org
>  include/linux/memcontrol.h | 16 ++++----
>  include/linux/sched.h      |  2 +-
>  mm/memcontrol.c            | 75 ++++++++++++++++++++++++++++++--------
>  mm/memory.c                |  4 +-
>  4 files changed, 71 insertions(+), 26 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6c6fb116e925..5a69bb4026f6 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -494,16 +494,16 @@ unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
>  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  				struct task_struct *p);
>  
> -static inline void mem_cgroup_oom_enable(void)
> +static inline void mem_cgroup_enter_user_fault(void)
>  {
> -	WARN_ON(current->memcg_may_oom);
> -	current->memcg_may_oom = 1;
> +	WARN_ON(current->in_user_fault);
> +	current->in_user_fault = 1;
>  }
>  
> -static inline void mem_cgroup_oom_disable(void)
> +static inline void mem_cgroup_exit_user_fault(void)
>  {
> -	WARN_ON(!current->memcg_may_oom);
> -	current->memcg_may_oom = 0;
> +	WARN_ON(!current->in_user_fault);
> +	current->in_user_fault = 0;
>  }
>  
>  static inline bool task_in_memcg_oom(struct task_struct *p)
> @@ -924,11 +924,11 @@ static inline void mem_cgroup_handle_over_high(void)
>  {
>  }
>  
> -static inline void mem_cgroup_oom_enable(void)
> +static inline void mem_cgroup_enter_user_fault(void)
>  {
>  }
>  
> -static inline void mem_cgroup_oom_disable(void)
> +static inline void mem_cgroup_exit_user_fault(void)
>  {
>  }
>  
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 87bf02d93a27..34cc95b751cd 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -722,7 +722,7 @@ struct task_struct {
>  	unsigned			restore_sigmask:1;
>  #endif
>  #ifdef CONFIG_MEMCG
> -	unsigned			memcg_may_oom:1;
> +	unsigned			in_user_fault:1;
>  #ifndef CONFIG_SLOB
>  	unsigned			memcg_kmem_skip_account:1;
>  #endif
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e6f0d5ef320a..cff6c75137c1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1483,28 +1483,53 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
>  		__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
>  }
>  
> -static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> +enum oom_status {
> +	OOM_SUCCESS,
> +	OOM_FAILED,
> +	OOM_ASYNC,
> +	OOM_SKIPPED
> +};
> +
> +static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  {
> -	if (!current->memcg_may_oom || order > PAGE_ALLOC_COSTLY_ORDER)
> -		return;
> +	if (order > PAGE_ALLOC_COSTLY_ORDER)
> +		return OOM_SKIPPED;
> +
>  	/*
>  	 * We are in the middle of the charge context here, so we
>  	 * don't want to block when potentially sitting on a callstack
>  	 * that holds all kinds of filesystem and mm locks.
>  	 *
> -	 * Also, the caller may handle a failed allocation gracefully
> -	 * (like optional page cache readahead) and so an OOM killer
> -	 * invocation might not even be necessary.
> +	 * cgroup1 allows disabling the OOM killer and waiting for outside
> +	 * handling until the charge can succeed; remember the context and put
> +	 * the task to sleep at the end of the page fault when all locks are
> +	 * released.
> +	 *
> +	 * On the other hand, in-kernel OOM killer allows for an async victim
> +	 * memory reclaim (oom_reaper) and that means that we are not solely
> +	 * relying on the oom victim to make a forward progress and we can
> +	 * invoke the oom killer here.
>  	 *
> -	 * That's why we don't do anything here except remember the
> -	 * OOM context and then deal with it at the end of the page
> -	 * fault when the stack is unwound, the locks are released,
> -	 * and when we know whether the fault was overall successful.
> +	 * Please note that mem_cgroup_out_of_memory might fail to find a
> +	 * victim and then we have to bail out from the charge path.
>  	 */
> -	css_get(&memcg->css);
> -	current->memcg_in_oom = memcg;
> -	current->memcg_oom_gfp_mask = mask;
> -	current->memcg_oom_order = order;
> +	if (memcg->oom_kill_disable) {
> +		if (!current->in_user_fault)
> +			return OOM_SKIPPED;
> +		css_get(&memcg->css);
> +		current->memcg_in_oom = memcg;
> +		current->memcg_oom_gfp_mask = mask;
> +		current->memcg_oom_order = order;
> +
> +		return OOM_ASYNC;
> +	}
> +
> +	if (mem_cgroup_out_of_memory(memcg, mask, order))
> +		return OOM_SUCCESS;
> +
> +	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> +		"This looks like a misconfiguration or a kernel bug.");

I'm not sure here if the warning should here or so strongly worded.  It
seems like the current task could be oom reaped with MMF_OOM_SKIP and
thus mem_cgroup_out_of_memory() will return false.  So there's nothing
alarming in that case.

> +	return OOM_FAILED;
>  }
>  
>  /**
> @@ -1899,6 +1924,8 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	unsigned long nr_reclaimed;
>  	bool may_swap = true;
>  	bool drained = false;
> +	bool oomed = false;
> +	enum oom_status oom_status;
>  
>  	if (mem_cgroup_is_root(memcg))
>  		return 0;
> @@ -1986,6 +2013,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (nr_retries--)
>  		goto retry;
>  
> +	if (gfp_mask & __GFP_RETRY_MAYFAIL && oomed)
> +		goto nomem;
> +
>  	if (gfp_mask & __GFP_NOFAIL)
>  		goto force;
>  
> @@ -1994,8 +2024,23 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  
>  	memcg_memory_event(mem_over_limit, MEMCG_OOM);
>  
> -	mem_cgroup_oom(mem_over_limit, gfp_mask,
> +	/*
> +	 * keep retrying as long as the memcg oom killer is able to make
> +	 * a forward progress or bypass the charge if the oom killer
> +	 * couldn't make any progress.
> +	 */
> +	oom_status = mem_cgroup_oom(mem_over_limit, gfp_mask,
>  		       get_order(nr_pages * PAGE_SIZE));
> +	switch (oom_status) {
> +	case OOM_SUCCESS:
> +		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> +		oomed = true;
> +		goto retry;
> +	case OOM_FAILED:
> +		goto force;
> +	default:
> +		goto nomem;
> +	}
>  nomem:
>  	if (!(gfp_mask & __GFP_NOFAIL))
>  		return -ENOMEM;
> diff --git a/mm/memory.c b/mm/memory.c
> index 7206a634270b..a4b1f8c24884 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4125,7 +4125,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  	 * space.  Kernel faults are handled more gracefully.
>  	 */
>  	if (flags & FAULT_FLAG_USER)
> -		mem_cgroup_oom_enable();
> +		mem_cgroup_enter_user_fault();
>  
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
> @@ -4133,7 +4133,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  		ret = __handle_mm_fault(vma, address, flags);
>  
>  	if (flags & FAULT_FLAG_USER) {
> -		mem_cgroup_oom_disable();
> +		mem_cgroup_exit_user_fault();
>  		/*
>  		 * The task may have entered a memcg OOM situation but
>  		 * if the allocation error was handled gracefully (no
