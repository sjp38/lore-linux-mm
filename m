Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5626B0036
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 05:32:02 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so5651045pab.4
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 02:32:01 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id au10si21032442pbd.14.2014.06.23.02.32.00
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 02:32:01 -0700 (PDT)
Message-ID: <53A7F406.6080309@cn.fujitsu.com>
Date: Mon, 23 Jun 2014 17:31:50 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 11/13] mm, compaction: pass gfp mask to compact_control
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-12-git-send-email-vbabka@suse.cz>
In-Reply-To: <1403279383-5862-12-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On 06/20/2014 11:49 PM, Vlastimil Babka wrote:
> From: David Rientjes <rientjes@google.com>
> 
> struct compact_control currently converts the gfp mask to a migratetype, but we
> need the entire gfp mask in a follow-up patch.
> 
> Pass the entire gfp mask as part of struct compact_control.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Rik van Riel <riel@redhat.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  mm/compaction.c | 12 +++++++-----
>  mm/internal.h   |  2 +-
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 32c768b..d4e0c13 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -975,8 +975,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>  }
>  
> -static int compact_finished(struct zone *zone,
> -			    struct compact_control *cc)
> +static int compact_finished(struct zone *zone, struct compact_control *cc,
> +			    const int migratetype)
>  {
>  	unsigned int order;
>  	unsigned long watermark;
> @@ -1022,7 +1022,7 @@ static int compact_finished(struct zone *zone,
>  		struct free_area *area = &zone->free_area[order];
>  
>  		/* Job done if page is free of the right migratetype */
> -		if (!list_empty(&area->free_list[cc->migratetype]))
> +		if (!list_empty(&area->free_list[migratetype]))
>  			return COMPACT_PARTIAL;
>  
>  		/* Job done if allocation would set block type */
> @@ -1088,6 +1088,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  	int ret;
>  	unsigned long start_pfn = zone->zone_start_pfn;
>  	unsigned long end_pfn = zone_end_pfn(zone);
> +	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
>  	const bool sync = cc->mode != MIGRATE_ASYNC;
>  
>  	ret = compaction_suitable(zone, cc->order);
> @@ -1130,7 +1131,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  
>  	migrate_prep_local();
>  
> -	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
> +	while ((ret = compact_finished(zone, cc, migratetype)) ==
> +						COMPACT_CONTINUE) {
>  		int err;
>  
>  		switch (isolate_migratepages(zone, cc)) {
> @@ -1185,7 +1187,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
>  		.nr_freepages = 0,
>  		.nr_migratepages = 0,
>  		.order = order,
> -		.migratetype = gfpflags_to_migratetype(gfp_mask),
> +		.gfp_mask = gfp_mask,
>  		.zone = zone,
>  		.mode = mode,
>  	};
> diff --git a/mm/internal.h b/mm/internal.h
> index 584cd69..dd17a40 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -149,7 +149,7 @@ struct compact_control {
>  	bool finished_update_migrate;
>  
>  	int order;			/* order a direct compactor needs */
> -	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
> +	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
>  	struct zone *zone;
>  	enum compact_contended contended; /* Signal need_sched() or lock
>  					   * contention detected during
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
