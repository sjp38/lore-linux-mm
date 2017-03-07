Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 33B136B0387
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 08:34:54 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c143so1373731wmd.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 05:34:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 47si66469wrc.11.2017.03.07.05.34.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 05:34:52 -0800 (PST)
Subject: Re: [PATCH] mm: move pcp and lru-pcp drainging into single wq
References: <20170307131751.24936-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ab30b081-4829-c64a-e341-7f35d7096cb7@suse.cz>
Date: Tue, 7 Mar 2017 14:34:51 +0100
MIME-Version: 1.0
In-Reply-To: <20170307131751.24936-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 03/07/2017 02:17 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
> vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
> per cpu lru caches. This seems more than necessary because both can run
> on a single WQ. Both do not block on locks requiring a memory allocation
> nor perform any allocations themselves. We will save one rescuer thread
> this way.
> 
> On the other hand drain_all_pages() queues work on the system wq which
> doesn't have rescuer and so this depend on memory allocation (when all
> workers are stuck allocating and new ones cannot be created). This is
> not critical as there should be somebody invoking the OOM killer (e.g.
> the forking worker) and get the situation unstuck and eventually
> performs the draining. Quite annoying though. This worker should be
> using WQ_RECLAIM as well. We can reuse the same one as for lru draining
> and vmstat.
> 
> Changes since v1
> - rename vmstat_wq to mm_percpu_wq - per Mel
> - make sure we are not trying to enqueue anything while the WQ hasn't
>   been intialized yet. This shouldn't happen because the initialization
>   is done from an init code but some init section might be triggering
>   those paths indirectly so just warn and skip the draining in that case
>   per Vlastimil
> - do not propagate error from setup_vmstat to keep the previous behavior
>   per Mel
> 
> Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> 
> Hi,
> this has been previous posted [1] as an RFC. There was no fundamental
> opposition and some minor comments are addressed in this patch I
> believe.
> 
> To remind the original motivation, Tetsuo has noted that drain_all_pages
> doesn't use WQ_RECLAIM [1] and asked whether we can move the worker to
> the vmstat_wq which is WQ_RECLAIM. I think the deadlock he has described
> shouldn't happen but it would be really better to have the rescuer. I
> also think that we do not really need 2 or more workqueues and also pull
> lru draining in.
> 
> [1] http://lkml.kernel.org/r/20170207210908.530-1-mhocko@kernel.org
> 
>  mm/internal.h   |  7 +++++++
>  mm/page_alloc.c |  9 ++++++++-
>  mm/swap.c       | 27 ++++++++-------------------
>  mm/vmstat.c     | 14 ++++++++------
>  4 files changed, 31 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 823a7a89099b..04d08ef91224 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -486,6 +486,13 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  enum ttu_flags;
>  struct tlbflush_unmap_batch;
>  
> +
> +/*
> + * only for MM internal work items which do not depend on
> + * any allocations or locks which might depend on allocations
> + */
> +extern struct workqueue_struct *mm_percpu_wq;
> +
>  #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
>  void try_to_unmap_flush(void);
>  void try_to_unmap_flush_dirty(void);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1c72dd91c82e..1aa5729c8f98 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2362,6 +2362,13 @@ void drain_all_pages(struct zone *zone)
>  	 */
>  	static cpumask_t cpus_with_pcps;
>  
> +	/*
> +	 * Make sure nobody triggers this path before mm_percpu_wq is fully
> +	 * initialized.
> +	 */
> +	if (WARN_ON_ONCE(!mm_percpu_wq))
> +		return;
> +
>  	/* Workqueues cannot recurse */
>  	if (current->flags & PF_WQ_WORKER)
>  		return;
> @@ -2411,7 +2418,7 @@ void drain_all_pages(struct zone *zone)
>  	for_each_cpu(cpu, &cpus_with_pcps) {
>  		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
>  		INIT_WORK(work, drain_local_pages_wq);
> -		schedule_work_on(cpu, work);
> +		queue_work_on(cpu, mm_percpu_wq, work);
>  	}
>  	for_each_cpu(cpu, &cpus_with_pcps)
>  		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
> diff --git a/mm/swap.c b/mm/swap.c
> index ac98eb443a03..361bdb1575ab 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -677,30 +677,19 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
>  
>  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
>  
> -/*
> - * lru_add_drain_wq is used to do lru_add_drain_all() from a WQ_MEM_RECLAIM
> - * workqueue, aiding in getting memory freed.
> - */
> -static struct workqueue_struct *lru_add_drain_wq;
> -
> -static int __init lru_init(void)
> -{
> -	lru_add_drain_wq = alloc_workqueue("lru-add-drain", WQ_MEM_RECLAIM, 0);
> -
> -	if (WARN(!lru_add_drain_wq,
> -		"Failed to create workqueue lru_add_drain_wq"))
> -		return -ENOMEM;
> -
> -	return 0;
> -}
> -early_initcall(lru_init);
> -
>  void lru_add_drain_all(void)
>  {
>  	static DEFINE_MUTEX(lock);
>  	static struct cpumask has_work;
>  	int cpu;
>  
> +	/*
> +	 * Make sure nobody triggers this path before mm_percpu_wq is fully
> +	 * initialized.
> +	 */
> +	if (WARN_ON(!mm_percpu_wq))
> +		return;
> +
>  	mutex_lock(&lock);
>  	get_online_cpus();
>  	cpumask_clear(&has_work);
> @@ -714,7 +703,7 @@ void lru_add_drain_all(void)
>  		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
>  		    need_activate_page_drain(cpu)) {
>  			INIT_WORK(work, lru_add_drain_per_cpu);
> -			queue_work_on(cpu, lru_add_drain_wq, work);
> +			queue_work_on(cpu, mm_percpu_wq, work);
>  			cpumask_set_cpu(cpu, &has_work);
>  		}
>  	}
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 9557fc0f36a4..ff9c49c47f32 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1563,7 +1563,6 @@ static const struct file_operations proc_vmstat_file_operations = {
>  #endif /* CONFIG_PROC_FS */
>  
>  #ifdef CONFIG_SMP
> -static struct workqueue_struct *vmstat_wq;
>  static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
>  int sysctl_stat_interval __read_mostly = HZ;
>  
> @@ -1621,7 +1620,7 @@ static void vmstat_update(struct work_struct *w)
>  		 * to occur in the future. Keep on running the
>  		 * update worker thread.
>  		 */
> -		queue_delayed_work_on(smp_processor_id(), vmstat_wq,
> +		queue_delayed_work_on(smp_processor_id(), mm_percpu_wq,
>  				this_cpu_ptr(&vmstat_work),
>  				round_jiffies_relative(sysctl_stat_interval));
>  	}
> @@ -1700,7 +1699,7 @@ static void vmstat_shepherd(struct work_struct *w)
>  		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
>  
>  		if (!delayed_work_pending(dw) && need_update(cpu))
> -			queue_delayed_work_on(cpu, vmstat_wq, dw, 0);
> +			queue_delayed_work_on(cpu, mm_percpu_wq, dw, 0);
>  	}
>  	put_online_cpus();
>  
> @@ -1716,7 +1715,6 @@ static void __init start_shepherd_timer(void)
>  		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
>  			vmstat_update);
>  
> -	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
>  	schedule_delayed_work(&shepherd,
>  		round_jiffies_relative(sysctl_stat_interval));
>  }
> @@ -1762,11 +1760,15 @@ static int vmstat_cpu_dead(unsigned int cpu)
>  
>  #endif
>  
> +struct workqueue_struct *mm_percpu_wq;
> +
>  static int __init setup_vmstat(void)
>  {
> -#ifdef CONFIG_SMP
> -	int ret;
> +	int ret __maybe_unused;
>  
> +	mm_percpu_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
> +
> +#ifdef CONFIG_SMP
>  	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
>  					NULL, vmstat_cpu_dead);
>  	if (ret < 0)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
