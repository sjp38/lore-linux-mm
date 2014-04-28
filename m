Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
	by kanga.kvack.org (Postfix) with ESMTP id 38AE16B0036
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 08:27:05 -0400 (EDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so4810565eei.33
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:27:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g45si22898154eev.250.2014.04.28.05.27.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 05:27:03 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Date: Mon, 28 Apr 2014 14:26:42 +0200
Message-Id: <1398688005-26207-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

This patch introduces low limit reclaim. The low_limit acts as a reclaim
protection because groups which are under their low_limit are considered
ineligible for reclaim. While hardlimit protects from using more memory
than allowed lowlimit protects from getting bellow memory assigned to
the group due to external memory pressure.

More precisely a group is considered eligible for the reclaim under a
specific hierarchy represented by its root only if the group is above
its low limit and the same applies to all parents up the hierarchy to
the root. Nevertheless the limit still might be ignored if all groups
under the reclaimed hierarchy are under their low limits. This will
prevent from OOM rather than protecting the memory.

Consider the following hierarchy with memory pressure coming from the
group A (hard limit reclaim - l-low_limit_in_bytes, u-usage_in_bytes,
h-limit_in_bytes):
		root_mem_cgroup
			.
		  _____/
		 /
		A (l = 80 u=90 h=90)
	       /
	      / \_________
	     /            \
	    B (l=0 u=50)   C (l=50 u=40)
	                    \
			     D (l=0 u=30)

A and B are reclaimable but C and D are not (D is protected by C).

The low_limit is 0 by default so every group is eligible. This patch
doesn't provide a way to set the limit yet although the core
infrastructure is there already.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h  |  9 +++++++++
 include/linux/res_counter.h | 27 +++++++++++++++++++++++++++
 mm/memcontrol.c             | 23 +++++++++++++++++++++++
 mm/vmscan.c                 | 34 +++++++++++++++++++++++++++++++++-
 4 files changed, 92 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1fa23244fe37..6c59056f4bc6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -92,6 +92,9 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 bool task_in_mem_cgroup(struct task_struct *task,
 			const struct mem_cgroup *memcg);
 
+extern bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root);
+
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
@@ -288,6 +291,12 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 	return &zone->lruvec;
 }
 
+static inline bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root)
+{
+	return true;
+}
+
 static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	return NULL;
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 56b7bc32db4f..408724eeec71 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -40,6 +40,11 @@ struct res_counter {
 	 */
 	unsigned long long soft_limit;
 	/*
+	 * the limit under which the usage cannot be pushed
+	 * due to external pressure.
+	 */
+	unsigned long long low_limit;
+	/*
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
@@ -175,6 +180,28 @@ res_counter_soft_limit_excess(struct res_counter *cnt)
 	return excess;
 }
 
+/**
+ * Get the difference between the usage and the low limit
+ * @cnt: The counter
+ *
+ * Returns 0 if usage is less than or equal to low limit
+ * The difference between usage and low limit, otherwise.
+ */
+static inline unsigned long long
+res_counter_low_limit_excess(struct res_counter *cnt)
+{
+	unsigned long long excess;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage <= cnt->low_limit)
+		excess = 0;
+	else
+		excess = cnt->usage - cnt->low_limit;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return excess;
+}
+
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 19d620b3d69c..40e517630138 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2808,6 +2808,29 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
 	return mem_cgroup_from_id(id);
 }
 
+/**
+ * mem_cgroup_reclaim_eligible - checks whether given memcg is eligible for the
+ * reclaim
+ * @memcg: target memcg for the reclaim
+ * @root: root of the reclaim hierarchy (null for the global reclaim)
+ *
+ * The given group is reclaimable if it is above its low limit and the same
+ * applies for all parents up the hierarchy until root (including).
+ */
+bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root)
+{
+	do {
+		if (!res_counter_low_limit_excess(&memcg->res))
+			return false;
+		if (memcg == root)
+			break;
+
+	} while ((memcg = parent_mem_cgroup(memcg)));
+
+	return true;
+}
+
 struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 {
 	struct mem_cgroup *memcg = NULL;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c1cd99a5074b..0f428158254e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2215,9 +2215,11 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	}
 }
 
-static void shrink_zone(struct zone *zone, struct scan_control *sc)
+static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
+		bool follow_low_limit)
 {
 	unsigned long nr_reclaimed, nr_scanned;
+	unsigned nr_scanned_groups = 0;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2234,7 +2236,23 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		do {
 			struct lruvec *lruvec;
 
+			/*
+			 * Memcg might be under its low limit so we have to
+			 * skip it during the first reclaim round
+			 */
+			if (follow_low_limit &&
+					!mem_cgroup_reclaim_eligible(memcg, root)) {
+				/*
+				 * It would be more optimal to skip the memcg
+				 * subtree now but we do not have a memcg iter
+				 * helper for that. Anyone?
+				 */
+				memcg = mem_cgroup_iter(root, memcg, &reclaim);
+				continue;
+			}
+
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+			nr_scanned_groups++;
 
 			shrink_lruvec(lruvec, sc);
 
@@ -2262,6 +2280,20 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 
 	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
+
+	return nr_scanned_groups;
+}
+
+static void shrink_zone(struct zone *zone, struct scan_control *sc)
+{
+	if (!__shrink_zone(zone, sc, true)) {
+		/*
+		 * First round of reclaim didn't find anything to reclaim
+		 * because of low limit protection so try again and ignore
+		 * the low limit this time.
+		 */
+		__shrink_zone(zone, sc, false);
+	}
 }
 
 /* Returns true if compaction should go ahead for a high-order request */
-- 
2.0.0.rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
