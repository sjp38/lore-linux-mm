Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id C17B26B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 03:23:15 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n3so408762wiv.15
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 00:23:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id do8si1327270wib.62.2014.07.08.00.23.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 00:23:14 -0700 (PDT)
Message-ID: <53BB9C61.8040902@suse.cz>
Date: Tue, 08 Jul 2014 09:23:13 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] mm/page_alloc: use get_onbuddy_migratetype() to
 get buddy list type
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-9-git-send-email-iamjoonsoo.kim@lge.com> <53BAC37D.3060703@suse.cz> <53BB42E3.4060005@lge.com>
In-Reply-To: <53BB42E3.4060005@lge.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/08/2014 03:01 AM, Gioh Kim wrote:
>
>
> 2014-07-08 i??i ? 12:57, Vlastimil Babka i?' e,?:
>> On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
>>> When isolating free page, what we want to know is which list
>>> the page is linked. If it is linked in isolate migratetype buddy list,
>>> we can skip watermark check and freepage counting. And if it is linked
>>> in CMA migratetype buddy list, we need to fixup freepage counting. For
>>> this purpose, get_onbuddy_migratetype() is more fit and cheap than
>>> get_pageblock_migratetype(). So use it.
>>
>> Hm but you made get_onbuddy_migratetype() work only with CONFIG_MEMORY_ISOLATION. And __isolate_free_page is (despite the name) not at all limited to CONFIG_MEMORY_ISOLATION.
>>
>
> Current __isolate_free_page is called by only split_free_page, and split_free_page by isolate_freepages_block.
> split_free_page is called only for isolated pages now but It can be changed someday.

Yeah, but isolate_freepages_block is also not part of 
CONFIG_MEMORY_ISOLATION. Unfortunately, there are two distinct concepts 
of memory isolation and LRU isolation, that are not distinguished in 
function names.

> I think get_onbuddy_migratetype should work with any situation.
>
> And I think the name of get_onbuddy_migratetype is confused.
> Because of _onbuddy_, it might look like that the pages are buddy pages.
> I think the original name _freepage_ is proper one.
>
>
>>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> ---
>>>    mm/page_alloc.c |    2 +-
>>>    1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index e1c4c3e..d9fb8bb 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -1597,7 +1597,7 @@ static int __isolate_free_page(struct page *page, unsigned int order)
>>>        BUG_ON(!PageBuddy(page));
>>>
>>>        zone = page_zone(page);
>>> -    mt = get_pageblock_migratetype(page);
>>> +    mt = get_onbuddy_migratetype(page);
>>>
>>>        if (!is_migrate_isolate(mt)) {
>>>            /* Obey watermarks as if the page was being allocated */
>>>
>>
>>
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
