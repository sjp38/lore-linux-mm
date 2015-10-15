Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EDBD96B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 02:02:29 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so77210947pab.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 23:02:29 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id uh5si19076218pab.115.2015.10.14.23.02.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 23:02:29 -0700 (PDT)
Date: Thu, 15 Oct 2015 15:03:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 9/9] mm/compaction: new threshold for compaction
 depleted zone
Message-ID: <20151015060317.GC7566@js1304-P5Q-DELUXE>
References: <1440382773-16070-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1440382773-16070-10-git-send-email-iamjoonsoo.kim@lge.com>
 <561E4A6F.5070801@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561E4A6F.5070801@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

On Wed, Oct 14, 2015 at 02:28:31PM +0200, Vlastimil Babka wrote:
> On 08/24/2015 04:19 AM, Joonsoo Kim wrote:
> > Now, compaction algorithm become powerful. Migration scanner traverses
> > whole zone range. So, old threshold for depleted zone which is designed
> > to imitate compaction deferring approach isn't appropriate for current
> > compaction algorithm. If we adhere to current threshold, 1, we can't
> > avoid excessive overhead caused by compaction, because one compaction
> > for low order allocation would be easily successful in any situation.
> > 
> > This patch re-implements threshold calculation based on zone size and
> > allocation requested order. We judge whther compaction possibility is
> > depleted or not by number of successful compaction. Roughly, 1/100
> > of future scanned area should be allocated for high order page during
> > one comaction iteration in order to determine whether zone's compaction
> > possiblity is depleted or not.
> 
> Finally finishing my review, sorry it took that long...
> 
> > Below is test result with following setup.
> > 
> > Memory is artificially fragmented to make order 3 allocation hard. And,
> > most of pageblocks are changed to movable migratetype.
> > 
> >   System: 512 MB with 32 MB Zram
> >   Memory: 25% memory is allocated to make fragmentation and 200 MB is
> >   	occupied by memory hogger. Most pageblocks are movable
> >   	migratetype.
> >   Fragmentation: Successful order 3 allocation candidates may be around
> >   	1500 roughly.
> >   Allocation attempts: Roughly 3000 order 3 allocation attempts
> >   	with GFP_NORETRY. This value is determined to saturate allocation
> >   	success.
> > 
> > Test: hogger-frag-movable
> > 
> > Success(N)                    94              83
> > compact_stall               3642            4048
> > compact_success              144             212
> > compact_fail                3498            3835
> > pgmigrate_success       15897219          216387
> > compact_isolated        31899553          487712
> > compact_migrate_scanned 59146745         2513245
> > compact_free_scanned    49566134         4124319
> 
> The decrease in scanned/isolated/migrated counts looks definitely nice, but why
> did success regress when compact_success improved substantially?

I don't know exact reason. I guess that more compaction success rate
comes from the fact that async compaction is stopped when depleted.
This compact_success metric doesn't fully reflect allocation success because
allocation success comes from not only compaction but also reclaim and
others. In the above test, compaction just succeed 200 times but
allocation succeed more than 1300 times.

> 
> > This change results in greatly decreasing compaction overhead when
> > zone's compaction possibility is nearly depleted. But, I should admit
> > that it's not perfect because compaction success rate is decreased.
> > More precise tuning threshold would restore this regression, but,
> > it highly depends on workload so I'm not doing it here.
> > 
> > Other test doesn't show big regression.
> > 
> >   System: 512 MB with 32 MB Zram
> >   Memory: 25% memory is allocated to make fragmentation and kernel
> >   	build is running on background. Most pageblocks are movable
> >   	migratetype.
> >   Fragmentation: Successful order 3 allocation candidates may be around
> >   	1500 roughly.
> >   Allocation attempts: Roughly 3000 order 3 allocation attempts
> >   	with GFP_NORETRY. This value is determined to saturate allocation
> >   	success.
> > 
> > Test: build-frag-movable
> > 
> > Success(N)                    89              87
> > compact_stall               4053            3642
> > compact_success              264             202
> > compact_fail                3788            3440
> > pgmigrate_success        6497642          153413
> > compact_isolated        13292640          353445
> > compact_migrate_scanned 69714502         2307433
> > compact_free_scanned    20243121         2325295
> 
> Here compact_success decreased relatively a lot, while success just barely.
> Less counterintuitive than the first result, but still a bit.

compact_stall on build test would be more unpredictable, because there
are a lot of background working threads and they allocate and free
memory. Anyway, I will investigate it and if I find something, I will
note. :)

To know precise reason, separating async/sync compaction stat will be
helpful.

> > This looks like reasonable trade-off.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/compaction.c | 19 ++++++++++++-------
> >  1 file changed, 12 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index e61ee77..e1b44a5 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -129,19 +129,24 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
> >  
> >  /* Do not skip compaction more than 64 times */
> >  #define COMPACT_MAX_FAILED 4
> > -#define COMPACT_MIN_DEPLETE_THRESHOLD 1UL
> > +#define COMPACT_MIN_DEPLETE_THRESHOLD 4UL
> >  #define COMPACT_MIN_SCAN_LIMIT (pageblock_nr_pages)
> >  
> >  static bool compaction_depleted(struct zone *zone)
> >  {
> > -	unsigned long threshold;
> > +	unsigned long nr_possible;
> >  	unsigned long success = zone->compact_success;
> > +	unsigned long threshold;
> >  
> > -	/*
> > -	 * Now, to imitate current compaction deferring approach,
> > -	 * choose threshold to 1. It will be changed in the future.
> > -	 */
> > -	threshold = COMPACT_MIN_DEPLETE_THRESHOLD;
> > +	nr_possible = zone->managed_pages >> zone->compact_order_failed;
> > +
> > +	/* Migration scanner normally scans less than 1/4 range of zone */
> > +	nr_possible >>= 2;
> > +
> > +	/* We hope to succeed more than 1/100 roughly */
> > +	threshold = nr_possible >> 7;
> > +
> > +	threshold = max(threshold, COMPACT_MIN_DEPLETE_THRESHOLD);
> >  	if (success >= threshold)
> >  		return false;
> 
> I wonder if compact_depletion_depth should play some "positive" role here. The
> bigger the depth, the lower the migration_scan_limit, which means higher chance
> of failing and so on. Ideally, the system should stabilize itself, so that
> migration_scan_limit is set based how many pages on average have to be scanned
> to succeed?

compact_depletion_depth is for throttling compaction when compaction
success possibility is depleted. Not for more success when depleted.
If compaction possibility is recovered, this little try will make
high-order page and stop throttling. This is a way to reduce excessive
compaction overhead like as deferring.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
