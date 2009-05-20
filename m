Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E91386B0083
	for <linux-mm@kvack.org>; Wed, 20 May 2009 06:31:43 -0400 (EDT)
Date: Wed, 20 May 2009 11:32:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] reset wmark_min and inactive ratio of zone when
	hotplug happens
Message-ID: <20090520103207.GC12433@csn.ul.ie>
References: <20090520162001.3f3bbe5c.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090520162001.3f3bbe5c.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 20, 2009 at 04:20:01PM +0900, Minchan Kim wrote:
> This patch solve two problems.
> 
> Whenever memory hotplug sucessfully happens, zone->present_pages
> have to be changed.
> 
> 1) Now, memory hotplug calls setup_per_zone_wmark_min only when
> online_pages called, not offline_pages.
> 
> It breaks balance.
> 

Very true.

> 2) If zone->present_pages is changed, we also have to change
> zone->inactive_ratio. That's because inactive_ratio depends
> on zone->present_pages.
> 
> CC: Mel Gorman <mel@csn.ul.ie>
> CC: Rik van Riel <riel@redhat.com>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/memory_hotplug.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 40bf385..1611010 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -423,6 +423,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
>  	zone->zone_pgdat->node_present_pages += onlined_pages;
>  
>  	setup_per_zone_wmark_min();
> +	calculate_per_zone_inactive_ratio(zone);
>  	if (onlined_pages) {
>  		kswapd_run(zone_to_nid(zone));
>  		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> @@ -832,6 +833,9 @@ repeat:
>  	totalram_pages -= offlined_pages;
>  	num_physpages -= offlined_pages;
>  
> +	setup_per_zone_wmark_min();
> +	calculate_per_zone_inactive_ratio(zone);
> +
>  	vm_total_pages = nr_free_pagecache_pages();
>  	writeback_set_ratelimit();
>  

Seems sensible.;

> -- 
> 1.5.4.3
> 
> 
> 
> -- 
> Kinds Regards
> Minchan Kim
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
