Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id CC61F6B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 00:56:32 -0500 (EST)
Message-ID: <5108B5D1.6050600@cn.fujitsu.com>
Date: Wed, 30 Jan 2013 13:55:29 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 08/15] memory-hotplug: Common APIs to support page
 tables hot-remove
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>   <1357723959-5416-9-git-send-email-tangchen@cn.fujitsu.com>  <1359464694.1624.18.camel@kernel> <51088298.9080302@cn.fujitsu.com> <1359516425.1288.5.camel@kernel>
In-Reply-To: <1359516425.1288.5.camel@kernel>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

On 01/30/2013 11:27 AM, Simon Jeons wrote:
> On Wed, 2013-01-30 at 10:16 +0800, Tang Chen wrote:
>> On 01/29/2013 09:04 PM, Simon Jeons wrote:
>>> Hi Tang,
>>> On Wed, 2013-01-09 at 17:32 +0800, Tang Chen wrote:
>>>> From: Wen Congyang<wency@cn.fujitsu.com>
>>>>
>>>> When memory is removed, the corresponding pagetables should alse be removed.
>>>> This patch introduces some common APIs to support vmemmap pagetable and x86_64
>>>> architecture pagetable removing.
>>>
>>> Why don't need to build_all_zonelists like online_pages does during
>>> hot-add path(add_memory)?
>>
>> Hi Simon,
>>
>> As you said, build_all_zonelists is done by online_pages. When the
>> memory device
>> is hot-added, we cannot use it. we can only use is when we online the
>> pages on it.
>
> Why?
>
> If a node has just one memory device and memory is small, some zone will
> not present like zone_highmem, then hot-add another memory device and
> zone_highmem appear, if you should build_all_zonelists this time?

Hi Simon,

We built zone list when the first memory on the node is hot-added.

add_memory()
  |-->if (!node_online(nid)) hotadd_new_pgdat()
                              |-->free_area_init_node()
                              |-->build_all_zonelists()

All the zones on the new node will be initialized as empty. So here, we 
build zone list.

But actually we did nothing because no page is online, and zones are empty.
In build_zonelists_node(), populated_zone(zone) will always be false.

The real work of building zone list is when pages are online. :)


And in your question, you said some small memory is there, and 
zone_normal is present.
OK, when these pages are onlined (not added), the zone list has been 
rebuilt.
But pages in zone_highmem is not added, which means not onlined, so we 
don't need to
build zone list for it. And later, the zone_highmem pages are added, we 
still don't
rebuild the zone list because the real rebuilding work is when the pages 
are onlined.

I think this is the current logic. :)

Thanks. :)

