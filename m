Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED2B28E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:51:20 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so3904587edc.9
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:51:20 -0800 (PST)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.106])
        by mx.google.com with ESMTPS id k43si681038eda.389.2019.01.17.07.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 07:51:19 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id CE8971C2DE5
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:51:18 +0000 (GMT)
Date: Thu, 17 Jan 2019 15:51:17 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 13/25] mm, compaction: Use free lists to quickly locate a
 migration target
Message-ID: <20190117155117.GI27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-14-mgorman@techsingularity.net>
 <f9ba4f25-b0b1-8323-f2a8-a4dd639a1882@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <f9ba4f25-b0b1-8323-f2a8-a4dd639a1882@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Thu, Jan 17, 2019 at 03:36:08PM +0100, Vlastimil Babka wrote:
> >  /* Reorder the free list to reduce repeated future searches */
> >  static void
> > -move_freelist_tail(struct list_head *freelist, struct page *freepage)
> > +move_freelist_head(struct list_head *freelist, struct page *freepage)
> >  {
> >  	LIST_HEAD(sublist);
> >  
> > @@ -1147,6 +1147,193 @@ move_freelist_tail(struct list_head *freelist, struct page *freepage)
> >  	}
> >  }
> 
> Hmm this hunk appears to simply rename move_freelist_tail() to
> move_freelist_head(), but fast_find_migrateblock() is unchanged, so it now calls
> the new version below.
> 

Rebase screwup. I'll fix it up and retest

> <SNIP>
> BTW it would be nice to
> document both of the functions what they are doing on the high level :) The one
> above was a bit tricky to decode to me, as it seems to be moving the initial
> part of list to the tail, to effectively move the latter part of the list
> (including freepage) to the head.
> 

I'll include a blurb.

> > +	/*
> > +	 * If starting the scan, use a deeper search and use the highest
> > +	 * PFN found if a suitable one is not found.
> > +	 */
> > +	if (cc->free_pfn == pageblock_start_pfn(zone_end_pfn(cc->zone) - 1)) {
> > +		limit = pageblock_nr_pages >> 1;
> > +		scan_start = true;
> > +	}
> > +
> > +	/*
> > +	 * Preferred point is in the top quarter of the scan space but take
> > +	 * a pfn from the top half if the search is problematic.
> > +	 */
> > +	distance = (cc->free_pfn - cc->migrate_pfn);
> > +	low_pfn = pageblock_start_pfn(cc->free_pfn - (distance >> 2));
> > +	min_pfn = pageblock_start_pfn(cc->free_pfn - (distance >> 1));
> > +
> > +	if (WARN_ON_ONCE(min_pfn > low_pfn))
> > +		low_pfn = min_pfn;
> > +
> > +	for (order = cc->order - 1;
> > +	     order >= 0 && !page;
> > +	     order--) {
> > +		struct free_area *area = &cc->zone->free_area[order];
> > +		struct list_head *freelist;
> > +		struct page *freepage;
> > +		unsigned long flags;
> > +
> > +		if (!area->nr_free)
> > +			continue;
> > +
> > +		spin_lock_irqsave(&cc->zone->lock, flags);
> > +		freelist = &area->free_list[MIGRATE_MOVABLE];
> > +		list_for_each_entry_reverse(freepage, freelist, lru) {
> > +			unsigned long pfn;
> > +
> > +			order_scanned++;
> > +			nr_scanned++;
> 
> Seems order_scanned is supposed to be reset to 0 for each new order? Otherwise
> it's equivalent to nr_scanned...
> 

Yes, it was meant to be. Not sure at what point I broke that and failed
to spot it afterwards. As you note elsewhere, the code structure doesn't
make sense if it wasn't been set to 0. Instead of doing a shorter search
at each order, it would simply check one page for each lower order.

Thanks!

-- 
Mel Gorman
SUSE Labs
