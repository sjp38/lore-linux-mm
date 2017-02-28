Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B157B6B038A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:19 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u48so9385042wrc.0
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:19 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z41si4001577wrb.48.2017.02.28.13.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:18 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/9] mm: remove seemingly spurious reclaimability check from laptop_mode gating
Date: Tue, 28 Feb 2017 16:40:01 -0500
Message-Id: <20170228214007.5621-4-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-1-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
allowed laptop_mode=1 to start writing not just when the priority
drops to DEF_PRIORITY - 2 but also when the node is unreclaimable.
That appears to be a spurious change in this patch as I doubt the
series was tested with laptop_mode, and neither is that particular
change mentioned in the changelog. Remove it, it's still recent.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f006140f58c6..911957b66622 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3288,7 +3288,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * If we're getting trouble reclaiming, start doing writepage
 		 * even in laptop mode.
 		 */
-		if (sc.priority < DEF_PRIORITY - 2 || !pgdat_reclaimable(pgdat))
+		if (sc.priority < DEF_PRIORITY - 2)
 			sc.may_writepage = 1;
 
 		/* Call soft limit reclaim before calling shrink_node. */
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
