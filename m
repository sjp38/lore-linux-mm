Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1NI3q7s020344
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:03:52 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1NI3qSt232426
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:03:52 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k1NI3pJ7006988
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:03:52 -0500
Subject: Re: [RFC] memory-layout-free zones (for review) [1/3]
	for_each_page_in_zone()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060223175643.a685dfb3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060223175643.a685dfb3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 23 Feb 2006 10:03:44 -0800
Message-Id: <1140717824.8697.59.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-02-23 at 17:56 +0900, KAMEZAWA Hiroyuki wrote:
> +/*
> + *  These inline function for for_each_page_in_zone can work
> + *  even if CONFIG_SPARSEMEM=y.
> + */
> +static inline struct page *first_page_in_zone(struct zone *zone)
> +{
> +	unsigned long start_pfn = zone->zone_start_pfn;
> +	unsigned long i = 0;
> +
> +	if (!populated_zone(zone))
> +		return NULL;
> +
> +	for (i = 0; i < zone->zone_spanned_pages; i++) {
> +		if (pfn_valid(start_pfn + i))
> +			break;
> +	}
> +	return pfn_to_page(start_pfn + i);
> +}

Isn't this a little hefty of a function for an inline?

Also, why would we _ever_ have a zone that didn't actually have a valid
pfn at its start?  If there wasn't a valid pfn there, with no
zone_mem_map, wouldn't we just bump up the start_pfn?

> +static inline struct page *next_page_in_zone(struct page *page,
> +					     struct zone *zone)
> +{
> +	unsigned long start_pfn = zone->zone_start_pfn;
> +	unsigned long i = page_to_pfn(page) - start_pfn;
> +
> +	if (!populated_zone(zone))
> +		return NULL;
> +
> +	for (i = i + 1; i < zone->zone_spanned_pages; i++) {
> +		if (pfn_vlaid(start_pfn + i))
> +			break;
> +	}
> +	if (i == zone->zone_spanned_pages)
> +		return NULL;
> +	return pfn_to_page(start_pfn + i);
> +}

Seems like this should share code with the other function.  And the
"vlaid" part looks a bit uncompilable. ;)

> +/**
> + * for_each_page_in_zone -- helper macro to iterate over all pages in a zone.
> + * @page - pointer to page
> + * @zone - pointer to zone
> + *
> + */
> +#define for_each_page_in_zone(page, zone)		\
> +	for (page = (first_page_in_zone((zone)));	\
> +	     page;					\
> +	     page = next_page_in_zone(page, (zone)));
> +

Nice.  We need one of these.  The rest of the patch looks pretty
straighforward.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
