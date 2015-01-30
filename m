Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1FBB06B0038
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 05:07:39 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id va8so23045767obc.0
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 02:07:38 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id 11si5064962oin.122.2015.01.30.02.07.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 02:07:38 -0800 (PST)
Received: by mail-oi0-f47.google.com with SMTP id a141so34039439oig.6
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 02:07:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54CB46B9.2040604@suse.cz>
References: <CABymUCNMjM2KHXXB-LM=x+FTcJL6S5_jhG3GbP7VRi2vBoW49g@mail.gmail.com>
 <CABymUCO+xaify95bUqfbCLsEjkLzEC0yT_fgkhV+qzC36JNgoA@mail.gmail.com>
 <CABymUCPgEh93QsBtRyg0S+FyE0FHwjAF75qk+NWh5TS8ehWuew@mail.gmail.com>
 <54CAF314.4070301@linaro.org> <54CAF9A4.1040606@samsung.com>
 <54CAFDC4.5070408@linaro.org> <54CB132F.60604@samsung.com> <54CB46B9.2040604@suse.cz>
From: Hui Zhu <teawater@gmail.com>
Date: Fri, 30 Jan 2015 18:06:57 +0800
Message-ID: <CANFwon0+1c=OHAvZxUTK4gtvYwT_Uo1UhdkBN0pt373L_hNKuw@mail.gmail.com>
Subject: Re: CMA related memory questions
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Heesub Shin <heesub.shin@samsung.com>, Jun Nie <jun.nie@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Shawn Guo <shawn.guo@linaro.org>, "mark.brown@linaro.org, wan.zhijun" <wan.zhijun@zte.com.cn>, linux-arm-kernel@lists.infradead.org, Linux Memory Management List <linux-mm@kvack.org>, sunae.seo@samsung.com, cmlaika.kim@samsung.com, Laura Abbott <lauraa@codeaurora.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Hui Zhu <zhuhui@xiaomi.com>

On Fri, Jan 30, 2015 at 4:54 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> [CC some usual CMA suspects]
>
> On 01/30/2015 06:14 AM, Heesub Shin wrote:
>>
>>
>> On 01/30/2015 12:43 PM, Jun Nie wrote:
>>> On 2015=C4=EA01=D4=C230=C8=D5 11:25, Heesub Shin wrote:
>>>>
>>>>
>>>> On 01/30/2015 11:57 AM, Jun Nie wrote:
>>>>> On 2015=C4=EA01=D4=C230=C8=D5 10:36, Jun Nie wrote:
>>>>>> Hi Marek & Arnd,
>>>>>>
>>>>>> Did you ever know issue that free CMA memory is high, but system is
>>>>>> hungry for memory and page cache is very low? I am enabling CMA in
>>>>>> Android on my board with 512MB memory and see FreeMem in /proc/memin=
fo
>>>>>> increase a lot with CMA comparing the reservation solution on boot. =
But
>>>>>> I find system is not borrowing memory from CMA pool when running 3dm=
ark
>>>>>> (high webkit workload at start). Because the FreeMem size is high, b=
ut
>>>>>> cache size decreasing significantly to several MB during benchmark r=
un,
>>>>>> I suppose system is trying to reclaim memory from pagecache for new
>>>>>> allocation. My question is that what API that page cache and webkit
>>>>>> related functionality are using to allocate memory. Maybe page cache
>>>>>> require memory that is not movable/reclaimable memory, where we may
>>>>>> have
>>>>>> optimization to go thru dma_alloc_xxx to borrow CMA memory? I suppos=
e
>>>>>> app level memory allocation shall be movable/reclaimable memory and =
can
>>>>>> borrow from CMA pool, but not sure whether the flag match the
>>>>>> movable/reclaimable memory and go thru the right path.
>>>>>>
>>>>>> Could you help share your experience/thoughts on this? Thanks!
>>>>
>>>> CC'ed linux-mm@kvack.org
>>>>
>>>> __zone_watermark_ok() assumes that free pages from CMA pageblock are n=
ot
>>>> free when ALLOC_CMA is not set on alloc_flags. The main goal was to
>>>> force core mm to keep some non-CMA always free and thus let kernel to
>>>> allocate a few unmovable pages from any context (including atomic, irq=
,
>>>> etc.). However, this behavior may cause excessive page reclamation as =
it
>>>> is sometimes very hard to satisfy the high wmark + balance_gap with on=
ly
>>>> non-CMA pages and reclaiming CMA pages does not help at all.
>>> Seems it is tricky to tune it. Could you help share some experience on
>>> this, how to change the parameters, what's pro/con? Thanks!
>>
>> AFAIK, unfortunately there's no other way rather than reducing the
>> number of CMA pageblocks which are making anomalies. Selectively
>> ignoring CMA pages when we isolate pages from LRU could be an
>> alternative, but it has another side effect. I also want to know how to
>> handle this problem nicely.
>
> Well maybe zone_balanced() could check watermarks with passing ALLOC_CMA =
in
> alloc_flags instead of 0? This would mean that high watermark will be sat=
isfied
> for movable allocations, which pass ALLOC_CMA. That should fix your too-d=
epleted
> page cache problem, I think? But in that case it should probably also che=
ck low
> watermark without ALLOC_CMA, to make sure unmovable/reclaimable allocatio=
ns
> won't stall.
>
> There might however still be some side effects. IIRC unmovable allocation=
s are
> already treated badly due to CMA, and it could make it worse. And we shou=
ld also
> check if direct reclaim paths use watermark checking with proper alloc_fl=
ags and
> classzone_idx. IIRC they don't always do, which can also result in mismat=
ched
> decisions on compaction.
>
> But maybe this is all moot if the plan for moving CMA to a different zone=
 works
> out...

I did a lot of works around it to make current CMA code work OK with waterm=
ark.
It need too much work around it.  For example, my patch
https://lkml.org/lkml/2015/1/18/28 (It still has something wrong).
To make it work OK we need add more and more hook to page alloc code.

So I think special zone is the best way for that.

After we got CMA_ZONE, we can begin to handle the issue that how to
make it work OK with different board.

Thanks,
Hui


>
>>>>
>>>> It is observed that page cache pages are excessively reclaimed and
>>>> entire system falls into thrashing even though the amount of free page=
s
>>>> are much higer than the high wmark. In this case, majority of the free
>>>> pages were from CMA page block (and about 30% pages in highmem zone we=
re
>>>> from CMA pageblock). Therefore, kswapd kept running and reclaiming too
>>>> many pages. Although it is relatively rare and only observed on a
>>>> specific workload, the device gets in an unresponsive state for a whil=
e
>>>> (up to 10 secs), once it happens.
>>>>
>>> I am in this situation. kswapd is busy and most FreeMem is from CMA
>>> because I have 192MB CMA memblock and most of them are free.
>>>> regards,
>>>> heesub
>>>>
>>>>>>
>>>>>>
>>>>>> B.R.
>>>>>> Jun
>>>>>
>>>>> Add more people.
>>>>>
>>>>> _______________________________________________
>>>>> linux-arm-kernel mailing list
>>>>> linux-arm-kernel@lists.infradead.org
>>>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
