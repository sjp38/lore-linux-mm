Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 214316B0271
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 10:29:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x23so155124251pgx.6
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 07:29:24 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e72si32300567pfl.77.2016.11.16.07.29.22
        for <linux-mm@kvack.org>;
        Wed, 16 Nov 2016 07:29:22 -0800 (PST)
Date: Wed, 16 Nov 2016 15:29:19 +0000
From: Brian Starkey <brian.starkey@arm.com>
Subject: Re: [PATCH] [RFC] drivers: dma-coherent: use MEMREMAP_WB instead of
 MEMREMAP_WC
Message-ID: <20161116152919.GC5833@e106950-lin.cambridge.arm.com>
References: <1478682609-26477-1-git-send-email-jaewon31.kim@samsung.com>
 <CGME20161109092808epcas3p3e44ec4c60646f29c765d4cdac27f151c@epcas3p3.samsung.com>
 <20161109092726.GA6009@e106950-lin.cambridge.arm.com>
 <5822F0AE.30101@samsung.com>
 <20161109102336.GB6009@e106950-lin.cambridge.arm.com>
 <5823D057.2050509@samsung.com>
 <20161110095155.GA28852@e106950-lin.cambridge.arm.com>
 <58259520.208@samsung.com>
 <582AC24E.8090909@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <582AC24E.8090909@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Jaewon,

On Tue, Nov 15, 2016 at 05:07:42PM +0900, Jaewon Kim wrote:
>
>Hi Brian please look into my new approach.
>I may need to change other part to use this patch but
>I want to get your comment for dma_alloc_from_coherent.
>
>[PATCH] [RFC] drivers: dma-coherent: pass struct dma_attrs to
> dma_alloc_from_coherent
>
>dma_alloc_from_coherent does not get struct dma_attrs information.
>If dma_attrs information is passed to dma_alloc_from_coherent,
>dma_alloc_from_coherent can do more jobs accodring to the information.
>As a example I added DMA_ATTR_SKIP_ZEROING to skip zeroing. Accoring
>to driver implementation ZEROING could be skipped or could be done later.
>
>Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>

I don't think I'm the right person to be reviewing this, but I didn't
spot a DMA_ATTR_SKIP_ZEROING in mainline. I'm not totally convinced
it's a good idea, but I suppose there are occasions where zeroing
really isn't needed.

I saw Laura Abbott has a commit around from a year ago which does
similar to what you're trying to do. I didn't find anything upstream
about it though.

I'd be interested to see some input from others on that, but obviously
adding that is going to be the first step here before thinking about
adding attrs to dma_alloc_from_coherent().

Thanks,
Brian

