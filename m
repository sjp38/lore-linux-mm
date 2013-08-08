Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C8FA36B0032
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 00:16:49 -0400 (EDT)
Date: Thu, 8 Aug 2013 00:16:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v2 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130808041623.GL1845@cmpxchg.org>
References: <1375457846-21521-1-git-send-email-hannes@cmpxchg.org>
 <1375457846-21521-4-git-send-email-hannes@cmpxchg.org>
 <20130807145828.GQ2296@suse.de>
 <20130807153743.GH715@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807153743.GH715@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@surriel.com>, Andrea Arcangeli <aarcange@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 07, 2013 at 11:37:43AM -0400, Johannes Weiner wrote:
> On Wed, Aug 07, 2013 at 03:58:28PM +0100, Mel Gorman wrote:
> > On Fri, Aug 02, 2013 at 11:37:26AM -0400, Johannes Weiner wrote:
> > > @@ -352,6 +352,7 @@ struct zone {
> > >  	 * free areas of different sizes
> > >  	 */
> > >  	spinlock_t		lock;
> > > +	int			alloc_batch;
> > >  	int                     all_unreclaimable; /* All pages pinned */
> > >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> > >  	/* Set to true when the PG_migrate_skip bits should be cleared */
> > 
> > This adds a dirty cache line that is updated on every allocation even if
> > it's from the per-cpu allocator. I am concerned that this will introduce
> > noticable overhead in the allocator paths on large machines running
> > allocator intensive workloads.
> > 
> > Would it be possible to move it into the per-cpu pageset? I understand
> > that hte round-robin nature will then depend on what CPU is running and
> > the performance characterisics will be different. There might even be an
> > adverse workload that uses all the batches from all available CPUs until
> > it is essentially the same problem but that would be a very worst case.
> > I would hope that in general it would work without adding a big source of
> > dirty cache line bouncing in the middle of the allocator.
> 
> Rik made the same suggestion.  The per-cpu error is one thing, the
> problem is if the allocating task and kswapd run on the same CPU and
> bypass the round-robin allocator completely, at which point we are
> back to square one.  We'd have to reduce the per-cpu lists from a pool
> to strict batching of frees and allocs without reuse in between.  That
> might be doable, I'll give this another look.

I found a way.  It's still in the fast path, but I'm using vmstat
percpu counters and can stick the update inside the same irq-safe
section that does the other statistic updates.

On a two socket system with a small Normal zone, the results are as
follows (unfair: mmotm without the fairness allocator, fairpcp: the
fair allocator + the vmstat optimization):

---

pft
                             mmotm                 mmotm
                            unfair               fairpcp
User       1       0.0258 (  0.00%)       0.0254 (  1.40%)
User       2       0.0264 (  0.00%)       0.0263 (  0.21%)
User       3       0.0271 (  0.00%)       0.0277 ( -2.36%)
User       4       0.0287 (  0.00%)       0.0280 (  2.33%)
System     1       0.4904 (  0.00%)       0.4919 ( -0.29%)
System     2       0.6141 (  0.00%)       0.6183 ( -0.68%)
System     3       0.7346 (  0.00%)       0.7349 ( -0.04%)
System     4       0.8700 (  0.00%)       0.8704 ( -0.05%)
Elapsed    1       0.5164 (  0.00%)       0.5182 ( -0.35%)
Elapsed    2       0.3213 (  0.00%)       0.3235 ( -0.67%)
Elapsed    3       0.2800 (  0.00%)       0.2800 (  0.00%)
Elapsed    4       0.2304 (  0.00%)       0.2303 (  0.01%)
Faults/cpu 1  392724.3239 (  0.00%)  391558.5131 ( -0.30%)
Faults/cpu 2  319357.5074 (  0.00%)  317577.8745 ( -0.56%)
Faults/cpu 3  265703.1420 (  0.00%)  265668.3579 ( -0.01%)
Faults/cpu 4  225516.0058 (  0.00%)  225474.1508 ( -0.02%)
Faults/sec 1  392051.3043 (  0.00%)  390880.8201 ( -0.30%)
Faults/sec 2  635360.7045 (  0.00%)  631819.1117 ( -0.56%)
Faults/sec 3  725535.2889 (  0.00%)  725525.1280 ( -0.00%)
Faults/sec 4  883307.5047 (  0.00%)  884026.1721 (  0.08%)

The overhead appears to be negligible, if not noise.

               mmotm       mmotm
              unfair     fairpcp
User           39.90       39.70
System       1070.93     1069.50
Elapsed       557.47      556.86

                                 mmotm       mmotm
                                unfair     fairpcp
Page Ins                          1248         876
Page Outs                         4280        4184
Swap Ins                             0           0
Swap Outs                            0           0
Alloc DMA                            0           0
Alloc DMA32                   13098002   214383756
Alloc Normal                 279611269    78332806
Alloc Movable                        0           0
Direct pages scanned                 0           0
Kswapd pages scanned                 0           0
Kswapd pages reclaimed               0           0
Direct pages reclaimed               0           0
Kswapd efficiency                 100%        100%
Kswapd velocity                  0.000       0.000
Direct efficiency                 100%        100%
Direct velocity                  0.000       0.000
Percentage direct scans             0%          0%
Page writes by reclaim               0           0
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate               0           0
Page rescued immediate               0           0
Slabs scanned                        0           0
Direct inode steals                  0           0
Kswapd inode steals                  0           0
Kswapd skipped wait                  0           0
THP fault alloc                      0           0
THP collapse alloc                   0           0
THP splits                           0           0
THP fault fallback                   0           0
THP collapse fail                    0           0
Compaction stalls                    0           0
Compaction success                   0           0
Compaction failures                  0           0
Page migrate success                 0           0
Page migrate failure                 0           0
Compaction pages isolated            0           0
Compaction migrate scanned           0           0
Compaction free scanned              0           0
Compaction cost                      0           0
NUMA PTE updates                     0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA pages migrated                  0           0
AutoNUMA cost                        0           0

The zone allocation stats show that 26% of the allocations come out of
the Normal zone and 73% out of the DMA32 zone, which is equivalent to
their proportional share of physical memory.

---

micro

               mmotm       mmotm
              unfair     fairpcp
User          650.11      533.86
System         46.16       31.49
Elapsed       903.53      349.29

                                 mmotm       mmotm
                                unfair     fairpcp
Page Ins                      27582876    11116604
Page Outs                     33959012    16573856
Swap Ins                             0           0
Swap Outs                            0           0
Alloc DMA                            0           0
Alloc DMA32                    8709355     6046277
Alloc Normal                   3188567     1959526
Alloc Movable                        0           0
Direct pages scanned           2588172      549598
Kswapd pages scanned          14803621     8451319
Kswapd pages reclaimed         6845369     3671141
Direct pages reclaimed          559581      229586
Kswapd efficiency                  46%         43%
Kswapd velocity              16384.205   24195.708
Direct efficiency                  21%         41%
Direct velocity               2864.511    1573.472
Percentage direct scans            14%          6%
Page writes by reclaim               0           0
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate               1           0
Page rescued immediate               0           0
Slabs scanned                     9088        7936
Direct inode steals               3910           0
Kswapd inode steals              15793          14
Kswapd skipped wait                  0           0
THP fault alloc                   6350        5482
THP collapse alloc                   1           0
THP splits                           0           0
THP fault fallback                 164        1622
THP collapse fail                    0           0
Compaction stalls                  126         324
Compaction success                  40          57
Compaction failures                 86         267
Page migrate success             16633       96349
Page migrate failure                 0           0
Compaction pages isolated        49154      305649
Compaction migrate scanned       92448      414357
Compaction free scanned         598137     4971412
Compaction cost                     18         108
NUMA PTE updates                     0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA pages migrated                  0           0
AutoNUMA cost                        0           0

Elapsed time in comparison with user and sys time indicates much
reduced IO wait.

Interestingly, the allocations end up spreading out even in the
unpatched case, but only because kswapd seems to get stuck frequently
in a small Normal zone full of young dirty pages.

---

parallelio
                                              mmotm                       mmotm
                                             unfair                     fairpcp
Ops memcachetest-0M              28012.00 (  0.00%)          27887.00 ( -0.45%)
Ops memcachetest-1877M           22366.00 (  0.00%)          27878.00 ( 24.64%)
Ops memcachetest-6257M           17770.00 (  0.00%)          27610.00 ( 55.37%)
Ops memcachetest-10638M          17695.00 (  0.00%)          27350.00 ( 54.56%)
Ops io-duration-0M                   0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-1877M               42.00 (  0.00%)             18.00 ( 57.14%)
Ops io-duration-6257M               97.00 (  0.00%)             57.00 ( 41.24%)
Ops io-duration-10638M             172.00 (  0.00%)            122.00 ( 29.07%)
Ops swaptotal-0M                     0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-1877M              93603.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-6257M             113986.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-10638M            178887.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-0M                        0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-1877M                 20710.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-6257M                 18803.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-10638M                18755.00 (  0.00%)              0.00 (  0.00%)
Ops minorfaults-0M              866454.00 (  0.00%)         844880.00 (  2.49%)
Ops minorfaults-1877M           957107.00 (  0.00%)         845839.00 ( 11.63%)
Ops minorfaults-6257M           971144.00 (  0.00%)         844778.00 ( 13.01%)
Ops minorfaults-10638M         1066811.00 (  0.00%)         843628.00 ( 20.92%)
Ops majorfaults-0M                  17.00 (  0.00%)              0.00 (  0.00%)
Ops majorfaults-1877M             7636.00 (  0.00%)             37.00 ( 99.52%)
Ops majorfaults-6257M             6487.00 (  0.00%)             37.00 ( 99.43%)
Ops majorfaults-10638M            7337.00 (  0.00%)             37.00 ( 99.50%)

Mmtests reporting seems to have a bug calculating the percentage when
the numbers drop to 0, see swap activity.  Those should all be 100%.

               mmotm       mmotm
              unfair     fairpcp
User          592.67      695.15
System       3130.44     3628.81
Elapsed      7209.01     7206.46

                                 mmotm       mmotm
                                unfair     fairpcp
Page Ins                       1401120       42656
Page Outs                    163980516   153864256
Swap Ins                        316033           0
Swap Outs                      2528278           0
Alloc DMA                            0           0
Alloc DMA32                   59139091    51707843
Alloc Normal                  10013244    16310697
Alloc Movable                        0           0
Direct pages scanned            210080      235649
Kswapd pages scanned          61960450    50130023
Kswapd pages reclaimed        34998767    35769908
Direct pages reclaimed          179655      173478
Kswapd efficiency                  56%         71%
Kswapd velocity               8594.863    6956.262
Direct efficiency                  85%         73%
Direct velocity                 29.141      32.700
Percentage direct scans             0%          0%
Page writes by reclaim         3523501           1
Page writes file                995223           1
Page writes anon               2528278           0
Page reclaim immediate            2195        9188
Page rescued immediate               0           0
Slabs scanned                     2048        1536
Direct inode steals                  0           0
Kswapd inode steals                  0           0
Kswapd skipped wait                  0           0
THP fault alloc                      3           3
THP collapse alloc                4958        3026
THP splits                          28          27
THP fault fallback                   0           0
THP collapse fail                    7          72
Compaction stalls                   65          32
Compaction success                  57          14
Compaction failures                  8          18
Page migrate success             39460        9899
Page migrate failure                 0           0
Compaction pages isolated        87140       22017
Compaction migrate scanned       53494       12526
Compaction free scanned         913691      396861
Compaction cost                     42          10
NUMA PTE updates                     0           0
NUMA hint faults                     0           0
NUMA hint local faults               0           0
NUMA pages migrated                  0           0
AutoNUMA cost                        0           0

---

Patch on top of mmotm:

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: page_alloc: use vmstats for fair zone allocation batching

Avoid dirtying the same cache line with every single page allocation
by making the fair per-zone allocation batch a vmstat item, which will
turn it into batched percpu counters on SMP.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 21 ++++++++++++---------
 mm/vmstat.c            |  1 +
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index dcad2ab..ac1ea79 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -105,6 +105,7 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
+	NR_ALLOC_BATCH,
 	NR_LRU_BASE,
 	NR_INACTIVE_ANON = NR_LRU_BASE, /* must match order of LRU_[IN]ACTIVE */
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
@@ -352,7 +353,6 @@ struct zone {
 	 * free areas of different sizes
 	 */
 	spinlock_t		lock;
-	int			alloc_batch;
 	int                     all_unreclaimable; /* All pages pinned */
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
 	/* Set to true when the PG_migrate_skip bits should be cleared */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0d7e9e9..6a95d39 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1554,6 +1554,7 @@ again:
 					  get_pageblock_migratetype(page));
 	}
 
