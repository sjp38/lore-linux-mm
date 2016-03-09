Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f180.google.com (mail-ob0-f180.google.com [209.85.214.180])
	by kanga.kvack.org (Postfix) with ESMTP id 06FC76B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 20:37:35 -0500 (EST)
Received: by mail-ob0-f180.google.com with SMTP id fz5so32734958obc.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 17:37:35 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id u17si4363747oie.46.2016.03.08.17.37.07
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 17:37:34 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com> <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <20160304043232.GC12036@js1304-P5Q-DELUXE> <56D92595.60709@huawei.com>
 <20160304063807.GA13317@js1304-P5Q-DELUXE> <56D93ABE.9070406@huawei.com>
 <20160307043442.GB24602@js1304-P5Q-DELUXE> <56DD38E7.3050107@huawei.com>
 <56DDCB86.4030709@redhat.com> <56DE30CB.7020207@huawei.com>
From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Message-ID: <56DF7B28.9060108@huawei.com>
Date: Wed, 9 Mar 2016 09:23:52 +0800
MIME-Version: 1.0
In-Reply-To: <56DE30CB.7020207@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hanjun Guo <guohanjun@huawei.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2016/3/8 9:54, Leizhen (ThunderTown) wrote:
> 
> 
> On 2016/3/8 2:42, Laura Abbott wrote:
>> On 03/07/2016 12:16 AM, Leizhen (ThunderTown) wrote:
>>>
>>>
>>> On 2016/3/7 12:34, Joonsoo Kim wrote:
>>>> On Fri, Mar 04, 2016 at 03:35:26PM +0800, Hanjun Guo wrote:
>>>>> On 2016/3/4 14:38, Joonsoo Kim wrote:
>>>>>> On Fri, Mar 04, 2016 at 02:05:09PM +0800, Hanjun Guo wrote:
>>>>>>> On 2016/3/4 12:32, Joonsoo Kim wrote:
>>>>>>>> On Fri, Mar 04, 2016 at 11:02:33AM +0900, Joonsoo Kim wrote:
>>>>>>>>> On Thu, Mar 03, 2016 at 08:49:01PM +0800, Hanjun Guo wrote:
>>>>>>>>>> On 2016/3/3 15:42, Joonsoo Kim wrote:
>>>>>>>>>>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
>>>>>>>>>>>> (cc -mm and Joonsoo Kim)
>>>>>>>>>>>>
>>>>>>>>>>>>
>>>>>>>>>>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
>>>>>>>>>>>>> Hi,
>>>>>>>>>>>>>
>>>>>>>>>>>>> I came across a suspicious error for CMA stress test:
>>>>>>>>>>>>>
>>>>>>>>>>>>> Before the test, I got:
>>>>>>>>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>>>>>>>>> CmaTotal:         204800 kB
>>>>>>>>>>>>> CmaFree:          195044 kB
>>>>>>>>>>>>>
>>>>>>>>>>>>>
>>>>>>>>>>>>> After running the test:
>>>>>>>>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>>>>>>>>> CmaTotal:         204800 kB
>>>>>>>>>>>>> CmaFree:         6602584 kB
>>>>>>>>>>>>>
>>>>>>>>>>>>> So the freed CMA memory is more than total..
>>>>>>>>>>>>>
>>>>>>>>>>>>> Also the the MemFree is more than mem total:
>>>>>>>>>>>>>
>>>>>>>>>>>>> -bash-4.3# cat /proc/meminfo
>>>>>>>>>>>>> MemTotal:       16342016 kB
>>>>>>>>>>>>> MemFree:        22367268 kB
>>>>>>>>>>>>> MemAvailable:   22370528 kB
>>>>>>>>>> [...]
>>>>>>>>>>>> I played with this a bit and can see the same problem. The sanity
>>>>>>>>>>>> check of CmaFree < CmaTotal generally triggers in
>>>>>>>>>>>> __move_zone_freepage_state in unset_migratetype_isolate.
>>>>>>>>>>>> This also seems to be present as far back as v4.0 which was the
>>>>>>>>>>>> first version to have the updated accounting from Joonsoo.
>>>>>>>>>>>> Were there known limitations with the new freepage accounting,
>>>>>>>>>>>> Joonsoo?
>>>>>>>>>>> I don't know. I also played with this and looks like there is
>>>>>>>>>>> accounting problem, however, for my case, number of free page is slightly less
>>>>>>>>>>> than total. I will take a look.
>>>>>>>>>>>
>>>>>>>>>>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
>>>>>>>>>>> look like your case.
>>>>>>>>>> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
>>>>>>>>>> did some other test:
>>>>>>>>> Thanks! Now, I can re-generate erronous situation you mentioned.
>>>>>>>>>
>>>>>>>>>>   - run with single thread with 100000 times, everything is fine.
>>>>>>>>>>
>>>>>>>>>>   - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
>>>>>>>>>>     the same test with 100 multi-thread, then I got:
>>>>>>>>> [1] would not be sufficient to close this race.
>>>>>>>>>
>>>>>>>>> Try following things [A]. And, for more accurate test, I changed code a bit more
>>>>>>>>> to prevent kernel page allocation from cma area [B]. This will prevent kernel
>>>>>>>>> page allocation from cma area completely so we can focus cma_alloc/release race.
>>>>>>>>>
>>>>>>>>> Although, this is not correct fix, it could help that we can guess
>>>>>>>>> where the problem is.
>>>>>>>> More correct fix is something like below.
>>>>>>>> Please test it.
>>>>>>> Hmm, this is not working:
>>>>>> Sad to hear that.
>>>>>>
>>>>>> Could you tell me your system's MAX_ORDER and pageblock_order?
>>>>>>
>>>>>
>>>>> MAX_ORDER is 11, pageblock_order is 9, thanks for your help!
>>>>
>>>> Hmm... that's same with me.
>>>>
>>>> Below is similar fix that prevents buddy merging when one of buddy's
>>>> migrate type, but, not both, is MIGRATE_ISOLATE. In fact, I have
>>>> no idea why previous fix (more correct fix) doesn't work for you.
>>>> (It works for me.) But, maybe there is a bug on the fix
>>>> so I make new one which is more general form. Please test it.
>>>
>>> Hi,
>>>     Hanjun Guo has gone to Tailand on business, so I help him to run this patch. The result
>>> shows that the count of "CmaFree:" is OK now. But sometimes printed some information as below:
>>>
>>> alloc_contig_range: [28500, 28600) PFNs busy
>>> alloc_contig_range: [28300, 28380) PFNs busy
>>>
>>
>> Those messages aren't necessarily a problem. Those messages indicate that
> OK.
> 
>> those pages weren't able to be isolated. Given the test here is a
>> concurrency test, I suspect some concurrent allocation or free prevented
>> isolation which is to be expected some times. I'd only be concerned if
>> seeing those messages cause allocation failure or some other notable impact.
> I chose memory block size: 512K, 1M, 2M ran serveral times, there was no memory allocation failure.

