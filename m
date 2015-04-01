Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id B9A8D6B0070
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 08:05:36 -0400 (EDT)
Received: by widdi4 with SMTP id di4so42224310wid.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 05:05:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si2901423wjw.184.2015.04.01.05.05.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Apr 2015 05:05:34 -0700 (PDT)
Message-ID: <551BDF0A.2090503@suse.cz>
Date: Wed, 01 Apr 2015 14:05:30 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFCv2] mm: page allocation for less fragmentation
References: <1427251155-12322-1-git-send-email-gioh.kim@lge.com> <551333D6.20708@suse.cz> <551343E3.3050709@lge.com>
In-Reply-To: <551343E3.3050709@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, rientjes@google.com, vdavydov@parallels.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com

On 03/26/2015 12:25 AM, Gioh Kim wrote:
>
>
> 2015-03-26 i??i ? 7:16i?? Vlastimil Babka i?'(e??) i?' e,?:
>> On 25.3.2015 3:39, Gioh Kim wrote:
>>> My driver allocates more than 40MB pages via alloc_page() at a time and
>>> maps them at virtual address. Totally it uses 300~400MB pages.
>>>
>>> If I run a heavy load test for a few days in 1GB memory system, I cannot allocate even order=3 pages
>>> because-of the external fragmentation.
>>>
>>> I thought I needed a anti-fragmentation solution for my driver.
>>> But there is no allocation function that considers fragmentation.
>>> The compaction is not helpful because it is only for movable pages, not unmovable pages.
>>>
>>> This patch proposes a allocation function allocates only pages in the same pageblock.
>>>
>>> I tested this patch like following:
>>>
>>> 1. When the driver allocates about 400MB and do "cat /proc/pagetypeinfo;cat /proc/buddyinfo"
>>>
>>> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
>>> Node    0, zone   Normal, type    Unmovable   3864    728    394    216    129     47     18      9      1      0      0
>>> Node    0, zone   Normal, type  Reclaimable    902     96     68     17      3      0      1      0      0      0      0
>>> Node    0, zone   Normal, type      Movable   5146    663    178     91     43     16      4      0      0      0      0
>>> Node    0, zone   Normal, type      Reserve      1      4      6      6      2      1      1      1      0      1      1
>>> Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
>>> Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
>>>
>>> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate
>>> Node 0, zone   Normal          135            3          124            2            0            0
>>> Node 0, zone   Normal   9880   1489    647    332    177     64     24     10      1      1      1
>>>
>>> 2. The driver frees all pages and allocates pages again with alloc_pages_compact.
>>
>> This is not a good test setup. You shouldn't switch the allocation types during
>> single system boot. You should compare results from a boot where common
>> allocation is used and from a boot where your new allocation is used.
>
> The new allocator is slower so I don't think it can replace current allocator.
> I don't aim to change general allocator.

I don't say you should replace current allocator for everything. Use it 
just for your driver, that's fine. But when you perform/simulate your 
driver allocation, use either the general allocator or the new 
allocator, don't change from one to another during a single boot.

> The main pupose of the new allocator is a specific allocator if system has too much fragmentation.
> If some drivers consume much memory and generate fragmentation, it can use new allocator instead at the time.
> I want to make a kind of compaction for drivers that allocates unmovable pages.
>
> Therefore I tested like that.
> I first generated fragmentation and called the new allocator.
> I wanted to check whether the fragmentation was caused by my driver
> and the pages of the driver was able to be compacted.
> I thought the pages was compacted.
>
> If I freed pages and called the commmon allocator again,
> it could decrease a little fragmentation (not much as the new allocator).
> But there was no pages compaction and fragmentation would increase soon.

Yes, we need data comparing common/new allocator in the same scenario. 
Presumably that's what you have in v3 submission.

>
>
>>
>>> This is a kind of compaction of the driver.
>>> Following is the result of "cat /proc/pagetypeinfo;cat /proc/buddyinfo"
>>>
>>> Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
>>> Node    0, zone   Normal, type    Unmovable      8      5      1    432    272     91     37     11      1      0      0
>>> Node    0, zone   Normal, type  Reclaimable    901     96     68     17      3      0      1      0      0      0      0
>>> Node    0, zone   Normal, type      Movable   4790    776    192     91     43     16      4      0      0      0      0
>>> Node    0, zone   Normal, type      Reserve      1      4      6      6      2      1      1      1      0      1      1
>>> Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
>>> Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0
>>>
>>> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate
>>> Node 0, zone   Normal          135            3          124            2            0            0
>>> Node 0, zone   Normal   5693    877    266    544    320    108     43     12      1      1      1
>>
>> The number of unmovable pageblocks didn't change here. The stats for free
>> unmovable pages does look better for higher orders than in the first listing
>> above, but even the common allocation logic would give you that result, if you
>> allocated your 400 MB using (many) order-0 allocations (since you apparently
>> don't care about physically contiguous memory). That would also prefer order-0
>> free pages before splitting higher orders. So this doesn't demonstrate benefits
>> of the alloc_pages_compact() approach I'm afraid. The results suggest that the
>> system was in a worst state when the first allocation happened, and meanwhile
>> some pages were freed, creating the large numbers of order-0 unmovable free
>> pages. Or maybe the system got fragmented in the first allocation because your
>> driver tries to allocate the memory with high-order allocations before falling
>> back to lower orders? That would probably defeat the natural anti-fragmentation
>> of the buddy system.
>
> My driver is allocating pages only with alloc_page, not alloc_pages with high order.
>
> Yes, if I freed pages and called alloc_page again, it could decrease fragmentation at the time.
> But there was no compaction and fragmentation would increase soon,
> because the allocated pages was scattered all over the system.
>
> The new allocator compacts pages. I believe it can decrease fragmentation for long time.

If that's what v3 shows, ok. Let me check.

>>
>> So a proper test could be based on this:
>>
>>> If I run a heavy load test for a few days in 1GB memory system, I cannot
>> allocate even order=3 pages
>>> because-of the external fragmentation.
>>
>> With this patch, is the situation quantifiably better? Can you post the
>> pagetype/buddyinfo for system boot where all driver allocations use the common
>> allocator, and system boot with the patch? That should be comparable if the
>> workload is the same for both boots.
>>
>
> OK. I'll. I can be good test.
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
