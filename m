Date: Tue, 31 Jul 2007 23:52:28 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: make swappiness safer to use
Message-ID: <20070731215228.GU6910@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Swappiness isn't a safe sysctl. Setting it to 0 for example can hang a
system. That's a corner case but even setting it to 10 or lower can
waste enormous amounts of cpu without making much progress. We've
customers who wants to use swappiness but they can't because of the
current implementation (if you change it so the system stops swapping
it really stops swapping and nothing works sane anymore if you really
had to swap something to make progress).

This patch from Kurt Garloff makes swappiness safer to use (no more
huge cpu usage or hangs with low swappiness values).

I think the prev_priority can also be nuked since it wastes 4 bytes
per zone (that would be an incremental patch but I wait the
nr_scan_[in]active to be nuked first for similar reasons). Clearly
somebody at some point noticed how broken that thing was and they had
to add min(priority, prev_priority) to give it some reliability, but
they didn't go the last mile to nuke prev_priority too. Calculating
distress only in function of not-racy priority is correct and sure
more than enough without having to add randomness into the equation.

Patch is tested on older kernels but it compiles and it's quite simple
so...

Overall I'm not very satisified by the swappiness tweak, since it
doesn't rally do anything with the dirty pagecache that may be
inactive. We need another kind of tweak that controls the inactive
scan and tunes the can_writepage feature (not yet in mainline despite
having submitted it a few times), not only the active one. That new
tweak will tell the kernel how hard to scan the inactive list for pure
clean pagecache (something the mainline kernel isn't capable of
yet). We already have that feature working in all our enterprise
kernels with the default reasonable tune, or they can't even run a
readonly backup with tar without triggering huge write I/O. I think it
should be available also in mainline later.

Signed-off-by: Kurt Garloff <garloff@suse.de>
Acked-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -914,6 +914,22 @@ static void shrink_active_list(unsigned 
 		swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
 
 		/*
+		 * With low vm_swappiness values, we can actually reach
+		 * situations, where we have the inactive list almost
+		 * completely depleted.
+		 * This will result in the kernel behaving badly,
+		 * looping trying to find free ram and thrashing on
+		 * the working set's page faults.
+		 * So let's increase our swap_tendency when we get
+		 * into such a situation. The formula ensures we only
+		 * boost it when really needed.
+		 */
+		swap_tendency += zone_page_state(zone, NR_ACTIVE) /
+			(zone_page_state(zone, NR_INACTIVE) + 1)
+			* (vm_swappiness + 1) / 100
+			* mapped_ratio / 100;
+
+		/*
 		 * Now use this metric to decide whether to start moving mapped
 		 * memory onto the inactive list.
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
