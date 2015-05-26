Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1C96B6B0178
	for <linux-mm@kvack.org>; Tue, 26 May 2015 07:50:27 -0400 (EDT)
Received: by wgme6 with SMTP id e6so26194893wgm.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 04:50:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id el3si17741415wib.24.2015.05.26.04.50.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 May 2015 04:50:24 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/3] memcg: get rid of mm_struct::owner
Date: Tue, 26 May 2015 13:50:06 +0200
Message-Id: <1432641006-8025-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

mm_struct::owner keeps track of the task which is in charge for the
specific mm. This is usually the thread group leader of the task but
there are more exotic cases where this doesn't hold.

The most prominent one is when separate tasks (not in the same thread
group) share the address space (by using clone with CLONE_VM without
CLONE_THREAD). The first task will be the owner until it exits.
mm_update_next_owner will then try to find a new owner - a task which
points to the same mm_struct. There is no guarantee a new owner will
be the thread group leader though because the leader might have
exited. Even though such a thread will be still around waiting for the
remaining threads from its group, it's mm will be NULL so it cannot be
chosen.

cgroup migration code, however assumes only group leaders when migrating
via cgroup.procs (which will be the only mode in the unified hierarchy
API) while mem_cgroup_can_attach only those tasks which are owner
of the mm. So we might end up with tasks which cannot be migrated.
mm_update_next_owner could be tweaked to try harder and use a group
leader whenever possible but this will never be 100% because all the
leaders might be dead.  It seems that getting rid of the mm->owner
sounds like a better option.

The whole concept of the mm owner is a bit artificial and too tricky to
get right. All the memcg code needs is to find struct mem_cgroup from
a given mm_struct and there are only two events when the association
is either built or changed
	- a new mm is created - dup_mm - when the memcg is inherited
	  from the oldmm
	- task associated with the mm is moved to another memcg
So it is much more easier to bind mm_struct with the mem_cgroup directly
rather than indirectly via a task. This is exactly what this patch does.

mm_set_memcg and mm_drop_memcg are exported for the core kernel to bind
an old memcg during dup_mm and releasing that memcg in mmput after the
last reference is dropped and no task sees the mm anymore. We have to be
careful and take a reference to the memcg->css so that it doesn't vanish
from under our feet.
mm_move_memcg is then used during the task migration to change the
association. This is done in mem_cgroup_move_task before charges get
moved because mem_cgroup_can_attach is too early and other controllers
might fail and we would have to handle the rollback. The race between
can_attach and attach is harmless and it existed even before.

mm->memcg conforms to standard mem_cgroup locking rules. It has to be
used inside rcu_read_{un}lock() and a reference has to be taken before the
unlock if the memcg is supposed to be used outside. mm_move_memcg will
make sure that all the preexisting users will finish before it drops the
reference to the old memcg.

Finally mem_cgroup_can_attach will allow task migration only for the
thread group leaders to conform with cgroup core requirements.

Please note that this patch introduces a USER VISIBLE CHANGE OF BEHAVIOR.
Without mm->owner _all_ tasks associated with the mm_struct would
initiate memcg migration while previously only owner of the mm_struct
could do that. The original behavior was awkward though because the user
task didn't have any means to find out the current owner (esp. after
mm_update_next_owner) so the migration behavior was not well defined
in general.
New cgroup API (unified hierarchy) will discontinue tasks file which
means that migrating threads will no longer be possible. In such a case
having CLONE_VM without CLONE_THREAD could emulate the thread behavior
but this patch prevents from isolating memcg controllers from others.
Nevertheless I am not convinced such a use case would really deserve
complications on the memcg code side.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 fs/exec.c                  |  1 -
 include/linux/memcontrol.h | 14 ++++++-
 include/linux/mm_types.h   | 12 +-----
 kernel/exit.c              | 89 -----------------------------------------
 kernel/fork.c              | 10 +----
 mm/debug.c                 |  4 +-
 mm/memcontrol.c            | 99 +++++++++++++++++++++++++++++++++++-----------
 7 files changed, 93 insertions(+), 136 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 02bfd980a40c..2cd4def4b1d6 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -867,7 +867,6 @@ static int exec_mmap(struct mm_struct *mm)
 		up_read(&old_mm->mmap_sem);
 		BUG_ON(active_mm != old_mm);
 		setmax_mm_hiwater_rss(&tsk->signal->maxrss, old_mm);
