Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C29686B03A7
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:12 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id u30so22133667qtu.14
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c55si9632675qtb.120.2017.04.21.07.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:11 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 10/14] cgroup: Implement new thread mode semantics
Date: Fri, 21 Apr 2017 10:04:08 -0400
Message-Id: <1492783452-12267-11-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, Waiman Long <longman@redhat.com>

The current thread mode semantics aren't sufficient to fully support
threaded controllers like cpu. The main problem is that when thread
mode is enabled at root (mainly for performance reason), all the
non-threaded controllers cannot be supported at all.

To alleviate this problem, the roles of thread root and threaded
cgroups are now further separated. Now thread mode can only be enabled
on a non-root leaf cgroup whose parent will then become the thread
root. All the descendants of a threaded cgroup will still need to be
threaded. All the non-threaded resource will be accounted for in the
thread root. Unlike the previous thread mode, however, a thread root
can have non-threaded children where system resources like memory
can be further split down the hierarchy.

Now we could have something like

	R -- A -- B
	 \
	  T1 -- T2

where R is the thread root, A and B are non-threaded cgroups, T1 and
T2 are threaded cgroups. The cgroups R, T1, T2 form a threaded subtree
where all the non-threaded resources are accounted for in R.  The no
internal process constraint does not apply in the threaded subtree.
Non-threaded controllers need to properly handle the competition
between internal processes and child cgroups at the thread root.

This model will be flexible enough to support the need of the threaded
controllers.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/cgroup-v2.txt     |  51 +++++++----
 kernel/cgroup/cgroup-internal.h |  10 +++
 kernel/cgroup/cgroup.c          | 184 +++++++++++++++++++++++++++++++++++-----
 3 files changed, 208 insertions(+), 37 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 2375e22..4d1c24d 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -222,21 +222,32 @@ process can be put in different cgroups and are not subject to the no
 internal process constraint - threaded controllers can be enabled on
 non-leaf cgroups whether they have threads in them or not.
 
-To enable the thread mode, the following conditions must be met.
+To enable the thread mode on a cgroup, the following conditions must
+be met.
 
-- The thread root doesn't have any child cgroups.
+- The cgroup doesn't have any child cgroups.
 
-- The thread root doesn't have any controllers enabled.
+- The cgroup doesn't have any non-threaded controllers enabled.
+
+- The cgroup doesn't have any processes attached to it.
 
 Thread mode can be enabled by writing "enable" to "cgroup.threads"
 file.
 
   # echo enable > cgroup.threads
 
-Inside a threaded subtree, "cgroup.threads" can be read and contains
-the list of the thread IDs of all threads in the cgroup.  Except that
-the operations are per-thread instead of per-process, "cgroup.threads"
-has the same format and behaves the same way as "cgroup.procs".
+The parent of the threaded cgroup will become the thread root, if
+it hasn't been a thread root yet. In other word, thread mode cannot
+be enabled on the root cgroup as it doesn't have a parent cgroup. A
+thread root can have child cgroups and controllers enabled before
+becoming one.
+
+A threaded subtree includes the thread root and all the threaded child
+cgroups as well as their descendants which are all threaded cgroups.
+"cgroup.threads" can be read and contains the list of the thread
+IDs of all threads in the cgroup.  Except that the operations are
+per-thread instead of per-process, "cgroup.threads" has the same
+format and behaves the same way as "cgroup.procs".
 
 The thread root serves as the resource domain for the whole subtree,
 and, while the threads can be scattered across the subtree, all the
@@ -246,25 +257,30 @@ not readable in the subtree proper.  However, "cgroup.procs" can be
 written to from anywhere in the subtree to migrate all threads of the
 matching process to the cgroup.
 
-Only threaded controllers can be enabled in a threaded subtree.  When
-a threaded controller is enabled inside a threaded subtree, it only
-accounts for and controls resource consumptions associated with the
-threads in the cgroup and its descendants.  All consumptions which
-aren't tied to a specific thread belong to the thread root.
+Only threaded controllers can be enabled in a non-root threaded cgroup.
+When a threaded controller is enabled inside a threaded subtree,
+it only accounts for and controls resource consumptions associated
+with the threads in the cgroup and its descendants.  All consumptions
+which aren't tied to a specific thread belong to the thread root.
 
 Because a threaded subtree is exempt from no internal process
 constraint, a threaded controller must be able to handle competition
 between threads in a non-leaf cgroup and its child cgroups.  Each
 threaded controller defines how such competitions are handled.
 
