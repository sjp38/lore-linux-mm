Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 300946B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:47:34 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id x125so7613121pfb.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:47:34 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e12si10430263pap.197.2016.01.27.08.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 08:47:33 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] mm: vmscan: do not clear SHRINKER_NUMA_AWARE if nr_node_ids == 1
Date: Wed, 27 Jan 2016 19:47:22 +0300
Message-ID: <1453913242-26722-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently, on shrinker registration we clear SHRINKER_NUMA_AWARE if
there's the only NUMA node present. The comment states that this will
allow us to save some small loop time later. It used to be true when
this code was added (see commit 1d3d4437eae1b ("vmscan: per-node
deferred work")), but since commit 6b4f7799c6a57 ("mm: vmscan: invoke
slab shrinkers from shrink_zone()") it doesn't make any difference.
Anyway, running on non-NUMA machine shouldn't make a shrinker NUMA
unaware, so zap this hunk.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmscan.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 30e0cd7a0ceb..153fea2fc5e3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -228,14 +228,6 @@ int register_shrinker(struct shrinker *shrinker)
 {
 	size_t size = sizeof(*shrinker->nr_deferred);
 
-	/*
-	 * If we only have one possible node in the system anyway, save
-	 * ourselves the trouble and disable NUMA aware behavior. This way we
-	 * will save memory and some small loop time later.
-	 */
-	if (nr_node_ids == 1)
-		shrinker->flags &= ~SHRINKER_NUMA_AWARE;
-
 	if (shrinker->flags & SHRINKER_NUMA_AWARE)
 		size *= nr_node_ids;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
