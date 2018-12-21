Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD0268E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 18:45:42 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id y88so6394593pfi.9
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 15:45:42 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j5si3271436pgq.82.2018.12.21.15.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 15:45:41 -0800 (PST)
Message-ID: <fcbf10c73e2b2ce7b8580f0f91c447571a506ea4.camel@linux.intel.com>
Subject: Re: [PATCH] mm, page_alloc: calculate first_deferred_pfn directly
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Fri, 21 Dec 2018 15:45:40 -0800
In-Reply-To: <20181221224451.tv4plkhkmuolmclv@master>
References: <20181207100859.8999-1-richard.weiyang@gmail.com>
	 <619af066710334134f78fd5ed0f9e3222a468847.camel@linux.intel.com>
	 <20181221224451.tv4plkhkmuolmclv@master>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, pavel.tatashin@microsoft.com, akpm@linux-foundation.org, mhocko@suse.com

On Fri, 2018-12-21 at 22:44 +0000, Wei Yang wrote:
> On Thu, Dec 20, 2018 at 03:47:53PM -0800, Alexander Duyck wrote:
> > On Fri, 2018-12-07 at 18:08 +0800, Wei Yang wrote:
> > > After commit c9e97a1997fb ("mm: initialize pages on demand during
> > > boot"), the behavior of DEFERRED_STRUCT_PAGE_INIT is changed to
> > > initialize first section for highest zone on each node.
> > > 
> > > Instead of test each pfn during iteration, we could calculate the
> > > first_deferred_pfn directly with necessary information.
> > > 
> > > By doing so, we also get some performance benefit during bootup:
> > > 
> > >     +----------+-----------+-----------+--------+
> > >     |          |Base       |Patched    |Gain    |
> > >     +----------+-----------+-----------+--------+
> > >     | 1 Node   |0.011993   |0.011459   |-4.45%  |
> > >     +----------+-----------+-----------+--------+
> > >     | 4 Nodes  |0.006466   |0.006255   |-3.26%  |
> > >     +----------+-----------+-----------+--------+
> > > 
> > > Test result is retrieved from dmesg time stamp by add printk around
> > > free_area_init_nodes().
> > > 
> > > Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> 
> Hi, Alexander
> 
> Thanks for your comment!
> 
> > I'm pretty sure the fundamental assumption made in this patch is wrong.
> > 
> > It is assuming that the first deferred PFN will just be your start PFN
> > + PAGES_PER_SECTION aligned to the nearest PAGES_PER_SECTION, do I have
> > that correct?
> 
> You are right.
> 
> > 
> > If I am not mistaken that can result in scenarios where you actually
> > start out with 0 pages allocated if your first section is in a span
> > belonging to another node, or is reserved memory for things like MMIO.
> 
> Yeah, sounds it is possible.
> 
> > 
> > Ideally we don't want to do that as we have to immediately jump into
> > growing the zone with the code as it currently stands.
> 
> You are right.
> 
> > 
> > > ---
> > >  mm/page_alloc.c | 57 +++++++++++++++++++++++++++------------------------------
> > >  1 file changed, 27 insertions(+), 30 deletions(-)
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index baf473f80800..5f077bf07f3e 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -306,38 +306,33 @@ static inline bool __meminit early_page_uninitialised(unsigned long pfn)
> > >  }
> > >  
> > >  /*
> > > - * Returns true when the remaining initialisation should be deferred until
> > > - * later in the boot cycle when it can be parallelised.
> > > + * Calculate first_deferred_pfn in case:
> > > + * - in MEMMAP_EARLY context
> > > + * - this is the last zone
> > > + *
> > > + * If the first aligned section doesn't exceed the end_pfn, set it to
> > > + * first_deferred_pfn and return it.
> > >   */
> > > -static bool __meminit
> > > -defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> > > +unsigned long __meminit
> > > +defer_pfn(int nid, unsigned long start_pfn, unsigned long end_pfn,
> > > +	  enum memmap_context context)
> > >  {
> > > -	static unsigned long prev_end_pfn, nr_initialised;
> > > +	struct pglist_data *pgdat = NODE_DATA(nid);
> > > +	unsigned long pfn;
> > >  
> > > -	/*
> > > -	 * prev_end_pfn static that contains the end of previous zone
> > > -	 * No need to protect because called very early in boot before smp_init.
> > > -	 */
> > > -	if (prev_end_pfn != end_pfn) {
> > > -		prev_end_pfn = end_pfn;
> > > -		nr_initialised = 0;
> > > -	}
> > > +	if (context != MEMMAP_EARLY)
> > > +		return end_pfn;
> > >  
> > > -	/* Always populate low zones for address-constrained allocations */
> > > -	if (end_pfn < pgdat_end_pfn(NODE_DATA(nid)))
> > > -		return false;
> > > +	/* Always populate low zones */
> > > +	if (end_pfn < pgdat_end_pfn(pgdat))
> > > +		return end_pfn;
> > >  
> > > -	/*
> > > -	 * We start only with one section of pages, more pages are added as
> > > -	 * needed until the rest of deferred pages are initialized.
> > > -	 */
> > > -	nr_initialised++;
> > > -	if ((nr_initialised > PAGES_PER_SECTION) &&
> > > -	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
> > > -		NODE_DATA(nid)->first_deferred_pfn = pfn;
> > > -		return true;
> > > +	pfn = roundup(start_pfn + PAGES_PER_SECTION - 1, PAGES_PER_SECTION);
> > > +	if (end_pfn > pfn) {
> > > +		pgdat->first_deferred_pfn = pfn;
> > > +		end_pfn = pfn;
> > >  	}
> > > -	return false;
> > > +	return end_pfn;
> > 
> > Okay so I stand corrected. It looks like you are rounding up by
> > (PAGES_PER_SECTION - 1) * 2 since if I am not mistaken roundup should
> > do the same math you already did in side the function.
> > 
> > >  }
> > >  #else
> > >  static inline bool early_page_uninitialised(unsigned long pfn)
> > > @@ -345,9 +340,11 @@ static inline bool early_page_uninitialised(unsigned long pfn)
> > >  	return false;
> > >  }
> > >  
> > > -static inline bool defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> > > +unsigned long __meminit
> > > +defer_pfn(int nid, unsigned long start_pfn, unsigned long end_pfn,
> > > +	  enum memmap_context context)
> > >  {
> > > -	return false;
> > > +	return end_pfn;
> > >  }
> > >  #endif
> > >  
> > > @@ -5514,6 +5511,8 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> > >  	}
> > >  #endif
> > >  
> > > +	end_pfn = defer_pfn(nid, start_pfn, end_pfn, context);
> > > +
> > 
> > A better approach for this might be to look at placing the loop within
> > a loop similar to how I handled this for the deferred init. You only
> > really need to be performing all of these checks once per section
> > aligned point anyway.
> 
> I didn't really get your idea here. Do you have the commit id you handle
> deferred init?

