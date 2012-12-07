Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4EB0A6B0068
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 20:43:15 -0500 (EST)
Message-ID: <50C14976.2050606@cn.fujitsu.com>
Date: Fri, 07 Dec 2012 09:42:14 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch v4 08/12] memory-hotplug: remove memmap of sparse-vmemmap
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <1354010422-19648-9-git-send-email-wency@cn.fujitsu.com> <50B5DC00.20103@huawei.com> <50B80FB1.6040906@cn.fujitsu.com> <50BC0D2D.8040008@huawei.com>
In-Reply-To: <50BC0D2D.8040008@huawei.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Hi Wu,

I met some problems when I was digging into the code. It's very
kind of you if you could help me with that. :)

If I misunderstood your code, please tell me.
Please see below. :)

On 12/03/2012 10:23 AM, Jianguo Wu wrote:
> Signed-off-by: Jianguo Wu<wujianguo@huawei.com>
> Signed-off-by: Jiang Liu<jiang.liu@huawei.com>
> ---
>   include/linux/mm.h  |    1 +
>   mm/sparse-vmemmap.c |  231 +++++++++++++++++++++++++++++++++++++++++++++++++++
>   mm/sparse.c         |    3 +-
>   3 files changed, 234 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5657670..1f26af5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1642,6 +1642,7 @@ int vmemmap_populate(struct page *start_page, unsigned long pages, int node);
>   void vmemmap_populate_print_last(void);
>   void register_page_bootmem_memmap(unsigned long section_nr, struct page *map,
>   				  unsigned long size);
> +void vmemmap_free(struct page *memmap, unsigned long nr_pages);
>
>   enum mf_flags {
>   	MF_COUNT_INCREASED = 1<<  0,
> diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
> index 1b7e22a..748732d 100644
> --- a/mm/sparse-vmemmap.c
> +++ b/mm/sparse-vmemmap.c
> @@ -29,6 +29,10 @@
>   #include<asm/pgalloc.h>
>   #include<asm/pgtable.h>
>
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +#include<asm/tlbflush.h>
> +#endif
> +
>   /*
>    * Allocate a block of memory to be used to back the virtual memory map
>    * or to back the page tables that are used to create the mapping.
> @@ -224,3 +228,230 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
>   		vmemmap_buf_end = NULL;
>   	}
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +
> +#define PAGE_INUSE 0xFD
> +
> +static void vmemmap_free_pages(struct page *page, int order)
> +{
> +	struct zone *zone;
> +	unsigned long magic;
> +
> +	magic = (unsigned long) page->lru.next;
> +	if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
> +		put_page_bootmem(page);
> +
> +		zone = page_zone(page);
> +		zone_span_writelock(zone);
> +		zone->present_pages++;
> +		zone_span_writeunlock(zone);
> +		totalram_pages++;
> +	} else
> +		free_pages((unsigned long)page_address(page), order);

Here, I think SECTION_INFO and MIX_SECTION_INFO pages are all allocated
by bootmem, so I put this function this way.

I'm not sure if parameter order is necessary here. It will always be 0
in your code. Is this OK to you ?

static void free_pagetable(struct page *page)
{
         struct zone *zone;
         bool bootmem = false;
         unsigned long magic;

         /* bootmem page has reserved flag */
         if (PageReserved(page)) {
                 __ClearPageReserved(page);
                 bootmem = true;
         }

         magic = (unsigned long) page->lru.next;
         if (magic == SECTION_INFO || magic == MIX_SECTION_INFO)
                 put_page_bootmem(page);
         else
                 __free_page(page);

         /*
          * SECTION_INFO pages and MIX_SECTION_INFO pages
          * are all allocated by bootmem.
          */
         if (bootmem) {
                 zone = page_zone(page);
                 zone_span_writelock(zone);
                 zone->present_pages++;
                 zone_span_writeunlock(zone);
                 totalram_pages++;
         }
}

(snip)

> +
> +static void vmemmap_pte_remove(pmd_t *pmd, unsigned long addr, unsigned long end)
> +{
> +	pte_t *pte;
> +	unsigned long next;
> +	void *page_addr;
> +
> +	pte = pte_offset_kernel(pmd, addr);
> +	for (; addr<  end; pte++, addr += PAGE_SIZE) {
> +		next = (addr + PAGE_SIZE)&  PAGE_MASK;
> +		if (next>  end)
> +			next = end;
> +
> +		if (pte_none(*pte))

Here, you checked xxx_none() in your vmemmap_xxx_remove(), but you used
!xxx_present() in your x86_64 patches. Is it OK if I only check
!xxx_present() ?

> +			continue;
> +		if (IS_ALIGNED(addr, PAGE_SIZE)&&
> +		    IS_ALIGNED(next, PAGE_SIZE)) {
> +			vmemmap_free_pages(pte_page(*pte), 0);
> +			spin_lock(&init_mm.page_table_lock);
> +			pte_clear(&init_mm, addr, pte);
> +			spin_unlock(&init_mm.page_table_lock);
> +		} else {
> +			/*
> +			 * Removed page structs are filled with 0xFD.
> +			 */
> +			memset((void *)addr, PAGE_INUSE, next - addr);
> +			page_addr = page_address(pte_page(*pte));
> +
> +			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
> +				spin_lock(&init_mm.page_table_lock);
> +				pte_clear(&init_mm, addr, pte);
> +				spin_unlock(&init_mm.page_table_lock);

Here, since we clear pte, we should also free the page, right ?

> +			}
> +		}
> +	}
> +
> +	free_pte_table(pmd);
> +	__flush_tlb_all();
> +}
> +
> +static void vmemmap_pmd_remove(pud_t *pud, unsigned long addr, unsigned long end)
> +{
> +	unsigned long next;
> +	pmd_t *pmd;
> +
> +	pmd = pmd_offset(pud, addr);
> +	for (; addr<  end; addr = next, pmd++) {
> +		next = (addr, end);

And by the way, there isn't pte_addr_end() in kernel, why ?
I saw you calculated it like this:

                 next = (addr + PAGE_SIZE) & PAGE_MASK;
                 if (next > end)
                         next = end;

This logic is very similar to {pmd|pud|pgd}_addr_end(). Shall we add a
pte_addr_end() or something ? :)
Since there is no such code in kernel for a long time, I think there
must be some reasons.

I merged free_xxx_table() and remove_xxx_table() as common interfaces.

And again, thanks for your patient and nice explanation. :)

(snip)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
