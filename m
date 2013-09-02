Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B1BD36B0031
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 02:21:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6975D3EE0AE
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 15:21:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 57D4E2AEA84
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 15:21:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3412C1EF081
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 15:21:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 26ADB1DB803A
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 15:21:37 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C43ABE08005
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 15:21:36 +0900 (JST)
Message-ID: <52242E1D.4020406@jp.fujitsu.com>
Date: Mon, 2 Sep 2013 15:20:13 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 04/35] mm: Initialize node memory regions during
 boot
References: <20130830131221.4947.99764.stgit@srivatsabhat.in.ibm.com> <20130830131504.4947.86008.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130830131504.4947.86008.stgit@srivatsabhat.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, dave@sr71.net, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2013/08/30 22:15), Srivatsa S. Bhat wrote:
> Initialize the node's memory-regions structures with the information about
> the region-boundaries, at boot time.
>
> Based-on-patch-by: Ankita Garg <gargankita@gmail.com>
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
>
>   include/linux/mm.h |    4 ++++
>   mm/page_alloc.c    |   28 ++++++++++++++++++++++++++++
>   2 files changed, 32 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index f022460..18fdec4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -627,6 +627,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>   #define LAST_NID_MASK		((1UL << LAST_NID_WIDTH) - 1)
>   #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
>
> +/* Hard-code memory region size to be 512 MB for now. */
> +#define MEM_REGION_SHIFT	(29 - PAGE_SHIFT)
> +#define MEM_REGION_SIZE		(1UL << MEM_REGION_SHIFT)
> +
>   static inline enum zone_type page_zonenum(const struct page *page)
>   {
>   	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b86d7e3..bb2d5d4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4809,6 +4809,33 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
>   #endif /* CONFIG_FLAT_NODE_MEM_MAP */
>   }
>
> +static void __meminit init_node_memory_regions(struct pglist_data *pgdat)
> +{
> +	int nid = pgdat->node_id;
> +	unsigned long start_pfn = pgdat->node_start_pfn;
> +	unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
> +	struct node_mem_region *region;
> +	unsigned long i, absent;
> +	int idx;
> +
> +	for (i = start_pfn, idx = 0; i < end_pfn;
> +				i += region->spanned_pages, idx++) {
> +

> +		region = &pgdat->node_regions[idx];

It seems that overflow easily occurs.
node_regions[] has 256 entries and MEM_REGION_SIZE is 512MiB. So if
the pgdat has more than 128 GiB, overflow will occur. Am I wrong?

Thanks,
Yasuaki Ishimatsu

> +		region->pgdat = pgdat;
> +		region->start_pfn = i;
> +		region->spanned_pages = min(MEM_REGION_SIZE, end_pfn - i);
> +		region->end_pfn = region->start_pfn + region->spanned_pages;
> +
> +		absent = __absent_pages_in_range(nid, region->start_pfn,
> +						 region->end_pfn);
> +
> +		region->present_pages = region->spanned_pages - absent;
> +	}
> +
> +	pgdat->nr_node_regions = idx;
> +}
> +
>   void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>   		unsigned long node_start_pfn, unsigned long *zholes_size)
>   {
> @@ -4837,6 +4864,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
>
>   	free_area_init_core(pgdat, start_pfn, end_pfn,
>   			    zones_size, zholes_size);
> +	init_node_memory_regions(pgdat);
>   }
>
>   #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
