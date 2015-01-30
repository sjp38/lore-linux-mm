Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7DE6B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 03:54:32 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id k14so25545574wgh.10
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 00:54:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17si19597393wjs.13.2015.01.30.00.54.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 00:54:30 -0800 (PST)
Message-ID: <54CB46B9.2040604@suse.cz>
Date: Fri, 30 Jan 2015 09:54:17 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: CMA related memory questions
References: <CABymUCNMjM2KHXXB-LM=x+FTcJL6S5_jhG3GbP7VRi2vBoW49g@mail.gmail.com> <CABymUCO+xaify95bUqfbCLsEjkLzEC0yT_fgkhV+qzC36JNgoA@mail.gmail.com> <CABymUCPgEh93QsBtRyg0S+FyE0FHwjAF75qk+NWh5TS8ehWuew@mail.gmail.com> <54CAF314.4070301@linaro.org> <54CAF9A4.1040606@samsung.com> <54CAFDC4.5070408@linaro.org> <54CB132F.60604@samsung.com>
In-Reply-To: <54CB132F.60604@samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>, Jun Nie <jun.nie@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Shawn Guo <shawn.guo@linaro.org>, "mark.brown@linaro.org; \"wan.zhijun\"" <wan.zhijun@zte.com.cn>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, sunae.seo@samsung.com, cmlaika.kim@samsung.com, Laura Abbott <lauraa@codeaurora.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Hui Zhu <zhuhui@xiaomi.com>

[CC some usual CMA suspects]

On 01/30/2015 06:14 AM, Heesub Shin wrote:
> 
> 
> On 01/30/2015 12:43 PM, Jun Nie wrote:
>> On 2015a1'01ae??30ae?JPY 11:25, Heesub Shin wrote:
>>>
>>>
>>> On 01/30/2015 11:57 AM, Jun Nie wrote:
>>>> On 2015a1'01ae??30ae?JPY 10:36, Jun Nie wrote:
>>>>> Hi Marek & Arnd,
>>>>>
>>>>> Did you ever know issue that free CMA memory is high, but system is
>>>>> hungry for memory and page cache is very low? I am enabling CMA in
>>>>> Android on my board with 512MB memory and see FreeMem in /proc/meminfo
>>>>> increase a lot with CMA comparing the reservation solution on boot. But
>>>>> I find system is not borrowing memory from CMA pool when running 3dmark
>>>>> (high webkit workload at start). Because the FreeMem size is high, but
>>>>> cache size decreasing significantly to several MB during benchmark run,
>>>>> I suppose system is trying to reclaim memory from pagecache for new
>>>>> allocation. My question is that what API that page cache and webkit
>>>>> related functionality are using to allocate memory. Maybe page cache
>>>>> require memory that is not movable/reclaimable memory, where we may
>>>>> have
>>>>> optimization to go thru dma_alloc_xxx to borrow CMA memory? I suppose
>>>>> app level memory allocation shall be movable/reclaimable memory and can
>>>>> borrow from CMA pool, but not sure whether the flag match the
>>>>> movable/reclaimable memory and go thru the right path.
>>>>>
>>>>> Could you help share your experience/thoughts on this? Thanks!
>>>
>>> CC'ed linux-mm@kvack.org
>>>
>>> __zone_watermark_ok() assumes that free pages from CMA pageblock are not
>>> free when ALLOC_CMA is not set on alloc_flags. The main goal was to
>>> force core mm to keep some non-CMA always free and thus let kernel to
>>> allocate a few unmovable pages from any context (including atomic, irq,
>>> etc.). However, this behavior may cause excessive page reclamation as it
>>> is sometimes very hard to satisfy the high wmark + balance_gap with only
>>> non-CMA pages and reclaiming CMA pages does not help at all.
>> Seems it is tricky to tune it. Could you help share some experience on
>> this, how to change the parameters, what's pro/con? Thanks!
> 
> AFAIK, unfortunately there's no other way rather than reducing the 
> number of CMA pageblocks which are making anomalies. Selectively 
> ignoring CMA pages when we isolate pages from LRU could be an 
> alternative, but it has another side effect. I also want to know how to 
> handle this problem nicely.

Well maybe zone_balanced() could check watermarks with passing ALLOC_CMA in
alloc_flags instead of 0? This would mean that high watermark will be satisfied
for movable allocations, which pass ALLOC_CMA. That should fix your too-depleted
page cache problem, I think? But in that case it should probably also check low
watermark without ALLOC_CMA, to make sure unmovable/reclaimable allocations
won't stall.

There might however still be some side effects. IIRC unmovable allocations are
already treated badly due to CMA, and it could make it worse. And we should also
check if direct reclaim paths use watermark checking with proper alloc_flags and
classzone_idx. IIRC they don't always do, which can also result in mismatched
decisions on compaction.

But maybe this is all moot if the plan for moving CMA to a different zone works
out...

>>>
>>> It is observed that page cache pages are excessively reclaimed and
>>> entire system falls into thrashing even though the amount of free pages
>>> are much higer than the high wmark. In this case, majority of the free
>>> pages were from CMA page block (and about 30% pages in highmem zone were
>>> from CMA pageblock). Therefore, kswapd kept running and reclaiming too
>>> many pages. Although it is relatively rare and only observed on a
>>> specific workload, the device gets in an unresponsive state for a while
>>> (up to 10 secs), once it happens.
>>>
>> I am in this situation. kswapd is busy and most FreeMem is from CMA
>> because I have 192MB CMA memblock and most of them are free.
>>> regards,
>>> heesub
>>>
>>>>>
>>>>>
>>>>> B.R.
>>>>> Jun
>>>>
>>>> Add more people.
>>>>
>>>> _______________________________________________
>>>> linux-arm-kernel mailing list
>>>> linux-arm-kernel@lists.infradead.org
>>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
