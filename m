Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A33326B0044
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 05:48:46 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0KAmhPm001434
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jan 2009 19:48:43 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EFC845DE51
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 19:48:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C45445DD79
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 19:48:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 545011DB8038
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 19:48:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E7BD9E18001
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 19:48:39 +0900 (JST)
Date: Tue, 20 Jan 2009 19:47:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir v2
Message-Id: <20090120194735.cc52c5e0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090114121205.1bb913aa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
	<20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
	<20090114121205.1bb913aa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009 12:12:05 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 13 Jan 2009 19:05:35 -0800
> Paul Menage <menage@google.com> wrote:
> 
> > On Tue, Jan 13, 2009 at 7:00 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >
> > > Hmm, add wait_queue to css and wake it up at css_put() ?
> > >
> > > like this ?
> > > ==
> > > __css_put()
> > > {
> > >        if (atomi_dec_return(&css->refcnt) == 1) {
> > >                if (notify_on_release(cgrp) {
> > >                        .....
> > >                }
> > >                if (someone_waiting_rmdir(css)) {
> > >                        wake_up_him().
> > >                }
> > >        }
> > > }
> > 
> > Yes, something like that. A system-wide wake queue is probably fine though.
> > 
> Ok, I'll try that.
> 

I'm not testing this. any concerns ?
==
In following situation, with memory subsystem,

	/groupA use_hierarchy==1
		/01 some tasks
		/02 some tasks
		/03 some tasks
		/04 empty

When tasks under 01/02/03 hit limit on /groupA, hierarchical reclaim
routine is triggered and the kernel walks tree under groupA.
Then, rmdir /groupA/04 fails with -EBUSY frequently because of temporal
refcnt from internal kernel.

In general. cgroup can be rmdir'd if there are no children groups and
no tasks. Frequent fails of rmdir() is not useful to users.
(And the reason for -EBUSY is unknown to users.....in most cases)

This patch tries to modify above behavior, by
	- retries if css_refcnt is got by someone.
	- add "return value" to pre_destroy() and allows subsystem to
	  say "we're really busy!"

Changelog: v1 -> v2.
	- added return value to pre_destroy().
	- removed modification to cgroup_subsys.
	- added signal_pending() check.
	- added waitqueue and avoid busy spin loop.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
Index: mmotm-2.6.29-Jan16/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.29-Jan16.orig/include/linux/cgroup.h
+++ mmotm-2.6.29-Jan16/include/linux/cgroup.h
@@ -128,6 +128,8 @@ enum {
 	CGRP_RELEASABLE,
 	/* Control Group requires release notifications to userspace */
 	CGRP_NOTIFY_ON_RELEASE,
+	/* Someone calls rmdir() and is wating for this cgroup is released */
+	CGRP_WAIT_ON_RMDIR,
 };
 
 struct cgroup {
@@ -350,7 +352,7 @@ int cgroup_is_descendant(const struct cg
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
@@ -141,6 +141,11 @@ static int notify_on_release(const struc
 	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
 }
 
+static int wakeup_on_rmdir(const struct cgroup *cgrp)
+{
+	return test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
+}
+
 /*
  * for_each_subsys() allows you to iterate on each subsystem attached to
  * an active hierarchy
@@ -572,6 +577,7 @@ static struct backing_dev_info cgroup_ba
 static void populate_css_id(struct cgroup_subsys_state *id);
 static int alloc_css_id(struct cgroup_subsys *ss,
 			struct cgroup *parent, struct cgroup *child);
+static void cgroup_rmdir_wakeup_waiters(void);
 
 static struct inode *cgroup_new_inode(mode_t mode, struct super_block *sb)
 {
@@ -591,13 +597,18 @@ static struct inode *cgroup_new_inode(mo
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
@@ -1283,6 +1294,10 @@ int cgroup_attach_task(struct cgroup *cg
 	set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
 	synchronize_rcu();
 	put_css_set(cg);
+
+	/* wake up rmdir() waiter....it should fail.*/
+	if (wakeup_on_rmdir(cgrp))
+		cgroup_rmdir_wakeup_waiters();
 	return 0;
 }
 
@@ -2446,6 +2461,8 @@ static long cgroup_create(struct cgroup 
 
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
+	if (wakeup_on_rmdir(parent))
+		cgroup_rmdir_wakeup_waiters();
 
 	return 0;
 
@@ -2561,14 +2578,23 @@ static int cgroup_clear_css_refs(struct 
 	return !failed;
 }
 
+DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
+
+static void cgroup_rmdir_wakeup_waiters(void)
+{
+	wake_up_all(&cgroup_rmdir_waitq);
+}
+
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 {
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
@@ -2580,21 +2606,42 @@ static int cgroup_rmdir(struct inode *un
 	}
 	mutex_unlock(&cgroup_mutex);
 
+	if (signal_pending(current))
+		return -EINTR;
 	/*
 	 * Call pre_destroy handlers of subsys. Notify subsystems
 	 * that rmdir() request comes.
 	 */
-	cgroup_call_pre_destroy(cgrp);
-
+	ret = cgroup_call_pre_destroy(cgrp);
+	if (ret == -EBUSY)
+		return -EBUSY;
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
+	 * case, subsystem has no referenece after pre_destroy(). But,
+	 * considering hierarchy management, some *temporal* refcnt can be hold.
+	 * To avoid returning -EBUSY, cgroup_rmdir_waitq is used. If subsys
+	 * is really busy, it should return -EBUSY at pre_destroy(). wake_up
+	 * is called when css_put() is called and it seems ready to rmdir().
+	 */
+	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
+	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
+
+	if (!cgroup_clear_css_refs(cgrp)) {
+		mutex_unlock(&cgroup_mutex);
+		schedule();
+		finish_wait(&cgroup_rmdir_waitq, &wait);
+		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
+		goto again;
+	}
+	/* NO css_tryget() can success after here. */
+	finish_wait(&cgroup_rmdir_waitq, &wait);
+	clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 
 	spin_lock(&release_list_lock);
 	set_bit(CGRP_REMOVED, &cgrp->flags);
@@ -3150,10 +3197,13 @@ void __css_put(struct cgroup_subsys_stat
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
+		if (wakeup_on_rmdir(cgrp))
+			cgroup_rmdir_wakeup_waiters();
 	}
 	rcu_read_unlock();
 }
Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
===================================================================
--- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
+++ mmotm-2.6.29-Jan16/mm/memcontrol.c
@@ -2381,11 +2381,13 @@ free_out:
 	return ERR_PTR(error);
 }
 
-static void mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
+static int mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 					struct cgroup *cont)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+
 	mem_cgroup_force_empty(mem, false);
+	return 0;
 }
 
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
