Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 453436B007B
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 10:39:04 -0400 (EDT)
Received: by pwi12 with SMTP id 12so3429632pwi.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 07:39:01 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 02/10] Change isolate mode from int type to enum type
Date: Tue,  7 Jun 2011 23:38:15 +0900
Message-Id: <4eee88f894f0553aedb696d667967adb7dcf29ab.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1307455422.git.minchan.kim@gmail.com>
References: <cover.1307455422.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

This patch changes macro define with enum variable.
Normally, enum is preferred as it's type-safe and making debugging easier
as symbol can be passed throught to the debugger.

This patch doesn't change old behavior.
It is used by next patches.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/memcontrol.h    |    5 ++++-
 include/linux/swap.h          |   11 +++++++----
 include/trace/events/vmscan.h |    8 ++++----
 mm/compaction.c               |    3 ++-
 mm/memcontrol.c               |    3 ++-
 mm/migrate.c                  |    4 ++--
 mm/vmscan.c                   |   37 ++++++++++++++++++++-----------------
 7 files changed, 41 insertions(+), 30 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5e9840f..91a1162 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -30,10 +30,13 @@ enum mem_cgroup_page_stat_item {
 	MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
 };
 
+enum ISOLATE_MODE;
+
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
+					enum ISOLATE_MODE mode,
+					struct zone *z,
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a5c6da5..48d50e6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -244,9 +244,11 @@ static inline void lru_cache_add_file(struct page *page)
 }
 
 /* LRU Isolation modes. */
-#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
-#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
-#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
+enum ISOLATE_MODE {
+	ISOLATE_NONE,
+	ISOLATE_INACTIVE = 1,	/* Isolate inactive pages */
+	ISOLATE_ACTIVE = 2,	/* Isolate active pages */
+};
 
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
@@ -258,7 +260,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
 						struct zone *zone);
-extern int __isolate_lru_page(struct page *page, int mode, int file);
+extern int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode,
+					int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index ea422aa..4f53d43 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -187,7 +187,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		enum ISOLATE_MODE isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
 
@@ -199,7 +199,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__field(unsigned long, nr_lumpy_taken)
 		__field(unsigned long, nr_lumpy_dirty)
 		__field(unsigned long, nr_lumpy_failed)
-		__field(int, isolate_mode)
+		__field(enum ISOLATE_MODE, isolate_mode)
 	),
 
 	TP_fast_assign(
@@ -233,7 +233,7 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		enum ISOLATE_MODE isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
 
@@ -248,7 +248,7 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		enum ISOLATE_MODE isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 61eab88..f0d75e9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -327,7 +327,8 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		}
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
+		if (__isolate_lru_page(page,
+				ISOLATE_ACTIVE|ISOLATE_INACTIVE, 0) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 010f916..f4c0b71 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1106,7 +1106,8 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
+					enum ISOLATE_MODE mode,
+					struct zone *z,
 					struct mem_cgroup *mem_cont,
 					int active, int file)
 {
diff --git a/mm/migrate.c b/mm/migrate.c
index 819d233..e797b5c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1363,10 +1363,10 @@ int migrate_vmas(struct mm_struct *mm, const nodemask_t *to,
 
 	for (vma = mm->mmap; vma && !err; vma = vma->vm_next) {
  		if (vma->vm_ops && vma->vm_ops->migrate) {
- 			err = vma->vm_ops->migrate(vma, to, from, flags);
+ 			err = vma->vm_ops->migrate(vma, to, from, flags);   
  			if (err)
  				break;
- 		}
+ 		}     
  	}
  	return err;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a658dde..4cbe114 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -957,23 +957,27 @@ keep_lumpy:
  *
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, int mode, int file)
+int __isolate_lru_page(struct page *page, enum ISOLATE_MODE mode, int file)
 {
+	bool all_lru_mode;
 	int ret = -EINVAL;
 
 	/* Only take pages on the LRU. */
 	if (!PageLRU(page))
 		return ret;
 
+	all_lru_mode = (mode & (ISOLATE_ACTIVE|ISOLATE_INACTIVE)) == 
+		(ISOLATE_ACTIVE|ISOLATE_INACTIVE);
+
 	/*
 	 * When checking the active state, we need to be sure we are
 	 * dealing with comparible boolean values.  Take the logical not
 	 * of each.
 	 */
-	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
+	if (!all_lru_mode && !PageActive(page) != !(mode & ISOLATE_ACTIVE))
 		return ret;
 
-	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
+	if (!all_lru_mode && !!page_is_file_cache(page) != file)
 		return ret;
 
 	/*
@@ -1021,7 +1025,8 @@ int __isolate_lru_page(struct page *page, int mode, int file)
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int mode, int file)
+		unsigned long *scanned, int order, enum ISOLATE_MODE mode,
+		int file)
 {
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1134,8 +1139,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 static unsigned long isolate_pages_global(unsigned long nr,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
-					int active, int file)
+					enum ISOLATE_MODE mode,
+					struct zone *z,	int active, int file)
 {
 	int lru = LRU_BASE;
 	if (active)
@@ -1382,6 +1387,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	enum ISOLATE_MODE reclaim_mode = ISOLATE_INACTIVE;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1392,15 +1398,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	}
 
 	set_reclaim_mode(priority, sc, false);
+	if (sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM)
+		reclaim_mode |= ISOLATE_ACTIVE;
+
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 
 	if (scanning_global_lru(sc)) {
-		nr_taken = isolate_pages_global(nr_to_scan,
-			&page_list, &nr_scanned, sc->order,
-			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
-					ISOLATE_BOTH : ISOLATE_INACTIVE,
-			zone, 0, file);
+		nr_taken = isolate_pages_global(nr_to_scan, &page_list,
+			&nr_scanned, sc->order, reclaim_mode, zone, 0, file);
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
 			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
@@ -1409,12 +1415,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 			__count_zone_vm_events(PGSCAN_DIRECT, zone,
 					       nr_scanned);
 	} else {
-		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
-			&page_list, &nr_scanned, sc->order,
-			sc->reclaim_mode & RECLAIM_MODE_LUMPYRECLAIM ?
-					ISOLATE_BOTH : ISOLATE_INACTIVE,
-			zone, sc->mem_cgroup,
-			0, file);
+		nr_taken = mem_cgroup_isolate_pages(nr_to_scan, &page_list,
+			&nr_scanned, sc->order, reclaim_mode, zone,
+			sc->mem_cgroup, 0, file);
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
