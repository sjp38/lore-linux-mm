Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BBAC56B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:30:24 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:30:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 09/25] Calculate the migratetype for allocation only
	once
Message-ID: <20090421103048.GQ12713@csn.ul.ie>
References: <20090421160729.F136.A69D9226@jp.fujitsu.com> <20090421083513.GC12713@csn.ul.ie> <20090421191344.F162.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090421191344.F162.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 21, 2009 at 07:19:00PM +0900, KOSAKI Motohiro wrote:
> > On Tue, Apr 21, 2009 at 04:37:28PM +0900, KOSAKI Motohiro wrote:
> > > > GFP mask is converted into a migratetype when deciding which pagelist to
> > > > take a page from. However, it is happening multiple times per
> > > > allocation, at least once per zone traversed. Calculate it once.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > > ---
> > > >  mm/page_alloc.c |   43 ++++++++++++++++++++++++++-----------------
> > > >  1 files changed, 26 insertions(+), 17 deletions(-)
> > > > 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index b27bcde..f960cf5 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -1065,13 +1065,13 @@ void split_page(struct page *page, unsigned int order)
> > > >   * or two.
> > > >   */
> > > >  static struct page *buffered_rmqueue(struct zone *preferred_zone,
> > > > -			struct zone *zone, int order, gfp_t gfp_flags)
> > > > +			struct zone *zone, int order, gfp_t gfp_flags,
> > > > +			int migratetype)
> > > >  {
> > > >  	unsigned long flags;
> > > >  	struct page *page;
> > > >  	int cold = !!(gfp_flags & __GFP_COLD);
> > > >  	int cpu;
> > > > -	int migratetype = allocflags_to_migratetype(gfp_flags);
> > > 
> > > hmmm....
> > > 
> > > allocflags_to_migratetype() is very cheap function and buffered_rmqueue()
> > > and other non-inline static function isn't guranteed inlined.
> > > 
> > 
> > A later patch makes them inlined due to the fact there is only one call
> > site.
> 
> Oh, I see.
> I drop my claim. thanks.
> 
> > > -------------------------------------------------------------------
> > > /* Convert GFP flags to their corresponding migrate type */
> > > static inline int allocflags_to_migratetype(gfp_t gfp_flags)
> > > {
> > >         WARN_ON((gfp_flags & GFP_MOVABLE_MASK) == GFP_MOVABLE_MASK);
> > > 
> > >         if (unlikely(page_group_by_mobility_disabled))
> > >                 return MIGRATE_UNMOVABLE;
> > > 
> > >         /* Group based on mobility */
> > >         return (((gfp_flags & __GFP_MOVABLE) != 0) << 1) |
> > >                 ((gfp_flags & __GFP_RECLAIMABLE) != 0);
> > > }
> > > -------------------------------------------------------------------
> > > 
> > > s/WARN_ON/VM_BUG_ON/ is better?
> > > 
> > 
> > I wanted to catch out-of-tree drivers but it's been a while so maybe VM_BUG_ON
> > wouldn't hurt. I can add a patch that does that a pass 2 of improving the
> > allocator or would you prefer to see it now?
> 
> no. another patch is better :)
> 
> 
> > > GFP_MOVABLE_MASK makes 3. 3 mean MIGRATE_RESERVE. it seems obviously bug.
> > > 
> > 
> > Short answer;
> > No, GFP flags that result in MIGRATE_RESERVE is a bug. The caller should
> > never want to be allocating from there.
> > 
> > Longer answer;
> > The size of the MIGRATE_RESERVE depends on the number of free pages that
> > must be kept in the zone. Because GFP flags never result in here, the
> > area is only used when the alternative is to fail the allocation and the
> > watermarks are still met. The intention is that high-order atomic
> > allocations that were short lived may be allocated from here. This was
> > to preserve a behaviour in the allocator before MIGRATE_RESERVE was
> > introduced. It makes no sense for a caller to allocate directly out of
> > here and in fact the fallback list for MIGRATE_RESERVE are useless
> 
> Yeah.
> My past mail is too poor. I agree it is caller's bug.
> I mean VM_BUG_ON is better because
>   - obviously caller bug 
>   - VM_BUG_ON is no runtime impact when VM_DEBUG is off.
> 

Ah, I misread what you were saying. This is certainly a caller bug and I
think it's safe to change it to a VM_BUG_ON() at this stage. I've taken
note to do a patch to that effect in a later patch series.

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
