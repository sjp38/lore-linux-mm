Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DA7636B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 11:22:06 -0400 (EDT)
Date: Wed, 7 Apr 2010 16:21:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/14] Memory compaction core
Message-ID: <20100407152139.GQ17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-9-git-send-email-mel@csn.ul.ie> <20100406170551.cb4a0a8e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170551.cb4a0a8e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:51PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:42 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This patch is the core of a mechanism which compacts memory in a zone by
> > relocating movable pages towards the end of the zone.
> > 
> > A single compaction run involves a migration scanner and a free scanner.
> > Both scanners operate on pageblock-sized areas in the zone. The migration
> > scanner starts at the bottom of the zone and searches for all movable pages
> > within each area, isolating them onto a private list called migratelist.
> > The free scanner starts at the top of the zone and searches for suitable
> > areas and consumes the free pages within making them available for the
> > migration scanner. The pages isolated for migration are then migrated to
> > the newly isolated free pages.
> > 
> >
> > ...
> >
> > --- /dev/null
> > +++ b/include/linux/compaction.h
> > @@ -0,0 +1,9 @@
> > +#ifndef _LINUX_COMPACTION_H
> > +#define _LINUX_COMPACTION_H
> > +
> > +/* Return values for compact_zone() */
> > +#define COMPACT_INCOMPLETE	0
> > +#define COMPACT_PARTIAL		1
> > +#define COMPACT_COMPLETE	2
> 
> Confused.  "incomplete" and "partial" are synonyms.  Please fully
> document these here.
> 

I have a difficultly in that it's hard to give you fixes as it would
span two patches. It might be easiest on you overall if you so a

s/COMPACT_INCOMPLETE/COMPACT_CONTINUE/

on both this patch and the direct compaction patch. I'll then send a follow-on
patch documenting the four defines (later patch adds a fourth) as

/* Return values for compact_zone() and try_to_compact_pages() */

/* compaction didn't start as it was not possible or direct reclaim was more suitable */
#define COMPACT_SKIPPED         0

/* compaction should continue to another pageblock */
#define COMPACT_CONTINUE        1

/* direct compaction partially compacted a zone and there are suitable pages */
#define COMPACT_PARTIAL         2

/* The full zone was compacted */
#define COMPACT_COMPLETE        3

> > +#endif /* _LINUX_COMPACTION_H */
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index f3b473a..f920815 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -335,6 +335,7 @@ void put_page(struct page *page);
> >  void put_pages_list(struct list_head *pages);
> >  
> >  void split_page(struct page *page, unsigned int order);
> > +int split_free_page(struct page *page);
> >  
> >  /*
> >   * Compound pages have a destructor function.  Provide a
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 986b12d..cf8bba7 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -151,6 +151,7 @@ enum {
> >  };
> >  
> >  #define SWAP_CLUSTER_MAX 32
> > +#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
> 
> Why? 

To reduce the amount of time zone locks are held.

> What are the implications of this decision? 

Pro: Latencies are lower, fewer pages are isolated at any given time
Con: There is a wider window during which a parallel allocator can use a
     page within the pageblock being compacted

> How was it arrived at? 

It's somewhat arbitrary, only that reclaim works on similar units and
they share logic on what the correct number of pages to have isolated
from the LRU lists are.

> What might one expect if one were to alter COMPACT_CLUSTER_MAX?
> 

The higher the value, the longer the latency is that the lock is held
during isolation but under very heavy memory pressure, there might be
higher success rates for allocation as the window during which parallel
allocators can allocate pages being compacted is reduced.

The lower the value, the lower the time the lock is held. Fewer pages
will be isolated at any given time.

The only advantage of either choice is increasing the value makes it
less likely a parallel allocator will interfere but it had to be
balanced against the lock hold latency time. As we appear to be ok with
the hold time for reclaim, it was reasonable to assume we'd also be ok
with the hold time for compaction.

> >  #define SWAP_MAP_MAX	0x3e	/* Max duplication count, in first swap_map */
> >  #define SWAP_MAP_BAD	0x3f	/* Note pageblock is bad, in first swap_map */
> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> > index 117f0dd..56e4b44 100644
> > --- a/include/linux/vmstat.h
> > +++ b/include/linux/vmstat.h
> > @@ -43,6 +43,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
> >  		KSWAPD_SKIP_CONGESTION_WAIT,
> >  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> > +		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
> >  #ifdef CONFIG_HUGETLB_PAGE
> >  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
> >  #endif
> > diff --git a/mm/Makefile b/mm/Makefile
> > index 7a68d2a..ccb1f72 100644
> > --- a/mm/Makefile
> > +++ b/mm/Makefile
> >
> > ...
> >
> > +static int release_freepages(struct list_head *freelist)
> > +{
> > +	struct page *page, *next;
> > +	int count = 0;
> > +
> > +	list_for_each_entry_safe(page, next, freelist, lru) {
> > +		list_del(&page->lru);
> > +		__free_page(page);
> > +		count++;
> > +	}
> > +
> > +	return count;
> > +}
> 
> I'm kinda surprised that we don't already have a function to do this.
> 

