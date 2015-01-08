Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BC86C6B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 09:51:20 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so11612555pde.1
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 06:51:20 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e9si9087749pas.9.2015.01.08.06.51.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 06:51:19 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] vmscan: force scan offline memory cgroups
Date: Thu, 8 Jan 2015 17:51:09 +0300
Message-ID: <1420728669-16889-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit b2052564e66d ("mm: memcontrol: continue cache reclaim from
offlined groups") pages charged to a memory cgroup are not reparented
when the cgroup is removed. Instead, they are supposed to be reclaimed
in a regular way, along with pages accounted to online memory cgroups.

However, an lruvec of an offline memory cgroup will sooner or later get
so small that it will be scanned only at low scan priorities (see
get_scan_count()). Therefore, if there are enough reclaimable pages in
big lruvecs, pages accounted to offline memory cgroups will never be
scanned at all, wasting memory.

Fix this by unconditionally forcing scanning dead lruvecs from kswapd.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    6 ++++++
 mm/memcontrol.c            |   14 ++++++++++++++
 mm/vmscan.c                |    3 ++-
 3 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 76b4084b8d08..764d8801f3d1 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -102,6 +102,7 @@ void mem_cgroup_iter_break(struct mem_cgroup *, struct mem_cgroup *);
  * For memory reclaim.
  */
 int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec);
+bool mem_cgroup_need_force_scan(struct lruvec *lruvec);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
 void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
@@ -266,6 +267,11 @@ mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 	return 1;
 }
 
+bool mem_cgroup_need_force_scan(struct lruvec *lruvec)
+{
+	return false;
+}
+
 static inline unsigned long
 mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list lru)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index bfa1a849d113..a146ea8060dc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1367,6 +1367,20 @@ int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 	return inactive * inactive_ratio < active;
 }
 
+bool mem_cgroup_need_force_scan(struct lruvec *lruvec)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct mem_cgroup *memcg;
+
+	if (mem_cgroup_disabled())
+		return false;
+
+	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
+	memcg = mz->memcg;
+
+	return !(memcg->css.flags & CSS_ONLINE);
+}
+
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e29f411b38ac..2de646271f89 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1935,7 +1935,8 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 * latencies, so it's better to scan a minimum amount there as
 	 * well.
 	 */
-	if (current_is_kswapd() && !zone_reclaimable(zone))
+	if (current_is_kswapd() &&
+	    (!zone_reclaimable(zone) || mem_cgroup_need_force_scan(lruvec)))
 		force_scan = true;
 	if (!global_reclaim(sc))
 		force_scan = true;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
