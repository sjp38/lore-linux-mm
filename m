Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AECB8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:44:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so6707828pgv.23
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:44:44 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l30sor51200176plg.17.2019.01.10.09.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 09:44:43 -0800 (PST)
Date: Thu, 10 Jan 2019 09:44:32 -0800
Message-Id: <20190110174432.82064-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH v3] memcg: schedule high reclaim for remote memcgs on high_work
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

If a memcg is over high limit, memory reclaim is scheduled to run on
return-to-userland.  However it is assumed that the memcg is the current
process's memcg.  With remote memcg charging for kmem or swapping in a
page charged to remote memcg, current process can trigger reclaim on
remote memcg.  So, schduling reclaim on return-to-userland for remote
memcgs will ignore the high reclaim altogether.  So, record the memcg
needing high reclaim and trigger high reclaim for that memcg on
return-to-userland.  However if the memcg is already recorded for high
reclaim and the recorded memcg is not the descendant of the the memcg
needing high reclaim, punt the high reclaim to the work queue.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v2:
- TIF_NOTIFY_RESUME can be set from places other than try_charge() in
  which case current->memcg_high_reclaim will be null. Correctly handle
  such scenarios.

Changelog since v1:
- Punt high reclaim of a memcg to work queue only if the recorded memcg
  is not its descendant.

 include/linux/sched.h |  3 +++
 kernel/fork.c         |  1 +
 mm/memcontrol.c       | 22 ++++++++++++++++------
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7d08562eeec7..5e6690042497 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1172,6 +1172,9 @@ struct task_struct {
 
 	/* Used by memcontrol for targeted memcg charge: */
 	struct mem_cgroup		*active_memcg;
+
+	/* Used by memcontrol for high relcaim: */
+	struct mem_cgroup		*memcg_high_reclaim;
 #endif
 
 #ifdef CONFIG_BLK_CGROUP
diff --git a/kernel/fork.c b/kernel/fork.c
index 1b0fde63d831..85da44137847 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -918,6 +918,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 
 #ifdef CONFIG_MEMCG
 	tsk->active_memcg = NULL;
+	tsk->memcg_high_reclaim = NULL;
 #endif
 	return tsk;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 953d4ba8a595..18f4aefbe0bf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2168,14 +2168,17 @@ static void high_work_func(struct work_struct *work)
 void mem_cgroup_handle_over_high(void)
 {
 	unsigned int nr_pages = current->memcg_nr_pages_over_high;
-	struct mem_cgroup *memcg;
+	struct mem_cgroup *memcg = current->memcg_high_reclaim;
 
 	if (likely(!nr_pages))
 		return;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	if (!memcg)
+		memcg = get_mem_cgroup_from_mm(current->mm);
+
 	reclaim_high(memcg, nr_pages, GFP_KERNEL);
 	css_put(&memcg->css);
+	current->memcg_high_reclaim = NULL;
 	current->memcg_nr_pages_over_high = 0;
 }
 
@@ -2329,10 +2332,10 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * If the hierarchy is above the normal consumption range, schedule
 	 * reclaim on returning to userland.  We can perform reclaim here
 	 * if __GFP_RECLAIM but let's always punt for simplicity and so that
-	 * GFP_KERNEL can consistently be used during reclaim.  @memcg is
-	 * not recorded as it most likely matches current's and won't
-	 * change in the meantime.  As high limit is checked again before
-	 * reclaim, the cost of mismatch is negligible.
+	 * GFP_KERNEL can consistently be used during reclaim. Record the memcg
+	 * for the return-to-userland high reclaim. If the memcg is already
+	 * recorded and the recorded memcg is not the descendant of the memcg
+	 * needing high reclaim, punt the high reclaim to the work queue.
 	 */
 	do {
 		if (page_counter_read(&memcg->memory) > memcg->high) {
@@ -2340,6 +2343,13 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 			if (in_interrupt()) {
 				schedule_work(&memcg->high_work);
 				break;
+			} else if (!current->memcg_high_reclaim) {
+				css_get(&memcg->css);
+				current->memcg_high_reclaim = memcg;
+			} else if (!mem_cgroup_is_descendant(
+					current->memcg_high_reclaim, memcg)) {
+				schedule_work(&memcg->high_work);
+				break;
 			}
 			current->memcg_nr_pages_over_high += batch;
 			set_notify_resume(current);
-- 
2.20.1.97.g81188d93c3-goog
