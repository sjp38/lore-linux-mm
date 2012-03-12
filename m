Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 2E1B66B004A
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 17:33:48 -0400 (EDT)
Received: by dadv6 with SMTP id v6so6469447dad.14
        for <linux-mm@kvack.org>; Mon, 12 Mar 2012 14:33:47 -0700 (PDT)
Date: Mon, 12 Mar 2012 14:33:43 -0700
From: Tejun Heo <tj@kernel.org>
Subject: [RFC REPOST] cgroup: removing css reference drain wait during
 cgroup removal
Message-ID: <20120312213343.GF23255@google.com>
References: <20120312213155.GE23255@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120312213155.GE23255@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, gthelen@google.com, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vivek Goyal <vgoyal@redhat.com>, Jens Axboe <axboe@kernel.dk>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, cgroups@vger.kernel.org

(wrong mailing list addresses, reposing. sorry guys)

Hello, guys.

While working on blkcg, I learned that cgroup removal path tries to
drain all internal references synchronously before proceeding with
removal, and may be aborted by by pre_destroy() failing.

I find both quite unusual.  While there are some occassions where we
try to drain reference counts synchronously, the norm is deactivating
the target and then releasing it when the reference count hits zero
and exposing this synchronous behavior directly to userland makes it
worse.  This also requires allowing rmdir to be aborted from userland.

pre_destroy() being allowed to veto rmdir might be okay if there's
only one subsystem using it or it implemented proper
prepare-commit/cancel transaction, but as it currently stands,
pre_destroy() operations are not reversible and even within memcg
itself the state wouldn't be consistent after failure (some moved to
parent while the rest on child).  Note that abort from userland also
has the same problem.

It also complicates and adds even more subtleties to cgroup code.  A
lot of it was just me being dumb but making sense of
cgroup_exclude_rmdir() and cgroup_release_and_wakeup_rmdir() usages in
memcontrol took me quite some time even with Hugh's help.

In general, IMHO, it's a bad idea to expose purely internal
implementation details to userland directly.  Internal ref counts can
be kept around for whatever reason (e.g. blkcg does it for lookup
caching), such details shouldn't be visible to userland.  Midlayers
like cgroup which sit between userland and mechanism implementations
should provide isolation between the two so that each mechanism
implementation doesn't have to worry about things like that.

It seems cgroup is going through a lot of the same growing pains that
sysfs went through years ago and would probably benefit from using
sysfs for userland interfacing rather than trying to replicate
features that sysfs already provides.  Well, that's another long term
thing, I guess.  For now, I'd like to make cgroup rmdir path more
conventional so that rmdir behaves like the following.

1. disallow further css_tryget() on all affected subsystems

2. call pre_destroy() on each subsystem.  pre_destroy() can't fail and
   each subsystem is responsible for guaranteeing that all reference
   counts to its css will be released in finite amount of time.

3. destroy() will be called when all css refs drop to zero.

To do this, memcg, the only current user of pre_destroy() callback,
should be modified such that

* pre_destroy() doesn't fail.  Greg helped me walking through the
  different failure paths.  Two of them seem to be from race
  conditions which just require retries (I think it's wrong to fail
  userland operation for things like this).  pre_destroy() itself may
  loop or may schedule a work item if it's expected to take a long
  time.

  The last one seems more tricky.  On destruction of cgroup, the
  charges are transferred to its parent and the parent may not have
  enough room for that.  Greg told me that this should only be a
  problem for !hierarchical case.  I think this can be dealt with by
  dumping what's left over to root cgroup with a warning message.

* cgroup_exclude_rmdir() and cgroup_release_and_wakeup_rmdir() usages.
  The pair is used to re-trigger pre_destroy() for operations which
  may add css references while rmdir is in progress.  I think the
  right thing to do is calling (directly or through a work item)
  mem_cgroup_force_empty() if the css is dead after the operation.  I
  think such change would make following the logic easier too.

I'm appending the patch for the cgroup part of the change.  It removes
good amount of complication.  I think cgroup_has_css_refs() check
should be dropped from check_for_release() but other than that it
seems to work fine with blkcg in linux-next.

