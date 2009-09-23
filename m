Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CF1FA6B005D
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 19:52:55 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 07/80] cgroup freezer: Add CHECKPOINTING state to safeguard container checkpoint
Date: Wed, 23 Sep 2009 19:50:47 -0400
Message-Id: <1253749920-18673-8-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Matt Helsley <matthltc@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Cedric Le Goater <legoater@free.fr>
List-ID: <linux-mm.kvack.org>

From: Matt Helsley <matthltc@us.ibm.com>

The CHECKPOINTING state prevents userspace from unfreezing tasks until
sys_checkpoint() is finished. When doing container checkpoint userspace
will do:

	echo FROZEN > /cgroups/my_container/freezer.state
	...
	rc = sys_checkpoint( <pid of container root> );

To ensure a consistent checkpoint image userspace should not be allowed
to thaw the cgroup (echo THAWED > /cgroups/my_container/freezer.state)
during checkpoint.

"CHECKPOINTING" can only be set on a "FROZEN" cgroup using the checkpoint
system call. Once in the "CHECKPOINTING" state, the cgroup may not leave until
the checkpoint system call is finished and ready to return. Then the
freezer state returns to "FROZEN". Writing any new state to freezer.state while
checkpointing will return EBUSY. These semantics ensure that userspace cannot
unfreeze the cgroup midway through the checkpoint system call.

The cgroup_freezer_begin_checkpoint() and cgroup_freezer_end_checkpoint()
make relatively few assumptions about the task that is passed in. However the
way they are called in do_checkpoint() assumes that the root of the container
is in the same freezer cgroup as all the other tasks that will be
checkpointed.

Notes:
        As a side-effect this prevents the multiple tasks from entering the
        CHECKPOINTING state simultaneously. All but one will get -EBUSY.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Paul Menage <menage@google.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Cedric Le Goater <legoater@free.fr>
---
 Documentation/cgroups/freezer-subsystem.txt |   10 ++
 include/linux/freezer.h                     |    8 ++
 kernel/cgroup_freezer.c                     |  166 ++++++++++++++++++++-------
 3 files changed, 142 insertions(+), 42 deletions(-)

diff --git a/Documentation/cgroups/freezer-subsystem.txt b/Documentation/cgroups/freezer-subsystem.txt
index 41f37fe..92b68e6 100644
--- a/Documentation/cgroups/freezer-subsystem.txt
+++ b/Documentation/cgroups/freezer-subsystem.txt
@@ -100,3 +100,13 @@ things happens:
 		and returns EINVAL)
 	3) The tasks that blocked the cgroup from entering the "FROZEN"
 		state disappear from the cgroup's set of tasks.
+
+When the cgroup freezer is used to guard container checkpoint operations the
+freezer.state may be "CHECKPOINTING". "CHECKPOINTING" can only be set on a
+"FROZEN" cgroup using the checkpoint system call. Once in the "CHECKPOINTING"
+state, the cgroup may not leave until the checkpoint system call returns the
+freezer state to "FROZEN". Writing any new state to freezer.state while
+checkpointing will return EBUSY. These semantics ensure that userspace cannot
+unfreeze the cgroup midway through the checkpoint system call. Note that,
+unlike "FROZEN" and "FREEZING", there is no corresponding "CHECKPOINTED"
+state.
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index da7e52b..3d32641 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -65,11 +65,19 @@ extern void cancel_freezing(struct task_struct *p);
 
 #ifdef CONFIG_CGROUP_FREEZER
 extern int cgroup_freezing_or_frozen(struct task_struct *task);
+extern int in_same_cgroup_freezer(struct task_struct *p, struct task_struct *q);
+extern int cgroup_freezer_begin_checkpoint(struct task_struct *task);
+extern void cgroup_freezer_end_checkpoint(struct task_struct *task);
 #else /* !CONFIG_CGROUP_FREEZER */
 static inline int cgroup_freezing_or_frozen(struct task_struct *task)
 {
 	return 0;
 }
