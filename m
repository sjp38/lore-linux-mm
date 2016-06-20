Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE3AF6B0265
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 08:44:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so27189366wmr.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:44:11 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id mc5si29127781wjb.194.2016.06.20.05.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 05:43:58 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a66so8693879wme.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 05:43:58 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 05/10] mm, oom: skip vforked tasks from being selected
Date: Mon, 20 Jun 2016 14:43:43 +0200
Message-Id: <1466426628-15074-6-git-send-email-mhocko@kernel.org>
In-Reply-To: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
References: <1466426628-15074-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

vforked tasks are not really sitting on any memory. They are sharing
the mm with parent until they exec into a new code. Until then it is
just pinning the address space. OOM killer will kill the vforked task
along with its parent but we still can end up selecting vforked task
when the parent wouldn't be selected. E.g. init doing vfork to launch
a task or vforked being a child of oom unkillable task with an updated
oom_score_adj to be killable.

Add a new helper to check whether a task is in the vfork sharing memory
with its parent and use it in oom_badness to skip over these tasks.

Changes since v1
- copy_process() doesn't disallow CLONE_VFORK without CLONE_VM, so with
  this patch it would be trivial to make the exploit which hides a
  memory hog from oom-killer - per Oleg
- comment in in_vfork by Oleg

Acked-by: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h | 26 ++++++++++++++++++++++++++
 mm/oom_kill.c         |  6 ++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ec636400669f..7442f74b6d44 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1883,6 +1883,32 @@ extern int arch_task_struct_size __read_mostly;
 #define TNF_FAULT_LOCAL	0x08
 #define TNF_MIGRATE_FAIL 0x10
 
+static inline bool in_vfork(struct task_struct *tsk)
+{
+	bool ret;
+
+	/*
+	 * need RCU to access ->real_parent if CLONE_VM was used along with
+	 * CLONE_PARENT.
+	 *
+	 * We check real_parent->mm == tsk->mm because CLONE_VFORK does not
+	 * imply CLONE_VM
+	 *
+	 * CLONE_VFORK can be used with CLONE_PARENT/CLONE_THREAD and thus
+	 * ->real_parent is not necessarily the task doing vfork(), so in
+	 * theory we can't rely on task_lock() if we want to dereference it.
+	 *
+	 * And in this case we can't trust the real_parent->mm == tsk->mm
+	 * check, it can be false negative. But we do not care, if init or
+	 * another oom-unkillable task does this it should blame itself.
+	 */
+	rcu_read_lock();
+	ret = tsk->vfork_done && tsk->real_parent->mm == tsk->mm;
+	rcu_read_unlock();
+
+	return ret;
+}
+
 #ifdef CONFIG_NUMA_BALANCING
 extern void task_numa_fault(int last_node, int node, int pages, int flags);
 extern pid_t task_numa_group_id(struct task_struct *p);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index d8220c5603a5..02da660b7c25 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -176,11 +176,13 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 
 	/*
 	 * Do not even consider tasks which are explicitly marked oom
-	 * unkillable or have been already oom reaped.
+	 * unkillable or have been already oom reaped or the are in
+	 * the middle of vfork
 	 */
 	adj = (long)p->signal->oom_score_adj;
 	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
+			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
+			in_vfork(p)) {
 		task_unlock(p);
 		return 0;
 	}
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
