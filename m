Date: Mon, 8 Sep 2008 16:14:13 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 1/4] pull out the page pre-release and sanity check
	logic for reuse
Message-ID: <20080908151413.GB9190@brain>
References: <1220610002-18415-1-git-send-email-apw@shadowen.org> <1220610002-18415-2-git-send-email-apw@shadowen.org> <44c63dc40809080711v98f4fdbs19081aa7cb81634d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44c63dc40809080711v98f4fdbs19081aa7cb81634d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <barrioskmc@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 08, 2008 at 11:11:22PM +0900, MinChan Kim wrote:
> On Fri, Sep 5, 2008 at 7:19 PM, Andy Whitcroft <apw@shadowen.org> wrote:
> > When we are about to release a page we perform a number of actions
> > on that page.  We clear down any anonymous mappings, confirm that
> > the page is safe to release, check for freeing locks, before mapping
> > the page should that be required.  Pull this processing out into a
> > helper function for reuse in a later patch.
> >
> > Note that we do not convert the similar cleardown in free_hot_cold_page()
> > as the optimiser is unable to squash the loops during the inline.
> >
> > Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> > Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> > ---
> >  mm/page_alloc.c |   43 ++++++++++++++++++++++++++++++-------------
> >  1 files changed, 30 insertions(+), 13 deletions(-)
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index f52fcf1..b2a2c2b 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -489,6 +489,35 @@ static inline int free_pages_check(struct page *page)
> >  }
> >
> >  /*
> > + * Prepare this page for release to the buddy.  Sanity check the page.
> > + * Returns 1 if the page is safe to free.
> > + */
> > +static inline int free_page_prepare(struct page *page, int order)
> > +{
> > +       int i;
> > +       int reserved = 0;
> > +
> > +       if (PageAnon(page))
> > +               page->mapping = NULL;
> 
> Why do you need to clear down anonymous mapping ?
> I think if you don't convert this cleardown in free_hot_cold_page(),
> you don't need it.
> 
> If you do it, bad_page can't do his role.

Yeah that has slipped through from where originally this patch used to
merge two different instances of this code.  Good spot.  Will sort that
out.

> > +       for (i = 0 ; i < (1 << order) ; ++i)
> > +               reserved += free_pages_check(page + i);
> > +       if (reserved)
> > +               return 0;
> > +
> > +       if (!PageHighMem(page)) { > > +               debug_check_no_locks_freed(page_address(page),
> > +                                                       PAGE_SIZE << order);
> > +               debug_check_no_obj_freed(page_address(page),
> > +                                          PAGE_SIZE << order);
> > +       }
> > +       arch_free_page(page, order);
> > +       kernel_map_pages(page, 1 << order, 0);
> > +
> > +       return 1;
> > +}
> > +
> > +/*
> >  * Frees a list of pages.
> >  * Assumes all pages on list are in same zone, and of same order.
> >  * count is the number of pages to free.
> > @@ -529,22 +558,10 @@ static void free_one_page(struct zone *zone, struct page *page, int order)
> >  static void __free_pages_ok(struct page *page, unsigned int order)
> >  {
> >        unsigned long flags;
> > -       int i;
> > -       int reserved = 0;
> >
> > -       for (i = 0 ; i < (1 << order) ; ++i)
> > -               reserved += free_pages_check(page + i);
> > -       if (reserved)
> > +       if (!free_page_prepare(page, order))
> >                return;
> >
> > -       if (!PageHighMem(page)) {
> > -               debug_check_no_locks_freed(page_address(page),PAGE_SIZE<<order);
> > -               debug_check_no_obj_freed(page_address(page),
> > -                                          PAGE_SIZE << order);
> > -       }
> > -       arch_free_page(page, order);
> > -       kernel_map_pages(page, 1 << order, 0);
> > -
> >        local_irq_save(flags);
> >        __count_vm_events(PGFREE, 1 << order);
> >        free_one_page(page_zone(page), page, order);

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
