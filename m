Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7FD6B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 22:43:09 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so46997035pad.4
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 19:43:08 -0800 (PST)
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com. [209.85.220.51])
        by mx.google.com with ESMTPS id y4si12317361par.93.2015.01.29.19.43.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 19:43:08 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so47059533pad.10
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 19:43:08 -0800 (PST)
Message-ID: <54CAFDC4.5070408@linaro.org>
Date: Fri, 30 Jan 2015 11:43:00 +0800
From: Jun Nie <jun.nie@linaro.org>
MIME-Version: 1.0
Subject: Re: CMA related memory questions
References: <CABymUCNMjM2KHXXB-LM=x+FTcJL6S5_jhG3GbP7VRi2vBoW49g@mail.gmail.com> <CABymUCO+xaify95bUqfbCLsEjkLzEC0yT_fgkhV+qzC36JNgoA@mail.gmail.com> <CABymUCPgEh93QsBtRyg0S+FyE0FHwjAF75qk+NWh5TS8ehWuew@mail.gmail.com> <54CAF314.4070301@linaro.org> <54CAF9A4.1040606@samsung.com>
In-Reply-To: <54CAF9A4.1040606@samsung.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heesub Shin <heesub.shin@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Shawn Guo <shawn.guo@linaro.org>, "mark.brown@linaro.org; \"wan.zhijun\"" <wan.zhijun@zte.com.cn>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, sunae.seo@samsung.com, cmlaika.kim@samsung.com

On 2015a1'01ae??30ae?JPY 11:25, Heesub Shin wrote:
>
>
> On 01/30/2015 11:57 AM, Jun Nie wrote:
>> On 2015a1'01ae??30ae?JPY 10:36, Jun Nie wrote:
>>> Hi Marek & Arnd,
>>>
>>> Did you ever know issue that free CMA memory is high, but system is
>>> hungry for memory and page cache is very low? I am enabling CMA in
>>> Android on my board with 512MB memory and see FreeMem in /proc/meminfo
>>> increase a lot with CMA comparing the reservation solution on boot. But
>>> I find system is not borrowing memory from CMA pool when running 3dmark
>>> (high webkit workload at start). Because the FreeMem size is high, but
>>> cache size decreasing significantly to several MB during benchmark run,
>>> I suppose system is trying to reclaim memory from pagecache for new
>>> allocation. My question is that what API that page cache and webkit
>>> related functionality are using to allocate memory. Maybe page cache
>>> require memory that is not movable/reclaimable memory, where we may have
>>> optimization to go thru dma_alloc_xxx to borrow CMA memory? I suppose
>>> app level memory allocation shall be movable/reclaimable memory and can
>>> borrow from CMA pool, but not sure whether the flag match the
>>> movable/reclaimable memory and go thru the right path.
>>>
>>> Could you help share your experience/thoughts on this? Thanks!
>
> CC'ed linux-mm@kvack.org
>
> __zone_watermark_ok() assumes that free pages from CMA pageblock are not
> free when ALLOC_CMA is not set on alloc_flags. The main goal was to
> force core mm to keep some non-CMA always free and thus let kernel to
> allocate a few unmovable pages from any context (including atomic, irq,
> etc.). However, this behavior may cause excessive page reclamation as it
> is sometimes very hard to satisfy the high wmark + balance_gap with only
> non-CMA pages and reclaiming CMA pages does not help at all.
Seems it is tricky to tune it. Could you help share some experience on 
this, how to change the parameters, what's pro/con? Thanks!
>
> It is observed that page cache pages are excessively reclaimed and
> entire system falls into thrashing even though the amount of free pages
> are much higer than the high wmark. In this case, majority of the free
> pages were from CMA page block (and about 30% pages in highmem zone were
> from CMA pageblock). Therefore, kswapd kept running and reclaiming too
> many pages. Although it is relatively rare and only observed on a
> specific workload, the device gets in an unresponsive state for a while
> (up to 10 secs), once it happens.
>
I am in this situation. kswapd is busy and most FreeMem is from CMA 
because I have 192MB CMA memblock and most of them are free.
> regards,
> heesub
>
>>>
>>>
>>> B.R.
>>> Jun
>>
>> Add more people.
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
