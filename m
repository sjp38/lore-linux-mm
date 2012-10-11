Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 8020A6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 04:57:46 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: oom: fix totalpages calculation for memory.swappiness==0
Date: Thu, 11 Oct 2012 10:57:39 +0200
Message-Id: <1349945859-1350-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20121011085038.GA29295@dhcp22.suse.cz>
References: <20121011085038.GA29295@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

oom_badness takes totalpages argument which says how many pages are
available and it uses it as a base for the score calculation. The value
is calculated by mem_cgroup_get_limit which considers both limit and
total_swap_pages (resp. memsw portion of it).

This is usually correct but since fe35004f (mm: avoid swapping out
with swappiness==0) we do not swap when swappiness is 0 which means
that we cannot really use up all the totalpages pages. This in turn
confuses oom score calculation if the memcg limit is much smaller than
the available swap because the used memory (capped by the limit) is
negligible comparing to totalpages so the resulting score is too small
if adj!=0 (typically task with CAP_SYS_ADMIN or non zero oom_score_adj).
A wrong process might be selected as result.

The same issue exists for the global oom killer as well but it is not
that problematic as the amount of the RAM is usually much bigger than
the swap space.

The problem can be worked around by checking mem_cgroup_swappiness==0
and not considering swap at all in such a case.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: David Rientjes <rientjes@google.com>
Cc: stable [3.5+]
---
 mm/memcontrol.c |   21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7acf43b..93a7e36 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1452,17 +1452,26 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
 static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 {
 	u64 limit;
-	u64 memsw;
 
 	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-	limit += total_swap_pages << PAGE_SHIFT;
 
-	memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
 	/*
-	 * If memsw is finite and limits the amount of swap space available
-	 * to this memcg, return that limit.
+	 * Do not consider swap space if we cannot swap due to swappiness
 	 */
-	return min(limit, memsw);
+	if (mem_cgroup_swappiness(memcg)) {
+		u64 memsw;
+
+		limit += total_swap_pages << PAGE_SHIFT;
+		memsw = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
+
+		/*
+		 * If memsw is finite and limits the amount of swap space
+		 * available to this memcg, return that limit.
+		 */
+		limit = min(limit, memsw);
+	}
+
+	return limit;
 }
 
 void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
