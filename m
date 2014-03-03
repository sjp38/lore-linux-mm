Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 261DB6B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 08:54:14 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id w61so3245832wes.1
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 05:54:13 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx12si10202620wjc.110.2014.03.03.05.54.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 05:54:12 -0800 (PST)
Message-ID: <53148981.90709@suse.cz>
Date: Mon, 03 Mar 2014 14:54:09 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] mm: add get_pageblock_migratetype_nolock() for cases
 where locking is undesirable
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz> <1393596904-16537-3-git-send-email-vbabka@suse.cz> <20140303082227.GA28899@lge.com>
In-Reply-To: <20140303082227.GA28899@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 03/03/2014 09:22 AM, Joonsoo Kim wrote:
> On Fri, Feb 28, 2014 at 03:15:00PM +0100, Vlastimil Babka wrote:
>> In order to prevent race with set_pageblock_migratetype, most of calls to
>> get_pageblock_migratetype have been moved under zone->lock. For the remaining
>> call sites, the extra locking is undesirable, notably in free_hot_cold_page().
>>
>> This patch introduces a _nolock version to be used on these call sites, where
>> a wrong value does not affect correctness. The function makes sure that the
>> value does not exceed valid migratetype numbers. Such too-high values are
>> assumed to be a result of race and caller-supplied fallback value is returned
>> instead.
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>   include/linux/mmzone.h | 24 ++++++++++++++++++++++++
>>   mm/compaction.c        | 14 +++++++++++---
>>   mm/memory-failure.c    |  3 ++-
>>   mm/page_alloc.c        | 22 +++++++++++++++++-----
>>   mm/vmstat.c            |  2 +-
>>   5 files changed, 55 insertions(+), 10 deletions(-)
>>
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index fac5509..7c3f678 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -75,6 +75,30 @@ enum {
>>
>>   extern int page_group_by_mobility_disabled;
>>
>> +/*
>> + * When called without zone->lock held, a race with set_pageblock_migratetype
>> + * may result in bogus values. Use this variant only when this does not affect
>> + * correctness, and taking zone->lock would be costly. Values >= MIGRATE_TYPES
>> + * are considered to be a result of this race and the value of race_fallback
>> + * argument is returned instead.
>> + */
>> +static inline int get_pageblock_migratetype_nolock(struct page *page,
>> +	int race_fallback)
>> +{
>> +	int ret = get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
>> +
>> +	if (unlikely(ret >= MIGRATE_TYPES))
>> +		ret = race_fallback;
>> +
>> +	return ret;
>> +}
>
> Hello, Vlastimil.
>
> First of all, thanks for nice work!
> I have another opinion about this implementation. It can be wrong, so if it
> is wrong, please let me know.

Thanks, all opinions/reviewing is welcome :)

> Although this implementation would close the race which triggers NULL dereference,
> I think that this isn't enough if you have a plan to add more
> {start,undo}_isolate_page_range().
>
> Consider that there are lots of {start,undo}_isolate_page_range() calls
> on the system without CMA.
>
> bit representation of migratetype is like as following.
>
> MIGRATE_MOVABLE = 010
> MIGRATE_ISOLATE = 100
>
> We could read following values as migratetype of the page on movable pageblock
> if race occurs.
>
> start_isolate_page_range() case: 010 -> 100
> 010, 000, 100
>
> undo_isolate_page_range() case: 100 -> 010
> 100, 110, 010
>
> Above implementation prevents us from getting 110, but, it can't prevent us from
> getting 000, that is, MIGRATE_UNMOVABLE. If this race occurs in free_hot_cold_page(),
> this page would go into unmovable pcp and then allocated for that migratetype.
> It results in more fragmented memory.

Yes, that can happen. But I would expect it to be negligible to other 
causes of fragmentation. But I'm not at this moment sure how often 
{start,undo}_isolate_page_range() would be called in the end. Certainly
not as often as in the development patch which is just to see if that 
can improve anything. Because it will have its own overhead (mostly for 
zone->lock) that might be too large. But good point, I will try to 
quantify this.

>
> Consider another case that system enables CONFIG_CMA,
>
> MIGRATE_MOVABLE = 010
> MIGRATE_ISOLATE = 101
>
> start_isolate_page_range() case: 010 -> 101
> 010, 011, 001, 101
>
> undo_isolate_page_range() case: 101 -> 010
> 101, 100, 110, 010
>
> This can results in totally different values and this also makes the problem
> mentioned above. And, although this doesn't cause any problem on CMA for now,
> if another migratetype is introduced or some migratetype is removed, it can cause
> CMA typed page to go into other migratetype and makes CMA permanently failed.

This should actually be no problem for free_hot_cold_page() as any 
migratetype >= MIGRATE_PCPTYPES will defer to free_one_page() which will 
reread migratetype under zone->lock. So as long as MIGRATE_PCPTYPES does 
not include a migratetype with such dangerous "permanently failed" 
properties, it should be good. And I doubt such migratetype would be 
added to pcptypes. But of course, anyone adding new migratetype would 
have to reconsider each get_pageblock_migratetype_nolock() call for such 
potential problems.

> To close this kind of races without dependency how many pageblock isolation occurs,
> I recommend that you use separate pageblock bits for MIGRATE_CMA, MIGRATE_ISOLATE
> and use accessor function whenver we need to check migratetype. IMHO, it may not
> impose much overhead.

That could work in case the fragmentation is confirmed to be a problem.

Thanks,
Vlastimil

> How about it?
>
> Thanks.
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
