Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7888B6B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 08:29:09 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id nt9so13104626obb.3
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 05:29:09 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id eo8si9261501oeb.9.2015.02.02.05.29.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 05:29:08 -0800 (PST)
Received: by mail-oi0-f46.google.com with SMTP id a141so44274205oig.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 05:29:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <BLU436-SMTP50EE37851DFB83686A33A3833C0@phx.gbl>
References: <1422861348-5117-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1422861348-5117-2-git-send-email-iamjoonsoo.kim@lge.com>
	<BLU436-SMTP50EE37851DFB83686A33A3833C0@phx.gbl>
Date: Mon, 2 Feb 2015 22:29:08 +0900
Message-ID: <CAAmzW4Ms1ge4LDHL0vzv+VZLwu2R1t8R=oOm9uSq7iq1ZO2oMA@mail.gmail.com>
Subject: Re: [RFC PATCH v3 2/3] mm/page_alloc: factor out fallback freepage checking
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.ok@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2015-02-02 21:56 GMT+09:00 Zhang Yanfei <zhangyanfei.ok@hotmail.com>:
> Hello Joonsoo,
>
> At 2015/2/2 15:15, Joonsoo Kim wrote:
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
>
> Is this test necessary? Since an order which is >= pageblock_order
> will always pass the order >= pageblock_order / 2 test below.
>

Yes, that's true. But, I'd like to remain code as is, because
condition "order >= pageblock_order / 2" is really heuristic and could
be changed someday. Instead of removing it, I will add some comment on it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
