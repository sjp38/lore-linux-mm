Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 347BC6B0260
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:03:17 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id h67so243449400vkf.4
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:03:17 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id n5si76305648wmf.2.2017.01.04.06.03.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 06:03:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 83B5898BF0
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 14:03:15 +0000 (UTC)
Date: Wed, 4 Jan 2017 14:03:15 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/4] mm, page_alloc: Add a bulk page allocator
Message-ID: <20170104140314.37sg3ql2aoqvpgq5@techsingularity.net>
References: <20170104111049.15501-1-mgorman@techsingularity.net>
 <20170104111049.15501-5-mgorman@techsingularity.net>
 <20170104144844.7d2a1d6f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170104144844.7d2a1d6f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Jan 04, 2017 at 02:48:44PM +0100, Jesper Dangaard Brouer wrote:
> On Wed,  4 Jan 2017 11:10:49 +0000
> > The API is not guaranteed to return the requested number of pages and
> > may fail if the preferred allocation zone has limited free memory,
> > the cpuset changes during the allocation or page debugging decides
> > to fail an allocation. It's up to the caller to request more pages
> > in batch if necessary.
> 
> I generally like it, thanks! :-)
> 

No problem.

> > +	/*
> > +	 * Only attempt a batch allocation if watermarks on the preferred zone
> > +	 * are safe.
> > +	 */
> > +	zone = ac.preferred_zoneref->zone;
> > +	if (!zone_watermark_fast(zone, order, zone->watermark[ALLOC_WMARK_HIGH] + nr_pages,
> > +				 zonelist_zone_idx(ac.preferred_zoneref), alloc_flags))
> > +		goto failed;
> > +
> > +	/* Attempt the batch allocation */
> > +	migratetype = ac.migratetype;
> > +
> > +	local_irq_save(flags);
> 
> It would be a win if we could either use local_irq_{disable,enable} or
> preempt_{disable,enable} here, by dictating it can only be used from
> irq-safe context (like you did in patch 3).
> 

This was a stupid mistake during a rebase. I should have removed all the
IRQ-disabling entirely and made it only usable from non-IRQ context to
keep the motivation of patch 3 in place. It was a botched rebase of the
patch on top of patch 3 that wasn't properly tested. It still illustrates
the general shape at least. For extra safety, I should force it to return
just a single page if called from interrupt context.

Is bulk allocation from IRQ context a requirement? If so, the motivation
for patch 3 disappears which is a pity but IRQ safety has a price. The
shape of V2 depends on the answer.

> 
> > +	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> > +	pcp_list = &pcp->lists[migratetype];
> > +
> > +	while (nr_pages) {
> > +		page = __rmqueue_pcplist(zone, order, gfp_mask, migratetype,
> > +								cold, pcp, pcp_list);
> > +		if (!page)
> > +			break;
> > +
> > +		nr_pages--;
> > +		alloced++;
> > +		list_add(&page->lru, alloc_list);
> > +	}
> > +
> > +	if (!alloced) {
> > +		local_irq_restore(flags);
> > +		preempt_enable();
> 
> The preempt_enable here looks wrong.
> 

It is because I screwed up the rebase.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
