Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A7EBE6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 11:50:27 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d65so50253068ith.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 08:50:27 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 203si14193376ita.17.2016.07.19.08.50.26
        for <linux-mm@kvack.org>;
        Tue, 19 Jul 2016 08:50:26 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] mm: consider per-zone inactive ratio to deactivate
Date: Wed, 20 Jul 2016 00:50:33 +0900
Message-Id: <1468943433-24805-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1468943433-24805-1-git-send-email-minchan@kernel.org>
References: <1468943433-24805-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

With per-zone lru stat, we could know normal zone has 86M anonymous
memory but OOM happend with non-atomic order-0 allocation. And most of
anonymous pages in normal zone are on active list.

gfp_mask=0x26004c0(GFP_KERNEL|__GFP_REPEAT|__GFP_NOTRACK), order=0
Call Trace:
 [<c51a76e2>] __alloc_pages_nodemask+0xe52/0xe60
 [<c51f31dc>] ? new_slab+0x39c/0x3b0
 [<c51f31dc>] new_slab+0x39c/0x3b0
 [<c51f4eca>] ___slab_alloc.constprop.87+0x6da/0x840
 [<c563e6fc>] ? __alloc_skb+0x3c/0x260
 [<c50b8e93>] ? enqueue_task_fair+0x73/0xbf0
 [<c5219ee0>] ? poll_select_copy_remaining+0x140/0x140
 [<c5201645>] __slab_alloc.isra.81.constprop.86+0x40/0x6d
 [<c563e6fc>] ? __alloc_skb+0x3c/0x260
 [<c51f525c>] kmem_cache_alloc+0x22c/0x260
 [<c563e6fc>] ? __alloc_skb+0x3c/0x260
 [<c563e6fc>] __alloc_skb+0x3c/0x260
 [<c563eece>] alloc_skb_with_frags+0x4e/0x1a0
 [<c5638d6a>] sock_alloc_send_pskb+0x16a/0x1b0
 [<c570b581>] ? wait_for_unix_gc+0x31/0x90
 [<c57084dd>] unix_stream_sendmsg+0x28d/0x340
 [<c5634dad>] sock_sendmsg+0x2d/0x40
 [<c5634e2c>] sock_write_iter+0x6c/0xc0
 [<c5204a90>] __vfs_write+0xc0/0x120
 [<c52053ab>] vfs_write+0x9b/0x1a0
 [<c51cc4a9>] ? __might_fault+0x49/0xa0
 [<c52062c4>] SyS_write+0x44/0x90
 [<c50036c6>] do_fast_syscall_32+0xa6/0x1e0

Mem-Info:
active_anon:101103 inactive_anon:102219 isolated_anon:0
 active_file:503 inactive_file:544 isolated_file:0
 unevictable:0 dirty:0 writeback:34 unstable:0
 slab_reclaimable:6298 slab_unreclaimable:74669
 mapped:863 shmem:0 pagetables:100998 bounce:0
 free:23573 free_pcp:1861 free_cma:0
Node 0 active_anon:404412kB inactive_anon:409040kB active_file:2012kB inactive_file:2176kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:3452kB dirty:0kB writeback:136kB shmem:0kB writeback_tmp:0kB unstable:0kB pages_scanned:1320845 all_unreclaimable? yes
DMA free:3296kB min:68kB low:84kB high:100kB active_anon:5540kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:248kB slab_unreclaimable:2628kB kernel_stack:792kB pagetables:2316kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 809 1965 1965
Normal free:3600kB min:3604kB low:4504kB high:5404kB active_anon:86304kB inactive_anon:0kB active_file:160kB inactive_file:376kB present:897016kB managed:858524kB mlocked:0kB slab_reclaimable:24944kB slab_unreclaimable:296048kB kernel_stack:163832kB pagetables:35892kB bounce:0kB free_pcp:3076kB local_pcp:656kB free_cma:0kB
lowmem_reserve[]: 0 0 9247 9247
HighMem free:86156kB min:512kB low:1796kB high:3080kB active_anon:312852kB inactive_anon:410024kB active_file:1924kB inactive_file:2012kB present:1183736kB managed:1183736kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:365784kB bounce:0kB free_pcp:3868kB local_pcp:720kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0
DMA: 8*4kB (UM) 8*8kB (UM) 4*16kB (M) 2*32kB (UM) 2*64kB (UM) 1*128kB (M) 3*256kB (UME) 2*512kB (UE) 1*1024kB (E) 0*2048kB 0*4096kB = 3296kB
Normal: 240*4kB (UME) 160*8kB (UME) 23*16kB (ME) 3*32kB (UE) 3*64kB (UME) 2*128kB (ME) 1*256kB (U) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3408kB
HighMem: 10942*4kB (UM) 3102*8kB (UM) 866*16kB (UM) 76*32kB (UM) 11*64kB (UM) 4*128kB (UM) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 86344kB
Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
54409 total pagecache pages
53215 pages in swap cache
Swap cache stats: add 300982, delete 247765, find 157978/226539
Free swap  = 3803244kB
Total swap = 4192252kB
524186 pages RAM
295934 pages HighMem/MovableOnly
9642 pages reserved
0 pages cma reserved

