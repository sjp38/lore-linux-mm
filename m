Message-ID: <43CFD4BB.4070704@shadowen.org>
Date: Thu, 19 Jan 2006 18:04:43 +0000
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Add the pzone
References: <20060119080408.24736.13148.sendpatchset@debian> <20060119080413.24736.27946.sendpatchset@debian>
In-Reply-To: <20060119080413.24736.27946.sendpatchset@debian>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KUROSAWA Takahiro wrote:
> This patch implements the pzone (pseudo zone).  A pzone can be used
> for reserving pages in a zone.  Pzones are implemented by extending
> the zone structure and act almost the same as the conventional zones;
> we can specify pzones in a zonelist for __alloc_pages() and the vmscan
> code works on pzones with few modifications.
> 
> Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
[...]
> -/* Page flags: | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
> -#define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
> +/* Page flags: | [PZONE] | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
> +#define PZONE_BIT_PGOFF		((sizeof(unsigned long)*8) - PZONE_BIT_WIDTH)
> +#define SECTIONS_PGOFF		(PZONE_BIT_PGOFF - SECTIONS_WIDTH)
>  #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
>  #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)

In general this PZONE bit is really a part of the zone number.  Much of
the order of these bits is chosen to obtain the cheapest extraction of
the most used bits, particularly the node/zone conbination or section
number on the left.  I would say put the PZONE_BIT next to ZONE
probabally to the right of it?  [See below for more reasons to put it
there.]

> @@ -431,6 +438,7 @@ void put_page(struct page *page);
>   * sections we define the shift as 0; that plus a 0 mask ensures
>   * the compiler will optimise away reference to them.
>   */
> +#define PZONE_BIT_PGSHIFT	(PZONE_BIT_PGOFF * (PZONE_BIT_WIDTH != 0))
>  #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
>  #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
>  #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
> @@ -443,10 +451,11 @@ void put_page(struct page *page);
>  #endif
>  #define ZONETABLE_PGSHIFT	ZONES_PGSHIFT
>  
> -#if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> -#error SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> +#if PZONE_BIT_WIDTH+SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
> +#error PZONE_BIT_WIDTH+SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH > FLAGS_RESERVED
>  #endif

Do we have any bits left in the reserve on 32 bit machines?  The reserve
at last look was only 8 bits and there was little if any headroom in the
rest of the flags word to extend it; if memory serves at least 22 of the
24 remaining bits was accounted for.  Has this been tested on any such
machines?

> +#define PZONE_BIT_MASK		((1UL << PZONE_BIT_WIDTH) - 1)
>  #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
>  #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
>  #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
[...]
> +#ifdef CONFIG_PSEUDO_ZONE
> +static inline int page_in_pzone(struct page *page)
> +{
> +	return (page->flags >> PZONE_BIT_PGSHIFT) & PZONE_BIT_MASK;
> +}
> +
> +static inline struct zone *page_zone(struct page *page)
> +{
> +	int idx;
> +
> +	idx = (page->flags >> ZONETABLE_PGSHIFT) & ZONETABLE_MASK;
> +	if (page_in_pzone(page))
> +		return pzone_table[idx].zone;
> +	return zone_table[idx];
> +}

Could we not do this all without changing the structure of the zone
table at all by placing the PZONE_BIT either to the left or right of the
ZONE in the flags.  Then ZONETABLE_MASK could be extended to cover it
when pzone's are enabled and the pzone's could be added to zone_table
instead of their own pzone_table?  This would mean the code above could
be unmodified and much simpler.

> +
> +static inline unsigned long page_to_nid(struct page *page)
> +{
> +	return page_zone(page)->zone_pgdat->node_id;
> +}
[...]
> +#ifdef CONFIG_PSEUDO_ZONE
> +#define MAX_NR_PZONES		1024

You seem to be allowing for 1024 pzone's here?  But in
pzone_setup_page_flags() you place the pzone_idx (an offset into the
pzone_table) into the ZONE field of the page flags.  This field is
typically only two bits wide?  I don't see this being increased in this
patch, nor is there space for it generally to get much bigger not on 32
bit kernels anyhow (see comments about bits earlier)?

#define ZONES_SHIFT             2       /* ceil(log2(MAX_NR_ZONES)) */

Cheers.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
