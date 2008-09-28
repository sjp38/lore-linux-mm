Date: Sun, 28 Sep 2008 23:09:31 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] mm owner: fix race between swapoff and exit
In-Reply-To: <Pine.LNX.4.64.0809250117220.26422@blonde.site>
Message-ID: <Pine.LNX.4.64.0809282307540.12824@blonde.site>
References: <Pine.LNX.4.64.0809250117220.26422@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Jiri Slaby <jirislaby@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyuki@jp.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There's a race between mm->owner assignment and swapoff, more easily
seen when task slab poisoning is turned on.  The condition occurs when
try_to_unuse() runs in parallel with an exiting task.  A similar race
can occur with callers of get_task_mm(), such as /proc/<pid>/<mmstats>
or ptrace or page migration.

CPU0                                    CPU1
                                        try_to_unuse
                                        looks at mm = task0->mm
                                        increments mm->mm_users
task 0 exits
mm->owner needs to be updated, but no
new owner is found (mm_users > 1, but
no other task has task->mm = task0->mm)
mm_update_next_owner() leaves
                                        mmput(mm) decrements mm->mm_users
task0 freed
                                        dereferencing mm->owner fails

The fix is to notify the subsystem via mm_owner_changed callback(),
if no new owner is found, by specifying the new task as NULL.

Jiri Slaby:
mm->owner was set to NULL prior to calling cgroup_mm_owner_callbacks(), but
must be set after that, so as not to pass NULL as old owner causing oops.

Daisuke Nishimura:
mm_update_next_owner() may set mm->owner to NULL, but mem_cgroup_from_task()
and its callers need to take account of this situation to avoid oops.

Hugh Dickins:
Lockdep warning and hang below exec_mmap() when testing these patches.
exit_mm() up_reads mmap_sem before calling mm_update_next_owner(),
so exec_mmap() now needs to do the same.  And with that repositioning,
there's now no point in mm_need_new_owner() allowing for NULL mm.

Reported-by: Hugh Dickins <hugh@veritas.com>
Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
Andrew, this patch folds together the following three from mmotm:
mm-owner-fix-race-between-swap-and-exit.patch
mm-owner-fix-race-between-swap-and-exit-fix.patch
mm-owner-fix-race-between-swap-and-exit-fix-fix.patch
which tests just before KS showed now to be needed in 2.6.27.

Together with Hugh's already-folded-in contribution to:
memrlimit-cgroup-mm-owner-callback-changes-to-add-task-info.patch
which is now needed even without memrlimits, given the above changes.

The regression fixed is actually a regression since 2.6.25;
but let's take a breath before rushing an equivalent fix to stable.

 fs/exec.c       |    2 +-
 kernel/cgroup.c |    5 +++--
 kernel/exit.c   |   12 ++++++++++--
 mm/memcontrol.c |   17 +++++++++++++++++
 4 files changed, 31 insertions(+), 5 deletions(-)

--- 2.6.27-rc7/fs/exec.c	2008-07-29 04:24:47.000000000 +0100
+++ linux/fs/exec.c	2008-09-24 17:17:32.000000000 +0100
@@ -752,11 +752,11 @@ static int exec_mmap(struct mm_struct *m
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
 	task_unlock(tsk);
-	mm_update_next_owner(old_mm);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);
 		BUG_ON(active_mm != old_mm);
+		mm_update_next_owner(old_mm);
 		mmput(old_mm);
 		return 0;
 	}
--- 2.6.27-rc7/kernel/cgroup.c	2008-08-06 08:36:20.000000000 +0100
+++ linux/kernel/cgroup.c	2008-09-24 17:17:32.000000000 +0100
@@ -2738,14 +2738,15 @@ void cgroup_fork_callbacks(struct task_s
  */
 void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
 {
-	struct cgroup *oldcgrp, *newcgrp;
+	struct cgroup *oldcgrp, *newcgrp = NULL;
 
 	if (need_mm_owner_callback) {
 		int i;
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 			oldcgrp = task_cgroup(old, ss->subsys_id);
-			newcgrp = task_cgroup(new, ss->subsys_id);
+			if (new)
+				newcgrp = task_cgroup(new, ss->subsys_id);
 			if (oldcgrp == newcgrp)
 				continue;
 			if (ss->mm_owner_changed)
--- 2.6.27-rc7/kernel/exit.c	2008-09-10 07:37:25.000000000 +0100
+++ linux/kernel/exit.c	2008-09-24 17:17:32.000000000 +0100
@@ -583,8 +583,6 @@ mm_need_new_owner(struct mm_struct *mm, 
 	 * If there are other users of the mm and the owner (us) is exiting
 	 * we need to find a new owner to take on the responsibility.
 	 */
-	if (!mm)
-		return 0;
 	if (atomic_read(&mm->mm_users) <= 1)
 		return 0;
 	if (mm->owner != p)
@@ -627,6 +625,16 @@ retry:
 	} while_each_thread(g, c);
 
 	read_unlock(&tasklist_lock);
+	/*
+	 * We found no owner yet mm_users > 1: this implies that we are
+	 * most likely racing with swapoff (try_to_unuse()) or /proc or
+	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL,
+	 * so that subsystems can understand the callback and take action.
+	 */
+	down_write(&mm->mmap_sem);
+	cgroup_mm_owner_callbacks(mm->owner, NULL);
+	mm->owner = NULL;
+	up_write(&mm->mmap_sem);
 	return;
 
 assign_new_owner:
--- 2.6.27-rc7/mm/memcontrol.c	2008-08-13 04:14:51.000000000 +0100
+++ linux/mm/memcontrol.c	2008-09-24 17:17:32.000000000 +0100
@@ -250,6 +250,14 @@ static struct mem_cgroup *mem_cgroup_fro
 
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
+	/*
+	 * mm_update_next_owner() may clear mm->owner to NULL
+	 * if it races with swapoff, page migration, etc.
+	 * So this can be called with p == NULL.
+	 */
+	if (unlikely(!p))
+		return NULL;
+
 	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
 				struct mem_cgroup, css);
 }
@@ -549,6 +557,11 @@ static int mem_cgroup_charge_common(stru
 	if (likely(!memcg)) {
 		rcu_read_lock();
 		mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+		if (unlikely(!mem)) {
+			rcu_read_unlock();
+			kmem_cache_free(page_cgroup_cache, pc);
+			return 0;
+		}
 		/*
 		 * For every charge from the cgroup, increment reference count
 		 */
@@ -801,6 +814,10 @@ int mem_cgroup_shrink_usage(struct mm_st
 
 	rcu_read_lock();
 	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (unlikely(!mem)) {
+		rcu_read_unlock();
+		return 0;
+	}
 	css_get(&mem->css);
 	rcu_read_unlock();
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
