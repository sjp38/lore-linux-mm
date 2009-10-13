Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B9C286B00A5
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 01:00:03 -0400 (EDT)
Date: Tue, 13 Oct 2009 13:50:27 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 1/8] cgroup: introduce cancel_attach()
Message-Id: <20091013135027.c60285a8.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds cancel_attach() operation to struct cgroup_subsys.
cancel_attach() can be used when can_attach() operation prepares something
for the subsys, but we should discard what can_attach() operation has prepared
if attach task fails afterwards.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 Documentation/cgroups/cgroups.txt |   12 ++++++++++++
 include/linux/cgroup.h            |    2 ++
 kernel/cgroup.c                   |   27 ++++++++++++++++++++-------
 3 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 0b33bfe..fd8e1c1 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -540,6 +540,18 @@ remain valid while the caller holds cgroup_mutex. If threadgroup is
 true, then a successful result indicates that all threads in the given
 thread's threadgroup can be moved together.
 
+void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+	       struct task_struct *task, bool threadgroup)
+(cgroup_mutex held by caller)
+
+Called when a task attach operation has failed after can_attach() has succeeded.
+For example, this will be called if some subsystems are mounted on the same
+hierarchy, can_attach() operations have succeeded about part of the subsystems,
+but has failed about next subsystem. This will be called only about subsystems
+whose can_attach() operation has succeeded. A subsystem whose can_attach() has
+some side-effects should provide this function, so that the subsytem can
+implement a rollback. If not, not necessary.
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
index 0249f4b..bc145f8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1539,7 +1539,7 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
 	int retval = 0;
-	struct cgroup_subsys *ss;
+	struct cgroup_subsys *ss, *fail = NULL;
 	struct cgroup *oldcgrp;
 	struct css_set *cg;
 	struct css_set *newcg;
@@ -1553,8 +1553,10 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
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
 
@@ -1568,14 +1570,17 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
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
@@ -1601,7 +1606,15 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
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
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
