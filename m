Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 79CD36B0070
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 08:42:22 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id hl2so7391915igb.4
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:42:22 -0800 (PST)
Received: from mail-ig0-x22e.google.com (mail-ig0-x22e.google.com. [2607:f8b0:4001:c05::22e])
        by mx.google.com with ESMTPS id s7si2076500igh.3.2014.11.20.05.42.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 05:42:21 -0800 (PST)
Received: by mail-ig0-f174.google.com with SMTP id hn15so4764692igb.1
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:42:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <546D0B78.9010005@suse.cz>
References: <000301d00253$0fcd0560$2f671020$%yang@samsung.com>
	<546D0B78.9010005@suse.cz>
Date: Thu, 20 Nov 2014 21:42:20 +0800
Message-ID: <CAL1ERfNJKoAr3_Tx_MCn6KgF2n2Ui9B31W-z4sNiW8A6vaw8vA@mail.gmail.com>
Subject: Re: [PATCH] mm: page_alloc: store updated page migratetype to avoid
 misusing stale value
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Weijie Yang <weijie.yang@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Nov 20, 2014 at 5:28 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 11/17/2014 11:40 AM, Weijie Yang wrote:
>> The commit ad53f92e(fix incorrect isolation behavior by rechecking migratetype)
>> patch series describe the race between page isolation and free path, and try to
>> fix the freepage account issues.
>>
>> However, there is still a little issue: freed page could have stale migratetype
>> in the free_list. This would cause some bad behavior if we misuse this stale
>> value later.
>> Such as: in __test_page_isolated_in_pageblock() we check the buddy page, if the
>> page's stale migratetype is not MIGRATE_ISOLATE, which will cause unnecessary
>> page move action.
>
> Hello,

Hi Vlastimil,
Thanks for your reply, that makes me think from a bigger view.

After a careful check according to your said, this patch is not proper, it
should be dropped and I will resend a v2 patch.

> are there other places than __test_page_isolated_in_pageblock(), where
> freepage_migratetype matters? You make it sound like it's just an example, but I
> doubt there is any other. All other callers of get_freepage_migratetype() are
> querying pages on the pcplists, not the buddy lists. There it serves as a cached
> value for migratetype so it doesn't have to be read again when freeing from
> pcplists to budy list.

Agree. Now only __test_page_isolated_in_pageblock() matters
freepage_migratetype.
pages from pcplists have a cached but not 100% accurate migratetype and we
will recheck them when drain them to buddy if there is a need(race
with isolation);
pages in buddy should have an update and 100% accurate migratetype, or it would
cause some bad issue, and that is the aim of this patch.

Or, if we make nobody rely on the freepage_migratetype in buddy, we can take no
care of the 100% accuracy of the freepage_migratetype in buddy.
This is your suggestion, do I understand it correctly?

> Seems to me that __test_page_isolated_in_pageblock() was an exception that tried
> to rely on freepage_migratetype being valid even after the page has moved from
> pcplist to buddy list, but this assumption was always broken.

I am not very clear, could you please explain why it always broken?

> Sure, if all the pages in isolated pageblock are catched by move_freepages()
> during isolation, then the freetype is correct, but that doesn't always happen
> due to parallel activity (and that's the core problem that Joonsoo's series
> dealt with).

Agree. Joonsoo's series fix the race between page freeing and isolation due to
not-update freepage_migratetype check, and introduce nr_isolate_pageblock
to avoid too much heavy check.

> So, in this patch you try to make sure that freepage_migratetype will be correct
> after page got to buddy list via __free_one_page(). But I don't think that
> covers all situations. Look at expand(), which puts potentially numerous
> splitted free pages on free_list, and doesn't set freepage_migratetype. Sure,
> this ommision doesn't affect __test_page_isolated_in_pageblock(), as expand() is
> called during allocation, which won't touch ISOLATE pageblocks, and free pages
> created by expand() *before* setting ISOLATE are processed by move_freepages().

I have to admit I did not think about the page_alloc path(such as
expand), I will review
the code before I resend the patch.
What I thought is setting freepage_migratetype via __free_one_page()
is enough because
we can ensure them correct from the begining __free_pages_bootmem().

