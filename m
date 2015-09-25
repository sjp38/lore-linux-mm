Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC5A6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 13:35:44 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so28884275wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 10:35:43 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id bh5si5968161wjb.193.2015.09.25.10.35.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Sep 2015 10:35:42 -0700 (PDT)
Subject: Re: [PATCH 4/4] dma-debug: Allow poisoning nonzero allocations
References: <cover.1443178314.git.robin.murphy@arm.com>
 <0405c6131def5aa179ff4ba5d4201ebde89cede3.1443178314.git.robin.murphy@arm.com>
 <20150925124447.GO21513@n2100.arm.linux.org.uk>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <560585EB.3060908@arm.com>
Date: Fri, 25 Sep 2015 18:35:39 +0100
MIME-Version: 1.0
In-Reply-To: <20150925124447.GO21513@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=WINDOWS-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "sakari.ailus@iki.fi" <sakari.ailus@iki.fi>, "sumit.semwal@linaro.org" <sumit.semwal@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>

Hi Russell,

On 25/09/15 13:44, Russell King - ARM Linux wrote:
> On Fri, Sep 25, 2015 at 01:15:46PM +0100, Robin Murphy wrote:
>> Since some dma_alloc_coherent implementations return a zeroed buffer
>> regardless of whether __GFP_ZERO is passed, there exist drivers which
>> are implicitly dependent on this and pass otherwise uninitialised
>> buffers to hardware. This can lead to subtle and awkward-to-debug issues
>> using those drivers on different platforms, where nonzero uninitialised
>> junk may for instance occasionally look like a valid command which
>> causes the hardware to start misbehaving. To help with debugging such
>> issues, add the option to make uninitialised buffers much more obvious.
>
> The reason people started to do this is to stop a security leak in the
> ALSA code: ALSA allocates the ring buffer with dma_alloc_coherent()
> which used to grab pages and return them uninitialised.  These pages
> could contain anything - including the contents of /etc/shadow, or
> your bank details.
>
> ALSA then lets userspace mmap() that memory, which means any user process
> which has access to the sound devices can read data leaked from kernel
> memory.
>
> I think I did bring it up at the time I found it, and decided that the
> safest thing to do was to always return an initialised buffer - short of
> constantly auditing every dma_alloc_coherent() user which also mmap()s
> the buffer into userspace, I couldn't convince myself that it was safe
> to avoid initialising the buffer.
>
> I don't know whether the original problem still exists in ALSA or not,
> but I do know that there are dma_alloc_coherent() implementations out
> there which do not initialise prior to returning memory.

Indeed, I think we've discussed this before, and I don't imagine we'll=20
be changing the actual behaviour of the existing allocators any time soon.

[ I still don't see that as an excuse for callers not to be fixed,=20
though - anyone allocating something that may be exposed to userspace=20
has a responsibility to initialise it appropriately. After all, the DMA=20
API is just one source, what do we do if such a careless subsystem got=20
some uninitialised pages of leftover sensitive data from, say,=20
alloc_pages() instead? ]

That's a bit of a separate issue though. If a driver itself _needs_ a=20
zeroed buffer but doesn't specifically request one, or doesn't get one=20
even if it did, then that's just a regular bug, and it's what this patch=20
is intended to help weed out. We've no need for a special poison value=20
for data protection in the general case; zero is just fine for that.

>> diff --git a/lib/dma-debug.c b/lib/dma-debug.c
>> index 908fb35..40514ed 100644
>> --- a/lib/dma-debug.c
>> +++ b/lib/dma-debug.c
>> @@ -30,6 +30,7 @@
>>   #include <linux/sched.h>
>>   #include <linux/ctype.h>
>>   #include <linux/list.h>
>> +#include <linux/poison.h>
>>   #include <linux/slab.h>
>>
>>   #include <asm/sections.h>
>> @@ -1447,7 +1448,7 @@ void debug_dma_unmap_sg(struct device *dev, struct=
 scatterlist *sglist,
>>   EXPORT_SYMBOL(debug_dma_unmap_sg);
>>
>>   void debug_dma_alloc_coherent(struct device *dev, size_t size,
>> -=09=09=09      dma_addr_t dma_addr, void *virt)
>> +=09=09=09      dma_addr_t dma_addr, void *virt, gfp_t flags)
>>   {
>>   =09struct dma_debug_entry *entry;
>>
>> @@ -1457,6 +1458,9 @@ void debug_dma_alloc_coherent(struct device *dev, =
size_t size,
>>   =09if (unlikely(virt =3D=3D NULL))
>>   =09=09return;
>>
>> +=09if (IS_ENABLED(CONFIG_DMA_API_DEBUG_POISON) && !(flags & __GFP_ZERO)=
)
>> +=09=09memset(virt, DMA_ALLOC_POISON, size);
>> +
>
> This is likely to be slow in the case of non-cached memory and large
> allocations.  The config option should come with a warning.

It depends on DMA_API_DEBUG, which already has a stern performance=20
warning, is additionally hidden behind EXPERT, and carries a slightly=20
flippant yet largely truthful warning that actually using it could break=20
pretty much every driver in your system; is that not enough?

If I was feeling particularly antagonistic, I'd also point out that as=20
discussed above you've already taken the hit of a memset(0) and cache=20
flush that you _didn't_ ask for, and there was no warning on that ;)

The intent is a specific troubleshooting tool - realistically it's=20
probably only usable at all when restricting DMA debug to a per-driver=20
basis. My hunch is that nobody's too fussed about the performance of a=20
driver that doesn't work properly, especially once they've reached the=20
point of dumping buffers in an attempt to figure out why, when seeing=20
the presence or not of uniform poison values could be helpful.

(Of course, sometimes you end up debugging the allocator itself - see=20
commit 7132813c3845 - which was one of the motivating factors for this=20
patch).

Robin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
