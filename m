Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 685A96B0254
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 19:30:16 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so22416499pac.0
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:30:16 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id rb3si5984069pbc.134.2015.09.22.16.30.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 16:30:15 -0700 (PDT)
Received: by pacbt3 with SMTP id bt3so4094687pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:30:15 -0700 (PDT)
Date: Tue, 22 Sep 2015 16:30:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, oom: remove task_lock protecting comm printing
Message-ID: <alpine.DEB.2.10.1509221629440.7794@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

The oom killer takes task_lock() in a couple of places solely to protect
printing the task's comm.

A process's comm, including current's comm, may change due to
/proc/pid/comm or PR_SET_NAME.

The comm will always be NULL-terminated, so the worst race scenario would
only be during update.  We can tolerate a comm being printed that is in
the middle of an update to avoid taking the lock.

Other locations in the kernel have already dropped task_lock() when
printing comm, so this is consistent.

Suggested-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/cpuset.h |  4 ++--
 kernel/cpuset.c        | 14 +++++++-------
 mm/oom_kill.c          |  8 +-------
 3 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -93,7 +93,7 @@ extern int current_cpuset_is_being_rebound(void);
 
 extern void rebuild_sched_domains(void);
 
-extern void cpuset_print_task_mems_allowed(struct task_struct *p);
+extern void cpuset_print_current_mems_allowed(void);
 
 /*
  * read_mems_allowed_begin is required when making decisions involving
@@ -219,7 +219,7 @@ static inline void rebuild_sched_domains(void)
 	partition_sched_domains(1, NULL, NULL);
 }
 
-static inline void cpuset_print_task_mems_allowed(struct task_struct *p)
+static inline void cpuset_print_current_mems_allowed(void)
 {
 }
 
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2599,22 +2599,22 @@ int cpuset_mems_allowed_intersects(const struct task_struct *tsk1,
 }
 
 /**
- * cpuset_print_task_mems_allowed - prints task's cpuset and mems_allowed
- * @tsk: pointer to task_struct of some task.
+ * cpuset_print_current_mems_allowed - prints current's cpuset and mems_allowed
  *
- * Description: Prints @task's name, cpuset name, and cached copy of its
+ * Description: Prints current's name, cpuset name, and cached copy of its
  * mems_allowed to the kernel log.
  */
-void cpuset_print_task_mems_allowed(struct task_struct *tsk)
+void cpuset_print_current_mems_allowed(void)
 {
 	struct cgroup *cgrp;
 
 	rcu_read_lock();
 
-	cgrp = task_cs(tsk)->css.cgroup;
-	pr_info("%s cpuset=", tsk->comm);
+	cgrp = task_cs(current)->css.cgroup;
+	pr_info("%s cpuset=", current->comm);
 	pr_cont_cgroup_name(cgrp);
-	pr_cont(" mems_allowed=%*pbl\n", nodemask_pr_args(&tsk->mems_allowed));
+	pr_cont(" mems_allowed=%*pbl\n",
+		nodemask_pr_args(&current->mems_allowed));
 
 	rcu_read_unlock();
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -386,13 +386,11 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 static void dump_header(struct oom_control *oc, struct task_struct *p,
 			struct mem_cgroup *memcg)
 {
-	task_lock(current);
 	pr_warning("%s invoked oom-killer: gfp_mask=0x%x, order=%d, "
 		"oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, oc->order,
 		current->signal->oom_score_adj);
-	cpuset_print_task_mems_allowed(current);
-	task_unlock(current);
+	cpuset_print_current_mems_allowed();
 	dump_stack();
 	if (memcg)
 		mem_cgroup_print_oom_info(memcg, p);
@@ -518,10 +516,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p, memcg);
 
-	task_lock(p);
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
-	task_unlock(p);
 
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
@@ -586,10 +582,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
 				continue;
 
-			task_lock(p);	/* Protect ->comm from prctl() */
 			pr_err("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(p), p->comm);
-			task_unlock(p);
 			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 		}
 	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
