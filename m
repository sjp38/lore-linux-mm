Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 58234900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 17:32:08 -0400 (EDT)
Message-ID: <4DCDA347.9080207@cray.com>
Date: Fri, 13 May 2011 16:31:51 -0500
From: Andrew Barry <abarry@cray.com>
MIME-Version: 1.0
Subject: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

I believe I found a problem in __alloc_pages_slowpath, which allows a process to
get stuck endlessly looping, even when lots of memory is available.

Running an I/O and memory intensive stress-test I see a 0-order page allocation
with __GFP_IO and __GFP_WAIT, running on a system with very little free memory.
Right about the same time that the stress-test gets killed by the OOM-killer,
the utility trying to allocate memory gets stuck in __alloc_pages_slowpath even
though most of the systems memory was freed by the oom-kill of the stress-test.

The utility ends up looping from the rebalance label down through the
wait_iff_congested continiously. Because order=0, __alloc_pages_direct_compact
skips the call to get_page_from_freelist. Because all of the reclaimable memory
on the system has already been reclaimed, __alloc_pages_direct_reclaim skips the
call to get_page_from_freelist. Since there is no __GFP_FS flag, the block with
__alloc_pages_may_oom is skipped. The loop hits the wait_iff_congested, then
jumps back to rebalance without ever trying to get_page_from_freelist. This loop
repeats infinitely.

Is there a reason that this loop is set up this way for 0 order allocations? I
applied the below patch, and the problem corrects itself. Does anyone have any
thoughts on the patch, or on a better way to address this situation?

The test case is pretty pathological. Running a mix of I/O stress-tests that do
a lot of fork() and consume all of the system memory, I can pretty reliably hit
this on 600 nodes, in about 12 hours. 32GB/node.

Thanks
Andrew Barry

---
 mm/page_alloc.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9f8a97b..c719664 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2158,7 +2158,10 @@ rebalance:
        if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
                /* Wait for some write requests to complete then retry */
                wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
-               goto rebalance;
+               if (did_some_progress)
+                       goto rebalance;
+               else
+                       goto restart;
        } else {
                /*
                 * High-order allocations do not necessarily loop after

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
