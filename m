Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 164D96B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 09:26:08 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so15324409wjc.1
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 06:26:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s136si3640550wmd.98.2017.01.20.06.26.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 06:26:06 -0800 (PST)
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
Date: Fri, 20 Jan 2017 15:26:05 +0100
MIME-Version: 1.0
In-Reply-To: <20170117092954.15413-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

On 01/17/2017 10:29 AM, Mel Gorman wrote:
> The per-cpu page allocator can be drained immediately via drain_all_pages()
> which sends IPIs to every CPU. In the next patch, the per-cpu allocator
> will only be used for interrupt-safe allocations which prevents draining
> it from IPI context. This patch uses workqueues to drain the per-cpu
> lists instead.
> 
> This is slower but no slowdown during intensive reclaim was measured and
> the paths that use drain_all_pages() are not that sensitive to performance.
> This is particularly true as the path would only be triggered when reclaim
> is failing. It also makes a some sense to avoid storming a machine with IPIs
> when it's under memory pressure. Arguably, it should be further adjusted
> so that only one caller at a time is draining pages but it's beyond the
> scope of the current patch.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

I'm not a workqueue expert (CC Petr Mladek) but I compared this to
lru_add_drain_all() and have some questions...

> ---
>  mm/page_alloc.c | 42 +++++++++++++++++++++++++++++++++++-------
>  1 file changed, 35 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d15527a20dce..9c3a0fcf8c13 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2341,19 +2341,21 @@ void drain_local_pages(struct zone *zone)
>  		drain_pages(cpu);
>  }
>  
> +static void drain_local_pages_wq(struct work_struct *work)
> +{
> +	drain_local_pages(NULL);
> +}
> +
>  /*
>   * Spill all the per-cpu pages from all CPUs back into the buddy allocator.
>   *
>   * When zone parameter is non-NULL, spill just the single zone's pages.
>   *
> - * Note that this code is protected against sending an IPI to an offline
> - * CPU but does not guarantee sending an IPI to newly hotplugged CPUs:
> - * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs but
> - * nothing keeps CPUs from showing up after we populated the cpumask and
> - * before the call to on_each_cpu_mask().
> + * Note that this can be extremely slow as the draining happens in a workqueue.
>   */
>  void drain_all_pages(struct zone *zone)
>  {
> +	struct work_struct __percpu *works;
>  	int cpu;
>  
>  	/*
> @@ -2362,6 +2364,16 @@ void drain_all_pages(struct zone *zone)
>  	 */
>  	static cpumask_t cpus_with_pcps;
>  
> +	/* Workqueues cannot recurse */
> +	if (current->flags & PF_WQ_WORKER)
> +		return;
> +
> +	/*
> +	 * As this can be called from reclaim context, do not reenter reclaim.
> +	 * An allocation failure can be handled, it's simply slower
> +	 */
> +	works = alloc_percpu_gfp(struct work_struct, GFP_ATOMIC);
> +
>  	/*
>  	 * We don't care about racing with CPU hotplug event
>  	 * as offline notification will cause the notified
> @@ -2392,8 +2404,24 @@ void drain_all_pages(struct zone *zone)
>  		else
>  			cpumask_clear_cpu(cpu, &cpus_with_pcps);
>  	}
> -	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
> -								zone, 1);
> +
> +	if (works) {
> +		for_each_cpu(cpu, &cpus_with_pcps) {
> +			struct work_struct *work = per_cpu_ptr(works, cpu);
> +			INIT_WORK(work, drain_local_pages_wq);
> +			schedule_work_on(cpu, work);

This translates to queue_work_on(), which has the comment of "We queue
the work to a specific CPU, the caller must ensure it can't go away.",
so is this safe? lru_add_drain_all() uses get_online_cpus() around this.

schedule_work_on() also uses the generic system_wq, while lru drain has
its own workqueue with WQ_MEM_RECLAIM so it seems that would be useful
here as well?

> +		}
> +		for_each_cpu(cpu, &cpus_with_pcps)
> +			flush_work(per_cpu_ptr(works, cpu));
> +	} else {
> +		for_each_cpu(cpu, &cpus_with_pcps) {
> +			struct work_struct work;
> +
> +			INIT_WORK(&work, drain_local_pages_wq);
> +			schedule_work_on(cpu, &work);
> +			flush_work(&work);

Totally out of scope, but I wonder if schedule_on_each_cpu() could use
the same fallback that's here?

> +		}
> +	}
>  }
>  
>  #ifdef CONFIG_HIBERNATION
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
