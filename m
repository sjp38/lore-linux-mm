Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B39A39000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 03:18:02 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 2/5] mm: writeback: cleanups in preparation for per-zone dirty limits
Date: Fri, 30 Sep 2011 09:17:21 +0200
Message-Id: <1317367044-475-3-git-send-email-jweiner@redhat.com>
In-Reply-To: <1317367044-475-1-git-send-email-jweiner@redhat.com>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Shaohua Li <shaohua.li@intel.com>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

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
---
 mm/page-writeback.c |   92 +++++++++++++++++++++++++-------------------------
 1 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c8acf8a..78604a6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -186,12 +186,12 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 }
 
 /**
- * determine_dirtyable_memory - amount of memory that may be used
+ * global_dirtyable_memory - number of globally dirtyable pages
  *
- * Returns the numebr of pages that can currently be freed and used
- * by the kernel for direct mappings.
+ * Returns the global number of pages potentially available for dirty
+ * page cache.  This is the base value for the global dirty limits.
  */
-static unsigned long determine_dirtyable_memory(void)
+static unsigned long global_dirtyable_memory(void)
 {
 	unsigned long x;
 
@@ -205,6 +205,47 @@ static unsigned long determine_dirtyable_memory(void)
 }
 
 /*
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
@@ -216,7 +257,7 @@ static int calc_period_shift(void)
 	if (vm_dirty_bytes)
 		dirty_total = vm_dirty_bytes / PAGE_SIZE;
 	else
-		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
+		dirty_total = (vm_dirty_ratio * global_dirtyable_memory()) /
 				100;
 	return 2 + ilog2(dirty_total - 1);
 }
@@ -416,47 +457,6 @@ static unsigned long hard_dirty_limit(unsigned long thresh)
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
1.7.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
