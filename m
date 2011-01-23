Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2D16B00E7
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 17:58:49 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p0NMwjnE029689
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 14:58:46 -0800
Received: from iwn8 (iwn8.prod.google.com [10.241.68.72])
	by wpaz1.hot.corp.google.com with ESMTP id p0NMwisL000991
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 23 Jan 2011 14:58:44 -0800
Received: by iwn8 with SMTP id 8so3648657iwn.34
        for <linux-mm@kvack.org>; Sun, 23 Jan 2011 14:58:43 -0800 (PST)
Date: Sun, 23 Jan 2011 14:58:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm: clear pages_scanned only if draining a pcp adds pages
 to the buddy allocator
Message-ID: <alpine.DEB.2.00.1101231457130.966@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

0e093d99763e (writeback: do not sleep on the congestion queue if there
are no congested BDIs or if significant congestion is not being
encountered in the current zone) uncovered a livelock in the page
allocator that resulted in tasks infinitely looping trying to find memory
and kswapd running at 100% cpu.

The issue occurs because drain_all_pages() is called immediately
following direct reclaim when no memory is freed and try_to_free_pages()
returns non-zero because all zones in the zonelist do not have their
all_unreclaimable flag set.

When draining the per-cpu pagesets back to the buddy allocator for each
zone, the zone->pages_scanned counter is cleared to avoid erroneously
setting zone->all_unreclaimable later.  The problem is that no pages may
actually be drained and, thus, the unreclaimable logic never fails direct
reclaim so the oom killer may be invoked.

This apparently only manifested after wait_iff_congested() was introduced
and the zone was full of anonymous memory that would not congest the
backing store.  The page allocator would infinitely loop if there were no
other tasks waiting to be scheduled and clear zone->pages_scanned because
of drain_all_pages() as the result of this change before kswapd could
scan enough pages to trigger the reclaim logic.  Additionally, with every
loop of the page allocator and in the reclaim path, kswapd would be
kicked and would end up running at 100% cpu.  In this scenario, current
and kswapd are all running continuously with kswapd incrementing
zone->pages_scanned and current clearing it.

The problem is even more pronounced when current swaps some of its memory
to swap cache and the reclaimable logic then considers all active
anonymous memory in the all_unreclaimable logic, which requires a much
higher zone->pages_scanned value for try_to_free_pages() to return zero
that is never attainable in this scenario.

Before wait_iff_congested(), the page allocator would incur an
unconditional timeout and allow kswapd to elevate zone->pages_scanned to
a level that the oom killer would be called the next time it loops.

The fix is to only attempt to drain pcp pages if there is actually a
quantity to be drained.  The unconditional clearing of
zone->pages_scanned in free_pcppages_bulk() need not be changed since
other callers already ensure that draining will occur.  This patch
ensures that free_pcppages_bulk() will actually free memory before
calling into it from drain_all_pages() so zone->pages_scanned is only
cleared if appropriate.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1088,8 +1088,10 @@ static void drain_pages(unsigned int cpu)
 		pset = per_cpu_ptr(zone->pageset, cpu);
 
 		pcp = &pset->pcp;
-		free_pcppages_bulk(zone, pcp->count, pcp);
-		pcp->count = 0;
+		if (pcp->count) {
+			free_pcppages_bulk(zone, pcp->count, pcp);
+			pcp->count = 0;
+		}
 		local_irq_restore(flags);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
