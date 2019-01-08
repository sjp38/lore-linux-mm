Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D10D8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 15:04:40 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so2050098edq.4
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 12:04:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy4-v6si371508ejb.223.2019.01.08.12.04.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 12:04:38 -0800 (PST)
Date: Tue, 8 Jan 2019 21:04:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
Message-ID: <20190108200436.GK31793@dhcp22.suse.cz>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
 <37498672d5b2345b1435477e78251282af42742b.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <37498672d5b2345b1435477e78251282af42742b.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Arun KS <arunks@codeaurora.org>, arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Tue 08-01-19 10:40:18, Alexander Duyck wrote:
> On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
> > When freeing pages are done with higher order, time spent on coalescing
> > pages by buddy allocator can be reduced.  With section size of 256MB, hot
> > add latency of a single section shows improvement from 50-60 ms to less
> > than 1 ms, hence improving the hot add latency by 60 times.  Modify
> > external providers of online callback to align with the change.
> > 
> > Signed-off-by: Arun KS <arunks@codeaurora.org>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Reviewed-by: Oscar Salvador <osalvador@suse.de>
> 
> After running into my initial issue I actually had a few more questions
> about this patch.
> 
> > [...]
> > +static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> > +{
> > +	unsigned long end = start + nr_pages;
> > +	int order, ret, onlined_pages = 0;
> > +
> > +	while (start < end) {
> > +		order = min(MAX_ORDER - 1,
> > +			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
> > +
> > +		ret = (*online_page_callback)(pfn_to_page(start), order);
> > +		if (!ret)
> > +			onlined_pages += (1UL << order);
> > +		else if (ret > 0)
> > +			onlined_pages += ret;
> > +
> > +		start += (1UL << order);
> > +	}
> > +	return onlined_pages;
> >  }
> >  
> 
> Should the limit for this really be MAX_ORDER - 1 or should it be
> pageblock_order? In some cases this will be the same value, but I seem
> to recall that for x86 MAX_ORDER can be several times larger than
> pageblock_order.

Does it make any difference when we are in fact trying to onine nr_pages
and we clamp to it properly?

> >  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> >  			void *arg)
> >  {
> > -	unsigned long i;
> >  	unsigned long onlined_pages = *(unsigned long *)arg;
> > -	struct page *page;
> >  
> >  	if (PageReserved(pfn_to_page(start_pfn)))
> 
> I'm not sure we even really need this check. Getting back to the
> discussion I have been having with Michal in regards to the need for
> the DAX pages to not have the reserved bit cleared I was originally
> wondering if we could replace this check with a call to
> online_section_nr since the section shouldn't be online until we set
> the bit below in online_mem_sections.
> 
> However after doing some further digging it looks like this could
> probably be dropped entirely since we only call this function from
> online_pages and that function is only called by memory_block_action if
> pages_correctly_probed returns true. However pages_correctly_probed
> should return false if any of the sections contained in the page range
> is already online.

Yes you are right but I guess it would be better to address in a
separate patch that deals with PageReserved manipulation in general.
I do not think we want to remove the check silently. People who might be
interested in backporting this for whatever reason might screatch their
head why the test is not needed anymore.
-- 
Michal Hocko
SUSE Labs
