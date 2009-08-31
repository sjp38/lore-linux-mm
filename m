Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 26ED36B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 08:11:50 -0400 (EDT)
Date: Mon, 31 Aug 2009 13:11:53 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] page-allocator: Maintain rolling count of pages to
	free from the PCP
Message-ID: <20090831121153.GD29627@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie> <1251449067-3109-3-git-send-email-mel@csn.ul.ie> <28c262360908280804r4c40c7baw7bb535dd8c275960@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360908280804r4c40c7baw7bb535dd8c275960@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 29, 2009 at 12:04:48AM +0900, Minchan Kim wrote:
> 
> On Fri, Aug 28, 2009 at 5:44 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> > When round-robin freeing pages from the PCP lists, empty lists may be
> > encountered. In the event one of the lists has more pages than another,
> > there may be numerous checks for list_empty() which is undesirable. This
> > patch maintains a count of pages to free which is incremented when empty
> > lists are encountered. The intention is that more pages will then be freed
> > from fuller lists than the empty ones reducing the number of empty list
> > checks in the free path.
> >
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/page_alloc.c |   23 ++++++++++++++---------
> >  1 files changed, 14 insertions(+), 9 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 65eedb5..9b86977 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -536,32 +536,37 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >                                        struct per_cpu_pages *pcp)
> >  {
> >        int migratetype = 0;
> > +       int batch_free = 0;
> >
> >        spin_lock(&zone->lock);
> >        zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> >        zone->pages_scanned = 0;
> >
> >        __mod_zone_page_state(zone, NR_FREE_PAGES, count);
> > -       while (count--) {
> > +       while (count) {
> >                struct page *page;
> >                struct list_head *list;
> >
> >                /*
> > -                * Remove pages from lists in a round-robin fashion. This spinning
> > -                * around potentially empty lists is bloody awful, alternatives that
> > -                * don't suck are welcome
> > +                * Remove pages from lists in a round-robin fashion. A batch_free
> > +                * count is maintained that is incremented when an empty list is
> > +                * encountered. This is so more pages are freed off fuller lists
> > +                * instead of spinning excessively around empty lists
> >                 */
> >                do {
> > +                       batch_free++;
> >                        if (++migratetype == MIGRATE_PCPTYPES)
> >                                migratetype = 0;
> >                        list = &pcp->lists[migratetype];
> >                } while (list_empty(list));
> 
> How about increasing the weight by batch_free ?
> 
> batch_free = 1 << (batch_free - 1);
> 
> It's assumed that if batch_free is big, it means
> there are contiguous empty lists.
> Then it is likely to need more time to refill empty lists than
> one list refill. So I think it can decrease spinning empty list
> a little more.
> 

Maybe. As it is, the list spinning is not too bad and significant
amounts of time are no longer being spent in there. I've taken note to
follow-up and investigate your suggestion to see if it works out and if
it makes a difference.

Thanks

> >
> > -               page = list_entry(list->prev, struct page, lru);
> > -               /* have to delete it as __free_one_page list manipulates */
> > -               list_del(&page->lru);
> > -               trace_mm_page_pcpu_drain(page, 0, migratetype);
> > -               __free_one_page(page, zone, 0, migratetype);
> > +               do {
> > +                       page = list_entry(list->prev, struct page, lru);
> > +                       /* must delete as __free_one_page list manipulates */
> > +                       list_del(&page->lru);
> > +                       __free_one_page(page, zone, 0, migratetype);
> > +                       trace_mm_page_pcpu_drain(page, 0, migratetype);
> > +               } while (--count && --batch_free && !list_empty(list));
> >        }
> >        spin_unlock(&zone->lock);
> >  }
> > --
> > 1.6.3.3
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
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
