Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 024E06B03A2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:00 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u68so22863088qkd.20
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:04:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c40si9627542qte.118.2017.04.21.07.04.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:04:58 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 05/14] cgroup: implement cgroup v2 thread support
Date: Fri, 21 Apr 2017 10:04:03 -0400
Message-Id: <1492783452-12267-6-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

From: Tejun Heo <tj@kernel.org>

This patch implements cgroup v2 thread support.  The goal of the
thread mode is supporting hierarchical accounting and control at
thread granularity while staying inside the resource domain model
which allows coordination across different resource controllers and
handling of anonymous resource consumptions.

Once thread mode is enabled on a cgroup, the threads of the processes
which are in its subtree can be placed inside the subtree without
being restricted by process granularity or no-internal-process
constraint.  Note that the threads aren't allowed to escape to a
different threaded subtree.  To be used inside a threaded subtree, a
controller should explicitly support threaded mode and be able to
handle internal competition in the way which is appropriate for the
resource.

The root of a threaded subtree, where thread mode is enabled in the
first place, is called the thread root and serves as the resource
domain for the whole subtree.  This is the last cgroup where
non-threaded controllers are operational and where all the
domain-level resource consumptions in the subtree are accounted.  This
allows threaded controllers to operate at thread granularity when
requested while staying inside the scope of system-level resource
distribution.

Internally, in a threaded subtree, each css_set has its ->proc_cset
pointing to a matching css_set which belongs to the thread root.  This
ensures that thread root level cgroup_subsys_state for all threaded
controllers are readily accessible for domain-level operations.

This patch enables threaded mode for the pids and perf_events
controllers.  Neither has to worry about domain-level resource
consumptions and it's enough to simply set the flag.

For more details on the interface and behavior of the thread mode,
please refer to the section 2-2-2 in Documentation/cgroup-v2.txt added
by this patch.  Note that the documentation update is not complete as
the rest of the documentation needs to be updated accordingly.
Rolling those updates into this patch can be confusing so that will be
separate patches.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 Documentation/cgroup-v2.txt |  75 +++++++++++++-
 include/linux/cgroup-defs.h |  16 +++
 kernel/cgroup/cgroup.c      | 240 +++++++++++++++++++++++++++++++++++++++++++-
 kernel/cgroup/pids.c        |   1 +
 kernel/events/core.c        |   1 +
 5 files changed, 326 insertions(+), 7 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 49d7c99..2375e22 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -16,7 +16,9 @@ CONTENTS
   1-2. What is cgroup?
 2. Basic Operations
   2-1. Mounting
-  2-2. Organizing Processes
+  2-2. Organizing Processes and Threads
+    2-2-1. Processes
+    2-2-2. Threads
   2-3. [Un]populated Notification
   2-4. Controlling Controllers
     2-4-1. Enabling and Disabling
@@ -150,7 +152,9 @@ and experimenting easier, the kernel parameter cgroup_no_v1= allows
 disabling controllers in v1 and make them always available in v2.
 
 
-2-2. Organizing Processes
+2-2. Organizing Processes and Threads
+
+2-2-1. Processes
 
 Initially, only the root cgroup exists to which all processes belong.
 A child cgroup can be created by creating a sub-directory.
@@ -201,6 +205,73 @@ is removed subsequently, " (deleted)" is appended to the path.
   0::/test-cgroup/test-cgroup-nested (deleted)
 
 
