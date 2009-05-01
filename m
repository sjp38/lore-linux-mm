Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 66CF96B003D
	for <linux-mm@kvack.org>; Fri,  1 May 2009 10:42:49 -0400 (EDT)
Date: Fri, 1 May 2009 15:43:24 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Message-ID: <20090501144324.GD27831@csn.ul.ie>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils> <20090430132544.GB21997@csn.ul.ie> <Pine.LNX.4.64.0905011202530.8513@blonde.anvils> <20090501140015.GA27831@csn.ul.ie> <Pine.LNX.4.64.0905011509460.28876@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905011509460.28876@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 01, 2009 at 03:28:47PM +0100, Hugh Dickins wrote:
> On Fri, 1 May 2009, Mel Gorman wrote:
> > On Fri, May 01, 2009 at 12:30:03PM +0100, Hugh Dickins wrote:
> > > 
> > > Andrew noticed another oddity: that if it goes the hashdist __vmalloc()
> > > way, it won't be limited by MAX_ORDER.  Makes one wonder whether it
> > > ought to fall back to __vmalloc() if the alloc_pages_exact() fails.
> > 
> > I don't believe so. __vmalloc() is only used when hashdist= is used
> > or on IA-64 (according to the documentation).
> 
> Doc out of date, hashdist's default "on" was extended to include
> x86_64 ages ago, and to all 64-bit in 2.6.30-rc.
> 
> > It is used in the case that the caller is
> > willing to deal with the vmalloc() overhead (e.g. using base page PTEs) in
> > exchange for the pages being interleaved on different nodes so that access
> > to the hash table has average performance[*]
> > 
> > If we automatically fell back to vmalloc(), I bet 2c we'd eventually get
> > a mysterious performance regression report for a workload that depended on
> > the hash tables performance but that there was enough memory for the hash
> > table to be allocated with vmalloc() instead of alloc_pages_exact().
> > 
> > [*] I speculate that on non-IA64 NUMA machines that we see different
> >     performance for large filesystem benchmarks depending on whether we are
> >     running on the boot-CPU node or not depending on whether hashdist=
> >     is used or not.
> 
> Now that will be "32bit NUMA machines".  I was going to say that's
> a tiny sample, but I'm probably out of touch.  I thought NUMA-Q was
> on its way out, but see it still there in the tree.  And presumably
> nowadays there's a great swing to NUMA on Arm or netbooks or something.
> 

NUMA-Q can probably be ignored in terms of relevance but SuperH can have
32-bit NUMA judging from their Kconfig and my understanding is that NUMA is
important to sh in general. I don't know about ARM. Either way, the comment
for HASHDIST_DEFAULT saying that 32-bit NUMA may not have enough vmalloc()
space looks like a good enough reason to avoid dipping into it.

> > > I think that's a change we could make _if_ the large_system_hash
> > > users ever ask for it, but _not_ one we should make surreptitiously.
> > > 
> > 
> > If they want it, they'll have to ask with hashdist=.
> 
> That's quite a good argument for taking it out from under CONFIG_NUMA.
> The name "hashdist" would then be absurd, but we could delight our
> grandchildren with the story of how it came to be so named.
> 

What is the equivalent for "It was a dark and stormy night" for tales
about kernel hacking?

If it was pulled out from underneath, it would need to be for 64-bit-only to
avoid consuming too much vmalloc space but we'd still have no clue though
if the larger hash bucket performance gain (if any) would offset the cost
of using vmalloc.

> > Somehow I doubt it's specified very often :/ .
> 
> Our intuitions match!  Which is probably why it got extended.
> 

No doubt.

> > 
> > Here is Take 2
> > 
> > ==== CUT HERE ====
> > 
> > Use alloc_pages_exact() in alloc_large_system_hash() to avoid duplicated logic V2
> > 
> > alloc_large_system_hash() has logic for freeing pages at the end
> > of an excessively large power-of-two buffer that is a duplicate of what
> > is in alloc_pages_exact(). This patch converts alloc_large_system_hash()
> > to use alloc_pages_exact().
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> Acked-by: Hugh Dickins <hugh@veritas.com>
> 

Thanks.

> > --- 
> >  mm/page_alloc.c |   21 ++++-----------------
> >  1 file changed, 4 insertions(+), 17 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1b3da0f..8360d59 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -4756,26 +4756,13 @@ void *__init alloc_large_system_hash(const char *tablename,
> >  		else if (hashdist)
> >  			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
> >  		else {
> > -			unsigned long order = get_order(size);
> > -
> > -			if (order < MAX_ORDER)
> > -				table = (void *)__get_free_pages(GFP_ATOMIC,
> > -								order);
> >  			/*
> >  			 * If bucketsize is not a power-of-two, we may free
> > -			 * some pages at the end of hash table.
> > +			 * some pages at the end of hash table which
> > +			 * alloc_pages_exact() automatically does
> >  			 */
> > -			if (table) {
> > -				unsigned long alloc_end = (unsigned long)table +
> > -						(PAGE_SIZE << order);
> > -				unsigned long used = (unsigned long)table +
> > -						PAGE_ALIGN(size);
> > -				split_page(virt_to_page(table), order);
> > -				while (used < alloc_end) {
> > -					free_page(used);
> > -					used += PAGE_SIZE;
> > -				}
> > -			}
> > +			if (get_order(size) < MAX_ORDER)
> > +				table = alloc_pages_exact(size, GFP_ATOMIC);
> >  		}
> >  	} while (!table && size > PAGE_SIZE && --log2qty);
> >  
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