+A new child cgroup created under a thread root will not be threaded.
+Thread mode has to be explicitly enabled on each of the thread root's
+children.  Descendants of a threaded cgroup, however, will always be
+threaded and that mode cannot be disabled.
+
 To disable the thread mode, the following conditions must be met.
 
-- The cgroup is a thread root.  Thread mode can't be disabled
-  partially in the subtree.
+- The cgroup is a child of a thread root.  Thread mode can't be
+  disabled partially further down the hierarchy.
 
-- The thread root doesn't have any child cgroups.
+- The cgroup doesn't have any child cgroups.
 
-- The thread root doesn't have any controllers enabled.
+- The cgroup doesn't have any threads attached to it.
 
 Thread mode can be disabled by writing "disable" to "cgroup.threads"
 file.
@@ -366,6 +382,9 @@ with any other cgroups and requires special treatment from most
 controllers.  How resource consumption in the root cgroup is governed
 is up to each controller.
 
+The threaded cgroups and the thread roots are also exempt from this
+restriction.
+
 Note that the restriction doesn't get in the way if there is no
 enabled controller in the cgroup's "cgroup.subtree_control".  This is
 important as otherwise it wouldn't be possible to create children of a
diff --git a/kernel/cgroup/cgroup-internal.h b/kernel/cgroup/cgroup-internal.h
index bea3928..8d27258 100644
--- a/kernel/cgroup/cgroup-internal.h
+++ b/kernel/cgroup/cgroup-internal.h
@@ -123,6 +123,16 @@ static inline bool notify_on_release(const struct cgroup *cgrp)
 	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 }
 
+static inline bool cgroup_is_threaded(const struct cgroup *cgrp)
+{
+	return cgrp->proc_cgrp && (cgrp->proc_cgrp != cgrp);
+}
+
+static inline bool cgroup_is_thread_root(const struct cgroup *cgrp)
+{
+	return cgrp->proc_cgrp == cgrp;
+}
+
 void put_css_set_locked(struct css_set *cset);
 
 static inline void put_css_set(struct css_set *cset)
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 3186b1f..50577c5 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -334,8 +334,13 @@ static u16 cgroup_control(struct cgroup *cgrp)
 	struct cgroup *parent = cgroup_parent(cgrp);
 	u16 root_ss_mask = cgrp->root->subsys_mask;
 
-	if (parent)
-		return parent->subtree_control;
+	if (parent) {
+		u16 ss_mask = parent->subtree_control;
+
+		if (cgroup_is_threaded(cgrp))
+			ss_mask &= cgrp_dfl_threaded_ss_mask;
+		return ss_mask;
+	}
 
 	if (cgroup_on_dfl(cgrp))
 		root_ss_mask &= ~(cgrp_dfl_inhibit_ss_mask |
@@ -348,8 +353,13 @@ static u16 cgroup_ss_mask(struct cgroup *cgrp)
 {
 	struct cgroup *parent = cgroup_parent(cgrp);
 
-	if (parent)
-		return parent->subtree_ss_mask;
+	if (parent) {
+		u16 ss_mask = parent->subtree_ss_mask;
+
+		if (cgroup_is_threaded(cgrp))
+			ss_mask &= cgrp_dfl_threaded_ss_mask;
+		return ss_mask;
+	}
 
 	return cgrp->root->subsys_mask;
 }
@@ -593,6 +603,24 @@ static bool css_set_threaded(struct css_set *cset)
 }
 
 /**
+ * threaded_children_count - returns # of threaded children
+ * @cgrp: cgroup to be tested
+ *
+ * cgroup_mutex must be held by the caller.
+ */
+static int threaded_children_count(struct cgroup *cgrp)
+{
+	struct cgroup *child;
+	int count = 0;
+
+	lockdep_assert_held(&cgroup_mutex);
+	cgroup_for_each_live_child(child, cgrp)
+		if (cgroup_is_threaded(child))
+			count++;
+	return count;
+}
+
+/**
  * cgroup_update_populated - updated populated count of a cgroup
  * @cgrp: the target cgroup
  * @populated: inc or dec populated count
@@ -2921,15 +2949,15 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 	}
 
 	/* can't enable !threaded controllers on a threaded cgroup */