> So my point is, you are maybe fixing just the case of
> __test_page_isolated_in_pageblock() (but not completely I think, see below) by
> adding extra operation to __free_one_page() which is hot path. And all for a
> WARN_ON_ONCE. That doesn't seem like a good tradeoff. And to do it consistently,
> you would need to add the operation also to expand(), another hotpath. So that's
> a NAK from me.

I agree we should handle hot patch carefully, in my next patch I will
consider how to
avoid affecting the hot path meanwhile fix the
__test_page_isolated_in_pageblock().

> I would uggest you throw the __test_page_isolated_in_pageblock() function away
> completely.

I'm not sure we can throw it completely. There is another check on
page_count besides
PageBuddy() and hwpoison stuff.

> Or just rework it to check for PageBuddy() and hwpoison stuff - the
> migratetype checks make no sense to me. Or if you insist that this is needed for
> debugging further possible races in page isolation, then please hide the
> necessary bits in hot paths being a debugging config option.

Agree.

> If you agree, we can even throw away the set_freepage_migratetype() calls from
> move_freepages() - there's no point to them anymore.

Agree.

>> This patch store the page's updated migratetype after free the page to the
>> free_list to avoid subsequent misusing stale value, and use a WARN_ON_ONCE
>> to catch a potential undetected race between isolatation and free path.
>>
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>  mm/page_alloc.c     |    1 +
>>  mm/page_isolation.c |   17 +++++------------
>>  2 files changed, 6 insertions(+), 12 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 616a2c9..177fca0 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -622,6 +622,7 @@ static inline void __free_one_page(struct page *page,
>
> See here at this point, the function has this code:
>                         list_add_tail(&page->lru,
>                                &zone->free_area[order].free_list[migratetype]);
>                         goto out;
>
> You are missing this list_add_tail() path with your patch.

My fault.

>>       }
>>
>>       list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>> +     set_freepage_migratetype(page, migratetype);
>>  out:
>>       zone->free_area[order].nr_free++;
>>  }
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index c8778f7..0618071 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -223,19 +223,12 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
>>               page = pfn_to_page(pfn);
>>               if (PageBuddy(page)) {
>>                       /*
>> -                      * If race between isolatation and allocation happens,
>> -                      * some free pages could be in MIGRATE_MOVABLE list
>> -                      * although pageblock's migratation type of the page
>> -                      * is MIGRATE_ISOLATE. Catch it and move the page into
>> -                      * MIGRATE_ISOLATE list.
>> +                      * Use a WARN_ON_ONCE to catch a potential undetected
>> +                      * race between isolatation and free pages, even if
>> +                      * we try to avoid this issue.
>>                        */
>> -                     if (get_freepage_migratetype(page) != MIGRATE_ISOLATE) {
>> -                             struct page *end_page;
>> -
>> -                             end_page = page + (1 << page_order(page)) - 1;
>> -                             move_freepages(page_zone(page), page, end_page,
>> -                                             MIGRATE_ISOLATE);
>> -                     }
>> +                     WARN_ON_ONCE(get_freepage_migratetype(page) !=
>> +                                     MIGRATE_ISOLATE);
>
> So yeah as I said, all the trouble and inconsistency for a WARN_ON_ONCE doesn't
> seem worth it.

May be adding a debug config is better.

>>                       pfn += 1 << page_order(page);
>>               }
>
> BTW, here the function continues like:
>
>                 else if (page_count(page) == 0 &&
>                         get_freepage_migratetype(page) == MIGRATE_ISOLATE)
>                         pfn += 1;
>
> I believe this code tries to check for pages on pcplists? But isn't it bogus? At
> least currently, page is never added to pcplist with MIGRATE_ISOLATE
> freepage_migratetype - it goes straight to buddy lists.

I think we can remove this check, how do you think?
I cann't find its necessity.

> Also, why count pages on pcplists as successfully isolated?
> isolate_freepages_range() will fail on them.

I think you make a misread, if page's count is not zero we break the while
and return fail.

>>               else if (page_count(page) == 0 &&
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
