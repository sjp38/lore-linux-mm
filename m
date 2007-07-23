Message-ID: <46A4574A.8060102@yahoo.com.au>
Date: Mon, 23 Jul 2007 17:22:50 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] zone config patch set [1/2] zone ifdef cleaunp by
 renumbering
References: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070721160049.75bc8d9f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "apw@shadowen.org" <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This patch set is for changing ZONE_MOVABLE as configurable.
> 
> This patch cleans up #ifdef used for zones to some extent.
> But I noticed this will conflict witl Christoph's memory_less_node patch set.
> 
> If his set is ready to be merged to -mm(I hope so), I'll repost this after that.
> For now, this post is just for review, again. If this patch looks danger, please
> point out.
> 
> Patch is against 2.6.22-rc6-mm1. Tested on ia64/NUMA with and without setting CONFIG_ZONE_MOVABLE. both works well.
> 
> I'm sorry but my response will be delayed.
> 
> Thanks,
> -Kame
> ==
> zone_ifdef_cleanup_by_renumbering.patch
> 
> Now, this patch defines zone_idx for not-configured-zones.
> like 
> 	enum_zone_type {
> 		(ZONE_DMA configured)
> 		(ZONE_DMA32 configured)
> 		ZONE_NORMAL
> 		(ZONE_HIGHMEM configured)
> 		ZONE_MOVABLE
> 		MAX_NR_ZONES,
> 		(ZONE_DMA not-configured)
> 		(ZONE_DMA32 not-configured)
> 		(ZONE_HIGHMEM not-configured)
> 		MAX_POSSIBLE_ZONES,
> 	};
> 
> By this, we can determine zone is configured or not by
> 
> 	zone_idx < MAX_NR_ZONES.
> 
> By this, we can avoid #ifdef for CONFIG_ZONE_xxx to some extent.
> 
> This patch also replaces CONFIG_ZONE_DMA_FLAG by is_configured_zone(ZONE_DMA).

This looks nice to me. It seems like the constant folding will be pretty
trivial for the compiler to get right -- have you verified this?

Could make a comment about all the names of these little functions, but I
see that you're pretty well just following what's already there, so whoever
thought those are nice shouldn't have a problem with your patch :)

> 
> Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  include/linux/gfp.h    |   16 +++++-------
>  include/linux/mmzone.h |   64 ++++++++++++++++++++++++++-----------------------
>  include/linux/vmstat.h |   24 +++++++++---------
>  mm/Kconfig             |    5 ---
>  mm/page-writeback.c    |    7 ++---
>  mm/page_alloc.c        |   37 ++++++++++++----------------
>  mm/slab.c              |    4 +--
>  7 files changed, 74 insertions(+), 83 deletions(-)
> 
> Index: linux-2.6.22-rc6-mm1/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.22-rc6-mm1.orig/include/linux/mmzone.h
> +++ linux-2.6.22-rc6-mm1/include/linux/mmzone.h
> @@ -178,9 +178,24 @@ enum zone_type {
>  	ZONE_HIGHMEM,
>  #endif
>  	ZONE_MOVABLE,
> -	MAX_NR_ZONES
> +	MAX_NR_ZONES,
> +#ifndef CONFIG_ZONE_DMA
> +	ZONE_DMA,
> +#endif
> +#ifndef CONFIG_ZONE_DMA32
> +	ZONE_DMA32,
> +#endif
> +#ifndef CONFIG_HIGHMEM
> +	ZONE_HIGHMEM,
> +#endif
> +	MAX_POSSIBLE_ZONES,
>  };

One issue I see here is that MAX_POSSIBLE_ZONES also includes MAX_NR_ZONES
so I think it will be off-by-one, won't it?


> -static char * const zone_names[MAX_NR_ZONES] = {
> -#ifdef CONFIG_ZONE_DMA
> -	 "DMA",
> -#endif
> -#ifdef CONFIG_ZONE_DMA32
> -	 "DMA32",
> -#endif
> -	 "Normal",
> -#ifdef CONFIG_HIGHMEM
> -	 "HighMem",
> -#endif
> -	 "Movable",
> +static char * const zone_names[MAX_POSSIBLE_ZONES] = {
> +	[ZONE_DMA] = "DMA",
> +	[ZONE_DMA32] = "DMA32",
> +	[ZONE_NORMAL] = "Normal",
> +	[ZONE_HIGHMEM] = "HighMem",
> +	[ZONE_MOVABLE] =  "Movable",
>  };

Sweet :) I guess the slight increase in size is well worth the nice code!
However, I think you should be able to just avoid specifying the array
size explicitly, right?


> @@ -134,8 +128,8 @@ static unsigned long __meminitdata dma_r
>  
>    static struct node_active_region __meminitdata early_node_map[MAX_ACTIVE_REGIONS];
>    static int __meminitdata nr_nodemap_entries;
> -  static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
> -  static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
> +  static unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_POSSIBLE_ZONES];
> +  static unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_POSSIBLE_ZONES];

I don't quite understand why you need to make this change? AFAKS, it is wrong.
Given that, you might be able to just get rid of MAX_POSSIBLE_ZONES completely?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
