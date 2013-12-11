Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id DA92B6B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:16:42 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id o10so2961666eaj.4
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:16:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si19242912eeo.88.2013.12.11.06.16.41
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 06:16:42 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 1/4] memcg, mm: introduce lowlimit reclaim
Date: Wed, 11 Dec 2013 15:15:52 +0100
Message-Id: <1386771355-21805-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

This patch introduces low limit reclaim. The low_limit acts as a reclaim
protection because groups which are under their low_limit are considered
ineligible for reclaim. While hardlimit protects from using more memory
than allowed lowlimit protects from getting bellow memory assigned to
the group due to external memory pressure.

More precisely a group is considered eligible for the reclaim under a
specific hierarchy represented by its root only if the group is above
its low limit and the same applies to all parents up the hierarchy to
the root.

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
 include/linux/memcontrol.h  |  8 ++++++++
 include/linux/res_counter.h | 27 +++++++++++++++++++++++++++
 mm/memcontrol.c             | 23 +++++++++++++++++++++++
 mm/vmscan.c                 | 14 ++++++++++++++
 4 files changed, 72 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b3e7a667e03c..6841e591718d 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -92,6 +92,8 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 bool task_in_mem_cgroup(struct task_struct *task,
 			const struct mem_cgroup *memcg);
 
+extern bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
+		struct mem_cgroup *root);
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
@@ -289,6 +291,12 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
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
index 201a69749659..c7e7dfeca847 100644
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
@@ -179,6 +184,28 @@ res_counter_soft_limit_excess(struct res_counter *cnt)
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
index d1fded477ef6..a1cfee4491bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2851,6 +2851,29 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
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
index eea668d9cff6..1c9ce5f97872 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2186,6 +2186,20 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
 		do {
 			struct lruvec *lruvec;
 
+			/*
+			 * Memcg might be under its low limit so we have to
+			 * skip it.
+			 */
+			if (!mem_cgroup_reclaim_eligible(memcg, root)) {
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
 
 			shrink_lruvec(lruvec, sc);
-- 
1.8.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
