Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 770916B00DF
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 21:47:02 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn18so12036301igb.7
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 18:47:02 -0800 (PST)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id b9si3507286iob.17.2014.11.06.18.47.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 18:47:01 -0800 (PST)
Received: by mail-ie0-f173.google.com with SMTP id tr6so4349042ieb.18
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 18:47:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141106084907.GA29209@js1304-P5Q-DELUXE>
References: <000101cff999$09225070$1b66f150$%yang@samsung.com>
	<20141106084907.GA29209@js1304-P5Q-DELUXE>
Date: Fri, 7 Nov 2014 10:47:00 +0800
Message-ID: <CAL1ERfOca96HpWdHLMazOp8Ma4=EWJCu6RbpKCpF8ADZRfrZXw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: page_isolation: fix zone_freepage accounting
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, kamezawa.hiroyu@jp.fujitsu.com, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, mina86@mina86.com, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Nov 6, 2014 at 4:49 PM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> On Thu, Nov 06, 2014 at 04:09:08PM +0800, Weijie Yang wrote:
>> If race between isolatation and allocation happens, we could need to move
>> some freepages to MIGRATE_ISOLATE in __test_page_isolated_in_pageblock().
>> The current code ignores the zone_freepage accounting after the move,
>> which cause the zone NR_FREE_PAGES and NR_FREE_CMA_PAGES statistics incorrect.
>>
>> This patch fixes this rare issue.
>
> Hello,
>
> After "fix freepage count problems in memory isolation" merged, this race
> should not happen. I have to remove it in that patchset, but, I
> forgot to remove it. Please remove this race handling code completely and
> tag with stable. If we don't remove it, there is errornous situation
> because get_freepage_migratetype() could return invalid migratetype
> although the page is on the correct buddy list. So, we regard
> no race situation as race one.

Thanks for your remind, I will read your patch.

> Thanks.
>
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>  mm/page_isolation.c |    5 ++++-
>>  1 files changed, 4 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index 3ddc8b3..15b51de 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -193,12 +193,15 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>>                        * is MIGRATE_ISOLATE. Catch it and move the page into
>>                        * MIGRATE_ISOLATE list.
>>                        */
>> -                     if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
>> +                     int migratetype = get_freepage_migratetype(page);
>> +                     if (migratetype != MIGRATE_ISOLATE) {
>>                               struct page *end_page;
>>
>>                               end_page = page + (1 << page_order(page)) - 1;
>>                               move_freepages(page_zone(page), page, end_page,
>>                                               MIGRATE_ISOLATE);
>> +                             __mod_zone_freepage_state(zone,
>> +                                     -(1 << page_order(page)), migratetype);
>>                       }
>>                       pfn += 1 << page_order(page);
>>               }
>> --
>> 1.7.0.4
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
