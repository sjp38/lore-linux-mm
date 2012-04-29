Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id C725A6B004D
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:44:58 -0400 (EDT)
Received: by dadq36 with SMTP id q36so2826975dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:44:58 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 02/14] sched debug,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:25 +0200
Message-Id: <1335681937-3715-2-git-send-email-levinsasha928@gmail.com>
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
 kernel/sched/fair.c   |    8 +-------
 kernel/sysctl.c       |   12 ++++++++----
 3 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7d2acbd..722da9a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2136,9 +2136,7 @@ extern unsigned int sysctl_sched_time_avg;
 extern unsigned int sysctl_timer_migration;
 extern unsigned int sysctl_sched_shares_window;
 
-int sched_proc_update_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *length,
-		loff_t *ppos);
+int sched_proc_update_handler(void);
 #endif
 #ifdef CONFIG_SCHED_DEBUG
 static inline unsigned int get_sysctl_timer_migration(void)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index e955364..20ccdc8 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -558,16 +558,10 @@ struct sched_entity *__pick_last_entity(struct cfs_rq *cfs_rq)
  * Scheduling class statistics methods:
  */
 
-int sched_proc_update_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+int sched_proc_update_handler(void)
 {
-	int ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	int factor = get_update_sysctl_factor();
 
-	if (ret || !write)
-		return ret;
-
 	sched_nr_latency = DIV_ROUND_UP(sysctl_sched_latency,
 					sysctl_sched_min_granularity);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ba133ec..23f1ac6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -269,7 +269,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &sysctl_sched_min_granularity,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= sched_proc_update_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= sched_proc_update_handler,
 		.extra1		= &min_sched_granularity_ns,
 		.extra2		= &max_sched_granularity_ns,
 	},
@@ -278,7 +279,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &sysctl_sched_latency,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= sched_proc_update_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= sched_proc_update_handler,
 		.extra1		= &min_sched_granularity_ns,
 		.extra2		= &max_sched_granularity_ns,
 	},
@@ -287,7 +289,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &sysctl_sched_wakeup_granularity,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= sched_proc_update_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= sched_proc_update_handler,
 		.extra1		= &min_wakeup_granularity_ns,
 		.extra2		= &max_wakeup_granularity_ns,
 	},
@@ -296,7 +299,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &sysctl_sched_tunable_scaling,
 		.maxlen		= sizeof(enum sched_tunable_scaling),
 		.mode		= 0644,
-		.proc_handler	= sched_proc_update_handler,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= sched_proc_update_handler,
 		.extra1		= &min_sched_tunable_scaling,
 		.extra2		= &max_sched_tunable_scaling,
 	},
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
