Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49A67828E4
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 01:06:17 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u201so328148039oie.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 22:06:17 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k11si1835179ioi.41.2016.07.05.22.06.15
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 22:06:16 -0700 (PDT)
Date: Wed, 6 Jul 2016 14:09:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 09/17] mm, compaction: make whole_zone flag ignore
 cached scanner positions
Message-ID: <20160706050939.GD23627@js1304-P5Q-DELUXE>
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-10-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160624095437.16385-10-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 24, 2016 at 11:54:29AM +0200, Vlastimil Babka wrote:
> A recent patch has added whole_zone flag that compaction sets when scanning
> starts from the zone boundary, in order to report that zone has been fully
> scanned in one attempt. For allocations that want to try really hard or cannot
> fail, we will want to introduce a mode where scanning whole zone is guaranteed
> regardless of the cached positions.
> 
> This patch reuses the whole_zone flag in a way that if it's already passed true
> to compaction, the cached scanner positions are ignored. Employing this flag

Okay. But, please don't reset cached scanner position even if whole_zone
flag is set. Just set cc->migrate_pfn and free_pfn, appropriately. With
your following patches, whole_zone could be set without any compaction
try so there is no point to reset cached scanner position in this
case.

Thanks.

> during reclaim/compaction loop will be done in the next patch. This patch
> however converts compaction invoked from userspace via procfs to use this flag.
> Before this patch, the cached positions were first reset to zone boundaries and
> then read back from struct zone, so there was a window where a parallel
> compaction could replace the reset values, making the manual compaction less
> effective. Using the flag instead of performing reset is more robust.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/compaction.c | 15 +++++----------
>  mm/internal.h   |  2 +-
>  2 files changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f825a58bc37c..e7fe848e318e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1501,11 +1501,13 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  	 */
>  	cc->migrate_pfn = zone->compact_cached_migrate_pfn[sync];
>  	cc->free_pfn = zone->compact_cached_free_pfn;
> -	if (cc->free_pfn < start_pfn || cc->free_pfn >= end_pfn) {
> +	if (cc->whole_zone || cc->free_pfn < start_pfn ||
> +						cc->free_pfn >= end_pfn) {
>  		cc->free_pfn = pageblock_start_pfn(end_pfn - 1);
>  		zone->compact_cached_free_pfn = cc->free_pfn;
>  	}
> -	if (cc->migrate_pfn < start_pfn || cc->migrate_pfn >= end_pfn) {
> +	if (cc->whole_zone || cc->migrate_pfn < start_pfn ||
> +						cc->migrate_pfn >= end_pfn) {
>  		cc->migrate_pfn = start_pfn;
>  		zone->compact_cached_migrate_pfn[0] = cc->migrate_pfn;
>  		zone->compact_cached_migrate_pfn[1] = cc->migrate_pfn;
> @@ -1751,14 +1753,6 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
>  		INIT_LIST_HEAD(&cc->freepages);
>  		INIT_LIST_HEAD(&cc->migratepages);
>  
> -		/*
> -		 * When called via /proc/sys/vm/compact_memory
> -		 * this makes sure we compact the whole zone regardless of
> -		 * cached scanner positions.
> -		 */
> -		if (is_via_compact_memory(cc->order))
> -			__reset_isolation_suitable(zone);
> -
>  		if (is_via_compact_memory(cc->order) ||
>  				!compaction_deferred(zone, cc->order))
>  			compact_zone(zone, cc);
> @@ -1794,6 +1788,7 @@ static void compact_node(int nid)
>  		.order = -1,
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
> +		.whole_zone = true,
>  	};
>  
>  	__compact_pgdat(NODE_DATA(nid), &cc);
> diff --git a/mm/internal.h b/mm/internal.h
> index 680e5ce2ab37..153bb52335b4 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -179,7 +179,7 @@ struct compact_control {
>  	enum migrate_mode mode;		/* Async or sync migration mode */
>  	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
>  	bool direct_compaction;		/* False from kcompactd or /proc/... */
> -	bool whole_zone;		/* Whole zone has been scanned */
> +	bool whole_zone;		/* Whole zone should/has been scanned */
>  	int order;			/* order a direct compactor needs */
>  	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
>  	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
> -- 
> 2.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
