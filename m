Subject: Re: [patch 1/1] vmscan: give referenced, active and unmapped pages
	a second trip around the LRU
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20070525001812.9dfc972e.akpm@linux-foundation.org>
References: <200705242357.l4ONvw49006681@shell0.pdx.osdl.net>
	 <1180076565.7348.14.camel@twins>
	 <20070525001812.9dfc972e.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Fri, 25 May 2007 09:23:30 +0200
Message-Id: <1180077810.7348.20.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mbligh@mbligh.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-25 at 00:18 -0700, Andrew Morton wrote:
> On Fri, 25 May 2007 09:02:45 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > > +		} else if (TestClearPageReferenced(page)) {
> > > +			list_add(&page->lru, &l_active);
> > > +			continue;
> > >  		}
> > >  		list_add(&page->lru, &l_inactive);
> > >  	}
> > 
> > I myself prefer a patch like this:
> > 
> > ---
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 53ad8ee..5addda9 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -957,16 +957,17 @@ force_reclaim_mapped:
> >  	spin_unlock_irq(&zone->lru_lock);
> >  
> >  	while (!list_empty(&l_hold)) {
> > +		int referenced;
> > +
> >  		cond_resched();
> >  		page = lru_to_page(&l_hold);
> >  		list_del(&page->lru);
> > -		if (page_mapped(page)) {
> > -			if (!reclaim_mapped ||
> > -			    (total_swap_pages == 0 && PageAnon(page)) ||
> > -			    page_referenced(page, 0)) {
> > -				list_add(&page->lru, &l_active);
> > -				continue;
> > -			}
> > +
> > +		referenced = page_referenced(page, 0);
> > +		if (referenced || (page_mapped(page) && !reclaim_mapped) ||
> > +				(total_swap_pages == 0 && PageAnon(page))) {
> > +			list_add(&page->lru, &l_active);
> > +			continue;
> >  		}
> >  		list_add(&page->lru, &l_inactive);
> >  	}
> 
> That does a bit of extra work in the !PageReferenced && !page_mapped case,
> but whatever.
> 
> The question is: what effect does the change have on page reclaim
> effectiveness?   And how much more swappy does it become?  And
> how much more oom-killery?

All very good questions, of which I'd like to know the answers too :-(

I'm sitting on a huge pile of reclaim code, and have no real way of
answering these questions; I did start writing some synthetic benchmark
suite, but never really finished it - perhaps I ought to dive into that
again after OLS.

The trouble I had with the previous patch is that it somehow looks to
PG_referenced but not the PTE state, that seems wrong to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
