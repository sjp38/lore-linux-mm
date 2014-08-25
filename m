Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 028CC6B0074
	for <linux-mm@kvack.org>; Mon, 25 Aug 2014 04:01:01 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so19887790pdj.21
        for <linux-mm@kvack.org>; Mon, 25 Aug 2014 01:00:58 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id cb11si52122939pac.200.2014.08.25.01.00.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 25 Aug 2014 01:00:52 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAU00G6CRPTT970@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 25 Aug 2014 09:03:29 +0100 (BST)
Message-id: <53FAED20.60200@samsung.com>
Date: Mon, 25 Aug 2014 10:00:32 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 0/2] ARM: Remove lowmem limit for default CMA region
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
 <20140825012600.GN17372@bbox>
In-reply-to: <20140825012600.GN17372@bbox>
Content-type: text/plain; charset=utf-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

Hello,

On 2014-08-25 03:26, Minchan Kim wrote:
> Hello,
>
> On Thu, Aug 21, 2014 at 10:45:12AM +0200, Marek Szyprowski wrote:
>> Hello,
>>
>> Russell King recently noticed that limiting default CMA region only to
>> low memory on ARM architecture causes serious memory management issues
>> with machines having a lot of memory (which is mainly available as high
>> memory). More information can be found the following thread:
>> http://thread.gmane.org/gmane.linux.ports.arm.kernel/348441/
>>
>> Those two patches removes this limit letting kernel to put default CMA
>> region into high memory when this is possible (there is enough high
>> memory available and architecture specific DMA limit fits).
> Agreed. It should be from the beginning because CMA page is effectly
> pinned if it is anonymous page and system has no swap.

Nope. Even without swap, anonymous page can be correctly migrated to other
location. Migration code doesn't depend on presence of swap.

>> This should solve strange OOM issues on systems with lots of RAM
>> (i.e. >1GiB) and large (>256M) CMA area.
> I totally agree with the patchset although I didn't review code
> at all.
>
> Another topic:
> It means it should be a problem still if system has CMA in lowmem
> by some reason(ex, hardware limit or other purpose of CMA
> rather than DMA subsystem)?
>
> In that case, an idea that just popped in my head is to migrate
> pages from cma area to highest zone because they are all
> userspace pages which should be in there but not sure it's worth
> to implement at this point because how many such cripple platform
> are.
>
> Just for the recording.

Moving pages between low and high zone is not that easy. If I remember
correctly you cannot migrate a page from low memory to high zone in
generic case, although it should be possible to add exception for
anonymous pages. This will definitely improve poor low memory
handling in low zone when CMA is enabled.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