+	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
@@ -1927,7 +1928,7 @@ zonelist_scan:
 		 * fairness round-robin cycle of this zonelist.
 		 */
 		if (alloc_flags & ALLOC_WMARK_LOW) {
-			if (zone->alloc_batch <= 0)
+			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
 			if (zone_reclaim_mode &&
 			    !zone_local(preferred_zone, zone))
@@ -2039,8 +2040,7 @@ this_zone_full:
 		goto zonelist_scan;
 	}
 
-	if (page) {
-		zone->alloc_batch -= 1U << order;
+	if (page)
 		/*
 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
 		 * necessary to allocate the page. The expectation is
@@ -2049,7 +2049,6 @@ this_zone_full:
 		 * for !PFMEMALLOC purposes.
 		 */
 		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
-	}
 
 	return page;
 }
@@ -2418,8 +2417,10 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
 		 */
 		if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
 			continue;
-		zone->alloc_batch = high_wmark_pages(zone) -
-			low_wmark_pages(zone);
+		mod_zone_page_state(zone, NR_ALLOC_BATCH,
+				    high_wmark_pages(zone) -
+				    low_wmark_pages(zone) -
+				    zone_page_state(zone, NR_ALLOC_BATCH));
 	}
 }
 
@@ -4827,7 +4828,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->zone_pgdat = pgdat;
 
 		/* For bootup, initialized properly in watermark setup */
-		zone->alloc_batch = zone->managed_pages;
+		mod_zone_page_state(zone, NR_ALLOC_BATCH, zone->managed_pages);
 
 		zone_pcp_init(zone);
 		lruvec_init(&zone->lruvec);
@@ -5606,8 +5607,10 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
 
-		zone->alloc_batch = high_wmark_pages(zone) -
-			low_wmark_pages(zone);
+		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
+				      high_wmark_pages(zone) -
+				      low_wmark_pages(zone) -
+				      zone_page_state(zone, NR_ALLOC_BATCH));
 
 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 87228c5..ba9e46b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -704,6 +704,7 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
 const char * const vmstat_text[] = {
 	/* Zoned VM counters */
 	"nr_free_pages",
+	"nr_alloc_batch",
 	"nr_inactive_anon",
 	"nr_active_anon",
 	"nr_inactive_file",
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
