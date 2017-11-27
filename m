Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 360A06B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 08:47:59 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id x124so12684848oia.20
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:47:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x145sor4513589oif.300.2017.11.27.05.47.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 05:47:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <ac459cbf03c343ecad78450d89f340e7@AcuMS.aculab.com>
References: <CGME20171124055811epcas1p364177b515eb072d25cd9f49573daef72@epcas1p3.samsung.com>
 <20171124055833.10998-1-jaewon31.kim@samsung.com> <ac459cbf03c343ecad78450d89f340e7@AcuMS.aculab.com>
From: Jaewon Kim <jaewon31.kim@gmail.com>
Date: Mon, 27 Nov 2017 22:47:57 +0900
Message-ID: <CAJrd-UuEqwj9zcJzRTW-KvQxEEBedy8n6JGbZnmmAz=rtjgcVA@mail.gmail.com>
Subject: Re: [RFC v2] dma-coherent: introduce no-align to avoid allocation
 failure and save memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@aculab.com>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "hch@lst.de" <hch@lst.de>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello

2017-11-24 19:35 GMT+09:00 David Laight <David.Laight@aculab.com>:
> From: Jaewon Kim
>> Sent: 24 November 2017 05:59
>>
>> dma-coherent uses bitmap APIs which internally consider align based on the
>> requested size. If most of allocations are small size like KBs, using
>> alignment scheme seems to be good for anti-fragmentation. But if large
>> allocation are commonly used, then an allocation could be failed because
>> of the alignment. To avoid the allocation failure, we had to increase total
>> size.
>>
>> This is a example, total size is 30MB, only few memory at front is being
>> used, and 9MB is being requsted. Then 9MB will be aligned to 16MB. The
>> first try on offset 0MB will be failed because others already are using
>> them. The second try on offset 16MB will be failed because of ouf of bound.
>>
>> So if the alignment is not necessary on a specific dma-coherent memory
>> region, we can set no-align property. Then dma-coherent will ignore the
>> alignment only for the memory region.
>
> ISTM that the alignment needs to be a property of the request, not of the
> device. Certainly the device driver code is most likely to know the specific
> alignment requirements of any specific allocation.
>
Sorry but I'm not fully understand on 'a property of the request'. Actually
dma-coherent APIs does not get alignment through argument but it internally
uses get_order to determine alignment according to a requested size.
I think if you meant that dma-coherent APIs should work in that way
because drivers
calling to dma-coherent APIs have been assuming the alignment for a long time.

I still think few memory region could be managed without alignment if author
knows well and adds no-align into its device tree. But it's OK if open
source community
worried about the no-alignment.

Thank you
> We've some hardware that would need large allocations to be 16k aligned.
> We actually use multiple 16k allocations because any large buffers are
> accessed directly from userspace (mmap and vm_iomap_memory) and the
> card has its own page tables (with 16k pages).
>
>         David
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
