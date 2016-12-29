Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53F406B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 01:02:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so580521516pfg.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 22:02:07 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n22si52316526pfi.246.2016.12.28.22.02.05
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 22:02:06 -0800 (PST)
Date: Thu, 29 Dec 2016 15:02:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20161229060204.GC1815@bbox>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20161228153032.10821-5-mhocko@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Dec 28, 2016 at 04:30:29PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> from is file or anonymous but we do not know which LRU this is. It is
> useful to know whether the list is file or anonymous as well. Change
> the tracepoint to show symbolic names of the lru rather.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Not exactly same with this but idea is almost same.
I used almost same tracepoint to investigate agging(i.e., deactivating) problem
in 32b kernel with node-lru.
It was enough. Namely, I didn't need tracepoint in shrink_active_list like your
first patch.
Your first patch is more straightforwad and information. But as you introduced
this patch, I want to ask in here.
Isn't it enough with this patch without your first one to find a such problem?

Thanks.

> ---
>  include/trace/events/vmscan.h | 20 ++++++++++++++------
>  mm/vmscan.c                   |  2 +-
>  2 files changed, 15 insertions(+), 7 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 6af4dae46db2..cc0b4c456c78 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -36,6 +36,14 @@
>  		(RECLAIM_WB_ASYNC) \
>  	)
>  
> +#define show_lru_name(lru) \
> +	__print_symbolic(lru, \
> +			{LRU_INACTIVE_ANON, "LRU_INACTIVE_ANON"}, \
> +			{LRU_ACTIVE_ANON, "LRU_ACTIVE_ANON"}, \
> +			{LRU_INACTIVE_FILE, "LRU_INACTIVE_FILE"}, \
> +			{LRU_ACTIVE_FILE, "LRU_ACTIVE_FILE"}, \
> +			{LRU_UNEVICTABLE, "LRU_UNEVICTABLE"})
> +
>  TRACE_EVENT(mm_vmscan_kswapd_sleep,
>  
>  	TP_PROTO(int nid),
> @@ -277,9 +285,9 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
>  		unsigned long nr_skipped,
>  		unsigned long nr_taken,
>  		isolate_mode_t isolate_mode,
> -		int file),
> +		int lru),
>  
> -	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, file),
> +	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, lru),
>  
>  	TP_STRUCT__entry(
>  		__field(int, classzone_idx)
> @@ -289,7 +297,7 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
>  		__field(unsigned long, nr_skipped)
>  		__field(unsigned long, nr_taken)
>  		__field(isolate_mode_t, isolate_mode)
> -		__field(int, file)
> +		__field(int, lru)
>  	),
>  
>  	TP_fast_assign(
> @@ -300,10 +308,10 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
>  		__entry->nr_skipped = nr_skipped;
>  		__entry->nr_taken = nr_taken;
>  		__entry->isolate_mode = isolate_mode;
> -		__entry->file = file;
> +		__entry->lru = lru;
>  	),
>  
> -	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_skipped=%lu nr_taken=%lu file=%d",
> +	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_skipped=%lu nr_taken=%lu lru=%s",
>  		__entry->isolate_mode,
>  		__entry->classzone_idx,
>  		__entry->order,
> @@ -311,7 +319,7 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
>  		__entry->nr_scanned,
>  		__entry->nr_skipped,
>  		__entry->nr_taken,
> -		__entry->file)
> +		show_lru_name(__entry->lru))
>  );
>  
>  TRACE_EVENT(mm_vmscan_writepage,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4f7c0d66d629..3f0774f30a42 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1500,7 +1500,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	}
>  	*nr_scanned = scan + total_skipped;
>  	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
> -				    skipped, nr_taken, mode, is_file_lru(lru));
> +				    skipped, nr_taken, mode, lru);
>  	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);
>  	return nr_taken;
>  }
> -- 
> 2.10.2
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
