Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E16F96B0083
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 12:16:58 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v8 12/12] memcg: check memcg dirty limits in page writeback
Date: Fri,  3 Jun 2011 09:16:37 -0700
Message-Id: <1307117797-747-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Vivek Goyal <vgoyal@redhat.com>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

If the current process is in a non-root memcg, then
balance_dirty_pages() will consider the memcg dirty limits as well as
the system-wide limits.  This allows different cgroups to have distinct
dirty limits which trigger direct and background writeback at different
levels.

If called with a mem_cgroup, then throttle_vm_writeout() queries the
given cgroup for its dirty memory usage limits.

Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/writeback.h |    3 ++-
 mm/page-writeback.c       |   35 +++++++++++++++++++++++++++++------
 mm/vmscan.c               |    2 +-
 3 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 4f5c0d2..0b4b851 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -8,6 +8,7 @@
 #include <linux/fs.h>
 
 struct backing_dev_info;
+struct mem_cgroup;
 
 /*
  * fs/fs-writeback.c
@@ -91,7 +92,7 @@ void laptop_mode_timer_fn(unsigned long data);
 #else
 static inline void laptop_sync_completion(void) { }
 #endif
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 62fcf3d..30c265b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -473,7 +473,8 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
  * If we're over `background_thresh' then the writeback threads are woken to
- * perform some writeout.
+ * perform some writeout.  The current task may belong to a cgroup with
+ * dirty limits, which are also checked.
  */
 static void balance_dirty_pages(struct address_space *mapping,
 				unsigned long write_chunk)
@@ -488,6 +489,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
+	mem_cgroup_balance_dirty_pages(mapping, write_chunk);
+
 	for (;;) {
 		struct writeback_control wbc = {
 			.sync_mode	= WB_SYNC_NONE,
@@ -651,23 +654,43 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
-void throttle_vm_writeout(gfp_t gfp_mask)
+/*
+ * Throttle the current task if it is near dirty memory usage limits.  Both
+ * global dirty memory limits and (if @mem_cgroup is given) per-cgroup dirty
+ * memory limits are checked.
+ *
+ * If near limits, then wait for usage to drop.  Dirty usage should drop because
+ * dirty producers should have used balance_dirty_pages(), which would have
+ * scheduled writeback.
+ */
+void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup)
 {
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
+	struct dirty_info memcg_info;
+	bool do_memcg;
 
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
+		do_memcg = mem_cgroup &&
+			mem_cgroup_hierarchical_dirty_info(
+				determine_dirtyable_memory(), mem_cgroup,
+				&memcg_info);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
                  * allocators so they don't get DoS'ed by heavy writers
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
-
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
-                        	break;
+		if (do_memcg)
+			memcg_info.dirty_thresh += memcg_info.dirty_thresh / 10;
+
+		if ((global_page_state(NR_UNSTABLE_NFS) +
+		     global_page_state(NR_WRITEBACK) <= dirty_thresh) &&
+		    (!do_memcg ||
+		     (memcg_info.nr_unstable_nfs +
+		      memcg_info.nr_writeback <= memcg_info.dirty_thresh)))
+			break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 292582c..66324a4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1953,7 +1953,7 @@ restart:
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
