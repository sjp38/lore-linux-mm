Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 175D46B025F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:47:54 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id x189so211785031ywe.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:47:54 -0700 (PDT)
Received: from mail-vk0-x244.google.com (mail-vk0-x244.google.com. [2607:f8b0:400c:c05::244])
        by mx.google.com with ESMTPS id t127si969346vkg.203.2016.06.03.05.47.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 05:47:53 -0700 (PDT)
Received: by mail-vk0-x244.google.com with SMTP id m81so13156699vka.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 05:47:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b548cad8-e7d1-b742-cb29-caf6263cc65d@suse.cz>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-2-git-send-email-iamjoonsoo.kim@lge.com> <b548cad8-e7d1-b742-cb29-caf6263cc65d@suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Fri, 3 Jun 2016 21:47:52 +0900
Message-ID: <CAAmzW4NrJ8jFckmMdF+RY-++uoZ=RCpB34OF9+6=DEt1pSkQuw@mail.gmail.com>
Subject: Re: [PATCH v2 2/7] mm/page_owner: initialize page owner without
 holding the zone lock
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-06-03 19:23 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 05/26/2016 04:37 AM, js1304@gmail.com wrote:
>>
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> It's not necessary to initialized page_owner with holding the zone lock.
>> It would cause more contention on the zone lock although it's not
>> a big problem since it is just debug feature. But, it is better
>> than before so do it. This is also preparation step to use stackdepot
>> in page owner feature. Stackdepot allocates new pages when there is no
>> reserved space and holding the zone lock in this case will cause deadlock.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  mm/compaction.c     | 3 +++
>>  mm/page_alloc.c     | 2 --
>>  mm/page_isolation.c | 9 ++++++---
>>  3 files changed, 9 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 8e013eb..6043ef8 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -20,6 +20,7 @@
>>  #include <linux/kasan.h>
>>  #include <linux/kthread.h>
>>  #include <linux/freezer.h>
>> +#include <linux/page_owner.h>
>>  #include "internal.h"
>>
>>  #ifdef CONFIG_COMPACTION
>> @@ -80,6 +81,8 @@ static void map_pages(struct list_head *list)
>>                 arch_alloc_page(page, order);
>>                 kernel_map_pages(page, nr_pages, 1);
>>                 kasan_alloc_pages(page, order);
>> +
>> +               set_page_owner(page, order, __GFP_MOVABLE);
>>                 if (order)
>>                         split_page(page, order);
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 5134f46..1b1ca57 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -2507,8 +2507,6 @@ int __isolate_free_page(struct page *page, unsigned
>> int order)
>>         zone->free_area[order].nr_free--;
>>         rmv_page_order(page);
>>
>> -       set_page_owner(page, order, __GFP_MOVABLE);
>> -
>>         /* Set the pageblock if the isolated page is at least a pageblock
>> */
>>         if (order >= pageblock_order - 1) {
>>                 struct page *endpage = page + (1 << order) - 1;
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 612122b..927f5ee 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -7,6 +7,7 @@
>>  #include <linux/pageblock-flags.h>
>>  #include <linux/memory.h>
>>  #include <linux/hugetlb.h>
>> +#include <linux/page_owner.h>
>>  #include "internal.h"
>>
>>  #define CREATE_TRACE_POINTS
>> @@ -108,8 +109,6 @@ static void unset_migratetype_isolate(struct page
>> *page, unsigned migratetype)
>>                         if (pfn_valid_within(page_to_pfn(buddy)) &&
>>                             !is_migrate_isolate_page(buddy)) {
>>                                 __isolate_free_page(page, order);
>> -                               kernel_map_pages(page, (1 << order), 1);
>> -                               set_page_refcounted(page);
>>                                 isolated_page = page;
>>                         }
>>                 }
>> @@ -128,8 +127,12 @@ static void unset_migratetype_isolate(struct page
>> *page, unsigned migratetype)
>>         zone->nr_isolate_pageblock--;
>>  out:
>>         spin_unlock_irqrestore(&zone->lock, flags);
>> -       if (isolated_page)
>> +       if (isolated_page) {
>> +               kernel_map_pages(page, (1 << order), 1);
>
>
> So why we don't need the other stuff done by e.g. map_pages()? For example
> arch_alloc_page() and kasan_alloc_pages(). Maybe kasan_free_pages() (called
> below via __free_pages() I assume) now doesn't check if the allocation part
> was done. But maybe it will start doing that?
>
> See how the multiple places doing similar stuff is fragile? :(

I answered it in reply of comment of patch 1.

>> +               set_page_refcounted(page);
>> +               set_page_owner(page, order, __GFP_MOVABLE);
>>                 __free_pages(isolated_page, order);
>
>
> This mixing of "isolated_page" and "page" is not a bug, but quite ugly.
> Can't isolated_page variable just be a bool?
>

Looks better. I will do it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
