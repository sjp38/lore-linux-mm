Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4DA0B6B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 07:22:38 -0500 (EST)
Message-ID: <50BDEA82.4050809@huawei.com>
Date: Tue, 4 Dec 2012 20:20:18 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [Patch v4 08/12] memory-hotplug: remove memmap of sparse-vmemmap
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <1354010422-19648-9-git-send-email-wency@cn.fujitsu.com> <50B5DC00.20103@huawei.com> <50B80FB1.6040906@cn.fujitsu.com> <50BC0D2D.8040008@huawei.com> <50BDBEB7.3070807@cn.fujitsu.com>
In-Reply-To: <50BDBEB7.3070807@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Hi Tang,

Thanks for your review and comments, Please see below for my reply.

On 2012/12/4 17:13, Tang Chen wrote:

> Hi Wu,
> 
> Sorry to make noise here. Please see below. :)
> 
> On 12/03/2012 10:23 AM, Jianguo Wu wrote:
>> Signed-off-by: Jianguo Wu<wujianguo@huawei.com>
>> Signed-off-by: Jiang Liu<jiang.liu@huawei.com>
>> ---
>>   include/linux/mm.h  |    1 +
>>   mm/sparse-vmemmap.c |  231 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>   mm/sparse.c         |    3 +-
>>   3 files changed, 234 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 5657670..1f26af5 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1642,6 +1642,7 @@ int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
>>   void vmemmap_populate_print_last(void);
>>   void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
>>                     unsigned long size);
>> +void vmemmap_free(struct page *memmap, unsigned long nr_pages);
>>
>>   enum mf_flags {
>>       MF_COUNT_INCREASED = 1<<  0,
>> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
>> index 1b7e22a..748732d 100644
>> --- a/mm/sparse-vmemmap.c
>> +++ b/mm/sparse-vmemmap.c
>> @@ -29,6 +29,10 @@
>>   #include<asm/pgalloc.h>
>>   #include<asm/pgtable.h>
>>
>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>> +#include<asm/tlbflush.h>
>> +#endif
>> +
>>   /*
>>    * Allocate a block of memory to be used to back the virtual memory map
>>    * or to back the page tables that are used to create the mapping.
>> @@ -224,3 +228,230 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>>           vmemmap_buf_end = NULL;
>>       }
>>   }
>> +
>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>> +
>> +#define PAGE_INUSE 0xFD
>> +
>> +static void vmemmap_free_pages(struct page *page, int order)
>> +{
>> +    struct zone *zone;
>> +    unsigned long magic;
>> +
>> +    magic = (unsigned long) page->lru.next;
>> +    if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
>> +        put_page_bootmem(page);
>> +
>> +        zone = page_zone(page);
>> +        zone_span_writelock(zone);
>> +        zone->present_pages++;
>> +        zone_span_writeunlock(zone);
>> +        totalram_pages++;
> 
> Seems that we have different ways to handle pages allocated by bootmem
> or by regular allocator. Is the checking way in [PATCH 09/12] available
> here ?
> 
> +    /* bootmem page has reserved flag */
> +    if (PageReserved(page)) {
> ......
> +    }
> 
> If so, I think we can just merge these two functions.

Hmm, direct mapping table isn't allocated by bootmem allocator such as memblock, can't be free by put_page_bootmem().
But I will try to merge these two functions.

> 
>> +    } else
>> +        free_pages((unsigned long)page_address(page), order);
>> +}
>> +
>> +static void free_pte_table(pmd_t *pmd)
>> +{
>> +    pte_t *pte, *pte_start;
>> +    int i;
>> +
>> +    pte_start = (pte_t *)pmd_page_vaddr(*pmd);
>> +    for (i = 0; i<  PTRS_PER_PTE; i++) {
>> +        pte = pte_start + i;
>> +        if (pte_val(*pte))
>> +            return;
>> +    }
>> +
>> +    /* free a pte talbe */
>> +    vmemmap_free_pages(pmd_page(*pmd), 0);
>> +    spin_lock(&init_mm.page_table_lock);
>> +    pmd_clear(pmd);
>> +    spin_unlock(&init_mm.page_table_lock);
>> +}
>> +
>> +static void free_pmd_table(pud_t *pud)
>> +{
>> +    pmd_t *pmd, *pmd_start;
>> +    int i;
>> +
>> +    pmd_start = (pmd_t *)pud_page_vaddr(*pud);
>> +    for (i = 0; i<  PTRS_PER_PMD; i++) {
>> +        pmd = pmd_start + i;
>> +        if (pmd_val(*pmd))
>> +            return;
>> +    }
>> +
>> +    /* free a pmd talbe */
>> +    vmemmap_free_pages(pud_page(*pud), 0);
>> +    spin_lock(&init_mm.page_table_lock);
>> +    pud_clear(pud);
>> +    spin_unlock(&init_mm.page_table_lock);
>> +}
>> +
>> +static void free_pud_table(pgd_t *pgd)
>> +{
>> +    pud_t *pud, *pud_start;
>> +    int i;
>> +
>> +    pud_start = (pud_t *)pgd_page_vaddr(*pgd);
>> +    for (i = 0; i<  PTRS_PER_PUD; i++) {
>> +        pud = pud_start + i;
>> +        if (pud_val(*pud))
>> +            return;
>> +    }
>> +
>> +    /* free a pud table */
>> +    vmemmap_free_pages(pgd_page(*pgd), 0);
>> +    spin_lock(&init_mm.page_table_lock);
>> +    pgd_clear(pgd);
>> +    spin_unlock(&init_mm.page_table_lock);
>> +}
> 
> All the free_xxx_table() are very similar to the functions in
> [PATCH 09/12]. Could we reuse them anyway ?

