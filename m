Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 388046B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:02:13 -0400 (EDT)
Date: Tue, 7 Sep 2010 14:01:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] memory hotplug: use unified logic for is_removable
	and offline_pages
Message-ID: <20100907130154.GS8384@csn.ul.ie>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com> <20100906144716.dfd6d536.kamezawa.hiroyu@jp.fujitsu.com> <20100906135822.GM8384@csn.ul.ie> <20100907085836.c3451491.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100907085836.c3451491.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 07, 2010 at 08:58:36AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 6 Sep 2010 14:58:23 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Mon, Sep 06, 2010 at 02:47:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > > 
> > > Now, sysfs interface of memory hotplug shows whether the section is
> > > removable or not. But it checks only migrateype of pages and doesn't
> > > check details of cluster of pages.
> > > 
> > 
> > This was deliberate at the time. The intention was to avoid an expensive
> > linear page scan where possible.
> > 
> 
> > > Next, memory hotplug's set_migratetype_isolate() has the same kind
> > > of check, too. But the migrate-type is just a "hint" and the pageblock
> > > can contain several types of pages if fragmentation is very heavy.
> > > 
> > 
> > If fragmentation is very heavy on a system that requires memory
> > hot-plug, I'd also be checking the value of min_free_kbytes. If it's
> > low, I suggest an init script runs
> > 
> > hugeadm --set-recommended-min_free_kbytes
> > 
> > because it'll keep fragmentation-related events to a minimum. The
> > mm_page_alloc_extfrag tracepoint can be used to measure fragmentation
> > events if you want to see the effect of altering min_free_kbytes like
> > this.
> > 
> 
> Hmm, then what should I do in this patch ? 
> 

Nothing, it's simply an observation that maybe you would like to pass on
to heavy users of memory hot-remove.