+static inline int in_same_cgroup_freezer(struct task_struct *p,
+					 struct task_struct *q)
+{
+	return 0;
+}
 #endif /* !CONFIG_CGROUP_FREEZER */
 
 /*
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 22fce5d..87dfbfb 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -25,6 +25,7 @@ enum freezer_state {
 	CGROUP_THAWED = 0,
 	CGROUP_FREEZING,
 	CGROUP_FROZEN,
+	CGROUP_CHECKPOINTING,
 };
 
 struct freezer {
@@ -63,6 +64,44 @@ int cgroup_freezing_or_frozen(struct task_struct *task)
 	return (state == CGROUP_FREEZING) || (state == CGROUP_FROZEN);
 }
 
+/* Task is frozen or will freeze immediately when next it gets woken */
+static bool is_task_frozen_enough(struct task_struct *task)
+{
+	return frozen(task) ||
+		(task_is_stopped_or_traced(task) && freezing(task));
+}
+
+/*
+ * caller must hold freezer->lock
+ */
+static void update_freezer_state(struct cgroup *cgroup,
+				 struct freezer *freezer)
+{
+	struct cgroup_iter it;
+	struct task_struct *task;
+	unsigned int nfrozen = 0, ntotal = 0;
+
+	cgroup_iter_start(cgroup, &it);
+	while ((task = cgroup_iter_next(cgroup, &it))) {
+		ntotal++;
+		if (is_task_frozen_enough(task))
+			nfrozen++;
+	}
+
+	/*
+	 * Transition to FROZEN when no new tasks can be added ensures
+	 * that we never exist in the FROZEN state while there are unfrozen
+	 * tasks.
+	 */
+	if (nfrozen == ntotal)
+		freezer->state = CGROUP_FROZEN;
+	else if (nfrozen > 0)
+		freezer->state = CGROUP_FREEZING;
+	else
+		freezer->state = CGROUP_THAWED;
+	cgroup_iter_end(cgroup, &it);
+}
+
 /*
  * cgroups_write_string() limits the size of freezer state strings to
  * CGROUP_LOCAL_BUFFER_SIZE
@@ -71,6 +110,7 @@ static const char *freezer_state_strs[] = {
 	"THAWED",
 	"FREEZING",
 	"FROZEN",
+	"CHECKPOINTING",
 };
 
 /*
@@ -78,9 +118,9 @@ static const char *freezer_state_strs[] = {
  * Transitions are caused by userspace writes to the freezer.state file.
  * The values in parenthesis are state labels. The rest are edge labels.
  *
- * (THAWED) --FROZEN--> (FREEZING) --FROZEN--> (FROZEN)
- *    ^ ^                    |                     |
- *    | \_______THAWED_______/                     |
+ * (THAWED) --FROZEN--> (FREEZING) --FROZEN--> (FROZEN) --> (CHECKPOINTING)
+ *    ^ ^                    |                     | ^             |
+ *    | \_______THAWED_______/                     | \_____________/
  *    \__________________________THAWED____________/
  */
 
@@ -153,13 +193,6 @@ static void freezer_destroy(struct cgroup_subsys *ss,
 	kfree(cgroup_freezer(cgroup));
 }
 
