Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 54F776B00B4
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 12:56:31 -0400 (EDT)
Date: Fri, 19 Apr 2013 17:54:29 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v4, part3 13/41] mm/ARM: prepare for removing
	num_physpages and simplify mem_init()
Message-ID: <20130419165429.GA14496@n2100.arm.linux.org.uk>
References: <1365258760-30821-1-git-send-email-jiang.liu@huawei.com> <1365258760-30821-14-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365258760-30821-14-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org

On Sat, Apr 06, 2013 at 10:32:12PM +0800, Jiang Liu wrote:
> Prepare for removing num_physpages and simplify mem_init().
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  arch/arm/mm/init.c |   47 ++---------------------------------------------
>  1 file changed, 2 insertions(+), 45 deletions(-)
> 
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index add4fcb..7a911d1 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -582,9 +582,6 @@ static void __init free_highpages(void)
>   */
>  void __init mem_init(void)
>  {
> -	unsigned long reserved_pages, free_pages;
> -	struct memblock_region *reg;
> -	int i;
>  #ifdef CONFIG_HAVE_TCM
>  	/* These pointers are filled in on TCM detection */
>  	extern u32 dtcm_end;
> @@ -605,47 +602,7 @@ void __init mem_init(void)
>  
>  	free_highpages();
>  
> -	reserved_pages = free_pages = 0;
> -
> -	for_each_bank(i, &meminfo) {
> -		struct membank *bank = &meminfo.bank[i];
> -		unsigned int pfn1, pfn2;
> -		struct page *page, *end;
> -
> -		pfn1 = bank_pfn_start(bank);
> -		pfn2 = bank_pfn_end(bank);
> -
> -		page = pfn_to_page(pfn1);
> -		end  = pfn_to_page(pfn2 - 1) + 1;
> -
> -		do {
> -			if (PageReserved(page))
> -				reserved_pages++;
> -			else if (!page_count(page))
> -				free_pages++;
> -			page++;
> -		} while (page < end);
> -	}
> -
> -	/*
> -	 * Since our memory may not be contiguous, calculate the
> -	 * real number of pages we have in this system
> -	 */
> -	printk(KERN_INFO "Memory:");
> -	num_physpages = 0;
> -	for_each_memblock(memory, reg) {
> -		unsigned long pages = memblock_region_memory_end_pfn(reg) -
> -			memblock_region_memory_base_pfn(reg);
> -		num_physpages += pages;
> -		printk(" %ldMB", pages >> (20 - PAGE_SHIFT));
> -	}
> -	printk(" = %luMB total\n", num_physpages >> (20 - PAGE_SHIFT));
> -
> -	printk(KERN_NOTICE "Memory: %luk/%luk available, %luk reserved, %luK highmem\n",
> -		nr_free_pages() << (PAGE_SHIFT-10),
> -		free_pages << (PAGE_SHIFT-10),
> -		reserved_pages << (PAGE_SHIFT-10),
> -		totalhigh_pages << (PAGE_SHIFT-10));
> +	mem_init_print_info(NULL);

I'm concerned about this.  We explicitly do not use the memblock information
when walking the memory above for the reserved/free pages because memblock
merges the various banks of memory together - and those may cross sparsemem
boundaries.  Any crossing of the sparsemem boundaries needs the struct page
pointer to be re-evaluated because it can be part of a different array of
such things.

Where's the rest of the patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
