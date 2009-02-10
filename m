Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A382F6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 08:50:58 -0500 (EST)
Date: Tue, 10 Feb 2009 13:50:51 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] introduce for_each_populated_zone() macro
Message-ID: <20090210135050.GB4023@csn.ul.ie>
References: <20090210162220.6FBC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090210162220.6FBC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 04:39:13PM +0900, KOSAKI Motohiro wrote:
> 
> Impact: cleanup
> 
> In almost case, for_each_zone() is used with populated_zone().
> It's because almost function doesn't need memoryless node information.
> Therefore, for_each_populated_zone() can help to make code simplify.
> 
> This patch doesn't have any functional change.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/mmzone.h  |   11 +++++++++++
>  kernel/power/snapshot.c |    9 +++------
>  kernel/power/swsusp.c   |   17 ++++++++---------
>  mm/page_alloc.c         |   26 +++++---------------------
>  mm/vmscan.c             |    6 +-----
>  mm/vmstat.c             |   11 ++---------
>  6 files changed, 30 insertions(+), 50 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 09c14e2..abda5ec 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -806,6 +806,17 @@ extern struct zone *next_zone(struct zone *zone);
>  	     zone;					\
>  	     zone = next_zone(zone))
>  
> +#define for_each_populated_zone(zone)		        \
> +	for (zone = (first_online_pgdat())->node_zones; \
> +	     zone;					\
> +	     zone = next_zone(zone))			\
> +		if (!populated_zone(zone))		\
> +			; /* do nothing */		\
> +		else
> +
> +
> +
> +

There is tabs vs whitespace damage in there. Multiple empty lines are introduced
for no apparent reason. It's not clear why you did not use

if (populated_zone(zone))

instead of an if/else.

Otherwise, I did not spot anything out of the ordinary. Nice cleanup.

