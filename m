Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EDBBD6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 09:03:20 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id c126so184346699ith.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:03:20 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50095.outbound.protection.outlook.com. [40.107.5.95])
        by mx.google.com with ESMTPS id e136si27714269ioe.224.2016.08.01.06.03.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 06:03:20 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: vmscan: fix memcg-aware shrinkers not called on global reclaim
Date: Mon, 1 Aug 2016 16:03:10 +0300
Message-ID: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We must call shrink_slab() for each memory cgroup on both global and
memcg reclaim in shrink_node_memcg(). Commit d71df22b55099 accidentally
changed that so that now shrink_slab() is only called with memcg != NULL
on memcg reclaim. As a result, memcg-aware shrinkers (including
dentry/inode) are never invoked on global reclaim. Fix that.

Fixes: d71df22b55099 ("mm, vmscan: begin reclaiming pages on a per-node basis")
Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmscan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 650d26832569..374d95d04178 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2561,7 +2561,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (!global_reclaim(sc))
+			if (memcg)
 				shrink_slab(sc->gfp_mask, pgdat->node_id,
 					    memcg, sc->nr_scanned - scanned,
 					    lru_pages);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
