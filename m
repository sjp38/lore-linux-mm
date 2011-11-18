Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B59696B0095
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:58:53 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/5] mm: Do not stall in synchronous compaction for THP allocations
Date: Fri, 18 Nov 2011 16:58:42 +0000
Message-Id: <1321635524-8586-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1321635524-8586-1-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>

Occasionally during large file copies to slow storage, there are still
reports of user-visible stalls when THP is enabled. Reports on this
have been intermittent and not reliable to reproduce locally but;

Andy Isaacson reported a problem copying to VFAT on SD Card
	https://lkml.org/lkml/2011/11/7/2

	In this case, it was stuck in munmap for betwen 20 and 60
	seconds in compaction. It is also possible that khugepaged
	was holding mmap_sem on this process if CONFIG_NUMA was set.

Johannes Weiner reported stalls on USB
	https://lkml.org/lkml/2011/7/25/378

	In this case, there is no stack trace but it looks like the
	same problem. The USB stick may have been using NTFS as a
	filesystem based on other work done related to writing back
	to USB around the same time.

Internally in SUSE, I received a bug report related to stalls in firefox
	when using Java and Flash heavily while copying from NFS
	to VFAT on USB. It has not been confirmed to be the same problem
	but if it looks like a duck and quacks like a duck.....

In the past, commit [11bc82d6: mm: compaction: Use async migration for
__GFP_NO_KSWAPD and enforce no writeback] forced that sync compaction
would never be used for THP allocations. This was reverted in commit
[c6a140bf: mm/compaction: reverse the change that forbade sync
migraton with __GFP_NO_KSWAPD] on the grounds that it was uncertain
it was beneficial.

While user-visible stalls do not happen for me when writing to USB,
I setup a test running postmark while short-lived processes created
anonymous mapping. The objective was to exercise the paths that
allocate transparent huge pages. I then logged when processes were
stalled for more than 1 second, recorded a stack strace and did some
analysis to aggregate unique "stall events" which revealed

Time stalled in this event:    47369 ms
Event count:                      20
usemem               sleep_on_page          3690 ms
usemem               sleep_on_page          2148 ms
usemem               sleep_on_page          1534 ms
usemem               sleep_on_page          1518 ms
usemem               sleep_on_page          1225 ms
usemem               sleep_on_page          2205 ms
usemem               sleep_on_page          2399 ms
usemem               sleep_on_page          2398 ms
usemem               sleep_on_page          3760 ms
usemem               sleep_on_page          1861 ms
usemem               sleep_on_page          2948 ms
usemem               sleep_on_page          1515 ms
usemem               sleep_on_page          1386 ms
usemem               sleep_on_page          1882 ms
usemem               sleep_on_page          1850 ms
usemem               sleep_on_page          3715 ms
usemem               sleep_on_page          3716 ms
usemem               sleep_on_page          4846 ms
usemem               sleep_on_page          1306 ms
usemem               sleep_on_page          1467 ms
[<ffffffff810ef30c>] wait_on_page_bit+0x6c/0x80
[<ffffffff8113de9f>] unmap_and_move+0x1bf/0x360
[<ffffffff8113e0e2>] migrate_pages+0xa2/0x1b0
[<ffffffff81134273>] compact_zone+0x1f3/0x2f0
[<ffffffff811345d8>] compact_zone_order+0xa8/0xf0
[<ffffffff811346ff>] try_to_compact_pages+0xdf/0x110
[<ffffffff810f773a>] __alloc_pages_direct_compact+0xda/0x1a0
[<ffffffff810f7d5d>] __alloc_pages_slowpath+0x55d/0x7a0
[<ffffffff810f8151>] __alloc_pages_nodemask+0x1b1/0x1c0
[<ffffffff811331db>] alloc_pages_vma+0x9b/0x160
[<ffffffff81142bb0>] do_huge_pmd_anonymous_page+0x160/0x270
[<ffffffff814410a7>] do_page_fault+0x207/0x4c0
[<ffffffff8143dde5>] page_fault+0x25/0x30

The stall times are approximate at best but the estimates represent 25%
of the worst stalls and even if the estimates are off by a factor of
10, it's severe.

This patch once again prevents sync migration for transparent
hugepage allocations as it is preferable to fail a THP allocation
than stall.

It was suggested that __GFP_NORETRY be used instead of __GFP_NO_KSWAPD
to look less like a special case. This would prevent THP allocation
using sync compaction but it would have other side-effects. There are
existing users of __GFP_NORETRY that are doing high-order allocations
and while they can handle allocation failure, it seems reasonable that
they continue to use sync compaction unless there is a deliberate
reason to change that. To help clarify this for the future, this
patch updates the comment for __GFP_NO_KSWAPD.

If accepted, this is a -stable candidate.

Reported-by: Andy Isaacson <adi@hexapodia.org>
Reported-and-tested-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h |   11 +++++++++++
 mm/page_alloc.c     |    9 ++++++++-
 2 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 3a76faf..ef1b1af 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -83,7 +83,18 @@ struct vm_area_struct;
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
 #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
+/*
+ * __GFP_NO_KSWAPD indicates that the VM should favour failing the allocation
+ * over excessive disruption of the system. Currently this means
+ * 1. Do not wake kswapd (hence the flag name)
+ * 2. Do not use stall in synchronous compaction for high-order allocations
+ *    as this may cause the caller to stall writing out pages
+ *
+ * This flag it primarily intended for use with transparent hugepage support.
+ * If the flag is used outside the VM, linux-mm should be cc'd for review.
+ */
 #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
+
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..7a5c5b1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2168,7 +2168,14 @@ rebalance:
 					sync_migration);
 	if (page)
 		goto got_pg;
-	sync_migration = true;
+
+	/*
+	 * Do not use sync migration if __GFP_NO_KSWAPD is used to indicate
+	 * the system should not be heavily disrupted. In practice, this is
+	 * to avoid THP callers being stalled in writeback during migration
+	 * as it's preferable for the the allocations to fail than to stall
+	 */
+	sync_migration = !(gfp_mask & __GFP_NO_KSWAPD);
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
