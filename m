Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 37D4F6B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 01:05:28 -0400 (EDT)
Received: by pdea3 with SMTP id a3so116165016pde.3
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 22:05:27 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id fy4si15056681pbb.100.2015.04.16.22.05.25
        for <linux-mm@kvack.org>;
        Thu, 16 Apr 2015 22:05:27 -0700 (PDT)
Date: Fri, 17 Apr 2015 14:06:53 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm: vmscan: invoke slab shrinkers from shrink_zone()
Message-ID: <20150417050653.GA25530@js1304-P5Q-DELUXE>
References: <1416939830-20289-1-git-send-email-hannes@cmpxchg.org>
 <20141128160637.GH6948@esperanza>
 <20150416035736.GA1203@js1304-P5Q-DELUXE>
 <20150416143413.GA9228@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150416143413.GA9228@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 16, 2015 at 10:34:13AM -0400, Johannes Weiner wrote:
> Hi Joonsoo,
> 
> On Thu, Apr 16, 2015 at 12:57:36PM +0900, Joonsoo Kim wrote:
> > Hello, Johannes.
> > 
> > Ccing Vlastimil, because this patch causes some regression on
> > stress-highalloc test in mmtests and he is a expert on compaction
> > and would have interest on it. :)
> > 
> > On Fri, Nov 28, 2014 at 07:06:37PM +0300, Vladimir Davydov wrote:
> > > If the highest zone (zone_idx=requested_highidx) is not populated, we
> > > won't scan slab caches on direct reclaim, which may result in OOM kill
> > > even if there are plenty of freeable dentries available.
> > > 
> > > It's especially relevant for VMs, which often have less than 4G of RAM,
> > > in which case we will only have ZONE_DMA and ZONE_DMA32 populated and
> > > empty ZONE_NORMAL on x86_64.
> > 
> > I got similar problem mentioned above by Vladimir when I test stress-highest
> > benchmark. My test system has ZONE_DMA and ZONE_DMA32 and ZONE_NORMAL zones
> > like as following.
> > 
> > Node 0, zone      DMA
> >         spanned  4095
> >         present  3998
> >         managed  3977
> > Node 0, zone    DMA32
> >         spanned  1044480
> >         present  782333
> >         managed  762561
> > Node 0, zone   Normal
> >         spanned  262144
> >         present  262144
> >         managed  245318
> > 
> > Perhaps, requested_highidx would be ZONE_NORMAL for almost normal
> > allocation request.
> > 
> > When I test stress-highalloc benchmark, shrink_zone() on requested_highidx
> > zone in kswapd_shrink_zone() is frequently skipped because this zone is
> > already balanced. But, another zone, for example, DMA32, which has more memory,
> > isn't balanced so kswapd try to reclaim on that zone. But,
> > zone_idx(zone) == classzone_idx isn't true for that zone so
> > shrink_slab() is skipped and we can't age slab objects with same ratio
> > of lru pages.
> 
> No, kswapd_shrink_zone() has the highest *unbalanced* zone as the
> classzone.  When Normal is balanced but DMA32 is not, then kswapd
> scans DMA and DMA32 and invokes the shrinkers for DMA32.

Hmm... there is some corner cases related to compaction.
kswapd checks highest *unbalanced* zone with sc->order, but,
in kswapd_shrink_zone(), test_order would be changed to 0 if running
compaction is possible. In this case, following code could be true and
kswapd skip to shrink that highest unbalanced zone.

  if (!lowmem_pressure &&
    zone_balanced(zone, testorder, balance_gap, classzone_idx))

If this happens and lower zone is unbalanced, shrink_zone() would be
called but shrink_slab() could be skipped.

Anyway, I suspected that this is cause of regression, but, I found that
it isn't. When highest unbalanced zone is skipped to shrink due to
compaction possibility, lower zones are also balanced and all shrinks
are skipped in my test. See below.

> 
> > This could be also possible on direct reclaim path as Vladimir
> > mentioned.
> 
> Direct reclaim ignores watermarks and always scans a zone.  The
> problem is only with completely unpopulated zones, but Vladimir
> addressed that.

There is also similar corner case related to compaction in direct
reclaim path.

> > This causes following success rate regression of phase 1,2 on stress-highalloc
> > benchmark. The situation of phase 1,2 is that many high order allocations are
> > requested while many threads do kernel build in parallel.
> 
> Yes, the patch made the shrinkers on multi-zone nodes less aggressive.
> >From the changelog:
> 
>     This changes kswapd behavior, which used to invoke the shrinkers for each
>     zone, but with scan ratios gathered from the entire node, resulting in
>     meaningless pressure quantities on multi-zone nodes.
> 
> So the previous code *did* apply more pressure on the shrinkers, but
> it didn't make any sense.  The number of slab objects to scan for each
> scanned LRU page depended on how many zones there were in a node, and
> their relative sizes.  So a node with a large DMA32 and a small Normal
> would receive vastly different relative slab pressure than a node with
> only one big zone Normal.  That's not something we should revert to.

Yes, I agree that previous code didn't make any sense.

> If we are too weak on objects compared to LRU pages then we should
> adjust DEFAULT_SEEKS or individual shrinker settings.
> 
> If we think our pressure ratio is accurate but we don't reclaim enough
> compared to our compaction efforts, then any adjustments to improve
> huge page successrate should come from the allocator/compaction side.

