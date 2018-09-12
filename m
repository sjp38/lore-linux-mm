Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC358E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:57:49 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 191-v6so986027pgb.23
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:57:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6-v6sor155253pgn.384.2018.09.12.05.57.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 05:57:47 -0700 (PDT)
Date: Wed, 12 Sep 2018 22:57:43 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [RFC] memory_hotplug: Free pages as pageblock_order
Message-ID: <20180912125743.GB8537@350D>
References: <1536744405-16752-1-git-send-email-arunks@codeaurora.org>
 <20180912103853.GC10951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912103853.GC10951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Arun KS <arunks@codeaurora.org>, akpm@linux-foundation.org, dan.j.williams@intel.com, vbabka@suse.cz, pasha.tatashin@oracle.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, malat@debian.org, gregkh@linuxfoundation.org, yasu.isimatu@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, arunks.linux@gmail.com, vinmenon@codeaurora.org

On Wed, Sep 12, 2018 at 12:38:53PM +0200, Michal Hocko wrote:
> On Wed 12-09-18 14:56:45, Arun KS wrote:
> > When free pages are done with pageblock_order, time spend on
> > coalescing pages by buddy allocator can be reduced. With
> > section size of 256MB, hot add latency of a single section
> > shows improvement from 50-60 ms to less than 1 ms, hence
> > improving the hot add latency by 60%.
> 
> Where does the improvement come from? You are still doing the same
> amount of work except that the number of callbacks is lower. Is this the
> real source of 60% improvement?
>

It looks like only the first page of the pageblock is initialized, is
some of the cost amortized in terms of doing one initialization for
the page with order (order) and then relying on split_page and helpers
to do the rest? Of course the number of callbacks reduce by a significant
number as well.

 
> > 
> > If this looks okey, I'll modify users of set_online_page_callback
> > and resend clean patch.
> 
> [...]
> 
> > +static int generic_online_pages(struct page *page, unsigned int order);
> > +static online_pages_callback_t online_pages_callback = generic_online_pages;
> > +
> > +static int generic_online_pages(struct page *page, unsigned int order)
> > +{
> > +	unsigned long nr_pages = 1 << order;
> > +	struct page *p = page;
> > +	unsigned int loop;
> > +
> > +	for (loop = 0 ; loop < nr_pages ; loop++, p++) {
> > +		__ClearPageReserved(p);
> > +		set_page_count(p, 0);
> > +	}
> > +	adjust_managed_page_count(page, nr_pages);
> > +	init_page_count(page);
> > +	__free_pages(page, order);
> > +
> > +	return 0;
> > +}
> > +
> > +static int online_pages_blocks(unsigned long start_pfn, unsigned long nr_pages)
> > +{
> > +	unsigned long pages_per_block = (1 << pageblock_order);
> > +	unsigned long nr_pageblocks = nr_pages / pages_per_block;
> > +//	unsigned long rem_pages = nr_pages % pages_per_block;
> > +	int i, ret, onlined_pages = 0;
> > +	struct page *page;
> > +
> > +	for (i = 0 ; i < nr_pageblocks ; i++) {
> > +		page = pfn_to_page(start_pfn + (i * pages_per_block));
> > +		ret = (*online_pages_callback)(page, pageblock_order);
> > +		if (!ret)
> > +			onlined_pages += pages_per_block;
> > +		else if (ret > 0)
> > +			onlined_pages += ret;
> > +	}
> 
> Could you explain why does the pages_per_block step makes any sense? Why
> don't you simply apply handle the full nr_pages worth of memory range
> instead?
> 
> > +/*
> > +	if (rem_pages)
> > +		onlined_pages += online_page_single(start_pfn + i, rem_pages);
> > +*/

Do we expect no rem_pages with this patch?

> > +
> > +	return onlined_pages;
> > +}
> > +
> >  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> >  			void *arg)
> >  {
> > -	unsigned long i;
> >  	unsigned long onlined_pages = *(unsigned long *)arg;
> > -	struct page *page;
> >  
> >  	if (PageReserved(pfn_to_page(start_pfn)))
> > -		for (i = 0; i < nr_pages; i++) {
> > -			page = pfn_to_page(start_pfn + i);
> > -			(*online_page_callback)(page);
> > -			onlined_pages++;
> > -		}
> > +		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
> >  
> >  	online_mem_sections(start_pfn, start_pfn + nr_pages);


Balbir Singh.
