Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6636B05BC
	for <linux-mm@kvack.org>; Fri, 18 May 2018 04:44:23 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h15-v6so6338115qkh.3
        for <linux-mm@kvack.org>; Fri, 18 May 2018 01:44:23 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0107.outbound.protection.outlook.com. [104.47.0.107])
        by mx.google.com with ESMTPS id y2-v6si204155qkj.300.2018.05.18.01.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 May 2018 01:44:22 -0700 (PDT)
Subject: [PATCH v6 15/17] mm: Generalize shrink_slab() calls in shrink_node()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 18 May 2018 11:44:11 +0300
Message-ID: <152663305153.5308.14479673190611499656.stgit@localhost.localdomain>
In-Reply-To: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

From: Vladimir Davydov <vdavydov.dev@gmail.com>

The patch makes shrink_slab() be called for root_mem_cgroup
in the same way as it's called for the rest of cgroups.
This simplifies the logic and improves the readability.

Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>
ktkhai: Description written.
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |   13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2fbf3b476601..f1d23e2df988 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -661,9 +661,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
-		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
-			continue;
-
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 			sc.nid = 0;
 
@@ -693,6 +690,7 @@ void drop_slab_node(int nid)
 		struct mem_cgroup *memcg = NULL;
 
 		freed = 0;
+		memcg = mem_cgroup_iter(NULL, NULL, NULL);
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
@@ -2712,9 +2710,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (memcg)
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->priority);
+			shrink_slab(sc->gfp_mask, pgdat->node_id,
+				    memcg, sc->priority);
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2738,10 +2735,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
-				    sc->priority);
-
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
