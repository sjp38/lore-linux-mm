Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A1A4F6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 12:13:18 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l95so4074054wrc.12
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 09:13:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f185si7765377wma.135.2017.03.29.09.13.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 09:13:17 -0700 (PDT)
Subject: Re: [PATCH v3 8/8] mm, compaction: finish whole pageblock to reduce
 fragmentation
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-9-vbabka@suse.cz>
 <20170316021814.GD14063@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d224471c-0369-c967-fc83-b34ab49b245f@suse.cz>
Date: Wed, 29 Mar 2017 18:13:14 +0200
MIME-Version: 1.0
In-Reply-To: <20170316021814.GD14063@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

On 03/16/2017 03:18 AM, Joonsoo Kim wrote:
> On Tue, Mar 07, 2017 at 02:15:45PM +0100, Vlastimil Babka wrote:
>> The main goal of direct compaction is to form a high-order page for allocation,
>> but it should also help against long-term fragmentation when possible. Most
>> lower-than-pageblock-order compactions are for non-movable allocations, which
>> means that if we compact in a movable pageblock and terminate as soon as we
>> create the high-order page, it's unlikely that the fallback heuristics will
>> claim the whole block. Instead there might be a single unmovable page in a
>> pageblock full of movable pages, and the next unmovable allocation might pick
>> another pageblock and increase long-term fragmentation.
>> 
>> To help against such scenarios, this patch changes the termination criteria for
>> compaction so that the current pageblock is finished even though the high-order
>> page already exists. Note that it might be possible that the high-order page
>> formed elsewhere in the zone due to parallel activity, but this patch doesn't
>> try to detect that.
>> 
>> This is only done with sync compaction, because async compaction is limited to
>> pageblock of the same migratetype, where it cannot result in a migratetype
>> fallback. (Async compaction also eagerly skips order-aligned blocks where
>> isolation fails, which is against the goal of migrating away as much of the
>> pageblock as possible.)
>> 
>> As a result of this patch, long-term memory fragmentation should be reduced.
>> 
>> In testing based on 4.9 kernel with stress-highalloc from mmtests configured
>> for order-4 GFP_KERNEL allocations, this patch has reduced the number of
>> unmovable allocations falling back to movable pageblocks by 20%. The number
>> 
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> Acked-by: Mel Gorman <mgorman@techsingularity.net>
>> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>> ---
>>  mm/compaction.c | 36 ++++++++++++++++++++++++++++++++++--
>>  mm/internal.h   |  1 +
>>  2 files changed, 35 insertions(+), 2 deletions(-)
>> 
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 2c288e75840d..bc7903130501 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -1318,6 +1318,17 @@ static enum compact_result __compact_finished(struct zone *zone,
>>  	if (is_via_compact_memory(cc->order))
>>  		return COMPACT_CONTINUE;
>>  
>> +	if (cc->finishing_block) {
>> +		/*
>> +		 * We have finished the pageblock, but better check again that
>> +		 * we really succeeded.
>> +		 */
>> +		if (IS_ALIGNED(cc->migrate_pfn, pageblock_nr_pages))
>> +			cc->finishing_block = false;
>> +		else
>> +			return COMPACT_CONTINUE;
>> +	}
>> +
>>  	/* Direct compactor: Is a suitable page free? */
>>  	for (order = cc->order; order < MAX_ORDER; order++) {
>>  		struct free_area *area = &zone->free_area[order];
>> @@ -1338,8 +1349,29 @@ static enum compact_result __compact_finished(struct zone *zone,
>>  		 * other migratetype buddy lists.
>>  		 */
>>  		if (find_suitable_fallback(area, order, migratetype,
>> -						true, &can_steal) != -1)
>> -			return COMPACT_SUCCESS;
>> +						true, &can_steal) != -1) {
>> +
>> +			/* movable pages are OK in any pageblock */
>> +			if (migratetype == MIGRATE_MOVABLE)
>> +				return COMPACT_SUCCESS;
>> +
>> +			/*
>> +			 * We are stealing for a non-movable allocation. Make
>> +			 * sure we finish compacting the current pageblock
>> +			 * first so it is as free as possible and we won't
>> +			 * have to steal another one soon. This only applies
>> +			 * to sync compaction, as async compaction operates
>> +			 * on pageblocks of the same migratetype.
>> +			 */
>> +			if (cc->mode == MIGRATE_ASYNC ||
>> +					IS_ALIGNED(cc->migrate_pfn,
>> +							pageblock_nr_pages)) {
>> +				return COMPACT_SUCCESS;
>> +			}
> 
> If cc->migratetype and cc->migrate_pfn's migratetype is the same, stopping
> the compaction here doesn't cause any fragmentation. Do we need to
> compact full pageblock in this case?

Probably not, but if we make patch 7/8 less aggressive, then I'd rather keep
this chance of clearing a whole unmovable pageblock of movable pages.

I also realized that the finishing_block flag is just an unnecessary
complication. Just keep going until migrate_pfn hits the end of pageblock, and
only then check the termination criteria.

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