-	if (cgrp->proc_cgrp && (enable & ~cgrp_dfl_threaded_ss_mask)) {
+	if (cgroup_is_threaded(cgrp) && (enable & ~cgrp_dfl_threaded_ss_mask)) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
 
 	/*
-	 * Except for root and threaded cgroups, subtree_control must be
-	 * zero for a cgroup with tasks so that child cgroups don't compete
-	 * against tasks.
+	 * Except for root, thread roots and threaded cgroups, subtree_control
+	 * must be zero for a cgroup with tasks so that child cgroups don't
+	 * compete against tasks.
 	 */
 	if (enable && cgroup_parent(cgrp) && !cgrp->proc_cgrp) {
 		struct cgrp_cset_link *link;
@@ -2977,7 +3005,9 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
 	LIST_HEAD(csets);
 	struct cgrp_cset_link *link;
 	struct css_set *cset, *cset_next;
+	struct cgroup *child;
 	int ret;
+	u16 ss_mask;
 
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -2985,14 +3015,38 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
 	if (cgrp->proc_cgrp)
 		return 0;
 
-	/* allow only if there are neither children or enabled controllers */
-	if (css_has_online_children(&cgrp->self) || cgrp->subtree_control)
+	/*
+	 * Allow only if it is not the root and there are:
+	 * 1) no children,
+	 * 2) no non-threaded controllers are enabled for the children, and
+	 * 3) no attached tasks.
+	 *
+	 * With no attached tasks, it is assumed that no css_sets will be
+	 * linked to the current cgroup. This may not be true if some dead
+	 * css_sets linger around due to task_struct leakage, for example.
+	 */
+	if (css_has_online_children(&cgrp->self) ||
+	   (cgrp->subtree_control & ~cgrp_dfl_threaded_ss_mask) ||
+	   !cgroup_parent(cgrp) || cgroup_is_populated(cgrp))
 		return -EBUSY;
 
-	/* find all csets which need ->proc_cset updated */
+	/* make the parent cgroup a thread root */
+	child = cgrp;
+	cgrp = cgroup_parent(child);
+
+	/* noop for parent if parent has already been threaded */
+	if (cgrp->proc_cgrp)
+		goto setup_child;
+
+	/*
+	 * For the parent cgroup, we need to find all csets which need
+	 * ->proc_cset updated
+	 */
 	spin_lock_irq(&css_set_lock);
 	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
 		cset = link->cset;
+		if (cset->dead)
+			continue;
 		if (css_set_populated(cset)) {
 			WARN_ON_ONCE(css_set_threaded(cset));
 			WARN_ON_ONCE(cset->pcset_preload);
@@ -3031,7 +3085,34 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
 	/* mark it threaded */
 	cgrp->proc_cgrp = cgrp;
 
-	return 0;
+setup_child:
+	ss_mask = cgroup_ss_mask(child);
+	/*
+	 * If some non-threaded controllers are enabled, they have to be
+	 * disabled.
+	 */
+	if (ss_mask & ~cgrp_dfl_threaded_ss_mask) {
+		cgroup_save_control(child);
+		child->proc_cgrp = cgrp;
+		ret = cgroup_apply_control(child);
+		cgroup_finalize_control(child, ret);
+		kernfs_activate(child->kn);
+
+		/*
+		 * If an error happen (it shouldn't), the thread mode
+		 * enablement fails, but the parent will remain as thread
+		 * root. That shouldn't be a problem as a thread root
+		 * without threaded children is not much different from
+		 * a non-threaded cgroup.
+		 */
+		WARN_ON_ONCE(ret);
+		if (ret)
+			child->proc_cgrp = NULL;
+	} else {
+		child->proc_cgrp = cgrp;
+		ret = 0;
+	}
+	return ret;
 
 err_put_csets:
 	spin_lock_irq(&css_set_lock);
@@ -3050,26 +3131,71 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
 static int cgroup_disable_threaded(struct cgroup *cgrp)
 {
 	struct cgrp_cset_link *link;
+	struct cgroup *parent = cgroup_parent(cgrp);
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	/* noop if already !threaded */
-	if (!cgrp->proc_cgrp)
-		return 0;
-
 	/* partial disable isn't supported */
-	if (cgrp->proc_cgrp != cgrp)
+	if (cgrp->proc_cgrp != parent)
 		return -EBUSY;
 
-	/* allow only if there are neither children or enabled controllers */
-	if (css_has_online_children(&cgrp->self) || cgrp->subtree_control)
+	/* noop if not a threaded cgroup */
+	if (!cgroup_is_threaded(cgrp))
+		return 0;
+
+	/*
+	 * Allow only if there are
+	 * 1) no children, and
+	 * 2) no attached tasks.
+	 *
+	 * With no attached tasks, it is assumed that no css_sets will be
+	 * linked to the current cgroup. This may not be true if some dead
+	 * css_sets linger around due to task_struct leakage, for example.
+	 */
+	if (css_has_online_children(&cgrp->self) || cgroup_is_populated(cgrp))
 		return -EBUSY;
 
-	/* walk all csets and reset ->proc_cset */
+	/*
+	 * If the cgroup has some non-threaded controllers enabled at the
+	 * subtree_control level of the parent, we need to re-enabled those
+	 * controllers.
+	 */
+	cgrp->proc_cgrp = NULL;
+	if (cgroup_ss_mask(cgrp) & ~cgrp_dfl_threaded_ss_mask) {
+		int ret;
+
+		cgrp->proc_cgrp = parent;
+		cgroup_save_control(cgrp);
+		cgrp->proc_cgrp = NULL;
+		ret = cgroup_apply_control(cgrp);
+		cgroup_finalize_control(cgrp, ret);
+		kernfs_activate(cgrp->kn);
+
+		/*
+		 * If an error happen, we abandon update to the thread root
+		 * and return the erorr.
+		 */
+		if (ret)
+			return ret;
+	}
+
+	/*
+	 * Check remaining threaded children count to see if the threaded
+	 * csets of the parent need to be removed and ->proc_cset reset.
+	 */
 	spin_lock_irq(&css_set_lock);
+
+	if (threaded_children_count(parent))
+		goto out_unlock;	/* still have threaded children left */
+
+	cgrp = parent;
 	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
 		struct css_set *cset = link->cset;
 
+		/* skip dead css_set */
+		if (cset->dead)
+			continue;
+
 		if (css_set_threaded(cset)) {
 			struct css_set *pcset = proc_css_set(cset);
 
@@ -3085,6 +3211,7 @@ static int cgroup_disable_threaded(struct cgroup *cgrp)
 		}
 	}
 	cgrp->proc_cgrp = NULL;
+out_unlock:
 	spin_unlock_irq(&css_set_lock);
 
 	return 0;
@@ -4475,7 +4602,16 @@ static struct cgroup *cgroup_create(struct cgroup *parent)
 	cgrp->self.parent = &parent->self;
 	cgrp->root = root;
 	cgrp->level = level;
-	cgrp->proc_cgrp = parent->proc_cgrp;
+
+	/*
+	 * A child cgroup created directly under a thread root will not
+	 * be threaded. Thread mode has to be explictly enabled for it.
+	 * The child cgroup will be threaded if its parent is threaded.
+	 */
+	if (cgroup_is_thread_root(parent))
+		cgrp->proc_cgrp = NULL;
+	else
+		cgrp->proc_cgrp = parent->proc_cgrp;
 
 	for (tcgrp = cgrp; tcgrp; tcgrp = cgroup_parent(tcgrp))
 		cgrp->ancestor_ids[tcgrp->level] = tcgrp->id;
@@ -4702,6 +4838,12 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		return -EBUSY;
 
 	/*
+	 * Do an implicit thread mode disable if on default hierarchy.
+	 */
+	if (cgroup_on_dfl(cgrp))
+		cgroup_disable_threaded(cgrp);
+
+	/*
 	 * Mark @cgrp and the associated csets dead.  The former prevents
 	 * further task migration and child creation by disabling
 	 * cgroup_lock_live_group().  The latter makes the csets ignored by
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
