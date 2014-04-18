Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 21D586B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 19:01:56 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so1863824pbb.14
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 16:01:55 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id e10si17068243paw.5.2014.04.18.16.01.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 16:01:55 -0700 (PDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so1847335pde.11
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 16:01:54 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 2/2] mm/memcontrol.c: introduce helper mem_cgroup_zoneinfo_zone()
Date: Sat, 19 Apr 2014 07:01:43 +0800
Message-Id: <1397862103-31982-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

introduce helper mem_cgroup_zoneinfo_zone(). This will make
mem_cgroup_iter() code more compact.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/memcontrol.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e0ce15c..80d9e38 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -683,6 +683,15 @@ mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
 	return &memcg->nodeinfo[nid]->zoneinfo[zid];
 }
 
+static struct mem_cgroup_per_zone *
+mem_cgroup_zoneinfo_zone(struct mem_cgroup *memcg, struct zone *zone)
+{
+       int nid = zone_to_nid(zone);
+       int zid = zone_idx(zone);
+
+       return mem_cgroup_zoneinfo(memcg, nid, zid);
+}
+
 struct cgroup_subsys_state *mem_cgroup_css(struct mem_cgroup *memcg)
 {
 	return &memcg->css;
@@ -1232,11 +1241,9 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 	rcu_read_lock();
 	if (reclaim) {
-		int nid = zone_to_nid(reclaim->zone);
-		int zid = zone_idx(reclaim->zone);
 		struct mem_cgroup_per_zone *mz;
 
-		mz = mem_cgroup_zoneinfo(root, nid, zid);
+		mz = mem_cgroup_zoneinfo_zone(root, reclaim->zone);
 		iter = &mz->reclaim_iter[reclaim->priority];
 		if (prev && reclaim->generation != iter->generation) {
 			iter->last_visited = NULL;
@@ -1340,7 +1347,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
 		goto out;
 	}
 
-	mz = mem_cgroup_zoneinfo(memcg, zone_to_nid(zone), zone_idx(zone));
+	mz = mem_cgroup_zoneinfo_zone(memcg, zone);
 	lruvec = &mz->lruvec;
 out:
 	/*
-- 
1.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
