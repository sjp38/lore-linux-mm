Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 869B86B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 00:14:09 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so47872646pac.2
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 21:14:09 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id s11si12467528pdj.153.2015.01.29.21.14.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 29 Jan 2015 21:14:08 -0800 (PST)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NIZ001UN57IIKA0@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 30 Jan 2015 14:14:06 +0900 (KST)
Content-transfer-encoding: 8BIT
Message-id: <54CB132F.60604@samsung.com>
Date: Fri, 30 Jan 2015 14:14:23 +0900
From: Heesub Shin <heesub.shin@samsung.com>
Subject: Re: CMA related memory questions
References: 
 <CABymUCNMjM2KHXXB-LM=x+FTcJL6S5_jhG3GbP7VRi2vBoW49g@mail.gmail.com>
 <CABymUCO+xaify95bUqfbCLsEjkLzEC0yT_fgkhV+qzC36JNgoA@mail.gmail.com>
 <CABymUCPgEh93QsBtRyg0S+FyE0FHwjAF75qk+NWh5TS8ehWuew@mail.gmail.com>
 <54CAF314.4070301@linaro.org> <54CAF9A4.1040606@samsung.com>
 <54CAFDC4.5070408@linaro.org>
In-reply-to: <54CAFDC4.5070408@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jun Nie <jun.nie@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Shawn Guo <shawn.guo@linaro.org>, "mark.brown@linaro.org; \"wan.zhijun\"" <wan.zhijun@zte.com.cn>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, sunae.seo@samsung.com, cmlaika.kim@samsung.com



On 01/30/2015 12:43 PM, Jun Nie wrote:
> On 2015a1'01ae??30ae?JPY 11:25, Heesub Shin wrote:
>>
>>
>> On 01/30/2015 11:57 AM, Jun Nie wrote:
>>> On 2015a1'01ae??30ae?JPY 10:36, Jun Nie wrote:
>>>> Hi Marek & Arnd,
>>>>
>>>> Did you ever know issue that free CMA memory is high, but system is
>>>> hungry for memory and page cache is very low? I am enabling CMA in
>>>> Android on my board with 512MB memory and see FreeMem in /proc/meminfo
>>>> increase a lot with CMA comparing the reservation solution on boot. But
>>>> I find system is not borrowing memory from CMA pool when running 3dmark
>>>> (high webkit workload at start). Because the FreeMem size is high, but
>>>> cache size decreasing significantly to several MB during benchmark run,
>>>> I suppose system is trying to reclaim memory from pagecache for new
>>>> allocation. My question is that what API that page cache and webkit
>>>> related functionality are using to allocate memory. Maybe page cache
>>>> require memory that is not movable/reclaimable memory, where we may
>>>> have
>>>> optimization to go thru dma_alloc_xxx to borrow CMA memory? I suppose
>>>> app level memory allocation shall be movable/reclaimable memory and can
>>>> borrow from CMA pool, but not sure whether the flag match the
>>>> movable/reclaimable memory and go thru the right path.
>>>>
>>>> Could you help share your experience/thoughts on this? Thanks!
>>
>> CC'ed linux-mm@kvack.org
>>
>> __zone_watermark_ok() assumes that free pages from CMA pageblock are not
>> free when ALLOC_CMA is not set on alloc_flags. The main goal was to
>> force core mm to keep some non-CMA always free and thus let kernel to
>> allocate a few unmovable pages from any context (including atomic, irq,
>> etc.). However, this behavior may cause excessive page reclamation as it
>> is sometimes very hard to satisfy the high wmark + balance_gap with only
>> non-CMA pages and reclaiming CMA pages does not help at all.
> Seems it is tricky to tune it. Could you help share some experience on
> this, how to change the parameters, what's pro/con? Thanks!

AFAIK, unfortunately there's no other way rather than reducing the 
number of CMA pageblocks which are making anomalies. Selectively 
ignoring CMA pages when we isolate pages from LRU could be an 
alternative, but it has another side effect. I also want to know how to 
handle this problem nicely.

>>
>> It is observed that page cache pages are excessively reclaimed and
>> entire system falls into thrashing even though the amount of free pages
>> are much higer than the high wmark. In this case, majority of the free
>> pages were from CMA page block (and about 30% pages in highmem zone were
>> from CMA pageblock). Therefore, kswapd kept running and reclaiming too
>> many pages. Although it is relatively rare and only observed on a
>> specific workload, the device gets in an unresponsive state for a while
>> (up to 10 secs), once it happens.
>>
> I am in this situation. kswapd is busy and most FreeMem is from CMA
> because I have 192MB CMA memblock and most of them are free.
>> regards,
>> heesub
>>
>>>>
>>>>
>>>> B.R.
>>>> Jun
>>>
>>> Add more people.
>>>
>>> _______________________________________________
>>> linux-arm-kernel mailing list
>>> linux-arm-kernel@lists.infradead.org
>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
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
