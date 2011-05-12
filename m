Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 000206B0023
	for <linux-mm@kvack.org>; Thu, 12 May 2011 19:03:01 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4CMsvF0007568
	for <linux-mm@kvack.org>; Thu, 12 May 2011 16:54:57 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4CN2ux9152436
	for <linux-mm@kvack.org>; Thu, 12 May 2011 17:02:56 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4CH2tia002546
	for <linux-mm@kvack.org>; Thu, 12 May 2011 11:02:56 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 1/3] comm: Introduce comm_lock seqlock to protect task->comm access
Date: Thu, 12 May 2011 16:02:49 -0700
Message-Id: <1305241371-25276-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
References: <1305241371-25276-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

The implicit rules for current->comm access being safe without locking
are no longer true. Accessing current->comm without holding the task
lock may result in null or incomplete strings (however, access won't
run off the end of the string).

In order to properly fix this, I've introduced a comm_lock seqlock
which will protect comm access and modified get_task_comm() and
set_task_comm() to use it.

Since there are a number of cases where comm access is open-coded
safely grabbing the task_lock(), we preserve the task locking in
set_task_comm, so those users are also safe.

With this patch, users that access current->comm without a lock
are still prone to null/incomplete comm strings, but it should
be no worse then it is now.

The next step is to go through and convert all comm accesses to
use get_task_comm(). This is substantial, but can be done bit by
bit, reducing the race windows with each patch.

CC: Ted Ts'o <tytso@mit.edu>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/exec.c                 |   25 ++++++++++++++++++++-----
 include/linux/init_task.h |    1 +
 include/linux/sched.h     |    5 ++---
 3 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 5e62d26..fcd056a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -998,18 +998,32 @@ static void flush_old_files(struct files_struct * files)
 
 char *get_task_comm(char *buf, struct task_struct *tsk)
 {
-	/* buf must be at least sizeof(tsk->comm) in size */
-	task_lock(tsk);
-	strncpy(buf, tsk->comm, sizeof(tsk->comm));
-	task_unlock(tsk);
+	unsigned long seq;
+
+	do {
+		seq = read_seqbegin(&tsk->comm_lock);
+
+		strncpy(buf, tsk->comm, sizeof(tsk->comm));
+
+	} while (read_seqretry(&tsk->comm_lock, seq));
+
 	return buf;
 }
 
 void set_task_comm(struct task_struct *tsk, char *buf)
 {
-	task_lock(tsk);
+	unsigned long flags;
 
 	/*
+	 * XXX - Even though comm is protected by comm_lock,
+	 * we take the task_lock here to serialize against
+	 * current users that directly access comm.
+	 * Once those users are removed, we can drop the
+	 * task locking & memsetting.
+	 */
+	task_lock(tsk);
+	write_seqlock_irqsave(&tsk->comm_lock, flags);
+	/*
 	 * Threads may access current->comm without holding
 	 * the task lock, so write the string carefully.
 	 * Readers without a lock may see incomplete new
@@ -1018,6 +1032,7 @@ void set_task_comm(struct task_struct *tsk, char *buf)
 	memset(tsk->comm, 0, TASK_COMM_LEN);
 	wmb();
 	strlcpy(tsk->comm, buf, sizeof(tsk->comm));
+	write_sequnlock_irqrestore(&tsk->comm_lock, flags);
 	task_unlock(tsk);
 	perf_event_comm(tsk);
 }
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index caa151f..b4f7584 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -161,6 +161,7 @@ extern struct cred init_cred;
 	.group_leader	= &tsk,						\
 	RCU_INIT_POINTER(.real_cred, &init_cred),			\
 	RCU_INIT_POINTER(.cred, &init_cred),				\
+	.comm_lock	= SEQLOCK_UNLOCKED,				\
 	.comm		= "swapper",					\
 	.thread		= INIT_THREAD,					\
 	.fs		= &init_fs,					\
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 18d63ce..f9324e4 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1333,10 +1333,9 @@ struct task_struct {
 	const struct cred __rcu *cred;	/* effective (overridable) subjective task
 					 * credentials (COW) */
 	struct cred *replacement_session_keyring; /* for KEYCTL_SESSION_TO_PARENT */
-
+	seqlock_t comm_lock;		/* protect's comm */
 	char comm[TASK_COMM_LEN]; /* executable name excluding path
-				     - access with [gs]et_task_comm (which lock
-				       it with task_lock())
+				     - access with [gs]et_task_comm
 				     - initialized normally by setup_new_exec */
 /* file system info */
 	int link_count, total_link_count;
-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
