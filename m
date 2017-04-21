Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E65756B03A0
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:04:56 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g27so21927364qte.12
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:04:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o40si9598452qto.310.2017.04.21.07.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:04:55 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 03/14] cgroup: introduce cgroup->proc_cgrp and threaded css_set handling
Date: Fri, 21 Apr 2017 10:04:01 -0400
Message-Id: <1492783452-12267-4-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

From: Tejun Heo <tj@kernel.org>

cgroup v2 is in the process of growing thread granularity support.
Once thread mode is enabled, the root cgroup of the subtree serves as
the proc_cgrp to which the processes of the subtree conceptually
belong and domain-level resource consumptions not tied to any specific
task are charged.  In the subtree, threads won't be subject to process
granularity or no-internal-task constraint and can be distributed
arbitrarily across the subtree.

This patch introduces cgroup->proc_cgrp along with threaded css_set
handling.

* cgroup->proc_cgrp is NULL if !threaded.  If threaded, points to the
  proc_cgrp (root of the threaded subtree).

* css_set->proc_cset points to self if !threaded.  If threaded, points
  to the css_set which belongs to the cgrp->proc_cgrp.  The proc_cgrp
  serves as the resource domain and needs the matching csses readily
  available.  The proc_cset holds those csses and makes them easily
  accessible.

* All threaded csets are linked on their proc_csets to enable
  iteration of all threaded tasks.

