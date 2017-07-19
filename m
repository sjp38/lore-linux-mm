Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2430C6B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 09:16:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 79so3068859wmr.0
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 06:16:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p15si16083wmi.164.2017.07.19.06.15.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 06:15:58 -0700 (PDT)
Subject: Re: [PATCH 2/9] mm, page_alloc: remove boot pageset initialization
 from memory hotplug
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0a8dcf64-b170-e6db-8ce5-0b9a5327785b@suse.cz>
Date: Wed, 19 Jul 2017 15:15:56 +0200
MIME-Version: 1.0
In-Reply-To: <20170714080006.7250-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 07/14/2017 09:59 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> boot_pageset is a boot time hack which gets superseded by normal
> pagesets later in the boot process. It makes zero sense to reinitialize
> it again and again during memory hotplug.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 38 +++++++++++++++++++++-----------------
>  1 file changed, 21 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d9f4ea057e74..7746824a425d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5098,23 +5098,8 @@ static int __build_all_zonelists(void *data)
>  		}
>  	}
>  
> -	/*
> -	 * Initialize the boot_pagesets that are going to be used
> -	 * for bootstrapping processors. The real pagesets for
> -	 * each zone will be allocated later when the per cpu
> -	 * allocator is available.
> -	 *
> -	 * boot_pagesets are used also for bootstrapping offline
> -	 * cpus if the system is already booted because the pagesets
> -	 * are needed to initialize allocators on a specific cpu too.
> -	 * F.e. the percpu allocator needs the page allocator which
> -	 * needs the percpu allocator in order to allocate its pagesets
> -	 * (a chicken-egg dilemma).
> -	 */
> -	for_each_possible_cpu(cpu) {
> -		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
> -
>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
> +	for_each_possible_cpu(cpu) {
>  		/*
>  		 * We now know the "local memory node" for each node--
>  		 * i.e., the node of the first zone in the generic zonelist.
> @@ -5125,8 +5110,8 @@ static int __build_all_zonelists(void *data)
>  		 */
>  		if (cpu_online(cpu))
>  			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
> -#endif
>  	}
> +#endif
>  
>  	return 0;
>  }
> @@ -5134,7 +5119,26 @@ static int __build_all_zonelists(void *data)
>  static noinline void __init
>  build_all_zonelists_init(void)
>  {
> +	int cpu;
> +
>  	__build_all_zonelists(NULL);
> +
> +	/*
> +	 * Initialize the boot_pagesets that are going to be used
> +	 * for bootstrapping processors. The real pagesets for
> +	 * each zone will be allocated later when the per cpu
> +	 * allocator is available.
> +	 *
> +	 * boot_pagesets are used also for bootstrapping offline
> +	 * cpus if the system is already booted because the pagesets
> +	 * are needed to initialize allocators on a specific cpu too.
> +	 * F.e. the percpu allocator needs the page allocator which
> +	 * needs the percpu allocator in order to allocate its pagesets
> +	 * (a chicken-egg dilemma).
> +	 */
> +	for_each_possible_cpu(cpu)
> +		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
> +
>  	mminit_verify_zonelist();
>  	cpuset_init_current_mems_allowed();
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
