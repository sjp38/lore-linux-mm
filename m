Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 419206B0264
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:09:37 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so73202428lfi.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:09:37 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id k63si5191941wmd.98.2016.07.15.06.09.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 06:09:27 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 4E88C1C26FA
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:09:27 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 5/5] mm, vmscan: Update all zone LRU sizes before updating memcg
Date: Fri, 15 Jul 2016 14:09:25 +0100
Message-Id: <1468588165-12461-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Minchan Kim reported setting the following warning on a 32-bit system
although it can affect 64-bit systems.

  WARNING: CPU: 4 PID: 1322 at mm/memcontrol.c:998 mem_cgroup_update_lru_size+0x103/0x110
  mem_cgroup_update_lru_size(f44b4000, 1, -7): zid 1 lru_size 1 but empty
  Modules linked in:
  CPU: 4 PID: 1322 Comm: cp Not tainted 4.7.0-rc4-mm1+ #143
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
   00000086 00000086 c2bc5a10 db3e4a97 c2bc5a54 db9d4025 c2bc5a40 db07b82a
   db9d0594 c2bc5a70 0000052a db9d4025 000003e6 db208463 000003e6 00000001
   f44b4000 00000001 c2bc5a5c db07b88b 00000009 00000000 c2bc5a54 db9d0594
  Call Trace:
   [<db3e4a97>] dump_stack+0x76/0xaf
   [<db07b82a>] __warn+0xea/0x110
   [<db208463>] ? mem_cgroup_update_lru_size+0x103/0x110
   [<db07b88b>] warn_slowpath_fmt+0x3b/0x40
   [<db208463>] mem_cgroup_update_lru_size+0x103/0x110
   [<db1b52a2>] isolate_lru_pages.isra.61+0x2e2/0x360
   [<db1b6ffc>] shrink_active_list+0xac/0x2a0
   [<db3f136e>] ? __delay+0xe/0x10
   [<db1b772c>] shrink_node_memcg+0x53c/0x7a0
   [<db1b7a3b>] shrink_node+0xab/0x2a0
   [<db1b7cf6>] do_try_to_free_pages+0xc6/0x390
   [<db1b8205>] try_to_free_pages+0x245/0x590

LRU list contents and counts are updated separately. Counts are updated
before pages are added to the LRU and updated after pages are removed.
The warning above is from a check in mem_cgroup_update_lru_size that
ensures that list sizes of zero are empty.

The problem is that node-lru needs to account for highmem pages if
CONFIG_HIGHMEM is set. One impact of the implementation is that the
sizes are updated in multiple passes when pages from multiple zones were
isolated. This happens whether HIGHMEM is set or not. When multiple zones
are isolated, it's possible for a debugging check in memcg to be tripped.

This patch forces all the zone counts to be updated before the memcg
function is called.

Reported-and-tested-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/memcontrol.h |  2 +-
 include/linux/mm_inline.h  |  5 ++---
 mm/memcontrol.c            |  5 +----
 mm/vmscan.c                | 40 +++++++++++++++++++++++++++++++++-------
 4 files changed, 37 insertions(+), 15 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 80bf8458148a..79c17e1732ae 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -431,7 +431,7 @@ static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
-		enum zone_type zid, int nr_pages);
+		int nr_pages);
 
 unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 					   int nid, unsigned int lru_mask);
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index ccd40e357b56..d29237428199 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -56,10 +56,9 @@ static __always_inline void update_lru_size(struct lruvec *lruvec,
 				enum lru_list lru, enum zone_type zid,
 				int nr_pages)
 {
-#ifdef CONFIG_MEMCG
-	mem_cgroup_update_lru_size(lruvec, lru, zid, nr_pages);
-#else
 	__update_lru_size(lruvec, lru, zid, nr_pages);
+#ifdef CONFIG_MEMCG
+	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
 #endif
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9cbd40ebccd1..13be30c3ea78 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -965,7 +965,6 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgd
  * mem_cgroup_update_lru_size - account for adding or removing an lru page
  * @lruvec: mem_cgroup per zone lru vector
  * @lru: index of lru list the page is sitting on
- * @zid: Zone ID of the zone pages have been added to
  * @nr_pages: positive when adding or negative when removing
  *
  * This function must be called under lru_lock, just before a page is added
@@ -973,15 +972,13 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgd
  * so as to allow it to check that lru_size 0 is consistent with list_empty).
  */
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
-				enum zone_type zid, int nr_pages)
+				int nr_pages)
 {
 	struct mem_cgroup_per_node *mz;
 	unsigned long *lru_size;
 	long size;
 	bool empty;
 
-	__update_lru_size(lruvec, lru, zid, nr_pages);
-
 	if (mem_cgroup_disabled())
 		return;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c2ad4263f965..3f06a7a0d135 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1350,6 +1350,38 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 	return ret;
 }
 
+
+/*
+ * Update LRU sizes after isolating pages. The LRU size updates must
+ * be complete before mem_cgroup_update_lru_size due to a santity check.
+ */
+static __always_inline void update_lru_sizes(struct lruvec *lruvec,
+			enum lru_list lru, unsigned long *nr_zone_taken,
+			unsigned long nr_taken)
+{
+#ifdef CONFIG_HIGHMEM
+	int zid;
+
+	/*
+	 * Highmem has separate accounting for highmem pages so each zone
+	 * is updated separately.
+	 */
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		if (!nr_zone_taken[zid])
+			continue;
+
+		__update_lru_size(lruvec, lru, zid, -nr_zone_taken[zid]);
+	}
+#else
+	/* Zone ID does not matter on !HIGHMEM */
+	__update_lru_size(lruvec, lru, 0, -nr_taken);
+#endif
+
+#ifdef CONFIG_MEMCG
+	mem_cgroup_update_lru_size(lruvec, lru, -nr_taken);
+#endif
+}
+
 /*
  * zone_lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
@@ -1436,13 +1468,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
 				    nr_taken, mode, is_file_lru(lru));
-	for (scan = 0; scan < MAX_NR_ZONES; scan++) {
-		nr_pages = nr_zone_taken[scan];
-		if (!nr_pages)
-			continue;
-
-		update_lru_size(lruvec, lru, scan, -nr_pages);
-	}
+	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);
 	return nr_taken;
 }
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
