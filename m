Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A9BCA6B01F2
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 21:20:42 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH] mm: disallow direct reclaim page writeback
Date: Tue, 13 Apr 2010 10:17:58 +1000
Message-Id: <1271117878-19274-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

When we enter direct reclaim we may have used an arbitrary amount of stack
space, and hence enterring the filesystem to do writeback can then lead to
stack overruns. This problem was recently encountered x86_64 systems with
8k stacks running XFS with simple storage configurations.

Writeback from direct reclaim also adversely affects background writeback. The
background flusher threads should already be taking care of cleaning dirty
pages, and direct reclaim will kick them if they aren't already doing work. If
direct reclaim is also calling ->writepage, it will cause the IO patterns from
the background flusher threads to be upset by LRU-order writeback from
pageout() which can be effectively random IO. Having competing sources of IO
trying to clean pages on the same backing device reduces throughput by
increasing the amount of seeks that the backing device has to do to write back
the pages.

Hence for direct reclaim we should not allow ->writepages to be entered at all.
Set up the relevant scan_control structures to enforce this, and prevent
sc->may_writepage from being set in other places in the direct reclaim path in
response to other events.

Reported-by: John Berthels <john@humyo.com>
Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 mm/vmscan.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0e5f15..5321ac4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1826,10 +1826,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
 		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
-		if (total_scanned > writeback_threshold) {
+		if (total_scanned > writeback_threshold)
 			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
-			sc->may_writepage = 1;
-		}
 
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
@@ -1871,7 +1869,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
 		.may_swap = 1,
@@ -1893,7 +1891,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						struct zone *zone, int nid)
 {
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.swappiness = swappiness,
@@ -1926,7 +1924,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 {
 	struct zonelist *zonelist;
 	struct scan_control sc = {
-		.may_writepage = !laptop_mode,
+		.may_writepage = 0,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
@@ -2567,7 +2565,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	struct reclaim_state reclaim_state;
 	int priority;
 	struct scan_control sc = {
-		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
+		.may_writepage = (current_is_kswapd() &&
+					(zone_reclaim_mode & RECLAIM_WRITE)),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.may_swap = 1,
 		.nr_to_reclaim = max_t(unsigned long, nr_pages,
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
