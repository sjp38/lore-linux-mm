Date: Fri, 19 Aug 2005 11:29:32 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
In-Reply-To: <p73y86ysz5c.fsf@verdi.suse.de>
References: <20050818125236.4ffe1053.akpm@osdl.org> <p73y86ysz5c.fsf@verdi.suse.de>
Message-Id: <20050819102706.62C7.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, peterc@gelato.unsw.edu.au, linux-mm@kvack.org, mbligh@mbligh.org, linux-ia64@vger.kernel.org, kravetz@us.ibm.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

Hi, Andi-san.

> Andrew Morton <akpm@osdl.org> writes:
> > > 
> > >  To avoid this panic, following patch confirm allocated area, and retry
> > >  if it is not in DMA.
> > >  I tested this patch on my Tiger 4 and our new server.
> > 
> > It kills my x86_64 box:
> 
> 
> Funny I ran into a similar problem recently. On a multi node x86-64
> system when swiotlb is forced (normally those are AMD systems which
> use the AMD hardware IOMMU) the bootmem_alloc in swiotlb.c would
> allocate from the last node. Why? Because alloc_bootmem just
> does for_each_pgdat() and tries each node and the pgdat list
> starts with the highest node going down to the lowest.
> 
> I just changed the ordering of the pgdat list that made bootmem 
> work again.

It was another candidate for modification indeed.
But, if new node is hot-added (I'm working for it),
pgdat list should be sorted by order of memory.
I suppose it is a bit messy.
At least, I think the order of pgdat link list must not depend on 
memory address.

To hot-add a node, it is better that pgdat link list is removed.
(Hot add code will set JUST node_online_map by it.)
I posted a patch to remove this link list 3 month ago.
http://marc.theaimsgroup.com/?l=linux-mm&m=111596924629564&w=2
http://marc.theaimsgroup.com/?l=linux-mm&m=111596953711780&w=2

Thanks for your comment. 
Bye.

> 
> Index: linux/mm/bootmem.c
> ===================================================================
> --- linux.orig/mm/bootmem.c
> +++ linux/mm/bootmem.c
> @@ -61,9 +61,17 @@ static unsigned long __init init_bootmem
>  {
>  	bootmem_data_t *bdata = pgdat->bdata;
>  	unsigned long mapsize = ((end - start)+7)/8;
> +	static struct pglist_data *pgdat_last;
>  
> -	pgdat->pgdat_next = pgdat_list;
> -	pgdat_list = pgdat;
> +	pgdat->pgdat_next = NULL;
> +	/* Add new nodes last so that bootmem always starts 
> +	   searching in the first nodes, not the last ones */
> +	if (pgdat_last)
> +		pgdat_last->pgdat_next = pgdat;
> +	else {
> +		pgdat_list = pgdat; 	
> +		pgdat_last = pgdat;
> +	}
>  
>  	mapsize = ALIGN(mapsize, sizeof(long));
>  	bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