-		mm_update_next_owner(old_mm);
 		mmput(old_mm);
 		return 0;
 	}
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c8918114804..315ec1e58acb 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -67,6 +67,8 @@ enum mem_cgroup_events_index {
 };
 
 #ifdef CONFIG_MEMCG
+void mm_drop_memcg(struct mm_struct *mm);
+void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg);
 void mem_cgroup_events(struct mem_cgroup *memcg,
 		       enum mem_cgroup_events_index idx,
 		       unsigned int nr);
@@ -92,7 +94,6 @@ bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
-extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
 extern struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css);
@@ -104,7 +105,12 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 	bool match = false;
 
 	rcu_read_lock();
-	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	/*
+	 * rcu_dereference would be better but mem_cgroup is not a complete
+	 * type here
+	 */
+	task_memcg = READ_ONCE(mm->memcg);
+	smp_read_barrier_depends();
 	if (task_memcg)
 		match = mem_cgroup_is_descendant(task_memcg, memcg);
 	rcu_read_unlock();
@@ -195,6 +201,10 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
+void mm_drop_memcg(struct mm_struct *mm)
+{}
+void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
+{}
 static inline void mem_cgroup_events(struct mem_cgroup *memcg,
 				     enum mem_cgroup_events_index idx,
 				     unsigned int nr)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f6266742ce1f..93dc8cb9c636 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -426,17 +426,7 @@ struct mm_struct {
 	struct kioctx_table __rcu	*ioctx_table;
 #endif
 #ifdef CONFIG_MEMCG
-	/*
-	 * "owner" points to a task that is regarded as the canonical
-	 * user/owner of this mm. All of the following must be true in
-	 * order for it to be changed:
-	 *
-	 * current == mm->owner
-	 * current->mm != mm
-	 * new_owner->mm == mm
-	 * new_owner->alloc_lock is held
-	 */
-	struct task_struct __rcu *owner;
+	struct mem_cgroup __rcu *memcg;
 #endif
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
diff --git a/kernel/exit.c b/kernel/exit.c
index 4089c2fd373e..8f3e5b4c58ce 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -292,94 +292,6 @@ kill_orphaned_pgrp(struct task_struct *tsk, struct task_struct *parent)
 	}
 }
 