Hi, Joonsoo:
	This new patch worked well. Do you plan to upstream it in the near furture?

> 
>>
>> Thanks,
>> Laura
>>  
>>>>
>>>> Thanks.
>>>>
>>>> ---------->8-------------
>>>> >From dd41e348572948d70b935fc24f82c096ff0fb417 Mon Sep 17 00:00:00 2001
>>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>> Date: Fri, 4 Mar 2016 13:28:17 +0900
>>>> Subject: [PATCH] mm/cma: fix race
>>>>
>>>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>> ---
>>>>   mm/page_alloc.c | 33 +++++++++++++++++++--------------
>>>>   1 file changed, 19 insertions(+), 14 deletions(-)
>>>>
>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>> index c6c38ed..d80d071 100644
>>>> --- a/mm/page_alloc.c
>>>> +++ b/mm/page_alloc.c
>>>> @@ -620,8 +620,8 @@ static inline void rmv_page_order(struct page *page)
>>>>    *
>>>>    * For recording page's order, we use page_private(page).
>>>>    */
>>>> -static inline int page_is_buddy(struct page *page, struct page *buddy,
>>>> -                                                       unsigned int order)
>>>> +static inline int page_is_buddy(struct zone *zone, struct page *page,
>>>> +                               struct page *buddy, unsigned int order)
>>>>   {
>>>>          if (!pfn_valid_within(page_to_pfn(buddy)))
>>>>                  return 0;
>>>> @@ -644,6 +644,20 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>>>>                  if (page_zone_id(page) != page_zone_id(buddy))
>>>>                          return 0;
>>>>
>>>> +               if (IS_ENABLED(CONFIG_CMA) &&
>>>> +                       unlikely(has_isolate_pageblock(zone)) &&
>>>> +                       unlikely(order >= pageblock_order)) {
>>>> +                       int page_mt, buddy_mt;
>>>> +
>>>> +                       page_mt = get_pageblock_migratetype(page);
>>>> +                       buddy_mt = get_pageblock_migratetype(buddy);
>>>> +
>>>> +                       if (page_mt != buddy_mt &&
>>>> +                               (is_migrate_isolate(page_mt) ||
>>>> +                               is_migrate_isolate(buddy_mt)))
>>>> +                               return 0;
>>>> +               }
>>>> +
>>>>                  VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
>>>>
>>>>                  return 1;
>>>> @@ -691,17 +705,8 @@ static inline void __free_one_page(struct page *page,
>>>>          VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP, page);
>>>>
>>>>          VM_BUG_ON(migratetype == -1);
>>>> -       if (is_migrate_isolate(migratetype)) {
>>>> -               /*
>>>> -                * We restrict max order of merging to prevent merge
>>>> -                * between freepages on isolate pageblock and normal
>>>> -                * pageblock. Without this, pageblock isolation
>>>> -                * could cause incorrect freepage accounting.
>>>> -                */
>>>> -               max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
>>>> -       } else {
>>>> +       if (!is_migrate_isolate(migratetype))
>>>>                  __mod_zone_freepage_state(zone, 1 << order, migratetype);
>>>> -       }
>>>>
>>>>          page_idx = pfn & ((1 << max_order) - 1);
>>>>
>>>> @@ -711,7 +716,7 @@ static inline void __free_one_page(struct page *page,
>>>>          while (order < max_order - 1) {
>>>>                  buddy_idx = __find_buddy_index(page_idx, order);
>>>>                  buddy = page + (buddy_idx - page_idx);
>>>> -               if (!page_is_buddy(page, buddy, order))
>>>> +               if (!page_is_buddy(zone, page, buddy, order))
>>>>                          break;
>>>>                  /*
>>>>                   * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
>>>> @@ -745,7 +750,7 @@ static inline void __free_one_page(struct page *page,
>>>>                  higher_page = page + (combined_idx - page_idx);
>>>>                  buddy_idx = __find_buddy_index(combined_idx, order + 1);
>>>>                  higher_buddy = higher_page + (buddy_idx - combined_idx);
>>>> -               if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
>>>> +               if (page_is_buddy(zone, higher_page, higher_buddy, order + 1)) {
>>>>                          list_add_tail(&page->lru,
>>>>                                  &zone->free_area[order].free_list[migratetype]);
>>>>                          goto out;
>>>>
>>>
>>
>>
>> .
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
