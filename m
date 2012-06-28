Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 53CBA6B007B
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 12:31:20 -0400 (EDT)
Message-ID: <4FEC86BA.9050004@redhat.com>
Date: Thu, 28 Jun 2012 12:30:50 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: have order>0 compaction start off where it left
References: <20120627233742.53225fc7@annuminas.surriel.com> <20120628102919.GQ8103@csn.ul.ie>
In-Reply-To: <20120628102919.GQ8103@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, linux-kernel@vger.kernel.org, jaschut@sandia.gov

On 06/28/2012 06:29 AM, Mel Gorman wrote:

> Lets say there are two parallel compactions running. Process A meets
> the migration PFN and moves to the end of the zone to restart. Process B
> finishes scanning mid-way through the zone and updates last_free_pfn. This
> will cause Process A to "jump" to where Process B left off which is not
> necessarily desirable.
>
> Another side effect is that a workload that allocations/frees
> aggressively will not compact as well as the "free" scanner is not
> scanning the end of the zone each time. It would be better if
> last_free_pfn was updated when a full pageblock was encountered
>
> So;
>
> 1. Initialise last_free_pfn to the end of the zone
> 2. On compaction, scan from last_free_pfn and record where it started
> 3. If a pageblock is full, update last_free_pfn
> 4. If the migration and free scanner meet, reset last_free_pfn and
>     the free scanner. Abort if the free scanner wraps to where it started
>
> Does that make sense?

Yes, that makes sense.  We still have to keep track
of whether we have wrapped around, but I guess that
allows for a better name for the bool :)

Maybe cc->wrapped?

Does anyone have a better name?

As for point (4), should we abort when we wrap
around to where we started, or should we abort
when free_pfn and migrate_pfn meet after we
wrapped around?

>> diff --git a/mm/internal.h b/mm/internal.h
>> index 2ba87fb..b041874 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -120,6 +120,7 @@ struct compact_control {
>>   	unsigned long free_pfn;		/* isolate_freepages search base */
>>   	unsigned long migrate_pfn;	/* isolate_migratepages search base */
>>   	bool sync;			/* Synchronous migration */
>> +	bool last_round;		/* Last round for order>0 compaction */
>>
>
> I don't get what you mean by last_round. Did you mean "wrapped". When
> false, it means the free scanner started from last_pfn and when true it
> means it started from last_pfn, met the migrate scanner and wrapped
> around to the end of the zone?

Yes, I do mean "wrapped" :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
