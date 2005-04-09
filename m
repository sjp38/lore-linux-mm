Message-ID: <4257F3EC.1000901@yahoo.com.au>
Date: Sun, 10 Apr 2005 01:25:32 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 1/4] pcp: zonequeues
References: <4257D74C.3010703@yahoo.com.au>
In-Reply-To: <4257D74C.3010703@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi Jack,
> Was thinking about some problems in this area, and I hacked up
> a possible implementation to improve things.
> 
> 1/4 switches the per cpu pagesets in struct zone to a single list
> of zone pagesets for each CPU.
> 

Just thinking out loud here... this patch (or something like it)
would probably be a good idea regardless of the remote pageset
removal patches following it.

Shouldn't be any changes in behaviour, but it gives you remote
pagesets in local memory and hopefully better cache behaviour due
to less packing needed, and the use of percpu.

But...

> +
> +struct per_cpu_zone_stats {
>  	unsigned long numa_hit;		/* allocated in intended node */
>  	unsigned long numa_miss;	/* allocated in non intended node */
>  	unsigned long numa_foreign;	/* was intended here, hit elsewhere */
>  	unsigned long interleave_hit; 	/* interleaver prefered this zone */
>  	unsigned long local_node;	/* allocation from local node */
>  	unsigned long other_node;	/* allocation from other node */
> -#endif
>  } ____cacheline_aligned_in_smp;
>  
>  #define ZONE_DMA		0
> @@ -113,16 +114,19 @@ struct zone {
>  	unsigned long		free_pages;
>  	unsigned long		pages_min, pages_low, pages_high;
>  	/*
> -	 * We don't know if the memory that we're going to allocate will be freeable
> -	 * or/and it will be released eventually, so to avoid totally wasting several
> -	 * GB of ram we must reserve some of the lower zone memory (otherwise we risk
> -	 * to run OOM on the lower zones despite there's tons of freeable ram
> -	 * on the higher zones). This array is recalculated at runtime if the
> -	 * sysctl_lowmem_reserve_ratio sysctl changes.
> +	 * We don't know if the memory that we're going to allocate will be
> +	 * freeable or/and it will be released eventually, so to avoid totally
> +	 * wasting several GB of ram we must reserve some of the lower zone
> +	 * memory (otherwise we risk to run OOM on the lower zones despite
> +	 * there's tons of freeable ram on the higher zones). This array is
> +	 * recalculated at runtime if the sysctl_lowmem_reserve_ratio sysctl
> +	 * changes.
>  	 */
>  	unsigned long		lowmem_reserve[MAX_NR_ZONES];
>  
> -	struct per_cpu_pageset	pageset[NR_CPUS];
> +#ifdef CONFIG_NUMA
> +	struct per_cpu_zone_stats stats[NR_CPUS];
> +#endif
>  

I wonder if this stats information should be in the pageset there
in local memory as well? I initially moved it to its own structure
so that the zone queues could be completely confined to page_alloc.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
