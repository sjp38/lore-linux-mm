Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6F67782F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 11:17:34 -0400 (EDT)
Received: by wmll128 with SMTP id l128so26752319wml.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:17:34 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id e8si2622400wjx.133.2015.10.29.08.17.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 08:17:33 -0700 (PDT)
Received: by wicll6 with SMTP id ll6so230933207wic.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:17:33 -0700 (PDT)
From: mhocko@kernel.org
Subject: [RFC 2/3] mm: throttle on IO only when there are too many dirty and writeback pages
Date: Thu, 29 Oct 2015 16:17:14 +0100
Message-Id: <1446131835-3263-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

wait_iff_congested has been used to throttle allocator before it retried
another round of direct reclaim to allow the writeback to make some
progress and prevent reclaim from looping over dirty/writeback pages
without making any progress. We used to do congestion_wait before
0e093d99763e ("writeback: do not sleep on the congestion queue if
there are no congested BDIs or if significant congestion is not being
encountered in the current zone") but that led to undesirable stalls
and sleeping for the full timeout even when the BDI wasn't congested.
Hence wait_iff_congested was used instead. But it seems that even
wait_iff_congested doesn't work as expected. We might have a small file
LRU list with all pages dirty/writeback and yet the bdi is not congested
so this is just a cond_resched in the end and can end up triggering pre
mature OOM.

This patch replaces the unconditional wait_iff_congested by
congestion_wait which is executed only if we _know_ that the last round
of direct reclaim didn't make any progress and dirty+writeback pages are
more than a half of the reclaimable pages on the zone which might be
usable for our target allocation. This shouldn't reintroduce stalls
fixed by 0e093d99763e because congestion_wait is called only when we
are getting hopeless when sleeping is a better choice than OOM with many
pages under IO.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9c0abb75ad53..0518ca6a9776 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3191,8 +3191,23 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 */
 		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
 				ac->high_zoneidx, alloc_flags, target)) {
-			/* Wait for some write requests to complete then retry */
-			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
+			unsigned long writeback = zone_page_state(zone, NR_WRITEBACK),
+				      dirty = zone_page_state(zone, NR_FILE_DIRTY);
+
+			if (did_some_progress)
+				goto retry;
+
+			/*
+			 * If we didn't make any progress and have a lot of
+			 * dirty + writeback pages then we should wait for
+			 * an IO to complete to slow down the reclaim and
+			 * prevent from pre mature OOM
+			 */
+			if (2*(writeback + dirty) > reclaimable)
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+			else
+				cond_resched();
+
 			goto retry;
 		}
 	}
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
