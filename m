Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7BEBA6B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:10:46 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id rp18so2712544iec.39
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:10:46 -0800 (PST)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com. [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id g7si3006820ioj.23.2014.12.10.06.10.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 06:10:45 -0800 (PST)
Received: by mail-ie0-f182.google.com with SMTP id x19so2738628ier.13
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:10:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5486BFCB.4040305@suse.cz>
References: <000201d01385$25a6c950$70f45bf0$%yang@samsung.com>
	<5486BFCB.4040305@suse.cz>
Date: Wed, 10 Dec 2014 22:10:44 +0800
Message-ID: <CAL1ERfPsSs9GnvP4S3L+4OQUZ71Eps89_0qGgE7_2OQkPDyJ-w@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: page_isolation: remove unnecessary
 freepage_migratetype check for unused page
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Weijie Yang <weijie.yang@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Dec 9, 2014 at 5:24 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 12/09/2014 08:51 AM, Weijie Yang wrote:
>>
>> when we test the pages in a range is free or not, there is a little
>> chance we encounter some page which is not in buddy but page_count is 0.
>> That means that page could be in the page-freeing path but not in the
>> buddy freelist, such as in pcplist
>
>
> This shouldn't happen anymore IMHO. The pageblock is marked as
> MIGRATE_ISOLATE and then a lru+pcplist drain is performed. Nothing should be
> left on pcplist - anything newly freed goes directly to free lists. Hm,
> maybe it could be on lru cache, but that holds a page reference IIRC, so
> this test won't pass.

Yes, you are right. I made a mistake, this shouldn't happen.
I will remove this description in next version. Thanks.

>> or wait for the zone->lock which the
>> tester is holding.
>
>
> That could maybe happen, but is it worth testing? If yes, please add it in a
> comment to the code.

This could happen even though the chance is very tiny.
As for cma_alloc, the test makes no difference.
However, as for offline_page, the test makes sense. If we leave the test and
pass it when page_count is zero, it could trigger the BUG_ON(!PageBuddy(page))
in the __offline_isolated_pages() if the page hasn't finish its free journey.

>From the literal meaning of this test_pages_isolated() function, I think it is
better get a definite result and not leave some middle status even if
they are rare.

So, Let's remove the whole test branch
(page_count(page) == 0 && get_freepage_migratetype(page) == MIGRATE_ISOLATE)

Thanks for your remind and suggestion.

>
>> Back to the freepage_migratetype, we use it for a cached value for decide
>> which free-list the page go when freeing page. If the pageblock is
>> isolated
>> the page will go to free-list[MIGRATE_ISOLATE] even if the cached type is
>> not MIGRATE_ISOLATE, the commit ad53f92e(fix incorrect isolation behavior
>> by rechecking migratetype) patch series have ensure this.
>>
>> So the freepage_migratetype check for page_count==0 page in
>> __test_page_isolated_in_pageblock() is meaningless.
>> This patch removes the unnecessary freepage_migratetype check.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>   mm/page_isolation.c |    3 +--
>>   1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 6e5174d..f7c9183 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -223,8 +223,7 @@ __test_page_isolated_in_pageblock(unsigned long pfn,
>> unsigned long end_pfn,
>>                 page = pfn_to_page(pfn);
>>                 if (PageBuddy(page))
>>                         pfn += 1 << page_order(page);
>> -               else if (page_count(page) == 0 &&
>> -                       get_freepage_migratetype(page) == MIGRATE_ISOLATE)
>> +               else if (page_count(page) == 0)
>>                         pfn += 1;
>>                 else if (skip_hwpoisoned_pages && PageHWPoison(page)) {
>>                         /*
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
