Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E2E035F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 04:09:54 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1399qqm022131
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Feb 2009 18:09:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 392BF45DE57
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:09:52 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C5A521EF084
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:09:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BD0911DB8069
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:09:47 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 52FFB1DB8065
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 18:09:47 +0900 (JST)
Date: Tue, 3 Feb 2009 18:08:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 6/6] cgroup: fix frequent -EBUSY at rmdir
Message-Id: <20090203180837.f04a7c07.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090203180320.9f29aa76.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090203180320.9f29aa76.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
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

Changelog: v3 ->  v4
	- fixed text.
	- adjusted to new base kernel.
	- reverted move of CGRP_ flags.
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
 include/linux/cgroup.h            |    6 ++
 kernel/cgroup.c                   |   81 +++++++++++++++++++++++++++++++-------
 mm/memcontrol.c                   |    5 +-
 4 files changed, 79 insertions(+), 19 deletions(-)

Index: mmotm-2.6.29-Feb02/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.29-Feb02.orig/include/linux/cgroup.h
+++ mmotm-2.6.29-Feb02/include/linux/cgroup.h
@@ -135,6 +135,10 @@ enum {
 	CGRP_RELEASABLE,
 	/* Control Group requires release notifications to userspace */
 	CGRP_NOTIFY_ON_RELEASE,
+	/*
+	 * A thread in rmdir() is wating for this cgroup.
+	 */
+	CGRP_WAIT_ON_RMDIR,
 };
 
 struct cgroup {
@@ -360,7 +364,7 @@ int cgroup_is_descendant(const struct cg
 struct cgroup_subsys {
 	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
 						  struct cgroup *cgrp);
-	void (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
+	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss,
 			  struct cgroup *cgrp, struct task_struct *tsk);
Index: mmotm-2.6.29-Feb02/kernel/cgroup.c
===================================================================
--- mmotm-2.6.29-Feb02.orig/kernel/cgroup.c
+++ mmotm-2.6.29-Feb02/kernel/cgroup.c
@@ -622,13 +622,18 @@ static struct inode *cgroup_new_inode(mo
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
@@ -722,6 +727,22 @@ static void cgroup_d_remove_dir(struct d
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
@@ -1316,6 +1337,12 @@ int cgroup_attach_task(struct cgroup *cg
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
 
@@ -2607,9 +2634,11 @@ static int cgroup_rmdir(struct inode *un
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
@@ -2625,17 +2654,39 @@ static int cgroup_rmdir(struct inode *un
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
@@ -3192,10 +3243,12 @@ void __css_put(struct cgroup_subsys_stat
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
Index: mmotm-2.6.29-Feb02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Feb02.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Feb02/mm/memcontrol.c
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
Index: mmotm-2.6.29-Feb02/Documentation/cgroups/cgroups.txt
===================================================================
--- mmotm-2.6.29-Feb02.orig/Documentation/cgroups/cgroups.txt
+++ mmotm-2.6.29-Feb02/Documentation/cgroups/cgroups.txt
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
+called multiple times against a cgroup.
 
 int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	       struct task_struct *task)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
