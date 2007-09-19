Subject: Re: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU
	Infrastructure"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46F0BAF0.2020806@linux.vnet.ibm.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205438.6536.49500.sendpatchset@localhost>
	 <46F0BAF0.2020806@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Wed, 19 Sep 2007 10:47:29 -0400
Message-Id: <1190213249.5301.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-19 at 11:30 +0530, Balbir Singh wrote:
> Lee Schermerhorn wrote:
> > PATCH/RFC 06/14 Reclaim Scalability: "No Reclaim LRU Infrastructure"
> > 
> > Against:  2.6.23-rc4-mm1
> > 
> > Infrastructure to manage pages excluded from reclaim--i.e., hidden
> > from vmscan.  Based on a patch by Larry Woodman of Red Hat. Reworked
> > to maintain "nonreclaimable" pages on a separate per-zone LRU list,
> > to "hide" them from vmscan.  A separate noreclaim pagevec is provided
> > for shrink_active_list() to move nonreclaimable pages to the noreclaim
> > list without over burdening the zone lru_lock.
> > 
> > Pages on the noreclaim list have both PG_noreclaim and PG_lru set.
> > Thus, PG_noreclaim is analogous to and mutually exclusive with
> > PG_active--it specifies which LRU list the page is on.  
> > 
> > The noreclaim infrastructure is enabled by a new mm Kconfig option
> > [CONFIG_]NORECLAIM.
> > 
> 
> Could we use a different name. CONFIG_NORECLAIM could be misunderstood
> to be that reclaim is disabled on the system all together.

Sure.  When this settles down, if something like it gets accepted, we
can choose a different name--if we still want it to be configurable.


