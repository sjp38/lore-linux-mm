Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5109C6B0201
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 23:16:25 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G3GJ4i028521
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 12:16:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A862D45DE4F
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:16:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8768C45DE4C
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:16:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 700661DB8013
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:16:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C20B1DB8017
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:16:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: page_check_references() check low order lumpy reclaim properly
In-Reply-To: <20100415051911.GA17110@localhost>
References: <20100415135031.D186.A69D9226@jp.fujitsu.com> <20100415051911.GA17110@localhost>
Message-Id: <20100416115437.27AD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Apr 2010 12:16:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Apr 15, 2010 at 12:55:30PM +0800, KOSAKI Motohiro wrote:
> > > On Thu, Apr 15, 2010 at 12:32:50PM +0800, KOSAKI Motohiro wrote:
> > > > > On Thu, Apr 15, 2010 at 11:31:52AM +0800, KOSAKI Motohiro wrote:
> > > > > > > > Many applications (this one and below) are stuck in
> > > > > > > > wait_on_page_writeback(). I guess this is why "heavy write to
> > > > > > > > irrelevant partition stalls the whole system".  They are stuck on page
> > > > > > > > allocation. Your 512MB system memory is a bit tight, so reclaim
> > > > > > > > pressure is a bit high, which triggers the wait-on-writeback logic.
> > > > > > > 
> > > > > > > I wonder if this hacking patch may help.
> > > > > > > 
> > > > > > > When creating 300MB dirty file with dd, it is creating continuous
> > > > > > > region of hard-to-reclaim pages in the LRU list. priority can easily
> > > > > > > go low when irrelevant applications' direct reclaim run into these
> > > > > > > regions..
> > > > > > 
> > > > > > Sorry I'm confused not. can you please tell us more detail explanation?
> > > > > > Why did lumpy reclaim cause OOM? lumpy reclaim might cause
> > > > > > direct reclaim slow down. but IIUC it's not cause OOM because OOM is
> > > > > > only occur when priority-0 reclaim failure.
> > > > > 
> > > > > No I'm not talking OOM. Nor lumpy reclaim.
> > > > > 
> > > > > I mean the direct reclaim can get stuck for long time, when we do
> > > > > wait_on_page_writeback() on lumpy_reclaim=1.
> > > > > 
> > > > > > IO get stcking also prevent priority reach to 0.
> > > > > 
> > > > > Sure. But we can wait for IO a bit later -- after scanning 1/64 LRU
> > > > > (the below patch) instead of the current 1/1024.
> > > > > 
> > > > > In Andreas' case, 512MB/1024 = 512KB, this is way too low comparing to
> > > > > the 22MB writeback pages. There can easily be a continuous range of
> > > > > 512KB dirty/writeback pages in the LRU, which will trigger the wait
> > > > > logic.
> > > > 
> > > > In my feeling from your explanation, we need auto adjustment mechanism
> > > > instead change default value for special machine. no?
> > > 
> > > You mean the dumb DEF_PRIORITY/2 may be too large for a 1TB memory box?
> > > 
> > > However for such boxes, whether it be DEF_PRIORITY-2 or DEF_PRIORITY/2
> > > shall be irrelevant: it's trivial anyway to reclaim an order-1 or
> > > order-2 page. In other word, lumpy_reclaim will hardly go 1.  Do you
> > > think so?
> > 
> > If my remember is correct, Its order-1 lumpy reclaim was introduced
> > for solving such big box + AIM7 workload made kernel stack (order-1 page)
> > allocation failure.
> > 
> > Now, We are living on moore's law. so probably we need to pay attention
> > scalability always. today's big box is going to become desktop box after
> > 3-5 years.
> > 
> > Probably, Lee know such problem than me. cc to him.
> 
> In Andreas' trace, the processes are blocked in
> - do_fork:              console-kit-d
> - __alloc_skb:          x-terminal-em, konqueror
> - handle_mm_fault:      tclsh
> - filemap_fault:        ls
> 
> I'm a bit confused by the last one, and wonder what's the typical
> gfp order of __alloc_skb().

Probably I've found one of reason of low order lumpy reclaim slow down.
Let's fix obvious bug at first!


============================================================
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] vmscan: page_check_references() check low order lumpy reclaim properly

If vmscan is under lumpy reclaim mode, it have to ignore referenced bit
for making contenious free pages. but current page_check_references()
doesn't.

Fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3ff3311..13d9546 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -77,6 +77,8 @@ struct scan_control {
 
 	int order;
 
+	int lumpy_reclaim;
+
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
 
@@ -575,7 +577,7 @@ static enum page_references page_check_references(struct page *page,
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+	if (sc->lumpy_reclaim)
 		return PAGEREF_RECLAIM;
 
 	/*
@@ -1130,7 +1132,6 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
-	int lumpy_reclaim = 0;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1140,17 +1141,6 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 			return SWAP_CLUSTER_MAX;
 	}
 
-	/*
-	 * If we need a large contiguous chunk of memory, or have
-	 * trouble getting a small set of contiguous pages, we
-	 * will reclaim both active and inactive pages.
-	 *
-	 * We use the same threshold as pageout congestion_wait below.
-	 */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		lumpy_reclaim = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
-		lumpy_reclaim = 1;
 
 	pagevec_init(&pvec, 1);
 
@@ -1163,7 +1153,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_freed;
 		unsigned long nr_active;
 		unsigned int count[NR_LRU_LISTS] = { 0, };
-		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
+		int mode = sc->lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
 		unsigned long nr_anon;
 		unsigned long nr_file;
 
@@ -1216,7 +1206,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		 * but that should be acceptable to the caller
 		 */
 		if (nr_freed < nr_taken && !current_is_kswapd() &&
-		    lumpy_reclaim) {
+		    sc->lumpy_reclaim) {
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*
@@ -1655,6 +1645,18 @@ static void shrink_zone(int priority, struct zone *zone,
 					  &reclaim_stat->nr_saved_scan[l]);
 	}
 
+	/*
+	 * If we need a large contiguous chunk of memory, or have
+	 * trouble getting a small set of contiguous pages, we
+	 * will reclaim both active and inactive pages.
+	 */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		sc->lumpy_reclaim = 1;
+	else if (sc->order && priority < DEF_PRIORITY - 2)
+		sc->lumpy_reclaim = 1;
+	else
+		sc->lumpy_reclaim = 0;
+
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(l) {
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
