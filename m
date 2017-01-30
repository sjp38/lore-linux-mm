Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E51B6B0291
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:51:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 75so444194756pgf.3
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 92si11618470pli.75.2017.01.29.21.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 21:51:25 -0800 (PST)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U5e6Lq024835
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:24 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 288qgawr5d-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:24 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 21a82212e6b011e6b91f0002c99293a0-701f2a50 for <linux-mm@kvack.org>;	Sun, 29
 Jan 2017 21:51:23 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 3/6] mm: add LRU_LAZYFREE lru list
Date: Sun, 29 Jan 2017 21:51:20 -0800
Message-ID: <7cafca66d7862b97f7a4fd99e425551ee5bc5ea8.1485748619.git.shli@fb.com>
In-Reply-To: <cover.1485748619.git.shli@fb.com>
References: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net

MADV_FREE pages are in anonymous LRU list currently, there are several problems:
- Doesn't support system without swap enabled. Because if swap is off,
  we can't or can't efficiently age anonymous pages. And since MADV_FREE
  pages are mixed with other anonymous pages, we can't reclaim MADV_FREE pages
- Increases memory pressure. page reclaim bias file pages reclaim
  against anonymous pages. This doesn't make sense for MADV_FREE pages,
  because those pages could be freed easily with very slight penality.
  Even page reclaim doesn't bias file pages, there is still an issue,
  because MADV_FREE pages and other anonymous pages are mixed together.
  To reclaim a MADV_FREE page, we probably must scan a lot of other
  anonymous pages, which is inefficient.

Introducing a new LRU list for MADV_FREE pages could solve the issues.
If only MADV_FREE pages are in the new list, page reclaim can easily
reclaim such pages without interference of file or anonymous pages.

This patch adds a LRU_LAZYFREE lru list. It's a dedicated LRU list for
MADV_FREE pages.

The patch is based on Minchan's previous patch.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 drivers/base/node.c                       |  2 ++
 drivers/staging/android/lowmemorykiller.c |  3 ++-
 fs/proc/meminfo.c                         |  1 +
 include/linux/mm_inline.h                 | 10 ++++++++++
 include/linux/mmzone.h                    |  9 +++++++++
 include/linux/vm_event_item.h             |  2 +-
 include/trace/events/mmflags.h            |  1 +
 include/trace/events/vmscan.h             | 10 +++++++---
 kernel/power/snapshot.c                   |  1 +
 mm/compaction.c                           |  8 +++++---
 mm/memcontrol.c                           |  4 ++++
 mm/page_alloc.c                           | 10 ++++++++++
 mm/vmscan.c                               | 21 ++++++++++++++-------
 mm/vmstat.c                               |  4 ++++
 14 files changed, 71 insertions(+), 15 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..5c09b67 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -70,6 +70,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d Inactive(anon): %8lu kB\n"
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
+		       "Node %d LazyFree:	%8lu kB\n"
 		       "Node %d Unevictable:    %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n",
 		       nid, K(i.totalram),
@@ -83,6 +84,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_INACTIVE_ANON)),
 		       nid, K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(pgdat, NR_INACTIVE_FILE)),
+		       nid, K(node_page_state(pgdat, NR_LAZYFREE)),
 		       nid, K(node_page_state(pgdat, NR_UNEVICTABLE)),
 		       nid, K(sum_zone_node_page_state(nid, NR_MLOCK)));
 
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index ec3b665..2648872 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -75,7 +75,8 @@ static unsigned long lowmem_count(struct shrinker *s,
 	return global_node_page_state(NR_ACTIVE_ANON) +
 		global_node_page_state(NR_ACTIVE_FILE) +
 		global_node_page_state(NR_INACTIVE_ANON) +
-		global_node_page_state(NR_INACTIVE_FILE);
+		global_node_page_state(NR_INACTIVE_FILE) +
+		global_node_page_state(NR_LAZYFREE);
 }
 
 static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 8a42849..7803d33 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -79,6 +79,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Inactive(anon): ", pages[LRU_INACTIVE_ANON]);
 	show_val_kb(m, "Active(file):   ", pages[LRU_ACTIVE_FILE]);
 	show_val_kb(m, "Inactive(file): ", pages[LRU_INACTIVE_FILE]);
