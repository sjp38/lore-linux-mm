Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B80D06B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:23:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id o64so27058545pfb.2
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:23:23 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 9si3838757pfk.17.2017.02.23.01.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 01:23:22 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH v6] mm: vmscan: do not pass reclaimed slab to vmpressure
Date: Thu, 23 Feb 2017 14:52:50 +0530
Message-Id: <1487841770-26120-1-git-send-email-vinmenon@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, minchan@kernel.org, shashim@codeaurora.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

During global reclaim, the nr_reclaimed passed to vmpressure includes the
pages reclaimed from slab.  But the corresponding scanned slab pages is
not passed.  There is an impact to the vmpressure values because of this.
While moving from kernel version 3.18 to 4.4, a difference is seen in the
vmpressure values for the same workload resulting in a different behaviour
of the vmpressure consumer.  One such case is of a vmpressure based
lowmemorykiller.  It is observed that the vmpressure events are received
late and less in number resulting in tasks not being killed at the right
time. In this use case, The number of critical vmpressure events received
is around 50% less on 4.4 than 3.18. The following numbers show the impact
on reclaim activity due to the change in behaviour of lowmemorykiller on a
4GB device.  The test launches a number of apps in sequence and repeats it
multiple times. The difference in reclaim behaviour is because of lesser
number of kills and kills happening late, resulting in more swapping and
page cache reclaim.

                      v4.4           v3.18
pgpgin                163016456      145617236
pgpgout               4366220        4188004
workingset_refault    29857868       26781854
workingset_activate   6293946        5634625
pswpin                1327601        1133912
pswpout               3593842        3229602
pgalloc_dma           99520618       94402970
pgalloc_normal        104046854      98124798
pgfree                203772640      192600737
pgmajfault            2126962        1851836
pgsteal_kswapd_dma    19732899       18039462
pgsteal_kswapd_normal 19945336       17977706
pgsteal_direct_dma    206757         131376
pgsteal_direct_normal 236783         138247
pageoutrun            116622         108370
allocstall            7220           4684
compact_stall         931            856

The lowmemorykiller example above is just for indicating the difference in
vmpressure events between 4.4 and 3.18.

Do not consider reclaimed slab pages for vmpressure calculation. The
reclaimed pages from slab can be excluded because the freeing of a page by
slab shrinking depends on each slab's object population, making the cost
model (i.e. scan:free) different from that of LRU.  Also, not every
shrinker accounts the pages it reclaims. Ideally the pages reclaimed from
slab should be passed to vmpressure, otherwise higher vmpressure levels can
be triggered even when there is a reclaim progress.  But accounting only
the reclaimed slab pages without the scanned, and adding something which
does not fit into the cost model just adds noise to the vmpressure values.

Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
Link: http://lkml.kernel.org/r/1486641577-11685-2-git-send-email-vinmenon@codeaurora.org
Acked-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Shiraz Hashim <shashim@codeaurora.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
v6: Modifying the changelog as per Michal's suggestion

 mm/vmscan.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 70aa739..26c3b40 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2603,16 +2603,23 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
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
