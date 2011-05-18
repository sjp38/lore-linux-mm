Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B39278D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 21:41:32 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4I1JdI4002972
	for <linux-mm@kvack.org>; Tue, 17 May 2011 21:19:39 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4I1fFnw337292
	for <linux-mm@kvack.org>; Tue, 17 May 2011 21:41:16 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4HLf3GW029310
	for <linux-mm@kvack.org>; Tue, 17 May 2011 18:41:03 -0300
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 2/4] comm: Add lock-free task->comm accessor
Date: Tue, 17 May 2011 18:41:03 -0700
Message-Id: <1305682865-27111-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Joe Perches <joe@perches.com>, Ingo Molnar <mingo@elte.hu>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

This patch adds __get_task_comm() which returns the task->comm value
without taking the comm_lock. This function may return null or
incomplete comm values, and is only present for performance critical
paths that can handle these pitfalls.

CC: Joe Perches <joe@perches.com>
CC: Ingo Molnar <mingo@elte.hu>
CC: Michal Nazarewicz <mina86@mina86.com>
CC: Andy Whitcroft <apw@canonical.com>
CC: Jiri Slaby <jirislaby@gmail.com>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 fs/exec.c             |   13 +++++++++++++
 include/linux/sched.h |    1 +
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 34fa611..7e79c97 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -996,6 +996,19 @@ static void flush_old_files(struct files_struct * files)
 	spin_unlock(&files->file_lock);
 }
 
+/**
+ * __get_task_comm - Unlocked accessor to task comm value
+ *
+ * This function returns the task->comm value without
+ * taking the comm_lock. This method is only for performance
+ * critical paths, and may return a null or incomplete comm
+ * value.
+ */
+char *__get_task_comm(struct task_struct *tsk)
+{
+	return tsk->comm;
+}
+
 char *get_task_comm(char *buf, struct task_struct *tsk)
 {
 	unsigned long flags;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index f8a7cdf..5e3c25a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2189,6 +2189,7 @@ struct task_struct *fork_idle(int);
 
 extern void set_task_comm(struct task_struct *tsk, char *from);
 extern char *get_task_comm(char *to, struct task_struct *tsk);
+extern char *__get_task_comm(struct task_struct *tsk);
 
 #ifdef CONFIG_SMP
 extern unsigned long wait_task_inactive(struct task_struct *, long match_state);
-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