+2-2-2. Threads
+
+cgroup v2 supports thread granularity for a subset of controllers to
+support use cases requiring hierarchical resource distribution across
+the threads of a group of processes.  By default, all threads of a
+process belong to the same cgroup, which also serves as the resource
+domain to host resource consumptions which are not specific to a
+process or thread.  The thread mode allows threads to be spread across
+a subtree while still maintaining the common resource domain for them.
+
+Enabling thread mode on a subtree makes it threaded.  The root of a
+threaded subtree is called thread root and serves as the resource
+domain for the entire subtree.  In a threaded subtree, threads of a
+process can be put in different cgroups and are not subject to the no
+internal process constraint - threaded controllers can be enabled on
+non-leaf cgroups whether they have threads in them or not.
+
+To enable the thread mode, the following conditions must be met.
+
+- The thread root doesn't have any child cgroups.
+
+- The thread root doesn't have any controllers enabled.
+
+Thread mode can be enabled by writing "enable" to "cgroup.threads"
+file.
+
+  # echo enable > cgroup.threads
+
+Inside a threaded subtree, "cgroup.threads" can be read and contains
+the list of the thread IDs of all threads in the cgroup.  Except that
+the operations are per-thread instead of per-process, "cgroup.threads"
+has the same format and behaves the same way as "cgroup.procs".
+
+The thread root serves as the resource domain for the whole subtree,
+and, while the threads can be scattered across the subtree, all the
+processes are considered to be in the thread root.  "cgroup.procs" in
+a thread root contains the PIDs of all processes in the subtree and is
+not readable in the subtree proper.  However, "cgroup.procs" can be
+written to from anywhere in the subtree to migrate all threads of the
+matching process to the cgroup.
+
+Only threaded controllers can be enabled in a threaded subtree.  When
+a threaded controller is enabled inside a threaded subtree, it only
+accounts for and controls resource consumptions associated with the
+threads in the cgroup and its descendants.  All consumptions which
+aren't tied to a specific thread belong to the thread root.
+
+Because a threaded subtree is exempt from no internal process
+constraint, a threaded controller must be able to handle competition
+between threads in a non-leaf cgroup and its child cgroups.  Each
+threaded controller defines how such competitions are handled.
+
+To disable the thread mode, the following conditions must be met.
+
+- The cgroup is a thread root.  Thread mode can't be disabled
+  partially in the subtree.
+
+- The thread root doesn't have any child cgroups.
+
+- The thread root doesn't have any controllers enabled.
+
+Thread mode can be disabled by writing "disable" to "cgroup.threads"
+file.
+
+  # echo disable > cgroup.threads
+
+
 2-3. [Un]populated Notification
 
 Each non-root cgroup has a "cgroup.events" file which contains
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 9283ee9..bb4752a 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -226,6 +226,10 @@ struct css_set {
 	struct cgroup *mg_dst_cgrp;
 	struct css_set *mg_dst_cset;
 
+	/* used while updating ->proc_cset to enable/disable threaded mode */
+	struct list_head pcset_preload_node;
+	struct css_set *pcset_preload;
+
 	/* dead and being drained, ignore for migration */
 	bool dead;
 
@@ -497,6 +501,18 @@ struct cgroup_subsys {
 	bool implicit_on_dfl:1;
 
 	/*
+	 * If %true, the controller, supports threaded mode on the default
+	 * hierarchy.  In a threaded subtree, both process granularity and
+	 * no-internal-process constraint are ignored and a threaded
+	 * controllers should be able to handle that.
+	 *
+	 * Note that as an implicit controller is automatically enabled on
+	 * all cgroups on the default hierarchy, it should also be
+	 * threaded.  implicit && !threaded is not supported.
+	 */
+	bool threaded:1;
+
+	/*
 	 * If %false, this subsystem is properly hierarchical -
 	 * configuration, resource accounting and restriction on a parent
 	 * cgroup cover those of its children.  If %true, hierarchy support
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index b2b1886..6748207 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -162,6 +162,9 @@ struct cgroup_subsys *cgroup_subsys[] = {
 /* some controllers are implicitly enabled on the default hierarchy */
 static u16 cgrp_dfl_implicit_ss_mask;
 
+/* some controllers can be threaded on the default hierarchy */
+static u16 cgrp_dfl_threaded_ss_mask;
+
 /* The list of hierarchy roots */
 LIST_HEAD(cgroup_roots);
 static int cgroup_root_count;
@@ -2911,11 +2914,18 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 		goto out_unlock;
 	}
 
+	/* can't enable !threaded controllers on a threaded cgroup */
+	if (cgrp->proc_cgrp && (enable & ~cgrp_dfl_threaded_ss_mask)) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
 	/*
-	 * Except for the root, subtree_control must be zero for a cgroup
-	 * with tasks so that child cgroups don't compete against tasks.
+	 * Except for root and threaded cgroups, subtree_control must be
+	 * zero for a cgroup with tasks so that child cgroups don't compete
+	 * against tasks.
 	 */
-	if (enable && cgroup_parent(cgrp)) {
+	if (enable && cgroup_parent(cgrp) && !cgrp->proc_cgrp) {
 		struct cgrp_cset_link *link;
 
 		/*
@@ -2956,6 +2966,124 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 	return ret ?: nbytes;
 }
 
+static int cgroup_enable_threaded(struct cgroup *cgrp)
+{
+	LIST_HEAD(csets);
+	struct cgrp_cset_link *link;
+	struct css_set *cset, *cset_next;
+	int ret;
+
+	lockdep_assert_held(&cgroup_mutex);
+
+	/* noop if already threaded */
+	if (cgrp->proc_cgrp)
+		return 0;
+
+	/* allow only if there are neither children or enabled controllers */
+	if (css_has_online_children(&cgrp->self) || cgrp->subtree_control)
+		return -EBUSY;
+
+	/* find all csets which need ->proc_cset updated */
+	spin_lock_irq(&css_set_lock);
+	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
+		cset = link->cset;
+		if (css_set_populated(cset)) {
+			WARN_ON_ONCE(css_set_threaded(cset));
+			WARN_ON_ONCE(cset->pcset_preload);
+
+			list_add_tail(&cset->pcset_preload_node, &csets);
+			get_css_set(cset);
+		}
+	}
+	spin_unlock_irq(&css_set_lock);
+
+	/* find the proc_csets to associate */
+	list_for_each_entry(cset, &csets, pcset_preload_node) {
+		struct css_set *pcset = find_css_set(cset, cgrp, true);
+
+		WARN_ON_ONCE(cset == pcset);
+		if (!pcset) {
+			ret = -ENOMEM;
+			goto err_put_csets;
+		}
+		cset->pcset_preload = pcset;
+	}
+
+	/* install ->proc_cset */
+	spin_lock_irq(&css_set_lock);
+	list_for_each_entry_safe(cset, cset_next, &csets, pcset_preload_node) {
+		rcu_assign_pointer(cset->proc_cset, cset->pcset_preload);
+		list_add_tail(&cset->threaded_csets_node,
+			      &cset->pcset_preload->threaded_csets);
+
+		cset->pcset_preload = NULL;
+		list_del(&cset->pcset_preload_node);
+		put_css_set_locked(cset);
+	}
+	spin_unlock_irq(&css_set_lock);
+
+	/* mark it threaded */
+	cgrp->proc_cgrp = cgrp;
+
+	return 0;
+
+err_put_csets:
+	spin_lock_irq(&css_set_lock);
+	list_for_each_entry_safe(cset, cset_next, &csets, pcset_preload_node) {
+		if (cset->pcset_preload) {
+			put_css_set_locked(cset->pcset_preload);
+			cset->pcset_preload = NULL;
+		}
+		list_del(&cset->pcset_preload_node);
+		put_css_set_locked(cset);
+	}
+	spin_unlock_irq(&css_set_lock);
+	return ret;
+}
+
+static int cgroup_disable_threaded(struct cgroup *cgrp)
+{
+	struct cgrp_cset_link *link;
+
+	lockdep_assert_held(&cgroup_mutex);
+
+	/* noop if already !threaded */
+	if (!cgrp->proc_cgrp)
+		return 0;
+
+	/* partial disable isn't supported */
+	if (cgrp->proc_cgrp != cgrp)
+		return -EBUSY;
+
+	/* allow only if there are neither children or enabled controllers */
+	if (css_has_online_children(&cgrp->self) || cgrp->subtree_control)
+		return -EBUSY;
+
+	/* walk all csets and reset ->proc_cset */
+	spin_lock_irq(&css_set_lock);
+	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
+		struct css_set *cset = link->cset;
+
+		if (css_set_threaded(cset)) {
+			struct css_set *pcset = proc_css_set(cset);
+
+			WARN_ON_ONCE(pcset->dfl_cgrp != cgrp);
+			rcu_assign_pointer(cset->proc_cset, cset);
+			list_del(&cset->threaded_csets_node);
+
+			/*
+			 * @pcset is never @cset and safe to put during
+			 * iteration.
+			 */
+			put_css_set_locked(pcset);
+		}
+	}
+	cgrp->proc_cgrp = NULL;
+	spin_unlock_irq(&css_set_lock);
+
+	return 0;
+}
+
 static int cgroup_events_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "populated %d\n",
