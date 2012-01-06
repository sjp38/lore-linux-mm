Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id A45906B005C
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 15:57:59 -0500 (EST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [RESEND, PATCH 6/6] memcg: cleanup memcg_check_events()
Date: Fri,  6 Jan 2012 22:57:52 +0200
Message-Id: <1325883472-5614-6-git-send-email-kirill@shutemov.name>
In-Reply-To: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
References: <1325883472-5614-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   42 ++++++++++++++++++++++++------------------
 1 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2eddcb5..0a13afa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -108,11 +108,12 @@ enum mem_cgroup_events_index {
  * than using jiffies etc. to handle periodic memcg event.
  */
 enum mem_cgroup_events_target {
-	MEM_CGROUP_TARGET_THRESH,
-	MEM_CGROUP_TARGET_SOFTLIMIT,
-	MEM_CGROUP_TARGET_NUMAINFO,
-	MEM_CGROUP_NTARGETS,
+	MEM_CGROUP_TARGET_THRESH	= BIT(1),
+	MEM_CGROUP_TARGET_SOFTLIMIT	= BIT(2),
+	MEM_CGROUP_TARGET_NUMAINFO	= BIT(3),
 };
+#define MEM_CGROUP_NTARGETS 3
+
 #define THRESHOLDS_EVENTS_TARGET 128
 #define SOFTLIMIT_EVENTS_TARGET 1024
 #define NUMAINFO_EVENTS_TARGET	1024
@@ -734,7 +735,7 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 	return total;
 }
 
-static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
+static int mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 				       enum mem_cgroup_events_target target)
 {
 	unsigned long val, next;
@@ -757,9 +758,9 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
 			break;
 		}
 		__this_cpu_write(memcg->stat->targets[target], next);
-		return true;
+		return target;
 	}
-	return false;
+	return 0;
 }
 
 /*
@@ -768,29 +769,34 @@ static bool mem_cgroup_event_ratelimit(struct mem_cgroup *memcg,
  */
 static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 {
+	int flags;
+
 	preempt_disable();
-	/* threshold event is triggered in finer grain than soft limit */
-	if (unlikely(mem_cgroup_event_ratelimit(memcg,
-						MEM_CGROUP_TARGET_THRESH))) {
-		bool do_softlimit, do_numainfo;
+	flags = mem_cgroup_event_ratelimit(memcg, MEM_CGROUP_TARGET_THRESH);
 
-		do_softlimit = mem_cgroup_event_ratelimit(memcg,
+	/*
+	 * Threshold event is triggered in finer grain than soft limit
+	 * and numainfo
+	 */
+	if (unlikely(flags)) {
+		flags |= mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_SOFTLIMIT);
 #if MAX_NUMNODES > 1
-		do_numainfo = mem_cgroup_event_ratelimit(memcg,
+		flags |= mem_cgroup_event_ratelimit(memcg,
 						MEM_CGROUP_TARGET_NUMAINFO);
 #endif
-		preempt_enable();
+	}
+	preempt_enable();
 
+	if (unlikely(flags)) {
 		mem_cgroup_threshold(memcg);
-		if (unlikely(do_softlimit))
+		if (unlikely(flags & MEM_CGROUP_TARGET_SOFTLIMIT))
 			mem_cgroup_update_tree(memcg, page);
 #if MAX_NUMNODES > 1
-		if (unlikely(do_numainfo))
+		if (unlikely(flags & MEM_CGROUP_TARGET_NUMAINFO))
 			atomic_inc(&memcg->numainfo_events);
 #endif
-	} else
-		preempt_enable();
+	}
 }
 
 struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
-- 
1.7.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
