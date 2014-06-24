Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6276B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 11:42:54 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so6040893wib.4
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:42:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fv8si894874wjc.115.2014.06.24.08.42.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 08:42:53 -0700 (PDT)
Message-ID: <53A99C7A.7000806@suse.cz>
Date: Tue, 24 Jun 2014 17:42:50 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/13] mm, compaction: move pageblock checks up from
 isolate_migratepages_range()
References: <1403279383-5862-1-git-send-email-vbabka@suse.cz> <1403279383-5862-5-git-send-email-vbabka@suse.cz> <20140624083325.GG4836@js1304-P5Q-DELUXE>
In-Reply-To: <20140624083325.GG4836@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, linux-kernel@vger.kernel.org

On 06/24/2014 10:33 AM, Joonsoo Kim wrote:
> On Fri, Jun 20, 2014 at 05:49:34PM +0200, Vlastimil Babka wrote:
>> isolate_migratepages_range() is the main function of the compaction scanner,
>> called either on a single pageblock by isolate_migratepages() during regular
>> compaction, or on an arbitrary range by CMA's __alloc_contig_migrate_range().
>> It currently perfoms two pageblock-wide compaction suitability checks, and
>> because of the CMA callpath, it tracks if it crossed a pageblock boundary in
>> order to repeat those checks.
>>
>> However, closer inspection shows that those checks are always true for CMA:
>> - isolation_suitable() is true because CMA sets cc->ignore_skip_hint to true
>> - migrate_async_suitable() check is skipped because CMA uses sync compaction
>>
>> We can therefore move the checks to isolate_migratepages(), reducing variables
>> and simplifying isolate_migratepages_range(). The update_pageblock_skip()
>> function also no longer needs set_unsuitable parameter.
>>
>> Furthermore, going back to compact_zone() and compact_finished() when pageblock
>> is unsuitable is wasteful - the checks are meant to skip pageblocks quickly.
>> The patch therefore also introduces a simple loop into isolate_migratepages()
>> so that it does not return immediately on pageblock checks, but keeps going
>> until isolate_migratepages_range() gets called once. Similarily to
>> isolate_freepages(), the function periodically checks if it needs to reschedule
>> or abort async compaction.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Michal Nazarewicz <mina86@mina86.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: David Rientjes <rientjes@google.com>
>> ---
>>   mm/compaction.c | 112 +++++++++++++++++++++++++++++---------------------------
>>   1 file changed, 59 insertions(+), 53 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 3064a7f..ebe30c9 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -132,7 +132,7 @@ void reset_isolation_suitable(pg_data_t *pgdat)
>>    */
>>   static void update_pageblock_skip(struct compact_control *cc,
>>   			struct page *page, unsigned long nr_isolated,
>> -			bool set_unsuitable, bool migrate_scanner)
>> +			bool migrate_scanner)
>>   {
>>   	struct zone *zone = cc->zone;
>>   	unsigned long pfn;
>> @@ -146,12 +146,7 @@ static void update_pageblock_skip(struct compact_control *cc,
>>   	if (nr_isolated)
>>   		return;
>>
>> -	/*
>> -	 * Only skip pageblocks when all forms of compaction will be known to
>> -	 * fail in the near future.
>> -	 */
>> -	if (set_unsuitable)
>> -		set_pageblock_skip(page);
>> +	set_pageblock_skip(page);
>>
>>   	pfn = page_to_pfn(page);
>>
>> @@ -180,7 +175,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
>>
>>   static void update_pageblock_skip(struct compact_control *cc,
>>   			struct page *page, unsigned long nr_isolated,
>> -			bool set_unsuitable, bool migrate_scanner)
>> +			bool migrate_scanner)
>>   {
>>   }
>>   #endif /* CONFIG_COMPACTION */
>> @@ -345,8 +340,7 @@ isolate_fail:
>>
>>   	/* Update the pageblock-skip if the whole pageblock was scanned */
>>   	if (blockpfn == end_pfn)
>> -		update_pageblock_skip(cc, valid_page, total_isolated, true,
>> -				      false);
>> +		update_pageblock_skip(cc, valid_page, total_isolated, false);
>>
>>   	count_compact_events(COMPACTFREE_SCANNED, nr_scanned);
>>   	if (total_isolated)
>> @@ -474,14 +468,12 @@ unsigned long
>>   isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>>   		unsigned long low_pfn, unsigned long end_pfn, bool unevictable)
>>   {
>> -	unsigned long last_pageblock_nr = 0, pageblock_nr;
>>   	unsigned long nr_scanned = 0, nr_isolated = 0;
>>   	struct list_head *migratelist = &cc->migratepages;
>>   	struct lruvec *lruvec;
>>   	unsigned long flags;
>>   	bool locked = false;
>>   	struct page *page = NULL, *valid_page = NULL;
>> -	bool set_unsuitable = true;
>>   	const isolate_mode_t mode = (cc->mode == MIGRATE_ASYNC ?
>>   					ISOLATE_ASYNC_MIGRATE : 0) |
>>   				    (unevictable ? ISOLATE_UNEVICTABLE : 0);
>> @@ -545,28 +537,6 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
>>   		if (!valid_page)
>>   			valid_page = page;
>>
>> -		/* If isolation recently failed, do not retry */
>> -		pageblock_nr = low_pfn >> pageblock_order;
>> -		if (last_pageblock_nr != pageblock_nr) {
>> -			int mt;
>> -
>> -			last_pageblock_nr = pageblock_nr;
>> -			if (!isolation_suitable(cc, page))
>> -				goto next_pageblock;
>> -
>> -			/*
>> -			 * For async migration, also only scan in MOVABLE
>> -			 * blocks. Async migration is optimistic to see if
>> -			 * the minimum amount of work satisfies the allocation
>> -			 */
>> -			mt = get_pageblock_migratetype(page);
>> -			if (cc->mode == MIGRATE_ASYNC &&
>> -			    !migrate_async_suitable(mt)) {
>> -				set_unsuitable = false;
>> -				goto next_pageblock;
>> -			}
>> -		}
>> -
>>   		/*
>>   		 * Skip if free. page_order cannot be used without zone->lock
>>   		 * as nothing prevents parallel allocations or buddy merging.
>> @@ -668,8 +638,7 @@ next_pageblock:
>>   	 * if the whole pageblock was scanned without isolating any page.
>>   	 */
>>   	if (low_pfn == end_pfn)
>> -		update_pageblock_skip(cc, valid_page, nr_isolated,
>> -				      set_unsuitable, true);
>> +		update_pageblock_skip(cc, valid_page, nr_isolated, true);
>>
>>   	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
>>
>> @@ -840,34 +809,74 @@ typedef enum {
>>   } isolate_migrate_t;
>>
>>   /*
>> - * Isolate all pages that can be migrated from the block pointed to by
>> - * the migrate scanner within compact_control.
>> + * Isolate all pages that can be migrated from the first suitable block,
>> + * starting at the block pointed to by the migrate scanner pfn within
>> + * compact_control.
>>    */
>>   static isolate_migrate_t isolate_migratepages(struct zone *zone,
>>   					struct compact_control *cc)
>>   {
>>   	unsigned long low_pfn, end_pfn;
>> +	struct page *page;
>>
>> -	/* Do not scan outside zone boundaries */
>> -	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
>> +	/* Start at where we last stopped, or beginning of the zone */
>> +	low_pfn = cc->migrate_pfn;
>>
>>   	/* Only scan within a pageblock boundary */
>>   	end_pfn = ALIGN(low_pfn + 1, pageblock_nr_pages);
>>
>> -	/* Do not cross the free scanner or scan within a memory hole */
>> -	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
>> -		cc->migrate_pfn = end_pfn;
>> -		return ISOLATE_NONE;
>> -	}
>> +	/*
>> +	 * Iterate over whole pageblocks until we find the first suitable.
>> +	 * Do not cross the free scanner.
>> +	 */
>> +	for (; end_pfn <= cc->free_pfn;
>> +			low_pfn = end_pfn, end_pfn += pageblock_nr_pages) {
>> +
>> +		/*
>> +		 * This can potentially iterate a massively long zone with
>> +		 * many pageblocks unsuitable, so periodically check if we
>> +		 * need to schedule, or even abort async compaction.
>> +		 */
>> +		if (!(low_pfn % (SWAP_CLUSTER_MAX * pageblock_nr_pages))
>> +						&& compact_should_abort(cc))
>> +			break;
>>
>> -	/* Perform the isolation */
>> -	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn, false);
>> -	if (!low_pfn || cc->contended)
>> -		return ISOLATE_ABORT;
>> +		/* Do not scan within a memory hole */
>> +		if (!pfn_valid(low_pfn))
>> +			continue;
>> +
>> +		page = pfn_to_page(low_pfn);
>> +		/* If isolation recently failed, do not retry */
>> +		if (!isolation_suitable(cc, page))
>> +			continue;
>>
>> +		/*
>> +		 * For async compaction, also only scan in MOVABLE blocks.
>> +		 * Async compaction is optimistic to see if the minimum amount
>> +		 * of work satisfies the allocation.
>> +		 */
>> +		if (cc->mode == MIGRATE_ASYNC &&
>> +		    !migrate_async_suitable(get_pageblock_migratetype(page)))
>> +			continue;
>> +
>> +		/* Perform the isolation */
>> +		low_pfn = isolate_migratepages_range(zone, cc, low_pfn,
>> +								end_pfn, false);
>> +		if (!low_pfn || cc->contended)
>> +			return ISOLATE_ABORT;
>> +
>> +		/*
>> +		 * Either we isolated something and proceed with migration. Or
>> +		 * we failed and compact_zone should decide if we should
>> +		 * continue or not.
>> +		 */
>> +		break;
>> +	}
>> +
>> +	/* Record where migration scanner will be restarted */
>
> If we make isolate_migratepages* interface like as isolate_freepages*,
> we can get more clean and micro optimized code. Because
> isolate_migratepages_range() can handle arbitrary range and this patch
> make isolate_migratepages() also handle arbitrary range, there would
> be some redundant codes. :)

I'm not sure if it's worth already. Where is the arbitrary range adding 
overhead? I can only imagine that next_pageblock: label could do a 
'break;' instead of setting up next_capture_pfn, but that's about it AFAICS.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
