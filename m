Date: Fri, 14 Sep 2007 15:23:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Configurable reclaim batch size 
Message-ID: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch allows a configuration of the basic reclaim unit for reclaim in 
vmscan.c. As memory sizes increase so will the frequency of running 
reclaim. Configuring the reclaim unit higher will reduce the number of 
times reclaim has to be entered and reduce the number of times that the 
zone locks have to be taken.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mmzone.h |    1 +
 kernel/sysctl.c        |    8 ++++++++
 mm/vmscan.c            |   41 +++++++++++++++++++++--------------------
 3 files changed, 30 insertions(+), 20 deletions(-)

Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-09-12 18:21:28.000000000 -0700
+++ linux-2.6/mm/vmscan.c	2007-09-12 18:31:13.000000000 -0700
@@ -57,11 +57,11 @@ struct scan_control {
 	/* Can pages be swapped as part of reclaim? */
 	int may_swap;
 
-	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
-	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
+	/* This context's  reclaim batch size. If freeing memory for
+	 * suspend, we effectively ignore reclaim_batch.
 	 * In this context, it doesn't matter that we scan the
 	 * whole list at once. */
-	int swap_cluster_max;
+	int reclaim_batch;
 
 	int swappiness;
 
@@ -105,6 +105,7 @@ struct scan_control {
  */
 int vm_swappiness = 60;
 long vm_total_pages;	/* The total number of pages which the VM controls */
+int sysctl_reclaim_batch = SWAP_CLUSTER_MAX;
 
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
@@ -159,7 +160,7 @@ unsigned long shrink_slab(unsigned long 
 	unsigned long ret = 0;
 
 	if (scanned == 0)
-		scanned = SWAP_CLUSTER_MAX;
+		scanned = sysctl_reclaim_batch;
 
 	if (!down_read_trylock(&shrinker_rwsem))
 		return 1;	/* Assume we'll be able to shrink next time */
@@ -338,7 +339,7 @@ static pageout_t pageout(struct page *pa
 		int res;
 		struct writeback_control wbc = {
 			.sync_mode = WB_SYNC_NONE,
-			.nr_to_write = SWAP_CLUSTER_MAX,
+			.nr_to_write = sysctl_reclaim_batch,
 			.range_start = 0,
 			.range_end = LLONG_MAX,
 			.nonblocking = 1,
@@ -801,7 +802,7 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_freed;
 		unsigned long nr_active;
 
-		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
+		nr_taken = isolate_lru_pages(sc->reclaim_batch,
 			     &zone->inactive_list,
 			     &page_list, &nr_scan, sc->order,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
@@ -1076,7 +1077,7 @@ static unsigned long shrink_zone(int pri
 	zone->nr_scan_active +=
 		(zone_page_state(zone, NR_ACTIVE) >> priority) + 1;
 	nr_active = zone->nr_scan_active;
-	if (nr_active >= sc->swap_cluster_max)
+	if (nr_active >= sc->reclaim_batch)
 		zone->nr_scan_active = 0;
 	else
 		nr_active = 0;
@@ -1084,7 +1085,7 @@ static unsigned long shrink_zone(int pri
 	zone->nr_scan_inactive +=
 		(zone_page_state(zone, NR_INACTIVE) >> priority) + 1;
 	nr_inactive = zone->nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
+	if (nr_inactive >= sc->reclaim_batch)
 		zone->nr_scan_inactive = 0;
 	else
 		nr_inactive = 0;
@@ -1092,14 +1093,14 @@ static unsigned long shrink_zone(int pri
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
 			nr_to_scan = min(nr_active,
-					(unsigned long)sc->swap_cluster_max);
+					(unsigned long)sc->reclaim_batch);
 			nr_active -= nr_to_scan;
 			shrink_active_list(nr_to_scan, zone, sc, priority);
 		}
 
 		if (nr_inactive) {
 			nr_to_scan = min(nr_inactive,
-					(unsigned long)sc->swap_cluster_max);
+					(unsigned long)sc->reclaim_batch);
 			nr_inactive -= nr_to_scan;
 			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
 								sc);
@@ -1181,7 +1182,7 @@ unsigned long try_to_free_pages(struct z
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.reclaim_batch = sysctl_reclaim_batch,
 		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
@@ -1210,7 +1211,7 @@ unsigned long try_to_free_pages(struct z
 			reclaim_state->reclaimed_slab = 0;
 		}
 		total_scanned += sc.nr_scanned;
-		if (nr_reclaimed >= sc.swap_cluster_max) {
+		if (nr_reclaimed >= sc.reclaim_batch) {
 			ret = 1;
 			goto out;
 		}
@@ -1222,8 +1223,8 @@ unsigned long try_to_free_pages(struct z
 		 * that's undesirable in laptop mode, where we *want* lumpy
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
-		if (total_scanned > sc.swap_cluster_max +
-					sc.swap_cluster_max / 2) {
+		if (total_scanned > sc.reclaim_batch +
+					sc.reclaim_batch / 2) {
 			wakeup_pdflush(laptop_mode ? 0 : total_scanned);
 			sc.may_writepage = 1;
 		}
@@ -1288,7 +1289,7 @@ static unsigned long balance_pgdat(pg_da
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_swap = 1,
-		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.reclaim_batch = sysctl_reclaim_batch,
 		.swappiness = vm_swappiness,
 		.order = order,
 	};
@@ -1388,7 +1389,7 @@ loop_again:
 			 * the reclaim ratio is low, start doing writepage
 			 * even in laptop mode
 			 */
-			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
+			if (total_scanned > sysctl_reclaim_batch * 2 &&
 			    total_scanned > nr_reclaimed + nr_reclaimed / 2)
 				sc.may_writepage = 1;
 		}
@@ -1407,7 +1408,7 @@ loop_again:
 		 * matches the direct reclaim path behaviour in terms of impact
 		 * on zone->*_priority.
 		 */
-		if (nr_reclaimed >= SWAP_CLUSTER_MAX)
+		if (nr_reclaimed >= sysctl_reclaim_batch)
 			break;
 	}
 out:
@@ -1600,7 +1601,7 @@ unsigned long shrink_all_memory(unsigned
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_swap = 0,
-		.swap_cluster_max = nr_pages,
+		.reclaim_batch = nr_pages,
 		.may_writepage = 1,
 		.swappiness = vm_swappiness,
 	};
@@ -1782,8 +1783,8 @@ static int __zone_reclaim(struct zone *z
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
-		.swap_cluster_max = max_t(unsigned long, nr_pages,
-					SWAP_CLUSTER_MAX),
+		.reclaim_batch = max_t(unsigned long, nr_pages,
+					sysctl_reclaim_batch),
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
 	};
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2007-09-12 18:28:58.000000000 -0700
+++ linux-2.6/include/linux/mmzone.h	2007-09-12 18:29:42.000000000 -0700
@@ -607,6 +607,7 @@ int sysctl_min_unmapped_ratio_sysctl_han
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 
+extern int sysctl_reclaim_batch;
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			struct file *, void __user *, size_t *, loff_t *);
 extern char numa_zonelist_order[];
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2007-09-12 18:27:12.000000000 -0700
+++ linux-2.6/kernel/sysctl.c	2007-09-12 18:28:48.000000000 -0700
@@ -900,6 +900,14 @@ static ctl_table vm_table[] = {
 		.strategy	= &sysctl_intvec,
 	},
 	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "reclaim_batch",
+		.data		= &sysctl_reclaim_batch,
+		.maxlen		= sizeof(sysctl_reclaim_batch),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 		.ctl_name	= VM_DROP_PAGECACHE,
 		.procname	= "drop_caches",
 		.data		= &sysctl_drop_caches,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
