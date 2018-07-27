Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98F476B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 05:19:34 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f91-v6so3178546plb.10
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 02:19:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1-v6sor977361pgf.110.2018.07.27.02.19.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 02:19:33 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH] mm: terminate the reclaim early when direct reclaiming
Date: Fri, 27 Jul 2018 17:19:25 +0800
Message-Id: <1532683165-19416-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org

This patch try to let the direct reclaim finish earlier than it used
to be. The problem comes from We observing that the direct reclaim
took a long time to finish when memcg is enabled. By debugging, we
find that the reason is the softlimit is too low to meet the loop
end criteria. So we add two barriers to judge if it has reclaimed
enough memory as same criteria as it is in shrink_lruvec:
1. for each memcg softlimit reclaim.
2. before starting the global reclaim in shrink_zone.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
---
 include/linux/memcontrol.h |  3 ++-
 mm/memcontrol.c            |  3 +++
 mm/vmscan.c                | 24 ++++++++++++++++++++++++
 3 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb11..cdf5de6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -325,7 +325,8 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 void mem_cgroup_uncharge_list(struct list_head *page_list);
 
 void mem_cgroup_migrate(struct page *oldpage, struct page *newpage);
-
+bool direct_reclaim_reach_sflimit(pg_data_t *pgdat, unsigned long nr_reclaimed,
+			unsigned long nr_scanned, gfp_t gfp_mask, int order);
 static struct mem_cgroup_per_node *
 mem_cgroup_nodeinfo(struct mem_cgroup *memcg, int nid)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8c0280b..4e38223 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2577,6 +2577,9 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 			(next_mz == NULL ||
 			loop > MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS))
 			break;
+		if (direct_reclaim_reach_sflimit(pgdat, nr_reclaimed,
+					*total_scanned, gfp_mask, order))
+			break;
 	} while (!nr_reclaimed);
 	if (next_mz)
 		css_put(&next_mz->memcg->css);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 03822f8..77fcda4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2518,12 +2518,36 @@ static bool pgdat_memcg_congested(pg_data_t *pgdat, struct mem_cgroup *memcg)
 		(memcg && memcg_congested(pgdat, memcg));
 }
 
+bool direct_reclaim_reach_sflimit(pg_data_t *pgdat, unsigned long nr_reclaimed,
+		unsigned long nr_scanned, gfp_t gfp_mask,
+		int order)
+{
+	struct scan_control sc = {
+		.gfp_mask = gfp_mask,
+		.order = order,
+		.priority = DEF_PRIORITY,
+		.nr_reclaimed = nr_reclaimed,
+		.nr_scanned = nr_scanned,
+	};
+	if (!current_is_kswapd() && !should_continue_reclaim(pgdat,
+				sc.nr_reclaimed, sc.nr_scanned, &sc))
+		return true;
+	return false;
+}
+EXPORT_SYMBOL(direct_reclaim_reach_sflimit);
+
 static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 {
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
 
+	if (!current_is_kswapd() && !should_continue_reclaim(pgdat,
+		sc->nr_reclaimed, sc->nr_scanned, sc)) {
+
+		return !!sc->nr_reclaimed;
+	}
+
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
 		struct mem_cgroup_reclaim_cookie reclaim = {
-- 
1.9.1
