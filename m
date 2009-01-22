Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D4FB76B0047
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 04:41:27 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0M9fNUv002518
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jan 2009 18:41:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83F8E45DD7A
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:41:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6013045DD76
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:41:23 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46D23E08004
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:41:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD4371DB803E
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:41:22 +0900 (JST)
Date: Thu, 22 Jan 2009 18:40:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [FIX][PATCH 6/7] cgroup/memcg: fix frequent -EBUSY at rmdir
Message-Id: <20090122184018.5cd3c3b9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In following situation, with memory subsystem,

	/groupA use_hierarchy==1
		/01 some tasks
		/02 some tasks
		/03 some tasks
		/04 empty

When tasks under 01/02/03 hit limit on /groupA, hierarchical reclaim
is triggered and the kernel walks tree under groupA. In this case,
rmdir /groupA/04 fails with -EBUSY frequently because of temporal
refcnt from the kernel.

In general. cgroup can be rmdir'd if there are no children groups and
no tasks. Frequent fails of rmdir() is not useful to users.
(And the reason for -EBUSY is unknown to users.....in most cases)

This patch tries to modify above behavior, by
	- retries if css_refcnt is got by someone.
	- add "return value" to pre_destroy() and allows subsystem to
	  say "we're really busy!"

Changelog: v2 -> v3.
	- moved CGRP_ flags to cgroup.c
	- unified test function and wake up function.
	- check signal_pending() after wake up.
	- Modified documentation about pre_destroy().
Changelog: v1 -> v2.
	- added return value to pre_destroy().
	- removed modification to cgroup_subsys.
	- added signal_pending() check.
	- added waitqueue and avoid busy spin loop.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 Documentation/cgroups/cgroups.txt |    6 +-
 include/linux/cgroup.h            |   16 +-----
 kernel/cgroup.c                   |   97 ++++++++++++++++++++++++++++++++------
 mm/memcontrol.c                   |    5 +
 4 files changed, 93 insertions(+), 31 deletions(-)

Index: mmotm-2.6.29-Jan16/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.29-Jan16.orig/include/linux/cgroup.h
+++ mmotm-2.6.29-Jan16/include/linux/cgroup.h
@@ -119,19 +119,9 @@ static inline void css_put(struct cgroup
 		__css_put(css);
 }
 
