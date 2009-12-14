Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B8E476B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 01:25:46 -0500 (EST)
Date: Mon, 14 Dec 2009 15:18:46 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 1/8] cgroup: introduce cancel_attach()
Message-Id: <20091214151846.27b12687.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
References: <20091214151748.bf9c4978.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds cancel_attach() operation to struct cgroup_subsys.
cancel_attach() can be used when can_attach() operation prepares something
for the subsys, but we should rollback what can_attach() operation has prepared
if attach task fails after we've succeeded in can_attach().

Changelog: 2009/12/04
- update comments.
Changelog: 2009/11/19
- fix typo and coding style.
Changelog: 2009/09/24
- add explanation about cancel_attach() to Documentation/cgroup/cgroup.txt.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: Li Zefan <lizf@cn.fujitsu.com>
Reviewed-by: Paul Menage <menage@google.com>
---
 Documentation/cgroups/cgroups.txt |   13 +++++++++++-
 include/linux/cgroup.h            |    2 +
 kernel/cgroup.c                   |   40 ++++++++++++++++++++++++++++++------
 3 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 0b33bfe..d450826 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -536,10 +536,21 @@ returns an error, this will abort the attach operation.  If a NULL
 task is passed, then a successful result indicates that *any*
 unspecified task can be moved into the cgroup. Note that this isn't
 called on a fork. If this method returns 0 (success) then this should
-remain valid while the caller holds cgroup_mutex. If threadgroup is
+remain valid while the caller holds cgroup_mutex and it is ensured that either
+attach() or cancel_attach() will be called in future. If threadgroup is
 true, then a successful result indicates that all threads in the given
 thread's threadgroup can be moved together.
 
+void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+	       struct task_struct *task, bool threadgroup)
+(cgroup_mutex held by caller)
+
+Called when a task attach operation has failed after can_attach() has succeeded.
+A subsystem whose can_attach() has some side-effects should provide this
+function, so that the subsytem can implement a rollback. If not, not necessary.
+This will be called only about subsystems whose can_attach() operation have
+succeeded.
+
 void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	    struct cgroup *old_cgrp, struct task_struct *task,
 	    bool threadgroup)
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 0008dee..d4cc200 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -427,6 +427,8 @@ struct cgroup_subsys {
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			  struct task_struct *tsk, bool threadgroup);
+	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			  struct task_struct *tsk, bool threadgroup);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			struct cgroup *old_cgrp, struct task_struct *tsk,
 			bool threadgroup);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 0249f4b..d67d471 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1539,7 +1539,7 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
 	int retval = 0;
-	struct cgroup_subsys *ss;
+	struct cgroup_subsys *ss, *failed_ss = NULL;
 	struct cgroup *oldcgrp;
 	struct css_set *cg;
 	struct css_set *newcg;
@@ -1553,8 +1553,16 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
 			retval = ss->can_attach(ss, cgrp, tsk, false);
-			if (retval)
-				return retval;
+			if (retval) {
+				/*
+				 * Remember on which subsystem the can_attach()
+				 * failed, so that we only call cancel_attach()
+				 * against the subsystems whose can_attach()
+				 * succeeded. (See below)
+				 */
+				failed_ss = ss;
+				goto out;
+			}
 		}
 	}
 
@@ -1568,14 +1576,17 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	 */
 	newcg = find_css_set(cg, cgrp);
 	put_css_set(cg);
-	if (!newcg)
-		return -ENOMEM;
+	if (!newcg) {
+		retval = -ENOMEM;
+		goto out;
+	}
 
 	task_lock(tsk);
 	if (tsk->flags & PF_EXITING) {
 		task_unlock(tsk);
 		put_css_set(newcg);
-		return -ESRCH;
+		retval = -ESRCH;
+		goto out;
 	}
 	rcu_assign_pointer(tsk->cgroups, newcg);
 	task_unlock(tsk);
@@ -1601,7 +1612,22 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	 * is no longer empty.
 	 */
 	cgroup_wakeup_rmdir_waiter(cgrp);
-	return 0;
+out:
+	if (retval) {
+		for_each_subsys(root, ss) {
+			if (ss == failed_ss)
+				/*
+				 * This subsystem was the one that failed the
+				 * can_attach() check earlier, so we don't need
+				 * to call cancel_attach() against it or any
+				 * remaining subsystems.
+				 */
+				break;
+			if (ss->cancel_attach)
+				ss->cancel_attach(ss, cgrp, tsk, false);
+		}
+	}
+	return retval;
 }
 
 /*
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
