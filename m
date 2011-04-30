Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9A57D900001
	for <linux-mm@kvack.org>; Sat, 30 Apr 2011 10:17:47 -0400 (EDT)
Date: Sat, 30 Apr 2011 22:17:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110430141741.GA4511@localhost>
References: <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110429022824.GA8061@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

On Fri, Apr 29, 2011 at 10:28:24AM +0800, Wu Fengguang wrote:
> > Test results:
> > 
> > - the failure rate is pretty sensible to the page reclaim size,
> >   from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLUSTER_MAX)
> > 
> > - the IPIs are reduced by over 100 times
> 
> It's reduced by 500 times indeed.
> 
> CAL:     220449     220246     220372     220558     220251     219740     220043     219968   Function call interrupts
> CAL:         93        463        410        540        298        282        272        306   Function call interrupts
> 
> > base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocation patch
> > -------------------------------------------------------------------------------
> > nr_alloc_fail 10496
> > allocstall 1576602
> 
> > patched (WMARK_MIN)
> > -------------------
> > nr_alloc_fail 704
> > allocstall 105551
> 
> > patched (WMARK_HIGH)
> > --------------------
> > nr_alloc_fail 282
> > allocstall 53860
> 
> > this patch (WMARK_HIGH, limited scan)
> > -------------------------------------
> > nr_alloc_fail 276
> > allocstall 54034
> 
> There is a bad side effect though: the much reduced "allocstall" means
> each direct reclaim will take much more time to complete. A simple solution
> is to terminate direct reclaim after 10ms. I noticed that an 100ms
> time threshold can reduce the reclaim latency from 621ms to 358ms.
> Further lowering the time threshold to 20ms does not help reducing the
> real latencies though.

Experiments going on...

I tried the more reasonable terminate condition: stop direct reclaim
when the preferred zone is above high watermark (see the below chunk).

This helps reduce the average reclaim latency to under 100ms in the
1000-dd case.

However nr_alloc_fail is around 5000 and not ideal. The interesting
thing is, even if zone watermark is high, the task still may fail to
get a free page..

@@ -2067,8 +2072,17 @@ static unsigned long do_try_to_free_page
                        }
                }
                total_scanned += sc->nr_scanned;