Subsystems needing lists of free pages would be using mempools.

> An `unsigned' return value would make more sense.  Perhaps even
> `unsigned long', unless there's something else here which would prevent
> that absurd corner-case.
> 

Included in the patch below. The corner-case is impossible. We're
isolating only COMPACT_CLUSTER_MAX and this must be less than
MAX_ORDER_NR_PAGES. However, the return value of the function is used with
an unsigned long.  Technically, it could be unsigned int but page counts
are always in unsigned long so why be surprising.

> > +/* Isolate free pages onto a private freelist. Must hold zone->lock */
> > +static int isolate_freepages_block(struct zone *zone,
> > +				unsigned long blockpfn,
> > +				struct list_head *freelist)
> > +{
> > +	unsigned long zone_end_pfn, end_pfn;
> > +	int total_isolated = 0;
> > +
> > +	/* Get the last PFN we should scan for free pages at */
> > +	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> > +	end_pfn = blockpfn + pageblock_nr_pages;
> > +	if (end_pfn > zone_end_pfn)
> > +		end_pfn = zone_end_pfn;
> 
> 	end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
> 
> I find that easier to follow, dunno how others feel.
> 

It looks better. Done.

> > +	/* Isolate free pages. This assumes the block is valid */
> 
> What does "This assumes the block is valid" mean?  The code checks
> pfn_valid_within()..
> 

Typically, a MAX_ORDER_NR_PAGES naturally-aligned block of pages is
considered valid if any one of them return true for pfn_valid(). The
caller of this function has checked the block with pfn_valid so the
block of pages is "valid".

Some architectures insist on punching holes within a block of
MAX_ORDER_NR_PAGES. These are required to call pfn_valid_within() when
walking a range of PFNs. For architectures without these holes,
pfn_valid_within() is a no-op.

> > +	for (; blockpfn < end_pfn; blockpfn++) {
> > +		struct page *page;
> > +		int isolated, i;
> > +
> > +		if (!pfn_valid_within(blockpfn))
> > +			continue;
> > +
> > +		page = pfn_to_page(blockpfn);
> 
> hm.  pfn_to_page() isn't exactly cheap in some memory models.  I wonder
> if there was some partial result we could have locally cached across
> the entire loop.
> 

Ordinarily, a PFN walker is required to use pfn_to_page() in case it crosses
something like a sparsemem boundary (assuming no VMEMMAP) where there may
be no relationship between the PFN and the struct page location.

In this specific case though, we are within a MAX_ORDER_NR_PAGES block
so it's safe to cache the struct page assuming nothing crazy is
introduced by a memory model.

Done.

> > +		if (!PageBuddy(page))
> > +			continue;
> > +
> > +		/* Found a free page, break it into order-0 pages */
> > +		isolated = split_free_page(page);
> > +		total_isolated += isolated;
> > +		for (i = 0; i < isolated; i++) {
> > +			list_add(&page->lru, freelist);
> > +			page++;
> > +		}
> > +
> > +		/* If a page was split, advance to the end of it */
> > +		if (isolated)
> > +			blockpfn += isolated - 1;
> > +	}
> 
> Strange.  Having just busted a pageblock_order-sized higher-order page
> into order-0 pages

The page being broken up could be any size. It's not necessarily related
to pageblocks.

> , the loop goes on and inspects the remaining
> (1-2^pageblock_order) pages, presumably to no effect.  Perhaps
> 
> 	for (; blockpfn < end_pfn; blockpfn++) {
> 
> should be
> 
> 	for (; blockpfn < end_pfn; blockpfn += pageblock_nr_pages) {
> 
> or somesuch.
> 

That's what the code marked with "If a page was split, advance to the
end of it" is for. It knows how to advance to the end of the buddy page
without accidentally skipping over a page.

> btw, is the whole pageblock_order thing as sucky as it seems?  If I
> want my VM to be oriented to making order-4-skb-allocations work, I
> need to tune it that way, to coopt something the hugepage fetishists
> added?  What if I need order-4 skb's _and_ hugepages?
> 

It's easiest to consider migrating pages to and from in ranges of pageblocks
because that is the granularity anti-frag works on. There is very little gained
by considering a lower boundary. With direct compaction, compact_finished()
is checking on a regular basis whether it's ok to finish compaction early
because the caller is satisified.

At worst at the moment, more of a pageblock gets compacted than potentially
necessary for an order-4 allocation to succeed. Specifically, one pageblock
will get fully compacted even though only a small amount of it may have been
required. It'd be possible to do such an optimisation, but it'll be a
micro-optimisation and will obscure the logic somewhat.

> > +	return total_isolated;
> > +}
> > +
> > +/* Returns 1 if the page is within a block suitable for migration to */
> > +static int suitable_migration_target(struct page *page)
> 
> `bool'?
> 

Ok.

> > +{
> > +
> > +	int migratetype = get_pageblock_migratetype(page);
> > +
> > +	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
> > +	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
> > +		return 0;
> > +
> > +	/* If the page is a large free page, then allow migration */
> > +	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> > +		return 1;
> > +
> > +	/* If the block is MIGRATE_MOVABLE, allow migration */
> > +	if (migratetype == MIGRATE_MOVABLE)
> > +		return 1;
> > +
> > +	/* Otherwise skip the block */
> > +	return 0;
> > +}
> > +
> > +/*
> > + * Based on information in the current compact_control, find blocks
> > + * suitable for isolating free pages from
> 
> "and then isolate them"?
> 

Correct.

> > + */
> > +static void isolate_freepages(struct zone *zone,
> > +				struct compact_control *cc)
> > +{
> > +	struct page *page;
> > +	unsigned long high_pfn, low_pfn, pfn;
> > +	unsigned long flags;
> > +	int nr_freepages = cc->nr_freepages;
> > +	struct list_head *freelist = &cc->freepages;
> > +
> > +	pfn = cc->free_pfn;
> > +	low_pfn = cc->migrate_pfn + pageblock_nr_pages;
> > +	high_pfn = low_pfn;
> > +
> > +	/*
> > +	 * Isolate free pages until enough are available to migrate the
> > +	 * pages on cc->migratepages. We stop searching if the migrate
> > +	 * and free page scanners meet or enough free pages are isolated.
> > +	 */
> > +	spin_lock_irqsave(&zone->lock, flags);
> > +	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
> > +					pfn -= pageblock_nr_pages) {
> > +		int isolated;
> > +
> > +		if (!pfn_valid(pfn))
> > +			continue;
> > +
> > +		/* 
> > +		 * Check for overlapping nodes/zones. It's possible on some
> > +		 * configurations to have a setup like
> > +		 * node0 node1 node0
> > +		 * i.e. it's possible that all pages within a zones range of
> > +		 * pages do not belong to a single zone.
> > +		 */
> > +		page = pfn_to_page(pfn);
> > +		if (page_zone(page) != zone)
> > +			continue;
> 
> Well.  This code checks each pfn it touches, but
> isolate_freepages_block() doesn't do this - isolate_freepages_block()
> happily blunders across a contiguous span of pageframes, assuming that
> all those pages are valid, and within the same zone.
> 

This is walking in strides of pageblock_nr_pages. You only have to call
pfn_valid() once for MAX_ORDER_NR_PAGES but if walking the PFNs within
the block, pfn_valid_within() must be called for each one.

Granted, pageblock_nr_pages != MAX_ORDER_NR_PAGES, but it'd be little
more than a micro-optimisation to identify exactly when the boundary was
crossed and call pfn_valid() a few times less.

> > +		/* Check the block is suitable for migration */
> > +		if (!suitable_migration_target(page))
> > +			continue;
> > +
> > +		/* Found a block suitable for isolating free pages from */
> > +		isolated = isolate_freepages_block(zone, pfn, freelist);
> > +		nr_freepages += isolated;
> > +
> > +		/*
> > +		 * Record the highest PFN we isolated pages from. When next
> > +		 * looking for free pages, the search will restart here as
> > +		 * page migration may have returned some pages to the allocator
> > +		 */
> > +		if (isolated)
> > +			high_pfn = max(high_pfn, pfn);
> > +	}
> > +	spin_unlock_irqrestore(&zone->lock, flags);
> 
> For how long can this loop hold of interrupts?
> 

Absolute worst case, until it reaches the location of the migration
scanner. As we are isolating pages for migration in units of 32 pages,
it seems unlikely that the migration and free page scanner would be a
substantial difference apart without 32 free pages between them.

> > +	cc->free_pfn = high_pfn;
> > +	cc->nr_freepages = nr_freepages;
> > +}
> > +
> > +/* Update the number of anon and file isolated pages in the zone */
> > +static void acct_isolated(struct zone *zone, struct compact_control *cc)
> > +{
> > +	struct page *page;
> > +	unsigned int count[NR_LRU_LISTS] = { 0, };
> > +
> > +	list_for_each_entry(page, &cc->migratepages, lru) {
> > +		int lru = page_lru_base_type(page);
> > +		count[lru]++;
> > +	}
> > +
> > +	cc->nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
> > +	cc->nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
> > +	__mod_zone_page_state(zone, NR_ISOLATED_ANON, cc->nr_anon);
> > +	__mod_zone_page_state(zone, NR_ISOLATED_FILE, cc->nr_file);
> > +}
> > +
> > +/* Similar to reclaim, but different enough that they don't share logic */
> 
> yeah, but what does it do?
> 

hint is in the name. It tells you if there are "too many pages
isolated". Included in the patch below.

> > +static int too_many_isolated(struct zone *zone)
> > +{
> > +
> > +	unsigned long inactive, isolated;
> > +
> > +	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
> > +					zone_page_state(zone, NR_INACTIVE_ANON);
> > +	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
> > +					zone_page_state(zone, NR_ISOLATED_ANON);
> > +
> > +	return isolated > inactive;
> > +}
> > +
> > +/*
> > + * Isolate all pages that can be migrated from the block pointed to by
> > + * the migrate scanner within compact_control.
> > + */
> > +static unsigned long isolate_migratepages(struct zone *zone,
> > +					struct compact_control *cc)
> > +{
> > +	unsigned long low_pfn, end_pfn;
> > +	struct list_head *migratelist;
> > +
> > +	low_pfn = cc->migrate_pfn;
> > +	migratelist = &cc->migratepages;
> > +
> > +	/* Do not scan outside zone boundaries */
> > +	if (low_pfn < zone->zone_start_pfn)
> > +		low_pfn = zone->zone_start_pfn;
> 
> Can this happen?
> 

Unlikely, but yes.

> Use max()?
> 

Done, in the first follow-on patch.

> > +	/* Setup to scan one block but not past where we are migrating to */
> 
> what?
> 

What indeed. Changed to "Only scan within a pageblock boundary"

> > +	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
> > +
> > +	/* Do not cross the free scanner or scan within a memory hole */
> > +	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
> > +		cc->migrate_pfn = end_pfn;
> > +		return 0;
> > +	}
> > +
> > +	/* Do not isolate the world */
> 
> Needs (much) more explanation, please.
> 

        /*
         * Ensure that there are not too many pages isolated from the LRU
         * list by either parallel reclaimers or compaction. If there are,
         * delay for some time until fewer pages are isolated
         */

> > +	while (unlikely(too_many_isolated(zone))) {
> > +		congestion_wait(BLK_RW_ASYNC, HZ/10);
> 
> ... why did it do this?  Quite a head-scratcher.
> 

The expected cause of too many pages being isolated is parallel reclaimers. Too
many pages isolated implies pages are being cleaned so wait for a period of
time or until IO congestion clears to try again.

> > +		if (fatal_signal_pending(current))
> > +			return 0;
> > +	}
> > +
> > +	/* Time to isolate some pages for migration */
> > +	spin_lock_irq(&zone->lru_lock);
> > +	for (; low_pfn < end_pfn; low_pfn++) {
> > +		struct page *page;
> > +		if (!pfn_valid_within(low_pfn))
> > +			continue;
> > +
> > +		/* Get the page and skip if free */
> > +		page = pfn_to_page(low_pfn);
> > +		if (PageBuddy(page)) {
> > +			low_pfn += (1 << page_order(page)) - 1;
> > +			continue;
> > +		}
> > +
> > +		/* Try isolate the page */
> > +		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
> > +			del_page_from_lru_list(zone, page, page_lru(page));
> > +			list_add(&page->lru, migratelist);
> > +			mem_cgroup_del_lru(page);
> > +			cc->nr_migratepages++;
> > +		}
> > +
> > +		/* Avoid isolating too much */
> > +		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
> > +			break;
> 
> This test could/should be moved inside the preceding `if' block.  Or,
> better, simply do
> 
> 		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
> 			continue;	/* comment goes here */
> 

Done.

> > +	}
> > +
> > +	acct_isolated(zone, cc);
> > +
> > +	spin_unlock_irq(&zone->lru_lock);
> > +	cc->migrate_pfn = low_pfn;
> > +
> > +	return cc->nr_migratepages;
> > +}
> > +
> > +/*
> > + * This is a migrate-callback that "allocates" freepages by taking pages
> > + * from the isolated freelists in the block we are migrating to.
> > + */
> > +static struct page *compaction_alloc(struct page *migratepage,
> > +					unsigned long data,
> > +					int **result)
> > +{
> > +	struct compact_control *cc = (struct compact_control *)data;
> > +	struct page *freepage;
> > +
> > +	/* Isolate free pages if necessary */
> > +	if (list_empty(&cc->freepages)) {
> > +		isolate_freepages(cc->zone, cc);
> > +
> > +		if (list_empty(&cc->freepages))
> > +			return NULL;
> > +	}
> > +
> > +	freepage = list_entry(cc->freepages.next, struct page, lru);
> > +	list_del(&freepage->lru);
> > +	cc->nr_freepages--;
> > +
> > +	return freepage;
> > +}
> > +
> > +/*
> > + * We cannot control nr_migratepages and nr_freepages fully when migration is
> > + * running as migrate_pages() has no knowledge of compact_control. When
> > + * migration is complete, we count the number of pages on the lists by hand.
> > + */
> > +static void update_nr_listpages(struct compact_control *cc)
> > +{
> > +	int nr_migratepages = 0;
> > +	int nr_freepages = 0;
> > +	struct page *page;
> 
> newline here please.
> 

Done

> > +	list_for_each_entry(page, &cc->migratepages, lru)
> > +		nr_migratepages++;
> > +	list_for_each_entry(page, &cc->freepages, lru)
> > +		nr_freepages++;
> > +
> > +	cc->nr_migratepages = nr_migratepages;
> > +	cc->nr_freepages = nr_freepages;
> > +}
> > +
> > +static inline int compact_finished(struct zone *zone,
> > +						struct compact_control *cc)
> > +{
> > +	if (fatal_signal_pending(current))
> > +		return COMPACT_PARTIAL;
> 
> ah-hah!  So maybe we meant COMPACT_INTERRUPTED.
> 

No, although an interruption can be reason for a partial competion. In this
particular case, it's unfortunate because the caller is unlikely to get
the page requested but it also has received a fatal signal so it probably
doesn't care.

> > +	/* Compaction run completes if the migrate and free scanner meet */
> > +	if (cc->free_pfn <= cc->migrate_pfn)
> > +		return COMPACT_COMPLETE;
> > +
> > +	return COMPACT_INCOMPLETE;
> > +}
> > +
> > +static int compact_zone(struct zone *zone, struct compact_control *cc)
> > +{
> > +	int ret = COMPACT_INCOMPLETE;
> > +
> > +	/* Setup to move all movable pages to the end of the zone */
> > +	cc->migrate_pfn = zone->zone_start_pfn;
> > +	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
> > +	cc->free_pfn &= ~(pageblock_nr_pages-1);
> 
> If zone->spanned_pages is much much larger than zone->present_pages,
> this code will suck rather a bit.  Is there a reason why that can never
> happen?
> 

No reason why it can't happen but it's mitigated by only checking one PFN
per pageblock_nr_pages to see if it is valid in isolate_migratepages().

> > +	migrate_prep();
> > +
> > +	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
> 
> <stares at that for a while>
> 
> Perhaps
> 
> 	while ((ret = compact_finished(zone, cc)) == COMPACT_INCOMPLETE) {
> 
> would be clearer.  That would make the definition-site initialisation
> of `ret' unneeded too.
> 

True.

> > +		unsigned long nr_migrate, nr_remaining;
> 
> newline please.
> 

Done.

> > +		if (!isolate_migratepages(zone, cc))
> > +			continue;
> 
> Boy, this looks like an infinite loop waiting to happen. Are you sure?

Yes, compact_finished() has all the exit conditions.

> Suppose we hit a pageblock-sized string of !pfn_valid() pfn's,
> for example. 

Then the migrate scanner will eventually reach the free scanner and it
will exit.

> Worried.
> 

Can you spot a corner case that is not covered by compact_finished() ?

> > +		nr_migrate = cc->nr_migratepages;
> > +		migrate_pages(&cc->migratepages, compaction_alloc,
> > +						(unsigned long)cc, 0);
> > +		update_nr_listpages(cc);
> > +		nr_remaining = cc->nr_migratepages;
> > +
> > +		count_vm_event(COMPACTBLOCKS);
> > +		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
> > +		if (nr_remaining)
> > +			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
> > +
> > +		/* Release LRU pages not migrated */
> > +		if (!list_empty(&cc->migratepages)) {
> > +			putback_lru_pages(&cc->migratepages);
> > +			cc->nr_migratepages = 0;
> > +		}
> > +
> > +	}
> > +
> > +	/* Release free pages and check accounting */
> > +	cc->nr_freepages -= release_freepages(&cc->freepages);
> > +	VM_BUG_ON(cc->nr_freepages != 0);
> > +
> > +	return ret;
> > +}
> > +
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 624cba4..3cf947d 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1208,6 +1208,45 @@ void split_page(struct page *page, unsigned int order)
> >  }
> >  
> >  /*
> > + * Similar to split_page except the page is already free. As this is only
> > + * being used for migration, the migratetype of the block also changes.
> > + */
> > +int split_free_page(struct page *page)
> > +{
> > +	unsigned int order;
> > +	unsigned long watermark;
> > +	struct zone *zone;
> > +
> > +	BUG_ON(!PageBuddy(page));
> > +
> > +	zone = page_zone(page);
> > +	order = page_order(page);
> > +
> > +	/* Obey watermarks or the system could deadlock */
> > +	watermark = low_wmark_pages(zone) + (1 << order);
> > +	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> > +		return 0;
> 
> OK, there is no way in which the code-reader can work out why this is
> here.  What deadlock?
> 

It's a general comment on watermarks. Allocators shouldn't allow the
watermarks to be breached so that there are always pages for things like
TIF_MEMDIE. Changed the comment to 

	/* Obey watermarks as if the page was being allocated */

> > +	/* Remove page from free list */
> > +	list_del(&page->lru);
> > +	zone->free_area[order].nr_free--;
> > +	rmv_page_order(page);
> > +	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> > +
> > +	/* Split into individual pages */
> > +	set_page_refcounted(page);
> > +	split_page(page, order);
> > +
> > +	if (order >= pageblock_order - 1) {
> > +		struct page *endpage = page + (1 << order) - 1;
> > +		for (; page < endpage; page += pageblock_nr_pages)
> > +			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> > +	}
> > +
> > +	return 1 << order;
> > +}
> > +
> > +/*
> >   * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
> >   * we cheat by calling it from here, in the order > 0 path.  Saves a branch
> >   * or two.
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 351e491..3a69b48 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -892,6 +892,11 @@ static const char * const vmstat_text[] = {
> >  	"allocstall",
> >  
> >  	"pgrotated",
> > +
> > +	"compact_blocks_moved",
> > +	"compact_pages_moved",
> > +	"compact_pagemigrate_failed",
> 
> Should we present these on CONFIG_COMPACTION=n kernels?
> 

To do it would require changes to direct compaction as well. I'll do it
as a patch on top of the series as an incremental change to this patch
will be a mess.

> Does all this code really need to iterate across individual pfn's like
> this?  We can use the buddy structures to go straight to all of a
> zone's order-N free pages, can't we?  Wouldn't that save a whole heap
> of fruitless linear searching?
> 

You could do as you suggest, but it's would not reduce scanning. If anything,
it will increase it.

The objective is to move pages into the smallest number of pageblocks. For
that, we want all the free pages within a given range no matter what their
current order in the free lists are. Doing what you suggest would involve
scanning the buddy lists which is potentially more pages than a linear scan
of a range.

Here is a roll-up of the suggestions you made

==== CUT HERE ====
mm,compaction: Various fixes to the patch 'Memory compaction core'

 o Have CONFIG_COMPACTION depend on HUGETLB_PAGE instead of HUGETLBFS
 o Use unsigned long instead of int for page counters
 o Simplify logic in isolate_freepages_block() and isolate_migratepages()
 o Optimise isolate_freepages_block to use a cursor
 o Use bool instead of int for true/false
 o Clarify some comments
 o Improve control flow in isolate_migratepages()
 o Add newlines for clarity
 o Simply loop in compact_zones

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/Kconfig      |    2 +-
 mm/compaction.c |   81 +++++++++++++++++++++++++++++++-----------------------
 mm/page_alloc.c |    2 +-
 3 files changed, 48 insertions(+), 37 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 4fd75a0..a275a7d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -177,7 +177,7 @@ config COMPACTION
 	bool "Allow for memory compaction"
 	def_bool y
 	select MIGRATION
-	depends on EXPERIMENTAL && HUGETLBFS && MMU
+	depends on EXPERIMENTAL && HUGETLB_PAGE && MMU
 	help
 	  Allows the compaction of memory for the allocation of huge pages.
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 3bb65d7..38b54e2 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -40,10 +40,10 @@ struct compact_control {
 	struct zone *zone;
 };
 
-static int release_freepages(struct list_head *freelist)
+static unsigned long release_freepages(struct list_head *freelist)
 {
 	struct page *page, *next;
-	int count = 0;
+	unsigned long count = 0;
 
 	list_for_each_entry_safe(page, next, freelist, lru) {
 		list_del(&page->lru);
@@ -55,28 +55,33 @@ static int release_freepages(struct list_head *freelist)
 }
 
 /* Isolate free pages onto a private freelist. Must hold zone->lock */
-static int isolate_freepages_block(struct zone *zone,
+static unsigned long isolate_freepages_block(struct zone *zone,
 				unsigned long blockpfn,
 				struct list_head *freelist)
 {
 	unsigned long zone_end_pfn, end_pfn;
 	int total_isolated = 0;
+	struct page *cursor;
 
 	/* Get the last PFN we should scan for free pages at */
 	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
-	end_pfn = blockpfn + pageblock_nr_pages;
-	if (end_pfn > zone_end_pfn)
-		end_pfn = zone_end_pfn;
+	end_pfn = min(blockpfn + pageblock_nr_pages, zone_end_pfn);
 
-	/* Isolate free pages. This assumes the block is valid */
+	/* Find the first usable PFN in the block to initialse page cursor */
 	for (; blockpfn < end_pfn; blockpfn++) {
-		struct page *page;
+		if (pfn_valid_within(blockpfn))
+			break;
+	}
+	cursor = pfn_to_page(blockpfn);
+
+	/* Isolate free pages. This assumes the block is valid */
+	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
 		int isolated, i;
+		struct page *page = cursor;
 
 		if (!pfn_valid_within(blockpfn))
 			continue;
 
-		page = pfn_to_page(blockpfn);
 		if (!PageBuddy(page))
 			continue;
 
@@ -89,38 +94,40 @@ static int isolate_freepages_block(struct zone *zone,
 		}
 
 		/* If a page was split, advance to the end of it */
-		if (isolated)
+		if (isolated) {
 			blockpfn += isolated - 1;
+			cursor += isolated - 1;
+		}
 	}
 
 	return total_isolated;
 }
 
-/* Returns 1 if the page is within a block suitable for migration to */
-static int suitable_migration_target(struct page *page)
+/* Returns true if the page is within a block suitable for migration to */
+static bool suitable_migration_target(struct page *page)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
 
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
-		return 0;
+		return false;
 
 	/* If the page is a large free page, then allow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return 1;
+		return true;
 
 	/* If the block is MIGRATE_MOVABLE, allow migration */
 	if (migratetype == MIGRATE_MOVABLE)
-		return 1;
+		return true;
 
 	/* Otherwise skip the block */
-	return 0;
+	return false;
 }
 
 /*
  * Based on information in the current compact_control, find blocks
- * suitable for isolating free pages from
+ * suitable for isolating free pages from and then isolate them.
  */
 static void isolate_freepages(struct zone *zone,
 				struct compact_control *cc)
@@ -143,7 +150,7 @@ static void isolate_freepages(struct zone *zone,
 	spin_lock_irqsave(&zone->lock, flags);
 	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
 					pfn -= pageblock_nr_pages) {
-		int isolated;
+		unsigned long isolated;
 
 		if (!pfn_valid(pfn))
 			continue;
@@ -199,7 +206,7 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */
-static int too_many_isolated(struct zone *zone)
+static bool too_many_isolated(struct zone *zone)
 {
 
 	unsigned long inactive, isolated;
@@ -220,16 +227,12 @@ static unsigned long isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
 	unsigned long low_pfn, end_pfn;
-	struct list_head *migratelist;
-
-	low_pfn = cc->migrate_pfn;
-	migratelist = &cc->migratepages;
+	struct list_head *migratelist = &cc->migratepages;
 
 	/* Do not scan outside zone boundaries */
-	if (low_pfn < zone->zone_start_pfn)
-		low_pfn = zone->zone_start_pfn;
+	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
 
-	/* Setup to scan one block but not past where we are migrating to */
+	/* Only scan within a pageblock boundary */
 	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
 
 	/* Do not cross the free scanner or scan within a memory hole */
@@ -238,7 +241,11 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		return 0;
 	}
 
-	/* Do not isolate the world */
+	/*
+	 * Ensure that there are not too many pages isolated from the LRU
+	 * list by either parallel reclaimers or compaction. If there are,
+	 * delay for some time until fewer pages are isolated
+	 */
 	while (unlikely(too_many_isolated(zone))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
@@ -261,12 +268,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		}
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
-			del_page_from_lru_list(zone, page, page_lru(page));
-			list_add(&page->lru, migratelist);
-			mem_cgroup_del_lru(page);
-			cc->nr_migratepages++;
-		}
+		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
+			continue;
+
+		/* Successfully isolated */
+		del_page_from_lru_list(zone, page, page_lru(page));
+		list_add(&page->lru, migratelist);
+		mem_cgroup_del_lru(page);
+		cc->nr_migratepages++;
 
 		/* Avoid isolating too much */
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
@@ -317,6 +326,7 @@ static void update_nr_listpages(struct compact_control *cc)
 	int nr_migratepages = 0;
 	int nr_freepages = 0;
 	struct page *page;
+
 	list_for_each_entry(page, &cc->migratepages, lru)
 		nr_migratepages++;
 	list_for_each_entry(page, &cc->freepages, lru)
@@ -362,7 +372,7 @@ static int compact_finished(struct zone *zone,
 
 static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
-	int ret = COMPACT_INCOMPLETE;
+	int ret;
 
 	/* Setup to move all movable pages to the end of the zone */
 	cc->migrate_pfn = zone->zone_start_pfn;
@@ -371,8 +381,9 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 	migrate_prep();
 
-	for (; ret == COMPACT_INCOMPLETE; ret = compact_finished(zone, cc)) {
+	while ((ret = compact_finished(zone, cc)) == COMPACT_INCOMPLETE) {
 		unsigned long nr_migrate, nr_remaining;
+
 		if (!isolate_migratepages(zone, cc))
 			continue;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 66823bd..08b6306 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1223,7 +1223,7 @@ int split_free_page(struct page *page)
 	zone = page_zone(page);
 	order = page_order(page);
 
-	/* Obey watermarks or the system could deadlock */
+	/* Obey watermarks as if the page was being allocated */
 	watermark = low_wmark_pages(zone) + (1 << order);
 	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
