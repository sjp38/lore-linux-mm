Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E849D6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 22:49:55 -0400 (EDT)
Date: Tue, 3 May 2011 10:49:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110503024950.GA7095@localhost>
References: <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
 <20110430141741.GA4511@localhost>
 <20110501163542.GA3204@barrios-desktop>
 <20110502132958.GA9690@localhost>
 <20110502134953.GA12281@localhost>
 <65795E11DBF1E645A09CEC7EAEE94B9C3DED479C@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C3DED479C@USINDEVS02.corp.hds.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

Hi Satoru,

On Tue, May 03, 2011 at 08:27:43AM +0800, Satoru Moriya wrote:
> Hi Wu,
>  
> > On Mon, May 02, 2011 at 09:29:58PM +0800, Wu Fengguang wrote:
> > > > > +                     if (preferred_zone &&
> > > > > +                         zone_watermark_ok_safe(preferred_zone, sc->order,
> > > > > +                                     high_wmark_pages(preferred_zone),
> > > > > +                                     zone_idx(preferred_zone), 0))
> > > > > +                             goto out;
> > > > > +             }
> > > >
> > > > As I said, I think direct reclaim path sould be fast if possbile and
> > > > it should not a function of min_free_kbytes.
> > >
> > > It can be made not a function of min_free_kbytes by simply changing
> > > high_wmark_pages() to low_wmark_pages() in the above chunk, since
> > > direct reclaim is triggered when ALLOC_WMARK_LOW cannot be satisfied,
> > > ie. it just dropped below low_wmark_pages().
> > >
> > > But still, it costs 62ms reclaim latency (base kernel is 29ms).
> > 
> > I got new findings: the CPU schedule delays are much larger than
> > reclaim delays. It does make the "direct reclaim until low watermark
> > OK" latency less a problem :)
> > 
> > 1000 dd test case:
> >                 RECLAIM delay   CPU delay       nr_alloc_fail   CAL (last CPU)
> > base kernel     29ms            244ms           14586           218440
> > patched         62ms            215ms           5004            325
> 
> Hmm, in your system, the latency of direct reclaim may be a less problem.
> 
> But, generally speaking, in a latency sensitive system in enterprise area
> there are two kind of processes. One is latency sensitive -(A) the other
> is not-latency sensitive -(B). And usually we set cpu affinity for both processes
> to avoid scheduling issue in (A). In this situation, CPU delay tends to be lower
> than the above and a less problem but reclaim delay is more critical. 

Good point, thanks!

I also tried increasing min_free_kbytes as indicated by Minchan and
find 1-second long reclaim delays... Even adding explicit time limits,
it's still over 100ms with very high nr_alloc_fail.

I'm listing the code and results here as a record. But in general I'll
stop experiments in this direction. We need some more oriented way
that can guarantee to satisfy the page allocation request after small
sized direct reclaims.

Thanks,
Fengguang
---

root@fat /home/wfg# ./test-dd-sparse.sh
start time: 250
total time: 518
nr_alloc_fail 18551
allocstall 234468
LOC:     525770     523124     520782     529151     526192     525004     524166     521527   Local timer interrupts
RES:       2174       1674       1301       1420       3329       1563       1314       1563   Rescheduling interrupts
CAL:         67        402        602        267        240        270        291        274   Function call interrupts
TLB:        197         25         23         17         80        321        121         58   TLB shootdowns

CPU             count     real total  virtual total    delay total  delay average
                 1078     3408481832     3400786094   256971188317        238.378ms
IO              count    delay total  delay average
                    5      414363739             82ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  187    28564728545            152ms

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
    possible low watermark state

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

Test results (1000 dd case):

- the failure rate is pretty sensible to the page reclaim size,
  from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 5004 (WMARK_HIGH, stop on low
  watermark ok) to 10496 (SWAP_CLUSTER_MAX)

- the IPIs are reduced by over 500 times

- the reclaim delay is doubled, from 29ms to 62ms

Base kernel is vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocations.

base kernel, 1000 dd
--------------------

start time: 245
total time: 526
nr_alloc_fail 14586
allocstall 1578343
LOC:     533981     529210     528283     532346     533392     531314     531705     528983   Local timer interrupts
RES:       3123       2177       1676       1580       2157       1974       1606       1696   Rescheduling interrupts
CAL:     218392     218631     219167     219217     218840     218985     218429     218440   Function call interrupts
TLB:        175         13         21         18         62        309        119         42   TLB shootdowns


CPU             count     real total  virtual total    delay total
                 1122     3676441096     3656793547   274182127286
IO              count    delay total  delay average
                    3      291765493             97ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1350    39229752193             29ms
dd: read=45056, write=0, cancelled_write=0

patched, 1000 dd
----------------

root@fat /home/wfg# ./test-dd-sparse.sh
start time: 260
total time: 519
nr_alloc_fail 5004
allocstall 551429
LOC:     524861     521832     520945     524632     524666     523334     523797     521562   Local timer interrupts
RES:       1323       1976       2505       1610       1544       1848       3310       1644   Rescheduling interrupts
CAL:         67        335        353        614        289        287        293        325   Function call interrupts
TLB:        288         29         26         34        103        321        123         70   TLB shootdowns

CPU             count     real total  virtual total    delay total
                 1177     3797422704     3775174301   253228435955