-               if (sc->nr_reclaimed >= sc->nr_to_reclaim)
-                       goto out;
+               if (sc->nr_reclaimed >= min_reclaim) {
+                       if (sc->nr_reclaimed >= sc->nr_to_reclaim)
+                               goto out;
+                       if (total_scanned > 2 * sc->nr_to_reclaim)
+                               goto out;
+                       if (preferred_zone &&
+                           zone_watermark_ok_safe(preferred_zone, sc->order,
+                                       high_wmark_pages(preferred_zone),
+                                       zone_idx(preferred_zone), 0))
+                               goto out;
+               }
               
                /*
                 * Try to write back as many pages as we just scanned.  This

Thanks,
Fengguang
---
Subject: mm: cut down __GFP_NORETRY page allocation failures
Date: Thu Apr 28 13:46:39 CST 2011

Concurrent page allocations are suffering from high failure rates.

On a 8p, 3GB ram test box, when reading 1000 sparse files of size 1GB,
the page allocation failures are

nr_alloc_fail 733 	# interleaved reads by 1 single task
nr_alloc_fail 11799	# concurrent reads by 1000 tasks

The concurrent read test script is:

	for i in `seq 1000`
	do
		truncate -s 1G /fs/sparse-$i
		dd if=/fs/sparse-$i of=/dev/null &
	done

In order for get_page_from_freelist() to get free page,

(1) try_to_free_pages() should use much higher .nr_to_reclaim than the
    current SWAP_CLUSTER_MAX=32, in order to draw the zone out of the
    possible low watermark state as well as fill the pcp with enough free
    pages to overflow its high watermark.

(2) the get_page_from_freelist() _after_ direct reclaim should use lower
    watermark than its normal invocations, so that it can reasonably
    "reserve" some free pages for itself and prevent other concurrent
    page allocators stealing all its reclaimed pages.

Some notes:

- commit 9ee493ce ("mm: page allocator: drain per-cpu lists after direct
  reclaim allocation fails") has the same target, however is obviously
  costly and less effective. It seems more clean to just remove the
  retry and drain code than to retain it.

- it's a bit hacky to reclaim more than requested pages inside
  do_try_to_free_page(), and it won't help cgroup for now

- it only aims to reduce failures when there are plenty of reclaimable
  pages, so it stops the opportunistic reclaim when scanned 2 times pages

Test results:

- the failure rate is pretty sensible to the page reclaim size,
  from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLUSTER_MAX)

- the IPIs are reduced by over 100 times

base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocation patch
-------------------------------------------------------------------------------
nr_alloc_fail 10496
allocstall 1576602

slabs_scanned 21632
kswapd_steal 4393382
kswapd_inodesteal 124
kswapd_low_wmark_hit_quickly 885
kswapd_high_wmark_hit_quickly 2321
kswapd_skip_congestion_wait 0
pageoutrun 29426

CAL:     220449     220246     220372     220558     220251     219740     220043     219968   Function call interrupts

LOC:     536274     532529     531734     536801     536510     533676     534853     532038   Local timer interrupts
RES:       3032       2128       1792       1765       2184       1703       1754       1865   Rescheduling interrupts
TLB:        189         15         13         17         64        294         97         63   TLB shootdowns

patched (WMARK_MIN)
-------------------
nr_alloc_fail 704
allocstall 105551

slabs_scanned 33280
kswapd_steal 4525537
kswapd_inodesteal 187
kswapd_low_wmark_hit_quickly 4980
kswapd_high_wmark_hit_quickly 2573
kswapd_skip_congestion_wait 0
pageoutrun 35429

CAL:         93        286        396        754        272        297        275        281   Function call interrupts

LOC:     520550     517751     517043     522016     520302     518479     519329     517179   Local timer interrupts
RES:       2131       1371       1376       1269       1390       1181       1409       1280   Rescheduling interrupts
TLB:        280         26         27         30         65        305        134         75   TLB shootdowns

patched (WMARK_HIGH)
--------------------
nr_alloc_fail 282
allocstall 53860

slabs_scanned 23936
kswapd_steal 4561178
kswapd_inodesteal 0
kswapd_low_wmark_hit_quickly 2760
kswapd_high_wmark_hit_quickly 1748
kswapd_skip_congestion_wait 0
pageoutrun 32639

CAL:         93        463        410        540        298        282        272        306   Function call interrupts

LOC:     513956     510749     509890     514897     514300     512392     512825     510574   Local timer interrupts
RES:       1174       2081       1411       1320       1742       2683       1380       1230   Rescheduling interrupts
TLB:        274         21         19         22         57        317        131         61   TLB shootdowns

patched (WMARK_HIGH, limited scan)
----------------------------------
nr_alloc_fail 276
allocstall 54034

slabs_scanned 24320
kswapd_steal 4507482
kswapd_inodesteal 262
kswapd_low_wmark_hit_quickly 2638
kswapd_high_wmark_hit_quickly 1710
kswapd_skip_congestion_wait 0
pageoutrun 32182

CAL:         69        443        421        567        273        279        269        334   Function call interrupts

LOC:     514736     511698     510993     514069     514185     512986     513838     511229   Local timer interrupts
RES:       2153       1556       1126       1351       3047       1554       1131       1560   Rescheduling interrupts
TLB:        209         26         20         15         71        315        117         71   TLB shootdowns

patched (WMARK_HIGH, limited scan, stop on watermark OK), 100 dd
----------------------------------------------------------------

start time: 3
total time: 50
nr_alloc_fail 162
allocstall 45523

CPU             count     real total  virtual total    delay total
                  921     3024540200     3009244668    37123129525
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  357     4891766796             13ms
dd: read=0, write=0, cancelled_write=0

patched (WMARK_HIGH, limited scan, stop on watermark OK), 1000 dd
-----------------------------------------------------------------

start time: 272
total time: 509
nr_alloc_fail 3913
allocstall 541789

CPU             count     real total  virtual total    delay total
                 1044     3445476208     3437200482   229919915202
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  452    34691441605             76ms
dd: read=0, write=0, cancelled_write=0

patched (WMARK_HIGH, limited scan, stop on watermark OK, no time limit), 1000 dd
--------------------------------------------------------------------------------

start time: 278
total time: 513
nr_alloc_fail 4737
allocstall 436392


CPU             count     real total  virtual total    delay total
                 1024     3371487456     3359441487   225088210977
IO              count    delay total  delay average
                    1      160631171            160ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  367    30809994722             83ms
dd: read=20480, write=0, cancelled_write=0


no cond_resched():

start time: 263
total time: 516
nr_alloc_fail 5144
allocstall 436787

CPU             count     real total  virtual total    delay total
                 1018     3305497488     3283831119   241982934044
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  328    31398481378             95ms
dd: read=0, write=0, cancelled_write=0

zone_watermark_ok_safe():

start time: 266
total time: 513
nr_alloc_fail 4526
allocstall 440246

CPU             count     real total  virtual total    delay total
                 1119     3640446568     3619184439   240945024724
IO              count    delay total  delay average
                    3      303620082            101ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  372    27320731898             73ms
dd: read=77824, write=0, cancelled_write=0


start time: 275
total time: 517
nr_alloc_fail 4694
allocstall 431021


CPU             count     real total  virtual total    delay total
                 1073     3534462680     3512544928   234056498221
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  386    34751778363             89ms
dd: read=0, write=0, cancelled_write=0

CC: Mel Gorman <mel@linux.vnet.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/buffer.c          |    4 ++--
 include/linux/swap.h |    3 ++-
 mm/page_alloc.c      |   20 +++++---------------
 mm/vmscan.c          |   31 +++++++++++++++++++++++--------
 4 files changed, 32 insertions(+), 26 deletions(-)
--- linux-next.orig/mm/vmscan.c	2011-04-29 10:42:14.000000000 +0800
+++ linux-next/mm/vmscan.c	2011-04-30 21:59:33.000000000 +0800
@@ -2025,8 +2025,9 @@ static bool all_unreclaimable(struct zon
  * returns:	0, if no pages reclaimed
  * 		else, the number of pages reclaimed
  */
