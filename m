Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 768126B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:39:46 -0400 (EDT)
Date: Mon, 24 Sep 2012 10:39:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 8/9] mm: compaction: Cache if a pageblock was scanned and
 no pages were isolated
Message-ID: <20120924093938.GZ11266@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-9-git-send-email-mgorman@suse.de>
 <20120921143656.60a9a6cd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120921143656.60a9a6cd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 02:36:56PM -0700, Andrew Morton wrote:
> On Fri, 21 Sep 2012 11:46:22 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > When compaction was implemented it was known that scanning could potentially
> > be excessive. The ideal was that a counter be maintained for each pageblock
> > but maintaining this information would incur a severe penalty due to a
> > shared writable cache line. It has reached the point where the scanning
> > costs are an serious problem, particularly on long-lived systems where a
> > large process starts and allocates a large number of THPs at the same time.
> > 
> > Instead of using a shared counter, this patch adds another bit to the
> > pageblock flags called PG_migrate_skip. If a pageblock is scanned by
> > either migrate or free scanner and 0 pages were isolated, the pageblock
> > is marked to be skipped in the future. When scanning, this bit is checked
> > before any scanning takes place and the block skipped if set.
> > 
> > The main difficulty with a patch like this is "when to ignore the cached
> > information?" If it's ignored too often, the scanning rates will still
> > be excessive. If the information is too stale then allocations will fail
> > that might have otherwise succeeded. In this patch
> > 
> > o CMA always ignores the information
> > o If the migrate and free scanner meet then the cached information will
> >   be discarded if it's at least 5 seconds since the last time the cache
> >   was discarded
> > o If there are a large number of allocation failures, discard the cache.
> > 
> > The time-based heuristic is very clumsy but there are few choices for a
> > better event. Depending solely on multiple allocation failures still allows
> > excessive scanning when THP allocations are failing in quick succession
> > due to memory pressure. Waiting until memory pressure is relieved would
> > cause compaction to continually fail instead of using reclaim/compaction
> > to try allocate the page. The time-based mechanism is clumsy but a better
> > option is not obvious.
> 
> ick.
> 

I know. I was being generous when I described it as "clumsy".

> Wall time has sooo little relationship to what's happening in there. 
> If we *have* to use polling, cannot we clock the poll with some metric
> which is at least vaguely related to the amount of activity?

Initially I wanted to only depend on just this

        /* Clear pageblock skip if there are numerous alloc failures */
        if (zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT)
                reset_isolation_suitable(zone);

because this it at least related to activity but it's weak for two
reasons. One, it's depending on failures to make the decisions - i.e. when
it already is too late. Two, even this condition can be hit very quickly
and can result in many resets per second in the worst case.

> Number
> (or proportion) of pages scanned, for example?  Or reset everything on
> the Nth trip around the zone? 

For a full compaction failure we have scanned all pages in the zone so
there is no proportion to use there.

Resetting everything every Nth trip around the zone is similar to the
above check except it would look like

if (zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
		zone->compact_reset_laps == COMPACT_MAX_LAPS)
	reset_isolation_suitable(zone)

but it's weak for the same reasons - depending on failures to make decisions
and can happen too quickly.

I also considered using the PGFREE vmstat to reset if a pageblock worth of
pages had been freed since the last reset but this happens very quickly
under memory pressure and would not throttle enough. I also considered
deferring until NR_FREE_PAGES was high enough but this would severely
impact allocation success rates under memory pressure.

> Or even a combination of one of these
> *and* of wall time, so the system will at least work harder when MM is
> under load.
> 

We sortof do that now - we are depending on a number of failures and
time before clearing the bits.

> Also, what has to be done to avoid the polling altogether?  eg/ie, zap
> a pageblock's PB_migrate_skip synchronously, when something was done to
> that pageblock which justifies repolling it?
> 

The "something" event you are looking for is pages being freed or
allocated in the page allocator. A movable page being allocated in block
or a page being freed should clear the PB_migrate_skip bit if it's set.
Unfortunately this would impact the fast path of the alloc and free paths
of the page allocator. I felt that that was too high a price to pay.

> >
> > ...
> >
> > +static void reset_isolation_suitable(struct zone *zone)
> > +{
> > +	unsigned long start_pfn = zone->zone_start_pfn;
> > +	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> > +	unsigned long pfn;
> > +
> > +	/*
> > +	 * Do not reset more than once every five seconds. If allocations are
> > +	 * failing sufficiently quickly to allow this to happen then continually
> > +	 * scanning for compaction is not going to help. The choice of five
> > +	 * seconds is arbitrary but will mitigate excessive scanning.
> > +	 */
> > +	if (time_before(jiffies, zone->compact_blockskip_expire))
> > +		return;
> > +	zone->compact_blockskip_expire = jiffies + (HZ * 5);
> > +
> > +	/* Walk the zone and mark every pageblock as suitable for isolation */
> > +	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
> > +		struct page *page;
> > +		if (!pfn_valid(pfn))
> > +			continue;
> > +
> > +		page = pfn_to_page(pfn);
> > +		if (zone != page_zone(page))
> > +			continue;
> > +
> > +		clear_pageblock_skip(page);
> > +	}
> 
> What's the worst-case loop count here?
> 

zone->spanned_pages >> pageblock_order

> > +}
> > +
> >
> > ...
> >
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
