Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4756B0008
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 03:13:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e15-v6so910349pfi.5
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 00:13:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s11-v6sor914133pgi.138.2018.08.08.00.13.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 00:13:16 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] memcg, oom: emit oom report when there is no eligible task
Date: Wed,  8 Aug 2018 09:13:01 +0200
Message-Id: <20180808071301.12478-3-mhocko@kernel.org>
In-Reply-To: <20180808071301.12478-1-mhocko@kernel.org>
References: <20180808064414.GA27972@dhcp22.suse.cz>
 <20180808071301.12478-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Johannes had doubts that the current WARN in the memcg oom path
when there is no eligible task is not all that useful because it doesn't
really give any useful insight into the memcg state. My original
intention was to make this lightweight but it is true that seeing
a stack trace will likely be not sufficient when somebody gets back to
us and report this warning.

Therefore replace the current warning by the full oom report which will
give us not only the back trace of the offending path but also the full
memcg state - memory counters and existing tasks.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/oom.h |  2 ++
 mm/memcontrol.c     | 24 +++++++++++++-----------
 mm/oom_kill.c       |  8 ++++----
 3 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index a16a155a0d19..7424f9673cd1 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -133,6 +133,8 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
 
 extern int oom_evaluate_task(struct task_struct *task, void *arg);
 
+extern void dump_oom_header(struct oom_control *oc, struct task_struct *victim);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c80e5b6a8e9f..3d7c90e6c235 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1390,6 +1390,19 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	mutex_lock(&oom_lock);
 	ret = out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
+
+	/*
+	 * under rare race the current task might have been selected while
+	 * reaching mem_cgroup_out_of_memory and there is no other oom victim
+	 * left. There is still no reason to warn because this task will
+	 * die and release its bypassed charge eventually.
+	 */
+	if (tsk_is_oom_victim(current))
+		return ret;
+
+	pr_warn("Memory cgroup charge failed because of no reclaimable memory! "
+		"This looks like a misconfiguration or a kernel bug.");
+	dump_oom_header(&oc, NULL);
 	return ret;
 }
 
@@ -1706,17 +1719,6 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 	if (mem_cgroup_out_of_memory(memcg, mask, order))
 		return OOM_SUCCESS;
 	
-	/*
-	 * under rare race the current task might have been selected while
-	 * reaching mem_cgroup_out_of_memory and there is no other oom victim
-	 * left. There is still no reason to warn because this task will
-	 * die and release its bypassed charge eventually.
-	 */
-	if (tsk_is_oom_victim(current))
-		return OOM_SUCCESS;
-
-	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
-		"This looks like a misconfiguration or a kernel bug.");
 	return OOM_FAILED;
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 104ef4a01a55..8918640fcb85 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -428,7 +428,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 	rcu_read_unlock();
 }
 
-static void dump_header(struct oom_control *oc, struct task_struct *p)
+void dump_oom_header(struct oom_control *oc, struct task_struct *p)
 {
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask, oc->order,
@@ -945,7 +945,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	task_unlock(p);
 
 	if (__ratelimit(&oom_rs))
-		dump_header(oc, p);
+		dump_oom_header(oc, p);
 
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
@@ -1039,7 +1039,7 @@ static void check_panic_on_oom(struct oom_control *oc)
 	/* Do not panic for oom kills triggered by sysrq */
 	if (is_sysrq_oom(oc))
 		return;
-	dump_header(oc, NULL);
+	dump_oom_header(oc, NULL);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
@@ -1129,7 +1129,7 @@ bool out_of_memory(struct oom_control *oc)
 	select_bad_process(oc);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
 	if (!oc->chosen_task && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
-		dump_header(oc, NULL);
+		dump_oom_header(oc, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
 	if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM)
-- 
2.18.0
