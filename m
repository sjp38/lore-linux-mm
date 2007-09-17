Subject: Re: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU
	Infrastructure"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0709141537180.14937@schroedinger.engr.sgi.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205438.6536.49500.sendpatchset@localhost>
	 <Pine.LNX.4.64.0709141537180.14937@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 17 Sep 2007 11:17:25 -0400
Message-Id: <1190042245.5460.81.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 15:47 -0700, Christoph Lameter wrote:
> On Fri, 14 Sep 2007, Lee Schermerhorn wrote:
> 
> > 1.  for now, use bit 30 in page flags.  This restricts the no reclaim
> >     infrastructure to 64-bit systems.  [The mlock patch, later in this
> >     series, uses another of these 64-bit-system-only flags.]
> > 
> >     Rationale:  32-bit systems have no free page flags and are less
> >     likely to have the large amounts of memory that exhibit the problems
> >     this series attempts to solve.  [I'm sure someone will disabuse me
> >     of this notion.]
> > 
> >     Thus, NORECLAIM currently depends on [CONFIG_]64BIT.
> 
> Hmmm.. Good a creative solution to the page flag dilemma.

Still not sure I can get away with it tho' :-).

> 
> > +#ifdef CONFIG_NORECLAIM
> > +static inline void
> > +add_page_to_noreclaim_list(struct zone *zone, struct page *page)
> > +{
> > +	add_page_to_lru_list(zone, page, LRU_NORECLAIM);
> > +}
> > +
> > +static inline void
> > +del_page_from_noreclaim_list(struct zone *zone, struct page *page)
> > +{
> > +	del_page_from_lru_list(zone, page, LRU_NORECLAIM);
> > +}
> > +#else
> > +static inline void
> > +add_page_to_noreclaim_list(struct zone *zone, struct page *page) { }
> > +
> > +static inline void
> > +del_page_from_noreclaim_list(struct zone *zone, struct page *page) { }
> > +#endif
> > +
> 
> Do we really need to spell these out separately? 

Well, you left the "{add|del}_page_to_[in]active_list() functions, so I
kept these separate as well.  We could make another cleanup pass and
replace all of these with calls to the "{add|del}_page_to_lru_list()"
functions with the appropriate list enum.  

Also, nothing calls del_page_from_noreclaim_list() right now, so we can
probably lose it.

