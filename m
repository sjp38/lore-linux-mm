Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D90FC6B025E
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:41:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f5so270853371pgi.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 03:41:00 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id x17si23167383pfk.215.2017.01.25.03.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 03:40:59 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
Date: Wed, 25 Jan 2017 17:08:38 +0530
Message-Id: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shiraz.hashim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

It is noticed that during a global reclaim the memory
reclaimed via shrinking the slabs can sometimes result
in reclaimed pages being greater than the scanned pages
in shrink_node. When this is passed to vmpressure, the
unsigned arithmetic results in the pressure value to be
huge, thus resulting in a critical event being sent to
root cgroup. Fix this by not passing the reclaimed slab
count to vmpressure, with the assumption that vmpressure
should show the actual pressure on LRU which is now
diluted by adding reclaimed slab without a corresponding
scanned value.

Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
---
 mm/vmscan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 947ab6f..37c4486 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2594,16 +2594,16 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 				    sc->nr_scanned - nr_scanned,
 				    node_lru_pages);
 
-		if (reclaim_state) {
-			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
-			reclaim_state->reclaimed_slab = 0;
-		}
-
 		/* Record the subtree's reclaim efficiency */
 		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
 			   sc->nr_scanned - nr_scanned,
 			   sc->nr_reclaimed - nr_reclaimed);
 
+		if (reclaim_state) {
+			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
+			reclaim_state->reclaimed_slab = 0;
+		}
+
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
