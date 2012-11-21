Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 9A64C6B0044
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:06:20 -0500 (EST)
Message-ID: <50AC62C8.8020500@cn.fujitsu.com>
Date: Wed, 21 Nov 2012 13:12:40 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 06/12] memory-hotplug: unregister memory section on
 SPARSEMEM_VMEMMAP
References: <1351763083-7905-1-git-send-email-wency@cn.fujitsu.com> <1351763083-7905-7-git-send-email-wency@cn.fujitsu.com> <50AB669D.3060007@gmail.com> <50AC4505.1000007@cn.fujitsu.com> <50AC571C.4030504@gmail.com> <50AC5BC1.9050200@cn.fujitsu.com> <50AC608F.2020307@gmail.com>
In-Reply-To: <50AC608F.2020307@gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

At 11/21/2012 01:03 PM, Jaegeuk Hanse Wrote:
> On 11/21/2012 12:42 PM, Wen Congyang wrote:
>> At 11/21/2012 12:22 PM, Jaegeuk Hanse Wrote:
>>> On 11/21/2012 11:05 AM, Wen Congyang wrote:
>>>> At 11/20/2012 07:16 PM, Jaegeuk Hanse Wrote:
>>>>> On 11/01/2012 05:44 PM, Wen Congyang wrote:
>>>>>> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>>>
>>>>>> Currently __remove_section for SPARSEMEM_VMEMMAP does nothing. But
>>>>>> even if
>>>>>> we use SPARSEMEM_VMEMMAP, we can unregister the memory_section.
>>>>>>
>>>>>> So the patch add unregister_memory_section() into __remove_section().
>>>>> Hi Yasuaki,
>>>>>
>>>>> I have a question about these sparse vmemmap memory related
>>>>> patches. Hot
>>>>> add memory need allocated vmemmap pages, but this time is allocated by
>>>>> buddy system. How can gurantee virtual address is continuous to the
>>>>> address allocated before? If not continuous, page_to_pfn and
>>>>> pfn_to_page
>>>>> can't work correctly.
>>>> vmemmap has its virtual address range:
>>>> ffffea0000000000 - ffffeaffffffffff (=40 bits) virtual memory map (1TB)
>>>>
>>>> We allocate memory from buddy system to store struct page, and its
>>>> virtual
>>>> address isn't in this range. So we should update the page table:
>>>>
>>>> kmalloc_section_memmap()
>>>>       sparse_mem_map_populate()
>>>>           pfn_to_page() // get the virtual address in the vmemmap range
>>>>           vmemmap_populate() // we update page table here
>>>>
>>>> When we use vmemmap, page_to_pfn() always returns address in the
>>>> vmemmap
>>>> range, not the address that kmalloc() returns. So the virtual address
>>>> is continuous.
>>> Hi Congyang,
>>>
>>> Another question about memory hotplug. During hot remove memory, it will
>>> also call memblock_remove to remove related memblock.
>> IIRC, we don't touch memblock when hot-add/hot-remove memory. memblock is
>> only used for bootmem allocator. I think it isn't used after booting.
> 
> In IBM pseries servers.
> 
> pseries_remove_memory()
>     pseries_remove_memblock()
>         memblock_remove()
> 
> Furthermore, memblock is set to record available memory ranges get from
> e820 map(you can check it in memblock_x86_fill()) in x86 case, after
> hot-remove memory, this range of memory can't be available, why not
> remove them as pseries servers' codes do.

Oh, it is powerpc, and I don't read this code. I will check it now.

Thanks for pointing it out.

Wen Congyang

> 
>>> memblock_remove()
>>>             __memblock_remove()memory-hotplug: unregister memory
>>> section on SPARSEMEM_VMEMMAP
>>>
>>>                     memblock_isolate_range()
>>>                     memblock_remove_region()
>>>
>>> But memblock_isolate_range() only record fully contained regions,
>>> regions which are partial overlapped just be splitted instead of record.
>>> So these partial overlapped regions can't be removed. Where I miss?
>> No, memblock_isolate_range() can deal with partial overlapped region.
>> =====================
>>         if (rbase < base) {
>>             /*
>>              * @rgn intersects from below.  Split and continue
>>              * to process the next region - the new top half.
>>              */
>>             rgn->base = base;
>>             rgn->size -= base - rbase;
>>             type->total_size -= base - rbase;
>>             memblock_insert_region(type, i, rbase, base - rbase,
>>                            memblock_get_region_node(rgn));
>>         } else if (rend > end) {
>>             /*
>>              * @rgn intersects from above.  Split and redo the
>>              * current region - the new bottom half.
>>              */
>>             rgn->base = end;
>>             rgn->size -= end - rbase;
>>             type->total_size -= end - rbase;
>>             memblock_insert_region(type, i--, rbase, end - rbase,
>>                            memblock_get_region_node(rgn));
>> =====================
>>
>> If the region is partial overlapped region, we will split the old
>> region into
>> two regions. After doing this, it is full contained region now.
> 
> You are right, I misunderstand the codes.
> 
>>
>> Thanks
>> Wen Congyang
>>
>>> Regards,
>>> Jaegeuk
>>>
>>>> Thanks
>>>> Wen Congyang
>>>>> Regards,
>>>>> Jaegeuk
>>>>>
>>>>>> CC: David Rientjes <rientjes@google.com>
>>>>>> CC: Jiang Liu <liuj97@gmail.com>
>>>>>> CC: Len Brown <len.brown@intel.com>
>>>>>> CC: Christoph Lameter <cl@linux.com>
>>>>>> Cc: Minchan Kim <minchan.kim@gmail.com>
>>>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>>>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>>>> CC: Wen Congyang <wency@cn.fujitsu.com>
>>>>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>>> ---
>>>>>>     mm/memory_hotplug.c | 13 ++++++++-----
>>>>>>     1 file changed, 8 insertions(+), 5 deletions(-)
>>>>>>
>>>>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>>>>> index ca07433..66a79a7 100644
>>>>>> --- a/mm/memory_hotplug.c
>>>>>> +++ b/mm/memory_hotplug.c
>>>>>> @@ -286,11 +286,14 @@ static int __meminit __add_section(int nid,
>>>>>> struct zone *zone,
>>>>>>     #ifdef CONFIG_SPARSEMEM_VMEMMAP
>>>>>>     static int __remove_section(struct zone *zone, struct mem_section
>>>>>> *ms)
>>>>>>     {
>>>>>> -    /*
>>>>>> -     * XXX: Freeing memmap with vmemmap is not implement yet.
>>>>>> -     *      This should be removed later.
>>>>>> -     */
>>>>>> -    return -EBUSY;
>>>>>> +    int ret = -EINVAL;
>>>>>> +
>>>>>> +    if (!valid_section(ms))
>>>>>> +        return ret;
>>>>>> +
>>>>>> +    ret = unregister_memory_section(ms);
>>>>>> +
>>>>>> +    return ret;
>>>>>>     }
>>>>>>     #else
>>>>>>     static int __remove_section(struct zone *zone, struct mem_section
>>>>>> *ms)
>>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