> 
> > Index: Linux/mm/migrate.c
> > ===================================================================
> > --- Linux.orig/mm/migrate.c	2007-09-14 10:17:54.000000000 -0400
> > +++ Linux/mm/migrate.c	2007-09-14 10:21:48.000000000 -0400
> > @@ -52,13 +52,22 @@ int migrate_prep(void)
> >  	return 0;
> >  }
> >  
> > +/*
> > + * move_to_lru() - place @page onto appropriate lru list
> > + * based on preserved page flags:  active, noreclaim, none
> > + */
> >  static inline void move_to_lru(struct page *page)
> >  {
> > -	if (PageActive(page)) {
> > +	if (PageNoreclaim(page)) {
> > +		VM_BUG_ON(PageActive(page));
> > +		ClearPageNoreclaim(page);
> > +		lru_cache_add_noreclaim(page);
> > +	} else if (PageActive(page)) {
> >  		/*
> >  		 * lru_cache_add_active checks that
> >  		 * the PG_active bit is off.
> >  		 */
> > +		VM_BUG_ON(PageNoreclaim(page));	/* race ? */
> >  		ClearPageActive(page);
> >  		lru_cache_add_active(page);
> >  	} else {
> 
> Could this be unified with the generic LRU handling in mm_inline.h? If you 
> have a function that determines the LRU_xxx from the page flags then you 
> can target the right list by indexing.
> 
> Maybe also create a generic lru_cache_add(page, list) function?

Possibly.  When you created the migration facility, you had these as
separate.  It's still private to migrate.c.  There are a number of
different variants of this.  Here, we put the page back onto the
appropriate list based on the Active|Noreclaim|<none> flag, preserved by
isolate_lru_page().  In mm/mlock.c, I have a similar
function--putback_lru_page() that just clears the flags and calls
lru_cache_add_active_or_noreclaim() to retest page_reclaimable() and
chose the appropriate list.  It never chooses the inactive list, tho'
Maybe that's a mistake?.  

Neither of these is a particularly hot path, I think.  So, maybe we can
come up with one that serves both purposes with a steering argument.
I'd want to test it for performance regression, of course.

> 
> > +	 * Non-reclaimable pages shouldn't make it onto the inactive list,
> > +	 * so if we encounter one, we should be scanning either the active
> > +	 * list--e.g., after splicing noreclaim list to end of active list--
> > +	 * or nearby pages [lumpy reclaim].  Take it only if scanning active
> > +	 * list.
> 
> 
> One fleeting thought here: It may be useful to *not* allocate known 
> unreclaimable pages with __GFP_MOVABLE.

Sorry, I don't understand where you're coming from here.
Non-reclaimable pages should be migratable, but maybe __GFP_MOVABLE
means something else?

> 
> > @@ -670,6 +693,8 @@ int __isolate_lru_page(struct page *page
> >  		ret = 0;
> >  	}
> >  
> > +	if (TestClearPageNoreclaim(page))
> > +		SetPageActive(page);	/* will recheck in shrink_active_list */
> >  	return ret;
> >  }
> 
> Failing to do the isoilation in vmscan.c is not an option?

1) This test doesn't fail the isolation.  It just ensures that the
noreclaim flag is cleared and, if it was set, replaces it with Active.
I think this is OK because I only accept non-reclaimable pages if we're
scanning the active list.  This is in support of splicing the noreclaim
list onto the active list when we want to rescan.  As I mentioned in
mail to Peter, I'm not too happy with this approach--my current
implementation anyway.  Need to revisit/discuss this...

2) Since lumpy reclaim, __isolate_lru_page() CAN return -EBUSY and
isolate_lru_pages() will just stick the page back on the list being
scanned.  We do this if the page state [active/inactive] doesn't match
the isolation "mode"--i.e., when lumpy reclaim is looking for physically
adjacent pages.  I also do this if the page is non-reclaimable and
isolate_lru_pages() doesn't specify that it's OK to take them.  As
mentioned above, it's only OK if we're scanning the active list from
shrink_active_list().  I think this whole thing is fragile--thus my
dissatisfaction...

> 
> > @@ -843,6 +870,8 @@ int isolate_lru_page(struct page *page)
> >  			ClearPageLRU(page);
> >  			if (PageActive(page))
> >  				del_page_from_active_list(zone, page);
> > +			else if (PageNoreclaim(page))
> > +				del_page_from_noreclaim_list(zone, page);
> >  			else
> >  				del_page_from_inactive_list(zone, page);
> >  		}
> 
> Another place where an indexing function from page flags to type of LRU 
> list could simplify code.

Agreed.  Need another pass...

> 
> > @@ -933,14 +962,21 @@ static unsigned long shrink_inactive_lis
> >  			VM_BUG_ON(PageLRU(page));
> >  			SetPageLRU(page);
> >  			list_del(&page->lru);
> > -			add_page_to_lru_list(zone, page, PageActive(page));
> > +			if (PageActive(page)) {
> > +				VM_BUG_ON(PageNoreclaim(page));
> > +				add_page_to_active_list(zone, page);
> > +			} else if (PageNoreclaim(page)) {
> > +				VM_BUG_ON(PageActive(page));
> > +				add_page_to_noreclaim_list(zone, page);
> > +			} else
> > +				add_page_to_inactive_list(zone, page);
> >  			if (!pagevec_add(&pvec, page)) {
> 
> Ditto.
> 
> > +void putback_all_noreclaim_pages(void)
> > +{
> > +	struct zone *zone;
> > +
> > +	for_each_zone(zone) {
> > +		spin_lock(&zone->lru_lock);
> > +
> > +		list_splice(&zone->list[LRU_NORECLAIM],
> > +				&zone->list[LRU_ACTIVE]);
> > +		INIT_LIST_HEAD(&zone->list[LRU_NORECLAIM]);
> > +
> > +		zone_page_state_add(zone_page_state(zone, NR_NORECLAIM), zone,
> > +								NR_ACTIVE);
> > +		atomic_long_set(&zone->vm_stat[NR_NORECLAIM], 0);
> 
> Racy if multiple reclaims are ongoing. Better subtract the value via 
> mod_zone_page_state

OK.  I'll make that change.  But, again, I need to revisit this entire
concept--splicing the noreclaim list back to the active.

Thanks for the review.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
