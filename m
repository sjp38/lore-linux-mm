Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC0E90010C
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:17:15 -0400 (EDT)
Received: by mail-pw0-f41.google.com with SMTP id 12so457015pwi.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 10:17:14 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v1 03/10] Change int mode for isolate mode with enum ISOLATE_PAGE_MODE
Date: Thu, 12 May 2011 02:16:42 +0900
Message-Id: <cec16eaca8f2d3fbde203bfad375b2b02d57a1e0.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1305132792.git.minchan.kim@gmail.com>
References: <cover.1305132792.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

This patch changes macro define with enum variable.
Normally, enum is preferred as it's type-safe and making debugging easier
as symbol can be passed throught to the debugger.

This patch doesn't change old behavior and it will be used by next patches.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/memcontrol.h    |    5 ++++-
 include/linux/swap.h          |   12 ++++++++----
 include/trace/events/vmscan.h |    8 ++++----
 mm/memcontrol.c               |    3 ++-
 mm/vmscan.c                   |   19 +++++++++++++------
 5 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 77e47f5..81ec507 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -32,10 +32,13 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
 };
 
+enum ISOLATE_PAGE_MODE;
+
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
+					enum ISOLATE_PAGE_MODE mode,
+					struct zone *z,
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 384eb5f..a7cc199 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -244,9 +244,12 @@ static inline void lru_cache_add_file(struct page *page)
 }
 
 /* LRU Isolation modes. */
-#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
-#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
-#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
+enum ISOLATE_PAGE_MODE {
+	ISOLATE_NONE,
+	ISOLATE_INACTIVE = 1,	/* Isolate inactive pages */
+	ISOLATE_ACTIVE = 2,	/* Isolate active pages */
+	ISOLATE_BOTH = 4,	/* Isolate both active and inactive pages */
+};
 
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
@@ -259,7 +262,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						unsigned int swappiness,
 						struct zone *zone,
 						unsigned long *nr_scanned);
-extern int __isolate_lru_page(struct page *page, int mode, int file);
+extern int __isolate_lru_page(struct page *page, enum ISOLATE_PAGE_MODE mode,
+						int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index ea422aa..a20d766 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -187,7 +187,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		enum ISOLATE_PAGE_MODE isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
 
@@ -199,7 +199,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__field(unsigned long, nr_lumpy_taken)
 		__field(unsigned long, nr_lumpy_dirty)
 		__field(unsigned long, nr_lumpy_failed)
-		__field(int, isolate_mode)
+		__field(enum ISOLATE_PAGE_MODE, isolate_mode)
 	),
 
 	TP_fast_assign(
@@ -233,7 +233,7 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		enum ISOLATE_PAGE_MODE isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
 
@@ -248,7 +248,7 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		enum ISOLATE_PAGE_MODE isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 95aecca..0400d32 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1193,7 +1193,8 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
+					enum ISOLATE_PAGE_MODE mode,
+					struct zone *z,
 					struct mem_cgroup *mem_cont,
 					int active, int file)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a6a87c0..5d83e06 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -961,23 +961,29 @@ keep_lumpy:
  *
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, int mode, int file)
+int __isolate_lru_page(struct page *page, enum ISOLATE_PAGE_MODE mode,
+							int file)
 {
+	int active;
 	int ret = -EINVAL;
+	BUG_ON(mode & ISOLATE_BOTH &&
+		(mode & ISOLATE_INACTIVE || mode & ISOLATE_ACTIVE));
 
 	/* Only take pages on the LRU. */
 	if (!PageLRU(page))
 		return ret;
 
+	active = PageActive(page);
+
 	/*
 	 * When checking the active state, we need to be sure we are
 	 * dealing with comparible boolean values.  Take the logical not
 	 * of each.
 	 */
-	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
+	if (mode & ISOLATE_ACTIVE && !active)
 		return ret;
 
-	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
+	if (mode & ISOLATE_INACTIVE && active)
 		return ret;
 
 	/*
@@ -1025,7 +1031,8 @@ int __isolate_lru_page(struct page *page, int mode, int file)
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int mode, int file)
+		unsigned long *scanned, int order, enum ISOLATE_PAGE_MODE mode,
+		int file)
 {
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1138,8 +1145,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 static unsigned long isolate_pages_global(unsigned long nr,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
-					int active, int file)
+					enum ISOLATE_PAGE_MODE mode,
+					struct zone *z,	int active, int file)
 {
 	int lru = LRU_BASE;
 	if (active)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
