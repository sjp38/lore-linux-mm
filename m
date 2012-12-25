Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 124046B005A
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 12:20:42 -0500 (EST)
Received: by mail-da0-f50.google.com with SMTP id h15so3564332dan.9
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 09:20:41 -0800 (PST)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V3 1/8] memcg: remove MEMCG_NR_FILE_MAPPED
Date: Wed, 26 Dec 2012 01:20:12 +0800
Message-Id: <1356456012-14490-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

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
 mm/memcontrol.c            |   22 +++-------------------
 mm/rmap.c                  |    4 ++--
 3 files changed, 25 insertions(+), 29 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0108a56..5421b8a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -30,9 +30,21 @@ struct page;
 struct mm_struct;
 struct kmem_cache;
 
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
+	MEM_CGROUP_STAT_CACHE,	   /* # of pages charged as cache */
+	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
+	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
+	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_NSTATS,
 };
 
 struct mem_cgroup_reclaim_cookie {
@@ -165,17 +177,17 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
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
@@ -355,12 +367,12 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
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
index 1ea8951..d450c04 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -86,17 +86,9 @@ static int really_do_swap_account __initdata = 0;
 
 /*
  * Statistics for memory cgroup.
+ * The corresponding mem_cgroup_stat_index is defined in include/linux/
+ * memcontrol.h. These two lists should keep in accord with each other.
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
 
 static const char * const mem_cgroup_stat_names[] = {
 	"cache",
@@ -2226,7 +2218,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
-				 enum mem_cgroup_page_stat_item idx, int val)
+				 enum mem_cgroup_stat_index idx, int val)
 {
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -2239,14 +2231,6 @@ void mem_cgroup_update_page_stat(struct page *page,
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
index 59b0dca..c7de54e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1116,7 +1116,7 @@ void page_add_file_rmap(struct page *page)
 	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
 	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
@@ -1184,7 +1184,7 @@ void page_remove_rmap(struct page *page)
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	}
 	if (unlikely(PageMlocked(page)))
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
