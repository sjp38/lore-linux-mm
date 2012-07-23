Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 870B26B0078
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:38:57 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 12/34] mm: change isolate mode from #define to bitwise type
Date: Mon, 23 Jul 2012 14:38:25 +0100
Message-Id: <1343050727-3045-13-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Minchan Kim <minchan.kim@gmail.com>

commit 4356f21d09283dc6d39a6f7287a65ddab61e2808 upstream.

Stable note: Not tracked in Bugzilla. This patch makes later patches
	easier to apply but has no other impact.

Change ISOLATE_XXX macro with bitwise isolate_mode_t type.  Normally,
macro isn't recommended as it's type-unsafe and making debugging harder as
symbol cannot be passed throught to the debugger.

Quote from Johannes
" Hmm, it would probably be cleaner to fully convert the isolation mode
into independent flags.  INACTIVE, ACTIVE, BOTH is currently a
tri-state among flags, which is a bit ugly."

This patch moves isolate mode from swap.h to mmzone.h by memcontrol.h

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  |    8 ++---
 include/linux/memcontrol.h                         |    3 +-
 include/linux/mmzone.h                             |    8 +++++
 include/linux/swap.h                               |    7 +---
 include/trace/events/vmscan.h                      |    8 ++---
 mm/compaction.c                                    |    3 +-
 mm/memcontrol.c                                    |    3 +-
 mm/vmscan.c                                        |   37 +++++++++++---------
 8 files changed, 43 insertions(+), 34 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index 12cecc8..4a37c47 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -379,10 +379,10 @@ EVENT_PROCESS:
 
 			# To closer match vmstat scanning statistics, only count isolate_both
 			# and isolate_inactive as scanning. isolate_active is rotation
-			# isolate_inactive == 0
-			# isolate_active   == 1
-			# isolate_both     == 2
-			if ($isolate_mode != 1) {
+			# isolate_inactive == 1
+			# isolate_active   == 2
+			# isolate_both     == 3
+			if ($isolate_mode != 2) {
 				$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
 			}
 			$perprocesspid{$process_pid}->{HIGH_NR_CONTIG_DIRTY} += $nr_contig_dirty;
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 313a00e..4a8da84 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -35,7 +35,8 @@ enum mem_cgroup_page_stat_item {
 extern unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
+					isolate_mode_t mode,
+					struct zone *z,
 					struct mem_cgroup *mem_cont,
 					int active, int file);
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 9f7c3eb..5a5286d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -158,6 +158,14 @@ static inline int is_unevictable_lru(enum lru_list l)
 	return (l == LRU_UNEVICTABLE);
 }
 
+/* Isolate inactive pages */
+#define ISOLATE_INACTIVE	((__force isolate_mode_t)0x1)
+/* Isolate active pages */
+#define ISOLATE_ACTIVE		((__force isolate_mode_t)0x2)
+
+/* LRU Isolation modes. */
+typedef unsigned __bitwise__ isolate_mode_t;
+
 enum zone_watermarks {
 	WMARK_MIN,
 	WMARK_LOW,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a273468..e73799d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -243,11 +243,6 @@ static inline void lru_cache_add_file(struct page *page)
 	__lru_cache_add(page, LRU_INACTIVE_FILE);
 }
 
-/* LRU Isolation modes. */
-#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
-#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
-#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
-
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
@@ -259,7 +254,7 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						unsigned int swappiness,
 						struct zone *zone,
 						unsigned long *nr_scanned);
-extern int __isolate_lru_page(struct page *page, int mode, int file);
+extern int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 36851f7..edc4b3d 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -266,7 +266,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		isolate_mode_t isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
 
@@ -278,7 +278,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__field(unsigned long, nr_lumpy_taken)
 		__field(unsigned long, nr_lumpy_dirty)
 		__field(unsigned long, nr_lumpy_failed)
-		__field(int, isolate_mode)
+		__field(isolate_mode_t, isolate_mode)
 	),
 
 	TP_fast_assign(
@@ -312,7 +312,7 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		isolate_mode_t isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
 
@@ -327,7 +327,7 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		int isolate_mode),
+		isolate_mode_t isolate_mode),
 
 	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
 
diff --git a/mm/compaction.c b/mm/compaction.c
index d8c023e..4fbbbd0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -371,7 +371,8 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		}
 
 		/* Try isolate the page */
-		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) != 0)
+		if (__isolate_lru_page(page,
+				ISOLATE_ACTIVE|ISOLATE_INACTIVE, 0) != 0)
 			continue;
 
 		VM_BUG_ON(PageTransCompound(page));
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ffb99b4..57cdf5a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1251,7 +1251,8 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
+					isolate_mode_t mode,
+					struct zone *z,
 					struct mem_cgroup *mem_cont,
 					int active, int file)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 65388ac..4bb2010 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1012,23 +1012,27 @@ keep_lumpy:
  *
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, int mode, int file)
+int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
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
@@ -1076,7 +1080,8 @@ int __isolate_lru_page(struct page *page, int mode, int file)
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int mode, int file)
+		unsigned long *scanned, int order, isolate_mode_t mode,
+		int file)
 {
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1201,8 +1206,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 static unsigned long isolate_pages_global(unsigned long nr,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
-					int mode, struct zone *z,
-					int active, int file)
+					isolate_mode_t mode,
+					struct zone *z,	int active, int file)
 {
 	int lru = LRU_BASE;
 	if (active)
@@ -1448,6 +1453,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	unsigned long nr_taken;
 	unsigned long nr_anon;
 	unsigned long nr_file;
+	isolate_mode_t reclaim_mode = ISOLATE_INACTIVE;
 
 	while (unlikely(too_many_isolated(zone, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -1458,15 +1464,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
@@ -1475,12 +1481,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
