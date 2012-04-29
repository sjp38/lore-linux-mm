Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id CC7AD6B004D
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:45:34 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id q36so2826975dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:45:34 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 08/14] hung task,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:31 +0200
Message-Id: <1335681937-3715-8-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Simplify sysctl handler by removing user input checks and using the callback
provided by the sysctl table.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/sched.h |    4 +---
 kernel/hung_task.c    |   14 ++------------
 kernel/sysctl.c       |    3 ++-
 3 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 22e3768..f148b98 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -334,9 +334,7 @@ extern unsigned int  sysctl_hung_task_panic;
 extern unsigned long sysctl_hung_task_check_count;
 extern unsigned long sysctl_hung_task_timeout_secs;
 extern unsigned long sysctl_hung_task_warnings;
-extern int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
-					 void __user *buffer,
-					 size_t *lenp, loff_t *ppos);
+extern int proc_dohung_task_timeout_secs(void);
 #else
 /* Avoid need for ifdefs elsewhere in the code */
 enum { sysctl_hung_task_timeout_secs = 0 };
diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index 6df6149..5c67710 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -181,21 +181,11 @@ static unsigned long timeout_jiffies(unsigned long timeout)
 /*
  * Process updating of timeout sysctl
  */
-int proc_dohung_task_timeout_secs(struct ctl_table *table, int write,
-				  void __user *buffer,
-				  size_t *lenp, loff_t *ppos)
+int proc_dohung_task_timeout_secs(void)
 {
-	int ret;
-
-	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
-
-	if (ret || !write)
-		goto out;
-
 	wake_up_process(watchdog_task);
 
- out:
-	return ret;
+	return 0;
 }
 
 /*
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2fac00a..16252c9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -899,7 +899,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &sysctl_hung_task_timeout_secs,
 		.maxlen		= sizeof(unsigned long),
 		.mode		= 0644,
-		.proc_handler	= proc_dohung_task_timeout_secs,
+		.proc_handler	= proc_doulongvec_minmax,
+		.callback	= proc_dohung_task_timeout_secs,
 	},
 	{
 		.procname	= "hung_task_warnings",
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
