Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 518B06B0379
	for <linux-mm@kvack.org>; Sat, 21 Aug 2010 20:42:45 -0400 (EDT)
Date: Sun, 22 Aug 2010 08:42:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100822004232.GA11007@localhost>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100820141400.GD4636@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Michal,

It helps to explain in changelog/code

- in what situation a ZONE_MOVABLE will contain !MIGRATE_MOVABLE
  pages? And why the MIGRATE_MOVABLE test is still necessary given the
  ZONE_MOVABLE check?

- why do you think free pages are not removeable? Simply to cater for
  the set_migratetype_isolate() logic, or there are more fundamental
  reasons?

Thanks,
Fengguang

On Fri, Aug 20, 2010 at 04:14:00PM +0200, Michal Hocko wrote:
> Hi,
> what do you think about the patch below?
> 
> >From b983695b92b5be58f31c719fada1d3245f7b6768 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 20 Aug 2010 15:39:16 +0200
> Subject: [PATCH] Make is_mem_section_removable more conformable with offlining code
> 
> Currently is_mem_section_removable checks whether each pageblock from
> the given pfn range is of MIGRATE_MOVABLE type or if it is free. If both
> are false then the range is considered non removable.
> 
> On the other hand, offlining code (more specifically
> set_migratetype_isolate) doesn't care whether a page is free and instead
> it just checks the migrate type of the page and whether the page's zone
> is movable.
> 
> This can lead into a situation when a node is marked as removable even
> though all pages are neither MIGRATE_MOVABLE nor the zone is
> ZONE_MOVABLE.
> 
> Also we can mark a node as not removable just because a pageblock is
> MIGRATE_RESERVE and not free (and this situation is much more probable).
> ---
>  mm/memory_hotplug.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index a4cfcdc..da20568 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -611,10 +611,10 @@ int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  		type = get_pageblock_migratetype(page);
>  
>  		/*
> -		 * A pageblock containing MOVABLE or free pages is considered
> -		 * removable
> +		 * A pageblock containing MOVABLE or page from movable
> +		 * zone are considered removable
>  		 */
> -		if (type != MIGRATE_MOVABLE && !pageblock_free(page))
> +		if (type != MIGRATE_MOVABLE && zone_idx(page) != ZONE_MOVABLE)
>  			return 0;
>  
>  		/*
> -- 
> 1.7.1
> 
> 
> -- 
> Michal Hocko
> L3 team 
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9    
> Czech Republic
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
