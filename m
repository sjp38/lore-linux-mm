Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D63AC6B00C4
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:25 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 27/60] c/r: introduce PF_RESTARTING, and skip notification on exit
Date: Wed, 22 Jul 2009 05:59:49 -0400
Message-Id: <1248256822-23416-28-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

To restore zombie's we will create the a task, that, on its turn to
run, calls do_exit(). Unlike normal tasks that exit, we need to
prevent notification side effects that send signals to other
processes, e.g. parent (SIGCHLD) or child tasks (per child's request).

There are three main cases for such notifications:

1) do_notify_parent(): parent of a process is notified about a change
 in status (e.g. become zombie, reparent, etc). If parent ignores,
 then mark child for immediate release (skip zombie).

2) kill_orphan_pgrp(): a process group that becomes orphaned will
 signal stopped jobs (HUP then CONT).

3) reparent_thread(): children of a process are signaled (per request)
 with p->pdeath_signal

Remember that restoring signal state (for any restarting task) must
complete _before_ it is allowed to resume execution, and not during
the resume. Otherwise, a running task may send a signal to another
task that hasn't restored yet, so the new signal will be lost
soon-after.

I considered two possible way to address this:

1. Add another sync point to restart: all tasks will first restore
their state without signals (all signals blocked), and zombies call
do_exit(). A sync point then will ensure that all zombies are gone and
their effects done. Then all tasks restore their signal state (and
mask), and sync (new point) again. Only then they may resume
execution.
The main disadvantage is the added complexity and inefficiency,
for no good reason.

2. Introduce PF_RESTARTING: mark all restarting tasks with a new flag,
and teach the above three notifications to skip sending the signal if
theis flag is set.
The main advantage is simplicity and completeness. Also, such a flag
may to be useful later on. This the method implemented.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 kernel/exit.c   |    7 ++++++-
 kernel/signal.c |    4 ++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index 912b1fa..41ac4cf 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -299,6 +299,10 @@ kill_orphaned_pgrp(struct task_struct *tsk, struct task_struct *parent)
 	struct pid *pgrp = task_pgrp(tsk);
 	struct task_struct *ignored_task = tsk;
 
+	/* restarting zombie doesn't trigger signals */
+	if (tsk->flags & PF_RESTARTING)
+		return;
+
 	if (!parent)
 		 /* exit: our father is in a different pgrp than
 		  * we are and we were the only connection outside.
@@ -739,7 +743,8 @@ static struct task_struct *find_new_reaper(struct task_struct *father)
 static void reparent_thread(struct task_struct *father, struct task_struct *p,
 				struct list_head *dead)
 {
-	if (p->pdeath_signal)
+	/* restarting zombie doesn't trigger signals */
+	if (p->pdeath_signal && !(p->flags & PF_RESTARTING))
 		group_send_sig_info(p->pdeath_signal, SEND_SIG_NOINFO, p);
 
 	list_move_tail(&p->sibling, &p->real_parent->children);
diff --git a/kernel/signal.c b/kernel/signal.c
index ccf1cee..697f700 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1413,6 +1413,10 @@ int do_notify_parent(struct task_struct *tsk, int sig)
 	BUG_ON(!task_ptrace(tsk) &&
 	       (tsk->group_leader != tsk || !thread_group_empty(tsk)));
 
+	/* restarting zombie doesn't notify parent */
+	if (tsk->flags & PF_RESTARTING)
+		return ret;
+
 	info.si_signo = sig;
 	info.si_errno = 0;
 	/*
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
