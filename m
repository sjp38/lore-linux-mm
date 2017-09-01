Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08D4C6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 08:32:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 40so126507wrv.4
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 05:32:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p82si40079wmb.175.2017.09.01.05.32.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 05:32:27 -0700 (PDT)
Subject: Re: [patch 2/2] mm, compaction: persistently skip hugetlbfs
 pageblocks
From: Vlastimil Babka <vbabka@suse.cz>
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com>
 <fa162335-a36d-153a-7b5d-1d9c2d57aebc@suse.cz>
Message-ID: <74a33b7b-0586-c08a-cb2e-1c3d2872815d@suse.cz>
Date: Fri, 1 Sep 2017 14:32:25 +0200
MIME-Version: 1.0
In-Reply-To: <fa162335-a36d-153a-7b5d-1d9c2d57aebc@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 08/23/2017 10:41 AM, Vlastimil Babka wrote:
> On 08/16/2017 01:39 AM, David Rientjes wrote:
>> It is pointless to migrate hugetlb memory as part of memory compaction if
>> the hugetlb size is equal to the pageblock order.  No defragmentation is
>> occurring in this condition.
>>
>> It is also pointless to for the freeing scanner to scan a pageblock where
>> a hugetlb page is pinned.  Unconditionally skip these pageblocks, and do
>> so peristently so that they are not rescanned until it is observed that
>> these hugepages are no longer pinned.
>>
>> It would also be possible to do this by involving the hugetlb subsystem
>> in marking pageblocks to no longer be skipped when they hugetlb pages are
>> freed.  This is a simple solution that doesn't involve any additional
>> subsystems in pageblock skip manipulation.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>> ---
>>  mm/compaction.c | 48 +++++++++++++++++++++++++++++++++++++-----------
>>  1 file changed, 37 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -217,6 +217,20 @@ static void reset_cached_positions(struct zone *zone)
>>  				pageblock_start_pfn(zone_end_pfn(zone) - 1);
>>  }
>>  
>> +/*
>> + * Hugetlbfs pages should consistenly be skipped until updated by the hugetlb
>> + * subsystem.  It is always pointless to compact pages of pageblock_order and
>> + * the free scanner can reconsider when no longer huge.
>> + */
>> +static bool pageblock_skip_persistent(struct page *page, unsigned int order)
>> +{
>> +	if (!PageHuge(page))
>> +		return false;
>> +	if (order != pageblock_order)
>> +		return false;
>> +	return true;
> 
> Why just HugeTLBfs? There's also no point in migrating/finding free
> pages in THPs. Actually, any compound page of pageblock order?
> 
>> +}
>> +
>>  /*
>>   * This function is called to clear all cached information on pageblocks that
>>   * should be skipped for page isolation when the migrate and free page scanner
>> @@ -241,6 +255,8 @@ static void __reset_isolation_suitable(struct zone *zone)
>>  			continue;
>>  		if (zone != page_zone(page))
>>  			continue;
>> +		if (pageblock_skip_persistent(page, compound_order(page)))
>> +			continue;
> 
> I like the idea of how persistency is achieved by rechecking in the reset.
> 
>>  
>>  		clear_pageblock_skip(page);
>>  	}
>> @@ -448,13 +464,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>  		 * and the only danger is skipping too much.
>>  		 */
>>  		if (PageCompound(page)) {
>> -			unsigned int comp_order = compound_order(page);
>> -
>> -			if (likely(comp_order < MAX_ORDER)) {
>> -				blockpfn += (1UL << comp_order) - 1;
>> -				cursor += (1UL << comp_order) - 1;
>> +			const unsigned int order = compound_order(page);
>> +
>> +			if (pageblock_skip_persistent(page, order)) {
>> +				set_pageblock_skip(page);
>> +				blockpfn = end_pfn;
>> +			} else if (likely(order < MAX_ORDER)) {
>> +				blockpfn += (1UL << order) - 1;
>> +				cursor += (1UL << order) - 1;
>>  			}
> 
> Is this new code (and below) really necessary? The existing code should
> already lead to skip bit being set via update_pageblock_skip()?
 
Ok, here's a patch implementing my suggestions.

----8<----
