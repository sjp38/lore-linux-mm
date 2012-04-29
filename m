Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 9F7036B0081
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:45:03 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id q36so2826975dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:45:03 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 03/14] sched rt,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:26 +0200
Message-Id: <1335681937-3715-3-git-send-email-levinsasha928@gmail.com>
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
 kernel/sched/core.c   |   25 ++++++++++---------------
 kernel/sysctl.c       |    6 ++++--
 3 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 722da9a..9509d80 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2152,9 +2152,7 @@ static inline unsigned int get_sysctl_timer_migration(void)
 extern unsigned int sysctl_sched_rt_period;
 extern int sysctl_sched_rt_runtime;
 
-int sched_rt_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+int sched_rt_handler(void);
 
 #ifdef CONFIG_SCHED_AUTOGROUP
 extern unsigned int sysctl_sched_autogroup_enabled;
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 477b998..ca4a806 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -7573,9 +7573,7 @@ static int sched_rt_global_constraints(void)
 }
 #endif /* CONFIG_RT_GROUP_SCHED */
 
-int sched_rt_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+int sched_rt_handler(void)
 {
 	int ret;
 	int old_period, old_runtime;
@@ -7585,19 +7583,16 @@ int sched_rt_handler(struct ctl_table *table, int write,
 	old_period = sysctl_sched_rt_period;
 	old_runtime = sysctl_sched_rt_runtime;
 
-	ret = proc_dointvec(table, write, buffer, lenp, ppos);
-
-	if (!ret && write) {
-		ret = sched_rt_global_constraints();
-		if (ret) {
-			sysctl_sched_rt_period = old_period;
-			sysctl_sched_rt_runtime = old_runtime;
-		} else {
-			def_rt_bandwidth.rt_runtime = global_rt_runtime();
-			def_rt_bandwidth.rt_period =
-				ns_to_ktime(global_rt_period());
-		}
+	ret = sched_rt_global_constraints();
+	if (ret) {
+		sysctl_sched_rt_period = old_period;
+		sysctl_sched_rt_runtime = old_runtime;
+	} else {
+		def_rt_bandwidth.rt_runtime = global_rt_runtime();
+		def_rt_bandwidth.rt_period =
+			ns_to_ktime(global_rt_period());
 	}
+
 	mutex_unlock(&mutex);
 
 	return ret;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 23f1ac6..fad9ff6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -347,14 +347,16 @@ static struct ctl_table kern_table[] = {
 		.data		= &sysctl_sched_rt_period,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= sched_rt_handler,
+		.proc_handler	= proc_dointvec,
+		.callback	= sched_rt_handler,
 	},
 	{
 		.procname	= "sched_rt_runtime_us",
 		.data		= &sysctl_sched_rt_runtime,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= sched_rt_handler,
+		.proc_handler	= proc_dointvec,
+		.callback	= sched_rt_handler,
 	},
 #ifdef CONFIG_SCHED_AUTOGROUP
 	{
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