> > > To get precise information, we need to check
> > >  - the pageblock only contains free pages or LRU pages.
> > > 
> > > This patch adds the function __count_unmovable_pages() and makes
> > > above 2 checks to use the same logic. This will improve user experience
> > > of memory hotplug because sysfs interface tells accurate information.
> > > 
> > > Note:
> > > it may be better to check MIGRATE_UNMOVABLE for making failure case quick.
> > > 
> > > Changelog: 2010/09/06
> > >  - added comments.
> > >  - removed zone->lock.
> > >  - changed the name of the function to be is_pageblock_removable_async().
> > >    because I removed the zone->lock.
> > > 
> > > Reported-by: Michal Hocko <mhocko@suse.cz>
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > ---
> > >  include/linux/memory_hotplug.h |    1 
> > >  mm/memory_hotplug.c            |   15 -------
> > >  mm/page_alloc.c                |   77 ++++++++++++++++++++++++++++++-----------
> > >  3 files changed, 60 insertions(+), 33 deletions(-)
> > > 
> > > Index: kametest/mm/page_alloc.c
> > > ===================================================================
> > > --- kametest.orig/mm/page_alloc.c
> > > +++ kametest/mm/page_alloc.c
> > > @@ -5274,11 +5274,61 @@ void set_pageblock_flags_group(struct pa
> > >   * page allocater never alloc memory from ISOLATE block.
> > >   */
> > >  
> > > +static int __count_immobile_pages(struct zone *zone, struct page *page)
> > > +{
> > 
> > This will also count RECLAIMABLE pages belonging to some slab objects.
> 
> > These are potentially hot-removable if slab is shrunk. Your function gives a
> > more accurate count but not necessarily a better user-experience with respect
> > to finding sections to hot-remove. You might like to detect PageSlab pages
> > that belong to a RECLAIMABLE slab and not count these as immobile.
> > 
> 
> RECLAIMABLE object is not _always_ reclaimable.
> Should we add "maybe reclaimable" return value ?
> 

Your call but it would seem reasonable. Saying they are certainly not
reclaimable just seems a bit aggressive.

> 
> > 
> > > +	unsigned long pfn, iter, found;
> > > +	/*
> > > +	 * For avoiding noise data, lru_add_drain_all() should be called
> > > + 	 * If ZONE_MOVABLE, the zone never contains immobile pages
> > > + 	 */
> > > +	if (zone_idx(zone) == ZONE_MOVABLE)
> > > +		return 0;
> > > +
> > > +	pfn = page_to_pfn(page);
> > > +	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
> > > +		unsigned long check = pfn + iter;
> > > +
> > > +		if (!pfn_valid_within(check)) {
> > > +			iter++;
> > > +			continue;
> > > +		}
> > > +		page = pfn_to_page(check);
> > > +		if (!page_count(page)) {
> > > +			if (PageBuddy(page))
> > > +				iter += (1 << page_order(page)) - 1;
> > > +			continue;
> > > +		}
> > > +		if (!PageLRU(page))
> > > +			found++;
> > 
> > Arguably, you do not care how many pages there are, you just care if
> > there is one truely unmovable page. If you find one of them, then have
> > this function return fail to avoid the rest of the scan.
> > 
> 
> This is for IBM guys who added stupid notifier for memory hotplug scanning.

I wasn't aware of it, my bad.

> > > <SNIP>
> > >  	pfn = page_to_pfn(page);
> > >  	arg.start_pfn = pfn;
> > > @@ -5315,19 +5360,13 @@ int set_migratetype_isolate(struct page 
> > >  	notifier_ret = notifier_to_errno(notifier_ret);
> > >  	if (notifier_ret)
> > >  		goto out;
> > > +	immobile = __count_immobile_pages(zone ,page);
> > >  
> > > -	for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++) {
> > > -		if (!pfn_valid_within(pfn))
> > > -			continue;
> > > -
> > > -		curr_page = pfn_to_page(iter);
> > > -		if (!page_count(curr_page) || PageLRU(curr_page))
> > > -			continue;
> > > -
> > > -		immobile++;
> > > -	}
> > > -
> > > -	if (arg.pages_found == immobile)
> > > +	/*
> > > +	 * immobile means "not-on-lru" paes. If immobile is larger than
> > > +	 * removable-by-driver pages reported by notifier, we'll fail.
> > > +	 */
> > > +	if (!immobile || arg.pages_found >= immobile)
> > >  		ret = 0;
> > >  
> > 
> > Here is where I'd suggest reimplementing __count_immobile_pages as
> > pageblock_any_immobile() that returns true if it detects an immobile page
> > in a given PFN range.
> > 
>
> How about
> 
> 	__count_immobile_pages(page, count);
> 	returns true if count >= immobile.
> 

If it's returning a boolean, it's no longer a count so the name is
misleading. I think it would be clearer as well to deal with PFN ranges
instead of page -> page+count but maybe that's just me.

> Maybe we can add extention whether we allow RECLAIMABLE pages in the range or not.
> 

Return an enum for each of unmovable, movable_hard, movable_easy maybe where
detecting any RECLAIMABLE page make the pageblock "hard to move".

> 
> > >  out:
> > > Index: kametest/mm/memory_hotplug.c
> > > ===================================================================
> > > --- kametest.orig/mm/memory_hotplug.c
> > > +++ kametest/mm/memory_hotplug.c
> > > @@ -602,27 +602,14 @@ static struct page *next_active_pagebloc
> > >  /* Checks if this range of memory is likely to be hot-removable. */
> > >  int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
> > >  {
> > > -	int type;
> > >  	struct page *page = pfn_to_page(start_pfn);
> > >  	struct page *end_page = page + nr_pages;
> > >  
> > >  	/* Check the starting page of each pageblock within the range */
> > >  	for (; page < end_page; page = next_active_pageblock(page)) {
> > > -		type = get_pageblock_migratetype(page);
> > > -
> > > -		/*
> > > -		 * A pageblock containing MOVABLE or free pages is considered
> > > -		 * removable
> > > -		 */
> > > -		if (type != MIGRATE_MOVABLE && !pageblock_free(page))
> > > +		if (!is_pageblock_removable_async(page))
> > >  			return 0;
> > >  
> > > -		/*
> > > -		 * A pageblock starting with a PageReserved page is not
> > > -		 * considered removable.
> > > -		 */
> > > -		if (PageReserved(page))
> > > -			return 0;
> > >  	}
> > 
> > Bear in mind that a user or bad application constantly reading the sysfs
> > file potentially causes a lot of cache trashing as a result of the
> > linear scan instead of the pageblock type check.
> > 
> yes, hmm. 
> 
> I think there are 3 levels of checking.
> 
>   1. very strict check .... is_removable=true if the range contains only LRU and Free.
>   2. possibility check .... is_removable=true if the range contains LRU, Free, Slab(reclaimable)
>   3. fuzzy check       .... is_removable=true if type = MIGRATABLE. (but very quick.)
> 
> I wonder I should add sysctl (or some memory hotplug control file) and make
> "fuzzy check" as default, which is the same to old behavior.
> 

A sysctl would be racy as would be a hotplug control file. Maybe three
sysfs files for the different levels of checking but allow ordinary users
to only do the "fuzzy" check? The downside is that it'd require application
modification to use the three sysfs files.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
