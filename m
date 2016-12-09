Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9E676B025E
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so8377616pfk.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:35 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id b34si32032263pld.128.2016.12.08.21.16.34
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:35 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 02/15] x86/dumpstack: Add save_stack_trace()_fast()
Date: Fri,  9 Dec 2016 14:11:58 +0900
Message-Id: <1481260331-360-3-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

In non-oops case, it's usually not necessary to check all words of stack
area to extract backtrace. Instead, we can achieve it by tracking frame
pointer. So made it possible to save stack trace lightly in normal case.

I measured its ovehead and printed its difference of sched_clock() with
my QEMU x86 machine. The latency was improved over 80% when
trace->max_entries = 5.

Before this patch:

[    2.795000] save_stack_trace() takes 21147 ns
[    2.795397] save_stack_trace() takes 20230 ns
[    2.795397] save_stack_trace() takes 31274 ns
[    2.795739] save_stack_trace() takes 19706 ns
[    2.796484] save_stack_trace() takes 20266 ns
[    2.796484] save_stack_trace() takes 20902 ns
[    2.797000] save_stack_trace() takes 38110 ns
[    2.797510] save_stack_trace() takes 20224 ns
[    2.798181] save_stack_trace() takes 20172 ns
[    2.798837] save_stack_trace() takes 20824 ns

After this patch:

[    3.133807] save_stack_trace() takes 3297 ns
[    3.133954] save_stack_trace() takes 3330 ns
[    3.134235] save_stack_trace() takes 3517 ns
[    3.134711] save_stack_trace() takes 3773 ns
[    3.135000] save_stack_trace() takes 3685 ns
[    3.135541] save_stack_trace() takes 4757 ns
[    3.135865] save_stack_trace() takes 3420 ns
[    3.136000] save_stack_trace() takes 3329 ns
[    3.137000] save_stack_trace() takes 4058 ns
[    3.137000] save_stack_trace() takes 3499 ns

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 arch/x86/kernel/stacktrace.c | 25 +++++++++++++++++++++++++
 include/linux/stacktrace.h   |  2 ++
 2 files changed, 27 insertions(+)

diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index a44de4d..d8da90f 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -53,6 +53,10 @@ static int save_stack_end(void *data)
 	return trace->nr_entries >= trace->max_entries;
 }
 
+/*
+ * This operation should be used in the oops case where
+ * stack might be broken.
+ */
 static const struct stacktrace_ops save_stack_ops = {
 	.stack		= save_stack_stack,
 	.address	= save_stack_address,
@@ -60,6 +64,13 @@ static const struct stacktrace_ops save_stack_ops = {
 	.end_walk	= save_stack_end,
 };
 
+static const struct stacktrace_ops save_stack_ops_fast = {
+	.stack		= save_stack_stack,
+	.address	= save_stack_address,
+	.walk_stack	= print_context_stack_bp,
+	.end_walk	= save_stack_end,
+};
+
 static const struct stacktrace_ops save_stack_ops_nosched = {
 	.stack		= save_stack_stack,
 	.address	= save_stack_address_nosched,
@@ -68,6 +79,7 @@ static const struct stacktrace_ops save_stack_ops_nosched = {
 
 /*
  * Save stack-backtrace addresses into a stack_trace buffer.
+ * It works even in oops.
  */
 void save_stack_trace(struct stack_trace *trace)
 {
@@ -77,6 +89,19 @@ void save_stack_trace(struct stack_trace *trace)
 }
 EXPORT_SYMBOL_GPL(save_stack_trace);
 
+/*
+ * Save stack-backtrace addresses into a stack_trace buffer.
+ * This is perfered in normal case where we expect the stack is
+ * reliable.
+ */
+void save_stack_trace_fast(struct stack_trace *trace)
+{
+	dump_trace(current, NULL, NULL, 0, &save_stack_ops_fast, trace);
+	if (trace->nr_entries < trace->max_entries)
+		trace->entries[trace->nr_entries++] = ULONG_MAX;
+}
+EXPORT_SYMBOL_GPL(save_stack_trace_fast);
+
 void save_stack_trace_regs(struct pt_regs *regs, struct stack_trace *trace)
 {
 	dump_trace(current, regs, NULL, 0, &save_stack_ops, trace);
diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index 0a34489..ddef1d0 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -14,6 +14,7 @@ struct stack_trace {
 };
 
 extern void save_stack_trace(struct stack_trace *trace);
+extern void save_stack_trace_fast(struct stack_trace *trace);
 extern void save_stack_trace_regs(struct pt_regs *regs,
 				  struct stack_trace *trace);
 extern void save_stack_trace_tsk(struct task_struct *tsk,
@@ -31,6 +32,7 @@ extern void save_stack_trace_user(struct stack_trace *trace);
 
 #else
 # define save_stack_trace(trace)			do { } while (0)
+# define save_stack_trace_fast(trace)			do { } while (0)
 # define save_stack_trace_tsk(tsk, trace)		do { } while (0)
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