If memcg's pre_destroy() can be updated as described above, I can
apply that first and then apply the following cgroup behavior change.

What do you think?  Li, how does the cgroup portion look?

Thank you.

RFC PATCH. DON'T APPLY.
---
 include/linux/cgroup.h |   41 +-------
 kernel/cgroup.c        |  225 +++++++++++++------------------------------------
 2 files changed, 69 insertions(+), 197 deletions(-)

Index: work/include/linux/cgroup.h
===================================================================
--- work.orig/include/linux/cgroup.h
+++ work/include/linux/cgroup.h
@@ -16,6 +16,7 @@
 #include <linux/prio_heap.h>
 #include <linux/rwsem.h>
 #include <linux/idr.h>
+#include <linux/workqueue.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -81,7 +82,6 @@ struct cgroup_subsys_state {
 /* bits in struct cgroup_subsys_state flags field */
 enum {
 	CSS_ROOT, /* This CSS is the root of the subsystem */
-	CSS_REMOVED, /* This CSS is dead */
 };
 
 /* Caller must verify that the css is not for root cgroup */
@@ -104,27 +104,18 @@ static inline void css_get(struct cgroup
 		__css_get(css, 1);
 }
 
-static inline bool css_is_removed(struct cgroup_subsys_state *css)
-{
-	return test_bit(CSS_REMOVED, &css->flags);
-}
-
 /*
  * Call css_tryget() to take a reference on a css if your existing
  * (known-valid) reference isn't already ref-counted. Returns false if
  * the css has been destroyed.
  */
 
+extern bool __css_tryget(struct cgroup_subsys_state *css);
 static inline bool css_tryget(struct cgroup_subsys_state *css)
 {
 	if (test_bit(CSS_ROOT, &css->flags))
 		return true;
-	while (!atomic_inc_not_zero(&css->refcnt)) {
-		if (test_bit(CSS_REMOVED, &css->flags))
-			return false;
-		cpu_relax();
-	}
-	return true;
+	return __css_tryget(css);
 }
 
 /*
@@ -132,11 +123,11 @@ static inline bool css_tryget(struct cgr
  * css_get() or css_tryget()
  */
 
-extern void __css_put(struct cgroup_subsys_state *css, int count);
+extern void __css_put(struct cgroup_subsys_state *css);
 static inline void css_put(struct cgroup_subsys_state *css)
 {
 	if (!test_bit(CSS_ROOT, &css->flags))
-		__css_put(css, 1);
+		__css_put(css);
 }
 
 /* bits in struct cgroup flags field */
@@ -211,6 +202,9 @@ struct cgroup {
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
 	spinlock_t event_list_lock;
+
+	/* Used to dput @cgroup->dentry from css_put() */
+	struct work_struct dput_work;
 };
 
 /*
@@ -408,23 +402,6 @@ int cgroup_task_count(const struct cgrou
 int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
 
 /*
- * When the subsys has to access css and may add permanent refcnt to css,
- * it should take care of racy conditions with rmdir(). Following set of
- * functions, is for stop/restart rmdir if necessary.
- * Because these will call css_get/put, "css" should be alive css.
- *
- *  cgroup_exclude_rmdir();
- *  ...do some jobs which may access arbitrary empty cgroup
- *  cgroup_release_and_wakeup_rmdir();
- *
- *  When someone removes a cgroup while cgroup_exclude_rmdir() holds it,
- *  it sleeps and cgroup_release_and_wakeup_rmdir() will wake him up.
- */
-
-void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
-void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css);
-
-/*
  * Control Group taskset, used to pass around set of tasks to cgroup_subsys
  * methods.
  */