-/* bits in struct cgroup flags field */
-enum {
-	/* Control Group is dead */
-	CGRP_REMOVED,
-	/* Control Group has previously had a child cgroup or a task,
-	 * but no longer (only if CGRP_NOTIFY_ON_RELEASE is set) */
-	CGRP_RELEASABLE,
-	/* Control Group requires release notifications to userspace */
-	CGRP_NOTIFY_ON_RELEASE,
-};
-
 struct cgroup {
-	unsigned long flags;		/* "unsigned long" so bitops work */
+	/* "unsigned long" so bitops work. See CGRP_ flags in cgroup.c */
+	unsigned long flags;
 
 	/* count users of this cgroup. >0 means busy, but doesn't
 	 * necessarily indicate the number of tasks in the
@@ -350,7 +340,7 @@ int cgroup_is_descendant(const struct cg
 struct cgroup_subsys {
 	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
 						  struct cgroup *cgrp);
-	void (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
+	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss,
 			  struct cgroup *cgrp, struct task_struct *tsk);
Index: mmotm-2.6.29-Jan16/kernel/cgroup.c
===================================================================
--- mmotm-2.6.29-Jan16.orig/kernel/cgroup.c
+++ mmotm-2.6.29-Jan16/kernel/cgroup.c
@@ -94,6 +94,22 @@ struct cgroupfs_root {
 	char release_agent_path[PATH_MAX];
 };
 
+/* bits in struct cgroup flags field */
+enum {
+	/* Control Group is dead */
+	CGRP_REMOVED,
+	/* Control Group has previously had a child cgroup or a task,
+	 * but no longer (only if CGRP_NOTIFY_ON_RELEASE is set) */
+	CGRP_RELEASABLE,
+	/* Control Group requires release notifications to userspace */
+	CGRP_NOTIFY_ON_RELEASE,
+	/*
+	 * A thread in rmdir() is waiting to destroy this cgroup
+	 * See wake_up_rmdir_waiters().
+	 */
+	CGRP_WAIT_ON_RMDIR,
+};
+
 /*
  * The "rootnode" hierarchy is the "dummy hierarchy", reserved for the
  * subsystems that are otherwise unattached - it never has more than a
@@ -622,13 +638,18 @@ static struct inode *cgroup_new_inode(mo
  * Call subsys's pre_destroy handler.
  * This is called before css refcnt check.
  */
-static void cgroup_call_pre_destroy(struct cgroup *cgrp)
+static int cgroup_call_pre_destroy(struct cgroup *cgrp)
 {
 	struct cgroup_subsys *ss;
+	int ret = 0;
+
 	for_each_subsys(cgrp->root, ss)
-		if (ss->pre_destroy)
-			ss->pre_destroy(ss, cgrp);
-	return;
+		if (ss->pre_destroy) {
+			ret = ss->pre_destroy(ss, cgrp);
+			if (ret)
+				break;
+		}
+	return ret;
 }
 
 static void free_cgroup_rcu(struct rcu_head *obj)
@@ -722,6 +743,22 @@ static void cgroup_d_remove_dir(struct d
 	remove_dir(dentry);
 }
 
+/*
+ * A queue for waiters to do rmdir() cgroup. A tasks will sleep when
+ * cgroup->count == 0 && list_empty(&cgroup->children) && subsys has some
+ * reference to css->refcnt. In general, this refcnt is expected to goes down
+ * to zero, soon.
+ *
+ * CGRP_WAIT_ON_RMDIR flag is modified under cgroup's inode->i_mutex;
+ */
+DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
+
+static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
+{
+	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
+		wake_up_all(&cgroup_rmdir_waitq);
+}
+
 static int rebind_subsystems(struct cgroupfs_root *root,
 			      unsigned long final_bits)
 {
@@ -1314,6 +1351,12 @@ int cgroup_attach_task(struct cgroup *cg
 	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
 	synchronize_rcu();
 	put_css_set(cg);
+
+	/*
+	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
+	 * is no longer empty.
+	 */
+	cgroup_wakeup_rmdir_waiters(cgrp);
 	return 0;
 }
 
@@ -2602,9 +2645,11 @@ static int cgroup_rmdir(struct inode *un
 	struct cgroup *cgrp = dentry->d_fsdata;
 	struct dentry *d;
 	struct cgroup *parent;
+	DEFINE_WAIT(wait);
+	int ret;
 
 	/* the vfs holds both inode->i_mutex already */
-
+again:
 	mutex_lock(&cgroup_mutex);
 	if (atomic_read(&cgrp->count) != 0) {
 		mutex_unlock(&cgroup_mutex);
@@ -2620,17 +2665,39 @@ static int cgroup_rmdir(struct inode *un
 	 * Call pre_destroy handlers of subsys. Notify subsystems
 	 * that rmdir() request comes.
 	 */
-	cgroup_call_pre_destroy(cgrp);
+	ret = cgroup_call_pre_destroy(cgrp);
+	if (ret)
+		return ret;
 
 	mutex_lock(&cgroup_mutex);
 	parent = cgrp->parent;
-
-	if (atomic_read(&cgrp->count)
-	    || !list_empty(&cgrp->children)
-	    || !cgroup_clear_css_refs(cgrp)) {
+	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
 		mutex_unlock(&cgroup_mutex);
 		return -EBUSY;
 	}
+	/*
+	 * css_put/get is provided for subsys to grab refcnt to css. In typical
+	 * case, subsystem has no reference after pre_destroy(). But, under
+	 * hierarchy management, some *temporal* refcnt can be hold.
+	 * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
+	 * is really busy, it should return -EBUSY at pre_destroy(). wake_up
+	 * is called when css_put() is called and refcnt goes down to 0.
+	 */
+	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
+	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
+
+	if (!cgroup_clear_css_refs(cgrp)) {
+		mutex_unlock(&cgroup_mutex);
+		schedule();
+		finish_wait(&cgroup_rmdir_waitq, &wait);
+		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
+		if (signal_pending(current))
+			return -EINTR;
+		goto again;
+	}
+	/* NO css_tryget() can success after here. */
+	finish_wait(&cgroup_rmdir_waitq, &wait);
+	clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 
 	spin_lock(&release_list_lock);
 	set_bit(CGRP_REMOVED, &cgrp->flags);
@@ -3186,10 +3253,12 @@ void __css_put(struct cgroup_subsys_stat
 {
 	struct cgroup *cgrp = css->cgroup;
 	rcu_read_lock();
-	if ((atomic_dec_return(&css->refcnt) == 1) &&
-	    notify_on_release(cgrp)) {
-		set_bit(CGRP_RELEASABLE, &cgrp->flags);
-		check_for_release(cgrp);
+	if (atomic_dec_return(&css->refcnt) == 1) {
+		if (notify_on_release(cgrp)) {
+			set_bit(CGRP_RELEASABLE, &cgrp->flags);
+			check_for_release(cgrp);
+		}
+		cgroup_wakeup_rmdir_waiters(cgrp);
 	}
 	rcu_read_unlock();
 }
Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Jan16/mm/memcontrol.c
@@ -2371,11 +2371,12 @@ free_out:
 	return ERR_PTR(error);
 }
 
-static void mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
+static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
-	mem_cgroup_force_empty(mem, false);
+
+	return mem_cgroup_force_empty(mem, false);
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
Index: mmotm-2.6.29-Jan16/Documentation/cgroups/cgroups.txt
===================================================================
--- mmotm-2.6.29-Jan16.orig/Documentation/cgroups/cgroups.txt
+++ mmotm-2.6.29-Jan16/Documentation/cgroups/cgroups.txt
@@ -478,11 +478,13 @@ cgroup->parent is still valid. (Note - c
 newly-created cgroup if an error occurs after this subsystem's
 create() method has been called for the new cgroup).
 
-void pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
+int pre_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
 
 Called before checking the reference count on each subsystem. This may
 be useful for subsystems which have some extra references even if
-there are not tasks in the cgroup.
+there are not tasks in the cgroup. If pre_destroy() returns error code,
+rmdir() will fail with it. From this behavior, pre_destroy() can be
+called plural times against a cgroup.
 
 int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	       struct task_struct *task)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
