Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 05C1E6B0088
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:00:59 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 05/60] cgroup freezer: Fix buggy resume test for tasks frozen with cgroup freezer
Date: Wed, 22 Jul 2009 05:59:27 -0400
Message-Id: <1248256822-23416-6-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Matt Helsley <matthltc@us.ibm.com>, Cedric Le Goater <legoater@free.fr>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@suse.cz>, linux-pm@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Matt Helsley <matthltc@us.ibm.com>

When the cgroup freezer is used to freeze tasks we do not want to thaw
those tasks during resume. Currently we test the cgroup freezer
state of the resuming tasks to see if the cgroup is FROZEN.  If so
then we don't thaw the task. However, the FREEZING state also indicates
that the task should remain frozen.

This also avoids a problem pointed out by Oren Ladaan: the freezer state
transition from FREEZING to FROZEN is updated lazily when userspace reads
or writes the freezer.state file in the cgroup filesystem. This means that
resume will thaw tasks in cgroups which should be in the FROZEN state if
there is no read/write of the freezer.state file to trigger this
transition before suspend.

NOTE: Another "simple" solution would be to always update the cgroup
freezer state during resume. However it's a bad choice for several reasons:
Updating the cgroup freezer state is somewhat expensive because it requires
walking all the tasks in the cgroup and checking if they are each frozen.
Worse, this could easily make resume run in N^2 time where N is the number
of tasks in the cgroup. Finally, updating the freezer state from this code
path requires trickier locking because of the way locks must be ordered.

Instead of updating the freezer state we rely on the fact that lazy
updates only manage the transition from FREEZING to FROZEN. We know that
a cgroup with the FREEZING state may actually be FROZEN so test for that
state too. This makes sense in the resume path even for partially-frozen
cgroups -- those that really are FREEZING but not FROZEN.

Reported-by: Oren Ladaan <orenl@cs.columbia.edu>
Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Cedric Le Goater <legoater@free.fr>
Cc: Paul Menage <menage@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Pavel Machek <pavel@suse.cz>
Cc: linux-pm@lists.linux-foundation.org

Seems like a candidate for -stable.
---
 include/linux/freezer.h |    7 +++++--
 kernel/cgroup_freezer.c |    9 ++++++---
 kernel/power/process.c  |    2 +-
 3 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 5a361f8..da7e52b 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -64,9 +64,12 @@ extern bool freeze_task(struct task_struct *p, bool sig_only);
 extern void cancel_freezing(struct task_struct *p);
 
 #ifdef CONFIG_CGROUP_FREEZER
-extern int cgroup_frozen(struct task_struct *task);
+extern int cgroup_freezing_or_frozen(struct task_struct *task);
 #else /* !CONFIG_CGROUP_FREEZER */
-static inline int cgroup_frozen(struct task_struct *task) { return 0; }
+static inline int cgroup_freezing_or_frozen(struct task_struct *task)
+{
+	return 0;
+}
 #endif /* !CONFIG_CGROUP_FREEZER */
 
 /*
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index fb249e2..765e2c1 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -47,17 +47,20 @@ static inline struct freezer *task_freezer(struct task_struct *task)
 			    struct freezer, css);
 }
 
-int cgroup_frozen(struct task_struct *task)
+int cgroup_freezing_or_frozen(struct task_struct *task)
 {
 	struct freezer *freezer;
 	enum freezer_state state;
 
 	task_lock(task);
 	freezer = task_freezer(task);
-	state = freezer->state;
+	if (!freezer->css.cgroup->parent)
+		state = CGROUP_THAWED; /* root cgroup can't be frozen */
+	else
+		state = freezer->state;
 	task_unlock(task);
 
-	return state == CGROUP_FROZEN;
+	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
 }
 
 /*
diff --git a/kernel/power/process.c b/kernel/power/process.c
index da2072d..3728d4c 100644
--- a/kernel/power/process.c
+++ b/kernel/power/process.c
@@ -138,7 +138,7 @@ static void thaw_tasks(bool nosig_only)
 		if (nosig_only && should_send_signal(p))
 			continue;
 
-		if (cgroup_frozen(p))
+		if (cgroup_freezing_or_frozen(p))
 			continue;
 
 		thaw_process(p);
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
