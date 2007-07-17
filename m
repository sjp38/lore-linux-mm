Message-ID: <469D3600.9050300@google.com>
Date: Tue, 17 Jul 2007 14:34:56 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [PATCH 3/6] cpuset write throttle
References: <469D3342.3080405@google.com>
In-Reply-To: <469D3342.3080405@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, Christoph Lameter <clameter@sgi.com>
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

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Ethan Solomita <solo@google.com>

---

Patch against 2.6.22-rc6-mm1

diff -uprN -X 0/Documentation/dontdiff 2/mm/page-writeback.c 3/mm/page-writeback.c
--- 2/mm/page-writeback.c	2007-07-11 21:15:47.000000000 -0700
+++ 3/mm/page-writeback.c	2007-07-16 18:30:01.000000000 -0700
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
@@ -121,13 +129,15 @@ static void background_writeout(unsigned
  * clamping level.
  */
 
-static unsigned long highmem_dirtyable_memory(unsigned long total)
+static unsigned long highmem_dirtyable_memory(nodemask_t *nodes, unsigned long total)
 {
 #ifdef CONFIG_HIGHMEM
 	int node;
 	unsigned long x = 0;
 
-	for_each_online_node(node) {
+	if (nodes == NULL)
+		nodes = &node_online_mask;
+	for_each_node_mask(node, *nodes) {
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
@@ -154,26 +164,74 @@ static unsigned long determine_dirtyable
 	x = global_page_state(NR_FREE_PAGES)
 		+ global_page_state(NR_INACTIVE)
 		+ global_page_state(NR_ACTIVE);
-	x -= highmem_dirtyable_memory(x);
+	x -= highmem_dirtyable_memory(NULL, x);
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
-static void
-get_dirty_limits(long *pbackground, long *pdirty,
-					struct address_space *mapping)
+static int
+get_dirty_limits(struct dirty_limits *dl, struct address_space *mapping,
+					nodemask_t *nodes)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
 	int unmapped_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = determine_dirtyable_memory();
+	unsigned long available_memory;
+	unsigned long nr_mapped;
 	struct task_struct *tsk;
+	int is_subset = 0;
 
-	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
-				global_page_state(NR_ANON_PAGES)) * 100) /
-					available_memory;
+#ifdef CONFIG_CPUSETS
+	if (unlikely(nodes &&
+			!nodes_subset(node_online_map, *nodes))) {
+		int node;
 
+		/*
+		 * Calculate the limits relative to the current cpuset.
+		 *
+		 * We do not disregard highmem because all nodes (except
+		 * maybe node 0) have either all memory in HIGHMEM (32 bit) or
+		 * all memory in non HIGHMEM (64 bit). If we would disregard
+		 * highmem then cpuset throttling would not work on 32 bit.
+		 */
+		is_subset = 1;
+		memset(dl, 0, sizeof(struct dirty_limits));
+		available_memory = 0;
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
+				node_page_state(node, NR_ACTIVE) +
+				node_page_state(node, NR_INACTIVE) +
+				node_page_state(node, NR_FREE_PAGES);
+			nr_mapped += node_page_state(node, NR_FILE_MAPPED) +
+				node_page_state(node, NR_ANON_PAGES);
+		}
+		available_memory -= highmem_dirtyable_memory(nodes,
+							     available_memory);
+		/* Ensure that we return >= 0 */
+		if (available_memory <= 0)
+			available_memory = 1;
+	} else
+#endif
+	{
+		/* Global limits */
+		dl->nr_dirty = global_page_state(NR_FILE_DIRTY);
+		dl->nr_unstable = global_page_state(NR_UNSTABLE_NFS);
+		dl->nr_writeback = global_page_state(NR_WRITEBACK);
+		available_memory = determine_dirtyable_memory();
+		nr_mapped = global_page_state(NR_FILE_MAPPED) +
+			global_page_state(NR_ANON_PAGES);
+	}
+
+	unmapped_ratio = 100 - (nr_mapped * 100 / available_memory);
 	dirty_ratio = vm_dirty_ratio;
 	if (dirty_ratio > unmapped_ratio / 2)
 		dirty_ratio = unmapped_ratio / 2;
@@ -192,8 +250,9 @@ get_dirty_limits(long *pbackground, long
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
@@ -206,8 +265,7 @@ get_dirty_limits(long *pbackground, long
 static void balance_dirty_pages(struct address_space *mapping)
 {
 	long nr_reclaimable;
-	long background_thresh;
-	long dirty_thresh;
+	struct dirty_limits dl;
 	unsigned long pages_written = 0;
 	unsigned long write_chunk = sync_writeback_pages();
 
@@ -222,11 +280,12 @@ static void balance_dirty_pages(struct a
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
@@ -240,13 +299,10 @@ static void balance_dirty_pages(struct a
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
@@ -255,8 +311,8 @@ static void balance_dirty_pages(struct a
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	if (nr_reclaimable + global_page_state(NR_WRITEBACK)
-		<= dirty_thresh && dirty_exceeded)
+	if (nr_reclaimable + dl.nr_writeback
+		<= dl.thresh_dirty && dirty_exceeded)
 			dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
@@ -271,8 +327,9 @@ static void balance_dirty_pages(struct a
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
@@ -329,8 +386,7 @@ EXPORT_SYMBOL(balance_dirty_pages_rateli
 
 void throttle_vm_writeout(gfp_t gfp_mask)
 {
-	long background_thresh;
-	long dirty_thresh;
+	struct dirty_limits dl;
 
 	if ((gfp_mask & (__GFP_FS|__GFP_IO)) != (__GFP_FS|__GFP_IO)) {
 		/*
@@ -342,27 +398,26 @@ void throttle_vm_writeout(gfp_t gfp_mask
 		return;
 	}
 
-        for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+	for ( ; ; ) {
+		get_dirty_limits(&dl, NULL, &node_online_map);
+
+		/*
+		 * Boost the allowable dirty threshold a bit for page
+		 * allocators so they don't get DoS'ed by heavy writers
+		 */
+		dl.thresh_dirty += dl.thresh_dirty / 10; /* wheeee... */
 
-                /*
-                 * Boost the allowable dirty threshold a bit for page
-                 * allocators so they don't get DoS'ed by heavy writers
-                 */
-                dirty_thresh += dirty_thresh / 10;      /* wheeee... */
-
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
-                congestion_wait(WRITE, HZ/10);
-        }
+		if (dl.nr_unstable + dl.nr_writeback <= dl.thresh_dirty)
+			break;
+		congestion_wait(WRITE, HZ/10);
+	}
 }
 
 /*
  * writeback at least _min_pages, and keep writing until the amount of dirty
  * memory is less than the background threshold, or until we're all clean.
  */
-static void background_writeout(unsigned long _min_pages, nodemask_t *unused)
+static void background_writeout(unsigned long _min_pages, nodemask_t *nodes)
 {
 	long min_pages = _min_pages;
 	struct writeback_control wbc = {
@@ -375,12 +430,11 @@ static void background_writeout(unsigned
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
