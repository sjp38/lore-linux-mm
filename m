Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5B58A8D0005
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 04:25:38 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH 6/6] memcg: make mem_cgroup_page_stat() return value unsigned
Date: Tue,  9 Nov 2010 01:24:31 -0800
Message-Id: <1289294671-6865-7-git-send-email-gthelen@google.com>
In-Reply-To: <1289294671-6865-1-git-send-email-gthelen@google.com>
References: <1289294671-6865-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

mem_cgroup_page_stat() used to return a negative page count
value to indicate value.

mem_cgroup_page_stat() has changed so it never returns
error so convert the return value to the traditional page
count type (unsigned long).

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h |    6 +++---
 mm/memcontrol.c            |   12 ++++++++++--
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a81dfda..3433784 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -158,8 +158,8 @@ bool mem_cgroup_has_dirty_limit(void);
 bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 			   struct mem_cgroup *memcg,
 			   struct dirty_info *info);
-long mem_cgroup_page_stat(struct mem_cgroup *mem,
-			  enum mem_cgroup_nr_pages_item item);
+unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
+				   enum mem_cgroup_nr_pages_item item);
 
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
@@ -354,7 +354,7 @@ static inline bool mem_cgroup_dirty_info(unsigned long sys_available_mem,
 	return false;
 }
 
-static inline long mem_cgroup_page_stat(struct mem_cgroup *mem,
+static inline unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
 					enum mem_cgroup_nr_pages_item item)
 {
 	return -ENOSYS;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ccdbb7e..ed070d0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1361,8 +1361,8 @@ memcg_hierarchical_free_pages(struct mem_cgroup *mem)
  *
  * Return the accounted statistic value.
  */
-long mem_cgroup_page_stat(struct mem_cgroup *mem,
-			  enum mem_cgroup_nr_pages_item item)
+unsigned long mem_cgroup_page_stat(struct mem_cgroup *mem,
+				   enum mem_cgroup_nr_pages_item item)
 {
 	struct mem_cgroup *iter;
 	long value;
@@ -1388,6 +1388,14 @@ long mem_cgroup_page_stat(struct mem_cgroup *mem,
 	for_each_mem_cgroup_tree(iter, mem)
 		value += mem_cgroup_local_page_stat(iter, item);
 
+	/*
+	 * The sum of unlocked per-cpu counters may yield a slightly negative
+	 * value.  This function returns an unsigned value, so round it up to
+	 * zero to avoid returning a very large value.
+	 */
+	if (value < 0)
+		value = 0;
+
 	put_online_cpus();
 
 	return value;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
