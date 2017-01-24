Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78A986B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 04:19:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so24209519wmi.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 01:19:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d83si17508112wmc.151.2017.01.24.01.19.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 01:19:15 -0800 (PST)
Subject: Re: [PATCH] mm: ensure alloc_flags in slow path are initialized
References: <20170123121649.3180300-1-arnd@arndb.de>
 <20170123155638.db6036219cb6ab2582be104e@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dc810ec3-34e7-1b0d-e360-8bd6fb4ae53a@suse.cz>
Date: Tue, 24 Jan 2017 10:19:11 +0100
MIME-Version: 1.0
In-Reply-To: <20170123155638.db6036219cb6ab2582be104e@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/24/2017 12:56 AM, Andrew Morton wrote:
> On Mon, 23 Jan 2017 13:16:12 +0100 Arnd Bergmann <arnd@arndb.de> wrote:
> 
>> The __alloc_pages_slowpath() has gotten rather complex and gcc
>> is no longer able to follow the gotos and prove that the
>> alloc_flags variable is initialized at the time it is used:
>>
>> mm/page_alloc.c: In function '__alloc_pages_slowpath':
>> mm/page_alloc.c:3565:15: error: 'alloc_flags' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>>
>> To be honest, I can't figure that out either, maybe it is or
>> maybe not, but moving the existing initialization up a little
>> higher looks safe and makes it obvious to both me and gcc that
>> the initialization comes before the first use.
>>
>> ...
>>
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3591,6 +3591,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  				(__GFP_ATOMIC|__GFP_DIRECT_RECLAIM)))
>>  		gfp_mask &= ~__GFP_ATOMIC;
>>  
>> +	/*
>> +	 * The fast path uses conservative alloc_flags to succeed only until
>> +	 * kswapd needs to be woken up, and to avoid the cost of setting up
>> +	 * alloc_flags precisely. So we do that now.
>> +	 */
>> +	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>> +
>>  retry_cpuset:
>>  	compaction_retries = 0;
>>  	no_progress_loops = 0;
>> @@ -3607,14 +3614,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  	if (!ac->preferred_zoneref->zone)
>>  		goto nopage;
>>  
>> -
>> -	/*
>> -	 * The fast path uses conservative alloc_flags to succeed only until
>> -	 * kswapd needs to be woken up, and to avoid the cost of setting up
>> -	 * alloc_flags precisely. So we do that now.
>> -	 */
>> -	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>> -
>>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>>  		wake_all_kswapds(order, ac);
> 
> hm.  But we later do
> 
> 	if (gfp_pfmemalloc_allowed(gfp_mask))
> 		alloc_flags = ALLOC_NO_WATERMARKS;
> 
> 	...
> 	if (read_mems_allowed_retry(cpuset_mems_cookie))
> 		goto retry_cpuset;
> 
> so with your patch there's a path where we can rerun everything with
> alloc_flags == ALLOC_NO_WATERMARKS.  That's changed behaviour.

Right.

> When I saw the test robot warning I did this, which I think preserves
> behaviour?

Yes, that's cleaner. Thanks.

> --- a/mm/page_alloc.c~mm-consolidate-gfp_nofail-checks-in-the-allocator-slowpath-fix
> +++ a/mm/page_alloc.c
> @@ -3577,6 +3577,14 @@ retry_cpuset:
>  	no_progress_loops = 0;
>  	compact_priority = DEF_COMPACT_PRIORITY;
>  	cpuset_mems_cookie = read_mems_allowed_begin();
> +
> +	/*
> +	 * The fast path uses conservative alloc_flags to succeed only until
> +	 * kswapd needs to be woken up, and to avoid the cost of setting up
> +	 * alloc_flags precisely. So we do that now.
> +	 */
> +	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> +
>  	/*
>  	 * We need to recalculate the starting point for the zonelist iterator
>  	 * because we might have used different nodemask in the fast path, or
> @@ -3588,14 +3596,6 @@ retry_cpuset:
>  	if (!ac->preferred_zoneref->zone)
>  		goto nopage;
>  
> -
> -	/*
> -	 * The fast path uses conservative alloc_flags to succeed only until
> -	 * kswapd needs to be woken up, and to avoid the cost of setting up
> -	 * alloc_flags precisely. So we do that now.
> -	 */
> -	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> -
>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>  		wake_all_kswapds(order, ac);
>  
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
