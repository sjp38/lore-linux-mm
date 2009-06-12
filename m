Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DA4236B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 01:58:33 -0400 (EDT)
Message-ID: <4A31EF4E.5030204@cn.fujitsu.com>
Date: Fri, 12 Jun 2009 14:01:50 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH] memcg: fix page_cgroup fatal error in FLATMEM
 (Was Re: boot panic with memcg enabled
References: <Pine.LNX.4.64.0906110820170.2258@melkki.cs.Helsinki.FI>	<4A31C258.2050404@cn.fujitsu.com>	<20090612115501.df12a457.kamezawa.hiroyu@jp.fujitsu.com>	<20090612124408.721ba2ae.kamezawa.hiroyu@jp.fujitsu.com>	<4A31D326.3030206@cn.fujitsu.com> <20090612143429.76ef2357.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090612143429.76ef2357.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, mingo@elte.hu, hannes@cmpxchg.org, torvalds@linux-foundation.org, yinghai@kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 12 Jun 2009 12:01:42 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> alloc_bootmem() is not gone, but slab allocator is setup much earlier now.
>> See this commit:
>>
>> commit 83b519e8b9572c319c8e0c615ee5dd7272856090
>> Author: Pekka Enberg <penberg@cs.helsinki.fi>
>> Date:   Wed Jun 10 19:40:04 2009 +0300
>>
>>     slab: setup allocators earlier in the boot sequence
>>
>> now page_cgroup_init() is called after mem_init().
> 
> Ok, Li-san, could you test this on !SPARSEMEM config ?
> 

Yeah, the patch works. :)

Tested-by: Li Zefan <lizf@cn.fujitsu.com>

Some comments below.

> x86-64 doesn't allow memory models other than SPARSEMEM.
> This works well on SPARSEMEM.
> 
> I think FLATMEM should go away in future....but maybe never ;(
> 
> Thanks,
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, SLAB is configured in very early stage and it can be used in
> init routine now.
> 
> But replacing alloc_bootmem() in FLAT/DISCONTIGMEM's page_cgroup()
> initialization breaks the allocation, now.
> (Works well in SPARSEMEM case...it supports MEMORY_HOTPLUG and
>  Size of page_cgroup is in reasonable size (< 1 << MAX_ORDER.)
> 
> This patch revive FLATMEM+memory cgroup by using alloc_bootmem.
> 
> In future,
> We stop to support FLATMEM (if no users) or rewrite codes for flatmem
> completely. But this will adds more messy codes and (big) overheads.
> 
> Reported-by: Li Zefan <lizf@cn.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> Index: linux-2.6.30.org/init/main.c
> ===================================================================
> --- linux-2.6.30.org.orig/init/main.c
> +++ linux-2.6.30.org/init/main.c
> @@ -539,6 +539,11 @@ void __init __weak thread_info_cache_ini
>   */
>  static void __init mm_init(void)
>  {
> +	/*
> + 	 * page_cgroup requires countinous pages as memmap
> + 	 * and it's bigger than MAX_ORDER unless SPARSEMEM.

checkpatch.pl complains:

ERROR: code indent should use tabs where possible
#107: FILE: init/main.c:543:
+ ^I * page_cgroup requires countinous pages as memmap$

ERROR: code indent should use tabs where possible
#108: FILE: init/main.c:544:
+ ^I * and it's bigger than MAX_ORDER unless SPARSEMEM.$

> +	 */
> +	page_cgroup_init_flatmem();
>  	mem_init();
>  	kmem_cache_init();
>  	vmalloc_init();
> Index: linux-2.6.30.org/mm/page_cgroup.c
> ===================================================================
> --- linux-2.6.30.org.orig/mm/page_cgroup.c
> +++ linux-2.6.30.org/mm/page_cgroup.c
> @@ -47,8 +47,6 @@ static int __init alloc_node_page_cgroup
>  	struct page_cgroup *base, *pc;
>  	unsigned long table_size;
>  	unsigned long start_pfn, nr_pages, index;
> -	struct page *page;
> -	unsigned int order;
>  
>  	start_pfn = NODE_DATA(nid)->node_start_pfn;
>  	nr_pages = NODE_DATA(nid)->node_spanned_pages;
> @@ -57,13 +55,11 @@ static int __init alloc_node_page_cgroup
>  		return 0;
>  
>  	table_size = sizeof(struct page_cgroup) * nr_pages;
> -	order = get_order(table_size);
> -	page = alloc_pages_node(nid, GFP_NOWAIT | __GFP_ZERO, order);
> -	if (!page)
> -		page = alloc_pages_node(-1, GFP_NOWAIT | __GFP_ZERO, order);
> -	if (!page)
> +
> +	base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
> +			table_size, PAG_SIZE, __pa(MAX_DMA_ADDRESS));

s/PAG_SIZE/PAGE_SIZE

> +	if (!base)
>  		return -ENOMEM;
> -	base = page_address(page);
>  	for (index = 0; index < nr_pages; index++) {
>  		pc = base + index;
>  		__init_page_cgroup(pc, start_pfn + index);
> @@ -73,7 +69,7 @@ static int __init alloc_node_page_cgroup
>  	return 0;
>  }
>  
> -void __init page_cgroup_init(void)
> +void __init page_cgroup_init_flatmem(void)
>  {
>  
>  	int nid, fail;
> @@ -117,16 +113,11 @@ static int __init_refok init_section_pag
>  	if (!section->page_cgroup) {
>  		nid = page_to_nid(pfn_to_page(pfn));
>  		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> -		if (slab_is_available()) {
> -			base = kmalloc_node(table_size,
> -					GFP_KERNEL | __GFP_NOWARN, nid);
> -			if (!base)
> -				base = vmalloc_node(table_size, nid);
> -		} else {
> -			base = __alloc_bootmem_node_nopanic(NODE_DATA(nid),
> -				table_size,
> -				PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
> -		}
> +		VM_BUG_ON(!slab_is_available());
> +		base = kmalloc_node(table_size,
> +				GFP_KERNEL | __GFP_NOWARN, nid);
> +		if (!base)
> +			base = vmalloc_node(table_size, nid);
>  	} else {
>  		/*
>   		 * We don't have to allocate page_cgroup again, but
> Index: linux-2.6.30.org/include/linux/page_cgroup.h
> ===================================================================
> --- linux-2.6.30.org.orig/include/linux/page_cgroup.h
> +++ linux-2.6.30.org/include/linux/page_cgroup.h
> @@ -18,7 +18,19 @@ struct page_cgroup {
>  };
>  
>  void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat);
> -void __init page_cgroup_init(void);
> +
> +#ifdef CONFIG_SPARSEMEM
> +static inline void __init page_cgroup_init_flatmem(void)
> +{
> +}
> +extern void __init page_cgroup_init(void);
> +#else
> +void __init page_cgroup_init_flatmem(void)

tailing ';' is missing.

> +static inline void __init page_cgroup_init(void)
> +{
> +}
> +#endif
> +
>  struct page_cgroup *lookup_page_cgroup(struct page *page);
>  
>  enum {
> @@ -87,6 +99,10 @@ static inline void page_cgroup_init(void
>  {
>  }
>  
> +static inline void __init page_cgroup_init_flatmem(void)
> +{
> +}
> +
>  #endif
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
