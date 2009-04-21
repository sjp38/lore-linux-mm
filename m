Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 62F3B6B0055
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 01:22:15 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3L5MYXh006489
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 14:22:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D454C45DE54
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 14:22:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A7A5145DE53
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 14:22:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9019B1DB803A
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 14:22:33 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 15AD8E18004
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 14:22:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.
Message-Id: <20090421142056.F127.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 14:22:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andy Whitcroft <apw@shadowen.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] low order lumpy reclaim also should use PAGEOUT_IO_SYNC.

commit 33c120ed2843090e2bd316de1588b8bf8b96cbde (more aggressively use lumpy reclaim)
change lumpy reclaim using condition. but it isn't enough change.

lumpy reclaim don't only mean isolate neighber page, but also do pageout as synchronous.
this patch does it.

Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andy Whitcroft <apw@shadowen.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1049,6 +1049,19 @@ static unsigned long shrink_inactive_lis
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
 
@@ -1061,19 +1074,7 @@ static unsigned long shrink_inactive_lis
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
@@ -1110,7 +1111,7 @@ static unsigned long shrink_inactive_lis
 		 * but that should be acceptable to the caller
 		 */
 		if (nr_freed < nr_taken && !current_is_kswapd() &&
-					sc->order > PAGE_ALLOC_COSTLY_ORDER) {
+		    lumpy_reclaim) {
 			congestion_wait(WRITE, HZ/10);
 
 			/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
