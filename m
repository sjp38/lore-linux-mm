Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 839676B00A1
	for <linux-mm@kvack.org>; Wed, 29 May 2013 04:42:18 -0400 (EDT)
Message-ID: <51A5BF3A.2070108@synopsys.com>
Date: Wed, 29 May 2013 14:11:30 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5, part4 12/41] mm/ARC: prepare for removing num_physpages
 and simplify mem_init()
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com> <1368028298-7401-13-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368028298-7401-13-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, James Hogan <james.hogan@imgtec.com>, Rob
 Herring <rob.herring@calxeda.com>

Hi Jiang,

On 05/08/2013 09:21 PM, Jiang Liu wrote:
> Prepare for removing num_physpages and simplify mem_init().
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Vineet Gupta <vgupta@synopsys.com>
> Cc: James Hogan <james.hogan@imgtec.com>
> Cc: Rob Herring <rob.herring@calxeda.com>
> Cc: linux-kernel@vger.kernel.org
> ---
>  arch/arc/mm/init.c |   36 +++---------------------------------
>  1 file changed, 3 insertions(+), 33 deletions(-)
> 
> diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
> index 78d8c31..8ba6562 100644
> --- a/arch/arc/mm/init.c
> +++ b/arch/arc/mm/init.c
> @@ -74,7 +74,7 @@ void __init setup_arch_memory(void)
>  	/* Last usable page of low mem (no HIGHMEM yet for ARC port) */
>  	max_low_pfn = max_pfn = PFN_DOWN(end_mem);
>  
> -	max_mapnr = num_physpages = max_low_pfn - min_low_pfn;
> +	max_mapnr = max_low_pfn - min_low_pfn;
>  
>  	/*------------- reserve kernel image -----------------------*/
>  	memblock_reserve(CONFIG_LINUX_LINK_BASE,
> @@ -84,7 +84,7 @@ void __init setup_arch_memory(void)
>  
>  	/*-------------- node setup --------------------------------*/
>  	memset(zones_size, 0, sizeof(zones_size));
> -	zones_size[ZONE_NORMAL] = num_physpages;
> +	zones_size[ZONE_NORMAL] = max_low_pfn - min_low_pfn;
>  
>  	/*
>  	 * We can't use the helper free_area_init(zones[]) because it uses
> @@ -106,39 +106,9 @@ void __init setup_arch_memory(void)
>   */
>  void __init mem_init(void)
>  {
> -	int codesize, datasize, initsize, reserved_pages, free_pages;
> -	int tmp;
> -
>  	high_memory = (void *)(CONFIG_LINUX_LINK_BASE + arc_mem_sz);
> -
>  	free_all_bootmem();
> -

What baseline is this code against, since mainline looks like following:

       high_memory = (void *)(CONFIG_LINUX_LINK_BASE + arc_mem_sz);

       totalram_pages = free_all_bootmem();

So I would have expected the following

-       totalram_pages = free_all_bootmem();
+	free_all_bootmem();

Aha, you missed out CCing all maintainers on "[PATCH v7, part3 14/16]" or rather
"[PATCH v8, part3 13/14]" - and it is difficult to dig this out from all the
patches that fly by on linux-arch.

Same goes for "[PATCH v8, part3 01/14]" and "[PATCH v8, part3 02/14]"

> -	/* count all reserved pages [kernel code/data/mem_map..] */
> -	reserved_pages = 0;
> -	for (tmp = 0; tmp < max_mapnr; tmp++)
> -		if (PageReserved(mem_map + tmp))
> -			reserved_pages++;
> -
> -	/* XXX: nr_free_pages() is equivalent */
> -	free_pages = max_mapnr - reserved_pages;
> -
> -	/*
> -	 * For the purpose of display below, split the "reserve mem"
> -	 * kernel code/data is already shown explicitly,
> -	 * Show any other reservations (mem_map[ ] et al)
> -	 */
> -	reserved_pages -= (((unsigned int)_end - CONFIG_LINUX_LINK_BASE) >>
> -								PAGE_SHIFT);
> -
> -	codesize = _etext - _text;
> -	datasize = _end - _etext;
> -	initsize = __init_end - __init_begin;
> -
> -	pr_info("Memory Available: %dM / %ldM (%dK code, %dK data, %dK init, %dK reserv)\n",
> -		PAGES_TO_MB(free_pages),
> -		TO_MB(arc_mem_sz),
> -		TO_KB(codesize), TO_KB(datasize), TO_KB(initsize),
> -		PAGES_TO_KB(reserved_pages));
> +	mem_init_print_info(NULL);
>  }
>  
>  /*
> 

The Changes look OK though. I managed to build your github tree (mem_init_v5
branch). And it seems to work ok.

Acked-by: Vineet Gupta <vgupta@synopsys.com>   # for arch/arc

Thx
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
