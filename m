Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCAC6B0037
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 09:52:01 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id d49so2453194eek.18
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 06:52:01 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id l44si7158508eem.82.2013.12.04.06.52.00
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 06:52:00 -0800 (PST)
Message-ID: <529F418D.3070108@suse.cz>
Date: Wed, 04 Dec 2013 15:51:57 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: Trace compaction begin and end
References: <1385389570-11393-1-git-send-email-vbabka@suse.cz> <20131204143045.GZ11295@suse.de>
In-Reply-To: <20131204143045.GZ11295@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>

On 12/04/2013 03:30 PM, Mel Gorman wrote:
> This patch adds two tracepoints for compaction begin and end of a zone. Using
> this it is possible to calculate how much time a workload is spending
> within compaction and potentially debug problems related to cached pfns
> for scanning.

I guess for debugging pfns it would be also useful to print their values 
also in mm_compaction_end.

> In combination with the direct reclaim and slab trace points
> it should be possible to estimate most allocation-related overhead for
> a workload.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>   include/trace/events/compaction.h | 42 +++++++++++++++++++++++++++++++++++++++
>   mm/compaction.c                   |  4 ++++
>   2 files changed, 46 insertions(+)
>
> diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
> index fde1b3e..f4e115a 100644
> --- a/include/trace/events/compaction.h
> +++ b/include/trace/events/compaction.h
> @@ -67,6 +67,48 @@ TRACE_EVENT(mm_compaction_migratepages,
>   		__entry->nr_failed)
>   );
>
> +TRACE_EVENT(mm_compaction_begin,
> +	TP_PROTO(unsigned long zone_start, unsigned long migrate_start,
> +		unsigned long zone_end, unsigned long free_start),
> +
> +	TP_ARGS(zone_start, migrate_start, zone_end, free_start),

IMHO a better order would be:
  zone_start, migrate_start, free_start, zone_end
(well especially in the TP_printk part anyway).

> +
> +	TP_STRUCT__entry(
> +		__field(unsigned long, zone_start)
> +		__field(unsigned long, migrate_start)
> +		__field(unsigned long, zone_end)
> +		__field(unsigned long, free_start)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->zone_start = zone_start;
> +		__entry->migrate_start = migrate_start;
> +		__entry->zone_end = zone_end;
> +		__entry->free_start = free_start;
> +	),
> +
> +	TP_printk("zone_start=%lu migrate_start=%lu zone_end=%lu free_start=%lu",
> +		__entry->zone_start,
> +		__entry->migrate_start,
> +		__entry->zone_end,
> +		__entry->free_start)
> +);
> +
> +TRACE_EVENT(mm_compaction_end,
> +	TP_PROTO(int status),
> +
> +	TP_ARGS(status),
> +
> +	TP_STRUCT__entry(
> +		__field(int, status)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->status = status;
> +	),
> +
> +	TP_printk("status=%d", __entry->status)
> +);
>
>   #endif /* _TRACE_COMPACTION_H */
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c437893..78ff866 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -960,6 +960,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
>   		__reset_isolation_suitable(zone);
>
> +	trace_mm_compaction_begin(start_pfn, cc->migrate_pfn, end_pfn, cc->free_pfn);
> +
>   	migrate_prep_local();
>
>   	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
> @@ -1005,6 +1007,8 @@ out:
>   	cc->nr_freepages -= release_freepages(&cc->freepages);
>   	VM_BUG_ON(cc->nr_freepages != 0);
>
> +	trace_mm_compaction_end(ret);
> +
>   	return ret;
>   }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
