Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 642CA6B0255
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 13:13:26 -0400 (EDT)
Received: by wicfv10 with SMTP id fv10so17806568wic.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:13:26 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id ll6si6097615wjc.25.2015.08.28.10.13.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 10:13:24 -0700 (PDT)
Received: by wiae7 with SMTP id e7so2913225wia.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 10:13:24 -0700 (PDT)
Date: Fri, 28 Aug 2015 19:13:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828171322.GC21463@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440775530-18630-4-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Fri 28-08-15 11:25:29, Tejun Heo wrote:
> Currently, try_charge() tries to reclaim memory directly when the high
> limit is breached; however, this has a couple issues.
> 
> * try_charge() can be invoked from any in-kernel allocation site and
>   reclaim path may use considerable amount of stack.  This can lead to
>   stack overflows which are extremely difficult to reproduce.

This is true but I haven't seen any reports for the stack overflow for
quite some time.
 
> * If the allocation doesn't have __GFP_WAIT, direct reclaim is
>   skipped.  If a process performs only speculative allocations, it can
>   blow way past the high limit.  This is actually easily reproducible
>   by simply doing "find /".  VFS tries speculative !__GFP_WAIT
>   allocations first, so as long as there's memory which can be
>   consumed without blocking, it can keep allocating memory regardless
>   of the high limit.

It is a bit confusing that you are talking about direct reclaim but in
fact mean high limit reclaim. But yeah, you are right there is no
protection against GFP_NOWAIT allocations there.

> This patch makes try_charge() always punt the direct reclaim to the
> return-to-userland path.  If try_charge() detects that high limit is
> breached, it sets current->memcg_over_high to the offending memcg and
> schedules execution of mem_cgroup_handle_over_high() which performs
> the direct reclaim from the return-to-userland path.

OK, this is certainly an attractive idea because of allocation requests
with reduced reclaim capabilities. GFP_NOWAIT is not the only one.
GFP_NOFS would be another. With kmem accounting they are much bigger
problem than with regular page faults/page cache. And having full
GFP_KERNEL reclaim context is definitely nice.
I would just argue that this implementation has the same issue as the
other patch in the series which performs high-usage reclaim. I think
that each task should reclaim only its contribution which is trivial
to account.
 
