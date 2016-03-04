Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f182.google.com (mail-yw0-f182.google.com [209.85.161.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2BA6B0253
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 01:13:50 -0500 (EST)
Received: by mail-yw0-f182.google.com with SMTP id h129so37367213ywb.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 22:13:50 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id i130si683231yba.275.2016.03.03.22.13.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 22:13:49 -0800 (PST)
Subject: Re: Suspicious error for CMA stress test
References: <56D6F008.1050600@huawei.com> <56D79284.3030009@redhat.com>
 <CAAmzW4PUwoVF+F-BpOZUHhH6YHp_Z8VkiUjdBq85vK6AWVkyPg@mail.gmail.com>
 <56D832BD.5080305@huawei.com> <20160304020232.GA12036@js1304-P5Q-DELUXE>
 <20160304043232.GC12036@js1304-P5Q-DELUXE>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56D92595.60709@huawei.com>
Date: Fri, 4 Mar 2016 14:05:09 +0800
MIME-Version: 1.0
In-Reply-To: <20160304043232.GC12036@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2016/3/4 12:32, Joonsoo Kim wrote:
> On Fri, Mar 04, 2016 at 11:02:33AM +0900, Joonsoo Kim wrote:
>> On Thu, Mar 03, 2016 at 08:49:01PM +0800, Hanjun Guo wrote:
>>> On 2016/3/3 15:42, Joonsoo Kim wrote:
>>>> 2016-03-03 10:25 GMT+09:00 Laura Abbott <labbott@redhat.com>:
>>>>> (cc -mm and Joonsoo Kim)
>>>>>
>>>>>
>>>>> On 03/02/2016 05:52 AM, Hanjun Guo wrote:
>>>>>> Hi,
>>>>>>
>>>>>> I came across a suspicious error for CMA stress test:
>>>>>>
>>>>>> Before the test, I got:
>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>> CmaTotal:         204800 kB
>>>>>> CmaFree:          195044 kB
>>>>>>
>>>>>>
>>>>>> After running the test:
>>>>>> -bash-4.3# cat /proc/meminfo | grep Cma
>>>>>> CmaTotal:         204800 kB
>>>>>> CmaFree:         6602584 kB
>>>>>>
>>>>>> So the freed CMA memory is more than total..
>>>>>>
>>>>>> Also the the MemFree is more than mem total:
>>>>>>
>>>>>> -bash-4.3# cat /proc/meminfo
>>>>>> MemTotal:       16342016 kB
>>>>>> MemFree:        22367268 kB
>>>>>> MemAvailable:   22370528 kB
>>> [...]
>>>>> I played with this a bit and can see the same problem. The sanity
>>>>> check of CmaFree < CmaTotal generally triggers in
>>>>> __move_zone_freepage_state in unset_migratetype_isolate.
>>>>> This also seems to be present as far back as v4.0 which was the
>>>>> first version to have the updated accounting from Joonsoo.
>>>>> Were there known limitations with the new freepage accounting,
>>>>> Joonsoo?
>>>> I don't know. I also played with this and looks like there is
>>>> accounting problem, however, for my case, number of free page is slightly less
>>>> than total. I will take a look.
>>>>
>>>> Hanjun, could you tell me your malloc_size? I tested with 1 and it doesn't
>>>> look like your case.
>>> I tested with malloc_size with 2M, and it grows much bigger than 1M, also I
>>> did some other test:
>> Thanks! Now, I can re-generate erronous situation you mentioned.
>>
>>>  - run with single thread with 100000 times, everything is fine.
>>>
>>>  - I hack the cam_alloc() and free as below [1] to see if it's lock issue, with
>>>    the same test with 100 multi-thread, then I got:
>> [1] would not be sufficient to close this race.
>>
>> Try following things [A]. And, for more accurate test, I changed code a bit more
>> to prevent kernel page allocation from cma area [B]. This will prevent kernel
>> page allocation from cma area completely so we can focus cma_alloc/release race.
>>
>> Although, this is not correct fix, it could help that we can guess
>> where the problem is.
> More correct fix is something like below.
> Please test it.

Hmm, this is not working:

-bash-4.3# cat /proc/meminfo  |grep Cma                                                                                            
CmaTotal:         204800 kB                                                                                                        
CmaFree:        19388216 kB

-bash-4.3# cat /proc/meminfo                                                                                                       
MemTotal:       16342016 kB                                                                                                        
MemFree:        35146212 kB                                                                                                        
MemAvailable:   35158008 kB                                                                                                        
Buffers:            4236 kB                                                                                                        
Cached:            45032 kB                                                                                                        
SwapCached:            0 kB                                                                                                        
Active:            19276 kB                                                                                                        
Inactive:          36492 kB                                                                                                        
Active(anon):       6724 kB                                                                                                        
Inactive(anon):       52 kB                                                                                                        
Active(file):      12552 kB                                                                                                        
Inactive(file):    36440 kB                                                                                                        
Unevictable:           0 kB                                                                                                        
Mlocked:               0 kB                                                                                                        
SwapTotal:             0 kB                                                                                                        
SwapFree:              0 kB                                                                                                        
Dirty:                 0 kB                                                                                                        
Writeback:             0 kB                                                                                                        
AnonPages:          6524 kB                                                                                                        
Mapped:            24724 kB                                                                                                        
Shmem:               264 kB                                                                                                        
Slab:              26948 kB                                                                                                        
SReclaimable:       6260 kB                                                                                                        
SUnreclaim:        20688 kB                                                                                                        
KernelStack:        3296 kB                                                                                                        
PageTables:          400 kB                                                                                                        
NFS_Unstable:          0 kB                                                                                                        
Bounce:                0 kB                                                                                                        
WritebackTmp:          0 kB                                                                                                        
CommitLimit:     8171008 kB                                                                                                        
Committed_AS:      32764 kB                                                                                                        
VmallocTotal:   258998208 kB                                                                                                       
VmallocUsed:           0 kB                                                                                                        
VmallocChunk:          0 kB                                                                                                        
AnonHugePages:         0 kB                                                                                                        
CmaTotal:         204800 kB                                                                                                        
CmaFree:        19388216 kB                                                                                                        
HugePages_Total:       0                                                                                                           
HugePages_Free:        0                                                                                                           
HugePages_Rsvd:        0                                                                                                           
HugePages_Surp:        0                                                                                                           
Hugepagesize:       2048 kB

Thanks
Hanjun

>
> It checks problematic buddy merging and prevent it.
> I will try to find another way that is less intrusive for freepath performance.
>
> Thanks.
>
> ---------------->8-----------------------
> >From 855cb11368487a0f02a5ad5b3d9de375dfbb061c Mon Sep 17 00:00:00 2001
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date: Fri, 4 Mar 2016 13:28:17 +0900
> Subject: [PATCH] mm/cma: fix race
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/page_alloc.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c6c38ed..a01c3b5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -620,8 +620,8 @@ static inline void rmv_page_order(struct page *page)
>   *
>   * For recording page's order, we use page_private(page).
>   */
> -static inline int page_is_buddy(struct page *page, struct page *buddy,
> -                                                       unsigned int order)
> +static inline int page_is_buddy(struct zone *zone, struct page *page,
> +                               struct page *buddy, unsigned int order)
>  {
>         if (!pfn_valid_within(page_to_pfn(buddy)))
>                 return 0;
> @@ -644,6 +644,12 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>                 if (page_zone_id(page) != page_zone_id(buddy))
>                         return 0;
>  
> +               if (IS_ENABLED(CONFIG_CMA) &&
> +                       has_isolate_pageblock(zone) &&
> +                       order >= pageblock_order &&
> +                       is_migrate_isolate(get_pageblock_migratetype(buddy)))
> +                       return 0;
> +
>                 VM_BUG_ON_PAGE(page_count(buddy) != 0, buddy);
>  
>                 return 1;
> @@ -711,7 +717,7 @@ static inline void __free_one_page(struct page *page,
>         while (order < max_order - 1) {
>                 buddy_idx = __find_buddy_index(page_idx, order);
>                 buddy = page + (buddy_idx - page_idx);
> -               if (!page_is_buddy(page, buddy, order))
> +               if (!page_is_buddy(zone, page, buddy, order))
>                         break;
>                 /*
>                  * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
> @@ -745,7 +751,7 @@ static inline void __free_one_page(struct page *page,
>                 higher_page = page + (combined_idx - page_idx);
>                 buddy_idx = __find_buddy_index(combined_idx, order + 1);
>                 higher_buddy = higher_page + (buddy_idx - combined_idx);
> -               if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
> +               if (page_is_buddy(zone, higher_page, higher_buddy, order + 1)) {
>                         list_add_tail(&page->lru,
>                                 &zone->free_area[order].free_list[migratetype]);
>                         goto out;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
