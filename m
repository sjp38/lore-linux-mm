Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0D06B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 11:25:13 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l89so34722529lfi.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 08:25:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ue1si1369800wjc.178.2016.07.20.08.25.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 08:25:11 -0700 (PDT)
Subject: Re: [PATCH 3/8] mm, page_alloc: don't retry initial attempt in
 slowpath
References: <20160718112302.27381-1-vbabka@suse.cz>
 <20160718112302.27381-4-vbabka@suse.cz>
 <alpine.DEB.2.10.1607191532520.19940@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7f97c5e0-731c-0431-e9f6-b53cd8f87f61@suse.cz>
Date: Wed, 20 Jul 2016 17:25:07 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1607191532520.19940@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On 07/20/2016 12:36 AM, David Rientjes wrote:
> On Mon, 18 Jul 2016, Vlastimil Babka wrote:
> 
>> After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
>> first tries get_page_from_freelist() with the new alloc_flags, as it may
>> succeed e.g. due to using min watermark instead of low watermark. It makes
>> sense to to do this attempt before adjusting zonelist based on
>> alloc_flags/gfp_mask, as it's still relatively a fast path if we just wake up
>> kswapd and successfully allocate.
>>
>> This patch therefore moves the initial attempt above the retry label and
>> reorganizes a bit the part below the retry label. We still have to attempt
>> get_page_from_freelist() on each retry, as some allocations cannot do that
>> as part of direct reclaim or compaction, and yet are not allowed to fail
>> (even though they do a WARN_ON_ONCE() and thus should not exist). We can reuse
>> the call meant for ALLOC_NO_WATERMARKS attempt and just set alloc_flags to
>> ALLOC_NO_WATERMARKS if the context allows it. As a side-effect, the attempts
>> from direct reclaim/compaction will also no longer obey watermarks once this
>> is set, but there's little harm in that.
>>
>> Kswapd wakeups are also done on each retry to be safe from potential races
>> resulting in kswapd going to sleep while a process (that may not be able to
>> reclaim by itself) is still looping.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  mm/page_alloc.c | 29 ++++++++++++++++++-----------
>>  1 file changed, 18 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index eb1968a1041e..30443804f156 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3541,35 +3541,42 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>>  	 */
>>  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
>>  
>> +	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>> +		wake_all_kswapds(order, ac);
>> +
>> +	/*
>> +	 * The adjusted alloc_flags might result in immediate success, so try
>> +	 * that first
>> +	 */
>> +	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
>> +	if (page)
>> +		goto got_pg;
> 
> Any reason to not test gfp_pfmemalloc_allowed() here?  For contexts where 
> it returns true, it seems like the above would be an unneeded failure if 
> ALLOC_WMARK_MIN would have failed.  No strong opinion.

Yeah, two reasons:
1 - less overhead (for the test) if we went to slowpath just to wake up
kswapd and then succeed on min watermark
2 - try all zones with min watermark before resorting to no watermark
(if allowed), so we don't needlessly put below min watermark the first
zone in zonelist, while some later zone would still be above watermark

> 
>> +
>> +
>>  retry:
>> +	/* Ensure kswapd doesn't accidentally go to sleep as long as we loop */
>>  	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
>>  		wake_all_kswapds(order, ac);
>>  
>> +	if (gfp_pfmemalloc_allowed(gfp_mask))
>> +		alloc_flags = ALLOC_NO_WATERMARKS;
>> +
>>  	/*
>>  	 * Reset the zonelist iterators if memory policies can be ignored.
>>  	 * These allocations are high priority and system rather than user
>>  	 * orientated.
>>  	 */
>> -	if (!(alloc_flags & ALLOC_CPUSET) || gfp_pfmemalloc_allowed(gfp_mask)) {
>> +	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
> 
> Do we need to test ALLOC_NO_WATERMARKS here, or is it just for clarity?

I didn't realize it's redundant, but would keep for clarity and
robustness anyway.

> 
> Otherwise looks good!

Thanks!

>>  		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
>>  		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
>>  					ac->high_zoneidx, ac->nodemask);
>>  	}
>>  
>> -	/* This is the last chance, in general, before the goto nopage. */
>> +	/* Attempt with potentially adjusted zonelist and alloc_flags */
>>  	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
>>  	if (page)
>>  		goto got_pg;
>>  
>> -	/* Allocate without watermarks if the context allows */
>> -	if (gfp_pfmemalloc_allowed(gfp_mask)) {
>> -
>> -		page = get_page_from_freelist(gfp_mask, order,
>> -						ALLOC_NO_WATERMARKS, ac);
>> -		if (page)
>> -			goto got_pg;
>> -	}
>> -
>>  	/* Caller is not willing to reclaim, we can't balance anything */
>>  	if (!can_direct_reclaim) {
>>  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
