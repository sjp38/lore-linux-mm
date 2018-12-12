Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E02808E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:00:53 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s19so16537113qke.20
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:00:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k68si2301643qte.349.2018.12.12.09.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 09:00:52 -0800 (PST)
Subject: Re: [PATCH v2] mm, page_alloc: enable pcpu_drain with zone capability
References: <20181212002933.53337-1-richard.weiyang@gmail.com>
 <20181212142550.61686-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <05304709-209c-75b0-ae3b-adc2b46c876b@redhat.com>
Date: Wed, 12 Dec 2018 18:00:49 +0100
MIME-Version: 1.0
In-Reply-To: <20181212142550.61686-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de

On 12.12.18 15:25, Wei Yang wrote:
> drain_all_pages is documented to drain per-cpu pages for a given zone (if
> non-NULL). The current implementation doesn't match the description though.
> It will drain all pcp pages for all zones that happen to have cached pages
> on the same cpu as the given zone. This will leave to premature pcp cache
> draining for zones that are not of an interest for the caller - e.g.
> compaction, hwpoison or memory offline.
> 
> This would force the page allocator to take locks and potential lock
> contention as a result.
> 
> There is no real reason for this sub-optimal implementnation. Replace
> per-cpu work item with a dedicated structure which contains a pointer to
> zone and pass it over to the worker. This will get the zone information all
> the way down to the worker function and do the right job.
> 
> [mhocko@suse.com: refactor the whole changelog]
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
> v2:
>    * refactor changelog from Michal's suggestion
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

s/work_structs/work_struct/ ?

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
> 

Looks good to me!

Reviewed-by: David Hildenbrand <david@redhat.com>


-- 

Thanks,

David / dhildenb
