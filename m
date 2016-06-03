Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 816B26B0260
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 05:17:00 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id rs7so34432656lbb.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:17:00 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id t10si40759025wme.94.2016.06.03.02.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 02:16:53 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a20so10497853wma.3
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 02:16:53 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 04/10] mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj
Date: Fri,  3 Jun 2016 11:16:38 +0200
Message-Id: <1464945404-30157-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
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

Changes since v2
- skip over same thread group
- skip over kernel threads and global init

Changes since v1
- note that we are changing oom_score_adj outside of the thread group
  to the log

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c     | 53 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/mm.h |  2 ++
 mm/oom_kill.c      |  2 +-
 3 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 520fa467cad0..f5fa338daaed 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1040,14 +1040,13 @@ static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t count,
 static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 {
 	static DEFINE_MUTEX(oom_adj_mutex);
+	struct mm_struct *mm = NULL;
 	struct task_struct *task;
 	int err = 0;
 
 	task = get_proc_task(file_inode(file));
-	if (!task) {
-		err = -ESRCH;
-		goto out;
-	}
+	if (!task)
+		return -ESRCH;
 
 	mutex_lock(&oom_adj_mutex);
 	if (legacy) {
@@ -1071,14 +1070,58 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
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
 	trace_oom_score_adj_update(task);
+
+	if (mm) {
+		struct task_struct *p;
+
+		rcu_read_lock();
+		for_each_process(p) {
+			if (same_thread_group(task,p))
+				continue;
+
+			/* do not touch kernel threads or the global init */
+			if (p->flags & PF_KTHREAD || is_global_init(p))
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
 err_unlock:
 	mutex_unlock(&oom_adj_mutex);
 	put_task_struct(task);
-out:
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
index 25eac62c190c..d60924e1940d 100644
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
