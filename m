Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 123356B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 04:02:24 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d123so245970135pfd.0
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 01:02:24 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id s17si10707231pgo.49.2017.01.31.01.02.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 01:02:23 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to vmpressure
Date: Tue, 31 Jan 2017 14:32:08 +0530
Message-Id: <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
In-Reply-To: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

During global reclaim, the nr_reclaimed passed to vmpressure
includes the pages reclaimed from slab. But the corresponding
scanned slab pages is not passed. This can cause total reclaimed
pages to be greater than scanned, causing an unsigned underflow
in vmpressure resulting in a critical event being sent to root
cgroup. So do not consider reclaimed slab pages for vmpressure
calculation. The reclaimed pages from slab can be excluded because
the freeing of a page by slab shrinking depends on each slab's
object population, making the cost model (i.e. scan:free) different
from that of LRU. Also, not every shrinker accounts the pages it
reclaims. This is a regression introduced by commit 6b4f7799c6a5
("mm: vmscan: invoke slab shrinkers from shrink_zone()").

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/vmscan.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 947ab6f..8969f8e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2594,16 +2594,23 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 				    sc->nr_scanned - nr_scanned,
 				    node_lru_pages);
 
+		/*
+		 * Record the subtree's reclaim efficiency. The reclaimed
+		 * pages from slab is excluded here because the corresponding
+		 * scanned pages is not accounted. Moreover, freeing a page
+		 * by slab shrinking depends on each slab's object population,
+		 * making the cost model (i.e. scan:free) different from that
+		 * of LRU.
+		 */
+		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
+			   sc->nr_scanned - nr_scanned,
+			   sc->nr_reclaimed - nr_reclaimed);
+
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
 		}
 
-		/* Record the subtree's reclaim efficiency */
-		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
-			   sc->nr_scanned - nr_scanned,
-			   sc->nr_reclaimed - nr_reclaimed);
-
 		if (sc->nr_reclaimed - nr_reclaimed)
 			reclaimable = true;
 
-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
