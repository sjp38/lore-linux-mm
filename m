Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6AEF16B006E
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 03:56:58 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id p10so7498578wes.9
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 00:56:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d6si15239548wie.24.2015.01.05.00.56.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 00:56:56 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH V3 2/2] mm, vmscan: wake up all pfmemalloc-throttled processes at once
Date: Mon,  5 Jan 2015 09:56:43 +0100
Message-Id: <1420448203-30212-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1420448203-30212-1-git-send-email-vbabka@suse.cz>
References: <1420448203-30212-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Rik van Riel <riel@redhat.com>, stable@vger.kernel.org

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
index ab2505c..f73afa3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3175,7 +3175,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
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
