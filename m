Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B006A6B000C
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:00:59 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r10-v6so1855465itc.2
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:00:59 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30119.outbound.protection.outlook.com. [40.107.3.119])
        by mx.google.com with ESMTPS id v14-v6si1199482jan.6.2018.08.02.04.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Aug 2018 04:00:58 -0700 (PDT)
Subject: [PATCH] mm: Move check for SHRINKER_NUMA_AWARE to do_shrink_slab()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Thu, 02 Aug 2018 14:00:52 +0300
Message-ID: <153320759911.18959.8842396230157677671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ktkhai@virtuozzo.com, vdavydov.dev@gmail.com, mhocko@suse.com, aryabinin@virtuozzo.com, ying.huang@intel.com, penguin-kernel@I-love.SAKURA.ne.jp, willy@infradead.org, shakeelb@google.com, jbacik@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In case of shrink_slab_memcg() we do not zero nid, when shrinker
is not numa-aware. This is not a real problem, since currently
all memcg-aware shrinkers are numa-aware too (we have two:
super_block shrinker and workingset shrinker), but something may
change in the future.

(Andrew, this may be merged to mm-iterate-only-over-charged-shrinkers-during-memcg-shrink_slab)

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/vmscan.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ea0a46166e8e..0d980e801b8a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -455,6 +455,9 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 					  : SHRINK_BATCH;
 	long scanned = 0, next_deferred;
 
+	if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
+		nid = 0;
+
 	freeable = shrinker->count_objects(shrinker, shrinkctl);
 	if (freeable == 0 || freeable == SHRINK_EMPTY)
 		return freeable;
@@ -680,9 +683,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
-		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
-			sc.nid = 0;
-
 		ret = do_shrink_slab(&sc, shrinker, priority);
 		if (ret == SHRINK_EMPTY)
 			ret = 0;
