Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 92D646B00D2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 08:35:25 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] mm: writeback: cleanups in preparation for per-zone dirty limits
Date: Wed, 23 Nov 2011 14:34:15 +0100
Message-Id: <1322055258-3254-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
References: <1322055258-3254-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

From: Johannes Weiner <jweiner@redhat.com>

The next patch will introduce per-zone dirty limiting functions in
addition to the traditional global dirty limiting.

Rename determine_dirtyable_memory() to global_dirtyable_memory()
before adding the zone-specific version, and fix up its documentation.

Also, move the functions to determine the dirtyable memory and the
function to calculate the dirty limit based on that together so that
their relationship is more apparent and that they can be commented on
as a group.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Mel Gorman <mel@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 mm/page-writeback.c |  210 +++++++++++++++++++++++++-------------------------
 1 files changed, 105 insertions(+), 105 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 562f691..8856b7c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -131,6 +131,110 @@ static struct prop_descriptor vm_completions;
 static struct prop_descriptor vm_dirties;
 
 /*
+ * Work out the current dirty-memory clamping and background writeout
+ * thresholds.
+ *
+ * The main aim here is to lower them aggressively if there is a lot of mapped
+ * memory around.  To avoid stressing page reclaim with lots of unreclaimable
+ * pages.  It is better to clamp down on writers than to start swapping, and
+ * performing lots of scanning.
+ *
+ * We only allow 1/2 of the currently-unmapped memory to be dirtied.
+ *
+ * We don't permit the clamping level to fall below 5% - that is getting rather
+ * excessive.
+ *
+ * We make sure that the background writeout level is below the adjusted
+ * clamping level.
+ */
+
+static unsigned long highmem_dirtyable_memory(unsigned long total)
+{
+#ifdef CONFIG_HIGHMEM
+	int node;
+	unsigned long x = 0;
+
+	for_each_node_state(node, N_HIGH_MEMORY) {
+		struct zone *z =
+			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
+
+		x += zone_page_state(z, NR_FREE_PAGES) +
+		     zone_reclaimable_pages(z) -
+		     zone->dirty_balance_reserve;
+	}
+	/*
+	 * Make sure that the number of highmem pages is never larger
+	 * than the number of the total dirtyable memory. This can only
+	 * occur in very strange VM situations but we want to make sure
+	 * that this does not occur.
+	 */
+	return min(x, total);
+#else
+	return 0;
+#endif
+}
+
+/**
+ * global_dirtyable_memory - number of globally dirtyable pages
+ *
+ * Returns the global number of pages potentially available for dirty
+ * page cache.  This is the base value for the global dirty limits.
+ */
+unsigned long global_dirtyable_memory(void)
+{
+	unsigned long x;
+
+	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
+	    dirty_balance_reserve;
+
+	if (!vm_highmem_is_dirtyable)
+		x -= highmem_dirtyable_memory(x);
+
+	return x + 1;	/* Ensure that we never return 0 */
+}
+
+/*
+ * global_dirty_limits - background-writeback and dirty-throttling thresholds
+ *
+ * Calculate the dirty thresholds based on sysctl parameters
+ * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
+ * - vm.dirty_ratio             or  vm.dirty_bytes
+ * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
+ * real-time tasks.
+ */
+void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
+{
+	unsigned long background;
+	unsigned long dirty;
+	unsigned long uninitialized_var(available_memory);
+	struct task_struct *tsk;
+
+	if (!vm_dirty_bytes || !dirty_background_bytes)
+		available_memory = global_dirtyable_memory();
+
+	if (vm_dirty_bytes)
+		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
+	else
+		dirty = (vm_dirty_ratio * available_memory) / 100;
+
+	if (dirty_background_bytes)
+		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
+	else
+		background = (dirty_background_ratio * available_memory) / 100;
+
+	if (background >= dirty)
+		background = dirty / 2;
+	tsk = current;
+	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
+		background += background / 4;
+		dirty += dirty / 4;
+	}
+	*pbackground = background;
+	*pdirty = dirty;
+	trace_global_dirty_state(background, dirty);
+}
+
+/*
  * couple the period to the dirty_ratio:
  *
  *   period/2 ~ roundup_pow_of_two(dirty limit)
@@ -142,7 +246,7 @@ static int calc_period_shift(void)
 	if (vm_dirty_bytes)
 		dirty_total = vm_dirty_bytes / PAGE_SIZE;
 	else
-		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
+		dirty_total = (vm_dirty_ratio * global_dirtyable_memory()) /
 				100;
 	return 2 + ilog2(dirty_total - 1);
 }
@@ -298,69 +402,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
 }
 EXPORT_SYMBOL(bdi_set_max_ratio);
 
-/*
- * Work out the current dirty-memory clamping and background writeout
- * thresholds.
- *
- * The main aim here is to lower them aggressively if there is a lot of mapped
- * memory around.  To avoid stressing page reclaim with lots of unreclaimable
- * pages.  It is better to clamp down on writers than to start swapping, and
- * performing lots of scanning.
- *
- * We only allow 1/2 of the currently-unmapped memory to be dirtied.
- *
- * We don't permit the clamping level to fall below 5% - that is getting rather
- * excessive.
- *
- * We make sure that the background writeout level is below the adjusted
- * clamping level.
- */
-
-static unsigned long highmem_dirtyable_memory(unsigned long total)
-{
-#ifdef CONFIG_HIGHMEM
-	int node;
-	unsigned long x = 0;
-
-	for_each_node_state(node, N_HIGH_MEMORY) {
-		struct zone *z =
-			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
-
-		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z) -
-		     zone->dirty_balance_reserve;
-	}
-	/*
-	 * Make sure that the number of highmem pages is never larger
-	 * than the number of the total dirtyable memory. This can only
-	 * occur in very strange VM situations but we want to make sure
-	 * that this does not occur.
-	 */
-	return min(x, total);
-#else
-	return 0;
-#endif
-}
-
-/**
- * determine_dirtyable_memory - amount of memory that may be used
- *
- * Returns the numebr of pages that can currently be freed and used
- * by the kernel for direct mappings.
- */
-unsigned long determine_dirtyable_memory(void)
-{
-	unsigned long x;
-
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
-	    dirty_balance_reserve;
-
-	if (!vm_highmem_is_dirtyable)
-		x -= highmem_dirtyable_memory(x);
-
-	return x + 1;	/* Ensure that we never return 0 */
-}
-
 static unsigned long dirty_freerun_ceiling(unsigned long thresh,
 					   unsigned long bg_thresh)
 {
@@ -372,47 +413,6 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
 	return max(thresh, global_dirty_limit);
 }
 
-/*
- * global_dirty_limits - background-writeback and dirty-throttling thresholds
- *
- * Calculate the dirty thresholds based on sysctl parameters
- * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
- * - vm.dirty_ratio             or  vm.dirty_bytes
- * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
- * real-time tasks.
- */
-void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
-{
-	unsigned long background;
-	unsigned long dirty;
-	unsigned long uninitialized_var(available_memory);
-	struct task_struct *tsk;
-
-	if (!vm_dirty_bytes || !dirty_background_bytes)
-		available_memory = determine_dirtyable_memory();
-
-	if (vm_dirty_bytes)
-		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
-	else
-		dirty = (vm_dirty_ratio * available_memory) / 100;
-
-	if (dirty_background_bytes)
-		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
-	else
-		background = (dirty_background_ratio * available_memory) / 100;
-
-	if (background >= dirty)
-		background = dirty / 2;
-	tsk = current;
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
-		background += background / 4;
-		dirty += dirty / 4;
-	}
-	*pbackground = background;
-	*pdirty = dirty;
-	trace_global_dirty_state(background, dirty);
-}
-
 /**
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold
  * @bdi: the backing_dev_info to query
-- 
1.7.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
