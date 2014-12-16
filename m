Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D3A8A6B0095
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 19:09:04 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so12915200pab.30
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 16:09:04 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id uv10si16208211pac.39.2014.12.15.16.09.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 16:09:03 -0800 (PST)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id A751C3EE194
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 09:09:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id B8804AC04E8
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 09:08:59 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C96B1DB8040
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 09:08:59 +0900 (JST)
Message-ID: <548F7805.5000509@jp.fujitsu.com>
Date: Tue, 16 Dec 2014 09:08:37 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't alter
 arg gfp_mask
References: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org>	<548F6F94.2020209@jp.fujitsu.com> <20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>
In-Reply-To: <20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com

(2014/12/16 8:43), Andrew Morton wrote:
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
>
> This?

Looks good to me.

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

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
