Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id A18126B0070
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 05:47:14 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so19534010wgh.26
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 02:47:14 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v13si5888963wjw.146.2014.12.17.02.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 02:47:13 -0800 (PST)
Message-ID: <54915F2F.5050408@suse.cz>
Date: Wed, 17 Dec 2014 11:47:11 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't alter
 arg gfp_mask
References: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org>	<548F6F94.2020209@jp.fujitsu.com> <20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>
In-Reply-To: <20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com

On 12/16/2014 12:43 AM, Andrew Morton wrote:
> On Tue, 16 Dec 2014 08:32:36 +0900 Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> wrote:
>
>> (2014/12/16 8:03), akpm@linux-foundation.org wrote:
>>> From: Andrew Morton <akpm@linux-foundation.org>
>>> Subject: mm/page_alloc.c:__alloc_pages_nodemask(): don't alter arg gfp_mask
>>>
>>> __alloc_pages_nodemask() strips __GFP_IO when retrying the page
>>> allocation.  But it does this by altering the function-wide variable
>>> gfp_mask.  This will cause subsequent allocation attempts to inadvertently
>>> use the modified gfp_mask.
>>>
>>> Cc: Ming Lei <ming.lei@canonical.com>
>>> Cc: Mel Gorman <mel@csn.ul.ie>
>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>> ---
>>>
>>>    mm/page_alloc.c |    5 +++--
>>>    1 file changed, 3 insertions(+), 2 deletions(-)
>>>
>>> diff -puN mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask mm/page_alloc.c
>>> --- a/mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask
>>> +++ a/mm/page_alloc.c
>>> @@ -2918,8 +2918,9 @@ retry_cpuset:
>>>    		 * can deadlock because I/O on the device might not
>>>    		 * complete.
>>>    		 */
>>> -		gfp_mask = memalloc_noio_flags(gfp_mask);
>>> -		page = __alloc_pages_slowpath(gfp_mask, order,
>>
>>> +		gfp_t mask = memalloc_noio_flags(gfp_mask);
>>> +
>>> +		page = __alloc_pages_slowpath(mask, order,
>>>    				zonelist, high_zoneidx, nodemask,
>>>    				preferred_zone, classzone_idx, migratetype);
>>>    	}
>>
>> After allocating page, trace_mm_page_alloc(page, order, gfp_mask, migratetype)
>> is called. But mask is not passed to it. So trace_mm_page_alloc traces wrong
>> gfp_mask.
>
> Well it was already wrong because the first allocation attempt uses
> gfp_mask|__GFP_HARDWAL, but we only trace gfp_mask.

If we wanted to be 100% correct with the tracepoint, then there's also 
__alloc_pages_may_oom(), which also appends __GFP_HARDWALL on the fly

         page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,

But fixing that would be ugly :/ I guess it's not worth the trouble.

> This?
>
> --- a/mm/page_alloc.c~mm-page_allocc-__alloc_pages_nodemask-dont-alter-arg-gfp_mask-fix
> +++ a/mm/page_alloc.c
> @@ -2877,6 +2877,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
>   	unsigned int cpuset_mems_cookie;
>   	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
>   	int classzone_idx;
> +	gfp_t mask;
>
>   	gfp_mask &= gfp_allowed_mask;
>
> @@ -2910,23 +2911,24 @@ retry_cpuset:
>   	classzone_idx = zonelist_zone_idx(preferred_zoneref);
>
>   	/* First allocation attempt */
> -	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
> -			zonelist, high_zoneidx, alloc_flags,
> -			preferred_zone, classzone_idx, migratetype);
> +	mask = gfp_mask|__GFP_HARDWALL;
> +	page = get_page_from_freelist(mask, nodemask, order, zonelist,
> +			high_zoneidx, alloc_flags, preferred_zone,
> +			classzone_idx, migratetype);
>   	if (unlikely(!page)) {
>   		/*
>   		 * Runtime PM, block IO and its error handling path
>   		 * can deadlock because I/O on the device might not
>   		 * complete.
>   		 */
> -		gfp_t mask = memalloc_noio_flags(gfp_mask);
> +		mask = memalloc_noio_flags(gfp_mask);
>
>   		page = __alloc_pages_slowpath(mask, order,
>   				zonelist, high_zoneidx, nodemask,
>   				preferred_zone, classzone_idx, migratetype);
>   	}
>
> -	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
> +	trace_mm_page_alloc(page, order, mask, migratetype);
>
>   out:
>   	/*
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
