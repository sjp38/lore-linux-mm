Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 256696B0069
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 18:52:57 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id b22so735784689pfd.0
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:52:57 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h5si1172586plk.30.2017.01.10.15.52.55
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 15:52:56 -0800 (PST)
Date: Wed, 11 Jan 2017 08:52:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: + mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
 added to -mm tree
Message-ID: <20170110235250.GA7130@bbox>
References: <586edadc.figmHAGrTxvM7Wei%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <586edadc.figmHAGrTxvM7Wei%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mhocko@suse.com, hillf.zj@alibaba-inc.com, mgorman@suse.de, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

Hi Michal,

Sorry for the late review. Acutally, I just review your patch:
[RFC PATCH 2/2] mm, vmscan: cleanup inactive_list_is_low and
found some questions. Here it goes.

On Thu, Jan 05, 2017 at 03:46:36PM -0800, akpm@linux-foundation.org wrote:
> 
> The patch titled
>      Subject: mm, vmscan: add mm_vmscan_inactive_list_is_low tracepoint
> has been added to the -mm tree.  Its filename is
>      mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Michal Hocko <mhocko@suse.com>
> Subject: mm, vmscan: add mm_vmscan_inactive_list_is_low tracepoint
> 
> Currently we have tracepoints for both active and inactive LRU lists
> reclaim but we do not have any which would tell us why we we decided to
> age the active list.  Without that it is quite hard to diagnose
> active/inactive lists balancing.  Add mm_vmscan_inactive_list_is_low
> tracepoint to tell us this information.
> 
> Link: http://lkml.kernel.org/r/20170104101942.4860-8-mhocko@kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/trace/events/vmscan.h |   40 ++++++++++++++++++++++++++++++++
>  mm/vmscan.c                   |   23 +++++++++++-------
>  2 files changed, 54 insertions(+), 9 deletions(-)
> 
> diff -puN include/trace/events/vmscan.h~mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint include/trace/events/vmscan.h
> --- a/include/trace/events/vmscan.h~mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint
> +++ a/include/trace/events/vmscan.h
> @@ -15,6 +15,7 @@
>  #define RECLAIM_WB_MIXED	0x0010u
>  #define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim async */
>  #define RECLAIM_WB_ASYNC	0x0008u
> +#define RECLAIM_WB_LRU		(RECLAIM_WB_ANON|RECLAIM_WB_FILE)
>  
>  #define show_reclaim_flags(flags)				\
>  	(flags) ? __print_flags(flags, "|",			\
> @@ -426,6 +427,45 @@ TRACE_EVENT(mm_vmscan_lru_shrink_active,
>  		show_reclaim_flags(__entry->reclaim_flags))
>  );
>  
> +TRACE_EVENT(mm_vmscan_inactive_list_is_low,
> +
> +	TP_PROTO(int nid, int reclaim_idx,
> +		unsigned long total_inactive, unsigned long inactive,
> +		unsigned long total_active, unsigned long active,
> +		unsigned long ratio, int file),
> +
> +	TP_ARGS(nid, reclaim_idx, total_inactive, inactive, total_active, active, ratio, file),
> +
> +	TP_STRUCT__entry(
> +		__field(int, nid)
> +		__field(int, reclaim_idx)
> +		__field(unsigned long, total_inactive)
> +		__field(unsigned long, inactive)
> +		__field(unsigned long, total_active)
> +		__field(unsigned long, active)
> +		__field(unsigned long, ratio)
> +		__field(int, reclaim_flags)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nid = nid;
> +		__entry->reclaim_idx = reclaim_idx;
> +		__entry->total_inactive = total_inactive;
> +		__entry->inactive = inactive;
> +		__entry->total_active = total_active;
> +		__entry->active = active;
> +		__entry->ratio = ratio;
> +		__entry->reclaim_flags = trace_shrink_flags(file) & RECLAIM_WB_LRU;
> +	),
> +
> +	TP_printk("nid=%d reclaim_idx=%d total_inactive=%ld inactive=%ld total_active=%ld active=%ld ratio=%ld flags=%s",
> +		__entry->nid,
> +		__entry->reclaim_idx,
> +		__entry->total_inactive, __entry->inactive,
> +		__entry->total_active, __entry->active,
> +		__entry->ratio,
> +		show_reclaim_flags(__entry->reclaim_flags))
> +);
>  #endif /* _TRACE_VMSCAN_H */
>  
>  /* This part must be outside protection */
> diff -puN mm/vmscan.c~mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint mm/vmscan.c
> --- a/mm/vmscan.c~mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint
> +++ a/mm/vmscan.c
> @@ -2039,11 +2039,11 @@ static void shrink_active_list(unsigned
>   *   10TB     320        32GB
>   */
>  static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
> -						struct scan_control *sc)
> +						struct scan_control *sc, bool trace)
>  {
>  	unsigned long inactive_ratio;
> -	unsigned long inactive;
> -	unsigned long active;
> +	unsigned long total_inactive, inactive;
> +	unsigned long total_active, active;
>  	unsigned long gb;
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	int zid;
> @@ -2055,8 +2055,8 @@ static bool inactive_list_is_low(struct
>  	if (!file && !total_swap_pages)
>  		return false;
>  
> -	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> -	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> +	total_inactive = inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> +	total_active = active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
>  

the decision of deactivating is based on eligible zone's LRU size,
not whole zone so why should we need to get a trace of all zones's LRU?

>  	/*
>  	 * For zone-constrained allocations, it is necessary to check if
> @@ -2085,6 +2085,11 @@ static bool inactive_list_is_low(struct
>  	else
>  		inactive_ratio = 1;
>  
> +	if (trace)
> +		trace_mm_vmscan_inactive_list_is_low(pgdat->node_id,
> +				sc->reclaim_idx,
> +				total_inactive, inactive,
> +				total_active, active, inactive_ratio, file);
>  	return inactive * inactive_ratio < active;
>  }
>  
> @@ -2092,7 +2097,7 @@ static unsigned long shrink_list(enum lr
>  				 struct lruvec *lruvec, struct scan_control *sc)
>  {
>  	if (is_active_lru(lru)) {
> -		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc))
> +		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
>  			shrink_active_list(nr_to_scan, lruvec, sc, lru);
>  		return 0;
>  	}
> @@ -2223,7 +2228,7 @@ static void get_scan_count(struct lruvec
>  	 * lruvec even if it has plenty of old anonymous pages unless the
>  	 * system is under heavy pressure.
>  	 */
> -	if (!inactive_list_is_low(lruvec, true, sc) &&
> +	if (!inactive_list_is_low(lruvec, true, sc, false) &&

Hmm, I was curious why you added trace boolean arguement and found it here.
Yes, here is not related to deactivation directly but couldn't we help to
trace it unconditionally? With that, we can know why VM reclaim only
file-backed page on slow device although enough anonymous pages on fast
swap like zram are enough.

So I suggest to trace it unconditionally with sc->priority. With that,
we can catch such problem.
What do you think?

>  	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
>  		scan_balance = SCAN_FILE;
>  		goto out;
> @@ -2448,7 +2453,7 @@ static void shrink_node_memcg(struct pgl
>  	 * Even if we did not try to evict anon pages at all, we want to
>  	 * rebalance the anon lru active/inactive ratio.
>  	 */
> -	if (inactive_list_is_low(lruvec, false, sc))
> +	if (inactive_list_is_low(lruvec, false, sc, true))
>  		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>  				   sc, LRU_ACTIVE_ANON);
>  }
> @@ -3098,7 +3103,7 @@ static void age_active_anon(struct pglis
>  	do {
>  		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
>  
> -		if (inactive_list_is_low(lruvec, false, sc))
> +		if (inactive_list_is_low(lruvec, false, sc, true))
>  			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>  					   sc, LRU_ACTIVE_ANON);
>  
> _
> 
> Patches currently in -mm which might be from mhocko@suse.com are
> 
> mm-slab-make-sure-that-kmalloc_max_size-will-fit-into-max_order.patch
> bpf-do-not-use-kmalloc_shift_max.patch
> mm-fix-remote-numa-hits-statistics.patch
> mm-get-rid-of-__gfp_other_node.patch
> mm-throttle-show_mem-from-warn_alloc.patch
> mm-trace-extract-compaction_status-and-zone_type-to-a-common-header.patch
> oom-trace-add-oom-detection-tracepoints.patch
> oom-trace-add-compaction-retry-tracepoint.patch
> mm-vmscan-remove-unused-mm_vmscan_memcg_isolate.patch
> mm-vmscan-add-active-list-aging-tracepoint.patch
> mm-vmscan-add-active-list-aging-tracepoint-update.patch
> mm-vmscan-show-the-number-of-skipped-pages-in-mm_vmscan_lru_isolate.patch
> mm-vmscan-show-lru-name-in-mm_vmscan_lru_isolate-tracepoint.patch
> mm-vmscan-extract-shrink_page_list-reclaim-counters-into-a-struct.patch
> mm-vmscan-enhance-mm_vmscan_lru_shrink_inactive-tracepoint.patch
> mm-vmscan-add-mm_vmscan_inactive_list_is_low-tracepoint.patch
> trace-vmscan-postprocess-sync-with-tracepoints-updates.patch
> 
> --
> To unsubscribe from this list: send the line "unsubscribe mm-commits" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
