Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 333186B0202
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:13:58 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 31/96] c/r: introduce PF_RESTARTING, and skip notification on exit
Date: Wed, 17 Mar 2010 12:08:19 -0400
Message-Id: <1268842164-5590-32-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
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
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-30-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-31-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
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

3) forget_original_parent(): children of a process are signaled (per
 request) with p->pdeath_signal

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

Changelog [ckpt-v19-rc3]:
  - Rebase to kernel 2.6.33
Changelog [ckpt-v19-rc1]:
  - In reparent_thread() test for PF_RESTARTING on parent

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 kernel/exit.c   |    6 +++++-
 kernel/signal.c |    4 ++++
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/kernel/exit.c b/kernel/exit.c
index f8eb8bb..576576a 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -300,6 +300,10 @@ kill_orphaned_pgrp(struct task_struct *tsk, struct task_struct *parent)
 	struct pid *pgrp = task_pgrp(tsk);
 	struct task_struct *ignored_task = tsk;
 
+	/* restarting zombie doesn't trigger signals */
+	if (tsk->flags & PF_RESTARTING)
+		return;
+
 	if (!parent)
 		 /* exit: our father is in a different pgrp than
 		  * we are and we were the only connection outside.
@@ -785,7 +789,7 @@ static void forget_original_parent(struct task_struct *father)
 				BUG_ON(task_ptrace(t));
 				t->parent = t->real_parent;
 			}
-			if (t->pdeath_signal)
+			if (t->pdeath_signal && !(t->flags & PF_RESTARTING))
 				group_send_sig_info(t->pdeath_signal,
 						    SEND_SIG_NOINFO, t);
 		} while_each_thread(p, t);
diff --git a/kernel/signal.c b/kernel/signal.c
index 934ae5e..ce8d404 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1432,6 +1432,10 @@ int do_notify_parent(struct task_struct *tsk, int sig)
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
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
