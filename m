Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 880DA6B0070
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 02:04:49 -0500 (EST)
Message-ID: <50B5B754.1090003@huawei.com>
Date: Wed, 28 Nov 2012 15:03:48 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com> <CAA_GA1d7CxHvmZELvD_DO6u5tu1WBqfmLiuEzeFo=xMzuW50Tg@mail.gmail.com> <50B479FA.6010307@cn.fujitsu.com> <CAA_GA1ezZJyqVL=Dp5U2zzNw6bkfMKJY_STkt3E7TXkUYcv+jQ@mail.gmail.com> <50B4B6BE.3000902@cn.fujitsu.com> <CAA_GA1fE0fhLVs50rRZ6OsTw7DV0hyVC2EuRyUrbzxLztPLoeg@mail.gmail.com> <50B58E30.9060804@huawei.com> <50B5AC38.9060207@cn.fujitsu.com>
In-Reply-To: <50B5AC38.9060207@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>, hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, m.szyprowski@samsung.com

Hi Chen,

If a pageblock's migration type is movable, it may be converted to
reclaimable under memory pressure. CMA is introduced to guarantee
that pages of CMA won't be converted to other migratetypes.

And we are trying to avoid allocating kernel/DMA memory from specific
memory ranges, so we could easily reclaim pages when hot-removing
memory devices. 

I think the idea is not to directly reuse CMA for hotplug, but to 
reuse the mechanism to reserve specific memory ranges from bootmem
allocator. So CMA and hotplug could use the same code.
Basically we may try to reuse dma_declare_contiguous(), so that
we don't need to add special logic into bootmem allocator.

Regards!
Gerry

