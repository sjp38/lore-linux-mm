Date: Sat, 11 Feb 2006 01:46:49 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Get rid of scan_control
Message-Id: <20060211014649.7cb3b9e2.akpm@osdl.org>
In-Reply-To: <20060211013255.20832152.akpm@osdl.org>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
	<20060211045355.GA3318@dmt.cnet>
	<20060211013255.20832152.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com, clameter@engr.sgi.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> I found that scan_control wasn't
>  really a success.  We had one bug due to failing to initialise something in
>  it, and we're fiddling with fields all over the place.  It just seemed to
>  obfuscate the code, make it harder to work with, harder to check that
>  everything was correct.

I spose we could do this, which is a bit of an improvement.

But the problems do remain, really.  The one which creeps me out is looking
at a piece of code which does:


	foo(&sc);
	if (sc.bar ...)

and just not knowing whether foo() altered sc.bar.


diff -puN mm/vmscan.c~vmscan-scan_control-cleanup mm/vmscan.c
--- devel/mm/vmscan.c~vmscan-scan_control-cleanup	2006-02-11 01:34:04.000000000 -0800
+++ devel-akpm/mm/vmscan.c	2006-02-11 01:41:57.000000000 -0800
@@ -1414,13 +1414,14 @@ int try_to_free_pages(struct zone **zone
 	int ret = 0;
 	int total_scanned = 0, total_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	struct scan_control sc;
 	unsigned long lru_pages = 0;
 	int i;
-
-	sc.gfp_mask = gfp_mask;
-	sc.may_writepage = !laptop_mode;
-	sc.may_swap = 1;
+	struct scan_control sc = {
+		.gfp_mask = gfp_mask,
+		.may_writepage = !laptop_mode,
+		.swap_cluster_max = SWAP_CLUSTER_MAX,
+		.may_swap = 1,
+	};
 
 	inc_page_state(allocstall);
 
@@ -1438,7 +1439,6 @@ int try_to_free_pages(struct zone **zone
 		sc.nr_mapped = read_page_state(nr_mapped);
 		sc.nr_scanned = 0;
 		sc.nr_reclaimed = 0;
-		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
 		if (!priority)
 			disable_swap_token();
 		shrink_caches(priority, zones, &sc);
@@ -1461,7 +1461,8 @@ int try_to_free_pages(struct zone **zone
 		 * that's undesirable in laptop mode, where we *want* lumpy
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
-		if (total_scanned > sc.swap_cluster_max + sc.swap_cluster_max/2) {
+		if (total_scanned > sc.swap_cluster_max +
+					sc.swap_cluster_max / 2) {
 			wakeup_pdflush(laptop_mode ? 0 : total_scanned);
 			sc.may_writepage = 1;
 		}
@@ -1515,14 +1516,16 @@ static int balance_pgdat(pg_data_t *pgda
 	int i;
 	int total_scanned, total_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	struct scan_control sc;
+	struct scan_control sc = {
+		.gfp_mask = GFP_KERNEL,
+		.may_writepage = !laptop_mode,
+		.may_swap = 1,
+		.swap_cluster_max = nr_pages ? nr_pages : SWAP_CLUSTER_MAX,
+	};
 
 loop_again:
 	total_scanned = 0;
 	total_reclaimed = 0;
-	sc.gfp_mask = GFP_KERNEL;
-	sc.may_writepage = !laptop_mode;
-	sc.may_swap = 1;
 	sc.nr_mapped = read_page_state(nr_mapped);
 
 	inc_page_state(pageoutrun);
@@ -1604,7 +1607,6 @@ scan:
 				zone->prev_priority = priority;
 			sc.nr_scanned = 0;
 			sc.nr_reclaimed = 0;
-			sc.swap_cluster_max = nr_pages? nr_pages : SWAP_CLUSTER_MAX;
 			atomic_inc(&zone->reclaim_in_progress);
 			shrink_zone(priority, zone, &sc);
 			atomic_dec(&zone->reclaim_in_progress);
@@ -1856,13 +1858,19 @@ int zone_reclaim_interval __read_mostly 
  */
 int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 {
-	int nr_pages;
+	int nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	struct scan_control sc;
 	cpumask_t mask;
 	int node_id;
 	int priority;
+	struct scan_control sc = {
+		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
+		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
+		.nr_mapped = read_page_state(nr_mapped),
+		.swap_cluster_max = max(nr_pages, SWAP_CLUSTER_MAX),
+		.gfp_mask = gfp_mask,
+	};
 
 	if (time_before(jiffies,
 		zone->last_unsuccessful_zone_reclaim + zone_reclaim_interval))
@@ -1878,21 +1886,8 @@ int zone_reclaim(struct zone *zone, gfp_
 	if (!cpus_empty(mask) && node_id != numa_node_id())
 		return 0;
 
-	sc.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE);
-	sc.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP);
-	sc.nr_scanned = 0;
-	sc.nr_reclaimed = 0;
-	sc.nr_mapped = read_page_state(nr_mapped);
-	sc.gfp_mask = gfp_mask;
-
 	disable_swap_token();
 
-	nr_pages = 1 << order;
-	if (nr_pages > SWAP_CLUSTER_MAX)
-		sc.swap_cluster_max = nr_pages;
-	else
-		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
-
 	cond_resched();
 	p->flags |= PF_MEMALLOC;
 	reclaim_state.reclaimed_slab = 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
