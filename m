Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 764B344060D
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:10:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so2750129wmi.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:10:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 196si2208763wmg.65.2017.02.17.08.10.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 08:10:00 -0800 (PST)
Subject: Re: [PATCH v2 04/10] mm, page_alloc: count movable pages when
 stealing from pageblock
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-5-vbabka@suse.cz> <20170214181030.GE2450@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a0a3f023-956d-a558-c3ab-53ae8b709b68@suse.cz>
Date: Fri, 17 Feb 2017 17:09:57 +0100
MIME-Version: 1.0
In-Reply-To: <20170214181030.GE2450@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/14/2017 07:10 PM, Johannes Weiner wrote:
> 
> That makes sense to me. I have just one nit about the patch:
> 
>> @@ -1981,10 +1994,29 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>>  		return;
>>  	}
>>  
>> -	pages = move_freepages_block(zone, page, start_type);
>> +	free_pages = move_freepages_block(zone, page, start_type,
>> +						&good_pages);
>> +	/*
>> +	 * good_pages is now the number of movable pages, but if we
>> +	 * want UNMOVABLE or RECLAIMABLE allocation, it's more tricky
>> +	 */
>> +	if (start_type != MIGRATE_MOVABLE) {
>> +		/*
>> +		 * If we are falling back to MIGRATE_MOVABLE pageblock,
>> +		 * treat all non-movable pages as good. If it's UNMOVABLE
>> +		 * falling back to RECLAIMABLE or vice versa, be conservative
>> +		 * as we can't distinguish the exact migratetype.
>> +		 */
>> +		old_block_type = get_pageblock_migratetype(page);
>> +		if (old_block_type == MIGRATE_MOVABLE)
>> +			good_pages = pageblock_nr_pages
>> +						- free_pages - good_pages;
> 
> This line had me scratch my head for a while, and I think it's mostly
> because of the variable naming and the way the comments are phrased.
> 
> Could you use a variable called movable_pages to pass to and be filled
> in by move_freepages_block?
> 
> And instead of good_pages something like starttype_pages or
> alike_pages or st_pages or mt_pages or something, to indicate the
> number of pages that are comparable to the allocation's migratetype?
> 
>> -	/* Claim the whole block if over half of it is free */
>> -	if (pages >= (1 << (pageblock_order-1)) ||
>> +	/* Claim the whole block if over half of it is free or good type */
>> +	if (free_pages + good_pages >= (1 << (pageblock_order-1)) ||
>>  			page_group_by_mobility_disabled)
>>  		set_pageblock_migratetype(page, start_type);
> 
> This would then read
> 
> 	if (free_pages + alike_pages ...)
> 
> which I think would be more descriptive.
> 
> The comment leading the entire section following move_freepages_block
> could then say something like "If a sufficient number of pages in the
> block are either free or of comparable migratability as our
> allocation, claim the whole block." Followed by the caveats of how we
> determine this migratibility.
> 
> Or maybe even the function. The comment above the function seems out
> of date after this patch.

I'll incorporate this for the next posting, thanks for the feedback!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
