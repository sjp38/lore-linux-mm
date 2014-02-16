Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id E4F0D6B0062
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 00:01:56 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id rd18so117167iec.7
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 21:01:56 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id p7si10381979igr.49.2014.02.15.21.01.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 21:01:56 -0800 (PST)
Received: by mail-ig0-f173.google.com with SMTP id c10so3208802igq.0
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 21:01:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1402151953180.10073@eggly.anvils>
References: <000001cf2ac7$9abf23b0$d03d6b10$%yang@samsung.com>
	<alpine.LSU.2.11.1402151953180.10073@eggly.anvils>
Date: Sun, 16 Feb 2014 13:01:55 +0800
Message-ID: <CAL1ERfO4yYMRBO8XEM0oCwBb6NOqZRVGq648ncerM9XuyPPJkw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/vmscan: remove two un-needed mem_cgroup_page_lruvec()
 call
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, riel@redhat.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sun, Feb 16, 2014 at 12:00 PM, Hugh Dickins <hughd@google.com> wrote:
> On Sun, 16 Feb 2014, Weijie Yang wrote:
>
>> In putback_inactive_pages() and move_active_pages_to_lru(),
>> lruvec is already an input parameter and pages are all from this lruvec,
>> therefore there is no need to call mem_cgroup_page_lruvec() in loop.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>
> Looks plausible but I believe it's incorrect.  The lruvec passed in
> is the one we took the pages from, but there's a small but real chance
> that the page has become uncharged meanwhile, and should now be put back
> on the root_mem_cgroup's lruvec instead of the original memcg's lruvec.

Hi Hugh,

Thanks for your review.
Frankly speaking, I am not very sure about it, that is why I add a RFC tag here.
So,  do we need update the reclaim_stat meanwhile as we change the lruvec?

Regards,

> Hugh
>
>> ---
>>  mm/vmscan.c |    3 ---
>>  1 file changed, 3 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index a9c74b4..4804fdb 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1393,8 +1393,6 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>>                       continue;
>>               }
>>
>> -             lruvec = mem_cgroup_page_lruvec(page, zone);
>> -
>>               SetPageLRU(page);
>>               lru = page_lru(page);
>>               add_page_to_lru_list(page, lruvec, lru);
>> @@ -1602,7 +1600,6 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>>
>>       while (!list_empty(list)) {
>>               page = lru_to_page(list);
>> -             lruvec = mem_cgroup_page_lruvec(page, zone);
>>
>>               VM_BUG_ON_PAGE(PageLRU(page), page);
>>               SetPageLRU(page);
>> --
>> 1.7.10.4
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
