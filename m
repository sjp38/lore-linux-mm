Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 86CC36B0119
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 21:20:32 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3N1KneH014410
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 23 Apr 2009 10:20:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F10E45DE50
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 10:20:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02B2A45DE51
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 10:20:49 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D78841DB8037
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 10:20:48 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 724CDE08004
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 10:20:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.
In-Reply-To: <20090422143201.GE15367@csn.ul.ie>
References: <20090421142056.F127.A69D9226@jp.fujitsu.com> <20090422143201.GE15367@csn.ul.ie>
Message-Id: <20090423094411.F6EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 23 Apr 2009 10:20:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 21, 2009 at 02:22:27PM +0900, KOSAKI Motohiro wrote:
> > Subject: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.
> > 
> > commit 33c120ed2843090e2bd316de1588b8bf8b96cbde (more aggressively use lumpy reclaim)
> > change lumpy reclaim using condition. but it isn't enough change.
> > 
> > lumpy reclaim don't only mean isolate neighber page, but also do pageout as synchronous.
> > this patch does it.
> > 
> > Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> > Cc: Andy Whitcroft <apw@shadowen.org>
> > Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Rik van Riel <riel@redhat.com>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Seems fair although the changelog could be better. Maybe something like?
> 
> ====
> 
> Commit 33c120ed2843090e2bd316de1588b8bf8b96cbde increased how aggressive
> lumpy reclaim was by isolating both active and inactive pages for asynchronous
> lumpy reclaim on costly-high-order pages and for cheap-high-order when memory
> pressure is high. However, if the system is under heavy pressure and there
> are dirty pages, asynchronous IO may not be sufficient to reclaim a suitable
> page in time.
> 
> This patch causes the caller to enter synchronous lumpy reclaim for
> costly-high-order pages and for cheap-high-order pages when under memory
> pressure.
> ====
> 
> Whether the changelog is updated or not though;
> 
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>

Cool!


Andrew, Could you please replace vmscan-low-order-lumpy-reclaim-also-should-use-pageout_io_sync.patch 
with following patch?


===================================
Subject: vmscan: low order lumpy reclaim also should use PAGEOUT_IO_SYNC
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Commit 33c120ed2843090e2bd316de1588b8bf8b96cbde increased how aggressive
lumpy reclaim was by isolating both active and inactive pages for asynchronous
lumpy reclaim on costly-high-order pages and for cheap-high-order when memory
pressure is high. However, if the system is under heavy pressure and there
are dirty pages, asynchronous IO may not be sufficient to reclaim a suitable
page in time.

This patch causes the caller to enter synchronous lumpy reclaim for
costly-high-order pages and for cheap-high-order pages when under memory
pressure.


Minchan.kim@gmail.com said:

Andy added synchronous lumpy reclaim with
c661b078fd62abe06fd11fab4ac5e4eeafe26b6d.  At that time, lumpy reclaim is
not agressive.  His intension is just for high-order users.(above
PAGE_ALLOC_COSTLY_ORDER).  

After some time, Rik added aggressive lumpy reclaim with
33c120ed2843090e2bd316de1588b8bf8b96cbde.  His intention was to do lumpy
reclaim when high-order users and trouble getting a small set of
contiguous pages.  

So we also have to add synchronous pageout for small set of contiguous
pages.

Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <Minchan.kim@gmail.com>
Reviewed-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/vmscan.c |   29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff -puN mm/vmscan.c~vmscan-low-order-lumpy-reclaim-also-should-use-pageout_io_sync mm/vmscan.c
--- a/mm/vmscan.c~vmscan-low-order-lumpy-reclaim-also-should-use-pageout_io_sync
+++ a/mm/vmscan.c
@@ -1059,6 +1059,19 @@ static unsigned long shrink_inactive_lis
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
+	int lumpy_reclaim = 0;
+
+	/*
+	 * If we need a large contiguous chunk of memory, or have
+	 * trouble getting a small set of contiguous pages, we
+	 * will reclaim both active and inactive pages.
+	 *
+	 * We use the same threshold as pageout congestion_wait below.
+	 */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		lumpy_reclaim = 1;
+	else if (sc->order && priority < DEF_PRIORITY - 2)
+		lumpy_reclaim = 1;
 
 	pagevec_init(&pvec, 1);
 
@@ -1071,19 +1084,7 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_freed;
 		unsigned long nr_active;
 		unsigned int count[NR_LRU_LISTS] = { 0, };
-		int mode = ISOLATE_INACTIVE;
-
-		/*
-		 * If we need a large contiguous chunk of memory, or have
-		 * trouble getting a small set of contiguous pages, we
-		 * will reclaim both active and inactive pages.
-		 *
-		 * We use the same threshold as pageout congestion_wait below.
-		 */
-		if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-			mode = ISOLATE_BOTH;
-		else if (sc->order && priority < DEF_PRIORITY - 2)
-			mode = ISOLATE_BOTH;
+		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
 
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
 			     &page_list, &nr_scan, sc->order, mode,
@@ -1120,7 +1121,7 @@ static unsigned long shrink_inactive_lis
 		 * but that should be acceptable to the caller
 		 */
 		if (nr_freed < nr_taken && !current_is_kswapd() &&
-					sc->order > PAGE_ALLOC_COSTLY_ORDER) {
+		    lumpy_reclaim) {
 			congestion_wait(WRITE, HZ/10);
 
 			/*
_



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
