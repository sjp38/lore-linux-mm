Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 052C76B026D
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id f132so86947wmf.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h130si3845585wme.230.2017.11.30.14.15.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:51 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:48 -0800
From: akpm@linux-foundation.org
Subject: [patch 12/15] mm: vmscan: do not pass reclaimed slab to
 vmpressure
Message-ID: <5a208314.aMnBGe53fNh99xn8%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, vinmenon@codeaurora.org, anton.vorontsov@linaro.org, hannes@cmpxchg.org, mgorman@techsingularity.net, mhocko@suse.com, minchan@kernel.org, riel@redhat.com, shashim@codeaurora.org, vbabka@suse.cz, vdavydov.dev@gmail.com

From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: mm: vmscan: do not pass reclaimed slab to vmpressure

During global reclaim, the nr_reclaimed passed to vmpressure includes
the pages reclaimed from slab.  But the corresponding scanned slab
pages is not passed.  There is an impact to the vmpressure values
because of this.  While moving from kernel version 3.18 to 4.4, a
difference is seen in the vmpressure values for the same workload
resulting in a different behaviour of the vmpressure consumer.  One
such case is of a vmpressure based lowmemorykiller.  It is observed
that the vmpressure events are received late and less in number
resulting in tasks not being killed at the right time.  In this use
case, The number of critical vmpressure events received is around 50%
less on 4.4 than 3.18.  The following numbers show the impact on
reclaim activity due to the change in behaviour of lowmemorykiller on a
4GB device.  The test launches a number of apps in sequence and repeats
it multiple times.  The difference in reclaim behaviour is because of
lesser number of kills and kills happening late, resulting in more
swapping and page cache reclaim.

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

The lowmemorykiller example above is just for indicating the difference
in vmpressure events between 4.4 and 3.18.

Do not consider reclaimed slab pages for vmpressure calculation.  The
reclaimed pages from slab can be excluded because the freeing of a page
by slab shrinking depends on each slab's object population, making the
cost model (i.e.  scan:free) different from that of LRU.  Also, not
every shrinker accounts the pages it reclaims.  Ideally the pages
reclaimed from slab should be passed to vmpressure, otherwise higher
vmpressure levels can be triggered even when there is a reclaim
progress.  But accounting only the reclaimed slab pages without the
scanned, and adding something which does not fit into the cost model
just adds noise to the vmpressure values.

Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
Link: http://lkml.kernel.org/r/1486641577-11685-2-git-send-email-vinmenon@codeaurora.org
Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
Acked-by: Minchan Kim <minchan@kernel.org>
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

 mm/vmscan.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff -puN mm/vmscan.c~mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure mm/vmscan.c
--- a/mm/vmscan.c~mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure
+++ a/mm/vmscan.c
@@ -2567,16 +2567,23 @@ static bool shrink_node(pg_data_t *pgdat
 			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
 				    sc->priority);
 
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
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
