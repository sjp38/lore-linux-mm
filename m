Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A87B0828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 19:49:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so417494057pfa.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 16:49:32 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b72si843551pfc.221.2016.07.04.16.49.31
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 16:49:31 -0700 (PDT)
Date: Tue, 5 Jul 2016 08:50:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 01/31] mm, vmstat: add infrastructure for per-node vmstats
Message-ID: <20160704235018.GA26749@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-2-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1467403299-25786-2-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 09:01:09PM +0100, Mel Gorman wrote:
> VM statistic counters for reclaim decisions are zone-based.  If the kernel
> is to reclaim on a per-node basis then we need to track per-node
> statistics but there is no infrastructure for that.  The most notable
> change is that the old node_page_state is renamed to
> sum_zone_node_page_state.  The new node_page_state takes a pglist_data and
> uses per-node stats but none exist yet.  There is some renaming such as
> vm_stat to vm_zone_stat and the addition of vm_node_stat and the renaming
> of mod_state to mod_zone_state.  Otherwise, this is mostly a mechanical
> patch with no functional change.  There is a lot of similarity between the
> node and zone helpers which is unfortunate but there was no obvious way of
> reusing the code and maintaining type safety.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---

<snip>

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7997f52935c9..90b0737ee4be 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -86,8 +86,10 @@ void vm_events_fold_cpu(int cpu)
>   *
>   * vm_stat contains the global counters
>   */
> -atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
> -EXPORT_SYMBOL(vm_stat);
> +atomic_long_t vm_zone_stat[NR_VM_ZONE_STAT_ITEMS] __cacheline_aligned_in_smp;
> +atomic_long_t vm_node_stat[NR_VM_NODE_STAT_ITEMS] __cacheline_aligned_in_smp;
> +EXPORT_SYMBOL(vm_zone_stat);
> +EXPORT_SYMBOL(vm_node_stat);
>  
>  #ifdef CONFIG_SMP
>  
> @@ -172,13 +174,17 @@ void refresh_zone_stat_thresholds(void)
>  	int threshold;
>  
>  	for_each_populated_zone(zone) {
> +		struct pglist_data *pgdat = zone->zone_pgdat;
>  		unsigned long max_drift, tolerate_drift;
>  
>  		threshold = calculate_normal_threshold(zone);
>  
> -		for_each_online_cpu(cpu)
> +		for_each_online_cpu(cpu) {
>  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
>  							= threshold;
> +			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
> +							= threshold;
> +		}

I didn't see other patches yet so it might fix it then.

per_cpu_nodestats is per node not zone but it use per-zone threshold
and even overwritten by next zones. I don't think it's not intended.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
