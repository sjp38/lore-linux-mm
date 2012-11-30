Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 9124B6B0072
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 21:56:45 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 719183EE0C2
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:56:43 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D7C645DE52
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:56:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3613145DE4E
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:56:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 239021DB802F
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:56:43 +0900 (JST)
Received: from g01jpexchkw06.g01.fujitsu.local (g01jpexchkw06.g01.fujitsu.local [10.0.194.45])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D20051DB803B
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:56:42 +0900 (JST)
Message-ID: <50B8202B.80503@jp.fujitsu.com>
Date: Fri, 30 Nov 2012 11:55:39 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v4 08/12] memory-hotplug: remove memmap of sparse-vmemmap
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <1354010422-19648-9-git-send-email-wency@cn.fujitsu.com> <50B5DC00.20103@huawei.com> <50B80FB1.6040906@cn.fujitsu.com> <50B81E50.9050101@huawei.com>
In-Reply-To: <50B81E50.9050101@huawei.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi Jianguo,

2012/11/30 11:47, Jianguo Wu wrote:
> Hi Congyang,
>
> Thanks for your review and comments.
>
> On 2012/11/30 9:45, Wen Congyang wrote:
>
>> At 11/28/2012 05:40 PM, Jianguo Wu Wrote:
>>> Hi Congyang,
>>>
>>> I think vmemmap's pgtable pages should be freed after all entries are cleared, I have a patch to do this.
>>> The code logic is the same as [Patch v4 09/12] memory-hotplug: remove page table of x86_64 architecture.
>>>
>>> How do you think about this?
>>>
>>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>>> ---
>>>   include/linux/mm.h  |    1 +
>>>   mm/sparse-vmemmap.c |  214 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>>   mm/sparse.c         |    5 +-
>>>   3 files changed, 218 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index 5657670..1f26af5 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -1642,6 +1642,7 @@ int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
>>>   void vmemmap_populate_print_last(void);
>>>   void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
>>>   				  unsigned long size);
>>> +void vmemmap_free(struct page *memmap, unsigned long nr_pages);
>>>
>>>   enum mf_flags {
>>>   	MF_COUNT_INCREASED = 1 << 0,
>>> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
>>> index 1b7e22a..242cb28 100644
>>> --- a/mm/sparse-vmemmap.c
>>> +++ b/mm/sparse-vmemmap.c
>>> @@ -29,6 +29,10 @@
>>>   #include <asm/pgalloc.h>
>>>   #include <asm/pgtable.h>
>>>
>>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>>> +#include <asm/tlbflush.h>
>>> +#endif
>>> +
>>>   /*
>>>    * Allocate a block of memory to be used to back the virtual memory map
>>>    * or to back the page tables that are used to create the mapping.
>>> @@ -224,3 +228,213 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>>>   		vmemmap_buf_end = NULL;
>>>   	}
>>>   }
>>> +
>>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>>> +static void vmemmap_free_pages(struct page *page, int order)
>>> +{
>>> +	struct zone *zone;
>>> +	unsigned long magic;
>>> +
>>> +	magic = (unsigned long) page->lru.next;
>>> +	if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
>>> +		put_page_bootmem(page);
>>> +
>>> +		zone = page_zone(page);
>>> +		zone_span_writelock(zone);
>>> +		zone->present_pages++;
>>> +		zone_span_writeunlock(zone);
>>> +		totalram_pages++;
>>> +	} else {
>>> +		if (is_vmalloc_addr(page_address(page)))
>>> +			vfree(page_address(page));
>>
>> Hmm, vmemmap doesn't use vmalloc() to allocate memory.
>>
>
> yes, this can be removed.
>
>>> +		else
>>> +			free_pages((unsigned long)page_address(page), order);
>>> +	}
>>> +}
>>> +
>>> +static void free_pte_table(pmd_t *pmd)
>>> +{
>>> +	pte_t *pte, *pte_start;
>>> +	int i;
>>> +
>>> +	pte_start = (pte_t *)pmd_page_vaddr(*pmd);
>>> +	for (i = 0; i < PTRS_PER_PTE; i++) {
>>> +		pte = pte_start + i;
>>> +		if (pte_val(*pte))
>>> +			return;
>>> +	}
>>> +
>>> +	/* free a pte talbe */
>>> +	vmemmap_free_pages(pmd_page(*pmd), 0);
>>> +	spin_lock(&init_mm.page_table_lock);
>>> +	pmd_clear(pmd);
>>> +	spin_unlock(&init_mm.page_table_lock);
>>> +}
>>> +
>>> +static void free_pmd_table(pud_t *pud)
>>> +{
>>> +	pmd_t *pmd, *pmd_start;
>>> +	int i;
>>> +
>>> +	pmd_start = (pmd_t *)pud_page_vaddr(*pud);
>>> +	for (i = 0; i < PTRS_PER_PMD; i++) {
>>> +		pmd = pmd_start + i;
>>> +		if (pmd_val(*pmd))
>>> +			return;
>>> +	}
>>> +
>>> +	/* free a pmd talbe */
>>> +	vmemmap_free_pages(pud_page(*pud), 0);
>>> +	spin_lock(&init_mm.page_table_lock);
>>> +	pud_clear(pud);
>>> +	spin_unlock(&init_mm.page_table_lock);
>>> +}
>>> +
>>> +static void free_pud_table(pgd_t *pgd)
>>> +{
>>> +	pud_t *pud, *pud_start;
>>> +	int i;
>>> +
>>> +	pud_start = (pud_t *)pgd_page_vaddr(*pgd);
>>> +	for (i = 0; i < PTRS_PER_PUD; i++) {
>>> +		pud = pud_start + i;
>>> +		if (pud_val(*pud))
>>> +			return;
>>> +	}
>>> +
>>> +	/* free a pud table */
>>> +	vmemmap_free_pages(pgd_page(*pgd), 0);
>>> +	spin_lock(&init_mm.page_table_lock);
>>> +	pgd_clear(pgd);
>>> +	spin_unlock(&init_mm.page_table_lock);
>>> +}
>>> +
>>> +static int split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase)
>>> +{
>>> +	struct page *page = pmd_page(*(pmd_t *)kpte);
>>> +	int i = 0;
>>> +	unsigned long magic;
>>> +	unsigned long section_nr;
>>> +
>>> +	__split_large_page(kpte, address, pbase);
>>> +	__flush_tlb_all();
>>> +
>>> +	magic = (unsigned long) page->lru.next;
>>> +	if (magic == SECTION_INFO) {
>>> +		section_nr = pfn_to_section_nr(page_to_pfn(page));
>>> +		while (i < PTRS_PER_PMD) {
>>> +			page++;
>>> +			i++;
>>> +			get_page_bootmem(section_nr, page, SECTION_INFO);
>>> +		}
>>> +	}
>>> +
>>> +	return 0;
>>> +}
>>> +
>>> +static void vmemmap_pte_remove(pmd_t *pmd, unsigned long addr, unsigned long end)
>>> +{
>>> +	pte_t *pte;
>>> +	unsigned long next;
>>> +
>>> +	pte = pte_offset_kernel(pmd, addr);
>>> +	for (; addr < end; pte++, addr += PAGE_SIZE) {
>>> +		next = (addr + PAGE_SIZE) & PAGE_MASK;
>>> +		if (next > end)
>>> +			next = end;
>>> +
>>> +		if (pte_none(*pte))
>>> +			continue;
>>> +		if (IS_ALIGNED(addr, PAGE_SIZE) &&
>>> +		    IS_ALIGNED(end, PAGE_SIZE)) {
>>> +			vmemmap_free_pages(pte_page(*pte), 0);
>>> +			spin_lock(&init_mm.page_table_lock);
>>> +			pte_clear(&init_mm, addr, pte);
>>> +			spin_unlock(&init_mm.page_table_lock);
>>
>> If addr or end is not alianed with PAGE_SIZE, you may leak some
>> memory.
>>
>
> yes, I think we can handle this situation with the method you mentioned in the change log:
> 1. When removing memory, the page structs of the revmoved memory are filled
>     with 0xFD.
> 2. All page structs are filled with 0xFD on PT/PMD, PT/PMD can be cleared.
>     In this case, the page used as PT/PMD can be freed.
>
> By the way, why is 0xFD?

There is no reason. I just filled the page with unique number.

Thanks,
Yasuaki Ishimatsu

>
>>> +		}
>>> +	}
>>> +
>>> +	free_pte_table(pmd);
>>> +	__flush_tlb_all();
>>> +}
>>> +
>>> +static void vmemmap_pmd_remove(pud_t *pud, unsigned long addr, unsigned long end)
>>> +{
>>> +	unsigned long next;
>>> +	pmd_t *pmd;
>>> +
>>> +	pmd = pmd_offset(pud, addr);
>>> +	for (; addr < end; addr = next, pmd++) {
>>> +		next = pmd_addr_end(addr, end);
>>> +		if (pmd_none(*pmd))
>>> +			continue;
>>> +
>>> +		if (cpu_has_pse) {
>>> +			unsigned long pte_base;
>>> +
>>> +			if (IS_ALIGNED(addr, PMD_SIZE) &&
>>> +			    IS_ALIGNED(next, PMD_SIZE)) {
>>> +				vmemmap_free_pages(pmd_page(*pmd),
>>> +						   get_order(PMD_SIZE));
>>> +				spin_lock(&init_mm.page_table_lock);
>>> +				pmd_clear(pmd);
>>> +				spin_unlock(&init_mm.page_table_lock);
>>> +				continue;
>>> +			}
>>> +
>>> +			/*
>>> +			 * We use 2M page, but we need to remove part of them,
>>> +			 * so split 2M page to 4K page.
>>> +			 */
>>> +			pte_base = get_zeroed_page(GFP_ATOMIC | __GFP_NOTRACK);
>>
>> get_zeored_page() may fail. You should handle this error.
>>
>
> That means system is out of memory, I will trigger a bug_on.
>
>>> +			split_large_page((pte_t *)pmd, addr, (pte_t *)pte_base);
>>> +			__flush_tlb_all();
>>> +
>>> +			spin_lock(&init_mm.page_table_lock);
>>> +			pmd_populate_kernel(&init_mm, pmd, (pte_t *)pte_base);
>>> +			spin_unlock(&init_mm.page_table_lock);
>>> +		}
>>> +
>>> +		vmemmap_pte_remove(pmd, addr, next);
>>> +	}
>>> +
>>> +	free_pmd_table(pud);
>>> +	__flush_tlb_all();
>>> +}
>>> +
>>> +static void vmemmap_pud_remove(pgd_t *pgd, unsigned long addr, unsigned long end)
>>> +{
>>> +	unsigned long next;
>>> +	pud_t *pud;
>>> +
>>> +	pud = pud_offset(pgd, addr);
>>> +	for (; addr < end; addr = next, pud++) {
>>> +		next = pud_addr_end(addr, end);
>>> +		if (pud_none(*pud))
>>> +			continue;
>>> +
>>> +		vmemmap_pmd_remove(pud, addr, next);
>>> +	}
>>> +
>>> +	free_pud_table(pgd);
>>> +	__flush_tlb_all();
>>> +}
>>> +
>>> +void vmemmap_free(struct page *memmap, unsigned long nr_pages)
>>> +{
>>> +	unsigned long addr = (unsigned long)memmap;
>>> +	unsigned long end = (unsigned long)(memmap + nr_pages);
>>> +	unsigned long next;
>>> +
>>> +	for (; addr < end; addr = next) {
>>> +		pgd_t *pgd = pgd_offset_k(addr);
>>> +
>>> +		next = pgd_addr_end(addr, end);
>>> +		if (!pgd_present(*pgd))
>>> +			continue;
>>> +
>>> +		vmemmap_pud_remove(pgd, addr, next);
>>> +		sync_global_pgds(addr, next);
>>
>> The parameter for sync_global_pgds() is [start, end], not
>> [start, end)
>>
>
> yes, thanks.
>
>>> +	}
>>> +}
>>> +#endif
>>> diff --git a/mm/sparse.c b/mm/sparse.c
>>> index fac95f2..3a16d68 100644
>>> --- a/mm/sparse.c
>>> +++ b/mm/sparse.c
>>> @@ -613,12 +613,13 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
>>>   	/* This will make the necessary allocations eventually. */
>>>   	return sparse_mem_map_populate(pnum, nid);
>>>   }
>>> -static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
>>> +static void __kfree_section_memmap(struct page *page, unsigned long nr_pages)
>> Why do you change this line?
>>
>
> 0k, it is no need to change.
>
>>>   {
>>> -	return; /* XXX: Not implemented yet */
>>> +	vmemmap_free(page, nr_pages);
>>>   }
>>>   static void free_map_bootmem(struct page *page, unsigned long nr_pages)
>>>   {
>>> +	vmemmap_free(page, nr_pages);
>>>   }
>>>   #else
>>>   static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
>>
>>
>> .
>>
>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