>
>>
>> But we can online the pages as different types, kernel or movable (which
>> belongs to
>> different zones), and we can online part of the memory, not all of them.
>> So each time we online some pages, we should check if we need to update
>> the zone list.
>>
>> So I think that is why we do build_all_zonelists when online_pages.
>> (just my opinion)
>>
>> Thanks. :)
>>
>>>
>>>>
>>>> All pages of virtual mapping in removed memory cannot be freedi if some pages
>>>> used as PGD/PUD includes not only removed memory but also other memory. So the
>>>> patch uses the following way to check whether page can be freed or not.
>>>>
>>>>    1. When removing memory, the page structs of the revmoved memory are filled
>>>>       with 0FD.
>>>>    2. All page structs are filled with 0xFD on PT/PMD, PT/PMD can be cleared.
>>>>       In this case, the page used as PT/PMD can be freed.
>>>>
>>>> Signed-off-by: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>>>> Signed-off-by: Jianguo Wu<wujianguo@huawei.com>
>>>> Signed-off-by: Wen Congyang<wency@cn.fujitsu.com>
>>>> Signed-off-by: Tang Chen<tangchen@cn.fujitsu.com>
>>>> ---
>>>>    arch/x86/include/asm/pgtable_types.h |    1 +
>>>>    arch/x86/mm/init_64.c                |  299 ++++++++++++++++++++++++++++++++++
>>>>    arch/x86/mm/pageattr.c               |   47 +++---
>>>>    include/linux/bootmem.h              |    1 +
>>>>    4 files changed, 326 insertions(+), 22 deletions(-)
>>>>
>>>> diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
>>>> index 3c32db8..4b6fd2a 100644
>>>> --- a/arch/x86/include/asm/pgtable_types.h
>>>> +++ b/arch/x86/include/asm/pgtable_types.h
>>>> @@ -352,6 +352,7 @@ static inline void update_page_count(int level, unsigned long pages) { }
>>>>     * as a pte too.
>>>>     */
>>>>    extern pte_t *lookup_address(unsigned long address, unsigned int *level);
>>>> +extern int __split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase);
>>>>
>>>>    #endif	/* !__ASSEMBLY__ */
>>>>
>>>> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
>>>> index 9ac1723..fe01116 100644
>>>> --- a/arch/x86/mm/init_64.c
>>>> +++ b/arch/x86/mm/init_64.c
>>>> @@ -682,6 +682,305 @@ int arch_add_memory(int nid, u64 start, u64 size)
>>>>    }
>>>>    EXPORT_SYMBOL_GPL(arch_add_memory);
>>>>
>>>> +#define PAGE_INUSE 0xFD
>>>> +
>>>> +static void __meminit free_pagetable(struct page *page, int order)
>>>> +{
>>>> +	struct zone *zone;
>>>> +	bool bootmem = false;
>>>> +	unsigned long magic;
>>>> +	unsigned int nr_pages = 1<<   order;
>>>> +
>>>> +	/* bootmem page has reserved flag */
>>>> +	if (PageReserved(page)) {
>>>> +		__ClearPageReserved(page);
>>>> +		bootmem = true;
>>>> +
>>>> +		magic = (unsigned long)page->lru.next;
>>>> +		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
>>>> +			while (nr_pages--)
>>>> +				put_page_bootmem(page++);
>>>> +		} else
>>>> +			__free_pages_bootmem(page, order);
>>>> +	} else
>>>> +		free_pages((unsigned long)page_address(page), order);
>>>> +
>>>> +	/*
>>>> +	 * SECTION_INFO pages and MIX_SECTION_INFO pages
>>>> +	 * are all allocated by bootmem.
>>>> +	 */
>>>> +	if (bootmem) {
>>>> +		zone = page_zone(page);
>>>> +		zone_span_writelock(zone);
>>>> +		zone->present_pages += nr_pages;
>>>> +		zone_span_writeunlock(zone);
>>>> +		totalram_pages += nr_pages;
>>>> +	}
>>>> +}
>>>> +
>>>> +static void __meminit free_pte_table(pte_t *pte_start, pmd_t *pmd)
>>>> +{
>>>> +	pte_t *pte;
>>>> +	int i;
>>>> +
>>>> +	for (i = 0; i<   PTRS_PER_PTE; i++) {
>>>> +		pte = pte_start + i;
>>>> +		if (pte_val(*pte))
>>>> +			return;
>>>> +	}
>>>> +
>>>> +	/* free a pte talbe */
>>>> +	free_pagetable(pmd_page(*pmd), 0);
>>>> +	spin_lock(&init_mm.page_table_lock);
>>>> +	pmd_clear(pmd);
>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>> +}
>>>> +
>>>> +static void __meminit free_pmd_table(pmd_t *pmd_start, pud_t *pud)
>>>> +{
>>>> +	pmd_t *pmd;
>>>> +	int i;
>>>> +
>>>> +	for (i = 0; i<   PTRS_PER_PMD; i++) {
>>>> +		pmd = pmd_start + i;
>>>> +		if (pmd_val(*pmd))
>>>> +			return;
>>>> +	}
>>>> +
>>>> +	/* free a pmd talbe */
>>>> +	free_pagetable(pud_page(*pud), 0);
>>>> +	spin_lock(&init_mm.page_table_lock);
>>>> +	pud_clear(pud);
>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>> +}
>>>> +
>>>> +/* Return true if pgd is changed, otherwise return false. */
>>>> +static bool __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd)
>>>> +{
>>>> +	pud_t *pud;
>>>> +	int i;
>>>> +
>>>> +	for (i = 0; i<   PTRS_PER_PUD; i++) {
>>>> +		pud = pud_start + i;
>>>> +		if (pud_val(*pud))
>>>> +			return false;
>>>> +	}
>>>> +
>>>> +	/* free a pud table */
>>>> +	free_pagetable(pgd_page(*pgd), 0);
>>>> +	spin_lock(&init_mm.page_table_lock);
>>>> +	pgd_clear(pgd);
>>>> +	spin_unlock(&init_mm.page_table_lock);
>>>> +
>>>> +	return true;
>>>> +}
>>>> +
>>>> +static void __meminit
>>>> +remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
>>>> +		 bool direct)
>>>> +{
>>>> +	unsigned long next, pages = 0;
>>>> +	pte_t *pte;
>>>> +	void *page_addr;
>>>> +	phys_addr_t phys_addr;
>>>> +
>>>> +	pte = pte_start + pte_index(addr);
>>>> +	for (; addr<   end; addr = next, pte++) {
>>>> +		next = (addr + PAGE_SIZE)&   PAGE_MASK;
>>>> +		if (next>   end)
>>>> +			next = end;
>>>> +
>>>> +		if (!pte_present(*pte))
>>>> +			continue;
>>>> +
>>>> +		/*
>>>> +		 * We mapped [0,1G) memory as identity mapping when
>>>> +		 * initializing, in arch/x86/kernel/head_64.S. These
>>>> +		 * pagetables cannot be removed.
>>>> +		 */
>>>> +		phys_addr = pte_val(*pte) + (addr&   PAGE_MASK);
>>>> +		if (phys_addr<   (phys_addr_t)0x40000000)
>>>> +			return;
>>>> +
>>>> +		if (IS_ALIGNED(addr, PAGE_SIZE)&&
>>>> +		    IS_ALIGNED(next, PAGE_SIZE)) {
>>>> +			if (!direct) {
>>>> +				free_pagetable(pte_page(*pte), 0);
>>>> +				pages++;
>>>> +			}
>>>> +
>>>> +			spin_lock(&init_mm.page_table_lock);
>>>> +			pte_clear(&init_mm, addr, pte);
>>>> +			spin_unlock(&init_mm.page_table_lock);
>>>> +		} else {
>>>> +			/*
>>>> +			 * If we are not removing the whole page, it means
>>>> +			 * other ptes in this page are being used and we canot
>>>> +			 * remove them. So fill the unused ptes with 0xFD, and
>>>> +			 * remove the page when it is wholly filled with 0xFD.
>>>> +			 */
>>>> +			memset((void *)addr, PAGE_INUSE, next - addr);
>>>> +			page_addr = page_address(pte_page(*pte));
>>>> +
>>>> +			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
>>>> +				free_pagetable(pte_page(*pte), 0);
>>>> +				pages++;
>>>> +
>>>> +				spin_lock(&init_mm.page_table_lock);
>>>> +				pte_clear(&init_mm, addr, pte);
>>>> +				spin_unlock(&init_mm.page_table_lock);
>>>> +			}
>>>> +		}
>>>> +	}
>>>> +
>>>> +	/* Call free_pte_table() in remove_pmd_table(). */
>>>> +	flush_tlb_all();
>>>> +	if (direct)
>>>> +		update_page_count(PG_LEVEL_4K, -pages);
>>>> +}
>>>> +
>>>> +static void __meminit
>>>> +remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
>>>> +		 bool direct)
>>>> +{
>>>> +	unsigned long pte_phys, next, pages = 0;
>>>> +	pte_t *pte_base;
>>>> +	pmd_t *pmd;
>>>> +
>>>> +	pmd = pmd_start + pmd_index(addr);
>>>> +	for (; addr<   end; addr = next, pmd++) {
>>>> +		next = pmd_addr_end(addr, end);
>>>> +
>>>> +		if (!pmd_present(*pmd))
>>>> +			continue;
>>>> +
>>>> +		if (pmd_large(*pmd)) {
>>>> +			if (IS_ALIGNED(addr, PMD_SIZE)&&
>>>> +			    IS_ALIGNED(next, PMD_SIZE)) {
>>>> +				if (!direct) {
>>>> +					free_pagetable(pmd_page(*pmd),
>>>> +						       get_order(PMD_SIZE));
>>>> +					pages++;
>>>> +				}
>>>> +
>>>> +				spin_lock(&init_mm.page_table_lock);
>>>> +				pmd_clear(pmd);
>>>> +				spin_unlock(&init_mm.page_table_lock);
>>>> +				continue;
>>>> +			}
>>>> +
>>>> +			/*
>>>> +			 * We use 2M page, but we need to remove part of them,
>>>> +			 * so split 2M page to 4K page.
>>>> +			 */
>>>> +			pte_base = (pte_t *)alloc_low_page(&pte_phys);
>>>> +			BUG_ON(!pte_base);
>>>> +			__split_large_page((pte_t *)pmd, addr,
>>>> +					   (pte_t *)pte_base);
>>>> +
>>>> +			spin_lock(&init_mm.page_table_lock);
>>>> +			pmd_populate_kernel(&init_mm, pmd, __va(pte_phys));
>>>> +			spin_unlock(&init_mm.page_table_lock);
>>>> +
>>>> +			flush_tlb_all();
>>>> +		}
>>>> +
>>>> +		pte_base = (pte_t *)map_low_page((pte_t *)pmd_page_vaddr(*pmd));
>>>> +		remove_pte_table(pte_base, addr, next, direct);
>>>> +		free_pte_table(pte_base, pmd);
>>>> +		unmap_low_page(pte_base);
>>>> +	}
>>>> +
>>>> +	/* Call free_pmd_table() in remove_pud_table(). */
>>>> +	if (direct)
>>>> +		update_page_count(PG_LEVEL_2M, -pages);
>>>> +}
>>>> +
>>>> +static void __meminit
>>>> +remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
>>>> +		 bool direct)
>>>> +{
>>>> +	unsigned long pmd_phys, next, pages = 0;
>>>> +	pmd_t *pmd_base;
>>>> +	pud_t *pud;
>>>> +
>>>> +	pud = pud_start + pud_index(addr);
>>>> +	for (; addr<   end; addr = next, pud++) {
>>>> +		next = pud_addr_end(addr, end);
>>>> +
>>>> +		if (!pud_present(*pud))
>>>> +			continue;
>>>> +
>>>> +		if (pud_large(*pud)) {
>>>> +			if (IS_ALIGNED(addr, PUD_SIZE)&&
>>>> +			    IS_ALIGNED(next, PUD_SIZE)) {
>>>> +				if (!direct) {
>>>> +					free_pagetable(pud_page(*pud),
>>>> +						       get_order(PUD_SIZE));
>>>> +					pages++;
>>>> +				}
>>>> +
>>>> +				spin_lock(&init_mm.page_table_lock);
>>>> +				pud_clear(pud);
>>>> +				spin_unlock(&init_mm.page_table_lock);
>>>> +				continue;
>>>> +			}
>>>> +
>>>> +			/*
>>>> +			 * We use 1G page, but we need to remove part of them,
>>>> +			 * so split 1G page to 2M page.
>>>> +			 */
>>>> +			pmd_base = (pmd_t *)alloc_low_page(&pmd_phys);
>>>> +			BUG_ON(!pmd_base);
>>>> +			__split_large_page((pte_t *)pud, addr,
>>>> +					   (pte_t *)pmd_base);
>>>> +
>>>> +			spin_lock(&init_mm.page_table_lock);
>>>> +			pud_populate(&init_mm, pud, __va(pmd_phys));
>>>> +			spin_unlock(&init_mm.page_table_lock);
>>>> +
>>>> +			flush_tlb_all();
>>>> +		}
>>>> +
>>>> +		pmd_base = (pmd_t *)map_low_page((pmd_t *)pud_page_vaddr(*pud));
>>>> +		remove_pmd_table(pmd_base, addr, next, direct);
>>>> +		free_pmd_table(pmd_base, pud);
>>>> +		unmap_low_page(pmd_base);
>>>> +	}
>>>> +
>>>> +	if (direct)
>>>> +		update_page_count(PG_LEVEL_1G, -pages);
>>>> +}
>>>> +
>>>> +/* start and end are both virtual address. */
>>>> +static void __meminit
>>>> +remove_pagetable(unsigned long start, unsigned long end, bool direct)
>>>> +{
>>>> +	unsigned long next;
>>>> +	pgd_t *pgd;
>>>> +	pud_t *pud;
>>>> +	bool pgd_changed = false;
>>>> +
>>>> +	for (; start<   end; start = next) {
>>>> +		pgd = pgd_offset_k(start);
>>>> +		if (!pgd_present(*pgd))
>>>> +			continue;
>>>> +
>>>> +		next = pgd_addr_end(start, end);
>>>> +
>>>> +		pud = (pud_t *)map_low_page((pud_t *)pgd_page_vaddr(*pgd));
>>>> +		remove_pud_table(pud, start, next, direct);
>>>> +		if (free_pud_table(pud, pgd))
>>>> +			pgd_changed = true;
>>>> +		unmap_low_page(pud);
>>>> +	}
>>>> +
>>>> +	if (pgd_changed)
>>>> +		sync_global_pgds(start, end - 1);
>>>> +
>>>> +	flush_tlb_all();
>>>> +}
>>>> +
>>>>    #ifdef CONFIG_MEMORY_HOTREMOVE
>>>>    int __ref arch_remove_memory(u64 start, u64 size)
>>>>    {
>>>> diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
>>>> index a718e0d..7dcb6f9 100644
>>>> --- a/arch/x86/mm/pageattr.c
>>>> +++ b/arch/x86/mm/pageattr.c
>>>> @@ -501,21 +501,13 @@ out_unlock:
>>>>    	return do_split;
>>>>    }
>>>>
>>>> -static int split_large_page(pte_t *kpte, unsigned long address)
>>>> +int __split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase)
>>>>    {
>>>>    	unsigned long pfn, pfninc = 1;
>>>>    	unsigned int i, level;
>>>> -	pte_t *pbase, *tmp;
>>>> +	pte_t *tmp;
>>>>    	pgprot_t ref_prot;
>>>> -	struct page *base;
>>>> -
>>>> -	if (!debug_pagealloc)
>>>> -		spin_unlock(&cpa_lock);
>>>> -	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
>>>> -	if (!debug_pagealloc)
>>>> -		spin_lock(&cpa_lock);
>>>> -	if (!base)
>>>> -		return -ENOMEM;
>>>> +	struct page *base = virt_to_page(pbase);
>>>>
>>>>    	spin_lock(&pgd_lock);
>>>>    	/*
>>>> @@ -523,10 +515,11 @@ static int split_large_page(pte_t *kpte, unsigned long address)
>>>>    	 * up for us already:
>>>>    	 */
>>>>    	tmp = lookup_address(address,&level);
>>>> -	if (tmp != kpte)
>>>> -		goto out_unlock;
>>>> +	if (tmp != kpte) {
>>>> +		spin_unlock(&pgd_lock);
>>>> +		return 1;
>>>> +	}
>>>>
>>>> -	pbase = (pte_t *)page_address(base);
>>>>    	paravirt_alloc_pte(&init_mm, page_to_pfn(base));
>>>>    	ref_prot = pte_pgprot(pte_clrhuge(*kpte));
>>>>    	/*
>>>> @@ -579,17 +572,27 @@ static int split_large_page(pte_t *kpte, unsigned long address)
>>>>    	 * going on.
>>>>    	 */
>>>>    	__flush_tlb_all();
>>>> +	spin_unlock(&pgd_lock);
>>>>
>>>> -	base = NULL;
>>>> +	return 0;
>>>> +}
>>>>
>>>> -out_unlock:
>>>> -	/*
>>>> -	 * If we dropped out via the lookup_address check under
>>>> -	 * pgd_lock then stick the page back into the pool:
>>>> -	 */
>>>> -	if (base)
>>>> +static int split_large_page(pte_t *kpte, unsigned long address)
>>>> +{
>>>> +	pte_t *pbase;
>>>> +	struct page *base;
>>>> +
>>>> +	if (!debug_pagealloc)
>>>> +		spin_unlock(&cpa_lock);
>>>> +	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
>>>> +	if (!debug_pagealloc)
>>>> +		spin_lock(&cpa_lock);
>>>> +	if (!base)
>>>> +		return -ENOMEM;
>>>> +
>>>> +	pbase = (pte_t *)page_address(base);
>>>> +	if (__split_large_page(kpte, address, pbase))
>>>>    		__free_page(base);
>>>> -	spin_unlock(&pgd_lock);
>>>>
>>>>    	return 0;
>>>>    }
>>>> diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
>>>> index 3f778c2..190ff06 100644
>>>> --- a/include/linux/bootmem.h
>>>> +++ b/include/linux/bootmem.h
>>>> @@ -53,6 +53,7 @@ extern void free_bootmem_node(pg_data_t *pgdat,
>>>>    			      unsigned long size);
>>>>    extern void free_bootmem(unsigned long physaddr, unsigned long size);
>>>>    extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
>>>> +extern void __free_pages_bootmem(struct page *page, unsigned int order);
>>>>
>>>>    /*
>>>>     * Flags for reserve_bootmem (also if CONFIG_HAVE_ARCH_BOOTMEM_NODE,
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
