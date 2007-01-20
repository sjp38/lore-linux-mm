Date: Fri, 19 Jan 2007 19:10:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070120031023.17491.98933.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
References: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/5] Per cpuset dirty ratio calculation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Make page writeback obey cpuset constraints

Currently dirty throttling does not work properly in a cpuset.

If f.e a cpuset contains only 1/10th of available memory then all of the
memory of a cpuset can be dirtied without any writes being triggered.
If all of the cpusets memory is dirty then only 10% of total memory is dirty.
The background writeback threshold is usually set at 10% and the synchrononous
threshold at 40%. So we are still below the global limits while the dirty
ratio in the cpuset is 100%! Writeback throttling and background writeout
do not work at all in such scenarios.

This patch makes dirty writeout cpuset aware. When determining the
dirty limits in get_dirty_limits() we calculate values based on the
nodes that are reachable from the current process (that has been
dirtying the page). Then we can trigger writeout based on the
dirty ratio of the memory in the cpuset.

We trigger writeout in a a cpuset specific way. We go through the dirty
inodes and search for inodes that have dirty pages on the nodes of the
active cpuset. If an inode fulfills that requirement then we begin writeout
of the dirty pages of that inode.

Adding up all the counters for each node in a cpuset may seem to be quite
an expensive operation (in particular for large cpusets with hundreds of
nodes) compared to just accessing the global counters if we do not have
a cpuset. However, please remember that the global counters were only
introduced recently. Before 2.6.18 we did add up per processor
counters for each processor on each invocation of get_dirty_limits().
We now add per node information which I think is equal or less effort
since there are less nodes than processors.

Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-rc5/mm/page-writeback.c
===================================================================
--- linux-2.6.20-rc5.orig/mm/page-writeback.c	2007-01-18 13:48:37.000000000 -0600
+++ linux-2.6.20-rc5/mm/page-writeback.c	2007-01-18 13:48:50.838955335 -0600
@@ -103,6 +103,14 @@ EXPORT_SYMBOL(laptop_mode);
 
 static void background_writeout(unsigned long _min_pages, nodemask_t *nodes);
 
+struct dirty_limits {
+	long thresh_background;
+	long thresh_dirty;
+	unsigned long nr_dirty;
+	unsigned long nr_unstable;
+	unsigned long nr_writeback;
+};
+
 /*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
@@ -120,31 +128,74 @@ static void background_writeout(unsigned
  * We make sure that the background writeout level is below the adjusted
  * clamping level.
  */
-static void
-get_dirty_limits(long *pbackground, long *pdirty,
-					struct address_space *mapping)
+static int
+get_dirty_limits(struct dirty_limits *dl, struct address_space *mapping,
+		nodemask_t *nodes)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
 	int unmapped_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = vm_total_pages;
+	unsigned long available_memory;
+	unsigned long high_memory;
+	unsigned long nr_mapped;
 	struct task_struct *tsk;
+	int is_subset = 0;
 
+#ifdef CONFIG_CPUSETS
+	/*
+	 * Calculate the limits relative to the current cpuset if necessary.
+	 */
+	if (unlikely(nodes &&
+			!nodes_subset(node_online_map, *nodes))) {
+		int node;
+
+		is_subset = 1;
+		memset(dl, 0, sizeof(struct dirty_limits));
+		available_memory = 0;
+		high_memory = 0;
+		nr_mapped = 0;
+		for_each_node_mask(node, *nodes) {
+			if (!node_online(node))
+				continue;
+			dl->nr_dirty += node_page_state(node, NR_FILE_DIRTY);
+			dl->nr_unstable +=
+				node_page_state(node, NR_UNSTABLE_NFS);
+			dl->nr_writeback +=
+				node_page_state(node, NR_WRITEBACK);
+			available_memory +=
+				NODE_DATA(node)->node_present_pages;
+#ifdef CONFIG_HIGHMEM
+			high_memory += NODE_DATA(node)
+				->node_zones[ZONE_HIGHMEM]->present_pages;
+#endif
+			nr_mapped += node_page_state(node, NR_FILE_MAPPED) +
+					node_page_state(node, NR_ANON_PAGES);
+		}
+	} else
+#endif
+	{
+		/* Global limits */
+		dl->nr_dirty = global_page_state(NR_FILE_DIRTY);
+		dl->nr_unstable = global_page_state(NR_UNSTABLE_NFS);
+		dl->nr_writeback = global_page_state(NR_WRITEBACK);
+		available_memory = vm_total_pages;
+		high_memory = totalhigh_pages;
+		nr_mapped = global_page_state(NR_FILE_MAPPED) +
+				global_page_state(NR_ANON_PAGES);
+	}
 #ifdef CONFIG_HIGHMEM
 	/*
 	 * If this mapping can only allocate from low memory,
 	 * we exclude high memory from our count.
 	 */
 	if (mapping && !(mapping_gfp_mask(mapping) & __GFP_HIGHMEM))
-		available_memory -= totalhigh_pages;
+		available_memory -= high_memory;
 #endif
 
 
