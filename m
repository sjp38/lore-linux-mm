Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D4B656B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 01:02:26 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5G52Qhs015998
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Jun 2009 14:02:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D4ABD45DE53
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 14:02:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A523E45DD70
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 14:02:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 993361DB803E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 14:02:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 44EE5E08001
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 14:02:25 +0900 (JST)
Date: Tue, 16 Jun 2009 14:00:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090616140050.4172f988.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090616114735.c7a91b8b.nishimura@mxp.nes.nec.co.jp>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
	<20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
	<20090615120213.e9a3bd1d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615171715.53743dce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616114735.c7a91b8b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jun 2009 11:47:35 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 15 Jun 2009 17:17:15 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 15 Jun 2009 12:02:13 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > I don't like implict resource move. I'll try some today. plz see it.
> > > _But_ this case just happens when swap is shared between cgroups and _very_ heavy
> > > swap-in continues very long. I don't think this is a fatal and BUG.
> > > 
> > > But ok, maybe wake-up path is not enough.
> > > 
> > Here.
> > Anyway, there is an unfortunate complexity in cgroup's rmdir() path.
> > I think this will remove all concern in
> > 	pre_destroy -> check -> start rmdir path
> > if subsys is aware of what they does.
> > Usual subsys just consider "tasks" and no extra references I hope.
> > If your test result is good, I'll post again (after merge window ?).
> > 
> Thank you for your patch.
> 
> At first, I thought this problem can be solved by this direction, but
> there is a race window yet.
> 
> The root cause of this problem is that mem.usage can be incremented
> by swap-in behavior of memcg even after it has become 0 once.
> So, mem.usage can also be incremented between cgroup_need_restart_rmdir()
> and schedule().
> I can see rmdir being locked up actually in my test.
> 
> hmm, sleeping until being waken up might not be good if we don't change
> swap-in behavior of memcg in some way.
> 
Or, invalidate all refs from swap_cgroup in force_empty().
Fixed one is attached.

Why I don't like "charge to current process" at swap-in is that a user cannot
expect how the resource usage will change. It will be random.

In this meaning, I wanted to set "owner" of file-caches. But file-caches are
used in more explict way than swap and the user can be aware of the usage
easier than swap cache.(and files are expected to be shared in its nature.)

The patch itself will require some more work.
What I feel difficut in cgroup's rmdir() is
==
	pre_destroy();   => pre_destroy() reduces css's refcnt to be 0.
	CGROUP_WAIT_ON_RMDIR is set
	if (check css's refcnt again)
	{
		sleep and retry
	}
==
css_tryget() check CSS_IS_REMOVED but CSS_IS_REMOVED is set only when
css->refcnt goes down to be 0. Hmm.

I think my patch itself is not so bad. But the scheme is dirty in general.

Thanks,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/cgroup.h |   12 ++++++++++++
 kernel/cgroup.c        |   22 ++++++++++++++++++----
 mm/memcontrol.c        |   22 ++++++++++++++++++++--
 3 files changed, 50 insertions(+), 6 deletions(-)

Index: linux-2.6.30.org/kernel/cgroup.c
===================================================================
--- linux-2.6.30.org.orig/kernel/cgroup.c
+++ linux-2.6.30.org/kernel/cgroup.c
@@ -636,6 +636,20 @@ static int cgroup_call_pre_destroy(struc
 	return ret;
 }
 
+static int cgroup_retry_rmdir(struct cgroup *cgrp)
+{
+	struct cgroup_subsys *ss;
+	int ret = 0;
+
+	for_each_subsys(cgrp->root, ss)
+		if (ss->pre_destroy) {
+			ret = ss->retry_rmdir(ss, cgrp);
+			if (ret)
+				break;
+		}
+	return ret;
+}
+
 static void free_cgroup_rcu(struct rcu_head *obj)
 {
 	struct cgroup *cgrp = container_of(obj, struct cgroup, rcu_head);
@@ -737,10 +751,9 @@ static void cgroup_d_remove_dir(struct d
  */
 DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
 
-static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
+void __cgroup_wakeup_rmdir_waiters(struct cgroup *cgrp)
 {
-	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
-		wake_up_all(&cgroup_rmdir_waitq);
+	wake_up_all(&cgroup_rmdir_waitq);
 }
 
 static int rebind_subsystems(struct cgroupfs_root *root,
@@ -2705,7 +2718,8 @@ again:
 
 	if (!cgroup_clear_css_refs(cgrp)) {
 		mutex_unlock(&cgroup_mutex);
-		schedule();
+		if (!cgroup_retry_rmdir(cgrp))
+			schedule();
 		finish_wait(&cgroup_rmdir_waitq, &wait);
 		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 		if (signal_pending(current))
Index: linux-2.6.30.org/include/linux/cgroup.h
===================================================================
--- linux-2.6.30.org.orig/include/linux/cgroup.h
+++ linux-2.6.30.org/include/linux/cgroup.h
@@ -366,6 +366,17 @@ int cgroup_task_count(const struct cgrou
 int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
 
 /*
+ * Wake up rmdir() waiter if the subsys requires to call pre_destroy() again to
+ * make css's refcnt to be 0 and allow rmdir() go ahead.
+ */
+void __cgroup_wakeup_rmdir_waiters(struct cgroup *cgrp);
+static inline void cgroup_wakeup_rmdir_waiters(struct cgroup *cgrp)
+{
+	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
+		__cgroup_wakeup_rmdir_waiters(cgrp);
+}
+
+/*
  * Control Group subsystem type.
  * See Documentation/cgroups/cgroups.txt for details
  */
@@ -374,6 +385,7 @@ struct cgroup_subsys {
 	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
 						  struct cgroup *cgrp);
 	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
+	int (*rmdir_retry)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss,
 			  struct cgroup *cgrp, struct task_struct *tsk);
Index: linux-2.6.30.org/mm/memcontrol.c
===================================================================
--- linux-2.6.30.org.orig/mm/memcontrol.c
+++ linux-2.6.30.org/mm/memcontrol.c
@@ -1367,8 +1367,12 @@ __mem_cgroup_commit_charge_swapin(struct
 		}
 		rcu_read_unlock();
 	}
-	/* add this page(page_cgroup) to the LRU we want. */
-
+	/*
+	 * At swap-in, it's not guaranteed that "ptr" includes a task and
+	 * some thread may be waiting for rmdir(). Wake it up and allow to
+	 * retry pre_destroy();
+	 */
+	cgroup_wakeup_rmdir_waiters(ptr->css.cgroup);
 }
 
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
@@ -2462,6 +2466,18 @@ static int mem_cgroup_pre_destroy(struct
 	return mem_cgroup_force_empty(mem, false);
 }
 
+static int mem_cgroup_retry_rmdir(struct cgroup_subsys *ss,
+				  struct cgroup *cont)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	unsigned long long usage;
+
+	usage = res_counter_read_u64(&mem->res, RES_USAGE);
+	if (usage) /* some chagers after pre_destroy() */
+		return 1;
+	return 0;
+}
+
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
@@ -2496,11 +2512,13 @@ static void mem_cgroup_move_task(struct 
 	mutex_unlock(&memcg_tasklist);
 }
 
+
 struct cgroup_subsys mem_cgroup_subsys = {
 	.name = "memory",
 	.subsys_id = mem_cgroup_subsys_id,
 	.create = mem_cgroup_create,
 	.pre_destroy = mem_cgroup_pre_destroy,
+	.retry_rmdir = mem_cgroup_retry_rmdir,
 	.destroy = mem_cgroup_destroy,
 	.populate = mem_cgroup_populate,
 	.attach = mem_cgroup_move_task,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
