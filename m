Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0922B6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 19:08:04 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z67so289601704pgb.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 16:08:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q5si24916379pgh.189.2017.01.25.16.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 16:08:03 -0800 (PST)
Date: Wed, 25 Jan 2017 16:08:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_alloc: Use static global work_struct for
 draining per-cpu pages
Message-Id: <20170125160802.67172878e6692e45fa035f37@linux-foundation.org>
In-Reply-To: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
References: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 25 Jan 2017 08:30:38 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:

> As suggested by Vlastimil Babka and Tejun Heo, this patch uses a static
> work_struct to co-ordinate the draining of per-cpu pages on the workqueue.
> Only one task can drain at a time but this is better than the previous
> scheme that allowed multiple tasks to send IPIs at a time.
> 
> One consideration is whether parallel requests should synchronise against
> each other. This patch does not synchronise for a global drain as the common
> case for such callers is expected to be multiple parallel direct reclaimers
> competing for pages when the watermark is close to min. Draining the per-cpu
> list is unlikely to make much progress and serialising the drain is of
> dubious merit. Drains are synchonrised for callers such as memory hotplug
> and CMA that care about the drain being complete when the function returns.
> 
> ...
>
> @@ -2402,24 +2415,16 @@ void drain_all_pages(struct zone *zone)
>  			cpumask_clear_cpu(cpu, &cpus_with_pcps);
>  	}
>  
> -	if (works) {
> -		for_each_cpu(cpu, &cpus_with_pcps) {
> -			struct work_struct *work = per_cpu_ptr(works, cpu);
> -			INIT_WORK(work, drain_local_pages_wq);
> -			schedule_work_on(cpu, work);
> -		}
> -		for_each_cpu(cpu, &cpus_with_pcps)
> -			flush_work(per_cpu_ptr(works, cpu));
> -	} else {
> -		for_each_cpu(cpu, &cpus_with_pcps) {
> -			struct work_struct work;
> -
> -			INIT_WORK(&work, drain_local_pages_wq);
> -			schedule_work_on(cpu, &work);
> -			flush_work(&work);
> -		}
> +	for_each_cpu(cpu, &cpus_with_pcps) {
> +		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
> +		INIT_WORK(work, drain_local_pages_wq);

It's strange to repeatedly run INIT_WORK() in this fashion. 
Overwriting an atomic_t which should already be zero, initializing a
list_head which should already be in the initialized state...

Can we instead do this a single time in init code?

> +		schedule_work_on(cpu, work);
>  	}
> +	for_each_cpu(cpu, &cpus_with_pcps)
> +		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
> +
>  	put_online_cpus();
> +	mutex_unlock(&pcpu_drain_mutex);
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
