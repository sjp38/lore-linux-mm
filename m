Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 870698D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 16:39:11 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v5 9/9] memcg: check memcg dirty limits in page writeback
Date: Fri, 25 Feb 2011 13:36:00 -0800
Message-Id: <1298669760-26344-10-git-send-email-gthelen@google.com>
In-Reply-To: <1298669760-26344-1-git-send-email-gthelen@google.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>, Greg Thelen <gthelen@google.com>

If the current process is in a non-root memcg, then
balance_dirty_pages() will consider the memcg dirty limits as well as
the system-wide limits.  This allows different cgroups to have distinct
dirty limits which trigger direct and background writeback at different
levels.

If called with a mem_cgroup, then throttle_vm_writeout() should query
the given cgroup for its dirty memory usage limits.

Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
---
Changelog since v4:
- Added missing 'struct mem_cgroup' forward declaration in writeback.h.
- Made throttle_vm_writeout() memcg aware.
- Removed previously added dirty_writeback_pages() which is no longer needed.
- Added logic to balance_dirty_pages() to throttle if over foreground memcg
  limit.

Changelog since v3:
- Leave determine_dirtyable_memory() static.  v3 made is non-static.
- balance_dirty_pages() now considers both system and memcg dirty limits and
  usage data.  This data is retrieved with global_dirty_info() and
  memcg_dirty_info().  

 include/linux/writeback.h |    3 +-
 mm/page-writeback.c       |  112 +++++++++++++++++++++++++++++++++------------
 mm/vmscan.c               |    2 +-
 3 files changed, 86 insertions(+), 31 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index a06fb38..e4688d6 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -8,6 +8,7 @@
 #include <linux/fs.h>
 
 struct backing_dev_info;
+struct mem_cgroup;
 
 extern spinlock_t inode_lock;
 