yes, we can reuse them.

> 
>> +
>> +static int split_large_page(pte_t *kpte, unsigned long address, pte_t *pbase)
>> +{
>> +    struct page *page = pmd_page(*(pmd_t *)kpte);
>> +    int i = 0;
>> +    unsigned long magic;
>> +    unsigned long section_nr;
>> +
>> +    __split_large_page(kpte, address, pbase);
> 
> Is this patch going to replace [PATCH 08/12] ?
> 

I wish to replace [PATCH 08/12], but need Congyang and Yasuaki to confirm first:)

> If so, __split_large_page() was added and exported in [PATCH 09/12],
> then we should move it here, right ?

yes.

and what do you think about moving vmemmap_pud[pmd/pte]_remove() to arch/x86/mm/init_64.c,
to be consistent with vmemmap_populate() ?

I will rework [PATCH 08/12] and [PATCH 09/12] soon.

Thanks,
Jianguo Wu.

> 
> If not, free_map_bootmem() and __kfree_section_memmap() were changed in
> [PATCH 08/12], and we need to handle this.
> 
>> +    __flush_tlb_all();
>> +
>> +    magic = (unsigned long) page->lru.next;
>> +    if (magic == SECTION_INFO) {
>> +        section_nr = pfn_to_section_nr(page_to_pfn(page));
>> +        while (i<  PTRS_PER_PMD) {
>> +            page++;
>> +            i++;
>> +            get_page_bootmem(section_nr, page, SECTION_INFO);
>> +        }
>> +    }
>> +
>> +    return 0;
>> +}
>> +
>> +static void vmemmap_pte_remove(pmd_t *pmd, unsigned long addr, unsigned long end)
>> +{
>> +    pte_t *pte;
>> +    unsigned long next;
>> +    void *page_addr;
>> +
>> +    pte = pte_offset_kernel(pmd, addr);
>> +    for (; addr<  end; pte++, addr += PAGE_SIZE) {
>> +        next = (addr + PAGE_SIZE)&  PAGE_MASK;
>> +        if (next>  end)
>> +            next = end;
>> +
>> +        if (pte_none(*pte))
>> +            continue;
>> +        if (IS_ALIGNED(addr, PAGE_SIZE)&&
>> +            IS_ALIGNED(next, PAGE_SIZE)) {
>> +            vmemmap_free_pages(pte_page(*pte), 0);
>> +            spin_lock(&init_mm.page_table_lock);
>> +            pte_clear(&init_mm, addr, pte);
>> +            spin_unlock(&init_mm.page_table_lock);
>> +        } else {
>> +            /*
>> +             * Removed page structs are filled with 0xFD.
>> +             */
>> +            memset((void *)addr, PAGE_INUSE, next - addr);
>> +            page_addr = page_address(pte_page(*pte));
>> +
>> +            if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
>> +                spin_lock(&init_mm.page_table_lock);
>> +                pte_clear(&init_mm, addr, pte);
>> +                spin_unlock(&init_mm.page_table_lock);
>> +            }
>> +        }
>> +    }
>> +
>> +    free_pte_table(pmd);
>> +    __flush_tlb_all();
>> +}
>> +
>> +static void vmemmap_pmd_remove(pud_t *pud, unsigned long addr, unsigned long end)
>> +{
>> +    unsigned long next;
>> +    pmd_t *pmd;
>> +
>> +    pmd = pmd_offset(pud, addr);
>> +    for (; addr<  end; addr = next, pmd++) {
>> +        next = pmd_addr_end(addr, end);
>> +        if (pmd_none(*pmd))
>> +            continue;
>> +
>> +        if (cpu_has_pse) {
>> +            unsigned long pte_base;
>> +
>> +            if (IS_ALIGNED(addr, PMD_SIZE)&&
>> +                IS_ALIGNED(next, PMD_SIZE)) {
>> +                vmemmap_free_pages(pmd_page(*pmd),
>> +                           get_order(PMD_SIZE));
>> +                spin_lock(&init_mm.page_table_lock);
>> +                pmd_clear(pmd);
>> +                spin_unlock(&init_mm.page_table_lock);
>> +                continue;
>> +            }
>> +
>> +            /*
>> +             * We use 2M page, but we need to remove part of them,
>> +             * so split 2M page to 4K page.
>> +             */
>> +            pte_base = get_zeroed_page(GFP_ATOMIC | __GFP_NOTRACK);
>> +            if (!pte_base) {
>> +                WARN_ON(1);
>> +                continue;
>> +            }
>> +
>> +            split_large_page((pte_t *)pmd, addr, (pte_t *)pte_base);
>> +            __flush_tlb_all();
>> +
>> +            spin_lock(&init_mm.page_table_lock);
>> +            pmd_populate_kernel(&init_mm, pmd, (pte_t *)pte_base);
>> +            spin_unlock(&init_mm.page_table_lock);
>> +        }
>> +
>> +        vmemmap_pte_remove(pmd, addr, next);
>> +    }
>> +
>> +    free_pmd_table(pud);
>> +    __flush_tlb_all();
>> +}
>> +
>> +static void vmemmap_pud_remove(pgd_t *pgd, unsigned long addr, unsigned long end)
>> +{
>> +    unsigned long next;
>> +    pud_t *pud;
>> +
>> +    pud = pud_offset(pgd, addr);
>> +    for (; addr<  end; addr = next, pud++) {
>> +        next = pud_addr_end(addr, end);
>> +        if (pud_none(*pud))
>> +            continue;
>> +
>> +        vmemmap_pmd_remove(pud, addr, next);
>> +    }
>> +
>> +    free_pud_table(pgd);
>> +    __flush_tlb_all();
>> +}
>> +
>> +void vmemmap_free(struct page *memmap, unsigned long nr_pages)
>> +{
>> +    unsigned long addr = (unsigned long)memmap;
>> +    unsigned long end = (unsigned long)(memmap + nr_pages);
>> +    unsigned long next;
>> +
>> +    for (; addr<  end; addr = next) {
>> +        pgd_t *pgd = pgd_offset_k(addr);
>> +
>> +        next = pgd_addr_end(addr, end);
>> +        if (!pgd_present(*pgd))
>> +            continue;
>> +
>> +        vmemmap_pud_remove(pgd, addr, next);
>> +        sync_global_pgds(addr, next - 1);
>> +    }
>> +}
>> +#endif
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index fac95f2..4060229 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -615,10 +615,11 @@ static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
>>   }
>>   static void __kfree_section_memmap(struct page *memmap, unsigned long nr_pages)
>>   {
>> -    return; /* XXX: Not implemented yet */
>> +    vmemmap_free(memmap, nr_pages);
>>   }
>>   static void free_map_bootmem(struct page *page, unsigned long nr_pages)
> 
> In the latest kernel, this line was:
> static void free_map_bootmem(struct page *memmap, unsigned long nr_pages)
> 
>>   {
>> +    vmemmap_free(page, nr_pages);
>>   }
>>   #else
>>   static struct page *__kmalloc_section_memmap(unsigned long nr_pages)
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
