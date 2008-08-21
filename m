Date: Thu, 21 Aug 2008 12:33:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUG] [PATCH v2] Make setup_zone_migrate_reserve() aware of overlapping nodes
Message-ID: <20080821113338.GA29950@csn.ul.ie>
References: <1218837685.12953.11.camel@localhost.localdomain> <1219252134.13885.25.camel@localhost.localdomain> <1219255911.8960.41.camel@nimitz> <1219262152.13885.27.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1219262152.13885.27.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On (20/08/08 14:55), Adam Litke didst pronounce:
>     Changes since V1
>      - Fix build for !NUMA
>      - Add VM_BUG_ON() to catch this problem at the source
>     
>     I have gotten to the root cause of the hugetlb badness I reported back on
>     August 15th.  My system has the following memory topology (note the
>     overlapping node):
>     
>             Node 0 Memory: 0x8000000-0x44000000
>             Node 1 Memory: 0x0-0x8000000 0x44000000-0x80000000
>     
>     setup_zone_migrate_reserve() scans the address range 0x0-0x8000000 looking
>     for a pageblock to move onto the MIGRATE_RESERVE list.  Finding no
>     candidates, it happily continues the scan into 0x8000000-0x44000000.  When
>     a pageblock is found, the pages are moved to the MIGRATE_RESERVE list on
>     the wrong zone.  Oops.
>     
>     (Andrew: once the proper fix is agreed upon, this should also be a
>     candidate for -stable.)
>     
>     setup_zone_migrate_reserve() should skip pageblocks in overlapping nodes.
>     
>     Signed-off-by: Adam Litke <agl@us.ibm.com>
> 

zone_to_nid(zone) is called every time in the loop even though it will never
change. This is less than optimal but setup_zone_migrate_reserve() is only
called during init and when min_free_kbytes is adjusted so it's not worth
worrying about. Otherwise it looks good.

Acked-by: Mel Gorman <mel@csn.ul.ie>

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index af982f7..feb7916 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -694,6 +694,9 @@ static int move_freepages(struct zone *zone,
>  #endif
>  
>  	for (page = start_page; page <= end_page;) {
> +		/* Make sure we are not inadvertently changing nodes */
> +		VM_BUG_ON(page_to_nid(page) != zone_to_nid(zone));
> +
>  		if (!pfn_valid_within(page_to_pfn(page))) {
>  			page++;
>  			continue;
> @@ -2516,6 +2519,10 @@ static void setup_zone_migrate_reserve(struct zone *zone)
>  			continue;
>  		page = pfn_to_page(pfn);
>  
> +		/* Watch out for overlapping nodes */
> +		if (page_to_nid(page) != zone_to_nid(zone))
> +			continue;
> +
>  		/* Blocks with reserved pages will never free, skip them. */
>  		if (PageReserved(page))
>  			continue;
> 
> -- 
> Adam Litke - (agl at us.ibm.com)
> IBM Linux Technology Center
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
