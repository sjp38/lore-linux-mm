Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 828466B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:11:05 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r81-v6so26565394pfk.11
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 06:11:05 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c6-v6si1103590pfg.2.2018.10.17.06.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 06:11:03 -0700 (PDT)
Date: Wed, 17 Oct 2018 21:10:59 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20181017131059.GA9167@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
 <20181017104427.GJ5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017104427.GJ5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 11:44:27AM +0100, Mel Gorman wrote:
> On Wed, Oct 17, 2018 at 02:33:27PM +0800, Aaron Lu wrote:
> > Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> > Intel Skylake server showed severe lock contention of zone->lock, as
> > high as about 80%(42% on allocation path and 35% on free path) CPU
> > cycles are burnt spinning. With perf, the most time consuming part inside
> > that lock on free path is cache missing on page structures, mostly on
> > the to-be-freed page's buddy due to merging.
> > 
> 
> This confuses me slightly. The commit log for d8a759b57035 ("mm,
> page_alloc: double zone's batchsize") indicates that the contention for
> will-it-scale moved from the zone lock to the LRU lock. This appears to
> contradict that although the exact test case is different (page_fault_1
> vs page_fault2). Can you clarify why commit d8a759b57035 is
> insufficient?

commit d8a759b57035 helps zone lock scalability and while it reduced
zone lock scalability to some extent(but not entirely eliminated it),
the lock contention shifted to LRU lock in the meantime.

e.g. from commit d8a759b57035's changelog, with the same test case
will-it-scale/page_fault1:

4 sockets Skylake:
    batch   score     change   zone_contention   lru_contention   total_contention
     31   15345900    +0.00%       64%                 8%           72%
     63   17992886   +17.25%       24%                45%           69%

4 sockets Broadwell:
    batch   score     change   zone_contention   lru_contention   total_contention
     31   16703983    +0.00%       67%                 7%           74%
     63   18288885    +9.49%       38%                33%           71%

2 sockets Skylake:
    batch   score     change   zone_contention   lru_contention   total_contention
     31   9554867     +0.00%       66%                 3%           69%
     63   9980145     +4.45%       62%                 4%           66%

Please note that though zone lock contention for the 4 sockets server
reduced a lot with commit d8a759b57035, 2 sockets Skylake still suffered
a lot from zone lock contention even after we doubled batch size.

Also, the reduced zone lock contention will again get worse if LRU lock
is optimized away by Daniel's work, or in cases there are no LRU in the
picture, e.g. an in-kernel user of page allocator like Tariq Toukan
demonstrated with netperf.

> I'm wondering is this really about reducing the number of dirtied cache
> lines due to struct page updates and less about the actual zone lock.

Hmm...if we reduce the time it takes under the zone lock, aren't we
helping the zone lock? :-)

> 
> > One way to avoid this overhead is not do any merging at all for order-0
> > pages. With this approach, the lock contention for zone->lock on free
> > path dropped to 1.1% but allocation side still has as high as 42% lock
> > contention. In the meantime, the dropped lock contention on free side
> > doesn't translate to performance increase, instead, it's consumed by
> > increased lock contention of the per node lru_lock(rose from 5% to 37%)
> > and the final performance slightly dropped about 1%.
> > 
> 
> Although this implies it's really about contention.
> 
> > Though performance dropped a little, it almost eliminated zone lock
> > contention on free path and it is the foundation for the next patch
> > that eliminates zone lock contention for allocation path.
> > 
> 
> Can you clarify whether THP was enabled or not? As this is order-0 focused,
> it would imply the series should have minimal impact due to limited merging.

Sorry about this, I should have mentioned THP is not used here.

> 
> > Suggested-by: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> > ---
> >  include/linux/mm_types.h |  9 +++-
> >  mm/compaction.c          | 13 +++++-
> >  mm/internal.h            | 27 ++++++++++++
> >  mm/page_alloc.c          | 88 ++++++++++++++++++++++++++++++++++------
> >  4 files changed, 121 insertions(+), 16 deletions(-)
> > 
> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > index 5ed8f6292a53..aed93053ef6e 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -179,8 +179,13 @@ struct page {
> >  		int units;			/* SLOB */
> >  	};
> >  
> > -	/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
> > -	atomic_t _refcount;
> > +	union {
> > +		/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
> > +		atomic_t _refcount;
> > +
> > +		/* For pages in Buddy: if skipped merging when added to Buddy */
> > +		bool buddy_merge_skipped;
> > +	};
> >  
> 
> In some instances, bools within structrs are frowned upon because of
> differences in sizes across architectures. Because this is part of a
> union, I don't think it's problematic but bear in mind in case someone
> else spots it.

