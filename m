Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 23CE76B0034
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:50:50 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so1979326pab.36
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:50:49 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 1/4] memcg: remove MEMCG_NR_FILE_MAPPED
Date: Thu, 22 Aug 2013 17:50:23 +0800
Message-Id: <1377165023-23974-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
References: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

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
 include/linux/memcontrol.h |   27 +++++++++++++++++++--------
 mm/memcontrol.c            |   25 +------------------------
 mm/rmap.c                  |    4 ++--
 3 files changed, 22 insertions(+), 34 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8a9ed4d..630bfa1 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -30,9 +30,20 @@ struct page;
 struct mm_struct;
 struct kmem_cache;
 
-/* Stats that can be updated by kernel. */
-enum mem_cgroup_page_stat_item {
-	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
+/*
+ * The corresponding mem_cgroup_stat_names is defined in mm/memcontrol.c,
+ * These two lists should keep in accord with each other.
+ */
+enum mem_cgroup_stat_index {
+	/*
+	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
+	 */
+	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
+	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
+	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
+	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
+	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
+	MEM_CGROUP_STAT_NSTATS,
 };
 
 struct mem_cgroup_reclaim_cookie {
@@ -233,17 +244,17 @@ static inline void mem_cgroup_end_update_page_stat(struct page *page,
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
@@ -448,12 +459,12 @@ static inline bool mem_cgroup_oom_synchronize(void)
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
index b73988a..24d6d02 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -84,21 +84,6 @@ static int really_do_swap_account __initdata = 0;
 #endif
 
 
-/*
- * Statistics for memory cgroup.
- */
-enum mem_cgroup_stat_index {
-	/*
-	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
-	 */
-	MEM_CGROUP_STAT_CACHE,		/* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
-	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
-	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
-	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
-	MEM_CGROUP_STAT_NSTATS,
-};
-
 static const char * const mem_cgroup_stat_names[] = {
 	"cache",
 	"rss",
@@ -2255,7 +2240,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
 }
 
 void mem_cgroup_update_page_stat(struct page *page,
-				 enum mem_cgroup_page_stat_item idx, int val)
+				 enum mem_cgroup_stat_index idx, int val)
 {
 	struct mem_cgroup *memcg;
 	struct page_cgroup *pc = lookup_page_cgroup(page);
@@ -2268,14 +2253,6 @@ void mem_cgroup_update_page_stat(struct page *page,
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
index 07afd48..373da2a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1114,7 +1114,7 @@ void page_add_file_rmap(struct page *page)
 	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(page, MEMCG_NR_FILE_MAPPED);
+		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
 	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
@@ -1158,7 +1158,7 @@ void page_remove_rmap(struct page *page)
 				hpage_nr_pages(page));
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
