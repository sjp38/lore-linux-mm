Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA8C26B6805
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 03:01:47 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id k4so13455293ioc.10
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 00:01:47 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id 82si4383673jap.36.2018.12.03.00.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 00:01:46 -0800 (PST)
From: Xunlei Pang <xlpang@linux.alibaba.com>
Subject: [PATCH 3/3] mm/memcg: Avoid reclaiming below hard protection
Date: Mon,  3 Dec 2018 16:01:19 +0800
Message-Id: <20181203080119.18989-3-xlpang@linux.alibaba.com>
In-Reply-To: <20181203080119.18989-1-xlpang@linux.alibaba.com>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

When memcgs get reclaimed after its usage exceeds min, some
usages below the min may also be reclaimed in the current
implementation, the amount is considerably large during kswapd
reclaim according to my ftrace results.

This patch calculates the part over hard protection limit,
and allows only this part of usages to be reclaimed.

Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
---
 include/linux/memcontrol.h |  7 +++++--
 mm/memcontrol.c            |  9 +++++++--
 mm/vmscan.c                | 17 +++++++++++++++--
 3 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7ab2120155a4..637ef975792f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -334,7 +334,8 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
-						struct mem_cgroup *memcg);
+						struct mem_cgroup *memcg,
+						unsigned long *min_excess);
 
 int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 			  gfp_t gfp_mask, struct mem_cgroup **memcgp,
@@ -818,7 +819,9 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 }
 
 static inline enum mem_cgroup_protection mem_cgroup_protected(
-	struct mem_cgroup *root, struct mem_cgroup *memcg)
+					struct mem_cgroup *root,
+					struct mem_cgroup *memcg,
+					unsigned long *min_excess)
 {
 	return MEMCG_PROT_NONE;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e1469b80cb7..ca96f68e07a0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5694,6 +5694,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
  * mem_cgroup_protected - check if memory consumption is in the normal range
  * @root: the top ancestor of the sub-tree being checked
  * @memcg: the memory cgroup to check
+ * @min_excess: store the number of pages exceeding hard protection
  *
  * WARNING: This function is not stateless! It can only be used as part
  *          of a top-down tree iteration, not for isolated queries.
@@ -5761,7 +5762,8 @@ struct cgroup_subsys memory_cgrp_subsys = {
  * as memory.low is a best-effort mechanism.
  */
 enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
-						struct mem_cgroup *memcg)
+						struct mem_cgroup *memcg,
+						unsigned long *min_excess)
 {
 	struct mem_cgroup *parent;
 	unsigned long emin, parent_emin;
@@ -5827,8 +5829,11 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
 		return MEMCG_PROT_MIN;
 	else if (usage <= elow)
 		return MEMCG_PROT_LOW;
-	else
+	else {
+		if (emin)
+			*min_excess = usage - emin;
 		return MEMCG_PROT_NONE;
+	}
 }
 
 /**
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3d412eb91f73..e4fa7a2a63d0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -66,6 +66,9 @@ struct scan_control {
 	/* How many pages shrink_list() should reclaim */
 	unsigned long nr_to_reclaim;
 
+	/* How many pages hard protection allows */
+	unsigned long min_excess;
+
 	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
 	 * are scanned.
@@ -2503,10 +2506,14 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 	unsigned long nr_to_scan;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
-	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	unsigned long nr_to_reclaim;
 	struct blk_plug plug;
 	bool scan_adjusted;
 
+	nr_to_reclaim = sc->nr_to_reclaim;
+	if (sc->min_excess)
+		nr_to_reclaim = min(nr_to_reclaim, sc->min_excess);
+
 	get_scan_count(lruvec, memcg, sc, nr, lru_pages);
 
 	/* Record the original scan target for proportional adjustments later */
@@ -2544,6 +2551,10 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 
 		cond_resched();
 
+		/* Abort proportional reclaim when hard protection applies */
+		if (sc->min_excess && nr_reclaimed >= sc->min_excess)
+			break;
+
 		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
 			continue;
 
@@ -2725,8 +2736,9 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			unsigned long lru_pages;
 			unsigned long reclaimed;
 			unsigned long scanned;
+			unsigned long excess = 0;
 
-			switch (mem_cgroup_protected(root, memcg)) {
+			switch (mem_cgroup_protected(root, memcg, &excess)) {
 			case MEMCG_PROT_MIN:
 				/*
 				 * Hard protection.
@@ -2752,6 +2764,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 			reclaimed = sc->nr_reclaimed;
 			scanned = sc->nr_scanned;
+			sc->min_excess = excess;
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-- 
2.13.5 (Apple Git-94)
