Subject: Re: [PATCH] gurantee DMA area for alloc_bootmem_low() ver. 2.
References: <20050809194115.C370.Y-GOTO@jp.fujitsu.com>
	<17145.13835.592008.577583@wombat.chubb.wattle.id.au>
	<20050810145550.740D.Y-GOTO@jp.fujitsu.com>
	<20050818125236.4ffe1053.akpm@osdl.org>
From: Andi Kleen <ak@suse.de>
Date: 18 Aug 2005 23:39:27 +0200
In-Reply-To: <20050818125236.4ffe1053.akpm@osdl.org>
Message-ID: <p73y86ysz5c.fsf@verdi.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: peterc@gelato.unsw.edu.au, linux-mm@kvack.org, mbligh@mbligh.org, linux-ia64@vger.kernel.org, kravetz@us.ibm.com, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> writes:
> > 
> >  To avoid this panic, following patch confirm allocated area, and retry
> >  if it is not in DMA.
> >  I tested this patch on my Tiger 4 and our new server.
> 
> It kills my x86_64 box:


Funny I ran into a similar problem recently. On a multi node x86-64
system when swiotlb is forced (normally those are AMD systems which
use the AMD hardware IOMMU) the bootmem_alloc in swiotlb.c would
allocate from the last node. Why? Because alloc_bootmem just
does for_each_pgdat() and tries each node and the pgdat list
starts with the highest node going down to the lowest.

I just changed the ordering of the pgdat list that made bootmem 
work again.

-Andi

Index: linux/mm/bootmem.c
===================================================================
--- linux.orig/mm/bootmem.c
+++ linux/mm/bootmem.c
@@ -61,9 +61,17 @@ static unsigned long __init init_bootmem
 {
 	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long mapsize = ((end - start)+7)/8;
+	static struct pglist_data *pgdat_last;
 
-	pgdat->pgdat_next = pgdat_list;
-	pgdat_list = pgdat;
+	pgdat->pgdat_next = NULL;
+	/* Add new nodes last so that bootmem always starts 
+	   searching in the first nodes, not the last ones */
+	if (pgdat_last)
+		pgdat_last->pgdat_next = pgdat;
+	else {
+		pgdat_list = pgdat; 	
+		pgdat_last = pgdat;
+	}
 
 	mapsize = ALIGN(mapsize, sizeof(long));
 	bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
