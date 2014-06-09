Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1F40E6B0070
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 07:35:52 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so1424608wiv.3
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 04:35:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u2si31016501wjy.107.2014.06.09.04.35.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 04:35:49 -0700 (PDT)
Message-ID: <53959C11.2000305@suse.cz>
Date: Mon, 09 Jun 2014 13:35:45 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/6] mm, compaction: skip buddy pages by their order
 in the migrate scanner
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041656400.22536@chino.kir.corp.google.com> <5390374E.5080708@suse.cz> <alpine.DEB.2.02.1406051428360.18119@chino.kir.corp.google.com> <53916BB0.3070001@suse.cz> <alpine.DEB.2.02.1406090207300.24247@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406090207300.24247@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/09/2014 11:09 AM, David Rientjes wrote:
> On Fri, 6 Jun 2014, Vlastimil Babka wrote:
>
>>>>>> diff --git a/mm/internal.h b/mm/internal.h
>>>>>> index 1a8a0d4..6aa1f74 100644
>>>>>> --- a/mm/internal.h
>>>>>> +++ b/mm/internal.h
>>>>>> @@ -164,7 +164,8 @@ isolate_migratepages_range(struct zone *zone, struct
>>>>>> compact_control *cc,
>>>>>>     * general, page_zone(page)->lock must be held by the caller to prevent
>>>>>> the
>>>>>>     * page from being allocated in parallel and returning garbage as the
>>>>>> order.
>>>>>>     * If a caller does not hold page_zone(page)->lock, it must guarantee
>>>>>> that the
>>>>>> - * page cannot be allocated or merged in parallel.
>>>>>> + * page cannot be allocated or merged in parallel. Alternatively, it must
>>>>>> + * handle invalid values gracefully, and use page_order_unsafe() below.
>>>>>>     */
>>>>>>    static inline unsigned long page_order(struct page *page)
>>>>>>    {
>>>>>> @@ -172,6 +173,23 @@ static inline unsigned long page_order(struct page
>>>>>> *page)
>>>>>>    	return page_private(page);
>>>>>>    }
>>>>>>
>>>>>> +/*
>>>>>> + * Like page_order(), but for callers who cannot afford to hold the zone
>>>>>> lock,
>>>>>> + * and handle invalid values gracefully. ACCESS_ONCE is used so that if
>>>>>> the
>>>>>> + * caller assigns the result into a local variable and e.g. tests it for
>>>>>> valid
>>>>>> + * range  before using, the compiler cannot decide to remove the variable
>>>>>> and
>>>>>> + * inline the function multiple times, potentially observing different
>>>>>> values
>>>>>> + * in the tests and the actual use of the result.
>>>>>> + */
>>>>>> +static inline unsigned long page_order_unsafe(struct page *page)
>>>>>> +{
>>>>>> +	/*
>>>>>> +	 * PageBuddy() should be checked by the caller to minimize race
>>>>>> window,
>>>>>> +	 * and invalid values must be handled gracefully.
>>>>>> +	 */
>>>>>> +	return ACCESS_ONCE(page_private(page));
>>>>>> +}
>>>>>> +
>>>>>>    /* mm/util.c */
>>>>>>    void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
>>>>>>    		struct vm_area_struct *prev, struct rb_node *rb_parent);
>>>>>
>>>>> I don't like this change at all, I don't think we should have header
>>>>> functions that imply the context in which the function will be called.  I
>>>>> think it would make much more sense to just do
>>>>> ACCESS_ONCE(page_order(page)) in the migration scanner with a comment.
>>>>
>>>> But that won't compile. It would have to be converted to a #define, unless
>>>> there's some trick I don't know. Sure I would hope this could be done cleaner
>>>> somehow.
>>>>
>>>
>>> Sorry, I meant ACCESS_ONCE(page_private(page)) in the migration scanner
>>
>> Hm but that's breaking the abstraction of page_order(). I don't know if it's
>> worse to create a new variant of page_order() or to do this. BTW, seems like
>> next_active_pageblock() in memory-hotplug.c should use this variant too.
>>
>
> The compiler seems free to disregard the access of a volatile object above
> because the return value of the inline function is unsigned long.  What's
> the difference between unsigned long order = page_order_unsafe(page) and
> unsigned long order = (unsigned long)ACCESS_ONCE(page_private(page)) and

I think there's none functionally, but one is abstraction layer 
violation and the other imply the context of usage as you say (but is 
that so uncommon?).

> the compiler being able to reaccess page_private() because the result is
> no longer volatile qualified?

You think it will reaccess? That would defeat all current ACCESS_ONCE 
usages, no?

What I'm trying to prevent is that this code:

unsigned long freepage_order = page_order(page);

if (freepage_order > 0 && freepage_order < MAX_ORDER)
	low_pfn += (1UL << freepage_order) - 1;

could be effectively changed (AFAIK legal for the compiler to do) to:

if (page_order(page) > 0 && page_order(page) < MAX_ORDER)
	low_pfn += (1UL << page_order(page)) - 1;

And thus check a different value than it's in the end used to bump low_pfn.

I believe that even though freepage_order itself is not volatile, the 
fact it was assigned through a volatile cast means the compiler won't be 
able to do this anymore.

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
