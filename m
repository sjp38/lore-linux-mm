Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5B78D90015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 04:53:26 -0400 (EDT)
Received: by pvc12 with SMTP id 12so464585pvc.14
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 01:53:22 -0700 (PDT)
Message-ID: <4E01AD7B.3070806@gmail.com>
Date: Wed, 22 Jun 2011 14:23:15 +0530
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com> <4E017539.30505@gmail.com> <001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>
In-Reply-To: <001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Joerg Roedel' <joro@8bytes.org>, 'Arnd Bergmann' <arnd@arndb.de>



On 06/22/2011 12:29 PM, Marek Szyprowski wrote:
> Hello,
>
> On Wednesday, June 22, 2011 6:53 AM Subash Patel wrote:
>
>> On 06/20/2011 01:20 PM, Marek Szyprowski wrote:
>>> Hello,
>>>
>>> This patch series is a continuation of my works on implementing generic
>>> IOMMU support in DMA mapping framework for ARM architecture. Now I
>>> focused on the DMA mapping framework itself. It turned out that adding
>>> support for common dma_map_ops structure was not that hard as I initally
>>> thought. After some modification most of the code fits really well to
>>> the generic dma_map_ops methods.
>>>
>>> The only change required to dma_map_ops is a new alloc function. During
>>> the discussion on Linaro Memory Management meeting in Budapest we got
>>> the idea that we can have only one alloc/free/mmap function with
>>> additional attributes argument. This way all different kinds of
>>> architecture specific buffer mappings can be hidden behind the
>>> attributes without the need of creating several versions of dma_alloc_
>>> function. I also noticed that the dma_alloc_noncoherent() function can
>>> be also implemented this way with DMA_ATTRIB_NON_COHERENT attribute.
>>> Systems that just defines dma_alloc_noncoherent as dma_alloc_coherent
>>> will just ignore such attribute.
>>>
>>> Another good use case for alloc methods with attributes is the
>>> possibility to allocate buffer without a valid kernel mapping. There are
>>> a number of drivers (mainly V4L2 and ALSA) that only exports the DMA
>>> buffers to user space. Such drivers don't touch the buffer data at all.
>>> For such buffers we can avoid the creation of a mapping in kernel
>>> virtual address space, saving precious vmalloc area. Such buffers might
>>> be allocated once a new attribute DMA_ATTRIB_NO_KERNEL_MAPPING.
>>
>> Are you trying to say here, that the buffer would be allocated in the
>> user space, and we just use it to map it to the device in DMA+IOMMU
>> framework?
>
> Nope. I proposed an extension which would allow you to allocate a buffer
> without creating the kernel mapping for it. Right now dma_alloc_coherent()
> performs 3 operations:
> 1. allocates memory for the buffer
> 2. creates coherent kernel mapping for the buffer
> 3. translates physical buffer address to DMA address that can be used by
> the hardware.
>
> dma_mmap_coherent makes additional mapping for the buffer in user process
> virtual address space.
>
> I want make the step 2 in dma_alloc_coherent() optional to save virtual
> address space: it is really limited resource. I really want to avoid
> wasting it for mapping 128MiB buffers just to create full-HD processing
> hardware pipeline, where no drivers will use kernel mapping at all.
>

I think by (2) above, you are referring to 
__dma_alloc_remap()->arm_vmregion_alloc() to allocate the kernel virtual 
address for the drivers use. That makes sense now.

I have a query in similar lines, but related to user virtual address 
space. Is it feasible to extend these DMA interfaces(and IOMMU), to map 
a user allocated buffer into the hardware?

> Best regards

Regards,
Subash
SISO-SLG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
