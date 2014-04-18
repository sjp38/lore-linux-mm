Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id D6A936B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 18:59:51 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so1859439pbb.40
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 15:59:51 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id ic8si17051585pad.177.2014.04.18.15.59.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 15:59:50 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so1863022pab.18
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 15:59:50 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 1/2] mm/memcontrol.c: remove meaningless while loop in mem_cgroup_iter()
Date: Sat, 19 Apr 2014 06:58:55 +0800
Message-Id: <1397861935-31595-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

Currently, the iteration job in mem_cgroup_iter() all delegates
to __mem_cgroup_iter_next(), which will skip dead node.

Thus, the outer while loop in mem_cgroup_iter() is meaningless.
It could be proven by this:

1. memcg != NULL
    we are done, no loop needed.
2. memcg == NULL
   2.1 prev != NULL, a round-trip is done, break out, no loop.
   2.2 prev == NULL, this is impossible, since prev==NULL means
       the initial interation, it will returns memcg==root.

So, this patches remove this meaningless while loop.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/memcontrol.c | 49 ++++++++++++++++++++++---------------------------
 1 file changed, 22 insertions(+), 27 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 29501f0..e0ce15c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1212,6 +1212,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 {
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *last_visited = NULL;
+	struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
+	int uninitialized_var(seq);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1229,40 +1231,33 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	}
 
 	rcu_read_lock();
-	while (!memcg) {
-		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
-		int uninitialized_var(seq);
-
-		if (reclaim) {
-			int nid = zone_to_nid(reclaim->zone);
-			int zid = zone_idx(reclaim->zone);
-			struct mem_cgroup_per_zone *mz;
-
-			mz = mem_cgroup_zoneinfo(root, nid, zid);
-			iter = &mz->reclaim_iter[reclaim->priority];
-			if (prev && reclaim->generation != iter->generation) {
-				iter->last_visited = NULL;
-				goto out_unlock;
-			}
+	if (reclaim) {
+		int nid = zone_to_nid(reclaim->zone);
+		int zid = zone_idx(reclaim->zone);
+		struct mem_cgroup_per_zone *mz;
 
-			last_visited = mem_cgroup_iter_load(iter, root, &seq);
+		mz = mem_cgroup_zoneinfo(root, nid, zid);
+		iter = &mz->reclaim_iter[reclaim->priority];
+		if (prev && reclaim->generation != iter->generation) {
+			iter->last_visited = NULL;
+			goto out_unlock;
 		}
 
-		memcg = __mem_cgroup_iter_next(root, last_visited);
+		last_visited = mem_cgroup_iter_load(iter, root, &seq);
+	}
 
-		if (reclaim) {
-			mem_cgroup_iter_update(iter, last_visited, memcg, root,
-					seq);
+	memcg = __mem_cgroup_iter_next(root, last_visited);
 
-			if (!memcg)
-				iter->generation++;
-			else if (!prev && memcg)
-				reclaim->generation = iter->generation;
-		}
+	if (reclaim) {
+		mem_cgroup_iter_update(iter, last_visited, memcg, root,
+				seq);
 
-		if (prev && !memcg)
-			goto out_unlock;
+		if (!memcg)
+			iter->generation++;
+		else if (!prev && memcg)
+			reclaim->generation = iter->generation;
 	}
+
 out_unlock:
 	rcu_read_unlock();
 out_css_put:
-- 
1.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
