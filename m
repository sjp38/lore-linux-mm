Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id C208C6B006C
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 19:22:34 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z20so25746igj.10
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:22:34 -0800 (PST)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id 193si4004313ion.18.2014.12.17.16.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 16:22:33 -0800 (PST)
Received: by mail-ie0-f171.google.com with SMTP id rl12so170840iec.2
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:22:32 -0800 (PST)
Date: Wed, 17 Dec 2014 16:22:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't
 alter arg gfp_mask
In-Reply-To: <20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1412171608300.16260@chino.kir.corp.google.com>
References: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org> <548F6F94.2020209@jp.fujitsu.com> <20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com

On Mon, 15 Dec 2014, Andrew Morton wrote:

> Well it was already wrong because the first allocation attempt uses
> gfp_mask|__GFP_HARDWAL, but we only trace gfp_mask.
> 
> This?
> 
> --- a/mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask-fix
> +++ a/mm/page_alloc.c
> @@ -2877,6 +2877,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
>  	unsigned int cpuset_mems_cookie;
>  	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
>  	int classzone_idx;
> +	gfp_t mask;
>  
>  	gfp_mask &= gfp_allowed_mask;
>  
> @@ -2910,23 +2911,24 @@ retry_cpuset:
>  	classzone_idx = zonelist_zone_idx(preferred_zoneref);
>  
>  	/* First allocation attempt */
> -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> -			zonelist, high_zoneidx, alloc_flags,
> -			preferred_zone, classzone_idx, migratetype);
> +	mask = gfp_mask|__GFP_HARDWALL;
> +	page = get_page_from_freelist(mask, nodemask, order, zonelist,
> +			high_zoneidx, alloc_flags, preferred_zone,
> +			classzone_idx, migratetype);
>  	if (unlikely(!page)) {
>  		/*
>  		 * Runtime PM, block IO and its error handling path
>  		 * can deadlock because I/O on the device might not
>  		 * complete.
>  		 */
> -		gfp_t mask = memalloc_noio_flags(gfp_mask);
> +		mask = memalloc_noio_flags(gfp_mask);
>  
>  		page = __alloc_pages_slowpath(mask, order,
>  				zonelist, high_zoneidx, nodemask,
>  				preferred_zone, classzone_idx, migratetype);
>  	}
>  
> -	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +	trace_mm_page_alloc(page, order, mask, migratetype);
>  
>  out:
>  	/*

I'm not sure I understand why we need a local variable to hold the context 
mask vs. what was passed to the function.  We should only be allocating 
with a single gfp_mask that is passed to the function and modify it as 
necessary, and that becomes the context mask that can be traced.

The above is wrong because it unconditionally sets __GFP_HARDWALL as the 
gfp mask for __alloc_pages_slowpath() when we actually only want that for 
the first allocation attempt, it's needed for the implementation of 
__cpuset_node_allowed().

The page allocator slowpath is always called from the fastpath if the 
first allocation didn't succeed, so we don't know from which we allocated 
the page at this tracepoint.

I'm afraid the original code before either of these patches was more 
correct.  The use of memalloc_noio_flags() for "subsequent allocation 
attempts" doesn't really matter since neither __GFP_FS nor __GFP_IO 
matters for fastpath allocation (we aren't reclaiming).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
