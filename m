Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48C8E6B0268
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:38:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so8323031wma.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:38:17 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id k190si2057442wme.130.2016.07.08.02.38.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 02:38:16 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id B5F221C24D8
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:38:15 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 17/34] mm: move page mapped accounting to the node
Date: Fri,  8 Jul 2016 10:34:53 +0100
Message-Id: <1467970510-21195-18-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Reclaim makes decisions based on the number of pages that are mapped but
it's mixing node and zone information.  Account NR_FILE_MAPPED and
NR_ANON_PAGES pages on the node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/tile/mm/pgtable.c |  2 +-
 drivers/base/node.c    |  4 ++--
 fs/proc/meminfo.c      |  4 ++--
 include/linux/mmzone.h |  6 +++---
 mm/page_alloc.c        |  6 +++---
 mm/rmap.c              | 14 +++++++-------
 mm/vmscan.c            |  2 +-
 mm/vmstat.c            |  4 ++--
 8 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 9e389213580d..c606b0ef2f7e 100644
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
index b7f01a4a642d..acca09536ad9 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -121,8 +121,8 @@ static ssize_t node_read_meminfo(struct device *dev,
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
index cf301a9ef512..b8d52aa2f19a 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -140,8 +140,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
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
index fae2fe3c6942..95d34d1e1fb5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -115,9 +115,6 @@ enum zone_stat_item {
 	NR_ZONE_LRU_ANON = NR_ZONE_LRU_BASE,
 	NR_ZONE_LRU_FILE,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
-	NR_ANON_PAGES,	/* Mapped anonymous pages */
-	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
-			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
@@ -164,6 +161,9 @@ enum node_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
+	NR_ANON_PAGES,	/* Mapped anonymous pages */
+	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
+			   only modified from process context */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9e113a6ff9a0..78338b51819b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4355,7 +4355,7 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_UNSTABLE_NFS),
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
-		global_page_state(NR_FILE_MAPPED),
+		global_node_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
@@ -4377,6 +4377,7 @@ void show_free_areas(unsigned int filter)
 			" unevictable:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
+			" mapped:%lukB"
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
@@ -4387,6 +4388,7 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_UNEVICTABLE)),
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
+			K(node_page_state(pgdat, NR_FILE_MAPPED)),
 			!pgdat_reclaimable(pgdat) ? "yes" : "no");
 	}
 
@@ -4411,7 +4413,6 @@ void show_free_areas(unsigned int filter)
 			" mlocked:%lukB"
 			" dirty:%lukB"
 			" writeback:%lukB"
-			" mapped:%lukB"
 			" shmem:%lukB"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			" shmem_thp: %lukB"
@@ -4440,7 +4441,6 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_MLOCK)),
 			K(zone_page_state(zone, NR_FILE_DIRTY)),
 			K(zone_page_state(zone, NR_WRITEBACK)),
-			K(zone_page_state(zone, NR_FILE_MAPPED)),
 			K(zone_page_state(zone, NR_SHMEM)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			K(zone_page_state(zone, NR_SHMEM_THPS) * HPAGE_PMD_NR),
diff --git a/mm/rmap.c b/mm/rmap.c
index 573253efb645..17876517f5fa 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1217,7 +1217,7 @@ void do_page_add_anon_rmap(struct page *page,
 		 */
 		if (compound)
 			__inc_zone_page_state(page, NR_ANON_THPS);
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
+		__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, nr);
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1261,7 +1261,7 @@ void page_add_new_anon_rmap(struct page *page,
 		/* increment count (starts at -1) */
 		atomic_set(&page->_mapcount, 0);
 	}
-	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
+	__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, nr);
 	__page_set_anon_rmap(page, vma, address, 1);
 }
 
@@ -1296,7 +1296,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 		if (!atomic_inc_and_test(&page->_mapcount))
 			goto out;
 	}
-	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, nr);
+	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, nr);
 	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 out:
 	unlock_page_memcg(page);
@@ -1332,11 +1332,11 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	}
 
 	/*
-	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
+	 * We use the irq-unsafe __{inc|mod}_zone_page_state because
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, -nr);
+	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, -nr);
 	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
@@ -1378,7 +1378,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 		clear_page_mlock(page);
 
 	if (nr) {
-		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, -nr);
+		__mod_node_page_state(page_pgdat(page), NR_ANON_PAGES, -nr);
 		deferred_split_huge_page(page);
 	}
 }
@@ -1407,7 +1407,7 @@ void page_remove_rmap(struct page *page, bool compound)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_ANON_PAGES);
+	__dec_node_page_state(page, NR_ANON_PAGES);
 
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8d2555dd3ef3..2e8d72d7e268 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3587,7 +3587,7 @@ int sysctl_min_slab_ratio = 5;
 
 static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
 {
-	unsigned long file_mapped = zone_page_state(zone, NR_FILE_MAPPED);
+	unsigned long file_mapped = node_page_state(zone->zone_pgdat, NR_FILE_MAPPED);
 	unsigned long file_lru = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
 		node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d17d66e85def..02e7406e8fcd 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -925,8 +925,6 @@ const char * const vmstat_text[] = {
 	"nr_zone_anon_lru",
 	"nr_zone_file_lru",
 	"nr_mlock",
-	"nr_anon_pages",
-	"nr_mapped",
 	"nr_file_pages",
 	"nr_dirty",
 	"nr_writeback",
@@ -970,6 +968,8 @@ const char * const vmstat_text[] = {
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
