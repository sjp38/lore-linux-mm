Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 7A6166B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:23:14 -0400 (EDT)
Received: by yhr47 with SMTP id 47so3628540yhr.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 03:23:13 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 1/6] memcg: remove MEMCG_NR_FILE_MAPPED
Date: Fri, 27 Jul 2012 18:23:05 +0800
Message-Id: <1343384585-20046-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
References: <1343384432-19903-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: fengguang.wu@intel.com, gthelen@google.com, akpm@linux-foundation.org, yinghan@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

While accounting memcg page stat, it's not worth to use MEMCG_NR_FILE_MAPPED
as an extra layer of indirection because of the complexity and presumed
performance overhead. We can use MEM_CGROUP_STAT_FILE_MAPPED directly.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: Fengguang Wu <fengguang.wu@intel.com>
Reviewed-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h |   28 ++++++++++++++++++++--------
 mm/memcontrol.c            |   25 +++----------------------
 mm/rmap.c                  |    4 ++--
 3 files changed, 25 insertions(+), 32 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 83e7ba9..c1e2617 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -27,9 +27,21 @@ struct page_cgroup;
 struct page;
 struct mm_struct;
 
-/* Stats that can be updated by kernel. */
-enum mem_cgroup_page_stat_item {
-	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+/*
+ * Statistics for memory cgroup.
+ *
+ * The corresponding mem_cgroup_stat_names is defined in mm/memcontrol.c,
+ * These two lists should keep in accord with each other.
+ */
+enum mem_cgroup_stat_index {
+	/*
+	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
+	 */
+	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
+	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
+	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
+	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_NSTATS,
 };
 
 struct mem_cgroup_reclaim_cookie {
@@ -164,17 +176,17 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
-				 enum mem_cgroup_page_stat_item idx,
+				 enum mem_cgroup_stat_index idx,
 				 int val);
 
 static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum mem_cgroup_page_stat_item idx)
+					    enum mem_cgroup_stat_index idx)
 {
 	mem_cgroup_update_page_stat(page, idx, 1);
 }
 
 static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum mem_cgroup_page_stat_item idx)
+					    enum mem_cgroup_stat_index idx)
 {
 	mem_cgroup_update_page_stat(page, idx, -1);
 }
@@ -349,12 +361,12 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
 }
 
 static inline void mem_cgroup_inc_page_stat(struct page *page,
-					    enum mem_cgroup_page_stat_item idx)
+					    enum mem_cgroup_stat_index idx)
 {
 }
 
 static inline void mem_cgroup_dec_page_stat(struct page *page,
-					    enum mem_cgroup_page_stat_item idx)
+					    enum mem_cgroup_stat_index idx)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1940ba8..aef9fb0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -76,21 +76,10 @@ static int really_do_swap_account __initdata = 0;
 #define do_swap_account		0
 #endif
 
-
 /*
- * Statistics for memory cgroup.
+ * The corresponding mem_cgroup_stat_index is defined in include/linux/memcontrol.h,
+ * These two lists should keep in accord with each other.
  */
-enum mem_cgroup_stat_index {
-	/*
-	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
-	 */
-	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
-	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
-	MEM_CGROUP_STAT_NSTATS,
-};
-
 static const char * const mem_cgroup_stat_names[] = {
 	"cache",
 	"rss",
@@ -1926,7 +1915,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
-				 enum mem_cgroup_page_stat_item idx, int val)
+				 enum mem_cgroup_stat_index idx, int val)
 {
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -1939,14 +1928,6 @@ void mem_cgroup_update_page_stat(struct page *page,
 	if (unlikely(!memcg || !PageCgroupUsed(pc)))
 		return;
 
-	switch (idx) {
-	case MEMCG_NR_FILE_MAPPED:
-		idx = MEM_CGROUP_STAT_FILE_MAPPED;
-		break;
-	default:
-		BUG();
-	}
-
 	this_cpu_add(memcg->stat->count[idx], val);
 }
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 0f3b7cd..cd7e54e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1148,7 +1148,7 @@ void page_add_file_rmap(struct page *page)
 	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
 	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
@@ -1202,7 +1202,7 @@ void page_remove_rmap(struct page *page)
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
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
