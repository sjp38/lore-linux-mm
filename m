Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 654906B04B5
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:07:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h126so11280249wmf.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:07:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6si16580587wra.72.2017.07.27.09.07.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 09:07:13 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 4/6] mm, kswapd: wake up kcompactd when kswapd had too many failures
Date: Thu, 27 Jul 2017 18:06:59 +0200
Message-Id: <20170727160701.9245-5-vbabka@suse.cz>
In-Reply-To: <20170727160701.9245-1-vbabka@suse.cz>
References: <20170727160701.9245-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

This patch deals with a corner case found when testing kcompactd with a very
simple testcase that first fragments memory (by creating a large shmem file and
then punching hole in every even page) and then uses artificial order-9
GFP_NOWAIT allocations in a loop. This is freshly after virtme-run boot in KVM
and no other activity.

What happens is that after few kswapd runs, there are no more reclaimable
pages, and high-order pages can only be created by compaction. Because kswapd
can't reclaim anything, pgdat->kswapd_failures increases up to
MAX_RECLAIM_RETRIES and kswapd is no longer woken up. Thus kcompactd is also
not woken up. After this patch, we will try to wake up kcompactd immediately
instead of kswapd.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmscan.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a3f914c88dea..18ad0cd0c0f5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3578,9 +3578,15 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
 
-	/* Hopeless node, leave it to direct reclaim */
-	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
+	/*
+	 * Hopeless node, leave it to direct reclaim. For high-order
+	 * allocations, try to wake up kcompactd instead.
+	 */
+	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES) {
+		if (order)
+			wakeup_kcompactd(pgdat, order, classzone_idx);
 		return;
+	}
 
 	if (pgdat_balanced(pgdat, order, classzone_idx))
 		return;
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
