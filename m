Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DCAF6900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 12:17:54 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v9 13/13] memcg: check memcg dirty limits in page writeback
Date: Wed, 17 Aug 2011 09:15:05 -0700
Message-Id: <1313597705-6093-14-git-send-email-gthelen@google.com>
In-Reply-To: <1313597705-6093-1-git-send-email-gthelen@google.com>
References: <1313597705-6093-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>

If the current process is in a non-root memcg, then
balance_dirty_pages() will consider the memcg dirty limits as well as
the system-wide limits.  This allows different cgroups to have distinct
dirty limits which trigger direct and background writeback at different
levels.

If called with a mem_cgroup, then throttle_vm_writeout() queries the
given cgroup for its dirty memory usage limits.

Signed-off-by: Andrea Righi <andrea@betterlinux.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
Changelog since v8:

- Use 'memcg' rather than 'mem' for local variables and parameters.
  This is consistent with other memory controller code.

 include/linux/writeback.h |    2 +-
 mm/page-writeback.c       |   35 +++++++++++++++++++++++++++++------
 mm/vmscan.c               |    2 +-
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index e6790e8..0f809e3 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -116,7 +116,7 @@ void laptop_mode_timer_fn(unsigned long data);
 #else
 static inline void laptop_sync_completion(void) { }
 #endif
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *memcg);
 
 extern unsigned long global_dirty_limit;
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 64de98c..9ce199d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -645,7 +645,8 @@ static void bdi_update_bandwidth(struct backing_dev_info *bdi,
  * data.  It looks at the number of dirty pages in the machine and will force
  * the caller to perform writeback if the system is over `vm_dirty_ratio'.
  * If we're over `background_thresh' then the writeback threads are woken to
- * perform some writeout.
+ * perform some writeout.  The current task may belong to a cgroup with
+ * dirty limits, which are also checked.
  */
 static void balance_dirty_pages(struct address_space *mapping,
 				unsigned long write_chunk)
@@ -665,6 +666,8 @@ static void balance_dirty_pages(struct address_space *mapping,
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	unsigned long start_time = jiffies;
 
+	mem_cgroup_balance_dirty_pages(mapping, write_chunk);
+
 	for (;;) {
 		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
 					global_page_state(NR_UNSTABLE_NFS);
@@ -856,23 +859,43 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 }
 EXPORT_SYMBOL(balance_dirty_pages_ratelimited_nr);
 
-void throttle_vm_writeout(gfp_t gfp_mask)
+/*
+ * Throttle the current task if it is near dirty memory usage limits.  Both
+ * global dirty memory limits and (if @memcg is given) per-cgroup dirty memory
+ * limits are checked.
+ *
+ * If near limits, then wait for usage to drop.  Dirty usage should drop because
+ * dirty producers should have used balance_dirty_pages(), which would have
+ * scheduled writeback.
+ */
+void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *memcg)
 {
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
+	struct dirty_info memcg_info;
+	bool do_memcg;
 
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
+		do_memcg = memcg &&
+			mem_cgroup_hierarchical_dirty_info(
+				determine_dirtyable_memory(), memcg,
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
index fb0ae99..3c57788 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2068,7 +2068,7 @@ restart:
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
