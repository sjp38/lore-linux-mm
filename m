Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C62696B002C
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 04:08:45 -0500 (EST)
Date: Mon, 6 Feb 2012 09:08:41 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: mm: compaction: Check for overlapping nodes during isolation for
 migration
Message-ID: <20120206090841.GF5938@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When isolating pages for migration, migration starts at the start of a
zone while the free scanner starts at the end of the zone. Migration
avoids entering a new zone by never going beyond the free scanned.
Unfortunately, in very rare cases nodes can overlap. When this happens,
migration isolates pages without the LRU lock held, corrupting lists
which will trigger errors in reclaim or during page free such as in the
following oops

[ 8739.994311] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[ 8739.994331] IP: [<ffffffff810f795c>] free_pcppages_bulk+0xcc/0x450
[ 8739.994344] PGD 1dda554067 PUD 1e1cb58067 PMD 0
[ 8739.994350] Oops: 0000 [#1] SMP
[ 8739.994357] CPU 37
[ 8739.994359] Modules linked in: veth(X) <SNIPPED>
[ 8739.994457] Supported: Yes
[ 8739.994461]
[ 8739.994465] Pid: 17088, comm: memcg_process_s Tainted: G            X
[ 8739.994477] RIP: 0010:[<ffffffff810f795c>]  [<ffffffff810f795c>] free_pcppages_bulk+0xcc/0x450
[ 8739.994483] RSP: 0000:ffff881c2926f7a8  EFLAGS: 00010082
[ 8739.994488] RAX: 0000000000000010 RBX: 0000000000000000 RCX: ffff881e7f4546c8
[ 8739.994491] RDX: ffff881e7f4546b0 RSI: 0000000000000000 RDI: 0000000000000167
[ 8739.994498] RBP: 0000000000000000 R08: 0000000000000000 R09: 0000000000000000
[ 8739.994502] R10: 0000000000000166 R11: ffffea0060ea0e50 R12: ffffffffffffffd8
[ 8739.994506] R13: 0000000000000001 R14: ffff881c7ffd9e00 R15: 0000000000000000
[ 8739.994511] FS:  00007f5072690700(0000) GS:ffff881e7f440000(0000) knlGS:0000000000000000
[ 8739.994517] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 8739.994522] CR2: 0000000000000008 CR3: 0000001e1f1f9000 CR4: 00000000000006e0
[ 8739.994525] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 8739.994530] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 8739.994535] Process memcg_process_s (pid: 17088, threadinfo ffff881c2926e000, task ffff881c2926c0c0)
[ 8739.994539] Stack:
[ 8739.994541]  0000000000000000 ffff881e7f4546c8 0000000000000010 ffff881c7ffd9e60
[ 8739.994557]  ffff881e7f4546b0 0000001f814498ee 0000000000000000 0000001d81245255
[ 8739.994565]  ffff881e7f4546c0 ffffea005ecd2f40 ffff881e7f4546b0 0020000000200010
[ 8739.994573] Call Trace:
[ 8739.994590]  [<ffffffff810f8bfe>] free_hot_cold_page+0x17e/0x1f0
[ 8739.994600]  [<ffffffff810f8ff0>] __pagevec_free+0x90/0xb0
[ 8739.994610]  [<ffffffff810fc08a>] release_pages+0x22a/0x260
[ 8739.994617]  [<ffffffff810fc1b3>] pagevec_lru_move_fn+0xf3/0x110
[ 8739.994627]  [<ffffffff81101e76>] putback_lru_page+0x66/0xe0
[ 8739.994639]  [<ffffffff8113fde6>] unmap_and_move+0x156/0x180
[ 8739.994647]  [<ffffffff8113feae>] migrate_pages+0x9e/0x1b0
[ 8739.994656]  [<ffffffff81136313>] compact_zone+0x1f3/0x2f0
[ 8739.994665]  [<ffffffff81136672>] compact_zone_order+0xa2/0xe0
[ 8739.994672]  [<ffffffff8113678f>] try_to_compact_pages+0xdf/0x110
[ 8739.994678]  [<ffffffff810f7eae>] __alloc_pages_direct_compact+0xee/0x1c0
[ 8739.994686]  [<ffffffff810f82f0>] __alloc_pages_slowpath+0x370/0x830
[ 8739.994694]  [<ffffffff810f8961>] __alloc_pages_nodemask+0x1b1/0x1c0
[ 8739.994701]  [<ffffffff81134d2b>] alloc_pages_vma+0x9b/0x160
[ 8739.994712]  [<ffffffff811449a0>] do_huge_pmd_anonymous_page+0x160/0x270
[ 8739.994725]  [<ffffffff81444ba7>] do_page_fault+0x207/0x4c0
[ 8739.994735]  [<ffffffff814418e5>] page_fault+0x25/0x30
[ 8739.994748]  [<0000000000400997>] 0x400996

The "X" in the taint flag means that external modules were loaded but
but is unrelated to the bug triggering. The real problem was because
the PFN layout looks like this

[    0.000000] Zone PFN ranges:
[    0.000000]   DMA      0x00000010 -> 0x00001000
[    0.000000]   DMA32    0x00001000 -> 0x00100000
[    0.000000]   Normal   0x00100000 -> 0x01e80000
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[14] active PFN ranges
[    0.000000]     0: 0x00000010 -> 0x0000009b
[    0.000000]     0: 0x00000100 -> 0x0007a1ec
[    0.000000]     0: 0x0007a354 -> 0x0007a379
[    0.000000]     0: 0x0007f7ff -> 0x0007f800
[    0.000000]     0: 0x00100000 -> 0x00680000
[    0.000000]     1: 0x00680000 -> 0x00e80000
[    0.000000]     0: 0x00e80000 -> 0x01080000
[    0.000000]     1: 0x01080000 -> 0x01280000
[    0.000000]     0: 0x01280000 -> 0x01480000
[    0.000000]     1: 0x01480000 -> 0x01680000
[    0.000000]     0: 0x01680000 -> 0x01880000
[    0.000000]     1: 0x01880000 -> 0x01a80000
[    0.000000]     0: 0x01a80000 -> 0x01c80000
[    0.000000]     1: 0x01c80000 -> 0x01e80000

The fix is straight-forward. isolate_migratepages() has to make a
similar check to isolate_freepage to ensure that it never isolates
pages from a zone it does not hold the LRU lock for.

This was discovered in a 3.0-based kernel but it affects 3.1.x, 3.2.x
and current mainline.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: <stable@vger.kernel.org>
---
 mm/compaction.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index bd6e739..6042644 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -330,8 +330,17 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 			continue;
 		nr_scanned++;
 
-		/* Get the page and skip if free */
+		/*
+		 * Get the page and ensure the page is within the same zone.
+		 * See the comment in isolate_freepages about overlapping
+		 * nodes. It is deliberate that the new zone lock is not taken
+		 * as memory compaction should not move pages between nodes.
+		 */
 		page = pfn_to_page(low_pfn);
+		if (page_zone(page) != zone)
+			continue;
+
+		/* Skip if free */
 		if (PageBuddy(page))
 			continue;
 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