+	show_val_kb(m, "LazyFree:       ", pages[LRU_LAZYFREE]);
 	show_val_kb(m, "Unevictable:    ", pages[LRU_UNEVICTABLE]);
 	show_val_kb(m, "Mlocked:        ", global_page_state(NR_MLOCK));
 
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 828e813..5f22c93 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -81,6 +81,8 @@ static inline enum lru_list page_lru_base_type(struct page *page)
 {
 	if (page_is_file_cache(page))
 		return LRU_INACTIVE_FILE;
+	if (PageLazyFree(page))
+		return LRU_LAZYFREE;
 	return LRU_INACTIVE_ANON;
 }
 
@@ -100,6 +102,8 @@ static __always_inline enum lru_list page_off_lru(struct page *page)
 		lru = LRU_UNEVICTABLE;
 	} else {
 		lru = page_lru_base_type(page);
+		if (lru == LRU_LAZYFREE)
+			__ClearPageLazyFree(page);
 		if (PageActive(page)) {
 			__ClearPageActive(page);
 			lru += LRU_ACTIVE;
@@ -123,6 +127,8 @@ static __always_inline enum lru_list page_lru(struct page *page)
 		lru = LRU_UNEVICTABLE;
 	else {
 		lru = page_lru_base_type(page);
+		if (lru == LRU_LAZYFREE)
+			return lru;
 		if (PageActive(page))
 			lru += LRU_ACTIVE;
 	}
@@ -139,6 +145,8 @@ static inline int lru_isolate_index(enum lru_list lru)
 {
 	if (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE)
 		return NR_ISOLATED_FILE;
+	if (lru == LRU_LAZYFREE)
+		return NR_ISOLATED_LAZYFREE;
 	return NR_ISOLATED_ANON;
 }
 
@@ -152,6 +160,8 @@ static inline int page_isolate_index(struct page *page)
 {
 	if (!PageSwapBacked(page))
 		return NR_ISOLATED_FILE;
+	else if (PageLazyFree(page))
+		return NR_ISOLATED_LAZYFREE;
 	return NR_ISOLATED_ANON;
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 338a786a..589a165 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -117,6 +117,7 @@ enum zone_stat_item {
 	NR_ZONE_ACTIVE_ANON,
 	NR_ZONE_INACTIVE_FILE,
 	NR_ZONE_ACTIVE_FILE,
+	NR_ZONE_LAZYFREE,
 	NR_ZONE_UNEVICTABLE,
 	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
@@ -146,9 +147,11 @@ enum node_stat_item {
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
+	NR_LAZYFREE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
+	NR_ISOLATED_LAZYFREE,	/* Temporary isolated pages from lazyfree lru */
 	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
@@ -190,6 +193,7 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
+	LRU_LAZYFREE,
 	LRU_UNEVICTABLE,
 	NR_LRU_LISTS
 };
@@ -203,6 +207,11 @@ static inline int is_file_lru(enum lru_list lru)
 	return (lru == LRU_INACTIVE_FILE || lru == LRU_ACTIVE_FILE);
 }
 
+static inline int is_anon_lru(enum lru_list lru)
+{
+	return lru <= LRU_ACTIVE_ANON;
+}
+
 static inline int is_active_lru(enum lru_list lru)
 {
 	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 6aa1b6c..94e58da 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -25,7 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
 		FOR_ALL_ZONES(ALLOCSTALL),
 		FOR_ALL_ZONES(PGSCAN_SKIP),
-		PGFREE, PGACTIVATE, PGDEACTIVATE,
+		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
 		PGREFILL,
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 12cd88c..058b799 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -244,6 +244,7 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 		EM (LRU_ACTIVE_ANON, "active_anon") \
 		EM (LRU_INACTIVE_FILE, "inactive_file") \
 		EM (LRU_ACTIVE_FILE, "active_file") \
+		EM (LRU_LAZYFREE, "lazyfree") \
 		EMe(LRU_UNEVICTABLE, "unevictable")
 
 /*
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index fab386d..7ece3ab 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -12,8 +12,9 @@
 
 #define RECLAIM_WB_ANON		0x0001u
 #define RECLAIM_WB_FILE		0x0002u
+#define RECLAIM_WB_LAZYFREE	0x0004u
 #define RECLAIM_WB_MIXED	0x0010u
-#define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim async */
+#define RECLAIM_WB_SYNC		0x0020u /* Unused, all reclaim async */
 #define RECLAIM_WB_ASYNC	0x0008u
 #define RECLAIM_WB_LRU		(RECLAIM_WB_ANON|RECLAIM_WB_FILE)
 
@@ -21,20 +22,23 @@
 	(flags) ? __print_flags(flags, "|",			\
 		{RECLAIM_WB_ANON,	"RECLAIM_WB_ANON"},	\
 		{RECLAIM_WB_FILE,	"RECLAIM_WB_FILE"},	\
+		{RECLAIM_WB_LAZYFREE,	"RECLAIM_WB_LAZYFREE"},	\
 		{RECLAIM_WB_MIXED,	"RECLAIM_WB_MIXED"},	\
 		{RECLAIM_WB_SYNC,	"RECLAIM_WB_SYNC"},	\
 		{RECLAIM_WB_ASYNC,	"RECLAIM_WB_ASYNC"}	\
 		) : "RECLAIM_WB_NONE"
 
 #define trace_reclaim_flags(page) ( \
-	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
+	(page_is_file_cache(page) ? RECLAIM_WB_FILE : \
+	 PageLazyFree(page) ? RECLAIM_WB_LAZYFREE : RECLAIM_WB_ANON) | \
 	(RECLAIM_WB_ASYNC) \
 	)
 
 #define trace_shrink_flags(isolate_index) \
 	( \
 		(isolate_index == NR_ISOLATED_FILE ? RECLAIM_WB_FILE : \
-			RECLAIM_WB_ANON) | \
+			isolate_index == NR_ISOLATED_ANON ? RECLAIM_WB_ANON: \
+			RECLAIM_WB_LAZYFREE) | \
 		(RECLAIM_WB_ASYNC) \
 	)
 
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 2d8e2b2..6d50a48 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1653,6 +1653,7 @@ static unsigned long minimum_image_size(unsigned long saveable)
 		+ global_node_page_state(NR_INACTIVE_ANON)
 		+ global_node_page_state(NR_ACTIVE_FILE)
 		+ global_node_page_state(NR_INACTIVE_FILE)
+		+ global_node_page_state(NR_LAZYFREE)
 		- global_node_page_state(NR_FILE_MAPPED);
 
 	return saveable <= size ? 0 : saveable - size;
diff --git a/mm/compaction.c b/mm/compaction.c
index 3918c48..9c842b9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -637,16 +637,18 @@ isolate_freepages_range(struct compact_control *cc,
 /* Similar to reclaim, but different enough that they don't share logic */
 static bool too_many_isolated(struct zone *zone)
 {
-	unsigned long active, inactive, isolated;
+	unsigned long active, inactive, lazyfree, isolated;
 
 	inactive = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
 			node_page_state(zone->zone_pgdat, NR_INACTIVE_ANON);
 	active = node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE) +
 			node_page_state(zone->zone_pgdat, NR_ACTIVE_ANON);
+	lazyfree = node_page_state(zone->zone_pgdat, NR_LAZYFREE);
 	isolated = node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE) +
-			node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON);
+			node_page_state(zone->zone_pgdat, NR_ISOLATED_ANON) +
+			node_page_state(zone->zone_pgdat, NR_ISOLATED_LAZYFREE);
 
-	return isolated > (inactive + active) / 2;
+	return isolated > (inactive + active + lazyfree) / 2;
 }
 
 /**
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b822e15..0113240 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -120,6 +120,7 @@ static const char * const mem_cgroup_lru_names[] = {
 	"active_anon",
 	"inactive_file",
 	"active_file",
+	"lazyfree",
 	"unevictable",
 };
 
@@ -1263,6 +1264,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 		int nid, bool noswap)
 {
+	if (mem_cgroup_node_nr_lru_pages(memcg, nid, BIT(LRU_LAZYFREE)))
+		return true;
 	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
@@ -3086,6 +3089,7 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 		{ "total", LRU_ALL },
 		{ "file", LRU_ALL_FILE },
 		{ "anon", LRU_ALL_ANON },
+		{ "lazyfree", BIT(LRU_LAZYFREE) },
 		{ "unevictable", BIT(LRU_UNEVICTABLE) },
 	};
 	const struct numa_stat *stat;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 11b4cd4..d00b41e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4316,6 +4316,9 @@ long si_mem_available(void)
 	pagecache -= min(pagecache / 2, wmark_low);
 	available += pagecache;
 
+	/* lazyfree pages can be freed */
+	available += pages[LRU_LAZYFREE];
+
 	/*
 	 * Part of the reclaimable slab consists of items that are in use,
 	 * and cannot be freed. Cap this estimate at the low watermark.
@@ -4450,6 +4453,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
+		" lazy_free:%lu isolated_lazy_free:%lu\n"
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
@@ -4460,6 +4464,8 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 		global_node_page_state(NR_ACTIVE_FILE),
 		global_node_page_state(NR_INACTIVE_FILE),
 		global_node_page_state(NR_ISOLATED_FILE),
+		global_node_page_state(NR_LAZYFREE),
+		global_node_page_state(NR_ISOLATED_LAZYFREE),
 		global_node_page_state(NR_UNEVICTABLE),
 		global_node_page_state(NR_FILE_DIRTY),
 		global_node_page_state(NR_WRITEBACK),
@@ -4483,9 +4489,11 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" inactive_anon:%lukB"
 			" active_file:%lukB"
 			" inactive_file:%lukB"
+			" lazy_free:%lukB"
 			" unevictable:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
+			" isolated(lazy_free):%lukB"
 			" mapped:%lukB"
 			" dirty:%lukB"
 			" writeback:%lukB"
@@ -4505,9 +4513,11 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(node_page_state(pgdat, NR_INACTIVE_ANON)),
 			K(node_page_state(pgdat, NR_ACTIVE_FILE)),
 			K(node_page_state(pgdat, NR_INACTIVE_FILE)),
+			K(node_page_state(pgdat, NR_LAZYFREE)),
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			K(node_page_state(pgdat, NR_ISOLATED_LAZYFREE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			K(node_page_state(pgdat, NR_FILE_DIRTY)),
 			K(node_page_state(pgdat, NR_WRITEBACK)),
diff --git a/mm/vmscan.c b/mm/vmscan.c
index abb64b7..3a0d05b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -205,7 +205,8 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
 	unsigned long nr;
 
 	nr = zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_FILE) +
-		zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_FILE);
+		zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_FILE) +
+		zone_page_state_snapshot(zone, NR_ZONE_LAZYFREE);
 	if (get_nr_swap_pages() > 0)
 		nr += zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_ANON) +
 			zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_ANON);
@@ -219,7 +220,9 @@ unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
 
 	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
 	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
-	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
+	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE) +
+	     node_page_state_snapshot(pgdat, NR_LAZYFREE) +
+	     node_page_state_snapshot(pgdat, NR_ISOLATED_LAZYFREE);
 
 	if (get_nr_swap_pages() > 0)
 		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
@@ -1602,7 +1605,7 @@ int isolate_lru_page(struct page *page)
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
  */