>  static inline struct zone *zonelist_zone(struct zoneref *zoneref)
>  {
>  	return zoneref->zone;
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index f5fc2d7..33e2e4a 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -321,13 +321,10 @@ static int create_mem_extents(struct list_head *list, gfp_t gfp_mask)
>  
>  	INIT_LIST_HEAD(list);
>  
> -	for_each_zone(zone) {
> +	for_each_populated_zone(zone) {
>  		unsigned long zone_start, zone_end;
>  		struct mem_extent *ext, *cur, *aux;
>  
> -		if (!populated_zone(zone))
> -			continue;
> -
>  		zone_start = zone->zone_start_pfn;
>  		zone_end = zone->zone_start_pfn + zone->spanned_pages;
>  
> @@ -804,8 +801,8 @@ static unsigned int count_free_highmem_pages(void)
>  	struct zone *zone;
>  	unsigned int cnt = 0;
>  
> -	for_each_zone(zone)
> -		if (populated_zone(zone) && is_highmem(zone))
> +	for_each_populated_zone(zone)
> +		if (is_highmem(zone))
>  			cnt += zone_page_state(zone, NR_FREE_PAGES);
>  
>  	return cnt;
> diff --git a/kernel/power/swsusp.c b/kernel/power/swsusp.c
> index a92c914..1ee6636 100644
> --- a/kernel/power/swsusp.c
> +++ b/kernel/power/swsusp.c
> @@ -229,17 +229,16 @@ int swsusp_shrink_memory(void)
>  		size = count_data_pages() + PAGES_FOR_IO + SPARE_PAGES;
>  		tmp = size;
>  		size += highmem_size;
> -		for_each_zone (zone)
> -			if (populated_zone(zone)) {
> -				tmp += snapshot_additional_pages(zone);
> -				if (is_highmem(zone)) {
> -					highmem_size -=
> +		for_each_populated_zone(zone) {
> +			tmp += snapshot_additional_pages(zone);
> +			if (is_highmem(zone)) {
> +				highmem_size -=
>  					zone_page_state(zone, NR_FREE_PAGES);
> -				} else {
> -					tmp -= zone_page_state(zone, NR_FREE_PAGES);
> -					tmp += zone->lowmem_reserve[ZONE_NORMAL];
> -				}
> +			} else {
> +				tmp -= zone_page_state(zone, NR_FREE_PAGES);
> +				tmp += zone->lowmem_reserve[ZONE_NORMAL];
>  			}
> +		}
>  
>  		if (highmem_size < 0)
>  			highmem_size = 0;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5675b30..68610a9 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -922,13 +922,10 @@ static void drain_pages(unsigned int cpu)
>  	unsigned long flags;
>  	struct zone *zone;
>  
> -	for_each_zone(zone) {
> +	for_each_populated_zone(zone) {
>  		struct per_cpu_pageset *pset;
>  		struct per_cpu_pages *pcp;
>  
> -		if (!populated_zone(zone))
> -			continue;
> -
>  		pset = zone_pcp(zone, cpu);
>  
>  		pcp = &pset->pcp;
> @@ -1874,10 +1871,7 @@ void show_free_areas(void)
>  	int cpu;
>  	struct zone *zone;
>  
> -	for_each_zone(zone) {
> -		if (!populated_zone(zone))
> -			continue;
> -
> +	for_each_populated_zone(zone) {
>  		show_node(zone);
>  		printk("%s per-cpu:\n", zone->name);
>  
> @@ -1917,12 +1911,9 @@ void show_free_areas(void)
>  		global_page_state(NR_PAGETABLE),
>  		global_page_state(NR_BOUNCE));
>  
> -	for_each_zone(zone) {
> +	for_each_populated_zone(zone) {
>  		int i;
>  
> -		if (!populated_zone(zone))
> -			continue;
> -
>  		show_node(zone);
>  		printk("%s"
>  			" free:%lukB"
> @@ -1962,12 +1953,9 @@ void show_free_areas(void)
>  		printk("\n");
>  	}
>  
> -	for_each_zone(zone) {
> +	for_each_populated_zone(zone) {
>   		unsigned long nr[MAX_ORDER], flags, order, total = 0;
>  
> -		if (!populated_zone(zone))
> -			continue;
> -
>  		show_node(zone);
>  		printk("%s: ", zone->name);
>  
> @@ -2779,11 +2767,7 @@ static int __cpuinit process_zones(int cpu)
>  
>  	node_set_state(node, N_CPU);	/* this node has a cpu */
>  
> -	for_each_zone(zone) {
> -
> -		if (!populated_zone(zone))
> -			continue;
> -
> +	for_each_populated_zone(zone) {
>  		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
>  					 GFP_KERNEL, node);
>  		if (!zone_pcp(zone, cpu))
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9a27c44..b9c3cea 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2060,11 +2060,7 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
>  	unsigned long nr_to_scan, ret = 0;
>  	enum lru_list l;
>  
> -	for_each_zone(zone) {
> -
> -		if (!populated_zone(zone))
> -			continue;
> -
> +	for_each_populated_zone(zone) {
>  		if (zone_is_all_unreclaimable(zone) && prio != DEF_PRIORITY)
>  			continue;
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 9114974..6fb76fa 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -135,11 +135,7 @@ static void refresh_zone_stat_thresholds(void)
>  	int cpu;
>  	int threshold;
>  
> -	for_each_zone(zone) {
> -
> -		if (!zone->present_pages)
> -			continue;
> -
> +	for_each_populated_zone(zone) {
>  		threshold = calculate_threshold(zone);
>  
>  		for_each_online_cpu(cpu)
> @@ -301,12 +297,9 @@ void refresh_cpu_vm_stats(int cpu)
>  	int i;
>  	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
>  
> -	for_each_zone(zone) {
> +	for_each_populated_zone(zone) {
>  		struct per_cpu_pageset *p;
>  
> -		if (!populated_zone(zone))
> -			continue;
> -
>  		p = zone_pcp(zone, cpu);
>  
>  		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
