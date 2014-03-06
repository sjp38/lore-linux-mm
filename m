Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB816B0031
	for <linux-mm@kvack.org>; Thu,  6 Mar 2014 12:41:16 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id g10so2814625pdj.41
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 09:41:16 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id j4si5635218pad.22.2014.03.06.09.41.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Mar 2014 09:41:15 -0800 (PST)
Message-ID: <5318B339.6010000@codeaurora.org>
Date: Thu, 06 Mar 2014 09:41:13 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/compaction: Break out of loop on !PageBuddy in isolate_freepages_block
References: <1394072800-11776-1-git-send-email-lauraa@codeaurora.org> <53184C5F.1080406@suse.cz>
In-Reply-To: <53184C5F.1080406@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 3/6/2014 2:22 AM, Vlastimil Babka wrote:
> On 03/06/2014 03:26 AM, Laura Abbott wrote:
>> We received several reports of bad page state when freeing CMA pages
>> previously allocated with alloc_contig_range:
>>
>> <1>[ 1258.084111] BUG: Bad page state in process Binder_A  pfn:63202
>> <1>[ 1258.089763] page:d21130b0 count:0 mapcount:1 mapping:  (null)
>> index:0x7dfbf
>> <1>[ 1258.096109] page flags: 0x40080068(uptodate|lru|active|swapbacked)
>>
>> Based on the page state, it looks like the page was still in use. The
>> page
>> flags do not make sense for the use case though. Further debugging showed
>> that despite alloc_contig_range returning success, at least one page
>> in the
>> range still remained in the buddy allocator.
>>
>> There is an issue with isolate_freepages_block. In strict mode (which CMA
>> uses), if any pages in the range cannot be isolated,
>> isolate_freepages_block
>> should return failure 0. The current check keeps track of the total
>> number
>> of isolated pages and compares against the size of the range:
>>
>>          if (strict && nr_strict_required > total_isolated)
>>                  total_isolated = 0;
>>
>> After taking the zone lock, if one of the pages in the range is not
>> in the buddy allocator, we continue through the loop and do not
>
>> increment total_isolated. If we end up over isolating by more than
>> one page (e.g. last since page needed is a higher order page), it
>> is not possible to detect that the page was skipped. The fix is to
>
> I found it hard to grasp this sentence at first. Perhaps something like
> "if in the last iteration of the loop we isolate more than one page
> (e.g. ...), the check for total_isolated may pass and we fail to detect
> that a page was skipped" would be better?
>

Yes, that sounds much better.

>> bail out if the loop immediately if we are in strict mode. There's
>> no benfit to continuing anyway since we need all pages to be
>> isolated.
>
> That looks sound , but I wonder if it makes sense to keep the
> nr_strict_required stuff after this change. The check could then simply
> use 'if (pfn < end_pfn)' the same way as isolate_freepages_range does,
> right?
>

I had that thought as well. I'll fix that up for v2 along with the rest 
of your comments.

>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
>> ---
>>   mm/compaction.c |   25 +++++++++++++++++++------
>>   1 files changed, 19 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index b48c525..3190cef 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -263,12 +263,21 @@ static unsigned long
>> isolate_freepages_block(struct compact_control *cc,
>>           struct page *page = cursor;
>>
>>           nr_scanned++;
>> -        if (!pfn_valid_within(blockpfn))
>> -            continue;
>> +        if (!pfn_valid_within(blockpfn)) {
>> +            if (strict)
>> +                break;
>> +            else
>> +                continue;
>> +        }
>> +
>>           if (!valid_page)
>>               valid_page = page;
>> -        if (!PageBuddy(page))
>> -            continue;
>> +        if (!PageBuddy(page)) {
>> +            if (strict)
>> +                break;
>> +            else
>> +                continue;
>> +        }
>>
>>           /*
>>            * The zone lock must be held to isolate freepages.
>> @@ -288,8 +297,12 @@ static unsigned long
>> isolate_freepages_block(struct compact_control *cc,
>>               break;
>>
>>           /* Recheck this is a buddy page under lock */
>> -        if (!PageBuddy(page))
>> -            continue;
>> +        if (!PageBuddy(page)) {
>> +            if (strict)
>> +                break;
>> +            else
>> +                continue;
>> +        }
>
> To avoid this triple if-else occurence, you could instead do a "goto
> isolate_failed;" and put the if-else under said label at the end of the
> loop, also allowing extra cleanup, something like this:
>
> @@ -298,8 +298,6 @@ static unsigned long isolate_freepages_block(struct
> compact_control *cc,
>
>                  /* Found a free page, break it into order-0 pages */
>                  isolated = split_free_page(page);
> -               if (!isolated && strict)
> -                       break;
>                  total_isolated += isolated;
>                  for (i = 0; i < isolated; i++) {
>                          list_add(&page->lru, freelist);
> @@ -310,7 +308,13 @@ static unsigned long isolate_freepages_block(struct
> compact_control *cc,
>                  if (isolated) {
>                          blockpfn += isolated - 1;
>                          cursor += isolated - 1;
> +                       continue;
>                  }
> +isolate_fail:
> +               if (strict)
> +                       break;
> +               else
> +                       continue;
>
>
> Thanks,
> Vlastimil
>
>>           /* Found a free page, break it into order-0 pages */
>>           isolated = split_free_page(page);
>>
>

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