<snip>
> > Index: Linux/mm/swap.c
> > ===================================================================
> > --- Linux.orig/mm/swap.c	2007-09-14 10:21:45.000000000 -0400
> > +++ Linux/mm/swap.c	2007-09-14 10:21:48.000000000 -0400
> > @@ -116,14 +116,14 @@ int rotate_reclaimable_page(struct page 
> >  		return 1;
> >  	if (PageDirty(page))
> >  		return 1;
> > -	if (PageActive(page))
> > +	if (PageActive(page) | PageNoreclaim(page))
> 
> Did you intend to make this bitwise or?

Uh, no...  Thanks.  will fix.

> 
> > -	if (PageLRU(page) && !PageActive(page)) {
> > +	if (PageLRU(page) && !PageActive(page) && !PageNoreclaim(page)) {
> 
> Since we use this even below, does it make sense to wrap it into an
> inline function and call it check_page_lru_inactive_reclaimable()?

Perhaps.  But sometimes folks complain that the kernel is programmed in
C not in cpp.   So, I tend to err on the side of open coding..

> 
> 
> >  void lru_add_drain(void)
> > @@ -277,14 +312,18 @@ void release_pages(struct page **pages, 
> > 
> >  		if (PageLRU(page)) {
> >  			struct zone *pagezone = page_zone(page);
> > +			int is_lru_page;
> > +
> >  			if (pagezone != zone) {
> >  				if (zone)
> >  					spin_unlock_irq(&zone->lru_lock);
> >  				zone = pagezone;
> >  				spin_lock_irq(&zone->lru_lock);
> >  			}
> > -			VM_BUG_ON(!PageLRU(page));
> > -			__ClearPageLRU(page);
> > +			is_lru_page = PageLRU(page);
> > +			VM_BUG_ON(!(is_lru_page));
> > +			if (is_lru_page)
> 
> This is a little confusing, after asserting that the page
> is indeed in LRU, why add the check for is_lru_page again?
> Comments will be helpful here.

Not sure why I did this.  Maybe a hold over from previous code.  I'll
check and fix or comment.

> 
> 
> > +#ifdef CONFIG_NORECLAIM
> > +void __pagevec_lru_add_noreclaim(struct pagevec *pvec)
> > +{
> > +	int i;
> > +	struct zone *zone = NULL;
> > +
> > +	for (i = 0; i < pagevec_count(pvec); i++) {
> > +		struct page *page = pvec->pages[i];
> > +		struct zone *pagezone = page_zone(page);
> > +
> > +		if (pagezone != zone) {
> > +			if (zone)
> > +				spin_unlock_irq(&zone->lru_lock);
> > +			zone = pagezone;
> > +			spin_lock_irq(&zone->lru_lock);
> > +		}
> > +		VM_BUG_ON(PageLRU(page));
> > +		SetPageLRU(page);
> 
> > +		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
> > +		SetPageNoreclaim(page);
> > +		add_page_to_noreclaim_list(zone, page);
> 
> These two calls seem to be the only difference between __pagevec_lru_add
> and this routine, any chance we could refactor to reuse most of the
> code? Something like __pagevec_lru_add_prepare(), do the stuff and
> then call __pagevec_lru_add_finish()

Yeah.   There is a lot of duplicated code in the lru pagevec management.
I assumed this was intentional because it's fast path [fault path] code.
As the number of lru lists increases [Rik has a patch to double the
number of active/inactive lists per zone] we may want to factor this
area and the loops at the end of shrink_active_list() that distribute
pages back to the appropriate lists.  Have to be careful of performance
regression, tho'.

> 
> 
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
> 
> I know that lru_cache_add_noreclaim() does the right thing
> by looking at PageNoReclaim(), but the sequence is a little
> confusing to read.

I don't understand your comment.  I was just following the pre-existing
pattern in move_to_lru().  This function just moves pages that have been
isolated for migration back to the appropriate lru list based on the
page flags via the pagevec.  The page flag that determines the
"appropriate list" must be cleared to avoid a VM_BUG_ON later.  The
VM_BUG_ON here is just my paranoia--to ensure that I don't have both
PG_active and PG_noreclaim set at the same time.

> 
> 
> > -int __isolate_lru_page(struct page *page, int mode)
> > +int __isolate_lru_page(struct page *page, int mode, int take_nonreclaimable)
> >  {
> >  	int ret = -EINVAL;
> > 
> > @@ -652,12 +660,27 @@ int __isolate_lru_page(struct page *page
> >  		return ret;
> > 
> >  	/*
> > -	 * When checking the active state, we need to be sure we are
> > -	 * dealing with comparible boolean values.  Take the logical not
> > -	 * of each.
> > +	 * Non-reclaimable pages shouldn't make it onto the inactive list,
> > +	 * so if we encounter one, we should be scanning either the active
> > +	 * list--e.g., after splicing noreclaim list to end of active list--
> > +	 * or nearby pages [lumpy reclaim].  Take it only if scanning active
> > +	 * list.
> >  	 */
> > -	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
> > -		return ret;
> > +	if (PageNoreclaim(page)) {
> > +		if (!take_nonreclaimable)
> > +			return -EBUSY;	/* lumpy reclaim -- skip this page */
> > +		/*
> > +		 * else fall thru' and try to isolate
> > +		 */
> 
> I think we need to distinguish between the types of nonreclaimable
> pages. Is it the heavily mapped pages that you pass on further?
> A casual reader like me finds it hard to understand how lumpy reclaim
> might try to reclaim a non-reclaimable page :-)

If you look at isolate_lru_pages(), after it calls __isolate_lru_page()
to isolate a page off the list that it's scanning, if order is non-zero,
it attempts to isolate other pages that are part of the same higher
order page, w/o regard to what list they're on.  If it succeeded in
taking a non-reclaimable page here, this page would have to be tested
again in shrink_active_list() where it would probably be found to still
be non-reclaimable [but maybe not--more on this below] and we would have
wasted part of this batch.

I explicitly allowed isolating non-reclaimable pages from the active
list, because currently I have a function to splice the zones' noreclaim
lists to the end of the active list for another check for
reclaimability.  This would occur when swap was added, etc.  Note that
when I do take a non-reclaimable page, I reset PG_noreclaim [via
TestClear...] and set PG_active if it was non-reclaimable.

Now, I don't have a feel for how frequent lumpy reclaim will be, but
maybe it's not so bad to just allow non-reclaimable pages to be
unconditionally isolated and rechecked for reclaimability in
shrink_[in]active_list().  Just, need to ensure that the page flags
[active or not] are set correctly depending on which list we're
scanning.

Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