IO              count    delay total  delay average
                    1      198528820            198ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  508    31660219699             62ms

base kernel, 100 dd
-------------------
root@fat /home/wfg# ./test-dd-sparse.sh
start time: 3
total time: 53
nr_alloc_fail 849
allocstall 131330
LOC:      59843      56506      55838      65283      61774      57929      58880      56246   Local timer interrupts
RES:        376        308        372        239        374        307        491        239   Rescheduling interrupts
CAL:      17737      18083      17948      18192      17929      17845      17893      17906   Function call interrupts
TLB:        307         26         25         21         80        324        137         79   TLB shootdowns

CPU             count     real total  virtual total    delay total
                  974     3197513904     3180727460    38504429363
IO              count    delay total  delay average
                    1       18156696             18ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1036     3439387298              3ms
dd: read=12288, write=0, cancelled_write=0

patched, 100 dd
---------------

root@fat /home/wfg# ./test-dd-sparse.sh
start time: 3
total time: 52
nr_alloc_fail 307
allocstall 48178
LOC:      56486      53514      52792      55879      56317      55383      55311      53168   Local timer interrupts
RES:        604        345        257        250        775        371        272        252   Rescheduling interrupts
CAL:         75        373        369        543        272        278        295        296   Function call interrupts
TLB:        259         24         19         24         82        306        139         53   TLB shootdowns


CPU             count     real total  virtual total    delay total
                  974     3177516944     3161771347    38508053977
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                  393     5389030889             13ms
dd: read=0, write=0, cancelled_write=0

CC: Mel Gorman <mel@linux.vnet.ibm.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/buffer.c          |    4 ++--
 include/linux/swap.h |    3 ++-
 mm/page_alloc.c      |   22 +++++-----------------
 mm/vmscan.c          |   34 ++++++++++++++++++++++++++--------
 4 files changed, 35 insertions(+), 28 deletions(-)
--- linux-next.orig/mm/vmscan.c	2011-05-02 22:14:14.000000000 +0800
+++ linux-next/mm/vmscan.c	2011-05-03 10:07:14.000000000 +0800
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
@@ -2034,6 +2035,8 @@ static unsigned long do_try_to_free_page
 	struct zoneref *z;
 	struct zone *zone;
 	unsigned long writeback_threshold;
+	unsigned long min_reclaim = sc->nr_to_reclaim;
+	unsigned long start_time = jiffies;
 
 	get_mems_allowed();
 	delayacct_freepages_start();
@@ -2041,6 +2044,9 @@ static unsigned long do_try_to_free_page
 	if (scanning_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
 
+	if (preferred_zone)
+		sc->nr_to_reclaim += preferred_zone->watermark[WMARK_LOW];
+
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
 		if (!priority)
@@ -2067,8 +2073,19 @@ static unsigned long do_try_to_free_page
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
+			    zone_watermark_ok(preferred_zone, sc->order,
+					low_wmark_pages(preferred_zone),
+					zone_idx(preferred_zone), 0))
+				goto out;
+			if (jiffies - start_time > HZ / 100)
+				goto out;
+		}
 
 		/*
 		 * Try to write back as many pages as we just scanned.  This
@@ -2117,7 +2134,8 @@ out:
 	return 0;
 }
 
-unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
+unsigned long try_to_free_pages(struct zone *preferred_zone,
+				struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
 	unsigned long nr_reclaimed;
@@ -2137,7 +2155,7 @@ unsigned long try_to_free_pages(struct z
 				sc.may_writepage,
 				gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	nr_reclaimed = do_try_to_free_pages(preferred_zone, zonelist, &sc);
 
 	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
 
@@ -2207,7 +2225,7 @@ unsigned long try_to_free_mem_cgroup_pag
 					    sc.may_writepage,
 					    sc.gfp_mask);
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	nr_reclaimed = do_try_to_free_pages(NULL, zonelist, &sc);
 
 	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
 
@@ -2796,7 +2814,7 @@ unsigned long shrink_all_memory(unsigned
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+	nr_reclaimed = do_try_to_free_pages(NULL, zonelist, &sc);
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
--- linux-next.orig/mm/page_alloc.c	2011-05-02 22:14:14.000000000 +0800
+++ linux-next/mm/page_alloc.c	2011-05-02 22:14:21.000000000 +0800
@@ -1888,9 +1888,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
 	int migratetype, unsigned long *did_some_progress)
 {
-	struct page *page = NULL;
+	struct page *page;
 	struct reclaim_state reclaim_state;
-	bool drained = false;
 
 	cond_resched();
 
@@ -1901,33 +1900,22 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
+	*did_some_progress = try_to_free_pages(preferred_zone, zonelist, order,
+					       gfp_mask, nodemask);
 
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	current->flags &= ~PF_MEMALLOC;
 
-	cond_resched();
-
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
 
--- linux-next.orig/fs/buffer.c	2011-05-02 22:14:14.000000000 +0800
+++ linux-next/fs/buffer.c	2011-05-02 22:14:21.000000000 +0800
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
 
--- linux-next.orig/include/linux/swap.h	2011-05-02 22:14:14.000000000 +0800
+++ linux-next/include/linux/swap.h	2011-05-02 22:14:21.000000000 +0800
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
