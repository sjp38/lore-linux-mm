Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7D7906B0092
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 16:43:08 -0500 (EST)
Received: by obbta14 with SMTP id ta14so9759203obb.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 13:43:07 -0800 (PST)
Date: Wed, 7 Mar 2012 13:43:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: pass charge order to oom killer
Message-ID: <alpine.DEB.2.00.1203071341320.4520@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

The oom killer typically displays the allocation order at the time of oom
as a part of its diangostic messages (for global, cpuset, and mempolicy
ooms).

The memory controller may also pass the charge order to the oom killer so
it can emit the same information.  This is useful in determining how
large the memory allocation is that triggered the oom killer.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |    3 ++-
 mm/memcontrol.c            |    6 +++---
 mm/oom_kill.c              |    7 ++++---
 3 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -77,7 +77,8 @@ extern void mem_cgroup_uncharge_end(void);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 
-extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask);
+extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
+				     int order);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1791,7 +1791,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 /*
  * try to call OOM killer. returns false if we should exit memory-reclaim loop.
  */
-bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
+bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
 	struct oom_wait_info owait;
 	bool locked, need_to_kill;
@@ -1821,7 +1821,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 
 	if (need_to_kill) {
 		finish_wait(&memcg_oom_waitq, &owait.wait);
-		mem_cgroup_out_of_memory(memcg, mask);
+		mem_cgroup_out_of_memory(memcg, mask, order);
 	} else {
 		schedule();
 		finish_wait(&memcg_oom_waitq, &owait.wait);
@@ -2192,7 +2192,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (!oom_check)
 		return CHARGE_NOMEM;
 	/* check OOM */
-	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask))
+	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask, get_order(csize)))
 		return CHARGE_OOM_DIE;
 
 	return CHARGE_RETRY;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -561,7 +561,8 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask)
+void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
+			      int order)
 {
 	unsigned long limit;
 	unsigned int points = 0;
@@ -577,7 +578,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask)
 		return;
 	}
 
-	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, 0, NULL);
+	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
 	limit = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT;
 	read_lock(&tasklist_lock);
 retry:
@@ -585,7 +586,7 @@ retry:
 	if (!p || PTR_ERR(p) == -1UL)
 		goto out;
 
-	if (oom_kill_process(p, gfp_mask, 0, points, limit, memcg, NULL,
+	if (oom_kill_process(p, gfp_mask, order, points, limit, memcg, NULL,
 				"Memory cgroup out of memory"))
 		goto retry;
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
