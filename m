Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 211686B00DF
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 04:24:53 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 1/6] memcg: add mem_cgroup parameter to mem_cgroup_page_stat()
Date: Tue,  9 Nov 2010 01:24:26 -0800
Message-Id: <1289294671-6865-2-git-send-email-gthelen@google.com>
In-Reply-To: <1289294671-6865-1-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

This new parameter can be used to query dirty memory usage
from a given memcg rather than the current task's memcg.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h |    6 ++++--
 mm/memcontrol.c            |   37 +++++++++++++++++++++----------------
 mm/page-writeback.c        |    2 +-
 3 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7a3d915..89a9278 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -157,7 +157,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 bool mem_cgroup_has_dirty_limit(void);
 bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 			   struct dirty_info *info);
-long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item);
+long mem_cgroup_page_stat(struct mem_cgroup *mem,
+			  enum mem_cgroup_nr_pages_item item);
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
@@ -351,7 +352,8 @@ static inline bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 	return false;
 }
 
-static inline long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
+static inline long mem_cgroup_page_stat(struct mem_cgroup *mem,
+					enum mem_cgroup_nr_pages_item item)
 {
 	return -ENOSYS;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d8a06d6..1bff7cf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1245,22 +1245,20 @@ bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 	unsigned long available_mem;
 	struct mem_cgroup *memcg;
 	long value;
+	bool valid = false;
 
 	if (mem_cgroup_disabled())
 		return false;
 
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(current);
-	if (!__mem_cgroup_has_dirty_limit(memcg)) {
-		rcu_read_unlock();
-		return false;
-	}
+	if (!__mem_cgroup_has_dirty_limit(memcg))
+		goto done;
 	__mem_cgroup_dirty_param(&dirty_param, memcg);
-	rcu_read_unlock();
 
-	value = mem_cgroup_page_stat(MEMCG_NR_DIRTYABLE_PAGES);
+	value = mem_cgroup_page_stat(memcg, MEMCG_NR_DIRTYABLE_PAGES);
 	if (value < 0)
-		return false;
+		goto done;
 
 	available_mem = min((unsigned long)value, sys_available_mem);
 
@@ -1280,17 +1278,21 @@ bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 			(dirty_param.dirty_background_ratio *
 			       available_mem) / 100;
 
-	value = mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
+	value = mem_cgroup_page_stat(memcg, MEMCG_NR_RECLAIM_PAGES);
 	if (value < 0)
-		return false;
+		goto done;
 	info->nr_reclaimable = value;
 
-	value = mem_cgroup_page_stat(MEMCG_NR_WRITEBACK);
+	value = mem_cgroup_page_stat(memcg, MEMCG_NR_WRITEBACK);
 	if (value < 0)
-		return false;
+		goto done;
 	info->nr_writeback = value;
 
-	return true;
+	valid = true;
+
+done:
+	rcu_read_unlock();
+	return valid;
 }
 
 static inline bool mem_cgroup_can_swap(struct mem_cgroup *memcg)
@@ -1361,20 +1363,23 @@ memcg_hierarchical_free_pages(struct mem_cgroup *mem)
 
 /*
  * mem_cgroup_page_stat() - get memory cgroup file cache statistics
- * @item:      memory statistic item exported to the kernel
+ * @mem:	optional memory cgroup to query.  If NULL, use current task's
+ *		cgroup.
+ * @item:	memory statistic item exported to the kernel
  *
  * Return the accounted statistic value or negative value if current task is
  * root cgroup.
  */
-long mem_cgroup_page_stat(enum mem_cgroup_nr_pages_item item)
+long mem_cgroup_page_stat(struct mem_cgroup *mem,
+			  enum mem_cgroup_nr_pages_item item)
 {
 	struct mem_cgroup *iter;
-	struct mem_cgroup *mem;
 	long value;
 
 	get_online_cpus();
 	rcu_read_lock();
-	mem = mem_cgroup_from_task(current);
+	if (!mem)
+		mem = mem_cgroup_from_task(current);
 	if (__mem_cgroup_has_dirty_limit(mem)) {
 		/*
 		 * If we're looking for dirtyable pages we need to evaluate
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index a477f59..dc3dbe3 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -135,7 +135,7 @@ static unsigned long dirty_writeback_pages(void)
 {
 	unsigned long ret;
 
-	ret = mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGES);
+	ret = mem_cgroup_page_stat(NULL, MEMCG_NR_DIRTY_WRITEBACK_PAGES);
 	if ((long)ret < 0)
 		ret = global_page_state(NR_UNSTABLE_NFS) +
 			global_page_state(NR_WRITEBACK);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
