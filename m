Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6EB6B008C
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:33:57 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so20350986pad.7
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 01:33:57 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ci1si7023394pdb.160.2014.08.25.01.33.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 25 Aug 2014 01:33:56 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAU00F28T96W8A0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 25 Aug 2014 09:36:42 +0100 (BST)
Message-id: <53FAF4EE.6060201@samsung.com>
Date: Mon, 25 Aug 2014 10:33:50 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
 <20140825012600.GN17372@bbox> <53FAED20.60200@samsung.com>
 <20140825081836.GF32620@bbox>
In-reply-to: <20140825081836.GF32620@bbox>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

Hello,

On 2014-08-25 10:18, Minchan Kim wrote:
> On Mon, Aug 25, 2014 at 10:00:32AM +0200, Marek Szyprowski wrote:
>> On 2014-08-25 03:26, Minchan Kim wrote:
>>> On Thu, Aug 21, 2014 at 10:45:12AM +0200, Marek Szyprowski wrote:
>>>> Russell King recently noticed that limiting default CMA region only to
>>>> low memory on ARM architecture causes serious memory management issues
>>>> with machines having a lot of memory (which is mainly available as high
>>>> memory). More information can be found the following thread:
>>>> http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/
>>>>
>>>> Those two patches removes this limit letting kernel to put default CMA
>>>> region into high memory when this is possible (there is enough high
>>>> memory available and architecture specific DMA limit fits).
>>> Agreed. It should be from the beginning because CMA page is effectly
>>> pinned if it is anonymous page and system has no swap.
>> Nope. Even without swap, anonymous page can be correctly migrated to other
>> location. Migration code doesn't depend on presence of swap.
> I could be possible only if the zone has freeable page(ie, free pages
> + shrinkable page like page cache). IOW, if the zone is full with
> anon pages, it's efffectively pinned.

Why? __alloc_contig_migrate_range() uses alloc_migrate_target() 
function, which
can take free page from any zone matching given flags.

>>>> This should solve strange OOM issues on systems with lots of RAM
>>>> (i.e. >1GiB) and large (>256M) CMA area.
>>> I totally agree with the patchset although I didn't review code
>>> at all.
>>>
>>> Another topic:
>>> It means it should be a problem still if system has CMA in lowmem
>>> by some reason(ex, hardware limit or other purpose of CMA
>>> rather than DMA subsystem)?
>>>
>>> In that case, an idea that just popped in my head is to migrate
>>> pages from cma area to highest zone because they are all
>>> userspace pages which should be in there but not sure it's worth
>>> to implement at this point because how many such cripple platform
>>> are.
>>>
>>> Just for the recording.
>> Moving pages between low and high zone is not that easy. If I remember
>> correctly you cannot migrate a page from low memory to high zone in
>> generic case, although it should be possible to add exception for
>> anonymous pages. This will definitely improve poor low memory
>> handling in low zone when CMA is enabled.
> Yeb, it's possible for anonymous pages but I just wonder it's worth
> to add more complexitiy to mm and and you are answering it's worth.
> Okay. May I understand your positive feedback means such platform(
> ie, DMA works with only lowmem) are still common?

There are still some platforms, which have limited DMA capabilities. However
the ability to move anonymous a page from lowmem to highmem will be a 
benefit
in any case, as low memory is really much more precious.

It also doesn't look to be really hard to add this exception for anonymous
pages from low memory. It will be just a matter of setting __GFP_HIGHMEM
flag if source page is anonymous page in alloc_migrate_target() function.
Am i right?

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
