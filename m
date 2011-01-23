Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5AC6B00E7
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 17:30:28 -0500 (EST)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p0NMUPFx019658
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 14:30:25 -0800
Received: from ywc21 (ywc21.prod.google.com [10.192.3.21])
	by hpaq3.eem.corp.google.com with ESMTP id p0NMULGT003432
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 14:30:24 -0800
Received: by ywc21 with SMTP id 21so730539ywc.9
        for <linux-mm@kvack.org>; Sun, 23 Jan 2011 14:30:21 -0800 (PST)
Date: Sun, 23 Jan 2011 14:30:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm: fix deferred congestion timeout if preferred zone is
 not allowed
In-Reply-To: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1101231429300.371@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Before 0e093d99763e (writeback: do not sleep on the congestion queue if
there are no congested BDIs or if significant congestion is not being
encountered in the current zone), preferred_zone was only used for
NUMA statistics, to determine the zoneidx from which to allocate from given
the type requested, and whether to utilize memory compaction.

wait_iff_congested(), though, uses preferred_zone to determine if the
congestion wait should be deferred because its dirty pages are backed by
a congested bdi.  This incorrectly defers the timeout and busy loops in
the page allocator with various cond_resched() calls if preferred_zone is
not allowed in the current context, usually consuming 100% of a cpu.

This patch ensures preferred_zone is an allowed zone in the fastpath
depending on whether current is constrained by its cpuset or nodes in
its mempolicy (when the nodemask passed is non-NULL).  This is correct
since the fastpath allocation always passes ALLOC_CPUSET when trying
to allocate memory.  In the slowpath, this patch resets preferred_zone
to the first zone of the allowed type when the allocation is not
constrained by current's cpuset, i.e. it does not pass ALLOC_CPUSET.

This patch also ensures preferred_zone is from the set of allowed nodes
when called from within direct reclaim since allocations are always
constrained by cpusets in this context (it is blockable).

Both of these uses of cpuset_current_mems_allowed are protected by
get_mems_allowed().

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |   12 +++++++++++-
 mm/vmscan.c     |    3 ++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2034,6 +2034,14 @@ restart:
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+	/*
+	 * Find the true preferred zone if the allocation is unconstrained by
+	 * cpusets.
+	 */
+	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask)
+		first_zones_zonelist(zonelist, high_zoneidx, NULL,
+					&preferred_zone);
+
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
@@ -2192,7 +2200,9 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	get_mems_allowed();
 	/* The preferred zone is used for statistics later */
-	first_zones_zonelist(zonelist, high_zoneidx, nodemask, &preferred_zone);
+	first_zones_zonelist(zonelist, high_zoneidx,
+				nodemask ? : &cpuset_current_mems_allowed,
+				&preferred_zone);
 	if (!preferred_zone) {
 		put_mems_allowed();
 		return NULL;
diff --git a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2083,7 +2083,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
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