On 2012-11-28 14:16, Tang Chen wrote:
> Hi Bob, Liu Jiang,
> 
> About CMA, could you give me more info ?
> Thanks for your patent and nice advice. :)
> 
> 
> 1) I saw the following on http://lwn.net/Articles/447405/:
> 
> The "CMA" type is sticky; pages which are marked as being for CMA
> should never have their migration type changed by the kernel.
> 
> As Wen said, we now support a user interface to change movable memory
> into kernel memory. But seeing from above, the memory specified as
> CMA will not be able to be changed, right ?  If so, I don't think
> using CMA is a good idea.
> 
> 
> 2) Is CMA just implemented on ARM platform ?  I found the following in
> kernel-parameters.txt.
> 
> cma=nn[MG]      [ARM,KNL]
>         Sets the size of kernel global memory area for contiguous
>         memory allocations. For more information, see
>         include/linux/dma-contiguous.h
> 
> We are developing on x86. Could we use it ?
> 
> 
> 3) Is CMA just used for DMA ? I am a little confused here. :)
> I found the main code of CMA is implemented in dma-contiguous.c.
> 
> 
> 4) The boot options cma=xxx and movablecore_map=xxx have different
> meanings for user. Reusing CMA could make user confused, I'm afraid.
> 
> And, even if we reuse "cma=" option, we still need to do the work
> in patch 3~5, right ?
> 
> 
> Thanks. :)
> 
> 
> 
> On 11/28/2012 12:08 PM, Jiang Liu wrote:
>> On 2012-11-28 11:24, Bob Liu wrote:
>>> On Tue, Nov 27, 2012 at 8:49 PM, Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>>>> On 11/27/2012 08:09 PM, Bob Liu wrote:
>>>>>
>>>>> On Tue, Nov 27, 2012 at 4:29 PM, Tang Chen<tangchen@cn.fujitsu.com>
>>>>> wrote:
>>>>>>
>>>>>> Hi Liu,
>>>>>>
>>>>>>
>>>>>> This feature is used in memory hotplug.
>>>>>>
>>>>>> In order to implement a whole node hotplug, we need to make sure the
>>>>>> node contains no kernel memory, because memory used by kernel could
>>>>>> not be migrated. (Since the kernel memory is directly mapped,
>>>>>> VA = PA + __PAGE_OFFSET. So the physical address could not be changed.)
>>>>>>
>>>>>> User could specify all the memory on a node to be movable, so that the
>>>>>> node could be hot-removed.
>>>>>>
>>>>>
>>>>> Thank you for your explanation. It's reasonable.
>>>>>
>>>>> But i think it's a bit duplicated with CMA, i'm not sure but maybe we
>>>>> can combine it with CMA which already in mainline?
>>>>>
>>>> Hi Liu,
>>>>
>>>> Thanks for your advice. :)
>>>>
>>>> CMA is Contiguous Memory Allocator, right?  What I'm trying to do is
>>>> controlling where is the start of ZONE_MOVABLE of each node. Could
>>>> CMA do this job ?
>>>
>>> cma will not control the start of ZONE_MOVABLE of each node, but it
>>> can declare a memory that always movable
>>> and all non movable allocate request will not happen on that area.
>>>
>>> Currently cma use a boot parameter "cma=" to declare a memory size
>>> that always movable.
>>> I think it might fulfill your requirement if extending the boot
>>> parameter with a start address.
>>>
>>> more info at http://lwn.net/Articles/468044/
>>>>
>>>> And also, after a short investigation, CMA seems need to base on
>>>> memblock. But we need to limit memblock not to allocate memory on
>>>> ZONE_MOVABLE. As a result, we need to know the ranges before memblock
>>>> could be used. I'm afraid we still need an approach to get the ranges,
>>>> such as a boot option, or from static ACPI tables such as SRAT/MPST.
>>>>
>>>
>>> Yes, it's based on memblock and with boot option.
>>> In setup_arch32()
>>>      dma_contiguous_reserve(0);   =>  will declare a cma area using
>>> memblock_reserve()
>>>
>>>> I'm don't know much about CMA for now. So if you have any better idea,
>>>> please share with us, thanks. :)
>>>
>>> My idea is reuse cma like below patch(even not compiled) and boot with
>>> "cma=size@start_address".
>>> I don't know whether it can work and whether suitable for your
>>> requirement, if not forgive me for this noises.
>>>
>>> diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
>>> index 612afcc..564962a 100644
>>> --- a/drivers/base/dma-contiguous.c
>>> +++ b/drivers/base/dma-contiguous.c
>>> @@ -59,11 +59,18 @@ struct cma *dma_contiguous_default_area;
>>>    */
>>>   static const unsigned long size_bytes = CMA_SIZE_MBYTES * SZ_1M;
>>>   static long size_cmdline = -1;
>>> +static long cma_start_cmdline = -1;
>>>
>>>   static int __init early_cma(char *p)
>>>   {
>>> +       char *oldp;
>>>          pr_debug("%s(%s)\n", __func__, p);
>>> +       oldp = p;
>>>          size_cmdline = memparse(p,&p);
>>> +
>>> +       if (*p == '@')
>>> +               cma_start_cmdline = memparse(p+1,&p);
>>> +       printk("cma start:0x%x, size: 0x%x\n", size_cmdline, cma_start_cmdline);
>>>          return 0;
>>>   }
>>>   early_param("cma", early_cma);
>>> @@ -127,8 +134,10 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
>>>          if (selected_size) {
>>>                  pr_debug("%s: reserving %ld MiB for global area\n", __func__,
>>>                           selected_size / SZ_1M);
>>> -
>>> -               dma_declare_contiguous(NULL, selected_size, 0, limit);
>>> +               if (cma_size_cmdline != -1)
>>> +                       dma_declare_contiguous(NULL, selected_size,
>>> cma_start_cmdline, limit);
>>> +               else
>>> +                       dma_declare_contiguous(NULL, selected_size, 0, limit);
>>>          }
>>>   };
>> Seems a good idea to reserve memory by reusing CMA logic, though need more
>> investigation here. One of CMA goal is to ensure pages in CMA are really
>> movable, and this patchset tries to achieve the same goal at a first glance.
>>
>>
>>
>>
>>
> 
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
