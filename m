Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA2436B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:09:56 -0400 (EDT)
Date: Thu, 17 Sep 2009 11:25:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 3/8] cgroup: introduce cancel_attach()
Message-Id: <20090917112529.fa1853e9.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds cancel_attach() operation to struct cgroup_subsys.
cancel_attach() can be used when can_attach() operation prepares something
for the subsys and it should be discarded if attach_task/proc fails afterwards.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/cgroup.h |    2 ++
 kernel/cgroup.c        |   37 +++++++++++++++++++++++++++++--------
 2 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 642a47f..a08edbc 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -429,6 +429,8 @@ struct cgroup_subsys {
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			  struct task_struct *tsk, bool threadgroup);
+	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			  struct task_struct *tsk, bool threadgroup);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			struct cgroup *old_cgrp, struct task_struct *tsk,
 			bool threadgroup);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7da6004..f27f28f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1700,7 +1700,7 @@ void threadgroup_fork_unlock(struct sighand_struct *sighand)
 int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
 	int retval;
-	struct cgroup_subsys *ss;
+	struct cgroup_subsys *ss, *fail = NULL;
 	struct cgroup *oldcgrp;
 	struct cgroupfs_root *root = cgrp->root;
 
@@ -1712,15 +1712,18 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
 			retval = ss->can_attach(ss, cgrp, tsk, false);
-			if (retval)
-				return retval;
+			if (retval) {
+				fail = ss;
+				goto out;
+			}
 		}
 	}
 
 	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, 0);
 	if (retval)
-		return retval;
+		goto out;
 
+	retval = 0;
 	for_each_subsys(root, ss) {
 		if (ss->attach)
 			ss->attach(ss, cgrp, oldcgrp, tsk, false);
@@ -1733,7 +1736,15 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	 * is no longer empty.
 	 */
 	cgroup_wakeup_rmdir_waiter(cgrp);
-	return 0;
+out:
+	if (retval)
+		for_each_subsys(root, ss) {
+			if (ss == fail)
+				break;
+			if (ss->cancel_attach)
+				ss->cancel_attach(ss, cgrp, tsk, false);
+		}
+	return retval;
 }
 
 /*
@@ -1813,7 +1824,7 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
 int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
 	int retval;
-	struct cgroup_subsys *ss;
+	struct cgroup_subsys *ss, *fail = NULL;
 	struct cgroup *oldcgrp;
 	struct css_set *oldcg;
 	struct cgroupfs_root *root = cgrp->root;
@@ -1839,8 +1850,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
 			retval = ss->can_attach(ss, cgrp, leader, true);
-			if (retval)
-				return retval;
+			if (retval) {
+				fail = ss;
+				goto out;
+			}
 		}
 	}
 
@@ -1978,6 +1991,14 @@ list_teardown:
 		put_css_set(cg_entry->cg);
 		kfree(cg_entry);
 	}
+out:
+	if (retval)
+		for_each_subsys(root, ss) {
+			if (ss == fail)
+				break;
+			if (ss->cancel_attach)
+				ss->cancel_attach(ss, cgrp, tsk, true);
+		}
 	/* done! */
 	return retval;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
