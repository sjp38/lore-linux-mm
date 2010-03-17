Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 573FB6B01EC
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:12:58 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 18/96] cgroup freezer: interface to freeze a cgroup from within the kernel
Date: Wed, 17 Mar 2010 12:08:06 -0400
Message-Id: <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>, Matt Helsley <matthltc@us.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Cedric Le Goater <legoater@free.fr>
List-ID: <linux-mm.kvack.org>

Add public interface to freeze a cgroup freezer given a task that
belongs to that cgroup:  cgroup_freezer_make_frozen(task)

Freezing the root cgroup is not permitted. Freezing the cgroup to
which current process belong is also not permitted.

This will be used for restart(2) to be able to leave the restarted
processes in a frozen state, instead of resuming execution.

This is useful for debugging, if the user would like to attach a
debugger to the restarted task(s).

It is also useful if the restart procedure would like to perform
additional setup once the tasks are restored but before they are
allowed to proceed execution.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
CC: Matt Helsley <matthltc@us.ibm.com>
Cc: Paul Menage <menage@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Cedric Le Goater <legoater@free.fr>
---
 include/linux/freezer.h |    1 +
 kernel/cgroup_freezer.c |   27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 3d32641..0cb22cb 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -68,6 +68,7 @@ extern int cgroup_freezing_or_frozen(struct task_struct *task);
 extern int in_same_cgroup_freezer(struct task_struct *p, struct task_struct *q);
 extern int cgroup_freezer_begin_checkpoint(struct task_struct *task);
 extern void cgroup_freezer_end_checkpoint(struct task_struct *task);
+extern int cgroup_freezer_make_frozen(struct task_struct *task);
 #else /* !CONFIG_CGROUP_FREEZER */
 static inline int cgroup_freezing_or_frozen(struct task_struct *task)
 {
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index dd87010..efd4597 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -479,4 +479,31 @@ void cgroup_freezer_end_checkpoint(struct task_struct *task)
 	 */
 	WARN_ON(freezer_checkpointing(task, CGROUP_FROZEN) != CGROUP_CHECKPOINTING);
 }
+
+int cgroup_freezer_make_frozen(struct task_struct *task)
+{
+	struct freezer *freezer;
+	struct cgroup_subsys_state *css;
+	int ret = -ENODEV;
+
+	task_lock(task);
+	css = task_subsys_state(task, freezer_subsys_id);
+	css_get(css); /* make sure freezer doesn't go away */
+	freezer = container_of(css, struct freezer, css);
+	task_unlock(task);
+
+	/* Never freeze the root cgroup */
+	if (!test_bit(CSS_ROOT, &css->flags) &&
+	    cgroup_lock_live_group(css->cgroup)) {
+		/* do not freeze outselves, ei ?! */
+		if (css != task_subsys_state(current, freezer_subsys_id))
+			ret = freezer_change_state(css->cgroup, CGROUP_FROZEN);
+		else
+			ret = -EPERM;
+		cgroup_unlock();
+	}
+
+	css_put(css);
+	return ret;
+}
 #endif /* CONFIG_CHECKPOINT */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
