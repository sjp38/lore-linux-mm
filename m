Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B44146B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 03:22:35 -0400 (EDT)
Message-ID: <4FFD2ACA.90204@cn.fujitsu.com>
Date: Wed, 11 Jul 2012 15:27:06 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 11/13] memory-hotplug : free memmap of sparse-vmemmap
References: <4FFAB0A2.8070304@jp.fujitsu.com> <4FFAB37F.1060105@jp.fujitsu.com> <4FFD09D5.8010605@cn.fujitsu.com> <4FFD14B0.9010606@jp.fujitsu.com> <4FFD1C71.2020404@cn.fujitsu.com> <4FFD21C2.6000201@jp.fujitsu.com>
In-Reply-To: <4FFD21C2.6000201@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

At 07/11/2012 02:48 PM, Yasuaki Ishimatsu Wrote:
> Hi Wen,
> 
> 2012/07/11 15:25, Wen Congyang wrote:
>> At 07/11/2012 01:52 PM, Yasuaki Ishimatsu Wrote:
>>> 2012/07/11 14:06, Wen Congyang wrote:
>>> Hi Wen,
>>>
>>>> At 07/09/2012 06:33 PM, Yasuaki Ishimatsu Wrote:
>>>>> I don't think that all pages of virtual mapping in removed memory can be
>>>>> freed, since page which type is MIX_SECTION_INFO is difficult to free.
>>>>> So, the patch only frees page which type is SECTION_INFO at first.
>>>>>
>>>>> CC: David Rientjes <rientjes@google.com>
>>>>> CC: Jiang Liu <liuj97@gmail.com>
>>>>> CC: Len Brown <len.brown@intel.com>
>>>>> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>>>>> CC: Paul Mackerras <paulus@samba.org>
>>>>> CC: Christoph Lameter <cl@linux.com>
>>>>> Cc: Minchan Kim <minchan.kim@gmail.com>
>>>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>>>> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>>> CC: Wen Congyang <wency@cn.fujitsu.com>
>>>>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>>>>>
>>>>> ---
>>>>>    arch/x86/mm/init_64.c |   91 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>>>>    include/linux/mm.h    |    2 +
>>>>>    mm/memory_hotplug.c   |    5 ++
>>>>>    mm/sparse.c           |    5 +-
>>>>>    4 files changed, 101 insertions(+), 2 deletions(-)
>>>>>
>>>>> Index: linux-3.5-rc4/include/linux/mm.h
>>>>> ===================================================================
>>>>> --- linux-3.5-rc4.orig/include/linux/mm.h	2012-07-03 14:22:18.530011567 +0900
>>>>> +++ linux-3.5-rc4/include/linux/mm.h	2012-07-03 14:22:20.999983872 +0900
>>>>> @@ -1588,6 +1588,8 @@ int vmemmap_populate(struct page *start_
>>>>>    void vmemmap_populate_print_last(void);
>>>>>    void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
>>>>>    				  unsigned long size);
>>>>> +void vmemmap_kfree(struct page *memmpa, unsigned long nr_pages);
>>>>> +void vmemmap_free_bootmem(struct page *memmpa, unsigned long nr_pages);
>>>>>
>>>>>    enum mf_flags {
>>>>>    	MF_COUNT_INCREASED = 1 << 0,
>>>>> Index: linux-3.5-rc4/mm/sparse.c
>>>>> ===================================================================
>>>>> --- linux-3.5-rc4.orig/mm/sparse.c	2012-07-03 14:21:45.071429805 +0900
>>>>> +++ linux-3.5-rc4/mm/sparse.c	2012-07-03 14:22:21.000983767 +0900
>>>>> @@ -614,12 +614,13 @@ static inline struct page *kmalloc_secti
>>>>>    	/* This will make the necessary allocations eventually. */
>>>>>    	return sparse_mem_map_populate(pnum, nid);
>>>>>    }
>>>>> -static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
>>>>> +static void __kfree_section_memmap(struct page *page, unsigned long nr_pages)
>>>>>    {
>>>>> -	return; /* XXX: Not implemented yet */
>>>>> +	vmemmap_kfree(page, nr_pages);
>>>>
>>>> Hmm, I think you try to free the memory allocated in kmalloc_section_memmap().
>>>
>>> Yes.
>>>
>>>>
>>>>>    }
>>>>>    static void free_map_bootmem(struct page *page, unsigned long nr_pages)
>>>>>    {
>>>>> +	vmemmap_free_bootmem(page, nr_pages);
>>>>>    }
>>>>
>>>> Hmm, which function is the memory you try to free allocated in?
>>>
>>> The function try to free memory allocated from bootmem. The memory has
>>> been registered by get_page_bootmem(). So we can free the memory by
>>> put_page_bootmem().
>>
>> OK, I will read these codes, and check it.
>>
>>>
>>>>
>>>>>    #else
>>>>>    static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
>>>>> Index: linux-3.5-rc4/arch/x86/mm/init_64.c
>>>>> ===================================================================
>>>>> --- linux-3.5-rc4.orig/arch/x86/mm/init_64.c	2012-07-03 14:22:18.538011465 +0900
>>>>> +++ linux-3.5-rc4/arch/x86/mm/init_64.c	2012-07-03 14:22:21.007983103 +0900
>>>>> @@ -978,6 +978,97 @@ vmemmap_populate(struct page *start_page
>>>>>    	return 0;
>>>>>    }
>>>>>
>>>>> +unsigned long find_and_clear_pte_page(unsigned long addr, unsigned long end,
>>>>> +				      struct page **pp)
>>>>> +{
>>>>> +	pgd_t *pgd;
>>>>> +	pud_t *pud;
>>>>> +	pmd_t *pmd;
>>>>> +	pte_t *pte;
>>>>> +	unsigned long next;
>>>>> +
>>>>> +	*pp = NULL;
>>>>> +
>>>>> +	pgd = pgd_offset_k(addr);
>>>>> +	if (pgd_none(*pgd))
>>>>> +		return (addr + PAGE_SIZE) & PAGE_MASK;
>>>>
>>>> Hmm, why not goto next pgd?
>>>
>>> Does it mean "return (addr + PGDIR_SIZE) & PGDIR_MASK"?
>>>
>>>>
>>>>> +
>>>>> +	pud = pud_offset(pgd, addr);
>>>>> +	if (pud_none(*pud))
>>>>> +		return (addr + PAGE_SIZE) & PAGE_MASK;
>>>>> +
>>>>> +	if (!cpu_has_pse) {
>>>>> +		next = (addr + PAGE_SIZE) & PAGE_MASK;
>>>>> +		pmd = pmd_offset(pud, addr);
>>>>> +		if (pmd_none(*pmd))
>>>>> +			return next;
>>>>> +
>>>>> +		pte = pte_offset_kernel(pmd, addr);
>>>>> +		if (pte_none(*pte))
>>>>> +			return next;
>>>>> +
>>>>> +		*pp = pte_page(*pte);
>>>>> +		pte_clear(&init_mm, addr, pte);
>>>>
>>>> I think you should flush tlb here.
>>>
>>> Thanks, I'll update it.
>>>
>>>>
>>>>> +	} else {
>>>>> +		next = pmd_addr_end(addr, end);
>>>>> +
>>>>> +		pmd = pmd_offset(pud, addr);
>>>>> +		if (pmd_none(*pmd))
>>>>> +			return next;
>>>>> +
>>>>> +		*pp = pmd_page(*pmd);
>>>>> +		pmd_clear(pmd);
>>>>> +	}
>>>>> +
>>>>> +	return next;
>>>>> +}
>>>>> +
>>>>> +void __meminit
>>>>> +vmemmap_kfree(struct page *memmap, unsigned long nr_pages)
>>>>> +{
>>>>> +	unsigned long addr = (unsigned long)memmap;
>>>>> +	unsigned long end = (unsigned long)(memmap + nr_pages);
>>>>> +	unsigned long next;
>>>>> +	unsigned int order;
>>>>> +	struct page *page;
>>>>> +
>>>>> +	for (; addr < end; addr = next) {
>>>>> +		page = NULL;
>>>>> +		next = find_and_clear_pte_page(addr, end, &page);
>>>>> +		if (!page)
>>>>> +			continue;
>>>>> +
>>>>> +		if (is_vmalloc_addr(page_address(page)))
>>>>> +			vfree(page_address(page));
>>>>
>>>> Hmm, the memory is allocated in vmemmap_alloc_block(), and the address
>>>> can not be vmalloc address.
>>>
>>> Does it mean the if sentence is unnecessary?
>>>
>>>>
>>>>> +		else {
>>>>> +			order = next - addr;
>>>>> +			free_pages((unsigned long)page_address(page),
>>>>> +				   get_order(order));
>>>>
>>>> OOPS. I think we cannot free pages here.
>>>>
>>>> sizeof(struct page) is less than PAGE_SIZE. We store more than one struct
>>>> page in the same page. If you free it here while the other struct page
>>>> is in use, it is very dangerous.
>>>
>>> The memory has page structures for hot-removed memory. So nobody is using
>>> these pages, since the hot-removed memory has been offlined.
>>
>> The memory has page structures for hot-removed memory, but it may contain
>> page structures for the other hot-added memory.
> 
> Yes. There may be such corner case. But when does the corner case appear?
> When removed memory is not aligned to PMD_SIZE/PAGE_SIZE, does the corner
> case appear? Do you know it?

It does not depend whether the removed memory is aligned to PMD_SIZE/PAGE_SIZE.
If PAGE_SIZE % sizeof(struct page) != 0, this case will happen.

Thanks
Wen Congyang

> 
> Thank,
> Yasuaki Ishimatsu
> 
>>
>> IIUC, If we use sparse-vmemmap, all page structures is stored here.
>>
>> Thanks
>> Wen Congyang
>>
>>>
>>>>> +		}
>>>>> +	}
>>>>> +}
>>>>> +
>>>>> +void __meminit
>>>>> +vmemmap_free_bootmem(struct page *memmap, unsigned long nr_pages)
>>>>> +{
>>>>> +	unsigned long addr = (unsigned long)memmap;
>>>>> +	unsigned long end = (unsigned long)(memmap + nr_pages);
>>>>> +	unsigned long next;
>>>>> +	struct page *page;
>>>>> +	unsigned long magic;
>>>>> +
>>>>> +	for (; addr < end; addr = next) {
>>>>> +		page = NULL;
>>>>> +		next = find_and_clear_pte_page(addr, end, &page);
>>>>> +		if (!page)
>>>>> +			continue;
>>>>> +
>>>>> +		magic = (unsigned long) page->lru.next;
>>>>> +		if (magic == SECTION_INFO)
>>>>> +			put_page_bootmem(page);
>>>>> +	}
>>>>> +}
>>>>> +
>>>>>    void __meminit
>>>>>    register_page_bootmem_memmap(unsigned long section_nr, struct page *start_page,
>>>>>    			     unsigned long size)
>>>>> Index: linux-3.5-rc4/mm/memory_hotplug.c
>>>>> ===================================================================
>>>>> --- linux-3.5-rc4.orig/mm/memory_hotplug.c	2012-07-03 14:22:18.522011667 +0900
>>>>> +++ linux-3.5-rc4/mm/memory_hotplug.c	2012-07-03 14:22:21.012982694 +0900
>>>>> @@ -303,6 +303,8 @@ static int __meminit __add_section(int n
>>>>>    #ifdef CONFIG_SPARSEMEM_VMEMMAP
>>>>
>>>> I think this line can be removed now.
>>>
>>> I'll update it.
>>>
>>> Thanks,
>>> Yasuaki Ishimatsu
>>>
>>>>
>>>> Thanks
>>>> Wen Congyang
>>>>
>>>>>    static int __remove_section(struct zone *zone, struct mem_section *ms)
>>>>>    {
>>>>> +	unsigned long flags;
>>>>> +	struct pglist_data *pgdat = zone->zone_pgdat;
>>>>>    	int ret;
>>>>>
>>>>>    	if (!valid_section(ms))
>>>>> @@ -310,6 +312,9 @@ static int __remove_section(struct zone
>>>>>
>>>>>    	ret = unregister_memory_section(ms);
>>>>>
>>>>> +	pgdat_resize_lock(pgdat, &flags);
>>>>> +	sparse_remove_one_section(zone, ms);
>>>>> +	pgdat_resize_unlock(pgdat, &flags);
>>>>>    	return ret;
>>>>>    }
>>>>>    #else
>>>>>
>>>>>
>>>>
>>>
>>>
>>>
>>>
>>
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
