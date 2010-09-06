Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 610206B0078
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 20:03:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8703ggN008141
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Sep 2010 09:03:42 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 546F345DE51
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:03:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B93B45DE4F
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:03:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC1361DB804E
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:03:41 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 82E831DB8054
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:03:41 +0900 (JST)
Date: Tue, 7 Sep 2010 08:58:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] memory hotplug: use unified logic for is_removable
 and offline_pages
Message-Id: <20100907085836.c3451491.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100906135822.GM8384@csn.ul.ie>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
	<20100906144716.dfd6d536.kamezawa.hiroyu@jp.fujitsu.com>
	<20100906135822.GM8384@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Sep 2010 14:58:23 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Mon, Sep 06, 2010 at 02:47:16PM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > Now, sysfs interface of memory hotplug shows whether the section is
> > removable or not. But it checks only migrateype of pages and doesn't
> > check details of cluster of pages.
> > 
> 
> This was deliberate at the time. The intention was to avoid an expensive
> linear page scan where possible.
> 

> > Next, memory hotplug's set_migratetype_isolate() has the same kind
> > of check, too. But the migrate-type is just a "hint" and the pageblock
> > can contain several types of pages if fragmentation is very heavy.
> > 
> 
> If fragmentation is very heavy on a system that requires memory
> hot-plug, I'd also be checking the value of min_free_kbytes. If it's
> low, I suggest an init script runs
> 
> hugeadm --set-recommended-min_free_kbytes
> 
> because it'll keep fragmentation-related events to a minimum. The
> mm_page_alloc_extfrag tracepoint can be used to measure fragmentation
> events if you want to see the effect of altering min_free_kbytes like
> this.
> 

Hmm, then what should I do in this patch ? 