-/* Task is frozen or will freeze immediately when next it gets woken */
-static bool is_task_frozen_enough(struct task_struct *task)
-{
-	return frozen(task) ||
-		(task_is_stopped_or_traced(task) && freezing(task));
-}
-
 /*
  * The call to cgroup_lock() in the freezer.state write method prevents
  * a write to that file racing against an attach, and hence the
@@ -216,37 +249,6 @@ static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
 	spin_unlock_irq(&freezer->lock);
 }
 
-/*
- * caller must hold freezer->lock
- */
-static void update_freezer_state(struct cgroup *cgroup,
-				 struct freezer *freezer)
-{
-	struct cgroup_iter it;
-	struct task_struct *task;
-	unsigned int nfrozen = 0, ntotal = 0;
-
-	cgroup_iter_start(cgroup, &it);
-	while ((task = cgroup_iter_next(cgroup, &it))) {
-		ntotal++;
-		if (is_task_frozen_enough(task))
-			nfrozen++;
-	}
-
-	/*
-	 * Transition to FROZEN when no new tasks can be added ensures
-	 * that we never exist in the FROZEN state while there are unfrozen
-	 * tasks.
-	 */
-	if (nfrozen == ntotal)
-		freezer->state = CGROUP_FROZEN;
-	else if (nfrozen > 0)
-		freezer->state = CGROUP_FREEZING;
-	else
-		freezer->state = CGROUP_THAWED;
-	cgroup_iter_end(cgroup, &it);
-}
-
 static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
 			struct seq_file *m)
 {
@@ -317,7 +319,10 @@ static int freezer_change_state(struct cgroup *cgroup,
 	freezer = cgroup_freezer(cgroup);
 
 	spin_lock_irq(&freezer->lock);
-
+	if (freezer->state == CGROUP_CHECKPOINTING) {
+		retval = -EBUSY;
+		goto out;
+	}
 	update_freezer_state(cgroup, freezer);
 	if (goal_state == freezer->state)
 		goto out;
@@ -385,3 +390,80 @@ struct cgroup_subsys freezer_subsys = {
 	.fork		= freezer_fork,
 	.exit		= NULL,
 };
+
+#ifdef CONFIG_CHECKPOINT
+/*
+ * Caller is expected to ensure that neither @p nor @q may change its
+ * freezer cgroup during this test in a way that may affect the result.
+ * E.g., when called form c/r, @p must be in CHECKPOINTING cgroup, so
+ * may not change cgroup, and either @q is also there, or is not there
+ * and may not join.
+ */
+int in_same_cgroup_freezer(struct task_struct *p, struct task_struct *q)
+{
+	struct cgroup_subsys_state *p_css, *q_css;
+
+	task_lock(p);
+	p_css = task_subsys_state(p, freezer_subsys_id);
+	task_unlock(p);
+
+	task_lock(q);
+	q_css = task_subsys_state(q, freezer_subsys_id);
+	task_unlock(q);
+
+	return (p_css == q_css);
+}
+
+/*
+ * cgroup freezer state changes made without the aid of the cgroup filesystem
+ * must go through this function to ensure proper locking is observed.
+ */
+static int freezer_checkpointing(struct task_struct *task,
+				 enum freezer_state next_state)
+{
+	struct freezer *freezer;
+	struct cgroup_subsys_state *css;
+	enum freezer_state state;
+
+	task_lock(task);
+	css = task_subsys_state(task, freezer_subsys_id);
+	css_get(css); /* make sure freezer doesn't go away */
+	freezer = container_of(css, struct freezer, css);
+	task_unlock(task);
+
+	if (freezer->state == CGROUP_FREEZING) {
+		/* May be in middle of a lazy FREEZING -> FROZEN transition */
+		if (cgroup_lock_live_group(css->cgroup)) {
+			spin_lock_irq(&freezer->lock);
+			update_freezer_state(css->cgroup, freezer);
+			spin_unlock_irq(&freezer->lock);
+			cgroup_unlock();
+		}
+	}
+
+	spin_lock_irq(&freezer->lock);
+	state = freezer->state;
+	if ((state == CGROUP_FROZEN && next_state == CGROUP_CHECKPOINTING) ||
+	    (state == CGROUP_CHECKPOINTING && next_state == CGROUP_FROZEN))
+		freezer->state = next_state;
+	spin_unlock_irq(&freezer->lock);
+	css_put(css);
+	return state;
+}
+
+int cgroup_freezer_begin_checkpoint(struct task_struct *task)
+{
+	if (freezer_checkpointing(task, CGROUP_CHECKPOINTING) != CGROUP_FROZEN)
+		return -EBUSY;
+	return 0;
+}
+
+void cgroup_freezer_end_checkpoint(struct task_struct *task)
+{
+	/*
+	 * If we weren't in CHECKPOINTING state then userspace could have
+	 * unfrozen a task and given us an inconsistent checkpoint image
+	 */
+	WARN_ON(freezer_checkpointing(task, CGROUP_FROZEN) != CGROUP_CHECKPOINTING);
+}
+#endif /* CONFIG_CHECKPOINT */
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
