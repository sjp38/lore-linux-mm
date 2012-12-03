Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 5A3DF6B005D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 01:42:15 -0500 (EST)
Date: Mon, 3 Dec 2012 15:42:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram, OOM, and speed of allocation
Message-ID: <20121203064212.GA4569@blaptop>
References: <CAA25o9S5zpH_No+xgYuFSAKSRkQ=19Vf_aLgO1UWiajQxtjrpg@mail.gmail.com>
 <CAA25o9TnmSqBe48EN+9E6E8EiSzKf275AUaAijdk3wxg6QV2kQ@mail.gmail.com>
 <CAA25o9RiNfwtoeMBk=PLg-X_2wPSHuYLztONw1KToeOx9pUHGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9RiNfwtoeMBk=PLg-X_2wPSHuYLztONw1KToeOx9pUHGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>

Hi Luigi,

On Thu, Nov 29, 2012 at 11:31:46AM -0800, Luigi Semenzato wrote:
> Oh well, I found the problem, it's laptop_mode.  We keep it on by
> default.  When I turn it off, I can allocate as fast as I can, and no
> OOMs happen until swap is exhausted.
> 
> I don't think this is a desirable behavior even for laptop_mode, so if
> anybody wants to help me debug it (or wants my help in debugging it)
> do let me know.

Interesting.

