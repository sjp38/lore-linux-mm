Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 82F1A8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:58:23 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2VFbRil008251
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:37:29 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0E11B38C8042
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:58:06 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2VFw8JV2723938
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:58:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2VFw7pu030732
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:58:07 -0400
Subject: Re: [PATCH 04/12] mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1301577368-16095-5-git-send-email-m.szyprowski@samsung.com>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
	 <1301577368-16095-5-git-send-email-m.szyprowski@samsung.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 31 Mar 2011 08:58:03 -0700
Message-ID: <1301587083.31087.1032.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
> 
> +unsigned long alloc_contig_freed_pages(unsigned long start, unsigned long end,
> +                                      gfp_t flag)
> +{
> +       unsigned long pfn = start, count;
> +       struct page *page;
> +       struct zone *zone;
> +       int order;
> +
> +       VM_BUG_ON(!pfn_valid(start));

This seems kinda mean.  Could we return an error?  I understand that
this is largely going to be an early-boot thing, but surely trying to
punt on crappy input beats a full-on BUG().

	if (!pfn_valid(start))
		return -1;

> +       zone = page_zone(pfn_to_page(start));
> +
> +       spin_lock_irq(&zone->lock);
> +
> +       page = pfn_to_page(pfn);
> +       for (;;) {
> +               VM_BUG_ON(page_count(page) || !PageBuddy(page));
> +               list_del(&page->lru);
> +               order = page_order(page);
> +               zone->free_area[order].nr_free--;
> +               rmv_page_order(page);
> +               __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> +               pfn  += 1 << order;
> +               if (pfn >= end)
> +                       break;

If start->end happens to span the end of a zone, I believe this will
jump out of the zone.  It will still be pfn_valid(), but potentially not
in the same zone. 

> +               VM_BUG_ON(!pfn_valid(pfn));
> +               page += 1 << order;
> +       }

That will break on SPARSEMEM.  You potentially need to revalidate the
pfn->page mapping on every MAX_ORDER pfn change.  It's easiest to just
do pfn_to_page() on each loop.

> +
> +       spin_unlock_irq(&zone->lock); 
> 
> +void free_contig_pages(struct page *page, int nr_pages)
> +{
> +       for (; nr_pages; --nr_pages, ++page)
> +               __free_page(page);
> +}

Can't help but notice that this resembles a bit of a patch I posted last
week:

http://www.spinics.net/lists/linux-mm/msg16364.html

We'll have to make sure we only have one copy of this in the end.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
