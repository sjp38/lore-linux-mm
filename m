Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 67D456B0257
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:39:41 -0500 (EST)
Received: by pacwq6 with SMTP id wq6so46390068pac.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 03:39:41 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id 69si19844184pfc.197.2015.12.10.03.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 03:39:40 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 3/7] mm: memcontrol: replace mem_cgroup_lruvec_online with mem_cgroup_online
Date: Thu, 10 Dec 2015 14:39:16 +0300
Message-ID: <a024e9b23584aa7bd3a74b7c7a69abd9f920812c.1449742561.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1449742560.git.vdavydov@virtuozzo.com>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

mem_cgroup_lruvec_online() takes lruvec, but it only needs memcg. Since
get_scan_count(), which is the only user of this function, now possesses
pointer to memcg, let's pass memcg directly to mem_cgroup_online()
instead of picking it out of lruvec and rename the function accordingly.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/memcontrol.h | 27 ++++++++++-----------------
 mm/vmscan.c                |  2 +-
 2 files changed, 11 insertions(+), 18 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 993c9a26b637..c9a14e1eab62 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -361,6 +361,13 @@ static inline bool mem_cgroup_disabled(void)
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
 }
 
+static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
+{
+	if (mem_cgroup_disabled())
+		return true;
+	return !!(memcg->css.flags & CSS_ONLINE);
+}
+
 /*
  * For memory reclaim.
  */
@@ -369,20 +376,6 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 		int nr_pages);
 
-static inline bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
-{
-	struct mem_cgroup_per_zone *mz;
-	struct mem_cgroup *memcg;
-
-	if (mem_cgroup_disabled())
-		return true;
-
-	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
-	memcg = mz->memcg;
-
-	return !!(memcg->css.flags & CSS_ONLINE);
-}
-
 static inline
 unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
@@ -706,13 +699,13 @@ static inline bool mem_cgroup_disabled(void)
 	return true;
 }
 
-static inline bool
-mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
+static inline bool mem_cgroup_online(struct mem_cgroup *memcg)
 {
 	return true;
 }
 
-static inline bool mem_cgroup_lruvec_online(struct lruvec *lruvec)
+static inline bool
+mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 {
 	return true;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index acc6bff84e26..b220e6cda25d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1988,7 +1988,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	if (current_is_kswapd()) {
 		if (!zone_reclaimable(zone))
 			force_scan = true;
-		if (!mem_cgroup_lruvec_online(lruvec))
+		if (!mem_cgroup_online(memcg))
 			force_scan = true;
 	}
 	if (!global_reclaim(sc))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
