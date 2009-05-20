Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1AC086B007E
	for <linux-mm@kvack.org>; Wed, 20 May 2009 03:23:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4K7Nmfw028736
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 May 2009 16:23:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EDE5245DD7B
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:23:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C574C45DD78
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:23:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ACD10E08001
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:23:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DE7F1DB8037
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:23:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] clean up setup_per_zone_pages_min
In-Reply-To: <20090520161853.1bfd415c.minchan.kim@barrios-desktop>
References: <20090520161853.1bfd415c.minchan.kim@barrios-desktop>
Message-Id: <20090520162231.7446.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 May 2009 16:23:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> 
> Mel changed zone->pages_[high/low/min] with zone->watermark array.
> So, setup_per_zone_pages_min also have to be changed.

Only naming change?
if so, the description sould talk about this explicitly.

 - kosaki

> 
> CC: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan kim <minchan.kim@gmail.com>
> ---
>  include/linux/mm.h  |    2 +-
>  mm/memory_hotplug.c |    2 +-
>  mm/page_alloc.c     |   14 +++++++-------
>  3 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a569862..1b2cb16 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1058,7 +1058,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn);
>  extern void set_dma_reserve(unsigned long new_dma_reserve);
>  extern void memmap_init_zone(unsigned long, int, unsigned long,
>  				unsigned long, enum memmap_context);
> -extern void setup_per_zone_pages_min(void);
> +extern void setup_per_zone_wmark_min(void);
>  extern void mem_init(void);
>  extern void __init mmap_init(void);
>  extern void show_mem(void);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index c083cf5..40bf385 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -422,7 +422,7 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
>  	zone->present_pages += onlined_pages;
>  	zone->zone_pgdat->node_present_pages += onlined_pages;
>  
> -	setup_per_zone_pages_min();
> +	setup_per_zone_wmark_min();
>  	if (onlined_pages) {
>  		kswapd_run(zone_to_nid(zone));
>  		node_set_state(zone_to_nid(zone), N_HIGH_MEMORY);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9c712f0..273526b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4471,12 +4471,12 @@ static void setup_per_zone_lowmem_reserve(void)
>  }
>  
>  /**
> - * setup_per_zone_pages_min - called when min_free_kbytes changes.
> + * setup_per_zone_wmark_min - called when min_free_kbytes changes.
>   *
> - * Ensures that the pages_{min,low,high} values for each zone are set correctly
> + * Ensures that the watermark[min,low,high] values for each zone are set correctly
>   * with respect to min_free_kbytes.
>   */
> -void setup_per_zone_pages_min(void)
> +void setup_per_zone_wmark_min(void)
>  {
>  	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
>  	unsigned long lowmem_pages = 0;
> @@ -4594,7 +4594,7 @@ static void __init setup_per_zone_inactive_ratio(void)
>   * 8192MB:	11584k
>   * 16384MB:	16384k
>   */
> -static int __init init_per_zone_pages_min(void)
> +static int __init init_per_zone_wmark_min(void)
>  {
>  	unsigned long lowmem_kbytes;
>  
> @@ -4605,12 +4605,12 @@ static int __init init_per_zone_pages_min(void)
>  		min_free_kbytes = 128;
>  	if (min_free_kbytes > 65536)
>  		min_free_kbytes = 65536;
> -	setup_per_zone_pages_min();
> +	setup_per_zone_wmark_min();
>  	setup_per_zone_lowmem_reserve();
>  	setup_per_zone_inactive_ratio();
>  	return 0;
>  }
> -module_init(init_per_zone_pages_min)
> +module_init(init_per_zone_wmark_min)
>  
>  /*
>   * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so 
> @@ -4622,7 +4622,7 @@ int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
>  {
>  	proc_dointvec(table, write, file, buffer, length, ppos);
>  	if (write)
> -		setup_per_zone_pages_min();
> +		setup_per_zone_wmark_min();
>  	return 0;
>  }
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