The deferred_grow_zone function actually had some logic like this
before I had rewritten it, you can still find it on lxr:
https://elixir.bootlin.com/linux/latest/source/mm/page_alloc.c#L1668

> 
> > 
> > Basically if you added another loop and limited the loop below so that
> > you only fed it one section at a time then you could just pull the
> > defer_init check out of this section and place it in the outer loop
> > after you have already tried initializing at least one section worth of
> > pages.
> > 
> > You could probably also look at pulling in the logic that is currently
> > sitting at the end of the current function that is initializing things
> > until the end_pfn is aligned with PAGES_PER_SECTION.
> > 
> > >  	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> > >  		/*
> > >  		 * There can be holes in boot-time mem_map[]s handed to this
> > > @@ -5526,8 +5525,6 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> > >  				continue;
> > >  			if (overlap_memmap_init(zone, &pfn))
> > >  				continue;
> > > -			if (defer_init(nid, pfn, end_pfn))
> > > -				break;
> > >  		}
> > 
> > So the whole reason for the "defer_init" call being placed here is
> > because there are checks to see if the prior PFN is valid, in our NUMA
> > node, or is an overlapping region. If your first section or in this
> > case 2 sections contain pages that fall into these categories you
> > aren't going to initialize any pages.
> 
> Ok, I get your point. Let me do a summary, the approach in this patch
> has one flaw: in case all pages in the first section fall into these two
> categories, we will end up with no page initialized for this zone.
> 
> So my suggestion is:
> 
>   Find the first valid page and roundup it to PAGES_PER_SECTION. This
>   would ensure we won't end up with zero initialized page.

Using the first valid PFN will not work either. The problem is you want
to ideally have PAGES_PER_SECTION number of pages allocated before we
begin deferring allocation. The pages will have a number of regions
that are reserved and/or full of holes so you cannot rely on the first
PFN to be the start of a contiguous section of pages.

> Generally, my purpose in this patch is:
> 
> 1. Don't affect the initialisation for non defer init zones.
>    Current code will call defer_init() for each pfn, no matter this pfn
>    should be defer_init or not. By taking this out, we try to minimize
>    the effect on the initialisation process.

So one problem with trying to pull out defer_init is that it contains
the increment nr_initialized. At a minimum that logic should probably
be pulled out and placed back where it was.

> 2. Iterate on less pfn for defer zone
>    Current code will count on each pfn in defer zone. By roundup pfn
>    directly, less calculation would be necessary. Defer init will handle
>    the rest. Or if we really want at least PAGES_PER_SECTION pfn be
>    initialized for defer zone, we can do the same math in defer_pfn().

So the general idea I was referring to above would be something like:
for (pfn = start_pfn; pfn < end_pfn;) {
	t = ALIGN_DOWN(pfn + PAGES_PER_SECTION, PAGES_PER_SECTION);
	first_deferred_pfn = min(t, end_pfn);
	section_initialized = 0;

	for (; pfn < first_deferred_pfn; pfn++) {
		struct page *page;

		/* All or original checks here w/ continue */

		/* all of the original page initialization stuff */

		section_initialized++;
	}

	/* Place all the original checks for deferred init here */

	nr_initialized += section_initialized;

	/* remaining checks for deferred init to see if we exit/break here */
}

The general idea is the same as what you have stated. However with this
approach we should be able to count the number of pages initialized and
once per section we will either just drop the results stored in
section_initialized, or we will add them to the initialized count and
if it exceeds the needed value we could then break out of the loop.

> 
> Glad to talk with you and look forward your comments:-)
> 
> > 
> > >  
> > >  		page = pfn_to_page(pfn);
> 
> 
