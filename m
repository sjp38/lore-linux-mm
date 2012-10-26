Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 791116B0073
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 11:17:49 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 26 Oct 2012 11:17:48 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 5A67AC9004C
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 11:17:45 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q9QFHiwg254554
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 11:17:45 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q9QFHiKh023130
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 13:17:44 -0200
Message-ID: <508AA965.7080003@linux.vnet.ibm.com>
Date: Fri, 26 Oct 2012 08:16:53 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] page_alloc: fix the incorrect adjustment to zone->present_pages
References: <1351245581-16652-1-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351245581-16652-1-git-send-email-laijs@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 10/26/2012 02:59 AM, Lai Jiangshan wrote:
> Current free_area_init_core() has incorrect adjustment code to adjust
> ->present_pages. It will cause ->present_pages overflow, make the
> system unusable(can't create any process/thread in our test) and cause further problem.
> 
> Details:
> 1) Some/many ZONEs don't have memory which is used by memmap.
>    { Or all the actual memory used for memmap is much less than the "memmap_pages"
>    (memmap_pages = PAGE_ALIGN(span_size * sizeof(struct page)) >> PAGE_SHIFT)
>    CONFIG_SPARSEMEM is an example. }

Reading this code, the use of 'size' (which you correctly note is better
titled 'span_size') looks potentially wrong in the sparsemem cases
because the mem_map[] can have holes.  But, if we just replaced
'span_size' with 'realsize' it would probably be wrong in the sparsemem
case.

> 2) incorrect adjustment in free_area_init_core(): zone->present_pages -= memmap_pages
> 3) but the zone has big hole, it causes the result of zone->present_pages become much smaller
> 4) when we offline a/several memory section of the zone: zone->present_pages -= offline_size
> 5) Now, zone->present_pages will/may be *OVERFLOW*.
> 
> So the adjustment is dangerous and incorrect.
> 
> Addition 1:
> And in current kernel, the memmaps have nothing related/bound to any ZONE:
> 	FLATMEM: global memmap
> 	CONFIG_DISCONTIGMEM: node-specific memmap
> 	CONFIG_SPARSEMEM: memorysection-specific memmap
> None of them is ZONE-specific memmap, and the memory used for memmap is not bound to any ZONE.
> So the adjustment "zone->present_pages -= memmap_pages" subtracts unrelated value
> and makes no sense.

You're right, mem_map[]s are not really _part_ of a zone.  But, we don't
keep track of watermarks on the basis of nodes or sections, we only keep
them on zones.  So, if we want to adjust those watermarks to make up for
the memory that the mem_map[] eats, we don't have a choice to do it
other than in the zone.

> Addition 2:
> We introduced this adjustment and tried to make page-reclaim/watermark happier,
> but the adjustment is wrong in current kernel, and even makes page-reclaim/watermark
> worse. It is against its original purpose/reason.
> 
> This adjustment is incorrect/buggy, subtracts unrelated value and violates its original
> purpose, so we simply remove the adjustment.

I don't think you can just remove it.  I agree that it needs to get
fixed, but nuking it isn't the answer.

I there a reason this would not work if we did this (I mean logically...
please don't do #ifdef monstrosities in code like this):

	spanned_size = zone_spanned_pages_in_node(nid, j,
						zones_size);
	realsize = size - zone_absent_pages_in_node(nid, j,
						zholes_size);

#ifdef CONFIG_HOLES_IN_ZONE
	zone_size_for_memmap = realsize;
#else
	zone_size_for_memmap = spanned_size;
#endif

The other option for the sparsemem cases would be to go back at this
point and try to figure out in exactly which zones the bootmem-allocated
mem_map[]s now lie.

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bb90971..6bf72e3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4455,30 +4455,12 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
> 
>  	for (j = 0; j < MAX_NR_ZONES; j++) {
>  		struct zone *zone = pgdat->node_zones + j;
> -		unsigned long size, realsize, memmap_pages;
> +		unsigned long size, realsize;
> 
>  		size = zone_spanned_pages_in_node(nid, j, zones_size);
>  		realsize = size - zone_absent_pages_in_node(nid, j,
>  								zholes_size);
> 
> -		/*
> -		 * Adjust realsize so that it accounts for how much memory
> -		 * is used by this zone for memmap. This affects the watermark
> -		 * and per-cpu initialisations
> -		 */
> -		memmap_pages =
> -			PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
> -		if (realsize >= memmap_pages) {
> -			realsize -= memmap_pages;
> -			if (memmap_pages)
> -				printk(KERN_DEBUG
> -				       "  %s zone: %lu pages used for memmap\n",
> -				       zone_names[j], memmap_pages);

I was actually kind of fond of that printk, despite it being imprecise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
