Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id ABE8A6B0070
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 10:59:57 -0400 (EDT)
Message-ID: <4FF308CE.4070209@redhat.com>
Date: Tue, 03 Jul 2012 10:59:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off where
 it left
References: <20120628135520.0c48b066@annuminas.surriel.com> <4FECE844.2050803@kernel.org>
In-Reply-To: <4FECE844.2050803@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com

On 06/28/2012 07:27 PM, Minchan Kim wrote:

>> index 7ea259d..2668b77 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -422,6 +422,17 @@ static void isolate_freepages(struct zone *zone,
>>   					pfn -= pageblock_nr_pages) {
>>   		unsigned long isolated;
>>
>> +		/*
>> +		 * Skip ahead if another thread is compacting in the area
>> +		 * simultaneously. If we wrapped around, we can only skip
>> +		 * ahead if zone->compact_cached_free_pfn also wrapped to
>> +		 * above our starting point.
>> +		 */
>> +		if (cc->order>  0&&  (!cc->wrapped ||
>
>
> So if (partial_compaction(cc)&&  ... ) or if (!full_compaction(cc)&&   ...

I am not sure that we want to abstract away what is happening
here.  We also are quite explicit with the meaning of cc->order
in compact_finished and other places in the compaction code.

>> +				      zone->compact_cached_free_pfn>
>> +				      cc->start_free_pfn))
>> +			pfn = min(pfn, zone->compact_cached_free_pfn);
>
>
> The pfn can be where migrate_pfn below?
> I mean we need this?
>
> if (pfn<= low_pfn)
> 	goto out;

That is a good point. I guess there is a small possibility that
another compaction thread is below us with cc->free_pfn and
cc->migrate_pfn, and we just inherited its cc->free_pfn via
zone->compact_cached_free_pfn, bringing us to below our own
cc->migrate_pfn.

Given that this was already possible with parallel compaction
in the past, I am not sure how important it is. It could result
in wasting a little bit of CPU, but your fix for it looks easy
enough.

Mel, any downside to compaction bailing (well, wrapping around)
a little earlier, like Minchan suggested?

>> @@ -463,6 +474,8 @@ static void isolate_freepages(struct zone *zone,
>>   		 */
>>   		if (isolated)
>>   			high_pfn = max(high_pfn, pfn);
>> +		if (cc->order>  0)
>> +			zone->compact_cached_free_pfn = high_pfn;
>
>
> Why do we cache high_pfn instead of pfn?

Reading the code, because we may not have isolated every
possible free page from this memory block.  The same reason
cc->free_pfn is set to high_pfn right before the function
exits.

> If we can't isolate any page, compact_cached_free_pfn would become low_pfn.
> I expect it's not what you want.

I guess we should only cache the value of high_pfn if
we isolated some pages?  In other words, this:

	if (isolated) {
		high_pfn = max(high_pfn, pfn);
		if (cc->order > 0)
			zone->compact_cached_free_pfn = high_pfn;
	}


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
