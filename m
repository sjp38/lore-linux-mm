Date: Tue, 09 Aug 2005 08:05:34 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
Message-ID: <537100000.1123599933@[10.10.2.4]>
In-Reply-To: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: linux-ia64@vger.kernel.org, Mike Kravetz <kravetz@us.ibm.com>, "Luck, Tony" <tony.luck@intel.com>
List-ID: <linux-mm.kvack.org>

This rev looks much better to me, at least. Thanks for fixing it up.

M.

> I modified the patch which guarantees allocation of DMA area
> at alloc_bootmem_low().
> 
> I tested this patch. Please apply.
> 
> The differences from previous one are ....
>   - Confirmation that allocated area is really DMA area.
>   - max_dma_physaddr() is defined for some architecture that
>     all of memory is DMA area.
> 
>     (Note: Mike Kravez-san's code was defined by MACRO like this.
>         #ifndef MAX_DMA_PHYSADDR
>         #if MAX_DMA_ADDRESS == ~0UL
>                 :
>                 :
>       However, MAX_DMA_ADDRESS is defined with cast "(unsigned long)"
>       in some architecture like i386. And, preprocessor doesn't like 
>       this cast in #IF sentence and displays error message as
>       "missing binary operator befor token "long"".
>       So, I changed it to static inline function.)
> 
> Thanks.
> 
> ----------------------
> 
> This is a patch to guarantee that alloc_bootmem_low() allocate DMA area.
> 
> Current alloc_bootmem_low() is just specify "goal=0". And it is 
> used for __alloc_bootmem_core() to decide which address is better.
> However, there is no guarantee that __alloc_bootmem_core()
> allocate DMA area when goal=0 is specified.
> Even if there is no DMA'ble area in searching node, it allocates
> higher address than MAX_DMA_ADDRESS.
> 
> __alloc_bootmem_core() is called by order of for_each_pgdat()
> in __alloc_bootmem(). So, if first node (node_id = 0) has
> DMA'ble area, no trouble will occur. However, our new Itanium2 server
> can change which node has lower address. And panic really occurred on it.
> The message was "bounce buffer is not DMA'ble" in swiothl_map_single().
> 
> To avoid this panic, following patch confirms allocated area, and retry
> if it is not in DMA.
> I tested this patch on my Tiger 4 and our new server.
> 
> 
> Signed-off by Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> -------------------------------------------------------------------
> Index: bootmem/mm/bootmem.c
> ===================================================================
> --- bootmem.orig/mm/bootmem.c	2005-08-09 15:50:06.000000000 +0900
> +++ bootmem/mm/bootmem.c	2005-08-09 16:11:57.076880203 +0900
> @@ -374,10 +374,25 @@ void * __init __alloc_bootmem (unsigned 
>  	pg_data_t *pgdat = pgdat_list;
>  	void *ptr;
>  
> -	for_each_pgdat(pgdat)
> -		if ((ptr = __alloc_bootmem_core(pgdat->bdata, size,
> -						align, goal)))
> -			return(ptr);
> +	for_each_pgdat(pgdat){
> +
> +		ptr = __alloc_bootmem_core(pgdat->bdata, size,
> +					   align, goal);
> +
> +		if (!ptr)
> +			continue;
> +
> +		if (goal < max_dma_physaddr() &&
> +		    (unsigned long)ptr >= MAX_DMA_ADDRESS){
> +			/* DMA area is required, but ptr is not DMA area.
> +			   Trying other nodes */
> +
> +			free_bootmem_core(pgdat->bdata, virt_to_phys(ptr), size);
> +			continue;
> +		}
> +
> +		return(ptr);
> +
> +	}
>  
>  	/*
>  	 * Whoops, we cannot satisfy the allocation request.
> Index: bootmem/include/linux/bootmem.h
> ===================================================================
> --- bootmem.orig/include/linux/bootmem.h	2005-08-09 15:50:06.000000000 +0900
> +++ bootmem/include/linux/bootmem.h	2005-08-09 16:05:17.929424155 +0900
> @@ -36,6 +36,15 @@ typedef struct bootmem_data {
>  					 * up searching */
>  } bootmem_data_t;
>  
> +static inline unsigned long max_dma_physaddr(void)
> +{
> +
> +	if (MAX_DMA_ADDRESS == ~0UL)
> +		return MAX_DMA_ADDRESS;
> +	else
> +		return __pa(MAX_DMA_ADDRESS);
> +}
> +
>  extern unsigned long __init bootmem_bootmap_pages (unsigned long);
>  extern unsigned long __init init_bootmem (unsigned long addr, unsigned long memend);
>  extern void __init free_bootmem (unsigned long addr, unsigned long size);
> @@ -43,11 +52,11 @@ extern void * __init __alloc_bootmem (un
>  #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
>  extern void __init reserve_bootmem (unsigned long addr, unsigned long size);
>  #define alloc_bootmem(x) \
> -	__alloc_bootmem((x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
> +	__alloc_bootmem((x), SMP_CACHE_BYTES, max_dma_physaddr())
>  #define alloc_bootmem_low(x) \
>  	__alloc_bootmem((x), SMP_CACHE_BYTES, 0)
>  #define alloc_bootmem_pages(x) \
> -	__alloc_bootmem((x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
> +	__alloc_bootmem((x), PAGE_SIZE, max_dma_physaddr())
>  #define alloc_bootmem_low_pages(x) \
>  	__alloc_bootmem((x), PAGE_SIZE, 0)
>  #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
> @@ -60,9 +69,9 @@ extern unsigned long __init free_all_boo
>  extern void * __init __alloc_bootmem_node (pg_data_t *pgdat, unsigned long size, unsigned long align, unsigned long goal);
>  #ifndef CONFIG_HAVE_ARCH_BOOTMEM_NODE
>  #define alloc_bootmem_node(pgdat, x) \
> -	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, __pa(MAX_DMA_ADDRESS))
> +	__alloc_bootmem_node((pgdat), (x), SMP_CACHE_BYTES, max_dma_physaddr())
>  #define alloc_bootmem_pages_node(pgdat, x) \
> -	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, __pa(MAX_DMA_ADDRESS))
> +	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, max_dma_physaddr())
>  #define alloc_bootmem_low_pages_node(pgdat, x) \
>  	__alloc_bootmem_node((pgdat), (x), PAGE_SIZE, 0)
>  #endif /* !CONFIG_HAVE_ARCH_BOOTMEM_NODE */
> 
> -- 
> Yasunori Goto 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