This patch adds the above but doesn't actually use them yet.  The
following patches will build on top.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup-defs.h | 22 ++++++++++++
 kernel/cgroup/cgroup.c      | 87 +++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 103 insertions(+), 6 deletions(-)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 6a3f850..9283ee9 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -158,6 +158,15 @@ struct css_set {
 	/* reference count */
 	atomic_t refcount;
 
+	/*
+	 * If not threaded, the following points to self.  If threaded, to
+	 * a cset which belongs to the top cgroup of the threaded subtree.
+	 * The proc_cset provides access to the process cgroup and its
+	 * csses to which domain level resource consumptions should be
+	 * charged.
+	 */
+	struct css_set __rcu *proc_cset;
+
 	/* the default cgroup associated with this css_set */
 	struct cgroup *dfl_cgrp;
 
@@ -183,6 +192,10 @@ struct css_set {
 	 */
 	struct list_head e_cset_node[CGROUP_SUBSYS_COUNT];
 
+	/* all csets whose ->proc_cset points to this cset */
+	struct list_head threaded_csets;
+	struct list_head threaded_csets_node;
+
 	/*
 	 * List running through all cgroup groups in the same hash
 	 * slot. Protected by css_set_lock
@@ -289,6 +302,15 @@ struct cgroup {
 	struct list_head e_csets[CGROUP_SUBSYS_COUNT];
 
 	/*
+	 * If !threaded, NULL.  If threaded, it points to the top cgroup of
+	 * the threaded subtree, on which it points to self.  Threaded
+	 * subtree is exempt from process granularity and no-internal-task
+	 * constraint.  Domain level resource consumptions which aren't
+	 * tied to a specific task should be charged to the proc_cgrp.
+	 */
+	struct cgroup *proc_cgrp;
+
+	/*
 	 * list of pidlists, up to two for each namespace (one for procs, one
 	 * for tasks); created on demand.
 	 */
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 9bbfadc..016bbc6 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -555,9 +555,11 @@ struct cgroup_subsys_state *of_css(struct kernfs_open_file *of)
  */
 struct css_set init_css_set = {
 	.refcount		= ATOMIC_INIT(1),
+	.proc_cset		= RCU_INITIALIZER(&init_css_set),
 	.tasks			= LIST_HEAD_INIT(init_css_set.tasks),
 	.mg_tasks		= LIST_HEAD_INIT(init_css_set.mg_tasks),
 	.task_iters		= LIST_HEAD_INIT(init_css_set.task_iters),
+	.threaded_csets		= LIST_HEAD_INIT(init_css_set.threaded_csets),
 	.cgrp_links		= LIST_HEAD_INIT(init_css_set.cgrp_links),
 	.mg_preload_node	= LIST_HEAD_INIT(init_css_set.mg_preload_node),
 	.mg_node		= LIST_HEAD_INIT(init_css_set.mg_node),
@@ -576,6 +578,17 @@ static bool css_set_populated(struct css_set *cset)
 	return !list_empty(&cset->tasks) || !list_empty(&cset->mg_tasks);
 }
 
+static struct css_set *proc_css_set(struct css_set *cset)
+{
+	return rcu_dereference_protected(cset->proc_cset,
+					 lockdep_is_held(&css_set_lock));
+}
+
+static bool css_set_threaded(struct css_set *cset)
+{
+	return proc_css_set(cset) != cset;
+}
+
 /**
  * cgroup_update_populated - updated populated count of a cgroup
  * @cgrp: the target cgroup
@@ -727,6 +740,8 @@ void put_css_set_locked(struct css_set *cset)
 	if (!atomic_dec_and_test(&cset->refcount))
 		return;
 
+	WARN_ON_ONCE(!list_empty(&cset->threaded_csets));
+
 	/* This css_set is dead. unlink it and release cgroup and css refs */
 	for_each_subsys(ss, ssid) {
 		list_del(&cset->e_cset_node[ssid]);
@@ -743,6 +758,11 @@ void put_css_set_locked(struct css_set *cset)
 		kfree(link);
 	}
 
+	if (css_set_threaded(cset)) {
+		list_del(&cset->threaded_csets_node);
+		put_css_set_locked(proc_css_set(cset));
+	}
+
 	kfree_rcu(cset, rcu_head);
 }
 
@@ -752,6 +772,7 @@ void put_css_set_locked(struct css_set *cset)
  * @old_cset: existing css_set for a task
  * @new_cgrp: cgroup that's being entered by the task
  * @template: desired set of css pointers in css_set (pre-calculated)
+ * @for_pcset: the comparison is for a new proc_cset
  *
  * Returns true if "cset" matches "old_cset" except for the hierarchy
  * which "new_cgrp" belongs to, for which it should match "new_cgrp".
@@ -759,7 +780,8 @@ void put_css_set_locked(struct css_set *cset)
 static bool compare_css_sets(struct css_set *cset,
 			     struct css_set *old_cset,
 			     struct cgroup *new_cgrp,
-			     struct cgroup_subsys_state *template[])
+			     struct cgroup_subsys_state *template[],
+			     bool for_pcset)
 {
 	struct list_head *l1, *l2;
 
@@ -771,6 +793,32 @@ static bool compare_css_sets(struct css_set *cset,
 	if (memcmp(template, cset->subsys, sizeof(cset->subsys)))
 		return false;
 
+	if (for_pcset) {
+		/*
+		 * We're looking for the pcset of @old_cset.  As @old_cset
+		 * doesn't have its ->proc_cset pointer set yet (we're
+		 * trying to find out what to set it to), @old_cset itself
+		 * may seem like a match here.  Explicitly exlude identity
+		 * matching.
+		 */
+		if (css_set_threaded(cset) || cset == old_cset)
+			return false;
+	} else {
+		bool is_threaded;
+
+		/*
+		 * Otherwise, @cset's threaded state should match the
+		 * default cgroup's.
+		 */
+		if (cgroup_on_dfl(new_cgrp))
+			is_threaded = new_cgrp->proc_cgrp;
+		else
+			is_threaded = old_cset->dfl_cgrp->proc_cgrp;
+
+		if (is_threaded != css_set_threaded(cset))
+			return false;
+	}
+
 	/*
 	 * Compare cgroup pointers in order to distinguish between
 	 * different cgroups in hierarchies.  As different cgroups may
@@ -823,10 +871,12 @@ static bool compare_css_sets(struct css_set *cset,
  * @old_cset: the css_set that we're using before the cgroup transition
  * @cgrp: the cgroup that we're moving into
  * @template: out param for the new set of csses, should be clear on entry
+ * @for_pcset: looking for a new proc_cset
  */
 static struct css_set *find_existing_css_set(struct css_set *old_cset,
 					struct cgroup *cgrp,
-					struct cgroup_subsys_state *template[])
+					struct cgroup_subsys_state *template[],
+					bool for_pcset)
 {
 	struct cgroup_root *root = cgrp->root;
 	struct cgroup_subsys *ss;
@@ -857,7 +907,7 @@ static struct css_set *find_existing_css_set(struct css_set *old_cset,
 
 	key = css_set_hash(template);
 	hash_for_each_possible(css_set_table, cset, hlist, key) {
-		if (!compare_css_sets(cset, old_cset, cgrp, template))
+		if (!compare_css_sets(cset, old_cset, cgrp, template, for_pcset))
 			continue;
 
 		/* This css_set matches what we need */
@@ -939,12 +989,13 @@ static void link_css_set(struct list_head *tmp_links, struct css_set *cset,
  * find_css_set - return a new css_set with one cgroup updated
  * @old_cset: the baseline css_set
  * @cgrp: the cgroup to be updated
+ * @for_pcset: looking for a new proc_cset
  *
  * Return a new css_set that's equivalent to @old_cset, but with @cgrp
  * substituted into the appropriate hierarchy.
  */
 static struct css_set *find_css_set(struct css_set *old_cset,
-				    struct cgroup *cgrp)
+				    struct cgroup *cgrp, bool for_pcset)
 {
 	struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT] = { };
 	struct css_set *cset;
@@ -959,7 +1010,7 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	/* First see if we already have a cgroup group that matches
 	 * the desired set */
 	spin_lock_irq(&css_set_lock);
-	cset = find_existing_css_set(old_cset, cgrp, template);
+	cset = find_existing_css_set(old_cset, cgrp, template, for_pcset);
 	if (cset)
 		get_css_set(cset);
 	spin_unlock_irq(&css_set_lock);
@@ -978,9 +1029,11 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 	}
 
 	atomic_set(&cset->refcount, 1);
+	RCU_INIT_POINTER(cset->proc_cset, cset);
 	INIT_LIST_HEAD(&cset->tasks);
 	INIT_LIST_HEAD(&cset->mg_tasks);
 	INIT_LIST_HEAD(&cset->task_iters);
+	INIT_LIST_HEAD(&cset->threaded_csets);
 	INIT_HLIST_NODE(&cset->hlist);
 	INIT_LIST_HEAD(&cset->cgrp_links);
 	INIT_LIST_HEAD(&cset->mg_preload_node);
@@ -1018,6 +1071,28 @@ static struct css_set *find_css_set(struct css_set *old_cset,
 
 	spin_unlock_irq(&css_set_lock);
 
+	/*
+	 * If @cset should be threaded, look up the matching proc_cset and
+	 * link them up.  We first fully initialize @cset then look for the
+	 * pcset.  It's simpler this way and safe as @cset is guaranteed to
+	 * stay empty until we return.
+	 */
+	if (!for_pcset && cset->dfl_cgrp->proc_cgrp) {
+		struct css_set *pcset;
+
+		pcset = find_css_set(cset, cset->dfl_cgrp->proc_cgrp, true);
+		if (!pcset) {
+			put_css_set(cset);
+			return NULL;
+		}
+
+		spin_lock_irq(&css_set_lock);
+		rcu_assign_pointer(cset->proc_cset, pcset);
+		list_add_tail(&cset->threaded_csets_node,
+			      &pcset->threaded_csets);
+		spin_unlock_irq(&css_set_lock);
+	}
+
 	return cset;
 }
 
@@ -2239,7 +2314,7 @@ int cgroup_migrate_prepare_dst(struct cgroup_mgctx *mgctx)
 		struct cgroup_subsys *ss;
 		int ssid;
 
-		dst_cset = find_css_set(src_cset, src_cset->mg_dst_cgrp);
+		dst_cset = find_css_set(src_cset, src_cset->mg_dst_cgrp, false);
 		if (!dst_cset)
 			goto err;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
