Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 328F1900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:09:27 -0400 (EDT)
Received: by pwi12 with SMTP id 12so1558841pwi.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 06:09:25 -0700 (PDT)
Message-ID: <4E033AFF.4020603@gmail.com>
Date: Thu, 23 Jun 2011 18:39:19 +0530
From: Subash Patel <subashrp@gmail.com>
MIME-Version: 1.0
Subject: Re: [Linaro-mm-sig] [PATCH/RFC 0/8] ARM: DMA-mapping framework	redesign
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>	<4E017539.30505@gmail.com>	<001d01cc30a9$ebe5e460$c3b1ad20$%szyprowski@samsung.com>	<4E01AD7B.3070806@gmail.com> <002701cc30be$ab296cc0$017c4640$%szyprowski@samsung.com> <4E02119F.4000901@codeaurora.org>
In-Reply-To: <4E02119F.4000901@codeaurora.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jordan Crouse <jcrouse@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arch@vger.kernel.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Hi Jordan,

On 06/22/2011 09:30 PM, Jordan Crouse wrote:
> On 06/22/2011 03:27 AM, Marek Szyprowski wrote:
>> Hello,
>>
>> On Wednesday, June 22, 2011 10:53 AM Subash Patel wrote:
>>
>>> On 06/22/2011 12:29 PM, Marek Szyprowski wrote:
>>>> Hello,
>>>>
>>>> On Wednesday, June 22, 2011 6:53 AM Subash Patel wrote:
>>>>
>>>>> On 06/20/2011 01:20 PM, Marek Szyprowski wrote:
>>>>>> Hello,
>>>>>>
>>>>>> This patch series is a continuation of my works on implementing
>>>>>> generic
>>>>>> IOMMU support in DMA mapping framework for ARM architecture. Now I
>>>>>> focused on the DMA mapping framework itself. It turned out that
>>>>>> adding
>>>>>> support for common dma_map_ops structure was not that hard as I
>>> initally
>>>>>> thought. After some modification most of the code fits really well to
>>>>>> the generic dma_map_ops methods.
>>>>>>
>>>>>> The only change required to dma_map_ops is a new alloc function.
>>>>>> During
>>>>>> the discussion on Linaro Memory Management meeting in Budapest we got
>>>>>> the idea that we can have only one alloc/free/mmap function with
>>>>>> additional attributes argument. This way all different kinds of
>>>>>> architecture specific buffer mappings can be hidden behind the
>>>>>> attributes without the need of creating several versions of
>>>>>> dma_alloc_
>>>>>> function. I also noticed that the dma_alloc_noncoherent() function
>>>>>> can
>>>>>> be also implemented this way with DMA_ATTRIB_NON_COHERENT attribute.
>>>>>> Systems that just defines dma_alloc_noncoherent as dma_alloc_coherent
>>>>>> will just ignore such attribute.
>>>>>>
>>>>>> Another good use case for alloc methods with attributes is the
>>>>>> possibility to allocate buffer without a valid kernel mapping. There
>>> are
>>>>>> a number of drivers (mainly V4L2 and ALSA) that only exports the DMA
>>>>>> buffers to user space. Such drivers don't touch the buffer data at
>>>>>> all.
>>>>>> For such buffers we can avoid the creation of a mapping in kernel
>>>>>> virtual address space, saving precious vmalloc area. Such buffers
>>>>>> might
>>>>>> be allocated once a new attribute DMA_ATTRIB_NO_KERNEL_MAPPING.
>>>>>
>>>>> Are you trying to say here, that the buffer would be allocated in the
>>>>> user space, and we just use it to map it to the device in DMA+IOMMU
>>>>> framework?
>>>>
>>>> Nope. I proposed an extension which would allow you to allocate a
>>>> buffer
>>>> without creating the kernel mapping for it. Right now
>>> dma_alloc_coherent()
>>>> performs 3 operations:
>>>> 1. allocates memory for the buffer
>>>> 2. creates coherent kernel mapping for the buffer
>>>> 3. translates physical buffer address to DMA address that can be
>>>> used by
>>>> the hardware.
>>>>
>>>> dma_mmap_coherent makes additional mapping for the buffer in user
>>>> process
>>>> virtual address space.
>>>>
>>>> I want make the step 2 in dma_alloc_coherent() optional to save virtual
>>>> address space: it is really limited resource. I really want to avoid
>>>> wasting it for mapping 128MiB buffers just to create full-HD processing
>>>> hardware pipeline, where no drivers will use kernel mapping at all.
>>>>
>>>
>>> I think by (2) above, you are referring to
>>> __dma_alloc_remap()->arm_vmregion_alloc() to allocate the kernel virtual
>>> address for the drivers use. That makes sense now.
>>
>> Well, this is particular implementation which is used on ARM. Other
>> architectures might implement it differently, that's why I used generic
>> description and didn't point to any particular function.
>>
>>> I have a query in similar lines, but related to user virtual address
>>> space. Is it feasible to extend these DMA interfaces(and IOMMU), to map
>>> a user allocated buffer into the hardware?
>>
>> This can be done with the current API, although it may not look so
>> straightforward. You just need to create a scatter list of user pages
>> (these can be gathered with get_user_pages function) and use dma_map_sg()
>> function. If the dma-mapping support iommu, it can map all these pages
>> into a single contiguous buffer on device (DMA) address space.
>>
>> Some additional 'magic' might be required to get access to pages that are
>> mapped with pure PFN (VM_PFNMAP flag), but imho it still can be done.
>>
>> I will try to implement this feature in videobuf2-dma-config allocator
>> together with the next version of my patches for dma-mapping&iommu.
>
> With luck DMA_ATTRIB_NO_KERNEL_MAPPING should remove any lingering
> arguments
> for trying to map user pages. Given that our ultimate goal here is buffer
> sharing, user allocated pages have limited value and appeal. If anything, I
> vote that this be a far lower priority compared to the rest of the win you
> have here.
>

We have some rare cases, where requirements like above are also there. 
So we require to have flexibility to map user allocated buffers to 
devices as well.

Please refer to my email 
(http://lists.linaro.org/pipermail/linaro-mm-sig/2011-June/000273.html)

Regards,
Subash

> Jordan
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
