Date: Tue, 15 Jun 2004 21:23:36 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
Message-Id: <20040615212336.17d0a396.akpm@osdl.org>
In-Reply-To: <40CFC67D.6020205@yahoo.com.au>
References: <20040608142918.GA7311@traveler.cistron.net>
	<40CAA904.8080305@yahoo.com.au>
	<20040614140642.GE13422@traveler.cistron.net>
	<40CE66EE.8090903@yahoo.com.au>
	<20040615143159.GQ19271@traveler.cistron.net>
	<40CFBB75.1010702@yahoo.com.au>
	<20040615205017.15dd1f1d.akpm@osdl.org>
	<40CFC67D.6020205@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: miquels@cistron.nl, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
> > 
> > shrink_zone() will free arbitrarily large amounts of memory as the scanning
> > priority increases.  Probably it shouldn't.
> > 
> > 
> 
> Especially for kswapd, I think, because it can end up fighting with
> memory allocators and think it is getting into trouble. It should
> probably rather just keep putting along quietly.
> 
> I have a few experimental patches that magnify this problem, so I'll
> be looking at fixing it soon. The tricky part will be trying to
> maintain a similar prev_priority / temp_priority balance.

hm, I don't see why.  Why not simply bale from shrink_listing as soon as
we've reclaimed SWAP_CLUSTER_MAX pages?

I got bored of shrink_zone() bugs and rewrote it again yesterday.  Haven't
tested it much.  I really hate struct scan_control btw ;)




We've been futzing with the scan rates of the inactive and active lists far
too much, and it's still not right (Anton reports interrupt-off times of over
a second).

- We have this logic in there from 2.4.early (at least) which tries to keep
  the inactive list 1/3rd the size of the active list.  Or something.

  I really cannot see any logic behind this, so toss it out and change the
  arithmetic in there so that all pages on both lists have equal scan rates.

- Chunk the work up so we never hold interrupts off for more that 32 pages
  worth of scanning.

- Make the per-zone scan-count accumulators unsigned long rather than
  atomic_t.

  Mainly because atomic_t's could conceivably overflow, but also because
  access to these counters is racy-by-design anyway.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/include/linux/mmzone.h |    4 +-
 25-akpm/mm/page_alloc.c        |    4 +-
 25-akpm/mm/vmscan.c            |   70 ++++++++++++++++++-----------------------
 3 files changed, 35 insertions(+), 43 deletions(-)

diff -puN mm/vmscan.c~vmscan-scan-sanity mm/vmscan.c
--- 25/mm/vmscan.c~vmscan-scan-sanity	2004-06-15 02:19:01.485627112 -0700
+++ 25-akpm/mm/vmscan.c	2004-06-15 02:49:29.317754392 -0700
@@ -789,54 +789,46 @@ refill_inactive_zone(struct zone *zone, 
 }
 
 /*
- * Scan `nr_pages' from this zone.  Returns the number of reclaimed pages.
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static void
 shrink_zone(struct zone *zone, struct scan_control *sc)
 {
-	unsigned long scan_active, scan_inactive;
-	int count;
-
-	scan_inactive = (zone->nr_active + zone->nr_inactive) >> sc->priority;
+	unsigned long nr_active;
+	unsigned long nr_inactive;
 
 	/*
-	 * Try to keep the active list 2/3 of the size of the cache.  And
-	 * make sure that refill_inactive is given a decent number of pages.
-	 *
-	 * The "scan_active + 1" here is important.  With pagecache-intensive
-	 * workloads the inactive list is huge, and `ratio' evaluates to zero
-	 * all the time.  Which pins the active list memory.  So we add one to
-	 * `scan_active' just to make sure that the kernel will slowly sift
-	 * through the active list.
+	 * Add one to `nr_to_scan' just to make sure that the kernel will
+	 * slowly sift through the active list.
 	 */
