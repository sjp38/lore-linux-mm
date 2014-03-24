Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id 503B56B00B7
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 14:04:04 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id pa12so6193599veb.29
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 11:04:04 -0700 (PDT)
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
        by mx.google.com with ESMTPS id rx10si3262969vdc.204.2014.03.24.11.04.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 11:04:03 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id lg15so6300054vcb.30
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 11:04:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53306C73.9030808@redhat.com>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
	<1395436655-21670-6-git-send-email-john.stultz@linaro.org>
	<53306C73.9030808@redhat.com>
Date: Mon, 24 Mar 2014 11:04:02 -0700
Message-ID: <CALAqxLW_sUiPUwTYbx2ZngJNd-BAKn0VPhD8pm2NmCyo+2vUbw@mail.gmail.com>
Subject: Re: [PATCH 5/5] vmscan: Age anonymous memory even when swap is off.
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 24, 2014 at 10:33 AM, Rik van Riel <riel@redhat.com> wrote:
> On 03/21/2014 05:17 PM, John Stultz wrote:
>>
>> Currently we don't shrink/scan the anonymous lrus when swap is off.
>> This is problematic for volatile range purging on swapless systems/
>>
>> This patch naievely changes the vmscan code to continue scanning
>> and shrinking the lrus even when there is no swap.
>>
>> It obviously has performance issues.
>>
>> Thoughts on how best to implement this would be appreciated.
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Android Kernel Team <kernel-team@android.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Robert Love <rlove@google.com>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Dave Hansen <dave@sr71.net>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
>> Cc: Neil Brown <neilb@suse.de>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Mike Hommey <mh@glandium.org>
>> Cc: Taras Glek <tglek@mozilla.com>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>> Cc: Michel Lespinasse <walken@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
>> Signed-off-by: John Stultz <john.stultz@linaro.org>
>> ---
>>   mm/vmscan.c | 26 ++++----------------------
>>   1 file changed, 4 insertions(+), 22 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 34f159a..07b0a8c 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -155,9 +155,8 @@ static unsigned long zone_reclaimable_pages(struct
>> zone *zone)
>>         nr = zone_page_state(zone, NR_ACTIVE_FILE) +
>>              zone_page_state(zone, NR_INACTIVE_FILE);
>>
>> -       if (get_nr_swap_pages() > 0)
>> -               nr += zone_page_state(zone, NR_ACTIVE_ANON) +
>> -                     zone_page_state(zone, NR_INACTIVE_ANON);
>> +       nr += zone_page_state(zone, NR_ACTIVE_ANON) +
>> +             zone_page_state(zone, NR_INACTIVE_ANON);
>>
>>         return nr;
>
>
> Not all of the anonymous pages will be reclaimable.
>
> Is there some counter that keeps track of how many
> volatile range pages there are in each zone?

So right, keeping statistics like NR_VOLATILE_PAGES (as well as
possibly NR_PURGED_VOLATILE_PAGES), would likely help here.

>> @@ -2181,8 +2166,8 @@ static inline bool should_continue_reclaim(struct
>> zone *zone,
>>          */
>>         pages_for_compaction = (2UL << sc->order);
>>         inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
>> -       if (get_nr_swap_pages() > 0)
>> -               inactive_lru_pages += zone_page_state(zone,
>> NR_INACTIVE_ANON);
>> +       inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
>> +
>>         if (sc->nr_reclaimed < pages_for_compaction &&
>>                         inactive_lru_pages > pages_for_compaction)
>
>
> Not sure this is a good idea, since the pages may not actually
> be reclaimable, and the inactive list will continue to be
> refilled indefinitely...
>
> If there was a counter of the number of volatile range pages
> in a zone, this would be easier.
>
> Of course, the overhead of keeping such a counter might be
> too high for what volatile ranges are designed for...

I started looking at something like this, but it runs into some
complexity when we're keeping volatility as a flag in the vma rather
then as a page state.

Also, even with a rough attempt at tracking of the number of volatile
pages, it seemed naively plugging that in for NR_INACTIVE_ANON here
was problematic, since we would scan for a shorter time, but but
wouldn't necessarily find the volatile pages in that time, causing us
not to always purge the volatile pages.

Part of me starts to wonder if a new LRU for volatile pages would be
needed to really be efficient here, but then I worry the moving of the
pages back and forth might be too expensive.

Thanks so much for the review and comments!
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
