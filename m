Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB1216B0262
	for <linux-mm@kvack.org>; Thu, 26 May 2016 08:40:31 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ne4so38971587lbc.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id wj5si18099291wjb.240.2016.05.26.05.40.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 05:40:27 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n129so4596350wmn.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:26 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj
Date: Thu, 26 May 2016 14:40:12 +0200
Message-Id: <1464266415-15558-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
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

It would be ideal to have the oom_score_adj per mm_struct becuase that
is the natural entity OOM killer considers. But this will not work
because some programs are doing
	vfork()
	set_oom_adj()
	exec()

We can achieve the same though. oom_score_adj write handler can set the
oom_score_adj for all processes sharing the same mm if the task is not
in the middle of vfork. As a result all the processes will share the
same oom_score_adj.

Note that we have to serialize all the oom_score_adj writers now to
guarantee they do not interleave and generate inconsistent results.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/proc/base.c     | 35 +++++++++++++++++++++++++++++++++++
 include/linux/mm.h |  2 ++
 mm/oom_kill.c      |  2 +-
 3 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 23679673bf5a..e3ee4fb1930c 100644
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
@@ -1085,6 +1088,20 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 		}
 	}
 
+	/*
+	 * If we are not in the vfork and share mm with other processes we
+	 * have to propagate the score otherwise we would have a schizophrenic
+	 * requirements for the same mm. We can use racy check because we
+	 * only risk the slow path.
+	 */
+	if (!task->vfork_done &&
+			atomic_read(&task->mm->mm_users) > get_nr_threads(task)) {
+		mm = task->mm;
+
+		/* pin the mm so it doesn't go away and get reused */
+		atomic_inc(&mm->mm_count);
+	}
+
 	task->signal->oom_score_adj = oom_adj;
 	if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
 		task->signal->oom_score_adj_min = (short)oom_adj;
@@ -1094,7 +1111,25 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
 err_task_lock:
 	task_unlock(task);
 	put_task_struct(task);
+
+	if (mm) {
+		struct task_struct *p;
+
+		rcu_read_lock();
+		for_each_process(p) {
+			task_lock(p);
+			if (!p->vfork_done && process_shares_mm(p, mm)) {
+				p->signal->oom_score_adj = oom_adj;
+				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
+					p->signal->oom_score_adj_min = (short)oom_adj;
+			}
+			task_unlock(p);
+		}
+		rcu_read_unlock();
+		mmdrop(mm);
+	}
 out:
+	mutex_unlock(&oom_adj_mutex);
 	return err;
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 05102822912c..b44d3d792a00 100644
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
index 0e33e912f7e4..eeccb4d7e7f5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -416,7 +416,7 @@ bool oom_killer_disabled __read_mostly;
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
