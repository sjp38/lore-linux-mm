Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F114E8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 07:52:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so8471836edd.16
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 04:52:42 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l24si678550edr.135.2018.12.12.04.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 04:52:41 -0800 (PST)
Date: Wed, 12 Dec 2018 13:52:38 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, page_alloc: enable pcpu_drain with zone capability
Message-ID: <20181212125238.GS1286@dhcp22.suse.cz>
References: <20181212002933.53337-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212002933.53337-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Wed 12-12-18 08:29:33, Wei Yang wrote:
> Current pcpu_drain is defined as work_struct, which is not capable to
> carry the zone information to drain pages. During __offline_pages(), the
> code is sure the exact zone to drain pages. This will leads to
> __offline_pages() to drain other zones which we don't want to touch and
> to some extend increase the contention of the system.

I think the above is quite vague and imprecise. I would formulate it as
follows. Feel free to take it or parts that you find useful.
"
drain_all_pages is documented to drain per-cpu pages for a given zone
(if non-NULL). The current implementation doesn't match the description
though. It will drain all pcp pages for all zones that happen to have
cached pages on the same cpu as the given zone. This will leave to
premature pcp cache draining for zones that are not of an interest for
the caller - e.g. compaction, hwpoison or memory offline.

This would force the page allocator to take locks and potential lock
contention as a result.

There is no real reason for this sub-optimal implementnation. Replace
per-cpu work item with a dedicated structure which contains a pointer
to zone and pass it over to the worker. This will get the zone
information all the way down to the worker function and do the right
job.
"
 
> This patch enable pcpu_drain with zone information, so that we could
> drain pages on the exact zone.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Other than that this makes sense to me
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/page_alloc.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 65db26995466..eb4df3f63f5e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -96,8 +96,12 @@ int _node_numa_mem_[MAX_NUMNODES];
>  #endif
>  
>  /* work_structs for global per-cpu drains */
> +struct pcpu_drain {
> +	struct zone *zone;
> +	struct work_struct work;
> +};
>  DEFINE_MUTEX(pcpu_drain_mutex);
> -DEFINE_PER_CPU(struct work_struct, pcpu_drain);
> +DEFINE_PER_CPU(struct pcpu_drain, pcpu_drain);
>  
>  #ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
>  volatile unsigned long latent_entropy __latent_entropy;
> @@ -2596,6 +2600,8 @@ void drain_local_pages(struct zone *zone)
>  
>  static void drain_local_pages_wq(struct work_struct *work)
>  {
> +	struct pcpu_drain *drain =
> +		container_of(work, struct pcpu_drain, work);
>  	/*
>  	 * drain_all_pages doesn't use proper cpu hotplug protection so
>  	 * we can race with cpu offline when the WQ can move this from
> @@ -2604,7 +2610,7 @@ static void drain_local_pages_wq(struct work_struct *work)
>  	 * a different one.
>  	 */
>  	preempt_disable();
> -	drain_local_pages(NULL);
> +	drain_local_pages(drain->zone);
>  	preempt_enable();
>  }
>  
> @@ -2675,12 +2681,14 @@ void drain_all_pages(struct zone *zone)
>  	}
>  
>  	for_each_cpu(cpu, &cpus_with_pcps) {
> -		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
> -		INIT_WORK(work, drain_local_pages_wq);
> -		queue_work_on(cpu, mm_percpu_wq, work);
> +		struct pcpu_drain *drain = per_cpu_ptr(&pcpu_drain, cpu);
> +
> +		drain->zone = zone;
> +		INIT_WORK(&drain->work, drain_local_pages_wq);
> +		queue_work_on(cpu, mm_percpu_wq, &drain->work);
>  	}
>  	for_each_cpu(cpu, &cpus_with_pcps)
> -		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
> +		flush_work(&per_cpu_ptr(&pcpu_drain, cpu)->work);
>  
>  	mutex_unlock(&pcpu_drain_mutex);
>  }
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
