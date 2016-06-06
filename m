Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 155FA6B026A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 11:20:06 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so67527165lfh.2
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 08:20:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 139si19173384wmp.19.2016.06.06.08.20.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Jun 2016 08:20:04 -0700 (PDT)
Subject: Re: [PATCH v2 2/7] mm/page_owner: initialize page owner without
 holding the zone lock
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-2-git-send-email-iamjoonsoo.kim@lge.com>
 <b548cad8-e7d1-b742-cb29-caf6263cc65d@suse.cz>
 <CAAmzW4NrJ8jFckmMdF+RY-++uoZ=RCpB34OF9+6=DEt1pSkQuw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5a37c41e-88cd-1345-218f-01b6760c0fd6@suse.cz>
Date: Mon, 6 Jun 2016 17:20:03 +0200
MIME-Version: 1.0
In-Reply-To: <CAAmzW4NrJ8jFckmMdF+RY-++uoZ=RCpB34OF9+6=DEt1pSkQuw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 06/03/2016 02:47 PM, Joonsoo Kim wrote:
[...]

>>> @@ -128,8 +127,12 @@ static void unset_migratetype_isolate(struct page
>>> *page, unsigned migratetype)
>>>         zone->nr_isolate_pageblock--;
>>>  out:
>>>         spin_unlock_irqrestore(&zone->lock, flags);
>>> -       if (isolated_page)
>>> +       if (isolated_page) {
>>> +               kernel_map_pages(page, (1 << order), 1);
>>
>>
>> So why we don't need the other stuff done by e.g. map_pages()? For example
>> arch_alloc_page() and kasan_alloc_pages(). Maybe kasan_free_pages() (called
>> below via __free_pages() I assume) now doesn't check if the allocation part
>> was done. But maybe it will start doing that?
>>
>> See how the multiple places doing similar stuff is fragile? :(
>
> I answered it in reply of comment of patch 1.

Right.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>
>>> +               set_page_refcounted(page);
>>> +               set_page_owner(page, order, __GFP_MOVABLE);
>>>                 __free_pages(isolated_page, order);
>>
>>
>> This mixing of "isolated_page" and "page" is not a bug, but quite ugly.
>> Can't isolated_page variable just be a bool?
>>
>
> Looks better. I will do it.
>
> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
