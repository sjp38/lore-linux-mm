Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 94F128D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 03:12:45 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v4 05/11] writeback: create dirty_info structure
Date: Fri, 29 Oct 2010 00:09:08 -0700
Message-Id: <1288336154-23256-6-git-send-email-gthelen@google.com>
In-Reply-To: <1288336154-23256-1-git-send-email-gthelen@google.com>
References: <1288336154-23256-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Bundle dirty limits and dirty memory usage metrics into a dirty_info
structure to simplify interfaces of routines that need all.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v3:
- This is a new patch in v4.

 fs/fs-writeback.c         |    7 ++---
 include/linux/writeback.h |    9 +++++++-
 mm/backing-dev.c          |   12 +++++-----
 mm/page-writeback.c       |   52 ++++++++++++++++++++++++--------------------
 mm/vmstat.c               |    6 +++-
 5 files changed, 49 insertions(+), 37 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 9e46aec..1c27bb9 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -577,12 +577,11 @@ static void __writeback_inodes_sb(struct super_block *sb,
 
 static inline bool over_bground_thresh(void)
 {
-	unsigned long background_thresh, dirty_thresh;
+	struct dirty_info info;
 
-	global_dirty_limits(&background_thresh, &dirty_thresh);
+	global_dirty_info(&info);
 
-	return (global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS) > background_thresh);
+	return info.nr_reclaimable > info.background_thresh;
 }
 
 /*
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index c7299d2..ab23a73 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -84,6 +84,13 @@ static inline void inode_sync_wait(struct inode *inode)
 /*
  * mm/page-writeback.c
  */
+struct dirty_info {
+	unsigned long dirty_thresh;
+	unsigned long background_thresh;
+	unsigned long nr_reclaimable;
+	unsigned long nr_writeback;
+};
+
 #ifdef CONFIG_BLOCK
 void laptop_io_completion(struct backing_dev_info *info);
 void laptop_sync_completion(void);
@@ -124,7 +131,7 @@ struct ctl_table;
 int dirty_writeback_centisecs_handler(struct ctl_table *, int,
 				      void __user *, size_t *, loff_t *);
 
-void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
+void global_dirty_info(struct dirty_info *info);
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
 			       unsigned long dirty);
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index f2eb278..b3a50d2 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -66,8 +66,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 {
 	struct backing_dev_info *bdi = m->private;
 	struct bdi_writeback *wb = &bdi->wb;
-	unsigned long background_thresh;
-	unsigned long dirty_thresh;
+	struct dirty_info dirty_info;
 	unsigned long bdi_thresh;
 	unsigned long nr_dirty, nr_io, nr_more_io, nr_wb;
 	struct inode *inode;
@@ -82,8 +81,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		nr_more_io++;
 	spin_unlock(&inode_lock);
 
-	global_dirty_limits(&background_thresh, &dirty_thresh);
-	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+	global_dirty_info(&dirty_info);
+	bdi_thresh = bdi_dirty_limit(bdi, dirty_info.dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
@@ -99,8 +98,9 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 		   "state:            %8lx\n",
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITEBACK)),
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
-		   K(bdi_thresh), K(dirty_thresh),
-		   K(background_thresh), nr_dirty, nr_io, nr_more_io,
+		   K(bdi_thresh), K(dirty_info.dirty_thresh),
+		   K(dirty_info.background_thresh),
+		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b840afa..722bd61 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -398,7 +398,8 @@ unsigned long determine_dirtyable_memory(void)
 }
 
 /*
- * global_dirty_limits - background-writeback and dirty-throttling thresholds
+ * global_dirty_info - return background-writeback and dirty-throttling
+ * thresholds as well as dirty usage metrics.
  *
  * Calculate the dirty thresholds based on sysctl parameters
  * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
@@ -406,7 +407,7 @@ unsigned long determine_dirtyable_memory(void)
  * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
  * runtime tasks.
  */
