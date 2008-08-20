Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7KIEbdZ012597
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 14:14:37 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7KIBr0o229930
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 14:11:53 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7KIBrJ9006872
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 14:11:53 -0400
Subject: Re: [BUG] Make setup_zone_migrate_reserve() aware of overlapping
	nodes
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1219252134.13885.25.camel@localhost.localdomain>
References: <1218837685.12953.11.camel@localhost.localdomain>
	 <1219252134.13885.25.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Date: Wed, 20 Aug 2008 11:11:51 -0700
Message-Id: <1219255911.8960.41.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, apw <apw@shadowen.org>, agl <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-20 at 12:08 -0500, Adam Litke wrote:
> I have gotten to the root cause of the hugetlb badness I reported back
> on August 15th.  My system has the following memory topology (note the
> overlapping node):
> 
> 	i>>?Node 0 Memory: 0x8000000-0x44000000
> 	i>>?Node 1 Memory: 0x0-0x8000000 0x44000000-0x80000000
> 
> setup_zone_migrate_reserve() scans the address range 0x0-0x8000000
> looking for a pageblock to move onto the MIGRATE_RESERVE list.  Finding
> no candidates, it happily continues the scan into 0x8000000-0x44000000.
> When a pageblock is found, the pages are moved to the MIGRATE_RESERVE
> list on the wrong zone.  Oops.

This eventually gets down into move_freepages() via:

	->setup_zone_migrate_reserve()
	 ->move_freepages_block()
	  ->move_freepages()
right?

It looks like there have been bugs in this area before in
move_freepages().  Should there be a more stringent check in *there*?
Maybe a warning?
> i>>?
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2512,6 +2512,10 @@ static void setup_zone_migrate_reserve(struct
> zone *zone)
>                                                         pageblock_order;
>  
>         for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
> +               /* Watch out for overlapping nodes */
> +               if (!early_pfn_in_nid(pfn, zone->node))
> +                       continue;

zone->node doesn't exist on !CONFIG_NUMA. :(

You probably want:

	if (!early_pfn_in_nid(pfn, zone_to_nid(zone)))
		continue;

Are you sure you need the "early_" variant here?  We're not using
early_pfn_valid() right below it.  I guess you could also use:

	if (!page_to_nid(page) != zone_to_nid(zone))
		continue;

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
