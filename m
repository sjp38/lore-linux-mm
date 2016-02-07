Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 627478309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 12:27:52 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e127so1771127pfe.3
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 09:27:52 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id q62si40181452pfi.239.2016.02.07.09.27.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 09:27:51 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 2/5] mm: vmscan: pass root_mem_cgroup instead of NULL to memcg aware shrinker
Date: Sun, 7 Feb 2016 20:27:32 +0300
Message-ID: <37826932f643b15c6eeeda4006e4e37a9f3fd8a6.1454864628.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1454864628.git.vdavydov@virtuozzo.com>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It's just convenient to implement a memcg aware shrinker when you know
that shrink_control->memcg != NULL unless memcg_kmem_enabled() returns
false.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmscan.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 18b3767136f4..bae8f32ad9cb 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -382,9 +382,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  *
  * @memcg specifies the memory cgroup to target. If it is not NULL,
  * only shrinkers with SHRINKER_MEMCG_AWARE set will be called to scan
- * objects from the memory cgroup specified. Otherwise all shrinkers
- * are called, and memcg aware shrinkers are supposed to scan the
- * global list then.
+ * objects from the memory cgroup specified. Otherwise, only unaware
+ * shrinkers are called.
  *
  * @nr_scanned and @nr_eligible form a ratio that indicate how much of
  * the available objects should be scanned.  Page reclaim for example
@@ -404,7 +403,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
 
-	if (memcg && !memcg_kmem_online(memcg))
+	if (memcg && (!memcg_kmem_enabled() || !mem_cgroup_online(memcg)))
 		return 0;
 
 	if (nr_scanned == 0)
@@ -428,7 +427,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
-		if (memcg && !(shrinker->flags & SHRINKER_MEMCG_AWARE))
+		/*
+		 * If kernel memory accounting is disabled, we ignore
+		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
+		 * passing NULL for memcg.
+		 */
+		if (memcg_kmem_enabled() &&
+		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
 			continue;
 
 		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
