Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8TMmU2A020588
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 18:48:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TMo5f4500182
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 16:50:05 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8TMo562021683
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 16:50:05 -0600
Subject: Re: [PATCH] earlier allocation of order 0 pages from pcp in
	__alloc_pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050929150155.A15646@unix-os.sc.intel.com>
References: <20050929150155.A15646@unix-os.sc.intel.com>
Content-Type: text/plain
Date: Thu, 29 Sep 2005 15:50:02 -0700
Message-Id: <1128034202.6145.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-09-29 at 15:01 -0700, Seth, Rohit wrote:
> +/* This routine allocates a order 0 page from cpu's pcp list when one is present.
> + * It does not try to remove the pages from zone_free_list as the zone low
> + * water mark has not yet been checked.
> + */
> +
> +static struct page *
> +remove_from_pcp(struct zone *zone, unsigned int __nocast gfp_flags)
> +{
> +	unsigned long flags;
> +	struct per_cpu_pages *pcp;
> +	struct page *page = NULL;
> +	int cold = !!(gfp_flags & __GFP_COLD);
> +
> +	pcp = &zone_pcp(zone, get_cpu())->pcp[cold];
> +	local_irq_save(flags);
> +	if (pcp->count > pcp->low) {
> +		page = list_entry(pcp->list.next, struct page, lru);
> +		list_del(&page->lru);
> +		pcp->count--;
> +	}
> +	local_irq_restore(flags);
> +	put_cpu();
> +
> +	if (page != NULL) {
> +		mod_page_state_zone(zone, pgalloc, 1 );
> +		prep_new_page(page, 0);
> +
> +		if (gfp_flags & __GFP_ZERO)
> +			prep_zero_page(page, 0, gfp_flags);
> +	}
> +	return page;
> +}
> +

That looks to share a decent amount of logic with the pcp code in
buffered_rmqueue.  Any chance it could be consolidated instead of
copy/pasting?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
