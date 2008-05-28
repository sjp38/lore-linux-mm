Date: Wed, 28 May 2008 12:57:59 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/23] hugetlb: support boot allocate different sizes
Message-ID: <20080528105759.GG2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143453.424711000@nick.local0.net> <1211923735.12036.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1211923735.12036.41.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 04:28:55PM -0500, Adam Litke wrote:
> Seems nice, but what exactly is this patch for?  From reading the code
> it would seem that this allows more than one >MAX_ORDER hstates to exist
> and removes assumptions about their positioning withing the hstates
> array?  A small patch leader would definitely clear up my confusion.

Yes it allows I guess hugetlb_init_one_hstate to be called multiple
times on an hstate, and also some logic dealing with giant page setup.

Though hmm, possibly it can be made a little cleaner by separating
hstate init from the actual page allocation a little more. I'll have
a look but it is kind of tricky... otherwise I can try a changelog.

 
> 
> On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> > plain text document attachment (hugetlb-different-page-sizes.patch)
> > Acked-by: Andrew Hastings <abh@cray.com>
> > Signed-off-by: Andi Kleen <ak@suse.de>
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> >  mm/hugetlb.c |   24 +++++++++++++++++++-----
> >  1 file changed, 19 insertions(+), 5 deletions(-)
> > 
> > Index: linux-2.6/mm/hugetlb.c
> > ===================================================================
> > --- linux-2.6.orig/mm/hugetlb.c
> > +++ linux-2.6/mm/hugetlb.c
> > @@ -609,10 +609,13 @@ static void __init hugetlb_init_one_hsta
> >  {
> >  	unsigned long i;
> > 
> > -	for (i = 0; i < MAX_NUMNODES; ++i)
> > -		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> > +	/* Don't reinitialize lists if they have been already init'ed */
> > +	if (!h->hugepage_freelists[0].next) {
> > +		for (i = 0; i < MAX_NUMNODES; ++i)
> > +			INIT_LIST_HEAD(&h->hugepage_freelists[i]);
> > 
> > -	h->hugetlb_next_nid = first_node(node_online_map);
> > +		h->hugetlb_next_nid = first_node(node_online_map);
> > +	}
> > 
> >  	for (i = 0; i < h->max_huge_pages; ++i) {
> >  		if (h->order >= MAX_ORDER) {
> > @@ -621,7 +624,7 @@ static void __init hugetlb_init_one_hsta
> >  		} else if (!alloc_fresh_huge_page(h))
> >  			break;
> >  	}
> > -	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> > +	h->max_huge_pages = i;
> >  }
> > 
> >  static void __init hugetlb_init_hstates(void)
> > @@ -629,7 +632,10 @@ static void __init hugetlb_init_hstates(
> >  	struct hstate *h;
> > 
> >  	for_each_hstate(h) {
> > -		hugetlb_init_one_hstate(h);
> > +		/* oversize hugepages were init'ed in early boot */
> > +		if (h->order < MAX_ORDER)
> > +			hugetlb_init_one_hstate(h);
> > +		max_huge_pages[h - hstates] = h->max_huge_pages;
> >  	}
> >  }
> > 
> > @@ -692,6 +698,14 @@ static int __init hugetlb_setup(char *s)
> >  	if (sscanf(s, "%lu", mhp) <= 0)
> >  		*mhp = 0;
> > 
> > +	/*
> > +	 * Global state is always initialized later in hugetlb_init.
> > +	 * But we need to allocate >= MAX_ORDER hstates here early to still
> > +	 * use the bootmem allocator.
> > +	 */
> > +	if (max_hstate > 0 && parsed_hstate->order >= MAX_ORDER)
> > +		hugetlb_init_one_hstate(parsed_hstate);
> > +
> >  	return 1;
> >  }
> >  __setup("hugepages=", hugetlb_setup);
> > 
> -- 
> Adam Litke - (agl at us.ibm.com)
> IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