> As long as kernel doesn't have a run-away allocation spree, this
> should provide enough protection while making kmemcg behave more
> consistently.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> ---
>  include/linux/memcontrol.h |  6 +++++
>  include/linux/sched.h      |  1 +
>  include/linux/tracehook.h  |  3 +++
>  mm/memcontrol.c            | 66 +++++++++++++++++++++++++++++++++++++---------
>  4 files changed, 64 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 3d28656..8d345a7 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -402,6 +402,8 @@ static inline int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
>  	return inactive * inactive_ratio < active;
>  }
>  
> +void mem_cgroup_handle_over_high(void);
> +
>  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  				struct task_struct *p);
>  
> @@ -621,6 +623,10 @@ static inline void mem_cgroup_end_page_stat(struct mem_cgroup *memcg)
>  {
>  }
>  
> +static inline void mem_cgroup_handle_over_high(void)
> +{
> +}
> +
>  static inline void mem_cgroup_oom_enable(void)
>  {
>  }
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index ef73b54..c76b71d 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1785,6 +1785,7 @@ struct task_struct {
>  #endif /* CONFIG_TRACING */
>  #ifdef CONFIG_MEMCG
>  	struct mem_cgroup *memcg_in_oom;
> +	struct mem_cgroup *memcg_over_high; /* reclaim on returning to user */
>  	gfp_t memcg_oom_gfp_mask;
>  	int memcg_oom_order;
>  #endif
> diff --git a/include/linux/tracehook.h b/include/linux/tracehook.h
> index 84d4972..26c1521 100644
> --- a/include/linux/tracehook.h
> +++ b/include/linux/tracehook.h
> @@ -50,6 +50,7 @@
>  #include <linux/ptrace.h>
>  #include <linux/security.h>
>  #include <linux/task_work.h>
> +#include <linux/memcontrol.h>
>  struct linux_binprm;
>  
>  /*
> @@ -188,6 +189,8 @@ static inline void tracehook_notify_resume(struct pt_regs *regs)
>  	smp_mb__after_atomic();
>  	if (unlikely(current->task_works))
>  		task_work_run();
> +
> +	mem_cgroup_handle_over_high();
>  }
>  
>  #endif	/* <linux/tracehook.h> */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 74abb31..c94b686 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -62,6 +62,7 @@
>  #include <linux/oom.h>
>  #include <linux/lockdep.h>
>  #include <linux/file.h>
> +#include <linux/tracehook.h>
>  #include "internal.h"
>  #include <net/sock.h>
>  #include <net/ip.h>
> @@ -1963,6 +1964,33 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
>  	return NOTIFY_OK;
>  }
>  
> +/*
> + * Scheduled by try_charge() to be executed from the userland return path
> + * and reclaims memory over the high limit.
> + */
> +void mem_cgroup_handle_over_high(void)
> +{
> +	struct mem_cgroup *memcg = current->memcg_over_high;
> +
> +	if (likely(!memcg))
> +		return;
> +
> +	do {
> +		unsigned long usage = page_counter_read(&memcg->memory);
> +		unsigned long high = ACCESS_ONCE(memcg->high);
> +
> +		if (usage <= high)
> +			continue;
> +
> +		mem_cgroup_events(memcg, MEMCG_HIGH, 1);
> +		try_to_free_mem_cgroup_pages(memcg, usage - high,
> +					     GFP_KERNEL, true);
> +	} while ((memcg = parent_mem_cgroup(memcg)));
> +
> +	css_put(&current->memcg_over_high->css);
> +	current->memcg_over_high = NULL;
> +}
> +
>  static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		      unsigned int nr_pages)
>  {
> @@ -2071,21 +2099,27 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	css_get_many(&memcg->css, batch);
>  	if (batch > nr_pages)
>  		refill_stock(memcg, batch - nr_pages);
> -	if (!(gfp_mask & __GFP_WAIT))
> -		goto done;
> +
>  	/*
> -	 * If the hierarchy is above the normal consumption range,
> -	 * make the charging task trim their excess contribution.
> +	 * If the hierarchy is above the normal consumption range, schedule
> +	 * direct reclaim on returning to userland.  We can perform direct
> +	 * reclaim here if __GFP_WAIT; however, punting has the benefit of
> +	 * avoiding surprise high stack usages and it's fine to breach the
> +	 * high limit temporarily while control stays in kernel.
>  	 */
> -	do {
> -		unsigned long usage = page_counter_read(&memcg->memory);
> -		unsigned long high = ACCESS_ONCE(memcg->high);
> +	if (!current->memcg_over_high) {
> +		struct mem_cgroup *pos = memcg;
>  
> -		if (usage <= high)
> -			continue;
> -		mem_cgroup_events(memcg, MEMCG_HIGH, 1);
> -		try_to_free_mem_cgroup_pages(memcg, high - usage, gfp_mask, true);
> -	} while ((memcg = parent_mem_cgroup(memcg)));
> +		do {
> +			if (page_counter_read(&pos->memory) > pos->high) {
> +				/* make user return path rescan from leaf */
> +				css_get(&memcg->css);
> +				current->memcg_over_high = memcg;
> +				set_notify_resume(current);
> +				break;
> +			}
> +		} while ((pos = parent_mem_cgroup(pos)));
> +	}
>  done:
>  	return ret;
>  }
> @@ -5053,6 +5087,13 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
>  }
>  #endif
>  
> +static void mem_cgroup_exit(struct cgroup_subsys_state *css,
> +			    struct cgroup_subsys_state *old_css,
> +			    struct task_struct *task)
> +{
> +	mem_cgroup_handle_over_high();
> +}
> +
>  /*
>   * Cgroup retains root cgroups across [un]mount cycles making it necessary
>   * to verify whether we're attached to the default hierarchy on each mount
> @@ -5223,6 +5264,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
>  	.can_attach = mem_cgroup_can_attach,
>  	.cancel_attach = mem_cgroup_cancel_attach,
>  	.attach = mem_cgroup_move_task,
> +	.exit = mem_cgroup_exit,
>  	.bind = mem_cgroup_bind,
>  	.dfl_cftypes = memory_files,
>  	.legacy_cftypes = mem_cgroup_legacy_files,
> -- 
> 2.4.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