> > To get precise information, we need to check
> >  - the pageblock only contains free pages or LRU pages.
> > 
> > This patch adds the function __count_unmovable_pages() and makes
> > above 2 checks to use the same logic. This will improve user experience
> > of memory hotplug because sysfs interface tells accurate information.
> > 
> > Note:
> > it may be better to check MIGRATE_UNMOVABLE for making failure case quick.
> > 
> > Changelog: 2010/09/06
> >  - added comments.
> >  - removed zone->lock.
> >  - changed the name of the function to be is_pageblock_removable_async().
> >    because I removed the zone->lock.
> > 
> > Reported-by: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memory_hotplug.h |    1 
> >  mm/memory_hotplug.c            |   15 -------
> >  mm/page_alloc.c                |   77 ++++++++++++++++++++++++++++++-----------
> >  3 files changed, 60 insertions(+), 33 deletions(-)
> > 
> > Index: kametest/mm/page_alloc.c
> > ===================================================================
> > --- kametest.orig/mm/page_alloc.c
> > +++ kametest/mm/page_alloc.c
> > @@ -5274,11 +5274,61 @@ void set_pageblock_flags_group(struct pa
> >   * page allocater never alloc memory from ISOLATE block.
> >   */
> >  
> > +static int __count_immobile_pages(struct zone *zone, struct page *page)
> > +{
> 
> This will also count RECLAIMABLE pages belonging to some slab objects.

> These are potentially hot-removable if slab is shrunk. Your function gives a
> more accurate count but not necessarily a better user-experience with respect
> to finding sections to hot-remove. You might like to detect PageSlab pages
> that belong to a RECLAIMABLE slab and not count these as immobile.
> 

RECLAIMABLE object is not _always_ reclaimable.
Should we add "maybe reclaimable" return value ?


> 
> > +	unsigned long pfn, iter, found;
> > +	/*
> > +	 * For avoiding noise data, lru_add_drain_all() should be called
> > + 	 * If ZONE_MOVABLE, the zone never contains immobile pages
> > + 	 */
> > +	if (zone_idx(zone) == ZONE_MOVABLE)
> > +		return 0;
> > +
> > +	pfn = page_to_pfn(page);
> > +	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
> > +		unsigned long check = pfn + iter;
> > +
> > +		if (!pfn_valid_within(check)) {
> > +			iter++;
> > +			continue;
> > +		}
> > +		page = pfn_to_page(check);
> > +		if (!page_count(page)) {
> > +			if (PageBuddy(page))
> > +				iter += (1 << page_order(page)) - 1;
> > +			continue;
> > +		}
> > +		if (!PageLRU(page))
> > +			found++;
> 
> Arguably, you do not care how many pages there are, you just care if
> there is one truely unmovable page. If you find one of them, then have
> this function return fail to avoid the rest of the scan.
> 

This is for IBM guys who added stupid notifier for memory hotplug scanning.
Hmm, ok, I'll add some trick.


> > +		/*
> > +		 * If the page is not RAM, page_count()should be 0.
> > +		 * we don't need more check. This is an _used_ not-movable page.
> > +		 *
> > +		 * The problematic thing here is PG_reserved pages. PG_reserved
> > +		 * is set to both of a memory hole page and a _used_ kernel
> > +		 * page at boot.
> > +		 */
> > +	}
> > +	return found;
> > +}
> > +
> > +bool is_pageblock_removable_async(struct page *page)
> > +{
> > +	struct zone *zone = page_zone(page);
> > +	unsigned long flags;
> > +	int num;
> > +	/* Don't take zone->lock interntionally. */
> 
> intentionally?
> 
yes. typo.

> > +	num = __count_immobile_pages(zone, page);
> > +
> > +	if (num)
> > +		return false;
> > +	return true;
> > +}
> > +
> >  int set_migratetype_isolate(struct page *page)
> >  {
> >  	struct zone *zone;
> > -	struct page *curr_page;
> > -	unsigned long flags, pfn, iter;
> > +	unsigned long flags, pfn;
> >  	unsigned long immobile = 0;
> >  	struct memory_isolate_notify arg;
> >  	int notifier_ret;
> > @@ -5289,11 +5339,6 @@ int set_migratetype_isolate(struct page 
> >  	zone_idx = zone_idx(zone);
> >  
> >  	spin_lock_irqsave(&zone->lock, flags);
> > -	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
> > -	    zone_idx == ZONE_MOVABLE) {
> > -		ret = 0;
> > -		goto out;
> > -	}
> >  
> 
> This will result in more scanning and a potentially more expensive
> memory hot-remove operation. I'm not massively concerned as such because
> memory hot-remove is not cheap but it's worth mentioning in the
> changelog that this is a consequence.
> 
Okay.


> >  	pfn = page_to_pfn(page);
> >  	arg.start_pfn = pfn;
> > @@ -5315,19 +5360,13 @@ int set_migratetype_isolate(struct page 
> >  	notifier_ret = notifier_to_errno(notifier_ret);
> >  	if (notifier_ret)
> >  		goto out;
> > +	immobile = __count_immobile_pages(zone ,page);
> >  
> > -	for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++) {
> > -		if (!pfn_valid_within(pfn))
> > -			continue;
> > -
> > -		curr_page = pfn_to_page(iter);
> > -		if (!page_count(curr_page) || PageLRU(curr_page))
> > -			continue;
> > -
> > -		immobile++;
> > -	}
> > -
> > -	if (arg.pages_found == immobile)
> > +	/*
> > +	 * immobile means "not-on-lru" paes. If immobile is larger than
> > +	 * removable-by-driver pages reported by notifier, we'll fail.
> > +	 */
> > +	if (!immobile || arg.pages_found >= immobile)
> >  		ret = 0;
> >  
> 
> Here is where I'd suggest reimplementing __count_immobile_pages as
> pageblock_any_immobile() that returns true if it detects an immobile page
> in a given PFN range.
> 
How about

	__count_immobile_pages(page, count);
	returns true if count >= immobile.

Maybe we can add extention whether we allow RECLAIMABLE pages in the range or not.


> >  out:
> > Index: kametest/mm/memory_hotplug.c
> > ===================================================================
> > --- kametest.orig/mm/memory_hotplug.c
> > +++ kametest/mm/memory_hotplug.c
> > @@ -602,27 +602,14 @@ static struct page *next_active_pagebloc
> >  /* Checks if this range of memory is likely to be hot-removable. */
> >  int is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
> >  {
> > -	int type;
> >  	struct page *page = pfn_to_page(start_pfn);
> >  	struct page *end_page = page + nr_pages;
> >  
> >  	/* Check the starting page of each pageblock within the range */
> >  	for (; page < end_page; page = next_active_pageblock(page)) {
> > -		type = get_pageblock_migratetype(page);
> > -
> > -		/*
> > -		 * A pageblock containing MOVABLE or free pages is considered
> > -		 * removable
> > -		 */
> > -		if (type != MIGRATE_MOVABLE && !pageblock_free(page))
> > +		if (!is_pageblock_removable_async(page))
> >  			return 0;
> >  
> > -		/*
> > -		 * A pageblock starting with a PageReserved page is not
> > -		 * considered removable.
> > -		 */
> > -		if (PageReserved(page))
> > -			return 0;
> >  	}
> 
> Bear in mind that a user or bad application constantly reading the sysfs
> file potentially causes a lot of cache trashing as a result of the
> linear scan instead of the pageblock type check.
> 
yes, hmm. 

I think there are 3 levels of checking.

  1. very strict check .... is_removable=true if the range contains only LRU and Free.
  2. possibility check .... is_removable=true if the range contains LRU, Free, Slab(reclaimable)
  3. fuzzy check       .... is_removable=true if type = MIGRATABLE. (but very quick.)

I wonder I should add sysctl (or some memory hotplug control file) and make
"fuzzy check" as default, which is the same to old behavior.

Any idea ?


Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
