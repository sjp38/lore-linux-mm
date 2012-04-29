Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 773A16B00E8
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:45:41 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id q36so2826975dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:45:41 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 09/14] perf,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:32 +0200
Message-Id: <1335681937-3715-9-git-send-email-levinsasha928@gmail.com>
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
 include/linux/perf_event.h |    4 +---
 kernel/events/core.c       |    9 +--------
 kernel/sysctl.c            |    3 ++-
 3 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index ddbb6a9..24c3a54 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -1244,9 +1244,7 @@ extern int sysctl_perf_event_paranoid;
 extern int sysctl_perf_event_mlock;
 extern int sysctl_perf_event_sample_rate;
 
-extern int perf_proc_update_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos);
+extern int perf_proc_update_handler(void);
 
 static inline bool perf_paranoid_tracepoint_raw(void)
 {
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 32cfc76..94d126f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -167,15 +167,8 @@ int sysctl_perf_event_sample_rate __read_mostly = DEFAULT_MAX_SAMPLE_RATE;
 static int max_samples_per_tick __read_mostly =
 	DIV_ROUND_UP(DEFAULT_MAX_SAMPLE_RATE, HZ);
 
-int perf_proc_update_handler(struct ctl_table *table, int write,
-		void __user *buffer, size_t *lenp,
-		loff_t *ppos)
+int perf_proc_update_handler(void)
 {
-	int ret = proc_dointvec(table, write, buffer, lenp, ppos);
-
-	if (ret || !write)
-		return ret;
-
 	max_samples_per_tick = DIV_ROUND_UP(sysctl_perf_event_sample_rate, HZ);
 
 	return 0;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 16252c9..eef7508 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -977,7 +977,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &sysctl_perf_event_sample_rate,
 		.maxlen		= sizeof(sysctl_perf_event_sample_rate),
 		.mode		= 0644,
-		.proc_handler	= perf_proc_update_handler,
+		.proc_handler	= proc_dointvec,
+		.callback	= perf_proc_update_handler,
 	},
 #endif
 #ifdef CONFIG_KMEMCHECK
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
