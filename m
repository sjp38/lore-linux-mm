Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85FE06B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:06:12 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id w16so80205458lfd.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:12 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id gs6si44396625wjc.83.2016.05.30.06.06.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 06:06:07 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so22523358wmn.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:07 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj
Date: Mon, 30 May 2016 15:05:53 +0200
Message-Id: <1464613556-16708-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_score_adj is shared for the thread groups (via struct signal) but
this is not sufficient to cover processes sharing mm (CLONE_VM without
CLONE_THREAD resp. CLONE_SIGHAND) and so we can easily end up in a
situation when some processes update their oom_score_adj and confuse
the oom killer. In the worst case some of those processes might hide
from oom killer altogether via OOM_SCORE_ADJ_MIN while others are
eligible. OOM killer would then pick up those eligible but won't be
allowed to kill others sharing the same mm so the mm wouldn't release
the mm and so the memory.

It would be ideal to have the oom_score_adj per mm_struct because that
is the natural entity OOM killer considers. But this will not work
because some programs are doing
	vfork()
	set_oom_adj()
	exec()

We can achieve the same though. oom_score_adj write handler can set the
oom_score_adj for all processes sharing the same mm if the task is not
in the middle of vfork. As a result all the processes will share the
same oom_score_adj. The current implementation is rather pessimistic
and checks all the existing processes by default if there are more than
1 holder of the mm but we do not have any reliable way to check for
external users yet.

Note that we have to serialize all the oom_score_adj writers now to
guarantee they do not interleave and generate inconsistent results.

Changes since v1
- note that we are changing oom_score_adj outside of the thread group
  to the log
- skip over kernel threads

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c     | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h |  2 ++
 mm/oom_kill.c      |  2 +-
 3 files changed, 49 insertions(+), 1 deletion(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 0afc77d4d84a..3947a0ea5465 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1043,10 +1043,13 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 
 static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 {
+	static DEFINE_MUTEX(oom_adj_mutex);
+	struct mm_struct *mm = NULL;
 	struct task_struct *task;
 	unsigned long flags;
 	int err = 0;
 
+	mutex_lock(&oom_adj_mutex);
 	task = get_proc_task(file_inode(file));
 	if (!task) {
 		err = -ESRCH;
@@ -1079,6 +1082,23 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		}
 	}
 
+	/*
+	 * Make sure we will check other processes sharing the mm if this is
+	 * not vfrok which wants its own oom_score_adj.
+	 * pin the mm so it doesn't go away and get reused after task_unlock
+	 */
+	if (!task->vfork_done) {
+		struct task_struct *p = find_lock_task_mm(task);
+
+		if (p) {
+			if (atomic_read(&p->mm->mm_users) > 1) {
+				mm = p->mm;
+				atomic_inc(&mm->mm_count);
+			}
+			task_unlock(p);
+		}
+	}
+
 	task->signal->oom_score_adj = oom_adj;
 	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = (short)oom_adj;
@@ -1086,8 +1106,34 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 err_sighand:
 	unlock_task_sighand(task, &flags);
 err_put_task:
+
+	if (mm) {
+		struct task_struct *p;
+
+		rcu_read_lock();
+		for_each_process(p) {
+			/* do not touch kernel threads */
+			if (p->flags & PF_KTHREAD)
+				continue;
+
+			task_lock(p);
+			if (!p->vfork_done && process_shares_mm(p, mm)) {
+				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
+						task_pid_nr(p), p->comm,
+						p->signal->oom_score_adj, oom_adj,
+						task_pid_nr(task), task->comm);
+				p->signal->oom_score_adj = oom_adj;
+				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
+					p->signal->oom_score_adj_min = (short)oom_adj;
+			}
+			task_unlock(p);
+		}
+		rcu_read_unlock();
+		mmdrop(mm);
+	}
 	put_task_struct(task);
 out:
+	mutex_unlock(&oom_adj_mutex);
 	return err;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 79e5129a3277..9bb4331f92f1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2248,6 +2248,8 @@ static inline int in_gate_area(struct mm_struct *mm, unsigned long addr)
 }
 #endif	/* __HAVE_ARCH_GATE_AREA */
 
+extern bool process_shares_mm(struct task_struct *p, struct mm_struct *mm);
+
 #ifdef CONFIG_SYSCTL
 extern int sysctl_drop_caches;
 int drop_caches_sysctl_handler(struct ctl_table *, int,
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index e01cc3e2e755..6bb322577fc6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -415,7 +415,7 @@ bool oom_killer_disabled __read_mostly;
  * task's threads: if one of those is using this mm then this task was also
  * using it.
  */
-static bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
+bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 {
 	struct task_struct *t;
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
