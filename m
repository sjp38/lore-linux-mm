Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 97D6E6B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 10:08:09 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2611782pwi.14
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 07:08:06 -0700 (PDT)
Date: Mon, 6 Jun 2011 23:07:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110606140756.GD1686@barrios-laptop>
References: <20110531143830.GC13418@barrios-laptop>
 <20110602182302.GA2802@random.random>
 <20110602202156.GA23486@barrios-laptop>
 <20110602214041.GF2802@random.random>
 <BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
 <20110602223201.GH2802@random.random>
 <BANLkTikA+ugFNS95Zs_o6QqG2u4r2g93=Q@mail.gmail.com>
 <20110603173707.GL2802@random.random>
 <20110603180730.GM2802@random.random>
 <20110606103216.GC5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110606103216.GC5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 06, 2011 at 11:32:16AM +0100, Mel Gorman wrote:
> On Fri, Jun 03, 2011 at 08:07:30PM +0200, Andrea Arcangeli wrote:
> > On Fri, Jun 03, 2011 at 07:37:07PM +0200, Andrea Arcangeli wrote:
> > > On Fri, Jun 03, 2011 at 08:01:44AM +0900, Minchan Kim wrote:
> > > > Do you want this? (it's almost pseudo-code)
> > > 
> > > Yes that's good idea so we at least take into account if we isolated
> > > something big, and it's pointless to insist wasting CPU on the tail
> > > pages and even trace a fail because of tail pages after it.
> > > 
> > > I introduced a __page_count to increase readability. It's still
> > > hackish to work on subpages in vmscan.c but at least I added a comment
> > > and until we serialize destroy_compound_page vs compound_head, I guess
> > > there's no better way. I didn't attempt to add out of order
> > > serialization similar to what exists for split_huge_page vs
> > > compound_trans_head yet, as the page can be allocated or go away from
> > > under us, in split_huge_page vs compound_trans_head it's simpler
> > > because both callers are required to hold a pin on the page so the
> > > page can't go be reallocated and destroyed under it.
> > 
> > Sent too fast... had to shuffle a few things around... trying again.
> > 
> > ===
> > Subject: mm: no page_count without a page pin
> > 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > It's unsafe to run page_count during the physical pfn scan because
> > compound_head could trip on a dangling pointer when reading page->first_page if
> > the compound page is being freed by another CPU. Also properly take into
> > account if we isolated a compound page during the scan and break the loop if
> > we've isolated enoguh. Introduce __page_count to cleanup some atomic_read from
> > &page->_count in common code to cleanup.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> This patch is pulling in stuff from Minchan. Minimally his patch should
> be kept separate to preserve history or his Signed-off should be
> included on this patch.
> 
> > ---
> >  arch/powerpc/mm/gup.c                        |    2 -
> >  arch/powerpc/platforms/512x/mpc512x_shared.c |    2 -
> >  arch/x86/mm/gup.c                            |    2 -
> >  fs/nilfs2/page.c                             |    2 -
> >  include/linux/mm.h                           |   13 ++++++----
> >  mm/huge_memory.c                             |    4 +--
> >  mm/internal.h                                |    2 -
> >  mm/page_alloc.c                              |    6 ++--
> >  mm/swap.c                                    |    4 +--
> >  mm/vmscan.c                                  |   35 ++++++++++++++++++++-------
> >  10 files changed, 47 insertions(+), 25 deletions(-)
> > 
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1047,7 +1047,7 @@ static unsigned long isolate_lru_pages(u
> >  	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> >  		struct page *page;
> >  		unsigned long pfn;
> > -		unsigned long end_pfn;
> > +		unsigned long start_pfn, end_pfn;
> >  		unsigned long page_pfn;
> >  		int zone_id;
> >  
> > @@ -1087,9 +1087,9 @@ static unsigned long isolate_lru_pages(u
> >  		 */
> >  		zone_id = page_zone_id(page);
> >  		page_pfn = page_to_pfn(page);
> > -		pfn = page_pfn & ~((1 << order) - 1);
> > -		end_pfn = pfn + (1 << order);
> > -		for (; pfn < end_pfn; pfn++) {
> > +		start_pfn = page_pfn & ~((1 << order) - 1);
> > +		end_pfn = start_pfn + (1 << order);
> > +		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> >  			struct page *cursor_page;
> >  
> >  			/* The target page is in the block, ignore it. */
> > @@ -1116,16 +1116,33 @@ static unsigned long isolate_lru_pages(u
> >  				break;
> >  
> >  			if (__isolate_lru_page(cursor_page, mode, file) == 0) {
> > +				unsigned int isolated_pages;
> >  				list_move(&cursor_page->lru, dst);
> >  				mem_cgroup_del_lru(cursor_page);
> > -				nr_taken += hpage_nr_pages(page);
> > -				nr_lumpy_taken++;
> > +				isolated_pages = hpage_nr_pages(page);
> > +				nr_taken += isolated_pages;
> > +				nr_lumpy_taken += isolated_pages;
> >  				if (PageDirty(cursor_page))
> > -					nr_lumpy_dirty++;
> > +					nr_lumpy_dirty += isolated_pages;
> >  				scan++;
> > +				pfn += isolated_pages-1;
> 
> Ah, here is the isolated_pages - 1 which is necessary. Should have read
> the whole thread before responding to anything :).
> 
> I still think this optimisation is rare and only applies if we are
> encountering huge pages during the linear scan. How often are we doing
> that really?
> 
> > +				VM_BUG_ON(!isolated_pages);
> 
> This BUG_ON is overkill. hpage_nr_pages would have to return 0.
> 
> > +				VM_BUG_ON(isolated_pages > MAX_ORDER_NR_PAGES);
> 
> This would require order > MAX_ORDER_NR_PAGES to be passed into
> isolate_lru_pages or for a huge page to be unaligned to a power of
> two. The former is very unlikely and the latter is not supported by
> any CPU.
> 
> >  			} else {
> > -				/* the page is freed already. */
> > -				if (!page_count(cursor_page))
> > +				/*
> > +				 * Check if the page is freed already.
> > +				 *
> > +				 * We can't use page_count() as that
> > +				 * requires compound_head and we don't
> > +				 * have a pin on the page here. If a
> > +				 * page is tail, we may or may not
> > +				 * have isolated the head, so assume
> > +				 * it's not free, it'd be tricky to
> > +				 * track the head status without a
> > +				 * page pin.
> > +				 */
> > +				if (!PageTail(cursor_page) &&
> > +				    !__page_count(cursor_page))
> >  					continue;
> >  				break;
> 
> Ack to this part.
> 
> I'm not keen on __page_count() as __ normally means the "unlocked"
> version of a function although I realise that rule isn't universal

Yes. It's not univeral.
I have thought about it as it's just private function or utility function
(ie, not-exportable).
So I don't mind the name.

> either. I can't think of a better name though.

Me, too.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
