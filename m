Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 753088D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 00:33:12 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E87733EE0C3
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:33:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFBA745DE4E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:33:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 89FF545DE55
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:33:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B3801DB803E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:33:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 395A31DB8038
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:33:05 +0900 (JST)
Date: Wed, 23 Mar 2011 13:26:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 1/3] forkbomb: introduce mm recorder
Message-Id: <20110323132637.85745f68.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110323132323.f223fc6d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110323132323.f223fc6d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rientjes@google.com" <rientjes@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, avagin@openvz.org, kirill@shutemov.name

One of famous fork-bomb which is hard to catch is a forkbomb
which includes exit(). For example, a shell script
can cause fork bomb
== (from wikipedia)
  #!/bin/bash
  forkbomb(){ forkbomb|forkbomb & } ; forkbomb
==
In this program, when oom happens, most of root tasks of forkbomb are
already dead (children becomes orphan).So, its hard to track all tasks
for kernel.

This patch implements a link between mm_struct. It doesn't disapear until all
children of task are dead even if the task is dead and mm_struct are freed.
(This can cause leak of memory, following patch will add some aging.)

Fork-Bomb killer in following patch just allows one trial at the moment
So, This patch uses a kind of read-write lock
Write v.s. Write is guarded by small spin locks
Write v.s. Scanning is guarded by a big lock, with support of percpu.

This patch is a part of patches and includes
  - hooks for fork/exit/exec
  - structure definition
  - add/delete code
  - scan code.
  - Kconfig.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/exec.c                |    1 
 include/linux/mm_types.h |    3 
 include/linux/oom.h      |   37 ++++++++
 kernel/fork.c            |    2 
 mm/Kconfig               |   13 +++
 mm/oom_kill.c            |  201 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 257 insertions(+)

Index: mm-work/include/linux/mm_types.h
===================================================================
--- mm-work.orig/include/linux/mm_types.h
+++ mm-work/include/linux/mm_types.h
@@ -317,6 +317,9 @@ struct mm_struct {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
+#ifdef CONFIG_FORKBOMB_KILLER
+	struct mm_record *record;
+#endif
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
Index: mm-work/include/linux/oom.h
===================================================================
--- mm-work.orig/include/linux/oom.h
+++ mm-work/include/linux/oom.h
@@ -25,6 +25,43 @@
 #include <linux/types.h>
 #include <linux/nodemask.h>
 
+/*
+ * For tracking where the task comes from. This will be
+ * used by fork-bomb detection. This tracks tasks even after dead.
+ * This struct is per-mm, not per task.
+ */
+
+#ifdef CONFIG_FORKBOMB_KILLER
+struct mm_record {
+	spinlock_t		lock;
+	struct mm_struct	*mm;	/* NULL if process is not alive. */
+	struct mm_record	*parent;
+	struct list_head	siblings;
+	struct list_head	children;
+	/* A memo for fork-bomb detection */
+	unsigned int		oom_score;
+	unsigned int		oom_family;
+	unsigned long		start_time;
+	char			need_to_kill;
+};
+extern void record_mm(struct mm_struct *new, struct mm_struct *parent);
+extern void del_mm_record(struct mm_struct *mm);
+extern void mm_record_exec(struct mm_struct *mm, struct mm_struct *old);
+#else
+static inline
+void record_mm(struct mm_struct *new, struct mm_struct *parent)
+{
+}
+static inline void del_mm_record(struct mm_struct *mm)
+{
+}
+static inline mm_record_exec(struct mm_struct *new, struct mm_struct *old)
+{
+}
+#endif
+
+
+
 struct zonelist;
 struct notifier_block;
 struct mem_cgroup;
Index: mm-work/kernel/fork.c
===================================================================
--- mm-work.orig/kernel/fork.c
+++ mm-work/kernel/fork.c
@@ -566,6 +566,7 @@ void mmput(struct mm_struct *mm)
 			spin_unlock(&mmlist_lock);
 		}
 		put_swap_token(mm);
+		del_mm_record(mm);
 		if (mm->binfmt)
 			module_put(mm->binfmt->module);
 		mmdrop(mm);