>---
> drivers/base/dma-coherent.c | 6 +++++-
> include/linux/dma-mapping.h | 7 ++++---
> 2 files changed, 9 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
>index 640a7e6..428eced 100644
>--- a/drivers/base/dma-coherent.c
>+++ b/drivers/base/dma-coherent.c
>@@ -151,6 +151,7 @@ void *dma_mark_declared_memory_occupied(struct device *dev,
>  * @dma_handle:    This will be filled with the correct dma handle
>  * @ret:    This pointer will be filled with the virtual address
>  *        to allocated area.
>+ * @attrs:    dma_attrs to pass additional information
>  *
>  * This function should be only called from per-arch dma_alloc_coherent()
>  * to support allocation from per-device coherent memory pools.
>@@ -159,7 +160,8 @@ void *dma_mark_declared_memory_occupied(struct device *dev,
>  * generic memory areas, or !0 if dma_alloc_coherent should return @ret.
>  */
> int dma_alloc_from_coherent(struct device *dev, ssize_t size,
>-                       dma_addr_t *dma_handle, void **ret)
>+                       dma_addr_t *dma_handle, void **ret,
>+                       struct dma_attrs *attrs)
> {
>     struct dma_coherent_mem *mem;
>     int order = get_order(size);
>@@ -190,6 +192,8 @@ int dma_alloc_from_coherent(struct device *dev, ssize_t size,
>     *ret = mem->virt_base + (pageno << PAGE_SHIFT);
>     dma_memory_map = (mem->flags & DMA_MEMORY_MAP);
>     spin_unlock_irqrestore(&mem->spinlock, flags);
>+    if (dma_get_attr(DMA_ATTR_SKIP_ZEROING, attrs))
>+        return 1;
>     if (dma_memory_map)
>         memset(*ret, 0, size);
>     else
>diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
>index 08528af..737fd71 100644
>--- a/include/linux/dma-mapping.h
>+++ b/include/linux/dma-mapping.h
>@@ -151,13 +151,14 @@ static inline int is_device_dma_capable(struct device *dev)
>  * Don't use them in device drivers.
>  */
> int dma_alloc_from_coherent(struct device *dev, ssize_t size,
>-                       dma_addr_t *dma_handle, void **ret);
>+                       dma_addr_t *dma_handle, void **ret,
>+                       struct dma_attrs *attrs);
> int dma_release_from_coherent(struct device *dev, int order, void *vaddr);
>
> int dma_mmap_from_coherent(struct device *dev, struct vm_area_struct *vma,
>                 void *cpu_addr, size_t size, int *ret);
> #else
>-#define dma_alloc_from_coherent(dev, size, handle, ret) (0)
>+#define dma_alloc_from_coherent(dev, size, handle, ret, attrs) (0)
> #define dma_release_from_coherent(dev, order, vaddr) (0)
> #define dma_mmap_from_coherent(dev, vma, vaddr, order, ret) (0)
> #endif /* CONFIG_HAVE_GENERIC_DMA_COHERENT */
>@@ -456,7 +457,7 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
>
>     BUG_ON(!ops);
>
>-    if (dma_alloc_from_coherent(dev, size, dma_handle, &cpu_addr))
>+    if (dma_alloc_from_coherent(dev, size, dma_handle, &cpu_addr, attrs))
>         return cpu_addr;
>
>     if (!arch_dma_alloc_attrs(&dev, &flag))
>
>Thank you
>Jaewon Kim
>
>On 2016e?? 11i?? 11i? 1/4  18:53, Jaewon Kim wrote:
>> Hi
>>
>> On 2016e?? 11i?? 10i? 1/4  18:51, Brian Starkey wrote:
>>> Hi Jaewon,
>>>
>>> On Thu, Nov 10, 2016 at 10:41:43AM +0900, Jaewon Kim wrote:
>>>> Hi
>>>>
>>>> On 2016e?? 11i?? 09i? 1/4  19:23, Brian Starkey wrote:
>>>>> Hi,
>>>>>
>>>>> On Wed, Nov 09, 2016 at 06:47:26PM +0900, Jaewon Kim wrote:
>>>>>>
>>>>>> On 2016e?? 11i?? 09i? 1/4  18:27, Brian Starkey wrote:
>>>>>>> Hi Jaewon,
>>>>>>>
>>>>>>> On Wed, Nov 09, 2016 at 06:10:09PM +0900, Jaewon Kim wrote:
>>>>>>>> Commit 6b03ae0d42bf (drivers: dma-coherent: use MEMREMAP_WC for DMA_MEMORY_MA)
>>>>>>>> added MEMREMAP_WC for DMA_MEMORY_MAP. If, however, CPU cache can be used on
>>>>>>>> DMA_MEMORY_MAP, I think MEMREMAP_WC can be changed to MEMREMAP_WB. On my local
>>>>>>>> ARM device, memset in dma_alloc_from_coherent sometimes takes much longer with
>>>>>>>> MEMREMAP_WC compared to MEMREMAP_WB.
>>>>>>>>
>>>>>>>> Test results on AArch64 by allocating 4MB with putting trace_printk right
>>>>>>>> before and after memset.
>>>>>>>>     MEMREMAP_WC : 11.0ms, 5.7ms, 4.2ms, 4.9ms, 5.4ms, 4.3ms, 3.5ms
>>>>>>>>     MEMREMAP_WB : 0.7ms, 0.6ms, 0.6ms, 0.6ms, 0.6ms, 0.5ms, 0.4 ms
>>>>>>>>
>>>>>>> This doesn't look like a good idea to me. The point of coherent memory
>>>>>>> is to have it non-cached, however WB will make writes hit the cache.
>>>>>>>
>>>>>>> Writing to the cache is of course faster than writing to RAM, but
>>>>>>> that's not what we want to do here.
>>>>>>>
>>>>>>> -Brian
>>>>>>>
>>>>>> Hi Brian
>>>>>>
>>>>>> Thank you for your comment.
>>>>>> If allocated memory will be used by TZ side, however, I think cacheable
>>>>>> also can be used to be fast on memset in dma_alloc_from_coherent.
>>>>> Are you trying to share the buffer between the secure and non-secure
>>>>> worlds on the CPU? In that case, I don't think caching really helps
>>>>> you. I'm not a TZ expert, but I believe the two worlds can never
>>>>> share cached data.
>>>> I do not want memory sharing between the secure and non-secure worlds.
>>>> I just want faster allocation.
>>> So now I'm confused. Why did you mention TZ?
>>>
>>> Could you explain what your use-case for the buffer you are allocating
>>> is?
>> I wanted to send physically contiguous memory to TZapp size at Linux runtime.
>> And during discussion I realized I need to consider more if dma-coherent is proper approach only for TZapp.
>> But if another DMA master is joined, l think we can think this issue again.
>> Like secure HW device get memory from dma-coherent and it passes to TZapp.
>>>> I am not a TZ expert, either. I also think they cannot share cached data.
>>>> As far as I know secure world can decide its cache policy with secure
>>>> world page table regardless of non-secure world.
>>>>> If you want the secure world to see the non-secure world's data, as
>>>>> far as I know you will need to clean the cache in the non-secure world
>>>>> to make sure the secure world can see it (and vice-versa). I'd expect
>>>>> this to remove most of the speed advantage of using WB in the first
>>>>> place, except for some possible speedup from more efficient bursting.
>>>> Yes I also think non-secure world need to clean the cache before secure world
>>>> access the memory region to avoid invalid data issue. But if other software
>>>> like Linux driver or hypervisor do the cache cleaning, or engineer confirm,
>>>> then we may be able to use MEMREMAP_WB or just skipping memset for faster
>>>> memory allocation in dma_alloc_from_coherent.
>>> Skipping the memset doesn't sound like a good plan, you'd potentially
>>> be leaking information to whatever device receives the memory. And
>>> adding WB mappings to an API which is intended to be used for sharing
>>> buffers with DMA masters doesn't sound like a good move either.
>>>
>>>>> If you're sharing the buffer with other DMA masters, regardless of
>>>>> secure/non-secure you're not going to want WB mappings.
>>>>>
>>>> If there is a scenario where another DMA master works on this memory,
>>>> an engineer, I think, need to consider cache clean if he/she uses WB.
>>> The whole point of dma-coherent memory is for use by DMA masters.
>>>
>>>>>> How do you think to add another flag to distinguish this case?
>>>>> You could look into the streaming DMA API. It will depend on the exact
>>>>> implementation, but at some point you're still going to have to pay
>>>>> the penalty of syncing the CPU and device.
>>>>>
>>>>> -Brian
>>>>>
>>>> I cannot find DMA API and flag for WB. So I am considering additional flag
>>>> to meet my request. In my opinion the flag can be either WB or non-zeroing.
>>> To me, it sounds like dma-coherent isn't the right tool to achieve
>>> what you want, but I'm not clear on exactly what it is you're trying
>>> to do (I know you want faster allocations, the point is what for?)
>>>
>> I actually looking into enum dma_attr which has DMA_ATTR_SKIP_ZEROING.
>> If dma_alloc_attrs in arch/arm64/include/asm/dma-mapping.h passes struct dma_attrs *attrs to dma_alloc_from_coherent,
>> I think I can do what I want.
>>
>> Thank you for your comment.
>>> -Brian
>>>
>>>> For case #1 - DMA_MEMORY_MAP_WB
>>>> --- a/drivers/base/dma-coherent.c
>>>> +++ b/drivers/base/dma-coherent.c
>>>> @@ -32,7 +32,9 @@ static bool dma_init_coherent_memory(
>>>>        if (!size)
>>>>                goto out;
>>>>
>>>> -       if (flags & DMA_MEMORY_MAP)
>>>> +       if (flags & DMA_MEMORY_MAP_WB)
>>>> +               mem_base = memremap(phys_addr, size, MEMREMAP_WB);
>>>> +       else if (flags & DMA_MEMORY_MAP)
>>>>                mem_base = memremap(phys_addr, size, MEMREMAP_WC);
>>>>        else
>>>>                mem_base = ioremap(phys_addr, size);
>>>>
>>>> For case #2 - DMA_MEMORY_MAP_NOZEROING
>>>> --- a/drivers/base/dma-coherent.c
>>>> +++ b/drivers/base/dma-coherent.c
>>>> @@ -190,6 +190,8 @@ int dma_alloc_from_coherent(struct device *dev, ssize_t size,
>>>>        *ret = mem->virt_base + (pageno << PAGE_SHIFT);
>>>>        dma_memory_map = (mem->flags & DMA_MEMORY_MAP);
>>>>        spin_unlock_irqrestore(&mem->spinlock, flags);
>>>> +       if (mem->flags & DMA_MEMORY_MAP_NOZEROING)
>>>> +               return 1;
>>>>        if (dma_memory_map)
>>>>                memset(*ret, 0, size);
>>>>        else
>>>>
>>>> Can I get your comment?
>>>>
>>>> Thank you
>>>> Jaewon Kim
>>>>
>>>>>>>> Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
>>>>>>>> ---
>>>>>>>> drivers/base/dma-coherent.c | 2 +-
>>>>>>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>>>>
>>>>>>>> diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
>>>>>>>> index 640a7e6..0512a1d 100644
>>>>>>>> --- a/drivers/base/dma-coherent.c
>>>>>>>> +++ b/drivers/base/dma-coherent.c
>>>>>>>> @@ -33,7 +33,7 @@ static bool dma_init_coherent_memory(
>>>>>>>>         goto out;
>>>>>>>>
>>>>>>>>     if (flags & DMA_MEMORY_MAP)
>>>>>>>> -        mem_base = memremap(phys_addr, size, MEMREMAP_WC);
>>>>>>>> +        mem_base = memremap(phys_addr, size, MEMREMAP_WB);
>>>>>>>>     else
>>>>>>>>         mem_base = ioremap(phys_addr, size);
>>>>>>>>     if (!mem_base)
>>>>>>>> --
>>>>>>>> 1.9.1
>>>>>>>>
>>>>>>>
>>>>>>>
>>>>>
>>>>>
>>>
>>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
