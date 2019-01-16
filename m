Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 069258E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:55:49 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id a3so2962271otl.9
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 02:55:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id r10si2776489oia.78.2019.01.16.02.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 02:55:47 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, oom: Tolerate processes sharing mm with different view of oom_score_adj.
Date: Wed, 16 Jan 2019 19:55:21 +0900
Message-Id: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Yong-Taek Lee <ytk.lee@samsung.com>

This patch reverts both commit 44a70adec910d692 ("mm, oom_adj: make sure
processes sharing mm have same view of oom_score_adj") and commit
97fd49c2355ffded ("mm, oom: kill all tasks sharing the mm") in order to
close a race and reduce the latency at __set_oom_adj(), and reduces the
warning at __oom_kill_process() in order to minimize the latency.

Commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper managed
to unmap the address space") introduced the worst case mentioned in
44a70adec910d692. But since the OOM killer skips mm with MMF_OOM_SKIP set,
only administrators can trigger the worst case.

Since 44a70adec910d692 did not take latency into account, we can hold RCU
for minutes and trigger RCU stall warnings by calling printk() on many
thousands of thread groups. Even without calling printk(), the latency is
mentioned by Yong-Taek Lee [1]. And I noticed that 44a70adec910d692 is
racy, and trying to fix the race will require a global lock which is too
costly for rare events.

If the worst case in 44a70adec910d692 happens, it is an administrator's
request. Therefore, tolerate the worst case and speed up __set_oom_adj().

[1] https://lkml.kernel.org/r/20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Yong-Taek Lee <ytk.lee@samsung.com>
---
 fs/proc/base.c     | 46 ----------------------------------------------
 include/linux/mm.h |  2 --
 mm/oom_kill.c      | 10 ++++++----
 3 files changed, 6 insertions(+), 52 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 633a634..41ece8f 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1020,7 +1020,6 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 {
 	static DEFINE_MUTEX(oom_adj_mutex);
-	struct mm_struct *mm = NULL;
 	struct task_struct *task;
 	int err = 0;
 
@@ -1050,55 +1049,10 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		}
 	}
 
-	/*
-	 * Make sure we will check other processes sharing the mm if this is
-	 * not vfrok which wants its own oom_score_adj.
-	 * pin the mm so it doesn't go away and get reused after task_unlock
-	 */
-	if (!task->vfork_done) {
-		struct task_struct *p = find_lock_task_mm(task);
-
-		if (p) {
-			if (atomic_read(&p->mm->mm_users) > 1) {
-				mm = p->mm;
-				mmgrab(mm);
-			}
-			task_unlock(p);
-		}
-	}
-
 	task->signal->oom_score_adj = oom_adj;
 	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = (short)oom_adj;
 	trace_oom_score_adj_update(task);
-
-	if (mm) {
-		struct task_struct *p;
-
-		rcu_read_lock();
-		for_each_process(p) {
-			if (same_thread_group(task, p))
-				continue;
-
-			/* do not touch kernel threads or the global init */
-			if (p->flags & PF_KTHREAD || is_global_init(p))
-				continue;
-
-			task_lock(p);
-			if (!p->vfork_done && process_shares_mm(p, mm)) {
-				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
-						task_pid_nr(p), p->comm,
-						p->signal->oom_score_adj, oom_adj,
-						task_pid_nr(task), task->comm);
-				p->signal->oom_score_adj = oom_adj;
-				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
-					p->signal->oom_score_adj_min = (short)oom_adj;
-			}
-			task_unlock(p);
-		}
-		rcu_read_unlock();
-		mmdrop(mm);
-	}
 err_unlock:
 	mutex_unlock(&oom_adj_mutex);
 	put_task_struct(task);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb640..28879c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2690,8 +2690,6 @@ static inline int in_gate_area(struct mm_struct *mm, unsigned long addr)
 }
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
-extern bool process_shares_mm(struct task_struct *p, struct mm_struct *mm);
-
 #ifdef CONFIG_SYSCTL
 extern int sysctl_drop_caches;
 int drop_caches_sysctl_handler(struct ctl_table *, int,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9..c7005b1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -478,7 +478,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
  * task's threads: if one of those is using this mm then this task was also
  * using it.
  */
-bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
+static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 {
 	struct task_struct *t;
 
@@ -896,12 +896,14 @@ static void __oom_kill_process(struct task_struct *victim)
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (is_global_init(p)) {
+		if (is_global_init(p) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			can_oom_reap = false;
-			set_bit(MMF_OOM_SKIP, &mm->flags);
-			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
+			if (!test_bit(MMF_OOM_SKIP, &mm->flags))
+				pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
 					task_pid_nr(victim), victim->comm,
 					task_pid_nr(p), p->comm);
+			set_bit(MMF_OOM_SKIP, &mm->flags);
 			continue;
 		}
 		/*
-- 
1.8.3.1
