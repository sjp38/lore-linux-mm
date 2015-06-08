Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 48A75900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:07 -0400 (EDT)
Received: by wgv5 with SMTP id 5so104176601wgv.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x19si5343971wjq.43.2015.06.08.06.56.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:57 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/25] mm: Move NR_FILE_MAPPED accounting to the node
Date: Mon,  8 Jun 2015 14:56:19 +0100
Message-Id: <1433771791-30567-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Reclaim makes decisions based on the number of file pages that are mapped but
it's mixing node and zone information. Account NR_FILE_MAPPED pages on the node.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/tile/mm/pgtable.c |  2 +-
 drivers/base/node.c    |  4 ++--
 fs/proc/meminfo.c      |  4 ++--
 include/linux/mmzone.h |  6 +++---
 mm/page_alloc.c        |  6 +++---
 mm/rmap.c              | 12 ++++++------
 mm/vmscan.c            |  2 +-
 mm/vmstat.c            |  4 ++--
 8 files changed, 20 insertions(+), 20 deletions(-)

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
index b06ae7bfea63..4a83f3c9891a 100644
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
index d3ebf2e61853..8f105c774b2e 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -173,8 +173,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
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
index 22cdd8da6fb0..a523e1a30e54 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -116,9 +116,6 @@ enum zone_stat_item {
 	NR_FREE_PAGES,
 	NR_ALLOC_BATCH,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
-	NR_ANON_PAGES,	/* Mapped anonymous pages */
-	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
-			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
@@ -160,6 +157,9 @@ enum node_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
+	NR_ANON_PAGES,	/* Mapped anonymous pages */
+	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
+			   only modified from process context */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fa54792f1719..f5a376056ece 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3251,7 +3251,7 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_FREE_PAGES),
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
-		global_page_state(NR_FILE_MAPPED),
+		global_node_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
@@ -3266,6 +3266,7 @@ void show_free_areas(unsigned int filter)
 			" unevictable:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
+			" mapped:%lukB"
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
@@ -3276,6 +3277,7 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			!pgdat_reclaimable(pgdat) ? "yes" : "no");
 	}
 
@@ -3295,7 +3297,6 @@ void show_free_areas(unsigned int filter)
 			" mlocked:%lukB"
 			" dirty:%lukB"
 			" writeback:%lukB"
-			" mapped:%lukB"
 			" shmem:%lukB"
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
@@ -3317,7 +3318,6 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_MLOCK)),
 			K(zone_page_state(zone, NR_FILE_DIRTY)),
 			K(zone_page_state(zone, NR_WRITEBACK)),
-			K(zone_page_state(zone, NR_FILE_MAPPED)),
 			K(zone_page_state(zone, NR_SHMEM)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
diff --git a/mm/rmap.c b/mm/rmap.c
index 75f1e06f3339..f2ce8d11bed6 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1046,8 +1046,8 @@ void do_page_add_anon_rmap(struct page *page,
 		if (PageTransHuge(page))
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
-				hpage_nr_pages(page));
+		__mod_node_page_state(page_zone(page)->zone_pgdat,
+				NR_ANON_PAGES, hpage_nr_pages(page));
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1078,7 +1078,7 @@ void page_add_new_anon_rmap(struct page *page,
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
 	if (PageTransHuge(page))
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES,
 			hpage_nr_pages(page));
 	__page_set_anon_rmap(page, vma, address, 1);
 }
@@ -1095,7 +1095,7 @@ void page_add_file_rmap(struct page *page)
 
 	memcg = mem_cgroup_begin_page_stat(page);
 	if (atomic_inc_and_test(&page->_mapcount)) {
-		__inc_zone_page_state(page, NR_FILE_MAPPED);
+		__inc_node_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
 	mem_cgroup_end_page_stat(memcg);
@@ -1120,7 +1120,7 @@ static void page_remove_file_rmap(struct page *page)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_FILE_MAPPED);
+	__dec_node_page_state(page, NR_FILE_MAPPED);
 	mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
@@ -1158,7 +1158,7 @@ void page_remove_rmap(struct page *page)
 	if (PageTransHuge(page))
 		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
+	__mod_node_page_state(page_zone(page)->zone_pgdat, NR_ANON_PAGES,
 			      -hpage_nr_pages(page));
 
 	if (unlikely(PageMlocked(page)))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3a6a2fac48e5..1391fd15a7ec 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3549,7 +3549,7 @@ int sysctl_min_slab_ratio = 5;
 
 static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
 {
-	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
+	unsigned long file_mapped = node_page_state(zone->zone_pgdat, NR_FILE_MAPPED);
 	unsigned long file_lru = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
 		node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 054ee50974c9..4aa4fb09d078 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -895,8 +895,6 @@ const char * const vmstat_text[] = {
 	"nr_free_pages",
 	"nr_alloc_batch",
 	"nr_mlock",
-	"nr_anon_pages",
-	"nr_mapped",
 	"nr_file_pages",
 	"nr_dirty",
 	"nr_writeback",
@@ -936,6 +934,8 @@ const char * const vmstat_text[] = {
 	"workingset_refault",
 	"workingset_activate",
 	"workingset_nodereclaim",
+	"nr_anon_pages",
+	"nr_mapped",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
