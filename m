Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2D56B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 05:39:59 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so896619wgg.19
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 02:39:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk4si4159161wib.8.2014.07.30.02.39.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 02:39:57 -0700 (PDT)
Message-ID: <53D8BD6B.8040704@suse.cz>
Date: Wed, 30 Jul 2014 11:39:55 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v5 05/14] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
References: <1406553101-29326-1-git-send-email-vbabka@suse.cz> <1406553101-29326-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1407281709050.8998@chino.kir.corp.google.com> <53D7690D.5070307@suse.cz> <alpine.DEB.2.02.1407291559130.20991@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1407291559130.20991@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 07/30/2014 01:02 AM, David Rientjes wrote:
>>>>
>>>>    /*
>>>> - * Isolate all pages that can be migrated from the block pointed to by
>>>> - * the migrate scanner within compact_control.
>>>> + * Isolate all pages that can be migrated from the first suitable block,
>>>> + * starting at the block pointed to by the migrate scanner pfn within
>>>> + * compact_control.
>>>>     */
>>>>    static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>>>    					struct compact_control *cc)
>>>>    {
>>>>    	unsigned long low_pfn, end_pfn;
>>>> +	struct page *page;
>>>> +	const isolate_mode_t isolate_mode =
>>>> +		(cc->mode == MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
>>>>
>>>> -	/* Do not scan outside zone boundaries */
>>>> -	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
>>>> +	/*
>>>> +	 * Start at where we last stopped, or beginning of the zone as
>>>> +	 * initialized by compact_zone()
>>>> +	 */
>>>> +	low_pfn = cc->migrate_pfn;
>>>>
>>>>    	/* Only scan within a pageblock boundary */
>>>>    	end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
>>>>
>>>> -	/* Do not cross the free scanner or scan within a memory hole */
>>>> -	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
>>>> -		cc->migrate_pfn = end_pfn;
>>>> -		return ISOLATE_NONE;
>>>> -	}
>>>> +	/*
>>>> +	 * Iterate over whole pageblocks until we find the first suitable.
>>>> +	 * Do not cross the free scanner.
>>>> +	 */
>>>> +	for (; end_pfn <= cc->free_pfn;
>>>> +			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
>>>> +
>>>> +		/*
>>>> +		 * This can potentially iterate a massively long zone with
>>>> +		 * many pageblocks unsuitable, so periodically check if we
>>>> +		 * need to schedule, or even abort async compaction.
>>>> +		 */
>>>> +		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
>>>> +						&& compact_should_abort(cc))
>>>> +			break;
>>>> +
>>>> +		/* Skip whole pageblock in case of a memory hole */
>>>> +		if (!pfn_valid(low_pfn))
>>>> +			continue;
>>>> +
>>>> +		page = pfn_to_page(low_pfn);
>>>> +
>>>> +		/* If isolation recently failed, do not retry */
>>>> +		if (!isolation_suitable(cc, page))
>>>> +			continue;
>>>> +
>>>> +		/*
>>>> +		 * For async compaction, also only scan in MOVABLE blocks.
>>>> +		 * Async compaction is optimistic to see if the minimum amount
>>>> +		 * of work satisfies the allocation.
>>>> +		 */
>>>> +		if (cc->mode == MIGRATE_ASYNC &&
>>>> +		    !migrate_async_suitable(get_pageblock_migratetype(page)))
>>>> +			continue;
>>>> +
>>>> +		/* Perform the isolation */
>>>> +		low_pfn = isolate_migratepages_block(cc, low_pfn, end_pfn,
>>>> +								isolate_mode);
>>>
>>> Hmm, why would we want to unconditionally set pageblock_skip if no pages
>>> could be isolated from a pageblock when
>>> isolate_mode == ISOLATE_ASYNC_MIGRATE?  It seems like it erroneously skip
>>> pageblocks for cases when isolate_mode == 0.
>>
>> Well pageblock_skip is a single bit and you don't know if the next attempt
>> will be async or sync. So now you would maybe skip needlessly if the next
>> attempt would be sync. If we changed that, you wouldn't skip if the next
>> attempt would be async again. Could be that one way is better than other but
>> I'm not sure, and would consider it separately.
>> The former patch 15 (quick skip pageblock that won't be fully migrated) could
>> perhaps change the balance here.
>>
>
> That's why we have two separate per-zone cached start pfns, though, right?
> The next call to async compaction should start from where the previous
> caller left off so there would be no need to set pageblock skip in that
> case until we have checked all memory.  Or are you considering the case of
> concurrent async compaction?

Ah, well the lifecycle of cached pfn's and pageblock_skip is not 
generally in sync. It may be that cached pfn's are reset, but 
pageblock_skip bits remain. So this would be one async pass setting 
hints for the next async pass.

But maybe we've already reduced the impact of sync compaction enough so 
it could now be ignoring pageblock_skip completely, and leave those 
hints only for async compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