-static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
-					struct scan_control *sc)
+static unsigned long do_try_to_free_pages(struct zone *preferred_zone,
+					  struct zonelist *zonelist,
+					  struct scan_control *sc)
 {
 	int priority;
 	unsigned long total_scanned = 0;
@@ -2034,6 +2035,7 @@ static unsigned long do_try_to_free_page
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long writeback_threshold;
+	unsigned long min_reclaim = sc->nr_to_reclaim;
 
 	get_mems_allowed();
 	delayacct_freepages_start();
@@ -2041,6 +2043,9 @@ static unsigned long do_try_to_free_page
 	if (scanning_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
 
+	if (preferred_zone)
+		sc->nr_to_reclaim += preferred_zone->watermark[WMARK_HIGH];
+
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
 		if (!priority)
@@ -2067,8 +2072,17 @@ static unsigned long do_try_to_free_page
 			}
 		}
 		total_scanned += sc->nr_scanned;
-		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
-			goto out;
+		if (sc->nr_reclaimed >= min_reclaim) {
+			if (sc->nr_reclaimed >= sc->nr_to_reclaim)
+				goto out;
+			if (total_scanned > 2 * sc->nr_to_reclaim)
+				goto out;
+			if (preferred_zone &&
+			    zone_watermark_ok_safe(preferred_zone, sc->order,
+					high_wmark_pages(preferred_zone),
+					zone_idx(preferred_zone), 0))
+				goto out;
+		}
 
 		/*
 		 * Try to write back as many pages as we just scanned.  This
@@ -2117,7 +2131,8 @@ out:
 	return 0;
 }
 
-unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+unsigned long try_to_free_pages(struct zone *preferred_zone,
+				struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	unsigned long nr_reclaimed;
@@ -2137,7 +2152,7 @@ unsigned long try_to_free_pages(struct z
 				sc.may_writepage,
 				gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	nr_reclaimed = do_try_to_free_pages(preferred_zone, zonelist, &sc);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
 
@@ -2207,7 +2222,7 @@ unsigned long try_to_free_mem_cgroup_pag
 					    sc.may_writepage,
 					    sc.gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	nr_reclaimed = do_try_to_free_pages(NULL, zonelist, &sc);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
@@ -2796,7 +2811,7 @@ unsigned long shrink_all_memory(unsigned
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	nr_reclaimed = do_try_to_free_pages(NULL, zonelist, &sc);
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
--- linux-next.orig/mm/page_alloc.c	2011-04-29 10:42:15.000000000 +0800
+++ linux-next/mm/page_alloc.c	2011-04-30 21:29:40.000000000 +0800
@@ -1888,9 +1888,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
 	int migratetype, unsigned long *did_some_progress)
 {
-	struct page *page = NULL;
+	struct page *page;
 	struct reclaim_state reclaim_state;
-	bool drained = false;
 
 	cond_resched();
 
@@ -1901,7 +1900,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
+	*did_some_progress = try_to_free_pages(preferred_zone, zonelist, order,
+					       gfp_mask, nodemask);
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
@@ -1912,22 +1912,12 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	if (unlikely(!(*did_some_progress)))
 		return NULL;
 
-retry:
+	alloc_flags |= ALLOC_HARDER;
+
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags, preferred_zone,
 					migratetype);
-
-	/*
-	 * If an allocation failed after direct reclaim, it could be because
-	 * pages are pinned on the per-cpu lists. Drain them and try again
-	 */
-	if (!page && !drained) {
-		drain_all_pages();
-		drained = true;
-		goto retry;
-	}
-
 	return page;
 }
 
--- linux-next.orig/fs/buffer.c	2011-04-30 13:26:57.000000000 +0800
+++ linux-next/fs/buffer.c	2011-04-30 13:29:08.000000000 +0800
@@ -288,8 +288,8 @@ static void free_more_memory(void)
 						gfp_zone(GFP_NOFS), NULL,
 						&zone);
 		if (zone)
-			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS, NULL);
+			try_to_free_pages(zone, node_zonelist(nid, GFP_NOFS),
+					  0, GFP_NOFS, NULL);
 	}
 }
 
--- linux-next.orig/include/linux/swap.h	2011-04-30 13:30:36.000000000 +0800
+++ linux-next/include/linux/swap.h	2011-04-30 13:31:03.000000000 +0800
@@ -249,7 +249,8 @@ static inline void lru_cache_add_file(st
 #define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
 
 /* linux/mm/vmscan.c */
-extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+extern unsigned long try_to_free_pages(struct zone *preferred_zone,
+					struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
