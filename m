Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D39726B0088
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 08:54:56 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ey11so7350197pad.10
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 05:54:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id on3si2113336pdb.111.2014.12.12.05.54.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 05:54:54 -0800 (PST)
Subject: [RFC PATCH] oom: Don't count on mm-less current process.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201412122254.AJJ57896.OLFOOJQHSMtFVF@I-love.SAKURA.ne.jp>
Date: Fri, 12 Dec 2014 22:54:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.cz, rientjes@google.com, oleg@redhat.com

>From 29d0b34a1c60e91ace8e1208a415ca371e6851fe Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Fri, 12 Dec 2014 21:29:06 +0900
Subject: [PATCH] oom: Don't count on mm-less current process.

out_of_memory() doesn't trigger OOM killer if the current task is already
exiting or it has fatal signals pending, and gives the task access to
memory reserves instead. This is done to prevent from livelocks described by
commit 9ff4868e3051d912 ("mm, oom: allow exiting threads to have access to
memory reserves") and commit 7b98c2e402eaa1f2 ("oom: give current access to
memory reserves if it has been killed") as well as to prevent from unnecessary
killing of other tasks, with heuristic that the current task would finish
soon and release its resources.

However, this heuristic doesn't work as expected when out_of_memory() is
triggered by an allocation after the current task has already released
its memory in exit_mm() (e.g. from exit_task_work()) because it might
livelock waiting for a memory which gets never released while there are
other tasks sitting on a lot of memory.

Therefore, consider doing checks as with sysctl_oom_kill_allocating_task
case before giving the current task access to memory reserves.

Note that this patch cannot prevent somebody from calling oom_kill_process()
with a victim task when the victim task already got PF_EXITING flag and
released its memory. This means that the OOM killer is kept disabled for
unpredictable duration when the victim task is unkillable due to dependency
which is invisible to the OOM killer (e.g. waiting for lock held by somebody)
after somebody set TIF_MEMDIE flag on the victim task by calling
oom_kill_process(). What is unfortunate, a local unprivileged user can make
the victim task unkillable on purpose. There are two approaches for mitigating
this problem. Workaround is to use sysctl-tunable panic on TIF_MEMDIE timeout
(Detect DoS attacks and react. Easy to backport. Works for memory depletion
bugs caused by kernel code.) and preferred fix is to develop complete kernel
memory allocation tracking (Try to avoid DoS but do nothing when failed to
avoid. Hard to backport. Works for memory depletion attacks caused by user
programs). Anyway that's beyond what this patch can do.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h |  3 +++
 mm/memcontrol.c     |  8 +++++++-
 mm/oom_kill.c       | 12 +++++++++---
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 4971874..eee5802 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -64,6 +64,9 @@ extern void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 			       int order, const nodemask_t *nodemask);
 
+extern bool oom_unkillable_task(struct task_struct *p,
+				struct mem_cgroup *memcg,
+				const nodemask_t *nodemask);
 extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c6ac50e..6d9532d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1558,8 +1558,14 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
+	 *
+	 * However, if current is calling out_of_memory() by doing memory
+	 * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
+	 * was set by exit_signals() and mm was released by exit_mm(), it is
+	 * wrong to expect current to exit and free its memory quickly.
 	 */
-	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
+	if ((fatal_signal_pending(current) || current->flags & PF_EXITING) &&
+	    current->mm && !oom_unkillable_task(current, memcg, NULL)) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 481d550..01719d6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -118,8 +118,8 @@ found:
 }
 
 /* return true if the task is not adequate as candidate victim task. */
-static bool oom_unkillable_task(struct task_struct *p,
-		struct mem_cgroup *memcg, const nodemask_t *nodemask)
+bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *memcg,
+			 const nodemask_t *nodemask)
 {
 	if (is_global_init(p))
 		return true;
@@ -649,8 +649,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
+	 *
+	 * However, if current is calling out_of_memory() by doing memory
+	 * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
+	 * was set by exit_signals() and mm was released by exit_mm(), it is
+	 * wrong to expect current to exit and free its memory quickly.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    current->mm && !oom_unkillable_task(current, NULL, nodemask)) {
 		set_thread_flag(TIF_MEMDIE);
 		return;
 	}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
