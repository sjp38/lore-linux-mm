Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFEE828E4
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 07:21:41 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id l6so60355351wml.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 04:21:41 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id 130si5234366wmq.3.2016.04.06.04.21.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 04:21:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 9B20898EDE
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 11:21:31 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 16/27] mm: Move page mapped accounting to the node
Date: Wed,  6 Apr 2016 12:20:15 +0100
Message-Id: <1459941626-3290-17-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
References: <1459941626-3290-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Reclaim makes decisions based on the number of file pages that are mapped but
it's mixing node and zone information. Account NR_FILE_MAPPED pages on the node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 arch/tile/mm/pgtable.c |  2 +-
 drivers/base/node.c    |  4 ++--
 fs/proc/meminfo.c      |  4 ++--
 include/linux/mmzone.h |  6 +++---
 mm/page_alloc.c        |  6 +++---
 mm/rmap.c              | 13 +++++++------
 mm/vmscan.c            |  2 +-
 mm/vmstat.c            |  4 ++--
 8 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 3ed0a666d44a..2e784e84bd6f 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -55,7 +55,7 @@ void show_mem(unsigned int filter)
 	       global_page_state(NR_FREE_PAGES),
 	       (global_page_state(NR_SLAB_RECLAIMABLE) +
 		global_page_state(NR_SLAB_UNRECLAIMABLE)),
-	       global_page_state(NR_FILE_MAPPED),
+	       global_node_page_state(NR_FILE_MAPPED),
 	       global_page_state(NR_PAGETABLE),
 	       global_page_state(NR_BOUNCE),
 	       global_page_state(NR_FILE_PAGES),
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 4260c7f3ee1b..66aed68a0fdc 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -119,8 +119,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(sum_zone_node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK)),
 		       nid, K(sum_zone_node_page_state(nid, NR_FILE_PAGES)),
-		       nid, K(sum_zone_node_page_state(nid, NR_FILE_MAPPED)),
-		       nid, K(sum_zone_node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
+		       nid, K(node_page_state(pgdat, NR_ANON_PAGES)),
 		       nid, K(i.sharedram),
 		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 83720460c5bc..54e039682ec9 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -138,8 +138,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
 		K(global_page_state(NR_WRITEBACK)),
-		K(global_page_state(NR_ANON_PAGES)),
-		K(global_page_state(NR_FILE_MAPPED)),
+		K(global_node_page_state(NR_ANON_PAGES)),
+		K(global_node_page_state(NR_FILE_MAPPED)),
 		K(i.sharedram),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 86714d52d3a3..e7d105259aa6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -119,9 +119,6 @@ enum zone_stat_item {
 	NR_FREE_PAGES,
 	NR_ALLOC_BATCH,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
-	NR_ANON_PAGES,	/* Mapped anonymous pages */
-	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
-			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
@@ -163,6 +160,9 @@ enum node_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
+	NR_ANON_PAGES,	/* Mapped anonymous pages */
+	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
+			   only modified from process context */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b30a77fb0697..36119b734e3c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3893,7 +3893,7 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_UNSTABLE_NFS),
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
-		global_page_state(NR_FILE_MAPPED),
+		global_node_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
@@ -3910,6 +3910,7 @@ void show_free_areas(unsigned int filter)
 			" unevictable:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
+			" mapped:%lukB"
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
@@ -3920,6 +3921,7 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			!pgdat_reclaimable(pgdat) ? "yes" : "no");
 	}
 
@@ -3944,7 +3946,6 @@ void show_free_areas(unsigned int filter)
 			" mlocked:%lukB"
 			" dirty:%lukB"
 			" writeback:%lukB"
-			" mapped:%lukB"
 			" shmem:%lukB"
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
@@ -3968,7 +3969,6 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_MLOCK)),
 			K(zone_page_state(zone, NR_FILE_DIRTY)),
 			K(zone_page_state(zone, NR_WRITEBACK)),
-			K(zone_page_state(zone, NR_FILE_MAPPED)),
 			K(zone_page_state(zone, NR_SHMEM)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
diff --git a/mm/rmap.c b/mm/rmap.c
index 5b3c19f633c2..0788298025e5 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1231,7 +1231,8 @@ void do_page_add_anon_rmap(struct page *page,
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
 		}
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
+		__mod_node_page_state(page_zone(page)->zone_pgdat,
+				NR_ANON_PAGES, nr);
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1275,7 +1276,7 @@ void page_add_new_anon_rmap(struct page *page,
 		/* increment count (starts at -1) */
 		atomic_set(&page->_mapcount, 0);
 	}
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
 }
 
@@ -1289,7 +1290,7 @@ void page_add_file_rmap(struct page *page)
 {
 	lock_page_memcg(page);
 	if (atomic_inc_and_test(&page->_mapcount)) {
-		__inc_zone_page_state(page, NR_FILE_MAPPED);
+		__inc_node_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
 	unlock_page_memcg(page);
@@ -1315,7 +1316,7 @@ static void page_remove_file_rmap(struct page *page)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_FILE_MAPPED);
+	__dec_node_page_state(page, NR_FILE_MAPPED);
 	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
@@ -1357,7 +1358,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		clear_page_mlock(page);
 
 	if (nr) {
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
+		__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES, -nr);
 		deferred_split_huge_page(page);
 	}
 }
@@ -1389,7 +1390,7 @@ void page_remove_rmap(struct page *page, bool compound)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_ANON_PAGES);
+	__dec_node_page_state(page, NR_ANON_PAGES);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 09e557c95731..b13deefc671b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3593,7 +3593,7 @@ int sysctl_min_slab_ratio = 5;
 
 static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
 {
-	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
+	unsigned long file_mapped = node_page_state(zone->zone_pgdat, NR_FILE_MAPPED);
 	unsigned long file_lru = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
 		node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 80a75f8ede5b..4fd6d3f8764d 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -939,8 +939,6 @@ const char * const vmstat_text[] = {
 	"nr_free_pages",
 	"nr_alloc_batch",
 	"nr_mlock",
-	"nr_anon_pages",
-	"nr_mapped",
 	"nr_file_pages",
 	"nr_dirty",
 	"nr_writeback",
@@ -980,6 +978,8 @@ const char * const vmstat_text[] = {
 	"workingset_refault",
 	"workingset_activate",
 	"workingset_nodereclaim",
+	"nr_anon_pages",
+	"nr_mapped",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
