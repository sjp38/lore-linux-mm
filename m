Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A4BC46B00DC
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 20:41:08 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v3 03/11] memcg: create extensible page stat update routines
Date: Mon, 18 Oct 2010 17:39:36 -0700
Message-Id: <1287448784-25684-4-git-send-email-gthelen@google.com>
In-Reply-To: <1287448784-25684-1-git-send-email-gthelen@google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

Replace usage of the mem_cgroup_update_file_mapped() memcg
statistic update routine with two new routines:
* mem_cgroup_inc_page_stat()
* mem_cgroup_dec_page_stat()

As before, only the file_mapped statistic is managed.  However,
these more general interfaces allow for new statistics to be
more easily added.  New statistics are added with memcg dirty
page accounting.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Andrea Righi <arighi@develer.com>
---

Changelog since v1:
- Rename (for clarity):
  - mem_cgroup_write_page_stat_item -> mem_cgroup_page_stat_item
  - mem_cgroup_read_page_stat_item -> mem_cgroup_nr_pages_item

 include/linux/memcontrol.h |   31 ++++++++++++++++++++++++++++---
 mm/memcontrol.c            |   16 +++++++---------
 mm/rmap.c                  |    4 ++--
 3 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 159a076..067115c 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -25,6 +25,11 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 
+/* Stats that can be updated by kernel. */
+enum mem_cgroup_page_stat_item {
+	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+};
+
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -121,7 +126,22 @@ static inline bool mem_cgroup_disabled(void)
 	return false;
 }
 
-void mem_cgroup_update_file_mapped(struct page *page, int val);
+void mem_cgroup_update_page_stat(struct page *page,
+				 enum mem_cgroup_page_stat_item idx,
+				 int val);
+
+static inline void mem_cgroup_inc_page_stat(struct page *page,
+					    enum mem_cgroup_page_stat_item idx)
+{
+	mem_cgroup_update_page_stat(page, idx, 1);
+}
+
+static inline void mem_cgroup_dec_page_stat(struct page *page,
+					    enum mem_cgroup_page_stat_item idx)
+{
+	mem_cgroup_update_page_stat(page, idx, -1);
+}
+
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
@@ -293,8 +313,13 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
-static inline void mem_cgroup_update_file_mapped(struct page *page,
-							int val)
+static inline void mem_cgroup_inc_page_stat(struct page *page,
+					    enum mem_cgroup_page_stat_item idx)
+{
+}
+
+static inline void mem_cgroup_dec_page_stat(struct page *page,
+					    enum mem_cgroup_page_stat_item idx)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a4034b6..369879a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1609,7 +1609,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
  * possibility of race condition. If there is, we take a lock.
  */
 
-static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
+void mem_cgroup_update_page_stat(struct page *page,
+				 enum mem_cgroup_page_stat_item idx, int val)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -1632,30 +1633,27 @@ static void mem_cgroup_update_file_stat(struct page *page, int idx, int val)
 			goto out;
 	}
 
-	this_cpu_add(mem->stat->count[idx], val);
-
 	switch (idx) {
-	case MEM_CGROUP_STAT_FILE_MAPPED:
+	case MEMCG_NR_FILE_MAPPED:
 		if (val > 0)
 			SetPageCgroupFileMapped(pc);
 		else if (!page_mapped(page))
 			ClearPageCgroupFileMapped(pc);
+		idx = MEM_CGROUP_STAT_FILE_MAPPED;
 		break;
 	default:
 		BUG();
 	}
 
+	this_cpu_add(mem->stat->count[idx], val);
+
 out:
 	if (unlikely(need_unlock))
 		unlock_page_cgroup(pc);
 	rcu_read_unlock();
 	return;
 }
-
-void mem_cgroup_update_file_mapped(struct page *page, int val)
-{
-	mem_cgroup_update_file_stat(page, MEM_CGROUP_STAT_FILE_MAPPED, val);
-}
+EXPORT_SYMBOL(mem_cgroup_update_page_stat);
 
 /*
  * size of first charge trial. "32" comes from vmscan.c's magic value.
diff --git a/mm/rmap.c b/mm/rmap.c
index 1a8bf76..a66ab76 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -911,7 +911,7 @@ void page_add_file_rmap(struct page *page)
 {
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_file_mapped(page, 1);
+		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
 	}
 }
 
@@ -949,7 +949,7 @@ void page_remove_rmap(struct page *page)
 		__dec_zone_page_state(page, NR_ANON_PAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_update_file_mapped(page, -1);
+		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
 	}
 	/*
 	 * It would be tidy to reset the PageAnon mapping here,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