@@ -705,6 +706,7 @@ struct mm_struct *dup_mm(struct task_str
 
 	if (mm->binfmt && !try_module_get(mm->binfmt->module))
 		goto free_pt;
+	record_mm(mm, oldmm);
 
 	return mm;
 
Index: mm-work/mm/Kconfig
===================================================================
--- mm-work.orig/mm/Kconfig
+++ mm-work/mm/Kconfig
@@ -340,6 +340,19 @@ choice
 	  benefit.
 endchoice
 
+config FORKBOMB_KILLER
+	bool "Enable fork-bomb-killer, a serial killer in OOM"
+	default n
+	help
+	  When forkbomb happens, it's hard to recover because the speed of
+          fork() is much faster than killing and OOM-Killer just kills a
+          child per a oom. This forkbomb-killer tries to detect there is
+	  a forkbomb and kill it if find. Because this is based on heuristics,
+          this may kill a family of memory eating tasks which is not a bomb.
+	  And this adds some overhead to track memory usage by bomb.
+	  please set 'y' if you are a brave.
+
+
 #
 # UP and nommu archs use km based percpu allocator
 #
Index: mm-work/mm/oom_kill.c
===================================================================
--- mm-work.orig/mm/oom_kill.c
+++ mm-work/mm/oom_kill.c
@@ -31,12 +31,213 @@
 #include <linux/memcontrol.h>
 #include <linux/mempolicy.h>
 #include <linux/security.h>
+#include <linux/cpu.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks = 1;
 static DEFINE_SPINLOCK(zone_scan_lock);
 
+#ifdef CONFIG_FORKBOMB_KILLER
+struct mm_record init_rec = {
+	.lock = __SPIN_LOCK_UNLOCKED(init_rec.lock),
+	.siblings = LIST_HEAD_INIT(init_rec.siblings),
+	.children = LIST_HEAD_INIT(init_rec.children),
+};
+
+struct mm_record_info {
+	int	scan_lock; /* set to 1 while someone scanning */
+};
+DEFINE_PER_CPU(struct mm_record_info, pcpu_rec_info);
+static DEFINE_MUTEX(oom_rec_scan_mutex);
+static DECLARE_WAIT_QUEUE_HEAD(oom_rec_scan_waitq);
+
+/*
+ * When running scan, it's better to have lock to disable
+ * add/remove entry,...rather than lockless approach.
+ * We do this by per cpu count + mutex.
+ */
+
+static void mm_rec_lock(void)
+{
+	DEFINE_WAIT(wait);
+retry:
+	rcu_read_lock(); /* Using rcu just for synchronization. */
+	if (this_cpu_read(pcpu_rec_info.scan_lock)) {
+		prepare_to_wait(&oom_rec_scan_waitq,
+				&wait, TASK_UNINTERRUPTIBLE);
+		rcu_read_unlock();
+		if (this_cpu_read(pcpu_rec_info.scan_lock))
+			schedule();
+		finish_wait(&oom_rec_scan_waitq, &wait);
+		goto retry;
+	}
+}
+
+static void mm_rec_unlock(void)
+{
+	rcu_read_unlock();
+}
+
+/* Only one scanner is allowed */
+static void mm_rec_scan_lock(void)
+{
+	int cpu;
+	mutex_lock(&oom_rec_scan_mutex);
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct mm_record_info *info = &per_cpu(pcpu_rec_info, cpu);
+		info->scan_lock = 1;
+	}
+	put_online_cpus();
+	synchronize_rcu();
+}
+
+static void mm_rec_scan_unlock(void)
+{
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu) {
+		struct mm_record_info *info = &per_cpu(pcpu_rec_info, cpu);
+		info->scan_lock = 0;
+	}
+	put_online_cpus();
+	wake_up_all(&oom_rec_scan_waitq);
+	mutex_unlock(&oom_rec_scan_mutex);
+}
+
+void record_mm(struct mm_struct *new, struct mm_struct *parent)
+{
+	struct mm_record *rec, *prec;
+
+	rec = kmalloc(sizeof(*rec), GFP_KERNEL);
+	if (!rec) {
+		new->record = NULL;
+		return;
+	}
+	spin_lock_init(&rec->lock);
+	INIT_LIST_HEAD(&rec->children);
+	rec->mm = new;
+	/* task can be freed before mm...then we just record pid. */
+	mm_rec_lock();
+	rec->start_time = jiffies;
+	if (parent)
+		prec = parent->record;
+	else
+		prec = NULL;
+	if (!prec)
+		prec = &init_rec;
+	new->record = rec;
+	rec->parent = prec; /* never cleared */
+
+	spin_lock(&prec->lock);
+	list_add_tail(&rec->siblings, &prec->children);
+	spin_unlock(&prec->lock);
+	mm_rec_unlock();
+	return;
+}
+
+void del_mm_record(struct mm_struct *mm)
+{
+	struct mm_record *rec = mm->record;
+	bool nochild = false;
+
+	if (!rec) /* happens after exec() */
+		return;
+	mm_rec_lock();
+	spin_lock(&rec->lock);
+	rec->mm = NULL;
+	if (list_empty(&rec->children))
+		nochild = true;
+	mm->record = NULL;
+	spin_unlock(&rec->lock);
+	while (nochild && rec != &init_rec) {
+		struct mm_record *prec;
+
+		nochild = false;
+		prec = rec->parent;
+		spin_lock(&prec->lock);
+		list_del(&rec->siblings);
+		if (prec->mm == NULL && list_empty(&prec->children))
+			nochild = true;
+		spin_unlock(&prec->lock);
+		kfree(rec);
+		rec = prec;
+	}
+	mm_rec_unlock();
+}
+
+void mm_record_exec(struct mm_struct *new, struct mm_struct *old)
+{
+	/*
+	 * This means there is a redundant link at exec because
+	 * "old" will be droppped after this.
+	 * But this is required for handle vfork().
+	 */
+	record_mm(new, old);
+}
+
+/* Because we have global scan lock, we need no lock at scaning. */
+static struct mm_record* __first_child(struct mm_record *p)
+{
+	if (list_empty(&p->children))
+		return NULL;
+	return list_first_entry(&p->children, struct mm_record, siblings);
+}
+
+static struct mm_record* __next_sibling(struct mm_record *p)
+{
+	if (p->siblings.next == &p->parent->children)
+		return NULL;
+	return list_first_entry(&p->siblings, struct mm_record, siblings);
+}
+
+static struct mm_record *first_deepest_child(struct mm_record *p)
+{
+	struct mm_record *tmp;
+
+	do {
+		tmp =  __first_child(p);
+		if (!tmp)
+			return p;
+		p = tmp;
+	} while (1);
+}
+
+static struct mm_record *mm_record_scan_start(struct mm_record *rec)
+{
+	return first_deepest_child(rec);
+}
+
+static struct mm_record *mm_record_scan_next(struct mm_record *pos)
+{
+	struct mm_record *tmp;
+
+	tmp = __next_sibling(pos);
+	if (!tmp)
+		return pos->parent;
+	pos = tmp;
+	pos = first_deepest_child(pos);
+	return pos;
+}
+
+/*
+ * scan leaf children first and visit parent, ancestors.
+ * rcu_read_lock() must be held.
+ */
+#define for_each_mm_record(pos)\
+	for (pos = mm_record_scan_start(&init_rec);\
+		pos != &init_rec;\
+		pos = mm_record_scan_next(pos))
+
+#define for_each_mm_record_under(pos, root)\
+	for (pos = mm_record_scan_start(root);\
+		pos != root;\
+		pos = mm_record_scan_next(pos))
+
+#endif
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
Index: mm-work/fs/exec.c
===================================================================
--- mm-work.orig/fs/exec.c
+++ mm-work/fs/exec.c
@@ -801,6 +801,7 @@ static int exec_mmap(struct mm_struct *m
 		atomic_inc(&tsk->mm->oom_disable_count);
 	}
 	task_unlock(tsk);
+	mm_record_exec(mm, old_mm);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
 		up_read(&old_mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
