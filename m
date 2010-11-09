Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 396566B00E3
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 04:25:21 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 3/6] memcg: make throttle_vm_writeout() memcg aware
Date: Tue,  9 Nov 2010 01:24:28 -0800
Message-Id: <1289294671-6865-4-git-send-email-gthelen@google.com>
In-Reply-To: <1289294671-6865-1-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

If called with a mem_cgroup, then throttle_vm_writeout() should
query the given cgroup for its dirty memory usage limits.

dirty_writeback_pages() is no longer used, so delete it.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/writeback.h |    2 +-
 mm/page-writeback.c       |   31 ++++++++++++++++---------------
 mm/vmscan.c               |    2 +-
 3 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 335dba1..1bacdda 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -97,7 +97,7 @@ void laptop_mode_timer_fn(unsigned long data);
 #else
 static inline void laptop_sync_completion(void) { }
 #endif
-void throttle_vm_writeout(gfp_t gfp_mask);
+void throttle_vm_writeout(gfp_t gfp_mask, struct mem_cgroup *mem_cgroup);
 
 /* These are exported to sysctl. */
 extern int dirty_background_ratio;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d717fa9..bf85062 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -131,18 +131,6 @@ EXPORT_SYMBOL(laptop_mode);
 static struct prop_descriptor vm_completions;
 static struct prop_descriptor vm_dirties;
 
-static unsigned long dirty_writeback_pages(void)
-{
-	unsigned long ret;
-
-	ret = mem_cgroup_page_stat(NULL, MEMCG_NR_DIRTY_WRITEBACK_PAGES);
-	if ((long)ret < 0)
-		ret = global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK);
-
-	return ret;
-}
-
 /*
  * couple the period to the dirty_ratio:
  *
@@ -703,12 +691,25 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
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
 	struct dirty_info dirty_info;
+	unsigned long nr_writeback;
 
         for ( ; ; ) {
-		global_dirty_info(&dirty_info);
+		if (!mem_cgroup || !memcg_dirty_info(mem_cgroup, &dirty_info)) {
+			global_dirty_info(&dirty_info);
+			nr_writeback = global_page_state(NR_UNSTABLE_NFS) +
+				global_page_state(NR_WRITEBACK);
+		} else {
+			nr_writeback = mem_cgroup_page_stat(
+				mem_cgroup, MEMCG_NR_DIRTY_WRITEBACK_PAGES);
+		}
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
@@ -717,7 +718,7 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 		dirty_info.dirty_thresh +=
 			dirty_info.dirty_thresh / 10;      /* wheeee... */
 
-		if (dirty_writeback_pages() <= dirty_info.dirty_thresh)
+		if (nr_writeback <= dirty_info.dirty_thresh)
 			break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6d84858..8cc90d5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1844,7 +1844,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	if (inactive_anon_is_low(zone, sc))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
