Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4DB4F6B0083
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:45:11 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id up15so3116335pbc.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:45:10 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 04/14] ftrace,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:27 +0200
Message-Id: <1335681937-3715-4-git-send-email-levinsasha928@gmail.com>
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
 include/linux/ftrace.h     |    8 ++------
 kernel/sysctl.c            |    6 ++++--
 kernel/trace/ftrace.c      |    8 ++------
 kernel/trace/trace_stack.c |    9 ++-------
 4 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index 72a6cab..75a3530 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -25,9 +25,7 @@ struct ftrace_hash;
 
 extern int ftrace_enabled;
 extern int
-ftrace_enable_sysctl(struct ctl_table *table, int write,
-		     void __user *buffer, size_t *lenp,
-		     loff_t *ppos);
+ftrace_enable_sysctl(void);
 
 typedef void (*ftrace_func_t)(unsigned long ip, unsigned long parent_ip);
 
@@ -181,9 +179,7 @@ static inline void ftrace_start(void) { }
 #ifdef CONFIG_STACK_TRACER
 extern int stack_tracer_enabled;
 int
-stack_trace_sysctl(struct ctl_table *table, int write,
-		   void __user *buffer, size_t *lenp,
-		   loff_t *ppos);
+stack_trace_sysctl(void);
 #endif
 
 struct ftrace_func_command {
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index fad9ff6..40be238 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -519,7 +519,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &ftrace_enabled,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= ftrace_enable_sysctl,
+		.proc_handler	= proc_dointvec,
+		.callback	= ftrace_enable_sysctl,
 	},
 #endif
 #ifdef CONFIG_STACK_TRACER
@@ -528,7 +529,8 @@ static struct ctl_table kern_table[] = {
 		.data		= &stack_tracer_enabled,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= stack_trace_sysctl,
+		.callback	= stack_trace_sysctl,
+		.proc_handler	= proc_dointvec,
 	},
 #endif
 #ifdef CONFIG_TRACING
diff --git a/kernel/trace/ftrace.c b/kernel/trace/ftrace.c
index 0fa92f6..70a5ec4 100644
--- a/kernel/trace/ftrace.c
+++ b/kernel/trace/ftrace.c
@@ -4340,9 +4340,7 @@ int unregister_ftrace_function(struct ftrace_ops *ops)
 EXPORT_SYMBOL_GPL(unregister_ftrace_function);
 
 int
-ftrace_enable_sysctl(struct ctl_table *table, int write,
-		     void __user *buffer, size_t *lenp,
-		     loff_t *ppos)
+ftrace_enable_sysctl(void)
 {
 	int ret = -ENODEV;
 
@@ -4351,9 +4349,7 @@ ftrace_enable_sysctl(struct ctl_table *table, int write,
 	if (unlikely(ftrace_disabled))
 		goto out;
 
-	ret = proc_dointvec(table, write, buffer, lenp, ppos);
-
-	if (ret || !write || (last_ftrace_enabled == !!ftrace_enabled))
+	if (last_ftrace_enabled == !!ftrace_enabled)
 		goto out;
 
 	last_ftrace_enabled = !!ftrace_enabled;
diff --git a/kernel/trace/trace_stack.c b/kernel/trace/trace_stack.c
index d4545f4..3b05ec2 100644
--- a/kernel/trace/trace_stack.c
+++ b/kernel/trace/trace_stack.c
@@ -329,18 +329,13 @@ static const struct file_operations stack_trace_filter_fops = {
 };
 
 int
-stack_trace_sysctl(struct ctl_table *table, int write,
-		   void __user *buffer, size_t *lenp,
-		   loff_t *ppos)
+stack_trace_sysctl(void)
 {
 	int ret;
 
 	mutex_lock(&stack_sysctl_mutex);
 
-	ret = proc_dointvec(table, write, buffer, lenp, ppos);
-
-	if (ret || !write ||
-	    (last_stack_tracer_enabled == !!stack_tracer_enabled))
+	if (last_stack_tracer_enabled == !!stack_tracer_enabled)
 		goto out;
 
 	last_stack_tracer_enabled = !!stack_tracer_enabled;
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
