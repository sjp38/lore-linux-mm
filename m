Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 47E866B0072
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 08:02:18 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so1255372wgg.35
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 05:02:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ly2si17239319wjb.126.2014.12.19.05.02.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 05:02:15 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/2] mm, vmscan: wake up all pfmemalloc-throttled processes at once
Date: Fri, 19 Dec 2014 14:01:56 +0100
Message-Id: <1418994116-23665-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
References: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org

Kswapd in balance_pgdate() currently uses wake_up() on processes waiting in
throttle_direct_reclaim(), which only wakes up a single process. This might
leave processes waiting for longer than necessary, until the check is reached
in the next loop iteration. Processes might also be left waiting if zone was
fully balanced in single iteration. Note that the comment in balance_pgdat()
also says "Wake them", so waking up a single process does not seem intentional.

Thus, replace wake_up() with wake_up_all().

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 162c3f8..60b999c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3178,7 +3178,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		 */
 		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
 				pfmemalloc_watermark_ok(pgdat))
-			wake_up(&pgdat->pfmemalloc_wait);
+			wake_up_all(&pgdat->pfmemalloc_wait);
 
 		/*
 		 * Fragmentation may mean that the system cannot be rebalanced
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
