Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA9CE6B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g10so9371449wrg.5
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:17 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id d13si3972036wra.226.2017.02.28.13.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:16 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/9] mm: fix check for reclaimable pages in PF_MEMALLOC reclaim throttling
Date: Tue, 28 Feb 2017 16:40:00 -0500
Message-Id: <20170228214007.5621-3-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-1-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

PF_MEMALLOC direct reclaimers get throttled on a node when the sum of
all free pages in each zone fall below half the min watermark. During
the summation, we want to exclude zones that don't have reclaimables.
Checking the same pgdat over and over again doesn't make sense.

Fixes: 599d0c954f91 ("mm, vmscan: move LRU lists to node")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 407b27831ff7..f006140f58c6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2838,8 +2838,10 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
-		if (!managed_zone(zone) ||
-		    pgdat_reclaimable_pages(pgdat) == 0)
+		if (!managed_zone(zone))
+			continue;
+
+		if (!zone_reclaimable_pages(zone))
 			continue;
 
 		pfmemalloc_reserve += min_wmark_pages(zone);
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
