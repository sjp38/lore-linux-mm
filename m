Received: from amidala (dsl-202-72-159-76.wa.westnet.com.au [202.72.159.76])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by oracle.bridgewayconsulting.com.au (Postfix) with ESMTP id 39F6C1F8007
	for <linux-mm@kvack.org>; Thu, 13 Jan 2005 14:14:21 +0800 (WST)
Date: Thu, 13 Jan 2005 14:14:02 +0800
From: Bernard Blackham <bernard@blackham.com.au>
Subject: Odd kswapd behaviour after suspending in 2.6.11-rc1
Message-ID: <20050113061401.GA7404@blackham.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

(Please Cc replies to me)

Hi,

Shortly after suspending with Software Suspend 2 in 2.6.11-rc1,
kswapd begins to act most strangely. I can't test with the vanilla
swsusp, as it Oopses on suspend. Using Software Suspend 2, I only
need to initiate the suspend then abort (which gets far enough to
call shrink_all_memory which I believe might be what triggers it).
Vanilla swsusp also calls shrink_all_memory(10000) so I imagine it
would probably suffer the same bug if it worked.

The machine has 1GB of RAM, kernel is using 4G highmem. Before
suspending, only about 200MB of memory is used. The machine comes
back fine, and all is well, until...

Within a minute or less, kswapd will try to flush out as much data
to disk as it possibly can, making the machine unusable in process.
Of the 200MB of memory, it flushes 170MB out to swap, leaving 30MB
in RAM. While it's doing this, kswapd's call trace looks like:

 [schedule_timeout+94/176] schedule_timeout+0x5e/0xb0
 [io_schedule_timeout+17/32] io_schedule_timeout+0x11/0x20
 [blk_congestion_wait+110/144] blk_congestion_wait+0x6e/0x90
 [balance_pgdat+572/912] balance_pgdat+0x23c/0x390
 [kswapd+221/256] kswapd+0xdd/0x100
 [kernel_thread_helper+5/16] kernel_thread_helper+0x5/0x10

I'm guessing it stops when it can't possibly flush out any more
memory, and goes back to idling:

 [kswapd+171/224] kswapd+0xab/0xe0
 [kernel_thread_helper+5/16] kernel_thread_helper+0x5/0x10

>From here on, the machine acts as normal. I can swapoff and swapon
again to flush things back into memory and life is happy.

If I disable the swap partition after resuming, instead of flushing
stuff out to swap, kswapd will simply alternate between R and D
states, consuming CPU and making the machine sluggish. I let it sit
there for a few minutes like this, then turned swap back on, at
which point it did the same thing as above (flush everything out to
swap).

If I set /proc/sys/vm/swappiness to 0, it only flushes about 30 or
40MB out to swap before returning to normal, but it still does it.
(swappiness is defaulting to 60).

I reverted the changes to mm/vmscan.c between 2.6.10 and 2.6.11-rc1
with the attached patch (applies forwards over the top of
2.6.11-rc1), and I no longer get any kswapd weirdness.  Is there
something in here misbehaving?

I'm happy to provide any more info, or test any patches.

Thanks in advance,

Bernard.

-- 
 Bernard Blackham <bernard at blackham dot com dot au>

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=94-kswapd-changes

diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	2005-01-11 20:02:35 -08:00
+++ b/mm/vmscan.c	2005-01-11 20:02:35 -08:00
@@ -361,6 +361,8 @@
 		int may_enter_fs;
 		int referenced;
 
+		cond_resched();
+
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
@@ -369,14 +371,14 @@
 
 		BUG_ON(PageActive(page));
 
-		if (PageWriteback(page))
-			goto keep_locked;
-
 		sc->nr_scanned++;
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
 
+		if (PageWriteback(page))
+			goto keep_locked;
+
 		referenced = page_referenced(page, 1, sc->priority <= 0);
 		/* In active use or really unfreeable?  Activate it. */
 		if (referenced && page_mapping_inuse(page))
