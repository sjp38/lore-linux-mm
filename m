Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id C88A06B0073
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 08:26:44 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wo20so12907525obc.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 05:26:44 -0800 (PST)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id l124si9239881oig.85.2015.02.02.05.26.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 05:26:43 -0800 (PST)
Received: by mail-ob0-f180.google.com with SMTP id vb8so16368999obc.11
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 05:26:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54CF4A95.4090504@suse.cz>
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1422861348-5117-2-git-send-email-iamjoonsoo.kim@lge.com>
	<54CF4A95.4090504@suse.cz>
Date: Mon, 2 Feb 2015 22:26:43 +0900
Message-ID: <CAAmzW4MJOZOs2RuWjmBV1vrzyLGd4Fb89TYaCUi89O7LcKV2Og@mail.gmail.com>
Subject: Re: [RFC PATCH v3 2/3] mm/page_alloc: factor out fallback freepage checking
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2015-02-02 18:59 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 02/02/2015 08:15 AM, Joonsoo Kim wrote:
>> This is preparation step to use page allocator's anti fragmentation logic
>> in compaction. This patch just separates fallback freepage checking part
>> from fallback freepage management part. Therefore, there is no functional
>> change.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  mm/page_alloc.c | 128 +++++++++++++++++++++++++++++++++-----------------------
>>  1 file changed, 76 insertions(+), 52 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index e64b260..6cb18f8 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1142,14 +1142,26 @@ static void change_pageblock_range(struct page *pageblock_page,
>>   * as fragmentation caused by those allocations polluting movable pageblocks
>>   * is worse than movable allocations stealing from unmovable and reclaimable
>>   * pageblocks.
>> - *
>> - * If we claim more than half of the pageblock, change pageblock's migratetype
>> - * as well.
>>   */
>> -static void try_to_steal_freepages(struct zone *zone, struct page *page,
>> -                               int start_type, int fallback_type)
>> +static bool can_steal_fallback(unsigned int order, int start_mt)
>> +{
>> +     if (order >= pageblock_order)
>> +             return true;
>> +
>> +     if (order >= pageblock_order / 2 ||
>> +             start_mt == MIGRATE_RECLAIMABLE ||
>> +             start_mt == MIGRATE_UNMOVABLE ||
>> +             page_group_by_mobility_disabled)
>> +             return true;
>> +
>> +     return false;
>> +}
>> +
>> +static void steal_suitable_fallback(struct zone *zone, struct page *page,
>> +                                                       int start_type)
>
> Some comment about the function please?

Okay.

>>  {
>>       int current_order = page_order(page);
>> +     int pages;
>>
>>       /* Take ownership for orders >= pageblock_order */
>>       if (current_order >= pageblock_order) {
>> @@ -1157,19 +1169,39 @@ static void try_to_steal_freepages(struct zone *zone, struct page *page,
>>               return;
>>       }
>>
>> -     if (current_order >= pageblock_order / 2 ||
>> -         start_type == MIGRATE_RECLAIMABLE ||
>> -         start_type == MIGRATE_UNMOVABLE ||
>> -         page_group_by_mobility_disabled) {
>> -             int pages;
>> +     pages = move_freepages_block(zone, page, start_type);
>>
>> -             pages = move_freepages_block(zone, page, start_type);
>> +     /* Claim the whole block if over half of it is free */
>> +     if (pages >= (1 << (pageblock_order-1)) ||
>> +                     page_group_by_mobility_disabled)
>> +             set_pageblock_migratetype(page, start_type);
>> +}
>>
>> -             /* Claim the whole block if over half of it is free */
>> -             if (pages >= (1 << (pageblock_order-1)) ||
>> -                             page_group_by_mobility_disabled)
>> -                     set_pageblock_migratetype(page, start_type);
>> +static int find_suitable_fallback(struct free_area *area, unsigned int order,
>> +                                     int migratetype, bool *can_steal)
>
> Same here.

Okay.

>> +{
>> +     int i;
>> +     int fallback_mt;
>> +
>> +     if (area->nr_free == 0)
>> +             return -1;
>> +
>> +     *can_steal = false;
>> +     for (i = 0;; i++) {
>> +             fallback_mt = fallbacks[migratetype][i];
>> +             if (fallback_mt == MIGRATE_RESERVE)
>> +                     break;
>> +
>> +             if (list_empty(&area->free_list[fallback_mt]))
>> +                     continue;
>> +
>> +             if (can_steal_fallback(order, migratetype))
>> +                     *can_steal = true;
>> +
>> +             return i;
>
> You want to return fallback_mt, not 'i', no?

Yes. I will fix it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
