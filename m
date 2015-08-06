Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id EB1C96B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 08:21:43 -0400 (EDT)
Received: by wijp15 with SMTP id p15so20308009wij.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 05:21:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si3348369wif.18.2015.08.06.05.21.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Aug 2015 05:21:41 -0700 (PDT)
Subject: Re: [PATCH v2] vmscan: fix increasing nr_isolated incurred by putback
 unevictable pages
References: <1438684808-12707-1-git-send-email-jaewon31.kim@samsung.com>
 <20150804150937.ee3b62257e77911a2f41a48e@linux-foundation.org>
 <20150804233108.GA662@bgram> <55C15E37.80504@samsung.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C35152.4010306@suse.cz>
Date: Thu, 6 Aug 2015 14:21:38 +0200
MIME-Version: 1.0
In-Reply-To: <55C15E37.80504@samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com

On 08/05/2015 02:52 AM, Jaewon Kim wrote:
>
>
> On 2015e?? 08i?? 05i? 1/4  08:31, Minchan Kim wrote:
>> Hello,
>>
>> On Tue, Aug 04, 2015 at 03:09:37PM -0700, Andrew Morton wrote:
>>> On Tue, 04 Aug 2015 19:40:08 +0900 Jaewon Kim <jaewon31.kim@samsung.com> wrote:
>>>
>>>> reclaim_clean_pages_from_list() assumes that shrink_page_list() returns
>>>> number of pages removed from the candidate list. But shrink_page_list()
>>>> puts back mlocked pages without passing it to caller and without
>>>> counting as nr_reclaimed. This incurrs increasing nr_isolated.
>>>> To fix this, this patch changes shrink_page_list() to pass unevictable
>>>> pages back to caller. Caller will take care those pages.
>>>>
>>>> ..
>>>>
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -1157,7 +1157,7 @@ cull_mlocked:
>>>>   		if (PageSwapCache(page))
>>>>   			try_to_free_swap(page);
>>>>   		unlock_page(page);
>>>> -		putback_lru_page(page);
>>>> +		list_add(&page->lru, &ret_pages);
>>>>   		continue;
>>>>
>>>>   activate_locked:
>>>
>>> Is this going to cause a whole bunch of mlocked pages to be migrated
>>> whereas in current kernels they stay where they are?

The only user that will see the change wrt migration is 
__alloc_contig_migrate_range() which is explicit about isolating mlocked 
page for migration (isolate_migratepages_range() calls 
isolate_migratepages_block() with ISOLATE_UNEVICTABLE). So this will 
make the migration work for clean page cache too.

>>
>>
>> It fixes two issues.
>>
>> 1. With unevictable page, cma_alloc will be successful.
>>
>> Exactly speaking, cma_alloc of current kernel will fail due to unevictable pages.
>>
>> 2. fix leaking of NR_ISOLATED counter of vmstat
>>
>> With it, too_many_isolated works. Otherwise, it could make hang until
>> the process get SIGKILL.

This should be more explicit in the changelog. The first issue is not 
mentioned at all. The second is not clear from the description.

>>
>> So, I think it's stable material.
>>
>> Acked-by: Minchan Kim <minchan@kernel.org>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>>
>>
> Hello
>
> Traditional shrink_inactive_list will put back the unevictable pages as it does through putback_inactive_pages.
> However as Minchan Kim said, cma_alloc will be more successful by migrating unevictable pages.
> In current kernel, I think, cma_alloc is already trying to migrate unevictable pages except clean page cache.
> This patch will allow clean page cache also to be migrated in cma_alloc.
>
> Thank you
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