@@ -710,6 +712,7 @@
 		reclaim_mapped = 1;
 
 	while (!list_empty(&l_hold)) {
+		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
 		if (page_mapped(page)) {
@@ -968,7 +971,7 @@
  * the page allocator fallback scheme to ensure that aging of pages is balanced
  * across the zones.
  */
-static int balance_pgdat(pg_data_t *pgdat, int nr_pages)
+static int balance_pgdat(pg_data_t *pgdat, int nr_pages, int order)
 {
 	int to_free = nr_pages;
 	int all_zones_ok;
@@ -1014,7 +1017,8 @@
 						priority != DEF_PRIORITY)
 					continue;
 
-				if (zone->free_pages <= zone->pages_high) {
+				if (!zone_watermark_ok(zone, order,
+						zone->pages_high, 0, 0, 0)) {
 					end_zone = i;
 					goto scan;
 				}
@@ -1049,7 +1053,8 @@
 				continue;
 
 			if (nr_pages == 0) {	/* Not software suspend */
-				if (zone->free_pages <= zone->pages_high)
+				if (!zone_watermark_ok(zone, order,
+						zone->pages_high, end_zone, 0, 0))
 					all_zones_ok = 0;
 			}
 			zone->temp_priority = priority;
@@ -1063,6 +1068,7 @@
 			shrink_slab(sc.nr_scanned, GFP_KERNEL, lru_pages);
 			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_reclaimed += sc.nr_reclaimed;
+			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
 				continue;
 			if (zone->pages_scanned >= (zone->nr_active +
@@ -1126,6 +1132,7 @@
  */
 static int kswapd(void *p)
 {
+	unsigned long order;
 	pg_data_t *pgdat = (pg_data_t*)p;
 	struct task_struct *tsk = current;
 	DEFINE_WAIT(wait);
@@ -1154,14 +1161,28 @@
 	 */
 	tsk->flags |= PF_MEMALLOC|PF_KSWAPD;
 
+	order = 0;
 	for ( ; ; ) {
+		unsigned long new_order;
 		if (current->flags & PF_FREEZE)
 			refrigerator(PF_FREEZE);
+
 		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
-		schedule();
+		new_order = pgdat->kswapd_max_order;
+		pgdat->kswapd_max_order = 0;
+		if (order < new_order) {
+			/*
+			 * Don't sleep if someone wants a larger 'order'
+			 * allocation
+			 */
+			order = new_order;
+		} else {
+			schedule();
+			order = pgdat->kswapd_max_order;
+		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
-		balance_pgdat(pgdat, 0);
+		balance_pgdat(pgdat, 0, order);
 	}
 	return 0;
 }
@@ -1197,7 +1224,7 @@
 	current->reclaim_state = &reclaim_state;
 	for_each_pgdat(pgdat) {
 		int freed;
-		freed = balance_pgdat(pgdat, nr_to_free);
+		freed = balance_pgdat(pgdat, nr_to_free, 0);
 		ret += freed;
 		nr_to_free -= freed;
 		if (nr_to_free <= 0)
--- linux-2.6.11-rc1/mm/vmscan.c.orig	2005-01-13 13:41:35.000000000 +0800
+++ linux-2.6.11-rc1/mm/vmscan.c	2005-01-13 13:41:55.000000000 +0800
@@ -1193,15 +1193,20 @@
 /*
  * A zone is low on free memory, so wake its kswapd task to service it.
  */
-void wakeup_kswapd(struct zone *zone)
+void wakeup_kswapd(struct zone *zone, int order)
 {
+	pg_data_t *pgdat;
+
 	if (test_suspend_state(SUSPEND_LRU_FREEZE))
 		return;
 	if (zone->present_pages == 0)
 		return;
 
-	if (zone->free_pages > zone->pages_low)
+	pgdat = zone->zone_pgdat;
+	if (zone_watermark_ok(zone, order, zone->pages_low, 0, 0, 0))
 		return;
+	if (pgdat->kswapd_max_order < order)
+		pgdat->kswapd_max_order = order;
 	if (!waitqueue_active(&zone->zone_pgdat->kswapd_wait))
 		return;
 	wake_up_interruptible(&zone->zone_pgdat->kswapd_wait);
--- linux-2.6.11-rc1/mm/page_alloc.c.orig	2005-01-13 12:56:20.000000000 +0800
+++ linux-2.6.11-rc1/mm/page_alloc.c	2005-01-13 12:56:27.000000000 +0800
@@ -741,7 +741,7 @@
 	}
 
 	for (i = 0; (z = zones[i]) != NULL; i++)
-		wakeup_kswapd(z, order);
+		wakeup_kswapd(z);
 
 	/*
 	 * Go through the zonelist again. Let __GFP_HIGH and allocations
--- linux-2.6.11-rc1/include/linux/mmzone.h.orig	2005-01-13 12:58:06.000000000 +0800
+++ linux-2.6.11-rc1/include/linux/mmzone.h	2005-01-13 12:58:11.000000000 +0800
@@ -278,7 +278,7 @@
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free);
 void build_all_zonelists(void);
-void wakeup_kswapd(struct zone *zone, int order);
+void wakeup_kswapd(struct zone *zone);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int alloc_type, int can_try_harder, int gfp_high);
 

--bg08WKrSYDhXBjb5--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