@@ -105,7 +106,7 @@ void laptop_mode_timer_fn(unsigned long data);
 #else
 static inline void laptop_sync_completion(void) { }
 #endif
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 8d61cfa..5557e0c 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -398,47 +398,72 @@ unsigned long determine_dirtyable_memory(void)
 }
 
 /*
+ * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
+ * real-time tasks.
+ */
+static inline void adjust_dirty_info(struct dirty_info *info)
+{
+	struct task_struct *tsk;
+
+	if (info->background_thresh >= info->dirty_thresh)
+		info->background_thresh = info->dirty_thresh / 2;
+	tsk = current;
+	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
+		info->background_thresh += info->background_thresh / 4;
+		info->dirty_thresh += info->dirty_thresh / 4;
+	}
+}
+
+/*
  * global_dirty_info - return dirty thresholds and usage metrics
  *
  * Calculate the dirty thresholds based on sysctl parameters
  * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
  * - vm.dirty_ratio             or  vm.dirty_bytes
- * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
- * real-time tasks.
  */
 void global_dirty_info(struct dirty_info *info)
 {
-	unsigned long background;
-	unsigned long dirty;
 	unsigned long uninitialized_var(available_memory);
-	struct task_struct *tsk;
 
 	if (!vm_dirty_bytes || !dirty_background_bytes)
 		available_memory = determine_dirtyable_memory();
 
 	if (vm_dirty_bytes)
-		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
+		info->dirty_thresh = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
 	else
-		dirty = (vm_dirty_ratio * available_memory) / 100;
+		info->dirty_thresh = (vm_dirty_ratio * available_memory) / 100;
 
 	if (dirty_background_bytes)
-		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
+		info->background_thresh =
+			DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
 	else
-		background = (dirty_background_ratio * available_memory) / 100;
+		info->background_thresh =
+			(dirty_background_ratio * available_memory) / 100;
 
 	info->nr_file_dirty = global_page_state(NR_FILE_DIRTY);
 	info->nr_writeback = global_page_state(NR_WRITEBACK);
 	info->nr_unstable_nfs = global_page_state(NR_UNSTABLE_NFS);
 
-	if (background >= dirty)
-		background = dirty / 2;
-	tsk = current;
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
-		background += background / 4;
-		dirty += dirty / 4;
-	}
-	info->background_thresh = background;
-	info->dirty_thresh = dirty;
+	adjust_dirty_info(info);
+}
+
+/*
+ * Calculate the background-writeback and dirty-throttling thresholds and dirty
+ * usage metrics from the current task's memcg dirty limit parameters.  Returns
+ * false if no memcg limits exist.
+ *
+ * @memcg may be NULL if the current task's memcg should be used.
+ * @info is the location where the dirty information is written.
+ */
+static bool memcg_dirty_info(struct mem_cgroup *memcg, struct dirty_info *info)
+{
+	unsigned long available_memory = determine_dirtyable_memory();
+
+	if (!mem_cgroup_hierarchical_dirty_info(available_memory, memcg, info))
+		return false;
+
+	adjust_dirty_info(info);
+	return true;
 }
 
 /*
@@ -477,12 +502,14 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
  * If we're over `background_thresh' then the writeback threads are woken to
- * perform some writeout.
+ * perform some writeout.  The current task may have per-memcg dirty
+ * limits, which are also checked.
  */
 static void balance_dirty_pages(struct address_space *mapping,
 				unsigned long write_chunk)
 {
 	struct dirty_info sys_info;
+	struct dirty_info memcg_info;
 	long bdi_nr_reclaimable;
 	long bdi_nr_writeback;
 	unsigned long bdi_thresh;
@@ -500,18 +527,27 @@ static void balance_dirty_pages(struct address_space *mapping,
 		};
 
 		global_dirty_info(&sys_info);
+		if (!memcg_dirty_info(NULL, &memcg_info))
+			memcg_info = sys_info;
 
 		/*
 		 * Throttle it only when the background writeback cannot
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		if (dirty_info_reclaimable(&sys_info) + sys_info.nr_writeback <=
+		if ((dirty_info_reclaimable(&sys_info) +
+		     sys_info.nr_writeback <=
 				(sys_info.background_thresh +
-				 sys_info.dirty_thresh) / 2)
+				 sys_info.dirty_thresh) / 2) &&
+		    (dirty_info_reclaimable(&memcg_info) +
+		     memcg_info.nr_writeback <=
+				(memcg_info.background_thresh +
+				 memcg_info.dirty_thresh) / 2))
 			break;
 
-		bdi_thresh = bdi_dirty_limit(bdi, sys_info.dirty_thresh);
+		bdi_thresh = bdi_dirty_limit(bdi,
+				min(sys_info.dirty_thresh,
+				    memcg_info.dirty_thresh));
 		bdi_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
@@ -541,7 +577,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 		dirty_exceeded =
 			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
 			|| (dirty_info_reclaimable(&sys_info) +
-			     sys_info.nr_writeback > sys_info.dirty_thresh);
+			    sys_info.nr_writeback > sys_info.dirty_thresh)
+			|| (dirty_info_reclaimable(&memcg_info) +
+			    memcg_info.nr_writeback > memcg_info.dirty_thresh);
 
 		if (!dirty_exceeded)
 			break;
@@ -559,7 +597,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * up.
 		 */
 		trace_wbc_balance_dirty_start(&wbc, bdi);
-		if (bdi_nr_reclaimable > bdi_thresh) {
+		if ((bdi_nr_reclaimable > bdi_thresh) ||
+		    (dirty_info_reclaimable(&memcg_info) >
+		     memcg_info.dirty_thresh)) {
 			writeback_inodes_wb(&bdi->wb, &wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
 			trace_wbc_balance_dirty_written(&wbc, bdi);
@@ -594,8 +634,10 @@ static void balance_dirty_pages(struct address_space *mapping,
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && (dirty_info_reclaimable(&sys_info) >
-			      sys_info.background_thresh)))
+	    (!laptop_mode && ((dirty_info_reclaimable(&sys_info) >
+			       sys_info.background_thresh) ||
+			      (dirty_info_reclaimable(&memcg_info) >
+			       memcg_info.background_thresh))))
 		bdi_start_background_writeback(bdi);
 }
 
@@ -653,12 +695,20 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
-void throttle_vm_writeout(gfp_t gfp_mask)
+/*
+ * Throttle the current task if it is near dirty memory usage limits.
+ * If @mem_cgroup is NULL or the root_cgroup, then use global dirty memory
+ * information; otherwise use the per-memcg dirty limits.
+ */
+void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup)
 {
 	struct dirty_info sys_info;
+	struct dirty_info memcg_info;
 
         for ( ; ; ) {
 		global_dirty_info(&sys_info);
+		if (!memcg_dirty_info(mem_cgroup, &memcg_info))
+			memcg_info = sys_info;
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
@@ -666,9 +716,13 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                  */
 		sys_info.dirty_thresh +=
 			sys_info.dirty_thresh / 10;      /* wheeee... */
+		memcg_info.dirty_thresh +=
+			memcg_info.dirty_thresh / 10;    /* wheeee... */
 
-		if (sys_info.nr_unstable_nfs +
-		    sys_info.nr_writeback <= sys_info.dirty_thresh)
+		if ((sys_info.nr_unstable_nfs +
+		     sys_info.nr_writeback <= sys_info.dirty_thresh) &&
+		    (memcg_info.nr_unstable_nfs +
+		     memcg_info.nr_writeback <= memcg_info.dirty_thresh))
 			break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ba11e28..f723242 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1927,7 +1927,7 @@ restart:
 					sc->nr_scanned - nr_scanned, sc))
 		goto restart;
 
-	throttle_vm_writeout(sc->gfp_mask);
+	throttle_vm_writeout(sc->gfp_mask, sc->mem_cgroup);
 }
 
 /*
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