The problem was current deactivation logic(i.e., inactive_list_is_low).

	Node 0 active_anon:404412kB inactive_anon:409040kB

IOW, (inactive_anon of node * inactive_ratio > active_anon of node) due
to highmem anonymous stat so VM never deactivates normal zone's
anonymous pages.

This patch makes inactive_list_is_low be aware of per-zone inactive raio
so if requested zone or lower zones's LRU list cannot meet the ratio, VM
start to deactivate pages.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/vmscan.c | 41 ++++++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dffa7e0..e60329b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1955,12 +1955,16 @@ static void shrink_active_list(unsigned long nr_to_scan,
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-static bool inactive_list_is_low(struct lruvec *lruvec, bool file)
+static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
+						int classzone_idx)
 {
 	unsigned long inactive_ratio;
 	unsigned long inactive;
 	unsigned long active;
 	unsigned long gb;
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+	struct zone *zone;
+	int zone_idx;
 
 	/*
 	 * If we don't have swap space, anonymous page deactivation
@@ -1969,23 +1973,34 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file)
 	if (!file && !total_swap_pages)
 		return false;
 
-	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
-	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
+	for (zone_idx = classzone_idx; zone_idx > 0; zone_idx--) {
+		zone = &pgdat->node_zones[zone_idx];
+		if (!populated_zone(zone))
+			continue;
 
-	gb = (inactive + active) >> (30 - PAGE_SHIFT);
-	if (gb)
-		inactive_ratio = int_sqrt(10 * gb);
-	else
-		inactive_ratio = 1;
+		inactive = zone_page_state(zone,
+				NR_ZONE_LRU_BASE + file * LRU_FILE);
+		active = zone_page_state(zone,
+				NR_ZONE_LRU_BASE + file * LRU_FILE + LRU_ACTIVE);
 
-	return inactive * inactive_ratio < active;
+		gb = (inactive + active) >> (30 - PAGE_SHIFT);
+		if (gb)
+			inactive_ratio = int_sqrt(10 * gb);
+		else
+			inactive_ratio = 1;
+
+		if ((inactive * inactive_ratio) < active)
+			return true;
+	}
+
+	return false;
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
 	if (is_active_lru(lru)) {
-		if (inactive_list_is_low(lruvec, is_file_lru(lru)))
+		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc->reclaim_idx))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
 		return 0;
 	}
@@ -2116,7 +2131,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * lruvec even if it has plenty of old anonymous pages unless the
 	 * system is under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true) &&
+	if (!inactive_list_is_low(lruvec, true, sc->reclaim_idx) &&
 	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
@@ -2358,7 +2373,7 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	 * Even if we did not try to evict anon pages at all, we want to
 	 * rebalance the anon lru active/inactive ratio.
 	 */
-	if (inactive_list_is_low(lruvec, false))
+	if (inactive_list_is_low(lruvec, false, sc->reclaim_idx))
 		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 				   sc, LRU_ACTIVE_ANON);
 
@@ -3011,7 +3026,7 @@ static void age_active_anon(struct pglist_data *pgdat,
 	do {
 		struct lruvec *lruvec = mem_cgroup_lruvec(pgdat, memcg);
 
-		if (inactive_list_is_low(lruvec, false))
+		if (inactive_list_is_low(lruvec, false, sc->reclaim_idx))
 			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
 					   sc, LRU_ACTIVE_ANON);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
