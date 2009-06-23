Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BDC5A6B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 03:10:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N7ATXM013169
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Jun 2009 16:10:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CA4945DE70
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:10:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34CAD45DE6E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:10:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 16D7F1DB8045
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:10:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A9C8D1DB803B
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:10:28 +0900 (JST)
Date: Tue, 23 Jun 2009 16:08:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] memcg: cgroup fix rmdir hang
Message-Id: <20090623160854.93abeecb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, cgroup has a logic to wait until ready-to-rmdir for avoiding
frequent -EBUSY at rmdir.
 (See Commit ec64f51545fffbc4cb968f0cea56341a4b07e85a
  cgroup: fix frequent -EBUSY at rmdir.

Nishimura-san reported bad case for waiting and This is a fix to
make it reliable. A thread waiting for thread cannot be waken up
when a refcnt gotten by css_tryget() isn't put immediately.
(Original code assumed css_put() will be called soon.)

memcg has this case and this is a fix for the problem. This adds
retry_rmdir() callback to subsys and check we can sleep or not.

Note: another solution will be adding "rmdir state" to subsys.
But it will be much complicated than this do-enough-check solution.

Changelog v1 -> v2:
 - splitted into 2 patches. This just includes retry_rmdir() modification.

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/cgroups/cgroups.txt |   11 +++++++++++
 include/linux/cgroup.h            |    1 +
 kernel/cgroup.c                   |   20 +++++++++++++++++++-
 mm/memcontrol.c                   |   14 ++++++++++++--
 4 files changed, 43 insertions(+), 3 deletions(-)

Index: fix-rmdir-cgroup/include/linux/cgroup.h
===================================================================
--- fix-rmdir-cgroup.orig/include/linux/cgroup.h
+++ fix-rmdir-cgroup/include/linux/cgroup.h
@@ -374,6 +374,7 @@ struct cgroup_subsys {
 	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
 						  struct cgroup *cgrp);
 	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
+	int (*retry_rmdir)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss,
 			  struct cgroup *cgrp, struct task_struct *tsk);
Index: fix-rmdir-cgroup/kernel/cgroup.c
===================================================================
--- fix-rmdir-cgroup.orig/kernel/cgroup.c
+++ fix-rmdir-cgroup/kernel/cgroup.c
@@ -636,6 +636,23 @@ static int cgroup_call_pre_destroy(struc
 		}
 	return ret;
 }
+/*
+ * Call subsys's retry_rmdir() handler. If this returns non-Zero, we retry
+ * rmdir immediately and call pre_destroy again.
+ */
+static int cgroup_check_retry_rmdir(struct cgroup *cgrp)
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
 
 static void free_cgroup_rcu(struct rcu_head *obj)
 {
@@ -2722,7 +2739,8 @@ again:
 
 	if (!cgroup_clear_css_refs(cgrp)) {
 		mutex_unlock(&cgroup_mutex);
-		schedule();
+		if (!cgroup_check_retry_rmdir(cgrp))
+			schedule();
 		finish_wait(&cgroup_rmdir_waitq, &wait);
 		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
 		if (signal_pending(current))
Index: fix-rmdir-cgroup/mm/memcontrol.c
===================================================================
--- fix-rmdir-cgroup.orig/mm/memcontrol.c
+++ fix-rmdir-cgroup/mm/memcontrol.c
@@ -1457,8 +1457,6 @@ __mem_cgroup_commit_charge_swapin(struct
 		}
 		rcu_read_unlock();
 	}
-	/* add this page(page_cgroup) to the LRU we want. */
-
 }
 
 void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
@@ -2571,6 +2569,17 @@ static int mem_cgroup_pre_destroy(struct
 	return mem_cgroup_force_empty(mem, false);
 }
 
+static int mem_cgroup_retry_rmdir(struct cgroup_subsys *ss,
+				  struct cgroup *cont)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+
+	if (res_counter_read_u64(&mem->res, RES_USAGE))
+		return 1;
+	return 0;
+}
+
+
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
@@ -2610,6 +2619,7 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.subsys_id = mem_cgroup_subsys_id,
 	.create = mem_cgroup_create,
 	.pre_destroy = mem_cgroup_pre_destroy,
+	.retry_rmdir = mem_cgroup_retry_rmdir,
 	.destroy = mem_cgroup_destroy,
 	.populate = mem_cgroup_populate,
 	.attach = mem_cgroup_move_task,
Index: fix-rmdir-cgroup/Documentation/cgroups/cgroups.txt
===================================================================
--- fix-rmdir-cgroup.orig/Documentation/cgroups/cgroups.txt
+++ fix-rmdir-cgroup/Documentation/cgroups/cgroups.txt
@@ -500,6 +500,17 @@ there are not tasks in the cgroup. If pr
 rmdir() will fail with it. From this behavior, pre_destroy() can be
 called multiple times against a cgroup.
 
+int retry_rmdir(struct cgroup_subsys *ss, struct cgroup *cgrp);
+
+Called at rmdir right after the kernel finds there are remaining refcnt on
+subsystems after pre_destroy(). When retry_rmdir() returns 0, the caller enter
+sleep and wakes up when css's refcnt goes down to 0 by css_put().
+When this returns 1, the caller doesn't sleep and retry rmdir immediately.
+This is useful when the subsys knows remaining css's refcnt is not temporal
+and to calling pre_destroy() again is proper way to remove that.
+(or proper way to retrun -EBUSY.)
+
+
 int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	       struct task_struct *task)
 (cgroup_mutex held by caller)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