-	if (zone->nr_active >= 4*(zone->nr_inactive*2 + 1)) {
-		/* Don't scan more than 4 times the inactive list scan size */
-		scan_active = 4*scan_inactive;
-	} else {
-		unsigned long long tmp;
-
-		/* Cast to long long so the multiply doesn't overflow */
-
-		tmp = (unsigned long long)scan_inactive * zone->nr_active;
-		do_div(tmp, zone->nr_inactive*2 + 1);
-		scan_active = (unsigned long)tmp;
-	}
-
-	atomic_add(scan_active + 1, &zone->nr_scan_active);
-	count = atomic_read(&zone->nr_scan_active);
-	if (count >= SWAP_CLUSTER_MAX) {
-		atomic_set(&zone->nr_scan_active, 0);
-		sc->nr_to_scan = count;
-		refill_inactive_zone(zone, sc);
-	}
+	zone->nr_scan_active += (zone->nr_active >> sc->priority) + 1;
+	nr_active = zone->nr_scan_active;
+	if (nr_active >= SWAP_CLUSTER_MAX)
+		zone->nr_scan_active = 0;
+	else
+		nr_active = 0;
+
+	zone->nr_scan_inactive += (zone->nr_inactive >> sc->priority) + 1;
+	nr_inactive = zone->nr_scan_inactive;
+	if (nr_inactive >= SWAP_CLUSTER_MAX)
+		zone->nr_scan_inactive = 0;
+	else
+		nr_inactive = 0;
+
+	while (nr_active || nr_inactive) {
+		if (nr_active) {
+			sc->nr_to_scan = min(nr_active,
+					(unsigned long)SWAP_CLUSTER_MAX);
+			nr_active -= sc->nr_to_scan;
+			refill_inactive_zone(zone, sc);
+		}
 
-	atomic_add(scan_inactive, &zone->nr_scan_inactive);
-	count = atomic_read(&zone->nr_scan_inactive);
-	if (count >= SWAP_CLUSTER_MAX) {
-		atomic_set(&zone->nr_scan_inactive, 0);
-		sc->nr_to_scan = count;
-		shrink_cache(zone, sc);
+		if (nr_inactive) {
+			sc->nr_to_scan = min(nr_inactive,
+					(unsigned long)SWAP_CLUSTER_MAX);
+			nr_inactive -= sc->nr_to_scan;
+			shrink_cache(zone, sc);
+		}
 	}
 }
 
diff -puN include/linux/mmzone.h~vmscan-scan-sanity include/linux/mmzone.h
--- 25/include/linux/mmzone.h~vmscan-scan-sanity	2004-06-15 02:49:35.705783264 -0700
+++ 25-akpm/include/linux/mmzone.h	2004-06-15 02:49:48.283871104 -0700
@@ -118,8 +118,8 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct list_head	active_list;
 	struct list_head	inactive_list;
-	atomic_t		nr_scan_active;
-	atomic_t		nr_scan_inactive;
+	unsigned long		nr_scan_active;
+	unsigned long		nr_scan_inactive;
 	unsigned long		nr_active;
 	unsigned long		nr_inactive;
 	int			all_unreclaimable; /* All pages pinned */
diff -puN mm/page_alloc.c~vmscan-scan-sanity mm/page_alloc.c
--- 25/mm/page_alloc.c~vmscan-scan-sanity	2004-06-15 02:50:04.404420408 -0700
+++ 25-akpm/mm/page_alloc.c	2004-06-15 02:50:53.752918296 -0700
@@ -1482,8 +1482,8 @@ static void __init free_area_init_core(s
 				zone_names[j], realsize, batch);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
-		atomic_set(&zone->nr_scan_active, 0);
-		atomic_set(&zone->nr_scan_inactive, 0);
+		zone->nr_scan_active = 0;
+		zone->nr_scan_inactive = 0;
 		zone->nr_active = 0;
 		zone->nr_inactive = 0;
 		if (!size)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
