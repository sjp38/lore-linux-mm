Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3406B00E1
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 04:25:18 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 2/6] memcg: pass mem_cgroup to mem_cgroup_dirty_info()
Date: Tue,  9 Nov 2010 01:24:27 -0800
Message-Id: <1289294671-6865-3-git-send-email-gthelen@google.com>
In-Reply-To: <1289294671-6865-1-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Pass mem_cgroup parameter through memcg_dirty_info() into
mem_cgroup_dirty_info().  This allows for querying dirty memory
information from a particular cgroup, rather than just the
current task's cgroup.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h |    2 ++
 mm/memcontrol.c            |    5 +++--
 mm/page-writeback.c        |    9 ++++++---
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 89a9278..a81dfda 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -156,6 +156,7 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 
 bool mem_cgroup_has_dirty_limit(void);
 bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
+			   struct mem_cgroup *memcg,
 			   struct dirty_info *info);
 long mem_cgroup_page_stat(struct mem_cgroup *mem,
 			  enum mem_cgroup_nr_pages_item item);
@@ -347,6 +348,7 @@ static inline bool mem_cgroup_has_dirty_limit(void)
 }
 
 static inline bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
+					 struct mem_cgroup *memcg,
 					 struct dirty_info *info)
 {
 	return false;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1bff7cf..eb621ee 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1239,11 +1239,11 @@ static void __mem_cgroup_dirty_param(struct vm_dirty_param *param,
  * "memcg" will not be freed while holding rcu_read_lock().
  */
 bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
+			   struct mem_cgroup *memcg,
 			   struct dirty_info *info)
 {
 	struct vm_dirty_param dirty_param;
 	unsigned long available_mem;
-	struct mem_cgroup *memcg;
 	long value;
 	bool valid = false;
 
@@ -1251,7 +1251,8 @@ bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 		return false;
 
 	rcu_read_lock();
-	memcg = mem_cgroup_from_task(current);
+	if (!memcg)
+		memcg = mem_cgroup_from_task(current);
 	if (!__mem_cgroup_has_dirty_limit(memcg))
 		goto done;
 	__mem_cgroup_dirty_param(&dirty_param, memcg);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index dc3dbe3..d717fa9 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -461,12 +461,15 @@ void global_dirty_info(struct dirty_info *info)
  * Calculate the background-writeback and dirty-throttling thresholds and dirty
  * usage metrics from the current task's memcg dirty limit parameters.  Returns
  * false if no memcg limits exist.
+ *
+ * @memcg may be NULL if the current task's memcg should be used.
+ * @info is the location where the dirty information is written.
  */
-static bool memcg_dirty_info(struct dirty_info *info)
+static bool memcg_dirty_info(struct mem_cgroup *memcg, struct dirty_info *info)
 {
 	unsigned long available_memory = determine_dirtyable_memory();
 
-	if (!mem_cgroup_dirty_info(available_memory, info))
+	if (!mem_cgroup_dirty_info(available_memory, memcg, info))
 		return false;
 
 	adjust_dirty_info(info);
@@ -534,7 +537,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 
 		global_dirty_info(&sys_info);
 
-		if (!memcg_dirty_info(&memcg_info))
+		if (!memcg_dirty_info(NULL, &memcg_info))
 			memcg_info = sys_info;
 
 		/*
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