OK, thanks for the remind.

> 
> >  #ifdef CONFIG_MEMCG
> >  	struct mem_cgroup *mem_cgroup;
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index faca45ebe62d..0c9c7a30dde3 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -777,8 +777,19 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> >  		 * potential isolation targets.
> >  		 */
> >  		if (PageBuddy(page)) {
> > -			unsigned long freepage_order = page_order_unsafe(page);
> > +			unsigned long freepage_order;
> >  
> > +			/*
> > +			 * If this is a merge_skipped page, do merge now
> > +			 * since high-order pages are needed. zone lock
> > +			 * isn't taken for the merge_skipped check so the
> > +			 * check could be wrong but the worst case is we
> > +			 * lose a merge opportunity.
> > +			 */
> > +			if (page_merge_was_skipped(page))
> > +				try_to_merge_page(page);
> > +
> > +			freepage_order = page_order_unsafe(page);
> >  			/*
> >  			 * Without lock, we cannot be sure that what we got is
> >  			 * a valid page order. Consider only values in the
> > diff --git a/mm/internal.h b/mm/internal.h
> > index 87256ae1bef8..c166735a559e 100644
> > --- a/mm/internal.h
> > +++ b/mm/internal.h
> > @@ -527,4 +527,31 @@ static inline bool is_migrate_highatomic_page(struct page *page)
> >  
> >  void setup_zone_pageset(struct zone *zone);
> >  extern struct page *alloc_new_node_page(struct page *page, unsigned long node);
> > +
> > +static inline bool page_merge_was_skipped(struct page *page)
> > +{
> > +	return page->buddy_merge_skipped;
> > +}
> > +
> > +void try_to_merge_page(struct page *page);
> > +
> > +#ifdef CONFIG_COMPACTION
> > +static inline bool can_skip_merge(struct zone *zone, int order)
> > +{
> > +	/* Compaction has failed in this zone, we shouldn't skip merging */
> > +	if (zone->compact_considered)
> > +		return false;
> > +
> > +	/* Only consider no_merge for order 0 pages */
> > +	if (order)
> > +		return false;
> > +
> > +	return true;
> > +}
> > +#else /* CONFIG_COMPACTION */
> > +static inline bool can_skip_merge(struct zone *zone, int order)
> > +{
> > +	return false;
> > +}
> > +#endif  /* CONFIG_COMPACTION */
> >  #endif	/* __MM_INTERNAL_H */
> 
> Strictly speaking, lazy buddy merging does not need to be linked to
> compaction. Lazy merging doesn't say anything about the mobility of
> buddy pages that are still allocated.

True.
I was thinking if compactions isn't enabled, we probably shouldn't
enable this lazy buddy merging feature as it would make high order
allocation success rate dropping a lot.

I probably should have mentioned clearly somewhere in the changelog that
the function of merging those unmerged order0 pages are embedded in
compaction code, in function isolate_migratepages_block() when isolate
candidates are scanned.

> 
> When lazy buddy merging was last examined years ago, a consequence was
> that high-order allocation success rates were reduced. I see you do the

I tried mmtests/stress-highalloc on one desktop and didn't see
high-order allocation success rate dropping as shown in patch0's
changelog. But it could be that I didn't test enough machines or using
other test cases? Any suggestions on how to uncover this problem?

> merging when compaction has been recently considered but I don't see how
> that is sufficient. If a high-order allocation fails, there is no
> guarantee that compaction will find those unmerged buddies. There is

Any unmerged buddies will have page->buddy_merge_skipped set and during
compaction, when isolate_migratepages_block() iterates pages to find
isolate candidates, it will find these unmerged pages and will do_merge()
for them. Suppose an order-9 pageblock, every page is merge_skipped
order-0 page; after isolate_migratepages_block() iterates them one by one
and calls do_merge() for them one by one, higher order page will be
formed during this process and after the last unmerged order0 page goes
through do_merge(), an order-9 buddy page will be formed.

> also no guarantee that a page free will find them. So, in the event of a
> high-order allocation failure, what finds all those unmerged buddies and
> puts them together to see if the allocation would succeed without
> reclaim/compaction/etc.

compaction is needed to form a high-order page after high-order
allocation failed, I think this is also true for vanilla kernel?
