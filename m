Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 364F36B02E1
	for <linux-mm@kvack.org>; Wed, 10 May 2017 19:00:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u12so8424584pgo.4
        for <linux-mm@kvack.org>; Wed, 10 May 2017 16:00:38 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z133si359263pgz.210.2017.05.10.16.00.36
        for <linux-mm@kvack.org>;
        Wed, 10 May 2017 16:00:37 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2] mm: vmscan: scan until it founds eligible pages
Date: Thu, 11 May 2017 08:00:32 +0900
Message-ID: <1494457232-27401-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

Although there are a ton of free swap and anonymous LRU page
in elgible zones, OOM happened.

balloon invoked oom-killer: gfp_mask=0x17080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=(null),  order=0, oom_score_adj=0
CPU: 7 PID: 1138 Comm: balloon Not tainted 4.11.0-rc6-mm1-zram-00289-ge228d67e9677-dirty #17
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
Call Trace:
 dump_stack+0x65/0x87
 dump_header.isra.19+0x8f/0x20f
 ? preempt_count_add+0x9e/0xb0
 ? _raw_spin_unlock_irqrestore+0x24/0x40
 oom_kill_process+0x21d/0x3f0
 ? has_capability_noaudit+0x17/0x20
 out_of_memory+0xd8/0x390
 __alloc_pages_slowpath+0xbc1/0xc50
 ? anon_vma_interval_tree_insert+0x84/0x90
 __alloc_pages_nodemask+0x1a5/0x1c0
 pte_alloc_one+0x20/0x50
 __pte_alloc+0x1e/0x110
 __handle_mm_fault+0x919/0x960
 handle_mm_fault+0x77/0x120
 __do_page_fault+0x27a/0x550
 trace_do_page_fault+0x43/0x150
 do_async_page_fault+0x2c/0x90
 async_page_fault+0x28/0x30
RIP: 0033:0x7fc4636bacb8
RSP: 002b:00007fff97c9c4c0 EFLAGS: 00010202
RAX: 00007fc3e818d000 RBX: 00007fc4639f8760 RCX: 00007fc46372e9ca
RDX: 0000000000101002 RSI: 0000000000101000 RDI: 0000000000000000
RBP: 0000000000100010 R08: 00000000ffffffff R09: 0000000000000000
R10: 0000000000000022 R11: 00000000000a3901 R12: 00007fc3e818d010
R13: 0000000000101000 R14: 00007fc4639f87b8 R15: 00007fc4639f87b8
Mem-Info:
active_anon:424716 inactive_anon:65314 isolated_anon:0
 active_file:52 inactive_file:46 isolated_file:0
 unevictable:0 dirty:27 writeback:0 unstable:0
 slab_reclaimable:3967 slab_unreclaimable:4125
 mapped:133 shmem:43 pagetables:1674 bounce:0
 free:4637 free_pcp:225 free_cma:0