@@ -453,7 +430,7 @@ int cgroup_taskset_size(struct cgroup_ta
 
 struct cgroup_subsys {
 	struct cgroup_subsys_state *(*create)(struct cgroup *cgrp);
-	int (*pre_destroy)(struct cgroup *cgrp);
+	void (*pre_destroy)(struct cgroup *cgrp);
 	void (*destroy)(struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
 	void (*cancel_attach)(struct cgroup *cgrp, struct cgroup_taskset *tset);
Index: work/kernel/cgroup.c
===================================================================
--- work.orig/kernel/cgroup.c
+++ work/kernel/cgroup.c
@@ -63,6 +63,8 @@
 
 #include <linux/atomic.h>
 
+#define CSS_DEAD_BIAS		INT_MIN
+
 /*
  * cgroup_mutex is the master lock.  Any modification to cgroup or its
  * hierarchy must be performed while holding it.
@@ -154,8 +156,8 @@ struct css_id {
 	 * The css to which this ID points. This pointer is set to valid value
 	 * after cgroup is populated. If cgroup is removed, this will be NULL.
 	 * This pointer is expected to be RCU-safe because destroy()
-	 * is called after synchronize_rcu(). But for safe use, css_is_removed()
-	 * css_tryget() should be used for avoiding race.
+	 * is called after synchronize_rcu(). But for safe use, css_tryget()
+	 * should be used for avoiding race.
 	 */
 	struct cgroup_subsys_state __rcu *css;
 	/*
@@ -807,39 +809,14 @@ static struct inode *cgroup_new_inode(um
 	return inode;
 }
 
-/*
- * Call subsys's pre_destroy handler.
- * This is called before css refcnt check.
- */
-static int cgroup_call_pre_destroy(struct cgroup *cgrp)
-{
-	struct cgroup_subsys *ss;
-	int ret = 0;
-
-	for_each_subsys(cgrp->root, ss)
-		if (ss->pre_destroy) {
-			ret = ss->pre_destroy(cgrp);
-			if (ret)
-				break;
-		}
-
-	return ret;
-}
-
 static void cgroup_diput(struct dentry *dentry, struct inode *inode)
 {
 	/* is dentry a directory ? if so, kfree() associated cgroup */
 	if (S_ISDIR(inode->i_mode)) {
 		struct cgroup *cgrp = dentry->d_fsdata;
 		struct cgroup_subsys *ss;
+
 		BUG_ON(!(cgroup_is_removed(cgrp)));
-		/* It's possible for external users to be holding css
-		 * reference counts on a cgroup; css_put() needs to
-		 * be able to access the cgroup after decrementing
-		 * the reference count in order to know if it needs to
-		 * queue the cgroup to be handled by the release
-		 * agent */
-		synchronize_rcu();
 
 		mutex_lock(&cgroup_mutex);
 		/*
@@ -931,33 +908,6 @@ static void cgroup_d_remove_dir(struct d
 }
 
 /*
- * A queue for waiters to do rmdir() cgroup. A tasks will sleep when
- * cgroup->count == 0 && list_empty(&cgroup->children) && subsys has some
- * reference to css->refcnt. In general, this refcnt is expected to goes down
- * to zero, soon.
- *
- * CGRP_WAIT_ON_RMDIR flag is set under cgroup's inode->i_mutex;
- */
-static DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
-
-static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
-{
-	if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
-		wake_up_all(&cgroup_rmdir_waitq);
-}
-
-void cgroup_exclude_rmdir(struct cgroup_subsys_state *css)
-{
-	css_get(css);
-}
-
-void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css)
-{
-	cgroup_wakeup_rmdir_waiter(css->cgroup);
-	css_put(css);
-}
-
-/*
  * Call with cgroup_mutex held. Drops reference counts on modules, including
  * any duplicate ones that parse_cgroupfs_options took. If this function
  * returns an error, no reference counts are touched.
@@ -1329,6 +1279,13 @@ static const struct super_operations cgr
 	.remount_fs = cgroup_remount,
 };
 
+static void cgroup_dput_fn(struct work_struct *work)
+{
+	struct cgroup *cgrp = container_of(work, struct cgroup, dput_work);
+
+	dput(cgrp->dentry);
+}
+
 static void init_cgroup_housekeeping(struct cgroup *cgrp)
 {
 	INIT_LIST_HEAD(&cgrp->sibling);
@@ -1339,6 +1296,7 @@ static void init_cgroup_housekeeping(str
 	mutex_init(&cgrp->pidlist_mutex);
 	INIT_LIST_HEAD(&cgrp->event_list);
 	spin_lock_init(&cgrp->event_list_lock);
+	INIT_WORK(&cgrp->dput_work, cgroup_dput_fn);
 }
 
 static void init_cgroup_root(struct cgroupfs_root *root)
@@ -1936,12 +1894,6 @@ int cgroup_attach_task(struct cgroup *cg
 	}
 
 	synchronize_rcu();
-
-	/*
-	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
-	 * is no longer empty.
-	 */
-	cgroup_wakeup_rmdir_waiter(cgrp);
 out:
 	if (retval) {
 		for_each_subsys(root, ss) {
@@ -2111,7 +2063,6 @@ static int cgroup_attach_proc(struct cgr
 	 * step 5: success! and cleanup
 	 */
 	synchronize_rcu();
-	cgroup_wakeup_rmdir_waiter(cgrp);
 	retval = 0;
 out_put_css_set_refs:
 	if (retval) {
@@ -3768,6 +3719,7 @@ static long cgroup_create(struct cgroup 
 			err = PTR_ERR(css);
 			goto err_destroy;
 		}
+		dget(dentry);		/* will be put on the last @css put */
 		init_cgroup_css(css, ss, cgrp);
 		if (ss->use_id) {
 			err = alloc_css_id(ss, parent, cgrp);
@@ -3809,8 +3761,10 @@ static long cgroup_create(struct cgroup 
  err_destroy:
 
 	for_each_subsys(root, ss) {
-		if (cgrp->subsys[ss->subsys_id])
+		if (cgrp->subsys[ss->subsys_id]) {
+			dput(dentry);
 			ss->destroy(cgrp);
+		}
 	}
 
 	mutex_unlock(&cgroup_mutex);
@@ -3866,70 +3820,15 @@ static int cgroup_has_css_refs(struct cg
 	return 0;
 }
 
-/*
- * Atomically mark all (or else none) of the cgroup's CSS objects as
- * CSS_REMOVED. Return true on success, or false if the cgroup has
- * busy subsystems. Call with cgroup_mutex held
- */
-
-static int cgroup_clear_css_refs(struct cgroup *cgrp)
-{
-	struct cgroup_subsys *ss;
-	unsigned long flags;
-	bool failed = false;
-	local_irq_save(flags);
-	for_each_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-		int refcnt;
-		while (1) {
-			/* We can only remove a CSS with a refcnt==1 */
-			refcnt = atomic_read(&css->refcnt);
-			if (refcnt > 1) {
-				failed = true;
-				goto done;
-			}
-			BUG_ON(!refcnt);
-			/*
-			 * Drop the refcnt to 0 while we check other
-			 * subsystems. This will cause any racing
-			 * css_tryget() to spin until we set the
-			 * CSS_REMOVED bits or abort
-			 */
-			if (atomic_cmpxchg(&css->refcnt, refcnt, 0) == refcnt)
-				break;
-			cpu_relax();
-		}
-	}
- done:
-	for_each_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
-		if (failed) {
-			/*
-			 * Restore old refcnt if we previously managed
-			 * to clear it from 1 to 0
-			 */
-			if (!atomic_read(&css->refcnt))
-				atomic_set(&css->refcnt, 1);
-		} else {
-			/* Commit the fact that the CSS is removed */
-			set_bit(CSS_REMOVED, &css->flags);
-		}
-	}
-	local_irq_restore(flags);
-	return !failed;
-}
-
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
 	struct cgroup *cgrp = dentry->d_fsdata;
 	struct dentry *d;
 	struct cgroup *parent;
-	DEFINE_WAIT(wait);
+	struct cgroup_subsys *ss;
 	struct cgroup_event *event, *tmp;
-	int ret;
 
 	/* the vfs holds both inode->i_mutex already */
-again:
 	mutex_lock(&cgroup_mutex);
 	if (atomic_read(&cgrp->count) != 0) {
 		mutex_unlock(&cgroup_mutex);
@@ -3941,52 +3840,34 @@ again:
 	}
 	mutex_unlock(&cgroup_mutex);
 
-	/*
-	 * In general, subsystem has no css->refcnt after pre_destroy(). But
-	 * in racy cases, subsystem may have to get css->refcnt after
-	 * pre_destroy() and it makes rmdir return with -EBUSY. This sometimes
-	 * make rmdir return -EBUSY too often. To avoid that, we use waitqueue
-	 * for cgroup's rmdir. CGRP_WAIT_ON_RMDIR is for synchronizing rmdir
-	 * and subsystem's reference count handling. Please see css_get/put
-	 * and css_tryget() and cgroup_wakeup_rmdir_waiter() implementation.
-	 */
-	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-
-	/*
-	 * Call pre_destroy handlers of subsys. Notify subsystems
-	 * that rmdir() request comes.
-	 */
-	ret = cgroup_call_pre_destroy(cgrp);
-	if (ret) {
-		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-		return ret;
-	}
-
 	mutex_lock(&cgroup_mutex);
 	parent = cgrp->parent;
 	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
-		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
-	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
-	if (!cgroup_clear_css_refs(cgrp)) {
-		mutex_unlock(&cgroup_mutex);
-		/*
-		 * Because someone may call cgroup_wakeup_rmdir_waiter() before
-		 * prepare_to_wait(), we need to check this flag.
-		 */
-		if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags))
-			schedule();
-		finish_wait(&cgroup_rmdir_waitq, &wait);
-		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-		if (signal_pending(current))
-			return -EINTR;
-		goto again;
+
+	/* deny new css_tryget() attempts */
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
+		WARN_ON(atomic_read(&css->refcnt) < 0);
+		atomic_add(CSS_DEAD_BIAS, &css->refcnt);
+	}
+
+	/*
+	 * No new tryget reference will be handed out.  Tell subsystems to
+	 * drain the existing references.
+	 */
+	for_each_subsys(cgrp->root, ss)
+		if (ss->pre_destroy)
+			ss->pre_destroy(cgrp);
+
+	for_each_subsys(cgrp->root, ss) {
+		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
+
+		css_put(css);
 	}
-	/* NO css_tryget() can success after here. */
-	finish_wait(&cgroup_rmdir_waitq, &wait);
-	clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 
 	raw_spin_lock(&release_list_lock);
 	set_bit(CGRP_REMOVED, &cgrp->flags);
@@ -4689,21 +4570,35 @@ static void check_for_release(struct cgr
 }
 
 /* Caller must verify that the css is not for root cgroup */
-void __css_put(struct cgroup_subsys_state *css, int count)
+bool __css_tryget(struct cgroup_subsys_state *css)
+{
+	while (1) {
+		int v, t;
+
+		v = atomic_read(&css->refcnt);
+		if (unlikely(v < 0))
+			return false;
+
+		t = atomic_cmpxchg(&css->refcnt, v, v + 1);
+		if (likely(t == v))
+			return true;
+	}
+}
+
+/* Caller must verify that the css is not for root cgroup */
+void __css_put(struct cgroup_subsys_state *css)
 {
 	struct cgroup *cgrp = css->cgroup;
 	int val;
-	rcu_read_lock();
-	val = atomic_sub_return(count, &css->refcnt);
-	if (val == 1) {
+
+	val = atomic_dec_return(&css->refcnt);
+	if (val == CSS_DEAD_BIAS) {
 		if (notify_on_release(cgrp)) {
 			set_bit(CGRP_RELEASABLE, &cgrp->flags);
 			check_for_release(cgrp);
 		}
-		cgroup_wakeup_rmdir_waiter(cgrp);
+		schedule_work(&cgrp->dput_work);
 	}
-	rcu_read_unlock();
-	WARN_ON_ONCE(val < 1);
 }
 EXPORT_SYMBOL_GPL(__css_put);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
