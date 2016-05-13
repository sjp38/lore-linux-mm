Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF9CA6B0253
	for <linux-mm@kvack.org>; Fri, 13 May 2016 09:23:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so38636728lfq.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:23:12 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id tk4si5881742wjb.25.2016.05.13.06.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 06:23:11 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r12so3707085wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 06:23:11 -0700 (PDT)
Date: Fri, 13 May 2016 15:23:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 09/13] mm, compaction: make whole_zone flag ignore cached
 scanner positions
Message-ID: <20160513132309.GO20141@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-10-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462865763-22084-10-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 10-05-16 09:35:59, Vlastimil Babka wrote:
> A recent patch has added whole_zone flag that compaction sets when scanning
> starts from the zone boundary, in order to report that zone has been fully
> scanned in one attempt. For allocations that want to try really hard or cannot
> fail, we will want to introduce a mode where scanning whole zone is guaranteed
> regardless of the cached positions.
> 
> This patch reuses the whole_zone flag in a way that if it's already passed true
> to compaction, the cached scanner positions are ignored. Employing this flag
> during reclaim/compaction loop will be done in the next patch. This patch
> however converts compaction invoked from userspace via procfs to use this flag.
> Before this patch, the cached positions were first reset to zone boundaries and
> then read back from struct zone, so there was a window where a parallel
> compaction could replace the reset values, making the manual compaction less
> effective. Using the flag instead of performing reset is more robust.

This makes perfect sense because user visible API should better have a
deterministic behavior. Playing scanner positions games which might race
with the system triggered compaction sounds quite unpredictable.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/compaction.c | 15 +++++----------
>  mm/internal.h   |  2 +-
>  2 files changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f649c7bc6de5..1ce6783d3ead 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1442,11 +1442,13 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
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
> @@ -1693,14 +1695,6 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
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
> @@ -1736,6 +1730,7 @@ static void compact_node(int nid)
>  		.order = -1,
>  		.mode = MIGRATE_SYNC,
>  		.ignore_skip_hint = true,
> +		.whole_zone = true,
>  	};
>  
>  	__compact_pgdat(NODE_DATA(nid), &cc);
> diff --git a/mm/internal.h b/mm/internal.h
> index 556bc9d0a817..2acdee8ab0e6 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -178,7 +178,7 @@ struct compact_control {
>  	enum migrate_mode mode;		/* Async or sync migration mode */
>  	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
>  	bool direct_compaction;		/* False from kcompactd or /proc/... */
> -	bool whole_zone;		/* Whole zone has been scanned */
> +	bool whole_zone;		/* Whole zone should/has been scanned */
>  	int order;			/* order a direct compactor needs */
>  	const gfp_t gfp_mask;		/* gfp mask of a direct compactor */
>  	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
> -- 
> 2.8.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