-	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
-				global_page_state(NR_ANON_PAGES)) * 100) /
-					vm_total_pages;
+	unmapped_ratio = 100 - (nr_mapped * 100) / available_memory;
 
 	dirty_ratio = vm_dirty_ratio;
 	if (dirty_ratio > unmapped_ratio / 2)
@@ -164,8 +215,9 @@ get_dirty_limits(long *pbackground, long
 		background += background / 4;
 		dirty += dirty / 4;
 	}
-	*pbackground = background;
-	*pdirty = dirty;
+	dl->thresh_background = background;
+	dl->thresh_dirty = dirty;
+	return is_subset;
 }
 
 /*
@@ -178,8 +230,7 @@ get_dirty_limits(long *pbackground, long
 static void balance_dirty_pages(struct address_space *mapping)
 {
 	long nr_reclaimable;
-	long background_thresh;
-	long dirty_thresh;
+	struct dirty_limits dl;
 	unsigned long pages_written = 0;
 	unsigned long write_chunk = sync_writeback_pages();
 
@@ -194,11 +245,12 @@ static void balance_dirty_pages(struct a
 			.range_cyclic	= 1,
 		};
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, mapping);
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		if (nr_reclaimable + global_page_state(NR_WRITEBACK) <=
-			dirty_thresh)
+		if (get_dirty_limits(&dl, mapping,
+				&cpuset_current_mems_allowed))
+			wbc.nodes = &cpuset_current_mems_allowed;
+		nr_reclaimable = dl.nr_dirty + dl.nr_unstable;
+		if (nr_reclaimable + dl.nr_writeback <=
+			dl.thresh_dirty)
 				break;
 
 		if (!dirty_exceeded)
@@ -212,13 +264,10 @@ static void balance_dirty_pages(struct a
 		 */
 		if (nr_reclaimable) {
 			writeback_inodes(&wbc);
-			get_dirty_limits(&background_thresh,
-					 	&dirty_thresh, mapping);
-			nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-			if (nr_reclaimable +
-				global_page_state(NR_WRITEBACK)
-					<= dirty_thresh)
+			get_dirty_limits(&dl, mapping,
+				&cpuset_current_mems_allowed);
+			nr_reclaimable = dl.nr_dirty + dl.nr_unstable;
+			if (nr_reclaimable + dl.nr_writeback <= dl.thresh_dirty)
 						break;
 			pages_written += write_chunk - wbc.nr_to_write;
 			if (pages_written >= write_chunk)
@@ -227,8 +276,8 @@ static void balance_dirty_pages(struct a
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	if (nr_reclaimable + global_page_state(NR_WRITEBACK)
-		<= dirty_thresh && dirty_exceeded)
+	if (nr_reclaimable + dl.nr_writeback
+		<= dl.thresh_dirty && dirty_exceeded)
 			dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
@@ -243,8 +292,9 @@ static void balance_dirty_pages(struct a
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	     (!laptop_mode && (nr_reclaimable > background_thresh)))
-		pdflush_operation(background_writeout, 0, NULL);
+	     (!laptop_mode && (nr_reclaimable > dl.thresh_background)))
+		pdflush_operation(background_writeout, 0,
+			&cpuset_current_mems_allowed);
 }
 
 void set_page_dirty_balance(struct page *page)
@@ -301,21 +351,19 @@ EXPORT_SYMBOL(balance_dirty_pages_rateli
 
 void throttle_vm_writeout(void)
 {
-	long background_thresh;
-	long dirty_thresh;
+	struct dirty_limits dl;
 
         for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&dl, NULL, &node_online_map);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
                  * allocators so they don't get DoS'ed by heavy writers
                  */
-                dirty_thresh += dirty_thresh / 10;      /* wheeee... */
+                dl.thresh_dirty += dl.thresh_dirty / 10; /* wheeee... */
 
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
+                if (dl.nr_unstable + dl.nr_writeback <= dl.thresh_dirty)
+                       break;
                 congestion_wait(WRITE, HZ/10);
         }
 }
@@ -325,7 +373,7 @@ void throttle_vm_writeout(void)
  * writeback at least _min_pages, and keep writing until the amount of dirty
  * memory is less than the background threshold, or until we're all clean.
  */
-static void background_writeout(unsigned long _min_pages, nodemask_t *unused)
+static void background_writeout(unsigned long _min_pages, nodemask_t *nodes)
 {
 	long min_pages = _min_pages;
 	struct writeback_control wbc = {
@@ -338,12 +386,11 @@ static void background_writeout(unsigned
 	};
 
 	for ( ; ; ) {
-		long background_thresh;
-		long dirty_thresh;
+		struct dirty_limits dl;
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
-		if (global_page_state(NR_FILE_DIRTY) +
-			global_page_state(NR_UNSTABLE_NFS) < background_thresh
+		if (get_dirty_limits(&dl, NULL, nodes))
+			wbc.nodes = nodes;
+		if (dl.nr_dirty + dl.nr_unstable < dl.thresh_background
 				&& min_pages <= 0)
 			break;
 		wbc.encountered_congestion = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