Yes, I agree. Before tackling down to the compaction side, I'd like to
confirm how shrinker works and it has no problem.

> > Base: Run 1
> > Ops 1       33.00 (  0.00%)
> > Ops 2       43.00 (  0.00%)
> > Ops 3       80.00 (  0.00%)
> > Base: Run 2
> > Ops 1       33.00 (  0.00%)
> > Ops 2       44.00 (  0.00%)
> > Ops 3       80.00 (  0.00%)
> > Base: Run 3
> > Ops 1       30.00 (  0.00%)
> > Ops 2       44.00 (  0.00%)
> > Ops 3       80.00 (  0.00%)
> > 
> > Revert offending commit: Run 1
> > Ops 1       46.00 (  0.00%)
> > Ops 2       53.00 (  0.00%)
> > Ops 3       80.00 (  0.00%)
> > Revert offending commit: Run 2
> > Ops 1       48.00 (  0.00%)
> > Ops 2       55.00 (  0.00%)
> > Ops 3       80.00 (  0.00%)
> > Revert offending commit: Run 3
> > Ops 1       48.00 (  0.00%)
> > Ops 2       55.00 (  0.00%)
> > Ops 3       81.00 (  0.00%)
> > 
> > I'm not sure whether we should consider this benchmark's regression very much,
> > because real life's compaction behavious would be different with this
> > benchmark. Anyway, I have some questions related to this patch. I don't know
> > this code very well so please correct me if I'm wrong.
> > 
> > I read the patch carefully and there is two main differences between before
> > and after. One is the way of aging ratio calculation. Before, we use number of
> > lru pages in node, but, this patch uses number of lru pages in zone. As I
> > understand correctly, shrink_slab() works for a node range rather than
> > zone one. And, I guess that calculated ratio with zone's number of lru pages
> > could be more fluctuate than node's one. Is it reasonable to use zone's one?
> 
> The page allocator distributes allocations evenly among the zones in a
> node, so the fluctuation should be fairly low.
> 
> And we scan the LRUs in chunks of 32 pages, which gives us good enough
> ratio granularity on even tiny zones (1/8th on a hypothetical 1M zone).

Okay.

> > And, should we guarantee one time invocation of shrink_slab() in above cases?
> > When I tested it, benchmark result is restored a little.
> > 
> > Guarantee one time invocation: Run 1
> > Ops 1       30.00 (  0.00%)
> > Ops 2       47.00 (  0.00%)
> > Ops 3       80.00 (  0.00%)
> > Guarantee one time invocation: Run 2
> > Ops 1       43.00 (  0.00%)
> > Ops 2       45.00 (  0.00%)
> > Ops 3       78.00 (  0.00%)
> > Guarantee one time invocation: Run 3
> > Ops 1       39.00 (  0.00%)
> > Ops 2       45.00 (  0.00%)
> > Ops 3       80.00 (  0.00%)
> 
> It should already invoke the shrinkers at least once per node.  Could
> you tell me how you changed the code for this test?

Sorry about that. There is my mistake and above data is just
experimental error. Anyway, I put the code like as below.

@@ -2950,7 +2957,8 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 static bool kswapd_shrink_zone(struct zone *zone,
                               int classzone_idx,
                               struct scan_control *sc,
-                              unsigned long *nr_attempted)
+                              unsigned long *nr_attempted,
+                              bool *should_shrink_slab)
 {
        int testorder = sc->order;
        unsigned long balance_gap;
@@ -2985,10 +2993,15 @@ static bool kswapd_shrink_zone(struct zone *zone,
         */
        lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
        if (!lowmem_pressure && zone_balanced(zone, testorder,
-                                               balance_gap, classzone_idx))
+                                               balance_gap, classzone_idx)) {
+               if (zone_idx(zone) == classzone_idx)
+                       *should_shrink_slab = true;
                return true;
+       }

-       shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
+       shrink_zone(zone, sc, (zone_idx(zone) == classzone_idx) ||
+                               *should_shrink_slab);
+       *should_shrink_slab = false;

        /* Account for the number of pages attempted to reclaim */
        *nr_attempted += sc->nr_to_reclaim;
@@ -3052,6 +3065,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
                unsigned long nr_attempted = 0;
                bool raise_priority = true;
                bool pgdat_needs_compaction = (order > 0);
+               bool should_shrink_slab = false;

                sc.nr_reclaimed = 0;

@@ -3164,7 +3178,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
                         * efficiency.
                         */
                        if (kswapd_shrink_zone(zone, end_zone,
-                                              &sc, &nr_attempted))
+                                              &sc, &nr_attempted,
+                                              &should_shrink_slab))
                                raise_priority = false;
                }


Reason I did this change is that I see lots of '*should_shrink_slab = true'
cases happen. But, I didn't check shrink_zone() is called due to should_shrink_slab
before. Now I checked it again and found that calling shrink_zone with
'should_shrink_slab = true' doesn't happend. Maybe, in this case, lower zone
is also balanced.

I will inverstigate more about what causes compaction benchmark regression.
If it is related to less aggressive shrink on multi-zone, it is fine and
I will try to look at compaction code.

Anyway, As mentioned above, if, theoretically, skip is possible, we should
invoke the shrinkers at least once per node like as above change? I guess
this possibility is very low.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
