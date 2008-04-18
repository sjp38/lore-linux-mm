Date: Fri, 18 Apr 2008 12:04:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcgroup: check and initialize page->cgroup in
 memmap_init_zone
Message-Id: <20080418120456.68a663d7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48080B86.7040200@cn.fujitsu.com>
References: <48080706.50305@cn.fujitsu.com>
	<48080930.5090905@cn.fujitsu.com>
	<48080B86.7040200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shi Weihua <shiwh@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 18 Apr 2008 10:46:30 +0800
Shi Weihua <shiwh@cn.fujitsu.com> wrote:

> In this patch, the Author Hugh Dickins said 
> "...memmap_init_zone doesn't need it either, ...
> Linux assumes pointers in zeroed structures are NULL pointers."
> But it seems it's not always the case, so we should check and initialize
> page->cgroup anyways.
> 
Hmm...strange. (I never see this with 2.6.25 + Primequest) 
What memory model are you using ? CONFIG_SPRASEMEM_VMEMMAP ?


>  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>  		/*
> @@ -2535,6 +2536,9 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>  		set_page_links(page, zone, nid, pfn);
>  		init_page_count(page);
>  		reset_page_mapcount(page);
> +		pc = page_get_page_cgroup(page);
> +		if (pc) 
> +			page_reset_bad_cgroup(page);
>  		SetPageReserved(page);
>  
BTW, page_reset_page_cgroup, defined as this
==
#define page_reset_bad_cgroup(page)     ((page)->page_cgroup = 0)
==
Should be
==
#define page_reset_bad_cgroup(page)     ((page)->page_cgroup = 0UL)
==
...I'll write a patch.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
