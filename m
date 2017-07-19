Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B976A6B02C3
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 09:19:40 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q50so9233974wrb.14
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 06:19:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j28si1343832wrb.220.2017.07.19.06.19.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 06:19:39 -0700 (PDT)
Subject: Re: [PATCH 3/9] mm, page_alloc: do not set_cpu_numa_mem on empty
 nodes initialization
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7c122a7b-2b46-428e-cf67-eb2975e3a729@suse.cz>
Date: Wed, 19 Jul 2017 15:19:38 +0200
MIME-Version: 1.0
In-Reply-To: <20170714080006.7250-4-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 07/14/2017 10:00 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> __build_all_zonelists reinitializes each online cpu local node for
> CONFIG_HAVE_MEMORYLESS_NODES. This makes sense because previously memory
> less nodes could gain some memory during memory hotplug and so the local
> node should be changed for CPUs close to such a node. It makes less
> sense to do that unconditionally for a newly creaded NUMA node which is
> still offline and without any memory.
> 
> Let's also simplify the cpu loop and use for_each_online_cpu instead of
> an explicit cpu_online check for all possible cpus.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_alloc.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7746824a425d..ebc3311555b1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5096,10 +5096,8 @@ static int __build_all_zonelists(void *data)
>  
>  			build_zonelists(pgdat);
>  		}
> -	}
>  
>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
> -	for_each_possible_cpu(cpu) {
>  		/*
>  		 * We now know the "local memory node" for each node--
>  		 * i.e., the node of the first zone in the generic zonelist.
> @@ -5108,10 +5106,10 @@ static int __build_all_zonelists(void *data)
>  		 * secondary cpus' numa_mem as they come on-line.  During
>  		 * node/memory hotplug, we'll fixup all on-line cpus.
>  		 */
> -		if (cpu_online(cpu))
> +		for_each_online_cpu(cpu)
>  			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
> -	}
>  #endif
> +	}
>  
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
