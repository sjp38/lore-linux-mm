Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4766D6B006E
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 08:30:54 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so15080211pab.11
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:30:54 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id fn6si4699125pab.166.2015.01.20.05.30.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 05:30:52 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so11333943pac.13
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 05:30:52 -0800 (PST)
Message-ID: <54BE5885.7030506@gmail.com>
Date: Tue, 20 Jan 2015 21:30:45 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] mm, compaction: encapsulate resetting cached scanner
 positions
References: <1421661920-4114-1-git-send-email-vbabka@suse.cz> <1421661920-4114-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1421661920-4114-4-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

a?? 2015/1/19 18:05, Vlastimil Babka a??e??:
> Reseting the cached compaction scanner positions is now done implicitly in
> __reset_isolation_suitable() and compact_finished(). Encapsulate the
> functionality in a new function reset_cached_positions() and call it
> explicitly where needed.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Should the new function be inline?

Thanks.

> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 22 ++++++++++++++--------
>  1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 45799a4..5626220 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -123,6 +123,13 @@ static inline bool isolation_suitable(struct compact_control *cc,
>  	return !get_pageblock_skip(page);
>  }
>  
> +static void reset_cached_positions(struct zone *zone)
> +{
> +	zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
> +	zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
> +	zone->compact_cached_free_pfn = zone_end_pfn(zone);
> +}
> +
>  /*
>   * This function is called to clear all cached information on pageblocks that
>   * should be skipped for page isolation when the migrate and free page scanner
> @@ -134,9 +141,6 @@ static void __reset_isolation_suitable(struct zone *zone)
>  	unsigned long end_pfn = zone_end_pfn(zone);
>  	unsigned long pfn;
>  
> -	zone->compact_cached_migrate_pfn[0] = start_pfn;
> -	zone->compact_cached_migrate_pfn[1] = start_pfn;
> -	zone->compact_cached_free_pfn = end_pfn;
>  	zone->compact_blockskip_flush = false;
>  
>  	/* Walk the zone and mark every pageblock as suitable for isolation */
> @@ -166,8 +170,10 @@ void reset_isolation_suitable(pg_data_t *pgdat)
>  			continue;
>  
>  		/* Only flush if a full compaction finished recently */
> -		if (zone->compact_blockskip_flush)
> +		if (zone->compact_blockskip_flush) {
>  			__reset_isolation_suitable(zone);
> +			reset_cached_positions(zone);
> +		}
>  	}
>  }
>  
> @@ -1059,9 +1065,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
>  	/* Compaction run completes if the migrate and free scanner meet */
>  	if (compact_scanners_met(cc)) {
>  		/* Let the next compaction start anew. */
> -		zone->compact_cached_migrate_pfn[0] = zone->zone_start_pfn;
> -		zone->compact_cached_migrate_pfn[1] = zone->zone_start_pfn;
> -		zone->compact_cached_free_pfn = zone_end_pfn(zone);
> +		reset_cached_positions(zone);
>  
>  		/*
>  		 * Mark that the PG_migrate_skip information should be cleared
> @@ -1187,8 +1191,10 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  	 * is about to be retried after being deferred. kswapd does not do
>  	 * this reset as it'll reset the cached information when going to sleep.
>  	 */
> -	if (compaction_restarting(zone, cc->order) && !current_is_kswapd())
> +	if (compaction_restarting(zone, cc->order) && !current_is_kswapd()) {
>  		__reset_isolation_suitable(zone);
> +		reset_cached_positions(zone);
> +	}
>  
>  	/*
>  	 * Setup to move all movable pages to the end of the zone. Used cached
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
