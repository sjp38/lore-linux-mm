Date: Tue, 19 Jun 2007 17:49:12 +0100
Subject: Re: [PATCH 5/7] Introduce a means of compacting memory within a zone
Message-ID: <20070619164912.GE17109@skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie> <20070618093002.7790.68471.sendpatchset@skynet.skynet.ie> <20070619213927.AC83.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070619213927.AC83.Y-GOTO@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On (19/06/07 21:54), Yasunori Goto didst pronounce:
> Hi Mel-san.
> This is very interesting feature.
> 
> Now, I'm testing your patches.
> 
> > +static int isolate_migratepages(struct zone *zone,
> > +					struct compact_control *cc)
> > +{
> > +	unsigned long high_pfn, low_pfn, end_pfn, start_pfn;
> 
> (snip)
> 
> > +	/* Time to isolate some pages for migration */
> > +	spin_lock_irq(&zone->lru_lock);
> > +	for (; low_pfn < end_pfn; low_pfn++) {
> > +		if (!pfn_valid_within(low_pfn))
> > +			continue;
> > +
> > +		/* Get the page and skip if free */
> > +		page = pfn_to_page(low_pfn);
> 
> I met panic at here on my tiger4.
> 

How annoying.

> I compiled with CONFIG_SPARSEMEM. So, CONFIG_HOLES_IN_ZONE is not set.
> pfn_valid_within() returns 1 every time on this configuration.

As it should.

> (This config is for only virtual memmap)
> But, my tiger4 box has memory holes in normal zone.
> 
> When it is changed to normal pfn_valid(), no panic occurs.
> 

It's because I never check if the MAX_ORDER block is valid before
isolating. This needs to be implemented just like what
isolate_freepages() and isolate_freepages_block() does. Change it to
pfn_valid() for the moment and I'll have this one fixed up properly in
the next version.

> Hmmm.
> 
> Bye.

Thanks for testing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