-void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
+void global_dirty_info(struct dirty_info *info)
 {
 	unsigned long background;
 	unsigned long dirty;
@@ -423,6 +424,10 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 	else
 		background = (dirty_background_ratio * available_memory) / 100;
 
+	info->nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
+				global_page_state(NR_UNSTABLE_NFS);
+	info->nr_writeback = global_page_state(NR_WRITEBACK);
+
 	if (background >= dirty)
 		background = dirty / 2;
 	tsk = current;
@@ -430,8 +435,8 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 		background += background / 4;
 		dirty += dirty / 4;
 	}
-	*pbackground = background;
-	*pdirty = dirty;
+	info->background_thresh = background;
+	info->dirty_thresh = dirty;
 }
 
 /*
@@ -475,10 +480,9 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
 static void balance_dirty_pages(struct address_space *mapping,
 				unsigned long write_chunk)
 {
-	long nr_reclaimable, bdi_nr_reclaimable;
-	long nr_writeback, bdi_nr_writeback;
-	unsigned long background_thresh;
-	unsigned long dirty_thresh;
+	struct dirty_info dirty_info;
+	long bdi_nr_reclaimable;
+	long bdi_nr_writeback;
 	unsigned long bdi_thresh;
 	unsigned long pages_written = 0;
 	unsigned long pause = 1;
@@ -493,22 +497,19 @@ static void balance_dirty_pages(struct address_space *mapping,
 			.range_cyclic	= 1,
 		};
 
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
-
-		global_dirty_limits(&background_thresh, &dirty_thresh);
+		global_dirty_info(&dirty_info);
 
 		/*
 		 * Throttle it only when the background writeback cannot
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		if (nr_reclaimable + nr_writeback <=
-				(background_thresh + dirty_thresh) / 2)
+		if (dirty_info.nr_reclaimable + dirty_info.nr_writeback <=
+				(dirty_info.background_thresh +
+				 dirty_info.dirty_thresh) / 2)
 			break;
 
-		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+		bdi_thresh = bdi_dirty_limit(bdi, dirty_info.dirty_thresh);
 		bdi_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
@@ -537,7 +538,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 */
 		dirty_exceeded =
 			(bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
-			|| (nr_reclaimable + nr_writeback > dirty_thresh);
+			|| (dirty_info.nr_reclaimable +
+			    dirty_info.nr_writeback >
+			    dirty_info.dirty_thresh);
 
 		if (!dirty_exceeded)
 			break;
@@ -590,7 +593,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	    (!laptop_mode && (nr_reclaimable > background_thresh)))
+	    (!laptop_mode && (dirty_info.nr_reclaimable >
+			      dirty_info.background_thresh)))
 		bdi_start_background_writeback(bdi);
 }
 
@@ -650,21 +654,21 @@ EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
 void throttle_vm_writeout(gfp_t gfp_mask)
 {
-	unsigned long background_thresh;
-	unsigned long dirty_thresh;
+	struct dirty_info dirty_info;
 
         for ( ; ; ) {
-		global_dirty_limits(&background_thresh, &dirty_thresh);
+		global_dirty_info(&dirty_info);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
                  * allocators so they don't get DoS'ed by heavy writers
                  */
-                dirty_thresh += dirty_thresh / 10;      /* wheeee... */
+		dirty_info.dirty_thresh +=
+			dirty_info.dirty_thresh / 10;      /* wheeee... */
 
                 if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
+		    global_page_state(NR_WRITEBACK) <= dirty_info.dirty_thresh)
+			break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index cd2e42b..de4d415 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -922,6 +922,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 {
 	unsigned long *v;
 	int i, stat_items_size;
+	struct dirty_info dirty_info;
 
 	if (*pos >= ARRAY_SIZE(vmstat_text))
 		return NULL;
@@ -940,8 +941,9 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 		v[i] = global_page_state(i);
 	v += NR_VM_ZONE_STAT_ITEMS;
 
-	global_dirty_limits(v + NR_DIRTY_BG_THRESHOLD,
-			    v + NR_DIRTY_THRESHOLD);
+	global_dirty_info(&dirty_info);
+	v[NR_DIRTY_BG_THRESHOLD] = dirty_info.background_thresh;
+	v[NR_DIRTY_THRESHOLD] = dirty_info.dirty_thresh;
 	v += NR_VM_WRITEBACK_STAT_ITEMS;
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
