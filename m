Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EFCEF6B013C
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 22:48:51 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so6764289pdj.1
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:48:51 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id rw8si4907539pab.167.2014.06.10.19.48.49
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 19:48:51 -0700 (PDT)
Date: Wed, 11 Jun 2014 11:48:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 08/10] mm, compaction: pass gfp mask to compact_control
Message-ID: <20140611024855.GH15630@bbox>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz>
 <1402305982-6928-8-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1402305982-6928-8-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 09, 2014 at 11:26:20AM +0200, Vlastimil Babka wrote:
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
> ---
>  mm/compaction.c | 12 +++++++-----
>  mm/internal.h   |  2 +-
>  2 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index c339ccd..d1e30ba 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -965,8 +965,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  	return ISOLATE_SUCCESS;
>  }
>  
> -static int compact_finished(struct zone *zone,
> -			    struct compact_control *cc)
> +static int compact_finished(struct zone *zone, struct compact_control *cc,
> +			    const int migratetype)

If we has gfp_mask, we could use gfpflags_to_migratetype from cc->gfp_mask.
What's is your intention?

>  {
>  	unsigned int order;
>  	unsigned long watermark;
> @@ -1012,7 +1012,7 @@ static int compact_finished(struct zone *zone,
>  		struct free_area *area = &zone->free_area[order];
>  
>  		/* Job done if page is free of the right migratetype */
> -		if (!list_empty(&area->free_list[cc->migratetype]))
> +		if (!list_empty(&area->free_list[migratetype]))
>  			return COMPACT_PARTIAL;
>  
>  		/* Job done if allocation would set block type */
> @@ -1078,6 +1078,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  	int ret;
>  	unsigned long start_pfn = zone->zone_start_pfn;
>  	unsigned long end_pfn = zone_end_pfn(zone);
> +	const int migratetype = gfpflags_to_migratetype(cc->gfp_mask);
>  	const bool sync = cc->mode != MIGRATE_ASYNC;
>  
>  	ret = compaction_suitable(zone, cc->order);
> @@ -1120,7 +1121,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>  
>  	migrate_prep_local();
>  
> -	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
> +	while ((ret = compact_finished(zone, cc, migratetype)) ==
> +						COMPACT_CONTINUE) {
>  		int err;
>  
>  		switch (isolate_migratepages(zone, cc)) {
> @@ -1178,7 +1180,7 @@ static unsigned long compact_zone_order(struct zone *zone, int order,
>  		.nr_freepages = 0,
>  		.nr_migratepages = 0,
>  		.order = order,
> -		.migratetype = gfpflags_to_migratetype(gfp_mask),
> +		.gfp_mask = gfp_mask,
>  		.zone = zone,
>  		.mode = mode,
>  	};
> diff --git a/mm/internal.h b/mm/internal.h
> index 584d04f..af15461 100644
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
> -- 
> 1.8.4.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
