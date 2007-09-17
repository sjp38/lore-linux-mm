Subject: Re: [PATCH/RFC 5/14] Reclaim Scalability:  Use an indexed array
	for LRU variables
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1190038640.5460.35.camel@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205431.6536.43754.sendpatchset@localhost>
	 <20070917134000.GJ25706@skynet.ie>  <1190038640.5460.35.camel@localhost>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 10:39:36 -0400
Message-Id: <1190039976.5460.44.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 10:17 -0400, Lee Schermerhorn wrote:
> On Mon, 2007-09-17 at 14:40 +0100, Mel Gorman wrote:
> > On (14/09/07 16:54), Lee Schermerhorn didst pronounce:
> > > [PATCH/RFC] 05/15  Reclaim Scalability:   Use an indexed array for LRU variables
> > > 
> > > From clameter@sgi.com Wed Aug 29 11:39:51 2007
> > > 
> <snip>
> > >  
> > >  static inline void
> > >  del_page_from_lru(struct zone *zone, struct page *page)
> > >  {
> > > +	enum lru_list l = LRU_INACTIVE;
> > > +
> > >  	list_del(&page->lru);
> > >  	if (PageActive(page)) {
> > >  		__ClearPageActive(page);
> > >  		__dec_zone_state(zone, NR_ACTIVE);
> > > -	} else {
> > > -		__dec_zone_state(zone, NR_INACTIVE);
> > > +		l = LRU_ACTIVE;
> > >  	}
> > > +	__dec_zone_state(zone, NR_INACTIVE + l);
> > 
> > It looks like you can call __dec_zone_state() twice for active pages
> > here. Was it meant to be?
> > 
> > enum lru_list l = LRU_INACTIVE;
> > 
> > If (PageActive(page)) {
> > 	__ClearPageActive(page);
> > 	l = LRU_INACTIVE;
> > } else {
> > 	l = LRU_ACTIVE;
> > }
> > __dec_zone_state(zone, NR_INACTIVE + l);
> > 
> > ?
> 
> Yes, another botched merge :-(.  This does explain why I'm seeing the
> active memory in meminfo going to zero and staying there after I kill
> off the tests.  

Or maybe not...

> Will fix and retest.

Looks like I fix this in the noreclaim infrastructure patch when I add
in support for non-reclaimable pages.
> 
> It's great to have other eyes looking at these!

But, it's still great to have other eyes...  I will fix up this patch.

> 
> Thanks.
> 
> Lee
> 
> <snip>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
