Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF96828E2
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 09:21:58 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so53027199lfe.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 06:21:58 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.74])
        by mx.google.com with ESMTPS id cv1si183877wjb.126.2016.06.23.06.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 06:21:56 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [RFC, DEBUGGING v2 1/2] mm: pass NR_FILE_PAGES/NR_SHMEM into node_page_state
Date: Thu, 23 Jun 2016 15:18:38 +0200
Message-Id: <20160623131839.3579472-1-arnd@arndb.de>
In-Reply-To: <3817461.6pThRKgN9N@wuerfel>
References: <3817461.6pThRKgN9N@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>

I see some new warnings from a recent mm change:

mm/filemap.c: In function '__delete_from_page_cache':
include/linux/vmstat.h:116:2: error: array subscript is above array bounds [-Werror=array-bounds]
  atomic_long_add(x, &zone->vm_stat[item]);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
include/linux/vmstat.h:116:35: error: array subscript is above array bounds [-Werror=array-bounds]
  atomic_long_add(x, &zone->vm_stat[item]);
                      ~~~~~~~~~~~~~^~~~~~
include/linux/vmstat.h:116:35: error: array subscript is above array bounds [-Werror=array-bounds]
include/linux/vmstat.h:117:2: error: array subscript is above array bounds [-Werror=array-bounds]

Looking deeper into it, I find that we pass the wrong enum
into some functions after the type for the symbol has changed.

This changes the code to use the other function for those that
are using the incorrect type. I've done this blindly just going
by warnings I got from a debug patch I did for this, so it's likely
that some cases are more subtle and need another change, so please
treat this as a bug-report rather than a patch for applying.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: e426f7b4ade5 ("mm: move most file-based accounting to the node")
---
 mm/filemap.c    |  4 ++--
 mm/khugepaged.c |  4 ++--
 mm/page_alloc.c | 15 ++++++++-------
 mm/rmap.c       |  4 ++--
 mm/shmem.c      |  4 ++--
 mm/vmscan.c     |  2 +-
 6 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 6cb19e012887..e0fe47e9ea44 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -218,9 +218,9 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!PageHuge(page))
-		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page)) {
-		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
+		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
 		if (PageTransHuge(page))
 			__dec_zone_page_state(page, NR_SHMEM_THPS);
 	} else {
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index af256d599080..0efda0345aed 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1476,8 +1476,8 @@ tree_unlocked:
 		local_irq_save(flags);
 		__inc_zone_page_state(new_page, NR_SHMEM_THPS);
 		if (nr_none) {
-			__mod_zone_page_state(zone, NR_FILE_PAGES, nr_none);
-			__mod_zone_page_state(zone, NR_SHMEM, nr_none);
+			__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
+			__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
 		}
 		local_irq_restore(flags);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 23b5044f5ced..277dc0cbe780 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3484,9 +3484,10 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 				unsigned long writeback;
 				unsigned long dirty;
 
-				writeback = zone_page_state_snapshot(zone,
+				writeback = node_page_state_snapshot(zone->zone_pgdat,
 								     NR_WRITEBACK);
-				dirty = zone_page_state_snapshot(zone, NR_FILE_DIRTY);
+				dirty = node_page_state_snapshot(zone->zone_pgdat,
+								 NR_FILE_DIRTY);
 
 				if (2*(writeback + dirty) > reclaimable) {
 					congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -4396,9 +4397,9 @@ void show_free_areas(unsigned int filter)
 			K(zone->present_pages),
 			K(zone->managed_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
-			K(zone_page_state(zone, NR_FILE_DIRTY)),
-			K(zone_page_state(zone, NR_WRITEBACK)),
-			K(zone_page_state(zone, NR_SHMEM)),
+			K(node_page_state(zone->zone_pgdat, NR_FILE_DIRTY)),
+			K(node_page_state(zone->zone_pgdat, NR_WRITEBACK)),
+			K(node_page_state(zone->zone_pgdat, NR_SHMEM)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			K(zone_page_state(zone, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 			K(zone_page_state(zone, NR_SHMEM_PMDMAPPED)
@@ -4410,12 +4411,12 @@ void show_free_areas(unsigned int filter)
 			zone_page_state(zone, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
 			K(zone_page_state(zone, NR_PAGETABLE)),
-			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
+			K(node_page_state(zone->zone_pgdat, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(free_pcp),
 			K(this_cpu_read(zone->pageset->pcp.count)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
-			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
+			K(node_page_state(zone->zone_pgdat, NR_WRITEBACK_TEMP)),
 			K(node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
diff --git a/mm/rmap.c b/mm/rmap.c
index 4deff963ea8a..a66f80bc8703 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1296,7 +1296,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 		if (!atomic_inc_and_test(&page->_mapcount))
 			goto out;
 	}
-	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, nr);
+	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, nr);
 	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 out:
 	unlock_page_memcg(page);
@@ -1336,7 +1336,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, -nr);
+	__mod_node_page_state(page_pgdat(page), NR_FILE_MAPPED, -nr);
 	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
diff --git a/mm/shmem.c b/mm/shmem.c
index e5c50fb0d4a4..a03c087f71fe 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -576,8 +576,8 @@ static int shmem_add_to_page_cache(struct page *page,
 		mapping->nrpages += nr;
 		if (PageTransHuge(page))
 			__inc_zone_page_state(page, NR_SHMEM_THPS);
-		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
-		__mod_zone_page_state(page_zone(page), NR_SHMEM, nr);
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
+		__mod_node_page_state(page_pgdat(page), NR_SHMEM, nr);
 		spin_unlock_irq(&mapping->tree_lock);
 	} else {
 		page->mapping = NULL;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 07e17dac1793..4702069cc80b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2079,7 +2079,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 		int z;
 		unsigned long total_high_wmark = 0;
 
-		pgdatfree = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
+		pgdatfree = global_page_state(NR_FREE_PAGES);
 		pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
 			   node_page_state(pgdat, NR_INACTIVE_FILE);
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
