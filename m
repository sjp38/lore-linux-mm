Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ED4C96B0082
	for <linux-mm@kvack.org>; Wed, 20 May 2009 03:33:43 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4K7YDJq005321
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 May 2009 16:34:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F2D6F45DE58
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:34:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 92EA245DE55
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:34:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 604ACE38006
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:34:11 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C4304E3800E
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:34:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] reset wmark_min and inactive ratio of zone when hotplug happens
In-Reply-To: <20090520162001.3f3bbe5c.minchan.kim@barrios-desktop>
References: <20090520162001.3f3bbe5c.minchan.kim@barrios-desktop>
Message-Id: <20090520162616.744C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 May 2009 16:34:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

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
> 2) If zone->present_pages is changed, we also have to change
> zone->inactive_ratio. That's because inactive_ratio depends
> on zone->present_pages.

Good catch!
looks good to me. but I'm not familiar this area. CC to Goto-san.





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
> -- 
> 1.5.4.3
> 
> 
> 
> -- 
> Kinds Regards
> Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