@@ -3840,12 +3968,12 @@ static void *cgroup_procs_next(struct seq_file *s, void *v, loff_t *pos)
 	return css_task_iter_next(it);
 }
 
-static void *cgroup_procs_start(struct seq_file *s, loff_t *pos)
+static void *__cgroup_procs_start(struct seq_file *s, loff_t *pos,
+				  unsigned int iter_flags)
 {
 	struct kernfs_open_file *of = s->private;
 	struct cgroup *cgrp = seq_css(s)->cgroup;
 	struct css_task_iter *it = of->priv;
-	unsigned iter_flags = CSS_TASK_ITER_PROCS | CSS_TASK_ITER_THREADED;
 
 	/*
 	 * When a seq_file is seeked, it's always traversed sequentially
@@ -3868,6 +3996,23 @@ static void *cgroup_procs_start(struct seq_file *s, loff_t *pos)
 	return cgroup_procs_next(s, NULL, NULL);
 }
 
+static void *cgroup_procs_start(struct seq_file *s, loff_t *pos)
+{
+	struct cgroup *cgrp = seq_css(s)->cgroup;
+
+	/*
+	 * All processes of a threaded subtree are in the top threaded
+	 * cgroup.  Only threads can be distributed across the subtree.
+	 * Reject reads on cgroup.procs in the subtree proper.  They're
+	 * always empty anyway.
+	 */
+	if (cgrp->proc_cgrp && cgrp->proc_cgrp != cgrp)
+		return ERR_PTR(-EINVAL);
+
+	return __cgroup_procs_start(s, pos, CSS_TASK_ITER_PROCS |
+					    CSS_TASK_ITER_THREADED);
+}
+
 static int cgroup_procs_show(struct seq_file *s, void *v)
 {
 	seq_printf(s, "%d\n", task_pid_vnr(v));
@@ -3922,6 +4067,76 @@ static ssize_t cgroup_procs_write(struct kernfs_open_file *of,
 	return ret ?: nbytes;
 }
 
+static void *cgroup_threads_start(struct seq_file *s, loff_t *pos)
+{
+	struct cgroup *cgrp = seq_css(s)->cgroup;
+
+	if (!cgrp->proc_cgrp)
+		return ERR_PTR(-EINVAL);
+
+	return __cgroup_procs_start(s, pos, 0);
+}
+
+static ssize_t cgroup_threads_write(struct kernfs_open_file *of,
+				    char *buf, size_t nbytes, loff_t off)
+{
+	struct super_block *sb = of->file->f_path.dentry->d_sb;
+	struct cgroup *cgrp, *common_ancestor;
+	struct task_struct *task;
+	ssize_t ret;
+
+	buf = strstrip(buf);
+
+	cgrp = cgroup_kn_lock_live(of->kn, false);
+	if (!cgrp)
+		return -ENODEV;
+
+	/* cgroup.procs determines delegation, require permission on it too */
+	ret = cgroup_procs_write_permission(cgrp, sb);
+	if (ret)
+		goto out_unlock;
+
+	/* enable or disable? */
+	if (!strcmp(buf, "enable")) {
+		ret = cgroup_enable_threaded(cgrp);
+		goto out_unlock;
+	} else if (!strcmp(buf, "disable")) {
+		ret = cgroup_disable_threaded(cgrp);
+		goto out_unlock;
+	}
+
+	/* thread migration */
+	ret = -EINVAL;
+	if (!cgrp->proc_cgrp)
+		goto out_unlock;
+
+	task = cgroup_procs_write_start(buf, false);
+	ret = PTR_ERR_OR_ZERO(task);
+	if (ret)
+		goto out_unlock;
+
+	common_ancestor = cgroup_migrate_common_ancestor(task, cgrp);
+
+	/* can't migrate across disjoint threaded subtrees */
+	ret = -EACCES;
+	if (common_ancestor->proc_cgrp != cgrp->proc_cgrp)
+		goto out_finish;
+
+	/* and follow the cgroup.procs delegation rule */
+	ret = cgroup_procs_write_permission(common_ancestor, sb);
+	if (ret)
+		goto out_finish;
+
+	ret = cgroup_attach_task(cgrp, task, false);
+
+out_finish:
+	cgroup_procs_write_finish();
+out_unlock:
+	cgroup_kn_unlock(of->kn);
+
+	return ret ?: nbytes;
+}
+
 /* cgroup core interface files for the default hierarchy */
 static struct cftype cgroup_base_files[] = {
 	{
@@ -3934,6 +4149,14 @@ static ssize_t cgroup_procs_write(struct kernfs_open_file *of,
 		.write = cgroup_procs_write,
 	},
 	{
+		.name = "cgroup.threads",
+		.release = cgroup_procs_release,
+		.seq_start = cgroup_threads_start,
+		.seq_next = cgroup_procs_next,
+		.seq_show = cgroup_procs_show,
+		.write = cgroup_threads_write,
+	},
+	{
 		.name = "cgroup.controllers",
 		.seq_show = cgroup_controllers_show,
 	},
@@ -4247,6 +4470,7 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	cgrp->self.parent = &parent->self;
 	cgrp->root = root;
 	cgrp->level = level;
+	cgrp->proc_cgrp = parent->proc_cgrp;
 
 	for (tcgrp = cgrp; tcgrp; tcgrp = cgroup_parent(tcgrp))
 		cgrp->ancestor_ids[tcgrp->level] = tcgrp->id;
@@ -4689,11 +4913,17 @@ int __init cgroup_init(void)
 
 		cgrp_dfl_root.subsys_mask |= 1 << ss->id;
 
+		/* implicit controllers must be threaded too */
+		WARN_ON(ss->implicit_on_dfl && !ss->threaded);
+
 		if (ss->implicit_on_dfl)
 			cgrp_dfl_implicit_ss_mask |= 1 << ss->id;
 		else if (!ss->dfl_cftypes)
 			cgrp_dfl_inhibit_ss_mask |= 1 << ss->id;
 
+		if (ss->threaded)
+			cgrp_dfl_threaded_ss_mask |= 1 << ss->id;
+
 		if (ss->dfl_cftypes == ss->legacy_cftypes) {
 			WARN_ON(cgroup_add_cftypes(ss, ss->dfl_cftypes));
 		} else {
diff --git a/kernel/cgroup/pids.c b/kernel/cgroup/pids.c
index 2237201..9829c67 100644
--- a/kernel/cgroup/pids.c
+++ b/kernel/cgroup/pids.c
@@ -345,4 +345,5 @@ struct cgroup_subsys pids_cgrp_subsys = {
 	.free		= pids_free,
 	.legacy_cftypes	= pids_files,
 	.dfl_cftypes	= pids_files,
+	.threaded	= true,
 };
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 80cf340..095973b 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -11129,5 +11129,6 @@ struct cgroup_subsys perf_event_cgrp_subsys = {
 	 * controller is not mounted on a legacy hierarchy.
 	 */
 	.implicit_on_dfl = true,
+	.threaded	= true,
 };
 #endif /* CONFIG_CGROUP_PERF */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
