Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA5D9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 08:04:54 -0400 (EDT)
Received: by labpt2 with SMTP id pt2so14176533lab.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 05:04:53 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id i5si11803863lam.8.2015.08.03.05.04.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 05:04:52 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 3/3] mm: workingset: make shadow node shrinker memcg aware
Date: Mon, 3 Aug 2015 15:04:23 +0300
Message-ID: <fe642d828516b94f631ca464f543acae80de4f85.1438599199.git.vdavydov@parallels.com>
In-Reply-To: <cover.1438599199.git.vdavydov@parallels.com>
References: <cover.1438599199.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Shadow nodes are accounted to memcg/kmem, so they must be reclaimed per
memcg, otherwise they can eat all memory available to a memcg.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/list_lru.h | 1 -
 mm/workingset.c          | 9 +++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index 2a6b9947aaa3..132d86f031ff 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -58,7 +58,6 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 		    struct lock_class_key *key);
 
 #define list_lru_init(lru)		__list_lru_init((lru), false, NULL)
-#define list_lru_init_key(lru, key)	__list_lru_init((lru), false, (key))
 #define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
 
 int memcg_update_all_list_lrus(int num_memcgs);
diff --git a/mm/workingset.c b/mm/workingset.c
index 76bf9b6ee88c..424fdf5d0a80 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -286,6 +286,10 @@ static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 	local_irq_enable();
 
 	pages = node_present_pages(sc->nid);
+#ifdef CONFIG_MEMCG
+	if (sc->memcg)
+		pages = min(pages, sc->memcg->memory.limit);
+#endif
 	/*
 	 * Active cache pages are limited to 50% of memory, and shadow
 	 * entries that represent a refault distance bigger than that
@@ -394,7 +398,7 @@ static struct shrinker workingset_shadow_shrinker = {
 	.count_objects = count_shadow_nodes,
 	.scan_objects = scan_shadow_nodes,
 	.seeks = DEFAULT_SEEKS,
-	.flags = SHRINKER_NUMA_AWARE,
+	.flags = SHRINKER_NUMA_AWARE | SHRINKER_MEMCG_AWARE,
 };
 
 /*
@@ -407,7 +411,8 @@ static int __init workingset_init(void)
 {
 	int ret;
 
-	ret = list_lru_init_key(&workingset_shadow_nodes, &shadow_nodes_key);
+	ret = __list_lru_init(&workingset_shadow_nodes, true,
+			      &shadow_nodes_key);
 	if (ret)
 		goto err;
 	ret = register_shrinker(&workingset_shadow_shrinker);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
