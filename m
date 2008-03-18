Date: Tue, 18 Mar 2008 15:54:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] [8/18] Add a __alloc_bootmem_node_nopanic
Message-ID: <20080318155414.GH23866@csn.ul.ie>
References: <20080317258.659191058@firstfloor.org> <20080317015821.F18431B41E0@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080317015821.F18431B41E0@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On (17/03/08 02:58), Andi Kleen didst pronounce:
> Straight forward variant of the existing __alloc_bootmem_node, only 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> difference is that it doesn't panic on failure

Seems to be a bit of cut&paste jumbling there.

> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> ---
>  include/linux/bootmem.h |    4 ++++
>  mm/bootmem.c            |   12 ++++++++++++
>  2 files changed, 16 insertions(+)
> 
> Index: linux/mm/bootmem.c
> ===================================================================
> --- linux.orig/mm/bootmem.c
> +++ linux/mm/bootmem.c
> @@ -471,6 +471,18 @@ void * __init __alloc_bootmem_node(pg_da
>  	return __alloc_bootmem(size, align, goal);
>  }
>  
> +void * __init __alloc_bootmem_node_nopanic(pg_data_t *pgdat, unsigned long size,
> +				   unsigned long align, unsigned long goal)
> +{
> +	void *ptr;
> +
> +	ptr = __alloc_bootmem_core(pgdat->bdata, size, align, goal, 0);
> +	if (ptr)
> +		return ptr;
> +
> +	return __alloc_bootmem_nopanic(size, align, goal);
> +}

Straight-forward. Mildly irritating that there are multiple variants that
only differ by whether they panic on allocation failure or not. Probably
should be a seperate removal of duplicated code there but outside the
scope of this patch.

> +
>  #ifndef ARCH_LOW_ADDRESS_LIMIT
>  #define ARCH_LOW_ADDRESS_LIMIT	0xffffffffUL
>  #endif
> Index: linux/include/linux/bootmem.h
> ===================================================================
> --- linux.orig/include/linux/bootmem.h
> +++ linux/include/linux/bootmem.h
> @@ -90,6 +90,10 @@ extern void *__alloc_bootmem_node(pg_dat
>  				  unsigned long size,
>  				  unsigned long align,
>  				  unsigned long goal);
> +extern void *__alloc_bootmem_node_nopanic(pg_data_t *pgdat,
> +				  unsigned long size,
> +				  unsigned long align,
> +				  unsigned long goal);
>  extern unsigned long init_bootmem_node(pg_data_t *pgdat,
>  				       unsigned long freepfn,
>  				       unsigned long startpfn,
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