Node 0 active_anon:1698864kB inactive_anon:261256kB active_file:208kB inactive_file:184kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:532kB dirty:108kB writeback:0kB shmem:172kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
DMA free:7316kB min:32kB low:44kB high:56kB active_anon:8064kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:464kB slab_unreclaimable:40kB kernel_stack:0kB pagetables:24kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
lowmem_reserve[]: 0 992 992 1952
DMA32 free:9088kB min:2048kB low:3064kB high:4080kB active_anon:952176kB inactive_anon:0kB active_file:36kB inactive_file:0kB unevictable:0kB writepending:88kB present:1032192kB managed:1019388kB mlocked:0kB slab_reclaimable:13532kB slab_unreclaimable:16460kB kernel_stack:3552kB pagetables:6672kB bounce:0kB free_pcp:56kB local_pcp:24kB free_cma:0kB
lowmem_reserve[]: 0 0 0 959
Movable free:3644kB min:1980kB low:2960kB high:3940kB active_anon:738560kB inactive_anon:261340kB active_file:188kB inactive_file:640kB unevictable:0kB writepending:20kB present:1048444kB managed:1010816kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:832kB local_pcp:60kB free_cma:0kB
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB (E) 0*8kB 18*16kB (E) 10*32kB (E) 10*64kB (E) 9*128kB (ME) 8*256kB (E) 2*512kB (E) 2*1024kB (E) 0*2048kB 0*4096kB = 7524kB
DMA32: 417*4kB (UMEH) 181*8kB (UMEH) 68*16kB (UMEH) 48*32kB (UMEH) 14*64kB (MH) 3*128kB (M) 1*256kB (H) 1*512kB (M) 2*1024kB (M) 0*2048kB 0*4096kB = 9836kB
Movable: 1*4kB (M) 1*8kB (M) 1*16kB (M) 1*32kB (M) 0*64kB 1*128kB (M) 2*256kB (M) 4*512kB (M) 1*1024kB (M) 0*2048kB 0*4096kB = 3772kB
378 total pagecache pages
17 pages in swap cache
Swap cache stats: add 17325, delete 17302, find 0/27
Free swap  = 978940kB
Total swap = 1048572kB
524157 pages RAM
0 pages HighMem/MovableOnly
12629 pages reserved
0 pages cma reserved
0 pages hwpoisoned
[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  433]     0   433     4904        5      14       3       82             0 upstart-udev-br
[  438]     0   438    12371        5      27       3      191         -1000 systemd-udevd

With investigation, skipping page of isolate_lru_pages makes reclaim
void because it returns zero nr_taken easily so LRU shrinking is
effectively nothing and just increases priority aggressively.
Finally, OOM happens.

The problem is that get_scan_count determines nr_to_scan with
eligible zones so although priority drops to zero, it couldn't
reclaim any pages if the LRU contains mostly ineligible pages.

get_scan_count:

        size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
	size = size >> sc->priority;

Assumes sc->priority is 0 and LRU list is as follows.

	N-N-N-N-H-H-H-H-H-H-H-H-H-H-H-H-H-H-H-H

(Ie, small eligible pages are in the head of LRU but others are
 almost ineligible pages)

In that case, size becomes 4 so VM want to scan 4 pages but 4 pages
from tail of the LRU are not eligible pages.
If get_scan_count counts skipped pages, it doesn't reclaim any pages
remained after scanning 4 pages so it ends up OOM happening.

This patch makes isolate_lru_pages try to scan pages until it
encounters eligible zones's pages.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
* from v1
  * put more words in description and code
  * drop unncessary pages_skipped list flushing

 mm/vmscan.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ebf468c5429..e051bf4a1144 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1449,7 +1449,7 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
  *
  * Appropriate locks must be held before calling this function.
  *
- * @nr_to_scan:	The number of pages to look through on the list.
+ * @nr_to_scan:	The number of eligible pages to look through on the list.
  * @lruvec:	The LRU vector to pull pages from.
  * @dst:	The temp list to put pages on to.
  * @nr_scanned:	The number of pages that were scanned.
@@ -1469,11 +1469,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long skipped = 0;
-	unsigned long scan, nr_pages;
+	unsigned long scan, total_scan, nr_pages;
 	LIST_HEAD(pages_skipped);
 
-	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
-					!list_empty(src); scan++) {
+	for (total_scan = scan = 0; scan < nr_to_scan &&
+					nr_taken < nr_to_scan &&
+					!list_empty(src);
+					total_scan++) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1487,6 +1489,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 		}
 
+		/*
+		 * Do not count skipped pages because it makes the function to
+		 * return with none isolated pages if the LRU mostly contains
+		 * ineligible pages so that VM cannot reclaim any pages and
+		 * trigger premature OOM.
+		 */
+		scan++;
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
@@ -1524,9 +1533,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			skipped += nr_skipped[zid];
 		}
 	}
-	*nr_scanned = scan;
+	*nr_scanned = total_scan;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
-				    scan, skipped, nr_taken, mode, lru);
+				    total_scan, skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken);
 	return nr_taken;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
