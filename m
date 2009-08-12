Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1955B6B005D
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 04:32:19 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/5] mm: drop unneeded double negations
Date: Wed, 12 Aug 2009 10:32:05 +0200
Message-Id: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Remove double negations where the operand is already boolean.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>
---
 mm/memcontrol.c |    2 +-
 mm/memory.c     |    2 +-
 mm/vmscan.c     |    8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

v2: leave double negation for TestClearPageActive() until bitops
semantics are sorted out [thanks, Mel]

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 48a38e1..140b5a6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -900,7 +900,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 	int nid = z->zone_pgdat->node_id;
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
-	int lru = LRU_FILE * !!file + !!active;
+	int lru = LRU_FILE * file + active;
 	int ret;
 
 	BUG_ON(!mem_cont);
diff --git a/mm/memory.c b/mm/memory.c
index 2fadf30..574cd3e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -598,7 +598,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	if (page) {
 		get_page(page);
 		page_dup_rmap(page);
-		rss[!!PageAnon(page)]++;
+		rss[PageAnon(page)]++;
 	}
 
 out_set_pte:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bcddc75..9a4c298 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -966,7 +966,7 @@ static unsigned long isolate_pages_global(unsigned long nr,
 	if (file)
 		lru += LRU_FILE;
 	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, !!file);
+								mode, file);
 }
 
 /*
@@ -1204,7 +1204,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 			lru = page_lru(page);
 			add_page_to_lru_list(zone, page, lru);
 			if (is_active_lru(lru)) {
-				int file = !!is_file_lru(lru);
+				int file = is_file_lru(lru);
 				reclaim_stat->recent_rotated[file]++;
 			}
 			if (!pagevec_add(&pvec, page)) {
@@ -1314,7 +1314,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	if (scanning_global_lru(sc)) {
 		zone->pages_scanned += pgscanned;
 	}
-	reclaim_stat->recent_scanned[!!file] += nr_taken;
+	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	if (file)
@@ -1367,7 +1367,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	 * helps balance scan pressure between file and anonymous pages in
 	 * get_scan_ratio.
 	 */
-	reclaim_stat->recent_rotated[!!file] += nr_rotated;
+	reclaim_stat->recent_rotated[file] += nr_rotated;
 
 	move_active_pages_to_lru(zone, &l_active,
 						LRU_ACTIVE + file * LRU_FILE);
-- 
1.6.4.13.ge6580

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
