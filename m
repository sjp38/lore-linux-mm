Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 46ED96B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:26:16 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so2754233pbc.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 00:26:15 -0800 (PST)
Message-ID: <50BDB372.50106@gmail.com>
Date: Tue, 04 Dec 2012 16:25:22 +0800
From: wujianguo <wujianguo106@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/8] mm: Initialize node memory regions during boot
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com> <20121106195241.6941.43309.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195241.6941.43309.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Srivatsa,

I got following compile waring:

WARNING: vmlinux.o(.text+0x10b320): Section mismatch in reference from the function init_zone_memory_regions() to the function .meminit.text:__absent_pages_in_range()
The function init_zone_memory_regions() references
the function __meminit __absent_pages_in_range().
This is often because init_zone_memory_regions lacks a __meminit
annotation or the annotation of __absent_pages_in_range is wrong.

WARNING: vmlinux.o(.text+0x10b457): Section mismatch in reference from the function init_node_memory_regions() to the function .meminit.text:__absent_pages_in_range()
The function init_node_memory_regions() references
the function __meminit __absent_pages_in_range().
This is often because init_node_memory_regions lacks a __meminit
annotation or the annotation of __absent_pages_in_range is wrong.

I think should add *__paginginit* to the following three functions:
init_memory_regions()
init_node_memory_regions()
init_zone_memory_regions()

Thanks,
Jianguo wu

On 2012-11-7 3:52, Srivatsa S. Bhat wrote:
> Initialize the node's memory regions structures with the information about
> the region-boundaries, at boot time.
> 
> Based-on-patch-by: Ankita Garg <gargankita@gmail.com>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
> 
>  include/linux/mm.h |    4 ++++
>  mm/page_alloc.c    |   35 +++++++++++++++++++++++++++++++++++
>  2 files changed, 39 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fa06804..19c4fb0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -657,6 +657,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>  #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
>  #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
>  
> +/* Hard-code memory regions size to be 512 MB for now. */
> +#define MEM_REGION_SHIFT	(29 - PAGE_SHIFT)
> +#define MEM_REGION_SIZE		(1UL << MEM_REGION_SHIFT)
> +
>  static inline enum zone_type page_zonenum(const struct page *page)
>  {
>  	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bb90971..709e3c1 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4560,6 +4560,40 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>  #endif /* CONFIG_FLAT_NODE_MEM_MAP */
>  }
>  
> +void init_node_memory_regions(struct pglist_data *pgdat)
> +{
> +	int nid = pgdat->node_id;
> +	unsigned long start_pfn = pgdat->node_start_pfn;
> +	unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
> +	unsigned long i, absent;
> +	int idx;
> +	struct node_mem_region *region;
> +
> +	for (i = start_pfn, idx = 0; i < end_pfn;
> +				i += region->spanned_pages, idx++) {
> +
> +		region = &pgdat->node_regions[idx];
> +
> +		if (i + MEM_REGION_SIZE <= end_pfn) {
> +			region->start_pfn = i;
> +			region->spanned_pages = MEM_REGION_SIZE;
> +		} else {
> +			region->start_pfn = i;
> +			region->spanned_pages = end_pfn - i;
> +		}
> +
> +		absent = __absent_pages_in_range(nid, region->start_pfn,
> +						 region->start_pfn +
> +						 region->spanned_pages);
> +
> +		region->present_pages = region->spanned_pages - absent;
> +		region->idx = idx;
> +		region->node = nid;
> +		region->pgdat = pgdat;
> +		pgdat->nr_node_regions++;
> +	}
> +}
> +
>  void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  		unsigned long node_start_pfn, unsigned long *zholes_size)
>  {
> @@ -4581,6 +4615,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>  #endif
>  
>  	free_area_init_core(pgdat, zones_size, zholes_size);
> +	init_node_memory_regions(pgdat);
>  }
>  
>  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
