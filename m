Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 054A58E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 15:05:54 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id s3so4227303iob.15
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 12:05:54 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n143sor19887434itn.34.2019.01.08.12.05.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 12:05:52 -0800 (PST)
Date: Tue,  8 Jan 2019 12:05:38 -0800
Message-Id: <20190108200538.80371-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH v2] memcg: schedule high reclaim for remote memcgs on high_work
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

If a memcg is over high limit, memory reclaim is scheduled to run on
return-to-userland. However it is assumed that the memcg is the current
process's memcg. With remote memcg charging for kmem or swapping in a
page charged to remote memcg, current process can trigger reclaim on
remote memcg. So, schduling reclaim on return-to-userland for remote
memcgs will ignore the high reclaim altogether. So, record the memcg
needing high reclaim and trigger high reclaim for that memcg on
return-to-userland. However if the memcg is already recorded for high
reclaim and the recorded memcg is not the descendant of the the memcg
needing high reclaim, punt the high reclaim to the work queue.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- Punt high reclaim of a memcg to work queue only if the recorded memcg
  is not its descendant.

 include/linux/sched.h |  3 +++
 kernel/fork.c         |  1 +
 mm/memcontrol.c       | 18 +++++++++++++-----
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index a95d1a9574e7..9a46243e6585 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1168,6 +1168,9 @@ struct task_struct {
 
 	/* Used by memcontrol for targeted memcg charge: */
 	struct mem_cgroup		*active_memcg;
+
+	/* Used by memcontrol for high relcaim: */
+	struct mem_cgroup		*memcg_high_reclaim;
 #endif
 
 #ifdef CONFIG_BLK_CGROUP
diff --git a/kernel/fork.c b/kernel/fork.c
index 68e0a0c0b2d3..98c9963ac8d5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -916,6 +916,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
 
 #ifdef CONFIG_MEMCG
 	tsk->active_memcg = NULL;
+	tsk->memcg_high_reclaim = NULL;
 #endif
 	return tsk;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e9db1160ccbc..81fada6b4a32 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2145,7 +2145,8 @@ void mem_cgroup_handle_over_high(void)
 	if (likely(!nr_pages))
 		return;
 
-	memcg = get_mem_cgroup_from_mm(current->mm);
+	memcg = current->memcg_high_reclaim;
+	current->memcg_high_reclaim = NULL;
 	reclaim_high(memcg, nr_pages, GFP_KERNEL);
 	css_put(&memcg->css);
 	current->memcg_nr_pages_over_high = 0;
@@ -2301,10 +2302,10 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
@@ -2312,6 +2313,13 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
