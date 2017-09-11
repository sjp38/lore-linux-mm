Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5F46B02A2
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 02:50:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d8so15337959pgt.1
        for <linux-mm@kvack.org>; Sun, 10 Sep 2017 23:50:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si6336767plh.191.2017.09.10.23.50.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Sep 2017 23:50:05 -0700 (PDT)
Subject: Re: [patch 2/2] mm, compaction: persistently skip hugetlbfs
 pageblocks
References: <alpine.DEB.2.10.1708151638550.106658@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1708151639130.106658@chino.kir.corp.google.com>
 <fa162335-a36d-153a-7b5d-1d9c2d57aebc@suse.cz>
 <alpine.DEB.2.10.1709101807380.85650@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <41aa727a-7f34-3363-dc5b-a33c161c8933@suse.cz>
Date: Mon, 11 Sep 2017 08:50:01 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1709101807380.85650@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 09/11/2017 03:12 AM, David Rientjes wrote:
> On Wed, 23 Aug 2017, Vlastimil Babka wrote:
> 
>>> diff --git a/mm/compaction.c b/mm/compaction.c
>>> --- a/mm/compaction.c
>>> +++ b/mm/compaction.c
>>> @@ -217,6 +217,20 @@ static void reset_cached_positions(struct zone *zone)
>>>  				pageblock_start_pfn(zone_end_pfn(zone) - 1);
>>>  }
>>>  
>>> +/*
>>> + * Hugetlbfs pages should consistenly be skipped until updated by the hugetlb
>>> + * subsystem.  It is always pointless to compact pages of pageblock_order and
>>> + * the free scanner can reconsider when no longer huge.
>>> + */
>>> +static bool pageblock_skip_persistent(struct page *page, unsigned int order)
>>> +{
>>> +	if (!PageHuge(page))
>>> +		return false;
>>> +	if (order != pageblock_order)
>>> +		return false;
>>> +	return true;
>>
>> Why just HugeTLBfs? There's also no point in migrating/finding free
>> pages in THPs. Actually, any compound page of pageblock order?
>>
> 
> Yes, any page where compound_order(page) == pageblock_order would probably 
> benefit from the same treatment.  I haven't encountered such an issue, 
> however, so I thought it was best to restrict it only to hugetlb: hugetlb 
> memory usually sits in the hugetlb free pool and seldom gets freed under 
> normal conditions even when unmapped whereas thp is much more likely to be 
> unmapped and split.  I wasn't sure that it was worth the pageblock skip.

Well, my thinking is that once we start checking page properties when
resetting the skip bits, we might as well try to get the most of it, as
there's no additional cost.

>>> +}
>>> +
>>>  /*
>>>   * This function is called to clear all cached information on pageblocks that
>>>   * should be skipped for page isolation when the migrate and free page scanner
>>> @@ -241,6 +255,8 @@ static void __reset_isolation_suitable(struct zone *zone)
>>>  			continue;
>>>  		if (zone != page_zone(page))
>>>  			continue;
>>> +		if (pageblock_skip_persistent(page, compound_order(page)))
>>> +			continue;
>>
>> I like the idea of how persistency is achieved by rechecking in the reset.
>>
>>>  
>>>  		clear_pageblock_skip(page);
>>>  	}
>>> @@ -448,13 +464,15 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
>>>  		 * and the only danger is skipping too much.
>>>  		 */
>>>  		if (PageCompound(page)) {
>>> -			unsigned int comp_order = compound_order(page);
>>> -
>>> -			if (likely(comp_order < MAX_ORDER)) {
>>> -				blockpfn += (1UL << comp_order) - 1;
>>> -				cursor += (1UL << comp_order) - 1;
>>> +			const unsigned int order = compound_order(page);
>>> +
>>> +			if (pageblock_skip_persistent(page, order)) {
>>> +				set_pageblock_skip(page);
>>> +				blockpfn = end_pfn;
>>> +			} else if (likely(order < MAX_ORDER)) {
>>> +				blockpfn += (1UL << order) - 1;
>>> +				cursor += (1UL << order) - 1;
>>>  			}
>>
>> Is this new code (and below) really necessary? The existing code should
>> already lead to skip bit being set via update_pageblock_skip()?
>>
> 
> I wanted to set the persistent pageblock skip regardless of 
> cc->ignore_skip_hint without a local change to update_pageblock_skip().

After the first patch, there are no ignore_skip_hint users where it
would make that much difference overriding the flag for some pageblocks
(which this effectively does) at the cost of more complicated code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
