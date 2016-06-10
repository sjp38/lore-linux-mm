Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E261D6B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 09:32:00 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id u74so30916382lff.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 06:32:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si14614218wmf.86.2016.06.10.06.31.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Jun 2016 06:31:59 -0700 (PDT)
Subject: Re: [PATCH 01/27] mm, vmstat: Add infrastructure for per-node vmstats
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-2-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <575AC13D.2010104@suse.cz>
Date: Fri, 10 Jun 2016 15:31:41 +0200
MIME-Version: 1.0
In-Reply-To: <1465495483-11855-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2016 08:04 PM, Mel Gorman wrote:
> References: bnc#969297 PM performance -- intel_pstate
> Patch-mainline: No, expected 4.7 and queued in linux-mm
> Patch-name: patches.suse/mm-vmstat-Add-infrastructure-for-per-node-vmstats.patch

Remove?

> VM statistic counters for reclaim decisions are zone-based. If the kernel
> is to reclaim on a per-node basis then we need to track per-node statistics
> but there is no infrastructure for that. The most notable change is that
> the old node_page_state is renamed to sum_zone_node_page_state.  The new
> node_page_state takes a pglist_data and uses per-node stats but none exist
> yet. There is some renaming such as vm_stat to vm_zone_stat and the addition
> of vm_node_stat and the renaming of mod_state to mod_zone_state. Otherwise,
> this is mostly a mechanical patch with no functional change. There is a
> lot of similarity between the node and zone helpers which is unfortunate
> but there was no obvious way of reusing the code and maintaining type safety.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Mel Gorman <mgorman@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Some nitpicks below.

> @@ -237,12 +286,26 @@ static inline void __inc_zone_page_state(struct page *page,
>  	__inc_zone_state(page_zone(page), item);
>  }
>  
> +static inline void __inc_node_page_state(struct page *page,
> +			enum node_stat_item item)
> +{
> +	__inc_node_state(page_zone(page)->zone_pgdat, item);

This page -> node translation looks needlessly ineffective. How about
using NODE_DATA(page_to_nid(page)).

> +}
> +
> +
>  static inline void __dec_zone_page_state(struct page *page,
>  			enum zone_stat_item item)
>  {
>  	__dec_zone_state(page_zone(page), item);
>  }
>  
> +static inline void __dec_node_page_state(struct page *page,
> +			enum node_stat_item item)
> +{
> +	__dec_node_state(page_zone(page)->zone_pgdat, item);
> +}

Ditto.

> @@ -188,9 +190,13 @@ void refresh_zone_stat_thresholds(void)
>  
>  		threshold = calculate_normal_threshold(zone);
>  
> -		for_each_online_cpu(cpu)
> +		for_each_online_cpu(cpu) {
> +			struct pglist_data *pgdat = zone->zone_pgdat;

Move the variable outside?

>  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
>  							= threshold;
> +			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
> +							= threshold;
> +		}
>  
>  		/*
>  		 * Only set percpu_drift_mark if there is a danger that
>  void __inc_zone_page_state(struct page *page, enum zone_stat_item item)

[...]

>  {
>  	__inc_zone_state(page_zone(page), item);
>  }
>  EXPORT_SYMBOL(__inc_zone_page_state);
>  
> +void __inc_node_page_state(struct page *page, enum node_stat_item item)
> +{
> +	__inc_node_state(page_zone(page)->zone_pgdat, item);

Same page -> node thing here.


> +void __dec_node_page_state(struct page *page, enum node_stat_item item)
> +{
> +	__dec_node_state(page_zone(page)->zone_pgdat, item);

And here.

>  
>  void dec_zone_page_state(struct page *page, enum zone_stat_item item)
>  {
> -	mod_state(page_zone(page), item, -1, -1);
> +	mod_zone_state(page_zone(page), item, -1, -1);
>  }
>  EXPORT_SYMBOL(dec_zone_page_state);
> +
> +static inline void mod_node_state(struct pglist_data *pgdat,
> +       enum node_stat_item item, int delta, int overstep_mode)
> +{
> +	struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
> +	s8 __percpu *p = pcp->vm_node_stat_diff + item;
> +	long o, n, t, z;
> +
> +	do {
> +		z = 0;  /* overflow to zone counters */

s/zone/node/?

> +
> +		/*
> +		 * The fetching of the stat_threshold is racy. We may apply
> +		 * a counter threshold to the wrong the cpu if we get
> +		 * rescheduled while executing here. However, the next
> +		 * counter update will apply the threshold again and
> +		 * therefore bring the counter under the threshold again.
> +		 *
> +		 * Most of the time the thresholds are the same anyways
> +		 * for all cpus in a zone.

same here.

> +		 */
> +		t = this_cpu_read(pcp->stat_threshold);
> +
> +		o = this_cpu_read(*p);
> +		n = delta + o;
> +
> +		if (n > t || n < -t) {
> +			int os = overstep_mode * (t >> 1) ;
> +
> +			/* Overflow must be added to zone counters */

and here.

> +}
> +
> +void inc_node_page_state(struct page *page, enum node_stat_item item)
> +{
> +	mod_node_state(page_zone(page)->zone_pgdat, item, 1, 1);

Ditto about page -> nid.

> +}
> +EXPORT_SYMBOL(inc_node_page_state);
> +
> +void dec_node_page_state(struct page *page, enum node_stat_item item)
> +{
> +	mod_node_state(page_zone(page)->zone_pgdat, item, -1, -1);
> +}

Ditto.

> +EXPORT_SYMBOL(dec_node_page_state);
>  #else
>  /*
>   * Use interrupt disable to serialize counter updates
> @@ -436,21 +568,69 @@ void dec_zone_page_state(struct page *page, enum zone_stat_item item)
>  	local_irq_restore(flags);
>  }
>  EXPORT_SYMBOL(dec_zone_page_state);
> -#endif
>  
> +void inc_node_state(struct pglist_data *pgdat, enum node_stat_item item)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	__inc_node_state(pgdat, item);
> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(inc_node_state);
> +
> +void mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
> +					long delta)
> +{
> +	unsigned long flags;
> +
> +	local_irq_save(flags);
> +	__mod_node_page_state(pgdat, item, delta);
> +	local_irq_restore(flags);
> +}
> +EXPORT_SYMBOL(mod_node_page_state);
> +
> +void inc_node_page_state(struct page *page, enum node_stat_item item)
> +{
> +	unsigned long flags;
> +	struct pglist_data *pgdat;
> +
> +	pgdat = page_zone(page)->zone_pgdat;

And here.

,9 +736,11 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
>   */
>  void cpu_vm_stats_fold(int cpu)
>  {
> +	struct pglist_data *pgdat;
>  	struct zone *zone;
>  	int i;
> -	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
> +	int global_zone_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
> +	int global_node_diff[NR_VM_NODE_STAT_ITEMS] = { 0, };
>  
>  	for_each_populated_zone(zone) {
>  		struct per_cpu_pageset *p;
> @@ -555,11 +754,27 @@ void cpu_vm_stats_fold(int cpu)
>  				v = p->vm_stat_diff[i];
>  				p->vm_stat_diff[i] = 0;
>  				atomic_long_add(v, &zone->vm_stat[i]);
> -				global_diff[i] += v;
> +				global_zone_diff[i] += v;
>  			}
>  	}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
