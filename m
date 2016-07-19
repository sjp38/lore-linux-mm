Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 498456B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:50:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so64007658pfg.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:50:32 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id m125si11607679pfm.117.2016.07.19.15.50.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 15:50:30 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id p64so11773165pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:50:30 -0700 (PDT)
Date: Tue, 19 Jul 2016 15:50:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/8] mm, page_alloc: restructure direct compaction handling
 in slowpath
In-Reply-To: <20160718112302.27381-5-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1607191548370.19940@chino.kir.corp.google.com>
References: <20160718112302.27381-1-vbabka@suse.cz> <20160718112302.27381-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On Mon, 18 Jul 2016, Vlastimil Babka wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 30443804f156..a04a67745927 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3510,7 +3510,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	struct page *page = NULL;
>  	unsigned int alloc_flags;
>  	unsigned long did_some_progress;
> -	enum migrate_mode migration_mode = MIGRATE_ASYNC;
> +	enum migrate_mode migration_mode = MIGRATE_SYNC_LIGHT;
>  	enum compact_result compact_result;
>  	int compaction_retries = 0;
>  	int no_progress_loops = 0;
> @@ -3552,6 +3552,49 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (page)
>  		goto got_pg;
>  
> +	/*
> +	 * For costly allocations, try direct compaction first, as it's likely
> +	 * that we have enough base pages and don't need to reclaim.
> +	 */
> +	if (can_direct_reclaim && order > PAGE_ALLOC_COSTLY_ORDER) {
> +		page = __alloc_pages_direct_compact(gfp_mask, order,
> +						alloc_flags, ac,
> +						MIGRATE_ASYNC,
> +						&compact_result);
> +		if (page)
> +			goto got_pg;
> +
> +		/* Checks for THP-specific high-order allocations */
> +		if (is_thp_gfp_mask(gfp_mask)) {
> +			/*
> +			 * If compaction is deferred for high-order allocations,
> +			 * it is because sync compaction recently failed. If
> +			 * this is the case and the caller requested a THP
> +			 * allocation, we do not want to heavily disrupt the
> +			 * system, so we fail the allocation instead of entering
> +			 * direct reclaim.
> +			 */
> +			if (compact_result == COMPACT_DEFERRED)
> +				goto nopage;
> +
> +			/*
> +			 * Compaction is contended so rather back off than cause
> +			 * excessive stalls.
> +			 */
> +			if (compact_result == COMPACT_CONTENDED)
> +				goto nopage;
> +
> +			/*
> +			 * It can become very expensive to allocate transparent
> +			 * hugepages at fault, so use asynchronous memory
> +			 * compaction for THP unless it is khugepaged trying to
> +			 * collapse. All other requests should tolerate at
> +			 * least light sync migration.
> +			 */
> +			if (!(current->flags & PF_KTHREAD))
> +				migration_mode = MIGRATE_ASYNC;
> +		}
> +	}
>  

If gfp_pfmemalloc_allowed() == true, does this try to do compaction when 
get_page_from_freelist() would have succeeded with no watermarks?

>  retry:
>  	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
> @@ -3606,55 +3649,33 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
>  		goto nopage;
>  
> -	/*
> -	 * Try direct compaction. The first pass is asynchronous. Subsequent
> -	 * attempts after direct reclaim are synchronous
> -	 */
> +
> +	/* Try direct reclaim and then allocating */
> +	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
> +							&did_some_progress);
> +	if (page)
> +		goto got_pg;
> +
> +	/* Try direct compaction and then allocating */
>  	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
>  					migration_mode,
>  					&compact_result);
>  	if (page)
>  		goto got_pg;
>  
> -	/* Checks for THP-specific high-order allocations */
> -	if (is_thp_gfp_mask(gfp_mask)) {
> -		/*
> -		 * If compaction is deferred for high-order allocations, it is
> -		 * because sync compaction recently failed. If this is the case
> -		 * and the caller requested a THP allocation, we do not want
> -		 * to heavily disrupt the system, so we fail the allocation
> -		 * instead of entering direct reclaim.
> -		 */
> -		if (compact_result == COMPACT_DEFERRED)
> -			goto nopage;
> -
> -		/*
> -		 * Compaction is contended so rather back off than cause
> -		 * excessive stalls.
> -		 */
> -		if(compact_result == COMPACT_CONTENDED)
> -			goto nopage;
> -	}
> -
>  	if (order && compaction_made_progress(compact_result))
>  		compaction_retries++;
>  
> -	/* Try direct reclaim and then allocating */
> -	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
> -							&did_some_progress);
> -	if (page)
> -		goto got_pg;
> -
>  	/* Do not loop if specifically requested */
>  	if (gfp_mask & __GFP_NORETRY)
> -		goto noretry;
> +		goto nopage;
>  
>  	/*
>  	 * Do not retry costly high order allocations unless they are
>  	 * __GFP_REPEAT
>  	 */
>  	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
> -		goto noretry;
> +		goto nopage;
>  
>  	/*
>  	 * Costly allocations might have made a progress but this doesn't mean
> @@ -3693,25 +3714,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto retry;
>  	}
>  
> -noretry:
> -	/*
> -	 * High-order allocations do not necessarily loop after direct reclaim
> -	 * and reclaim/compaction depends on compaction being called after
> -	 * reclaim so call directly if necessary.
> -	 * It can become very expensive to allocate transparent hugepages at
> -	 * fault, so use asynchronous memory compaction for THP unless it is
> -	 * khugepaged trying to collapse. All other requests should tolerate
> -	 * at least light sync migration.
> -	 */
> -	if (is_thp_gfp_mask(gfp_mask) && !(current->flags & PF_KTHREAD))
> -		migration_mode = MIGRATE_ASYNC;
> -	else
> -		migration_mode = MIGRATE_SYNC_LIGHT;
> -	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags,
> -					    ac, migration_mode,
> -					    &compact_result);
> -	if (page)
> -		goto got_pg;
>  nopage:
>  	warn_alloc_failed(gfp_mask, order, NULL);
>  got_pg:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