-#ifdef CONFIG_MEMCG
-/*
- * A task is exiting.   If it owned this mm, find a new owner for the mm.
- */
-void mm_update_next_owner(struct mm_struct *mm)
-{
-	struct task_struct *c, *g, *p = current;
-
-retry:
-	/*
-	 * If the exiting or execing task is not the owner, it's
-	 * someone else's problem.
-	 */
-	if (mm->owner != p)
-		return;
-	/*
-	 * The current owner is exiting/execing and there are no other
-	 * candidates.  Do not leave the mm pointing to a possibly
-	 * freed task structure.
-	 */
-	if (atomic_read(&mm->mm_users) <= 1) {
-		mm->owner = NULL;
-		return;
-	}
-
-	read_lock(&tasklist_lock);
-	/*
-	 * Search in the children
-	 */
-	list_for_each_entry(c, &p->children, sibling) {
-		if (c->mm == mm)
-			goto assign_new_owner;
-	}
-
-	/*
-	 * Search in the siblings
-	 */
-	list_for_each_entry(c, &p->real_parent->children, sibling) {
-		if (c->mm == mm)
-			goto assign_new_owner;
-	}
-
-	/*
-	 * Search through everything else, we should not get here often.
-	 */
-	for_each_process(g) {
-		if (g->flags & PF_KTHREAD)
-			continue;
-		for_each_thread(g, c) {
-			if (c->mm == mm)
-				goto assign_new_owner;
-			if (c->mm)
-				break;
-		}
-	}
-	read_unlock(&tasklist_lock);
-	/*
-	 * We found no owner yet mm_users > 1: this implies that we are
-	 * most likely racing with swapoff (try_to_unuse()) or /proc or
-	 * ptrace or page migration (get_task_mm()).  Mark owner as NULL.
-	 */
-	mm->owner = NULL;
-	return;
-
-assign_new_owner:
-	BUG_ON(c == p);
-	get_task_struct(c);
-	/*
-	 * The task_lock protects c->mm from changing.
-	 * We always want mm->owner->mm == mm
-	 */
-	task_lock(c);
-	/*
-	 * Delay read_unlock() till we have the task_lock()
-	 * to ensure that c does not slip away underneath us
-	 */
-	read_unlock(&tasklist_lock);
-	if (c->mm != mm) {
-		task_unlock(c);
-		put_task_struct(c);
-		goto retry;
-	}
-	mm->owner = c;
-	task_unlock(c);
-	put_task_struct(c);
-}
-#endif /* CONFIG_MEMCG */
-
 /*
  * Turn us into a lazy TLB process if we
  * aren't already..
@@ -433,7 +345,6 @@ static void exit_mm(struct task_struct *tsk)
 	up_read(&mm->mmap_sem);
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
-	mm_update_next_owner(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
 		exit_oom_victim();
diff --git a/kernel/fork.c b/kernel/fork.c
index 556cc64ae0c4..075688b2cae5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -570,13 +570,6 @@ static void mm_init_aio(struct mm_struct *mm)
 #endif
 }
 
-static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
-{
-#ifdef CONFIG_MEMCG
-	mm->owner = p;
-#endif
-}
-
 static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 {
 	mm->mmap = NULL;
@@ -596,7 +589,6 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	spin_lock_init(&mm->page_table_lock);
 	mm_init_cpumask(mm);
 	mm_init_aio(mm);
-	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
 	clear_tlb_flush_pending(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
@@ -702,6 +694,7 @@ void mmput(struct mm_struct *mm)
 		}
 		if (mm->binfmt)
 			module_put(mm->binfmt->module);
+		mm_drop_memcg(mm);
 		mmdrop(mm);
 	}
 }
@@ -925,6 +918,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 	if (mm->binfmt && !try_module_get(mm->binfmt->module))
 		goto free_pt;
 
+	mm_set_memcg(mm, oldmm->memcg);
 	return mm;
 
 free_pt:
diff --git a/mm/debug.c b/mm/debug.c
index 3eb3ac2fcee7..d0347a168651 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -184,7 +184,7 @@ void dump_mm(const struct mm_struct *mm)
 		"ioctx_table %p\n"
 #endif
 #ifdef CONFIG_MEMCG
-		"owner %p "
+		"memcg %p "
 #endif
 		"exe_file %p\n"
 #ifdef CONFIG_MMU_NOTIFIER
@@ -218,7 +218,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm->ioctx_table,
 #endif
 #ifdef CONFIG_MEMCG
-		mm->owner,
+		mm->memcg,
 #endif
 		mm->exe_file,
 #ifdef CONFIG_MMU_NOTIFIER
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4d905209f00f..950875eb7d89 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -469,6 +469,46 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 	return mem_cgroup_from_css(css);
 }
 
+static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
+{
+	if (!p->mm)
+		return NULL;
+	return rcu_dereference(p->mm->memcg);
+}
+
+void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
+{
+	if (memcg)
+		css_get(&memcg->css);
+	rcu_assign_pointer(mm->memcg, memcg);
+}
+
+void mm_drop_memcg(struct mm_struct *mm)
+{
+	/*
+	 * This is the last reference to mm so nobody can see
+	 * this memcg
+	 */
+	if (mm->memcg)
+		css_put(&mm->memcg->css);
+}
+
+static void mm_move_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *old_memcg;
+
+	mm_set_memcg(mm, memcg);
+
+	/*
+	 * wait for all current users of the old memcg before we
+	 * release the reference.
+	 */
+	old_memcg = mm->memcg;
+	synchronize_rcu();
+	if (old_memcg)
+		css_put(&old_memcg->css);
+}
+
 /* Writing them here to avoid exposing memcg's inner layout */
 #if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
 
@@ -953,19 +993,6 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 	}
 }
 
-struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
-{
-	/*
-	 * mm_update_next_owner() may clear mm->owner to NULL
-	 * if it races with swapoff, page migration, etc.
-	 * So this can be called with p == NULL.
-	 */
-	if (unlikely(!p))
-		return NULL;
-
-	return mem_cgroup_from_css(task_css(p, memory_cgrp_id));
-}
-
 static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *memcg = NULL;
