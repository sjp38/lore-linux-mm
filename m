Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4CC156B0085
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 16:34:56 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so6262945pad.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 13:34:55 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 11/13] cpuset: pin down cpus and mems while a task is being attached
Date: Wed, 28 Nov 2012 13:34:18 -0800
Message-Id: <1354138460-19286-12-git-send-email-tj@kernel.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj@kernel.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

cpuset is scheduled to be decoupled from cgroup_lock which will make
configuration updates race with task migration.  Any config update
will be allowed to happen between ->can_attach() and ->attach().  If
such config update removes either all cpus or mems, by the time
->attach() is called, the condition verified by ->can_attach(), that
the cpuset is capable of hosting the tasks, is no longer true.

This patch adds cpuset->attach_in_progress which is incremented from
->can_attach() and decremented when the attach operation finishes
either successfully or not.  validate_change() treats cpusets w/
non-zero ->attach_in_progress like cpusets w/ tasks and refuses to
remove all cpus or mems from it.

This currently doesn't make any functional difference as everything is
protected by cgroup_mutex but enables decoupling the locking.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3558250..68a0906 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -91,6 +91,12 @@ struct cpuset {
 
 	struct fmeter fmeter;		/* memory_pressure filter */
 
+	/*
+	 * Tasks are being attached to this cpuset.  Used to prevent
+	 * zeroing cpus/mems_allowed between ->can_attach() and ->attach().
+	 */
+	int attach_in_progress;
+
 	/* partition number for rebuild_sched_domains() */
 	int pn;
 
@@ -468,9 +474,12 @@ static int validate_change(const struct cpuset *cur, const struct cpuset *trial)
 			goto out;
 	}
 
-	/* Cpusets with tasks can't have empty cpus_allowed or mems_allowed */
+	/*
+	 * Cpusets with tasks - existing or newly being attached - can't
+	 * have empty cpus_allowed or mems_allowed.
+	 */
 	ret = -ENOSPC;
-	if (cgroup_task_count(cur->css.cgroup) &&
+	if ((cgroup_task_count(cur->css.cgroup) || cur->attach_in_progress) &&
 	    (cpumask_empty(trial->cpus_allowed) ||
 	     nodes_empty(trial->mems_allowed)))
 		goto out;
@@ -1386,9 +1395,21 @@ static int cpuset_can_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 			return ret;
 	}
 
+	/*
+	 * Mark attach is in progress.  This makes validate_change() fail
+	 * changes which zero cpus/mems_allowed.
+	 */
+	cs->attach_in_progress++;
+
 	return 0;
 }
 
+static void cpuset_cancel_attach(struct cgroup *cgrp,
+				 struct cgroup_taskset *tset)
+{
+	cgroup_cs(cgrp)->attach_in_progress--;
+}
+
 static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 {
 	/* static bufs protected by cgroup_mutex */
@@ -1435,6 +1456,8 @@ static void cpuset_attach(struct cgroup *cgrp, struct cgroup_taskset *tset)
 					  &cpuset_attach_nodemask_to);
 		mmput(mm);
 	}
+
+	cs->attach_in_progress--;
 }
 
 /* The various types of files and directories in a cpuset file system */
@@ -1902,6 +1925,7 @@ struct cgroup_subsys cpuset_subsys = {
 	.css_offline = cpuset_css_offline,
 	.css_free = cpuset_css_free,
 	.can_attach = cpuset_can_attach,
+	.cancel_attach = cpuset_cancel_attach,
 	.attach = cpuset_attach,
 	.subsys_id = cpuset_subsys_id,
 	.base_cftypes = files,
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