-static int too_many_isolated(struct pglist_data *pgdat, int file,
+static int too_many_isolated(struct pglist_data *pgdat, enum lru_list lru,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
@@ -1613,12 +1616,15 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
 	if (!sane_reclaim(sc))
 		return 0;
 
-	if (file) {
+	if (is_file_lru(lru)) {
 		inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
 		isolated = node_page_state(pgdat, NR_ISOLATED_FILE);
-	} else {
+	} else if (is_anon_lru(lru)) {
 		inactive = node_page_state(pgdat, NR_INACTIVE_ANON);
 		isolated = node_page_state(pgdat, NR_ISOLATED_ANON);
+	} else {
+		inactive = node_page_state(pgdat, NR_LAZYFREE);
+		isolated = node_page_state(pgdat, NR_ISOLATED_LAZYFREE);
 	}
 
 	/*
@@ -1718,7 +1724,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(pgdat, file, sc))) {
+	while (unlikely(too_many_isolated(pgdat, lru, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
@@ -2498,7 +2504,8 @@ static inline bool should_continue_reclaim(struct pglist_data *pgdat,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = compact_gap(sc->order);
-	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE);
+	inactive_lru_pages = node_page_state(pgdat, NR_INACTIVE_FILE) +
+			node_page_state(pgdat, NR_LAZYFREE);
 	if (get_nr_swap_pages() > 0)
 		inactive_lru_pages += node_page_state(pgdat, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 69f9aff..86ffe2c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -925,6 +925,7 @@ const char * const vmstat_text[] = {
 	"nr_zone_active_anon",
 	"nr_zone_inactive_file",
 	"nr_zone_active_file",
+	"nr_zone_lazyfree",
 	"nr_zone_unevictable",
 	"nr_zone_write_pending",
 	"nr_mlock",
@@ -951,9 +952,11 @@ const char * const vmstat_text[] = {
 	"nr_active_anon",
 	"nr_inactive_file",
 	"nr_active_file",
+	"nr_lazyfree",
 	"nr_unevictable",
 	"nr_isolated_anon",
 	"nr_isolated_file",
+	"nr_isolated_lazyfree",
 	"nr_pages_scanned",
 	"workingset_refault",
 	"workingset_activate",
@@ -992,6 +995,7 @@ const char * const vmstat_text[] = {
 	"pgfree",
 	"pgactivate",
 	"pgdeactivate",
+	"pglazyfree",
 
 	"pgfault",
 	"pgmajfault",
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