@@ -980,7 +1007,7 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 		if (unlikely(!mm))
 			memcg = root_mem_cgroup;
 		else {
-			memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+			memcg = rcu_dereference(mm->memcg);
 			if (unlikely(!memcg))
 				memcg = root_mem_cgroup;
 		}
@@ -1157,7 +1184,7 @@ void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 	struct mem_cgroup *memcg;
 
 	rcu_read_lock();
-	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	memcg = rcu_dereference(mm->memcg);
 	if (unlikely(!memcg))
 		goto out;
 
@@ -2674,7 +2701,7 @@ void __memcg_kmem_put_cache(struct kmem_cache *cachep)
 }
 
 /*
- * We need to verify if the allocation against current->mm->owner's memcg is
+ * We need to verify if the allocation against current->mm->memcg is
  * possible for the given order. But the page is not allocated yet, so we'll
  * need a further commit step to do the final arrangements.
  *
@@ -4993,6 +5020,7 @@ static bool mc_move_charge(void)
 static void mem_cgroup_clear_mc(void)
 {
 	bool move_charge = mc_move_charge();
+	struct mem_cgroup *from;
 	/*
 	 * we must clear moving_task before waking up waiters at the end of
 	 * task migration.
@@ -5000,16 +5028,21 @@ static void mem_cgroup_clear_mc(void)
 	mc.moving_task = NULL;
 	if (move_charge)
 		__mem_cgroup_clear_mc();
+
 	spin_lock(&mc.lock);
+	from = mc.from;
 	mc.from = NULL;
 	mc.to = NULL;
 	spin_unlock(&mc.lock);
+
+	/* drops the reference from mem_cgroup_can_attach */
+	css_put(&from->css);
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 				 struct cgroup_taskset *tset)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *to = mem_cgroup_from_css(css);
 	struct mem_cgroup *from;
 	struct task_struct *p;
 	struct mm_struct *mm;
@@ -5017,14 +5050,27 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	int ret = 0;
 
 	p = cgroup_taskset_first(tset);
-	from = mem_cgroup_from_task(p);
-
-	VM_BUG_ON(from == memcg);
+	if (!thread_group_leader(p))
+		return 0;
 
 	mm = get_task_mm(p);
 	if (!mm)
 		return 0;
 
+	/*
+	 * tasks' cgroup might be different from the one p->mm is associated
+	 * with because CLONE_VM is allowed without CLONE_THREAD. The task is
+	 * moving so we have to migrate from the memcg associated with its
+	 * address space.
+	 * Keep the reference until the whole migration is done - until
+	 * mem_cgroup_clear_mc
+	 */
+	from = get_mem_cgroup_from_mm(mm);
+	if (from == to) {
+		css_put(&from->css);
+		goto out;
+	}
+
 	VM_BUG_ON(mc.from);
 	VM_BUG_ON(mc.to);
 	VM_BUG_ON(mc.precharge);
@@ -5033,7 +5079,7 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 
 	spin_lock(&mc.lock);
 	mc.from = from;
-	mc.to = memcg;
+	mc.to = to;
 	mc.flags = move_flags;
 	spin_unlock(&mc.lock);
 	/* We set mc.moving_task later */
@@ -5043,14 +5089,15 @@ static int mem_cgroup_can_attach(struct cgroup_subsys_state *css,
 	 * tunable will only affect upcoming migrations, not the current one.
 	 * So we need to save it, and keep it going.
 	 */
-	move_flags = READ_ONCE(memcg->move_charge_at_immigrate);
+	move_flags = READ_ONCE(to->move_charge_at_immigrate);
 
 	/* We move charges only when we move a owner of the mm */
-	if (move_flags && mm->owner == p) {
+	if (move_flags) {
 		ret = mem_cgroup_precharge_mc(mm);
 		if (ret)
 			mem_cgroup_clear_mc();
 	}
+out:
 	mmput(mm);
 	return ret;
 }
@@ -5204,6 +5251,12 @@ static void mem_cgroup_move_task(struct cgroup_subsys_state *css,
 	struct mm_struct *mm = get_task_mm(p);
 
 	if (mm) {
+		/*
+		 * Commit to a new memcg. mc.to points to the destination
+		 * memcg even when the current charges are not moved.
+		 */
+		mm_move_memcg(mm, mc.to);
+
 		if (mc_move_charge())
 			mem_cgroup_move_charge(mm);
 		mmput(mm);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
