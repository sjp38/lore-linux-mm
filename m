Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3AD6B0388
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 19:20:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c87so88428637pfl.6
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 16:20:27 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id p17si9931254pgc.399.2017.03.17.16.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 16:20:26 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id n190so49996028pga.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 16:20:26 -0700 (PDT)
From: Tim Murray <timmurray@google.com>
Subject: [RFC 1/1] mm, memcg: add prioritized reclaim
Date: Fri, 17 Mar 2017 16:16:36 -0700
Message-Id: <20170317231636.142311-2-timmurray@google.com>
In-Reply-To: <20170317231636.142311-1-timmurray@google.com>
References: <20170317231636.142311-1-timmurray@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, surenb@google.com, totte@google.com, kernel-team@android.com
Cc: Tim Murray <timmurray@google.com>

When a system is under memory pressure, it may be beneficial to prioritize
some memory cgroups to keep their pages resident ahead of other cgroups'
pages. Add a new interface to memory cgroups, memory.priority, that enables
kswapd and direct reclaim to scan more pages in lower-priority cgroups
before looking at higher-priority cgroups.

Signed-off-by: Tim Murray <timmurray@google.com>
---
 include/linux/memcontrol.h | 20 +++++++++++++++++++-
 mm/memcontrol.c            | 33 +++++++++++++++++++++++++++++++++
 mm/vmscan.c                |  3 ++-
 3 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5af377303880..0d0f95839a8d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -206,7 +206,9 @@ struct mem_cgroup {
 	bool		oom_lock;
 	int		under_oom;
 
-	int	swappiness;
+	int		swappiness;
+	int		priority;
+
 	/* OOM-Killer disable */
 	int		oom_kill_disable;
 
@@ -487,6 +489,16 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
 
 bool mem_cgroup_oom_synchronize(bool wait);
 
+static inline int mem_cgroup_priority(struct mem_cgroup *memcg)
+{
+	/* root ? */
+	if (mem_cgroup_disabled() || !memcg->css.parent)
+		return 0;
+
+	return memcg->priority;
+}
+
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
@@ -766,6 +778,12 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline int mem_cgroup_priority(struct mem_cgroup *memcg)
+{
+	return 0;
+}
+
 #endif /* CONFIG_MEMCG */
 
 #ifdef CONFIG_CGROUP_WRITEBACK
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2bd7541d7c11..7343ca106a36 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -81,6 +81,8 @@ struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #define MEM_CGROUP_RECLAIM_RETRIES	5
 
+#define MEM_CGROUP_PRIORITY_MAX	10
+
 /* Socket memory accounting disabled? */
 static bool cgroup_memory_nosocket;
 
@@ -241,6 +243,7 @@ enum res_type {
 	_OOM_TYPE,
 	_KMEM,
 	_TCP,
+	_PRIO,
 };
 
 #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
@@ -842,6 +845,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		 */
 		memcg = mem_cgroup_from_css(css);
 
+		if (reclaim && reclaim->priority &&
+		    (DEF_PRIORITY - memcg->priority) < reclaim->priority)
+			continue;
+
 		if (css == &root->css)
 			break;
 
@@ -2773,6 +2780,7 @@ enum {
 	RES_MAX_USAGE,
 	RES_FAILCNT,
 	RES_SOFT_LIMIT,
+	RES_PRIORITY,
 };
 
 static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
@@ -2783,6 +2791,7 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 
 	switch (MEMFILE_TYPE(cft->private)) {
 	case _MEM:
+	case _PRIO:
 		counter = &memcg->memory;
 		break;
 	case _MEMSWAP:
@@ -2813,6 +2822,8 @@ static u64 mem_cgroup_read_u64(struct cgroup_subsys_state *css,
 		return counter->failcnt;
 	case RES_SOFT_LIMIT:
 		return (u64)memcg->soft_limit * PAGE_SIZE;
+	case RES_PRIORITY:
+		return (u64)memcg->priority;
 	default:
 		BUG();
 	}
@@ -2966,6 +2977,22 @@ static int memcg_update_tcp_limit(struct mem_cgroup *memcg, unsigned long limit)
 	return ret;
 }
 
+static ssize_t mem_cgroup_update_prio(struct kernfs_open_file *of,
+				      char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	unsigned long long prio = -1;
+
+	buf = strstrip(buf);
+	prio = memparse(buf, NULL);
+
+	if (prio >= 0 && prio <= MEM_CGROUP_PRIORITY_MAX) {
+		memcg->priority = (int)prio;
+		return nbytes;
+	}
+	return -EINVAL;
+}
+
 /*
  * The user of this function is...
  * RES_LIMIT.
@@ -3940,6 +3967,12 @@ static struct cftype mem_cgroup_legacy_files[] = {
 		.read_u64 = mem_cgroup_read_u64,
 	},
 	{
+		.name = "priority",
+		.private = MEMFILE_PRIVATE(_PRIO, RES_PRIORITY),
+		.write = mem_cgroup_update_prio,
+		.read_u64 = mem_cgroup_read_u64,
+	},
+	{
 		.name = "stat",
 		.seq_show = memcg_stat_show,
 	},
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc8031ef994d..c47b21326ab0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2116,6 +2116,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			   unsigned long *lru_pages)
 {
 	int swappiness = mem_cgroup_swappiness(memcg);
+	int priority = mem_cgroup_priority(memcg);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
 	u64 denominator = 0;	/* gcc */
@@ -2287,7 +2288,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long scan;
 
 			size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
-			scan = size >> sc->priority;
+			scan = size >> (sc->priority + priority);
 
 			if (!scan && pass && force_scan)
 				scan = min(size, SWAP_CLUSTER_MAX);
-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