Just a quick trial.
Could you try this patch based on your kernel without my previous patch "
wakeup kswapd in direct reclaim path"?
If you still has a trouble about stopped kswapd, plz apply both patches.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 32bc955..4a7fe5d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -725,6 +725,7 @@ typedef struct pglist_data {
 	struct task_struct *kswapd;	/* Protected by lock_memory_hotplug() */
 	int kswapd_max_order;
 	enum zone_type classzone_idx;
+	bool may_writepage;
 } pg_data_t;
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 53dcde9..1952420 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -68,6 +68,11 @@ struct scan_control {
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
+	/*
+	 * If laptop_mode is true, you don't need to set may_writepage.
+	 * Otherwise, you should set may_writepage explicitly.
+	 */
+	bool laptop_mode;
 	int may_writepage;
 
 	/* Can mapped pages be reclaimed? */
@@ -1846,6 +1851,15 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	unsigned long nr_reclaimed, nr_scanned;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
+	struct zone *zone = lruvec_zone(lruvec);
+	pg_data_t *pgdat = zone->zone_pgdat;
+
+	if (sc->laptop_mode) {
+		if (pgdat->may_writepage)
+			sc->may_writepage = 1;
+		else
+			sc->may_writepage = 0;
+	}
 
 restart:
 	nr_reclaimed = 0;
@@ -2145,11 +2159,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
-		if (total_scanned > writeback_threshold) {
-			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned,
+		if (total_scanned > writeback_threshold)
+			wakeup_flusher_threads(sc->laptop_mode ? 0 : total_scanned,
 						WB_REASON_TRY_TO_FREE_PAGES);
-			sc->may_writepage = 1;
-		}
 
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
@@ -2289,7 +2301,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
-		.may_writepage = !laptop_mode,
+		.laptop_mode = laptop_mode,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -2331,7 +2343,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	struct scan_control sc = {
 		.nr_scanned = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.may_writepage = !laptop_mode,
+		.laptop_mode = laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.order = 0,
@@ -2370,7 +2382,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 	unsigned long nr_reclaimed;
 	int nid;
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.laptop_mode = laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
@@ -2585,7 +2597,7 @@ loop_again:
 	total_scanned = 0;
 	sc.priority = DEF_PRIORITY;
 	sc.nr_reclaimed = 0;
-	sc.may_writepage = !laptop_mode;
+	sc.laptop_mode = laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
 	do {
@@ -2722,7 +2734,7 @@ loop_again:
 			 */
 			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
 			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
-				sc.may_writepage = 1;
+				zone->zone_pgdat->may_writepage = true;
 
 			if (zone->all_unreclaimable) {
 				if (end_zone && end_zone == i)
@@ -2749,6 +2761,7 @@ loop_again:
 				 * speculatively avoid congestion waits
 				 */
 				zone_clear_flag(zone, ZONE_CONGESTED);
+				zone->zone_pgdat->may_writepage = false;
 				if (i <= *classzone_idx)
 					balanced += zone->present_pages;
 			}
@@ -3112,6 +3125,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.gfp_mask = GFP_HIGHUSER_MOVABLE,
 		.may_swap = 1,
 		.may_unmap = 1,
+		.laptop_mode = false,
 		.may_writepage = 1,
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
@@ -3299,6 +3313,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
+		.laptop_mode = false,
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,

> 
> Thanks!
> Luigi
> 
> On Thu, Nov 29, 2012 at 10:46 AM, Luigi Semenzato <semenzato@google.com> wrote:
> > Minchan:
> >
> > I tried your suggestion to move the call to wake_all_kswapd from after
> > "restart:" to after "rebalance:".  The behavior is still similar, but
> > slightly improved.  Here's what I see.
> >
> > Allocating as fast as I can: 1.5 GB of the 3 GB of zram swap are used,
> > then OOM kills happen, and the system ends up with 1 GB swap used, 2
> > unused.
> >
> > Allocating 10 MB/s: some kills happen when only 1 to 1.5 GB are used,
> > and continue happening while swap fills up.  Eventually swap fills up
> > completely.  This is better than before (could not go past about 1 GB
> > of swap used), but there are too many kills too early.  I would like
> > to see no OOM kills until swap is full or almost full.
> >
> > Allocating 20 MB/s: almost as good as with 10 MB/s, but more kills
> > happen earlier, and not all swap space is used (400 MB free at the
> > end).
> >
> > This is with 200 processes using 20 MB each, and 2:1 compression ratio.
> >
> > So it looks like kswapd is still not aggressive enough in pushing
> > pages out.  What's the best way of changing that?  Play around with
> > the watermarks?
> >
> > Incidentally, I also tried removing the min_filelist_kbytes hacky
> > patch, but, as usual, the system thrashes so badly that it's
> > impossible to complete any experiment.  I set it to a lower minimum
> > amount of free file pages, 10 MB instead of the 50 MB which we use
> > normally, and I could run with some thrashing, but I got the same
> > results.
> >
> > Thanks!
> > Luigi
> >
> >
> > On Wed, Nov 28, 2012 at 4:31 PM, Luigi Semenzato <semenzato@google.com> wrote:
> >> I am beginning to understand why zram appears to work fine on our x86
> >> systems but not on our ARM systems.  The bottom line is that swapping
> >> doesn't work as I would expect when allocation is "too fast".
> >>
> >> In one of my tests, opening 50 tabs simultaneously in a Chrome browser
> >> on devices with 2 GB of RAM and a zram-disk of 3 GB (uncompressed), I
> >> was observing that on the x86 device all of the zram swap space was
> >> used before OOM kills happened, but on the ARM device I would see OOM
> >> kills when only about 1 GB (out of 3) was swapped out.
> >>
> >> I wrote a simple program to understand this behavior.  The program
> >> (called "hog") allocates memory and fills it with a mix of
> >> incompressible data (from /dev/urandom) and highly compressible data
> >> (1's, just to avoid zero pages) in a given ratio.  The memory is never
> >> touched again.
> >>
> >> It turns out that if I don't limit the allocation speed, I see
> >> premature OOM kills also on the x86 device.  If I limit the allocation
> >> to 10 MB/s, the premature OOM kills stop happening on the x86 device,
> >> but still happen on the ARM device.  If I further limit the allocation
> >> speed to 5 Mb/s, the premature OOM kills disappear also from the ARM
> >> device.
> >>
> >> I have noticed a few time constants in the MM whose value is not well
> >> explained, and I am wondering if the code is tuned for some ideal
> >> system that doesn't behave like ours (considering, for instance, that
> >> zram is much faster than swapping to a disk device, but it also uses
> >> more CPU).  If this is plausible, I am wondering if anybody has
> >> suggestions for changes that I could try out to obtain a better
> >> behavior with a higher allocation speed.
> >>
> >> Thanks!
> >> Luigi
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
