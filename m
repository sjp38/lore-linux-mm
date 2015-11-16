Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 64EFE6B0253
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 04:10:03 -0500 (EST)
Received: by wmec201 with SMTP id c201so109694391wme.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 01:10:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j11si44664901wjq.53.2015.11.16.01.10.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Nov 2015 01:10:01 -0800 (PST)
Subject: Re: [PATCH V2] mm: change mm_vmscan_lru_shrink_inactive() proto types
References: <1447641465-1582-1-git-send-email-yalin.wang2010@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56499D67.6050102@suse.cz>
Date: Mon, 16 Nov 2015 10:09:59 +0100
MIME-Version: 1.0
In-Reply-To: <1447641465-1582-1-git-send-email-yalin.wang2010@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>, rostedt@goodmis.org, mingo@redhat.com, acme@redhat.com, namhyung@kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, vdavydov@parallels.com, hannes@cmpxchg.org, mgorman@techsingularity.net, tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/16/2015 03:37 AM, yalin wang wrote:
> Move node_id zone_idx shrink flags into trace function,
> so thay we don't need caculate these args if the trace is disabled,
> and will make this function have less arguments.
>
> Signed-off-by: yalin wang <yalin.wang2010@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Note that you could have added it yourself, as I said it's fine with me 
after doing the zone_to_nid() change. Also you can keep acked-by and 
reviewed-by from V1 when posting a V2 with only such a small change. V2 
didn't change the tracepoint API further from V1, so I'm quite sure 
Steven wouldn't mind keeping his:

Reviewed-by: Steven Rostedt <rostedt@goodmis.org>

(although it's true that the call to keep/drop the tags is not always 
obvious)

Thanks.

> ---
>   include/trace/events/vmscan.h | 14 +++++++-------
>   mm/vmscan.c                   |  7 ++-----
>   2 files changed, 9 insertions(+), 12 deletions(-)
>
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index dae7836..31763dd 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -352,11 +352,11 @@ TRACE_EVENT(mm_vmscan_writepage,
>
>   TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>
> -	TP_PROTO(int nid, int zid,
> -			unsigned long nr_scanned, unsigned long nr_reclaimed,
> -			int priority, int reclaim_flags),
> +	TP_PROTO(struct zone *zone,
> +		unsigned long nr_scanned, unsigned long nr_reclaimed,
> +		int priority, int file),
>
> -	TP_ARGS(nid, zid, nr_scanned, nr_reclaimed, priority, reclaim_flags),
> +	TP_ARGS(zone, nr_scanned, nr_reclaimed, priority, file),
>
>   	TP_STRUCT__entry(
>   		__field(int, nid)
> @@ -368,12 +368,12 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>   	),
>
>   	TP_fast_assign(
> -		__entry->nid = nid;
> -		__entry->zid = zid;
> +		__entry->nid = zone_to_nid(zone);
> +		__entry->zid = zone_idx(zone);
>   		__entry->nr_scanned = nr_scanned;
>   		__entry->nr_reclaimed = nr_reclaimed;
>   		__entry->priority = priority;
> -		__entry->reclaim_flags = reclaim_flags;
> +		__entry->reclaim_flags = trace_shrink_flags(file);
>   	),
>
>   	TP_printk("nid=%d zid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 69ca1f5..f8fc8c1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1691,11 +1691,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>   	    current_may_throttle())
>   		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
>
> -	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
> -		zone_idx(zone),
> -		nr_scanned, nr_reclaimed,
> -		sc->priority,
> -		trace_shrink_flags(file));
> +	trace_mm_vmscan_lru_shrink_inactive(zone, nr_scanned, nr_reclaimed,
> +			sc->priority, file);
>   	return nr_reclaimed;
>   }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
