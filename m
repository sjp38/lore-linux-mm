Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id F34E76B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 07:21:20 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id k13so7611317iea.21
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 04:21:20 -0800 (PST)
Message-ID: <5135E33C.1030708@gmail.com>
Date: Tue, 05 Mar 2013 20:21:16 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: mm: introduce new field "managed_pages" to struct zone
References: <512EF580.6000608@gmail.com> <51336FB4.9000202@gmail.com> <5133E356.6000502@gmail.com> <5134CDBB.60700@gmail.com>
In-Reply-To: <5134CDBB.60700@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, "linux-mm@kvack.org >> Linux Memory Management List" <linux-mm@kvack.org>

On 03/05/2013 12:37 AM, Jiang Liu wrote:
> On 03/04/2013 07:57 AM, Simon Jeons wrote:
>> Hi Jiang,
>> On 03/03/2013 11:43 PM, Jiang Liu wrote:
>>> Hi Simon,
>>>      Bootmem allocator is used to managed DMA and Normal memory only, and it does not manage highmem pages because kernel
>>> can't directly access highmem pages.
>> Why you say so? Could you point out where you figure out bootmem allocator doesn't handle highmem pages? In my understanding, it doesn't distinguish low memory or high memory.
> Hi Simon,
> 	According to my understanding, bootmem allocator does only manages lowmem pages.
> For traditional bootmem allocator in mm/bootmem.c, it could only manages directly mapped lowmem pages.
> For new bootmem allocator in mm/nobootmem.c, it depends on memblock to do the real work. Let's take
> x86 as an example:
> 1) following code set memblock.current_limit to max_low_pfn.
> arch/x86/kernel/setup.c:	memblock.current_limit = get_max_mapped();
> 2) the core of bootmem allocator in nobootmem.c is function __alloc_memory_core_early(),
> which has following code to avoid allocate highmem pages:
> static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
>                                          u64 goal, u64 limit)
> {
>          void *ptr;
>          u64 addr;
>
>          if (limit > memblock.current_limit)
>                  limit = memblock.current_limit;
>
>          addr = memblock_find_in_range_node(goal, limit, size, align, nid);
>          if (!addr)
>                  return NULL;
> }
>
> I guess it's the same for other architectures. On the other hand, some other architectures
> may allocate highmem pages during boot by directly using memblock interfaces. For example,
> ppc use memblock interfaces to allocate highmem pages for giagant hugetlb pages.

highmem is just used for x86, correct? ppc doesn't have highmem I think.

>
> I'm working a patch set to fix those cases.
>
> Regards!
> Gerry
>
>
>>>      Regards!
>>>      Gerry
>>>
>>> On 02/28/2013 02:13 PM, Simon Jeons wrote:
>>>> Hi Jiang,
>>>>
>>>> https://patchwork.kernel.org/patch/1781291/
>>>>
>>>> You said that the bootmem allocator doesn't touch *highmem pages*, so highmem zones' managed_pages is set to the accurate value "spanned_pages - absent_pages" in function free_area_init_core() and won't be updated anymore. Why it doesn't touch *highmem pages*? Could you point out where you figure out this?
>>>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
