Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 025536B0032
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 15:41:15 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z20so340237igj.4
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:41:14 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id y7si2972109igl.1.2015.02.24.12.41.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 12:41:14 -0800 (PST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so329512igb.5
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 12:41:14 -0800 (PST)
Date: Tue, 24 Feb 2015 12:41:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: hide per-cpu lists in output of show_mem()
In-Reply-To: <20150220143942.19568.4548.stgit@buzz>
Message-ID: <alpine.DEB.2.10.1502241239100.3855@chino.kir.corp.google.com>
References: <20150220143942.19568.4548.stgit@buzz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Fri, 20 Feb 2015, Konstantin Khlebnikov wrote:

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 028565a..0538de0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1126,6 +1126,7 @@ extern void pagefault_out_of_memory(void);
>   * various contexts.
>   */
>  #define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
> +#define SHOW_MEM_PERCPU_LISTS		(0x0002u)	/* per-zone per-cpu */
>  
>  extern void show_free_areas(unsigned int flags);
>  extern bool skip_free_areas_node(unsigned int flags, int nid);

I, like others, think this should probably be left out until someone 
actually needs to use it.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a47f0b2..e591f3b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3198,20 +3198,29 @@ static void show_migration_types(unsigned char type)
>   */
>  void show_free_areas(unsigned int filter)
>  {
> +	unsigned long free_pcp = 0;
>  	int cpu;
>  	struct zone *zone;
>  
>  	for_each_populated_zone(zone) {
>  		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>  			continue;
> -		show_node(zone);
> -		printk("%s per-cpu:\n", zone->name);
> +
> +		if (filter & SHOW_MEM_PERCPU_LISTS) {
> +			show_node(zone);
> +			printk("%s per-cpu:\n", zone->name);
> +		}
>  
>  		for_each_online_cpu(cpu) {
>  			struct per_cpu_pageset *pageset;
>  
>  			pageset = per_cpu_ptr(zone->pageset, cpu);
>  
> +			free_pcp += pageset->pcp.count;
> +
> +			if (!(filter & SHOW_MEM_PERCPU_LISTS))
> +				continue;
> +
>  			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
>  			       cpu, pageset->pcp.high,
>  			       pageset->pcp.batch, pageset->pcp.count);
> @@ -3220,11 +3229,10 @@ void show_free_areas(unsigned int filter)
>  
>  	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
>  		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> -		" unevictable:%lu"
> -		" dirty:%lu writeback:%lu unstable:%lu\n"
> -		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> +		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> +		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>  		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> -		" free_cma:%lu\n",
> +		" free:%lu free_pcp:%lu free_cma:%lu\n",

Why is "free:" itself moved?  It is unlikely, but I could imagine that 
this might break something that is parsing the kernel log and it would be 
better to just leave it where it is and add "free_pcp:" after "free_cma:" 
since this is extending the message.

>  		global_page_state(NR_ACTIVE_ANON),
>  		global_page_state(NR_INACTIVE_ANON),
>  		global_page_state(NR_ISOLATED_ANON),
> @@ -3235,13 +3243,14 @@ void show_free_areas(unsigned int filter)
>  		global_page_state(NR_FILE_DIRTY),
>  		global_page_state(NR_WRITEBACK),
>  		global_page_state(NR_UNSTABLE_NFS),
> -		global_page_state(NR_FREE_PAGES),
>  		global_page_state(NR_SLAB_RECLAIMABLE),
>  		global_page_state(NR_SLAB_UNRECLAIMABLE),
>  		global_page_state(NR_FILE_MAPPED),
>  		global_page_state(NR_SHMEM),
>  		global_page_state(NR_PAGETABLE),
>  		global_page_state(NR_BOUNCE),
> +		global_page_state(NR_FREE_PAGES),
> +		free_pcp,
>  		global_page_state(NR_FREE_CMA_PAGES));
>  
>  	for_each_populated_zone(zone) {
> @@ -3249,6 +3258,11 @@ void show_free_areas(unsigned int filter)
>  
>  		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>  			continue;
> +
> +		free_pcp = 0;
> +		for_each_online_cpu(cpu)
> +			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
> +
>  		show_node(zone);
>  		printk("%s"
>  			" free:%lukB"
> @@ -3275,6 +3289,8 @@ void show_free_areas(unsigned int filter)
>  			" pagetables:%lukB"
>  			" unstable:%lukB"
>  			" bounce:%lukB"
> +			" free_pcp:%lukB"
> +			" local_pcp:%ukB"
>  			" free_cma:%lukB"
>  			" writeback_tmp:%lukB"
>  			" pages_scanned:%lu"
> @@ -3306,6 +3322,8 @@ void show_free_areas(unsigned int filter)
>  			K(zone_page_state(zone, NR_PAGETABLE)),
>  			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
>  			K(zone_page_state(zone, NR_BOUNCE)),
> +			K(free_pcp),
> +			K(this_cpu_read(zone->pageset->pcp.count)),
>  			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
>  			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
>  			K(zone_page_state(zone, NR_PAGES_SCANNED)),
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
