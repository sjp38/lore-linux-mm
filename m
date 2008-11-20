Date: Thu, 20 Nov 2008 01:11:45 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 1/7] mm: remove cgroup_mm_owner_callbacks
In-Reply-To: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811200110180.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

cgroup_mm_owner_callbacks() was brought in to support the memrlimit
controller, but sneaked into mainline ahead of it.  That controller
has now been shelved, and the mm_owner_changed() args were inadequate
for it anyway (they needed an mm pointer instead of a task pointer).

Remove the dead code, and restore mm_update_next_owner() locking to
how it was before: taking mmap_sem there does nothing for memcontrol.c,
now the only user of mm->owner.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 include/linux/cgroup.h |   14 +-------------
 kernel/cgroup.c        |   33 ---------------------------------
 kernel/exit.c          |   16 ++++++----------
 3 files changed, 7 insertions(+), 56 deletions(-)

--- mmclean0/include/linux/cgroup.h	2008-11-02 23:17:56.000000000 +0000
+++ mmclean1/include/linux/cgroup.h	2008-11-19 15:26:10.000000000 +0000
@@ -329,13 +329,7 @@ struct cgroup_subsys {
 			struct cgroup *cgrp);
 	void (*post_clone)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
-	/*
-	 * This routine is called with the task_lock of mm->owner held
-	 */
-	void (*mm_owner_changed)(struct cgroup_subsys *ss,
-					struct cgroup *old,
-					struct cgroup *new,
-					struct task_struct *p);
+
 	int subsys_id;
 	int active;
 	int disabled;
@@ -400,9 +394,6 @@ void cgroup_iter_end(struct cgroup *cgrp
 int cgroup_scan_tasks(struct cgroup_scanner *scan);
 int cgroup_attach_task(struct cgroup *, struct task_struct *);
 
-void cgroup_mm_owner_callbacks(struct task_struct *old,
-			       struct task_struct *new);
-
 #else /* !CONFIG_CGROUPS */
 
 static inline int cgroup_init_early(void) { return 0; }
@@ -420,9 +411,6 @@ static inline int cgroupstats_build(stru
 	return -EINVAL;
 }
 
-static inline void cgroup_mm_owner_callbacks(struct task_struct *old,
-					     struct task_struct *new) {}
-
 #endif /* !CONFIG_CGROUPS */
 
 #endif /* _LINUX_CGROUP_H */
--- mmclean0/kernel/cgroup.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean1/kernel/cgroup.c	2008-11-19 15:26:10.000000000 +0000
@@ -116,7 +116,6 @@ static int root_count;
  * be called.
  */
 static int need_forkexit_callback __read_mostly;
-static int need_mm_owner_callback __read_mostly;
 
 /* convenient tests for these bits */
 inline int cgroup_is_removed(const struct cgroup *cgrp)
@@ -2539,7 +2538,6 @@ static void __init cgroup_init_subsys(st
 	init_css_set.subsys[ss->subsys_id] = dummytop->subsys[ss->subsys_id];
 
 	need_forkexit_callback |= ss->fork || ss->exit;
-	need_mm_owner_callback |= !!ss->mm_owner_changed;
 
 	/* At system boot, before all subsystems have been
 	 * registered, no tasks have been forked, so we don't
@@ -2789,37 +2787,6 @@ void cgroup_fork_callbacks(struct task_s
 	}
 }
 
-#ifdef CONFIG_MM_OWNER
-/**
- * cgroup_mm_owner_callbacks - run callbacks when the mm->owner changes
- * @p: the new owner
- *
- * Called on every change to mm->owner. mm_init_owner() does not
- * invoke this routine, since it assigns the mm->owner the first time
- * and does not change it.
- *
- * The callbacks are invoked with mmap_sem held in read mode.
- */
-void cgroup_mm_owner_callbacks(struct task_struct *old, struct task_struct *new)
-{
-	struct cgroup *oldcgrp, *newcgrp = NULL;
-
-	if (need_mm_owner_callback) {
-		int i;
-		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-			struct cgroup_subsys *ss = subsys[i];
-			oldcgrp = task_cgroup(old, ss->subsys_id);
-			if (new)
-				newcgrp = task_cgroup(new, ss->subsys_id);
-			if (oldcgrp == newcgrp)
-				continue;
-			if (ss->mm_owner_changed)
-				ss->mm_owner_changed(ss, oldcgrp, newcgrp, new);
-		}
-	}
-}
-#endif /* CONFIG_MM_OWNER */
-
 /**
  * cgroup_post_fork - called on a new task after adding it to the task list
  * @child: the task in question
--- mmclean0/kernel/exit.c	2008-11-19 15:25:12.000000000 +0000
+++ mmclean1/kernel/exit.c	2008-11-19 15:26:10.000000000 +0000
@@ -638,35 +638,31 @@ retry:
 	/*
 	 * We found no owner yet mm_users > 1: this implies that we are
 	 * most likely racing with swapoff (try_to_unuse()) or /proc or
-	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL,
-	 * so that subsystems can understand the callback and take action.
+	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL.
 	 */
-	down_write(&mm->mmap_sem);
-	cgroup_mm_owner_callbacks(mm->owner, NULL);
 	mm->owner = NULL;
-	up_write(&mm->mmap_sem);
 	return;
 
 assign_new_owner:
 	BUG_ON(c == p);
 	get_task_struct(c);
-	read_unlock(&tasklist_lock);
-	down_write(&mm->mmap_sem);
 	/*
 	 * The task_lock protects c->mm from changing.
 	 * We always want mm->owner->mm == mm
 	 */
 	task_lock(c);
+	/*
+	 * Delay read_unlock() till we have the task_lock()
+	 * to ensure that c does not slip away underneath us
+	 */
+	read_unlock(&tasklist_lock);
 	if (c->mm != mm) {
 		task_unlock(c);
-		up_write(&mm->mmap_sem);
 		put_task_struct(c);
 		goto retry;
 	}
-	cgroup_mm_owner_callbacks(mm->owner, c);
 	mm->owner = c;
 	task_unlock(c);
-	up_write(&mm->mmap_sem);
 	put_task_struct(c);
 }
 #endif /* CONFIG_MM_OWNER */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
