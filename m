Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 23D856B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:36:50 -0400 (EDT)
Date: Thu, 28 Apr 2011 21:36:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation failures
Message-ID: <20110428133644.GA12400@localhost>
References: <BANLkTin8mE=DLWma=U+CdJaQW03X2M2W1w@mail.gmail.com>
 <20110426055521.GA18473@localhost>
 <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110426124743.e58d9746.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

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

this patch (WMARK_HIGH, limited scan)
-------------------------------------
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

CC: Mel Gorman <mel@linux.vnet.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page_alloc.c |   17 +++--------------
 mm/vmscan.c     |    6 ++++++
 2 files changed, 9 insertions(+), 14 deletions(-)
--- linux-next.orig/mm/vmscan.c	2011-04-28 21:16:16.000000000 +0800
+++ linux-next/mm/vmscan.c	2011-04-28 21:28:57.000000000 +0800
@@ -1978,6 +1978,8 @@ static void shrink_zones(int priority, s
 				continue;
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
+			sc->nr_to_reclaim = max(sc->nr_to_reclaim,
+						zone->watermark[WMARK_HIGH]);
 		}
 
 		shrink_zone(priority, zone, sc);
@@ -2034,6 +2036,7 @@ static unsigned long do_try_to_free_page
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long writeback_threshold;
+	unsigned long min_reclaim = sc->nr_to_reclaim;
 
 	get_mems_allowed();
 	delayacct_freepages_start();
@@ -2067,6 +2070,9 @@ static unsigned long do_try_to_free_page
 			}
 		}
 		total_scanned += sc->nr_scanned;
+		if (sc->nr_reclaimed >= min_reclaim &&
+		    total_scanned > 2 * sc->nr_to_reclaim)
+			goto out;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
 			goto out;
 
--- linux-next.orig/mm/page_alloc.c	2011-04-28 21:16:16.000000000 +0800
+++ linux-next/mm/page_alloc.c	2011-04-28 21:16:18.000000000 +0800
@@ -1888,9 +1888,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
 	int migratetype, unsigned long *did_some_progress)
 {
-	struct page *page = NULL;
+	struct page *page;
 	struct reclaim_state reclaim_state;
-	bool drained = false;
 
 	cond_resched();
 
@@ -1912,22 +1911,12 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
