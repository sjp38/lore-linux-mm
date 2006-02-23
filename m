Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1NICKVD011116
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:12:20 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1NI9trN188552
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 11:09:55 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k1NICKUe028908
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 11:12:20 -0700
Subject: Re: [RFC] memory-layout-free zones (for review) [3/3]  fix
	for_each_page_in_zone
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060223180023.396d2cfe.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060223180023.396d2cfe.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 23 Feb 2006 10:12:13 -0800
Message-Id: <1140718333.8697.69.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-02-23 at 18:00 +0900, KAMEZAWA Hiroyuki wrote:
> +static inline struct page *first_page_in_zone(struct zone *zone)
> +{
> +	struct pglist_data *pgdat;
> +	unsigned long start_pfn;
> +	unsigned long i = 0;
> +
> +	if (!populated_zone(zone))
> +		return NULL;
> +
> +	pgdat = zone->zone_pgdat;
> +	zone = pgdat->node_start_pfn;
> +
> +	for (i = 0; i < pgdat->zone_spanned_pages; i++) {
> +		if (pfn_valid(start_pfn + i) && page_zone(page) == zone)
> +			break;
> +	}
> +	BUG_ON(i == pgdat->node_spanned_pages); /* zone is populated */
> +	return pfn_to_page(start_pfn + i);
> +}

I know we don't use this function _too_ much , but it would probably be
nice to make it a little smarter than "i++".  We can be pretty sure, at
least with SPARSEMEM that the granularity is larger than that.  We can
probably leave it until it gets to be a real problem.

I was also trying to think if a binary search is appropriate here.  I
guess it depends on whether we allow the zones to have overlapping pfn
ranges, which I _think_ is one of the goals from these patches.  Any
thoughts?

Oh, and I noticed the "pgdat->zone_spanned_pages" bit.  Did you compile
this? ;)

> +static inline struct page *next_page_in_zone(struct page *page,
> +					     struct zone *zone)
> +{
> +	struct pglist_data *pgdat;
> +	unsigned long start_pfn;
> +	unsigned long i;
> +
> +	if (!populated_zone(zone))
> +		return NULL;
> +	pgdat = zone->zone_pgdat;
> +	start_pfn = pgdat->node_start_pfn;
> +	i = page_to_pfn(page) - start_pfn;
> +
> +	for (i = i + 1; i < pgdat->node_spanned_pages; i++) {
> +		if (pfn_vlaid(start_pfn + i) && page_zone(page) == zone)
> +			break;
> +	}
> +	if (i == pgdat->node_spanned_pages)
> +		return NULL;
> +	return pfn_to_page(start_pfn + i);
> +}

Same comment, BTW, about code sharing.  Is it something we want to or
can do with these?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
