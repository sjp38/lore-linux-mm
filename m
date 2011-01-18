Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 428758D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 00:09:13 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p0I59BeX021426
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:09:11 -0800
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by wpaz33.hot.corp.google.com with ESMTP id p0I596wB010605
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:09:09 -0800
Received: by pwj8 with SMTP id 8so1315143pwj.0
        for <linux-mm@kvack.org>; Mon, 17 Jan 2011 21:09:09 -0800 (PST)
Date: Mon, 17 Jan 2011 21:09:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: fix deferred congestion timeout if preferred zone is
 not allowed
Message-ID: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before 0e093d99763e (writeback: do not sleep on the congestion queue if
there are no congested BDIs or if significant congestion is not being
encountered in the current zone), preferred_zone was only used for
statistics and to determine the zoneidx from which to allocate from given
the type requested.

wait_iff_congested(), though, uses preferred_zone to determine if the
congestion wait should be deferred because its dirty pages are backed by
a congested bdi.  This incorrectly defers the timeout and busy loops in
the page allocator with various cond_resched() calls if preferred_zone is
not allowed in the current context, usually consuming 100% of a cpu.

This patch resets preferred_zone to an allowed zone in the slowpath if
the allocation context is constrained by current's cpuset.  It also
ensures preferred_zone is from the set of allowed nodes when called from
within direct reclaim; allocations are always constrainted by cpusets
since the context is always blockable.

Both of these uses of cpuset_current_mems_allowed are protected by
get_mems_allowed().
---
 mm/page_alloc.c |   12 ++++++++++++
 mm/vmscan.c     |    3 ++-
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2034,6 +2034,18 @@ restart:
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+	/*
+	 * If preferred_zone cannot be allocated from in this context, find the
+	 * first allowable zone instead.
+	 */
+	if ((alloc_flags & ALLOC_CPUSET) &&
+	    !cpuset_zone_allowed_softwall(preferred_zone, gfp_mask)) {
+		first_zones_zonelist(zonelist, high_zoneidx,
+				&cpuset_current_mems_allowed, &preferred_zone);
+		if (unlikely(!preferred_zone))
+			goto nopage;
+	}
+
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2084,7 +2084,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 			struct zone *preferred_zone;
 
 			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
-							NULL, &preferred_zone);
+						&cpuset_current_mems_allowed,
+						&preferred_zone);
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/10);
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
