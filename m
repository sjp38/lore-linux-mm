Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id E3F466B0032
	for <linux-mm@kvack.org>; Tue, 14 May 2013 20:33:11 -0400 (EDT)
Message-ID: <1368577954.31689.63.camel@pasglop>
Subject: Re: [PATCH v5, part4 31/41] mm/ppc: prepare for removing
 num_physpages and simplify mem_init()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 15 May 2013 10:32:34 +1000
In-Reply-To: <1368028298-7401-32-git-send-email-jiang.liu@huawei.com>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
	 <1368028298-7401-32-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org

On Wed, 2013-05-08 at 23:51 +0800, Jiang Liu wrote:
> Prepare for removing num_physpages and simplify mem_init().

No objection, I haven't had a chance to actually build/boot test though.

BTW. A recommended way of doing so which is pretty easy even if you
don't have access to powerpc hardware nowadays is to use
qemu-system-ppc64 with -M pseries.

You can find cross compilers for the kernel on kernel.org and you can
feed qemu with some distro installer ISO.

Cheers,
Ben.

> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  arch/powerpc/mm/mem.c |   56 +++++++++++--------------------------------------
>  1 file changed, 12 insertions(+), 44 deletions(-)
> 
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index b890245..4e24f1c 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -299,46 +299,27 @@ void __init paging_init(void)
>  
>  void __init mem_init(void)
>  {
> -#ifdef CONFIG_NEED_MULTIPLE_NODES
> -	int nid;
> -#endif
> -	pg_data_t *pgdat;
> -	unsigned long i;
> -	struct page *page;
> -	unsigned long reservedpages = 0, codesize, initsize, datasize, bsssize;
> -
>  #ifdef CONFIG_SWIOTLB
>  	swiotlb_init(0);
>  #endif
>  
> -	num_physpages = memblock_phys_mem_size() >> PAGE_SHIFT;
>  	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
>  
>  #ifdef CONFIG_NEED_MULTIPLE_NODES
> -        for_each_online_node(nid) {
> -		if (NODE_DATA(nid)->node_spanned_pages != 0) {
> -			printk("freeing bootmem node %d\n", nid);
> -			free_all_bootmem_node(NODE_DATA(nid));
> -		}
> +	{
> +		pg_data_t *pgdat;
> +
> +		for_each_online_pgdat(pgdat)
> +			if (pgdat->node_spanned_pages != 0) {
> +				printk("freeing bootmem node %d\n",
> +					pgdat->node_id);
> +				free_all_bootmem_node(pgdat);
> +			}
>  	}
>  #else
>  	max_mapnr = max_pfn;
>  	free_all_bootmem();
>  #endif
> -	for_each_online_pgdat(pgdat) {
> -		for (i = 0; i < pgdat->node_spanned_pages; i++) {
> -			if (!pfn_valid(pgdat->node_start_pfn + i))
> -				continue;
> -			page = pgdat_page_nr(pgdat, i);
> -			if (PageReserved(page))
> -				reservedpages++;
> -		}
> -	}
> -
> -	codesize = (unsigned long)&_sdata - (unsigned long)&_stext;
> -	datasize = (unsigned long)&_edata - (unsigned long)&_sdata;
> -	initsize = (unsigned long)&__init_end - (unsigned long)&__init_begin;
> -	bsssize = (unsigned long)&__bss_stop - (unsigned long)&__bss_start;
>  
>  #ifdef CONFIG_HIGHMEM
>  	{
> @@ -348,13 +329,9 @@ void __init mem_init(void)
>  		for (pfn = highmem_mapnr; pfn < max_mapnr; ++pfn) {
>  			phys_addr_t paddr = (phys_addr_t)pfn << PAGE_SHIFT;
>  			struct page *page = pfn_to_page(pfn);
> -			if (memblock_is_reserved(paddr))
> -				continue;
> -			free_highmem_page(page);
> -			reservedpages--;
> +			if (!memblock_is_reserved(paddr))
> +				free_highmem_page(page);
>  		}
> -		printk(KERN_DEBUG "High memory: %luk\n",
> -		       totalhigh_pages << (PAGE_SHIFT-10));
>  	}
>  #endif /* CONFIG_HIGHMEM */
>  
> @@ -367,16 +344,7 @@ void __init mem_init(void)
>  		(mfspr(SPRN_TLB1CFG) & TLBnCFG_N_ENTRY) - 1;
>  #endif
>  
> -	printk(KERN_INFO "Memory: %luk/%luk available (%luk kernel code, "
> -	       "%luk reserved, %luk data, %luk bss, %luk init)\n",
> -		nr_free_pages() << (PAGE_SHIFT-10),
> -		num_physpages << (PAGE_SHIFT-10),
> -		codesize >> 10,
> -		reservedpages << (PAGE_SHIFT-10),
> -		datasize >> 10,
> -		bsssize >> 10,
> -		initsize >> 10);
> -
> +	mem_init_print_info(NULL);
>  #ifdef CONFIG_PPC32
>  	pr_info("Kernel virtual memory layout:\n");
>  	pr_info("  * 0x%08lx..0x%08lx  : fixmap\n", FIXADDR_START, FIXADDR_TOP);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
