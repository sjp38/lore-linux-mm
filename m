Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBB46B00E2
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 12:58:27 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so6550041wiv.2
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 09:58:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ge8si25903606wib.35.2015.01.06.09.58.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 09:58:25 -0800 (PST)
Message-ID: <54AC223F.80307@suse.cz>
Date: Tue, 06 Jan 2015 18:58:23 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't alter
 arg gfp_mask
References: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org>	<548F6F94.2020209@jp.fujitsu.com>	<20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>	<alpine.DEB.2.10.1412171608300.16260@chino.kir.corp.google.com>	<20141217162905.9bc063be55a341d40b293c72@linux-foundation.org>	<alpine.DEB.2.10.1412171642370.23841@chino.kir.corp.google.com> <20141218131041.76391e96a6bd8b071db45962@linux-foundation.org>
In-Reply-To: <20141218131041.76391e96a6bd8b071db45962@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On 12/18/2014 10:10 PM, Andrew Morton wrote:
> On Wed, 17 Dec 2014 16:51:21 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
>> > > The page allocator slowpath is always called from the fastpath if the 
>> > > first allocation didn't succeed, so we don't know from which we allocated 
>> > > the page at this tracepoint.
>> > 
>> > True, but the idea is that when we call trace_mm_page_alloc(), local
>> > var `mask' holds the gfp_t which was used in the most recent allocation
>> > attempt.
>> > 
>> 
>> So if the fastpath succeeds, which should be the majority of the time, 
>> then we get a tracepoint here that says we allocated with 
>> __GFP_FS | __GFP_IO even though we may have PF_MEMALLOC_NOIO set.  So if 
>> page != NULL, we can know that either the fastpath succeeded or we don't 
>> have PF_MEMALLOC_NOIO and were allowed to reclaim.  Not sure that's very 
>> helpful.
>> 
>> Easiest thing to do would be to just clear __GFP_FS and __GFP_IO when we 
>> clear everything not in gfp_allowed_mask, but that's pointless if the 
>> fastpath succeeds.  I'm not sure it's worth to restructure the code with a 
>> possible performance overhead for the benefit of a tracepoint.
>> 
>> And then there's the call to lockdep_trace_alloc() which does care about 
>> __GFP_FS.  That looks broken because we need to clear __GFP_FS with 
>> PF_MEMALLOC_NOIO.
> 
> <head spinning>
> 
> I'm not particuarly concerned about the tracepoint and we can change
> that later.  The main intent here is to restore the allocation mask
> when __alloc_pages_nodemask() does the "goto retry_cpuset".

Hmm David seems to be correct about the initial get_page_from_freelist() not
caring about __GFP_FS/__GFP_IO, since it won't be reclaiming. Well, there might
be zone reclaim enabled, but __zone_reclaim() seems to be calling
memalloc_noio_flags() itself so it's fine.

Anyway it's subtle and fragile, so even though your patch seems now to really
affect just the tracepoint (which you are not so concerned about), it's IMHO
better than current state. So feel free to add my acked-by.

I also agree that lockdep_trace_alloc() seems broken if it doesn't take
PF_MEMALLOC_NOIO into account, but that could be solved within
lockdep_trace_alloc()? Adding Peter and Ingo to CC.

> (I renamed `mask' to `alloc_mask' and documented it a bit)
> 
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/page_alloc.c:__alloc_pages_nodemask(): don't alter arg gfp_mask
> 
> __alloc_pages_nodemask() strips __GFP_IO when retrying the page
> allocation.  But it does this by altering the function-wide variable
> gfp_mask.  This will cause subsequent allocation attempts to inadvertently
> use the modified gfp_mask.
> 
> Also, pass the correct mask (the mask we actually used) into
> trace_mm_page_alloc().
> 
> Cc: Ming Lei <ming.lei@canonical.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/page_alloc.c |   15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> diff -puN mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask
> +++ a/mm/page_alloc.c
> @@ -2865,6 +2865,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
>  	unsigned int cpuset_mems_cookie;
>  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
>  	int classzone_idx;
> +	gfp_t alloc_mask; /* The gfp_t that was actually used for allocation */
>  
>  	gfp_mask &= gfp_allowed_mask;
>  
> @@ -2898,22 +2899,24 @@ retry_cpuset:
>  	classzone_idx = zonelist_zone_idx(preferred_zoneref);
>  
>  	/* First allocation attempt */
> -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> -			zonelist, high_zoneidx, alloc_flags,
> -			preferred_zone, classzone_idx, migratetype);
> +	alloc_mask = gfp_mask|__GFP_HARDWALL;
> +	page = get_page_from_freelist(alloc_mask, nodemask, order, zonelist,
> +			high_zoneidx, alloc_flags, preferred_zone,
> +			classzone_idx, migratetype);
>  	if (unlikely(!page)) {
>  		/*
>  		 * Runtime PM, block IO and its error handling path
>  		 * can deadlock because I/O on the device might not
>  		 * complete.
>  		 */
> -		gfp_mask = memalloc_noio_flags(gfp_mask);
> -		page = __alloc_pages_slowpath(gfp_mask, order,
> +		alloc_mask = memalloc_noio_flags(gfp_mask);
> +
> +		page = __alloc_pages_slowpath(alloc_mask, order,
>  				zonelist, high_zoneidx, nodemask,
>  				preferred_zone, classzone_idx, migratetype);
>  	}
>  
> -	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +	trace_mm_page_alloc(page, order, alloc_mask, migratetype);
>  
>  out:
>  	/*
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
