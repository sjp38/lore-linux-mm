Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C19056B0069
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:35 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so8671074pfx.1
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:35 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m5si31929238pgj.182.2016.12.08.21.16.34
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:34 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 01/15] x86/dumpstack: Optimize save_stack_trace
Date: Fri,  9 Dec 2016 14:11:57 +0900
Message-Id: <1481260331-360-2-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Currently, x86 implementation of save_stack_trace() is walking all stack
region word by word regardless of what the trace->max_entries is.
However, it's unnecessary to walk after already fulfilling caller's
requirement, say, if trace->nr_entries >= trace->max_entries is true.

I measured its overhead and printed its difference of sched_clock() with
my QEMU x86 machine. The latency was improved over 70% when
trace->max_entries = 5.

Before this patch:

[    2.329573] save_stack_trace() takes 76820 ns
[    2.329863] save_stack_trace() takes 62131 ns
[    2.330000] save_stack_trace() takes 99476 ns
[    2.329846] save_stack_trace() takes 62419 ns
[    2.330000] save_stack_trace() takes 88918 ns
[    2.330253] save_stack_trace() takes 73669 ns
[    2.330520] save_stack_trace() takes 67876 ns
[    2.330671] save_stack_trace() takes 75963 ns
[    2.330983] save_stack_trace() takes 95079 ns
[    2.330451] save_stack_trace() takes 62352 ns

After this patch:

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

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 arch/x86/include/asm/stacktrace.h | 1 +
 arch/x86/kernel/dumpstack.c       | 4 ++++
 arch/x86/kernel/dumpstack_32.c    | 2 ++
 arch/x86/kernel/stacktrace.c      | 7 +++++++
 4 files changed, 14 insertions(+)

diff --git a/arch/x86/include/asm/stacktrace.h b/arch/x86/include/asm/stacktrace.h
index 0944218..f6d0694 100644
--- a/arch/x86/include/asm/stacktrace.h
+++ b/arch/x86/include/asm/stacktrace.h
@@ -41,6 +41,7 @@ struct stacktrace_ops {
 	/* On negative return stop dumping */
 	int (*stack)(void *data, char *name);
 	walk_stack_t	walk_stack;
+	int (*end_walk)(void *data);
 };
 
 void dump_trace(struct task_struct *tsk, struct pt_regs *regs,
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index ef8017c..274d42a 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -113,6 +113,8 @@ print_context_stack(struct task_struct *task,
 			print_ftrace_graph_addr(addr, data, ops, task, graph);
 		}
 		stack++;
+		if (ops->end_walk && ops->end_walk(data))
+			break;
 	}
 	return bp;
 }
@@ -138,6 +140,8 @@ print_context_stack_bp(struct task_struct *task,
 		frame = frame->next_frame;
 		ret_addr = &frame->return_address;
 		print_ftrace_graph_addr(addr, data, ops, task, graph);
+		if (ops->end_walk && ops->end_walk(data))
+			break;
 	}
 
 	return (unsigned long)frame;
diff --git a/arch/x86/kernel/dumpstack_32.c b/arch/x86/kernel/dumpstack_32.c
index fef917e..762d1fd 100644
--- a/arch/x86/kernel/dumpstack_32.c
+++ b/arch/x86/kernel/dumpstack_32.c
@@ -69,6 +69,8 @@ void dump_trace(struct task_struct *task, struct pt_regs *regs,
 
 		bp = ops->walk_stack(task, stack, bp, ops, data,
 				     end_stack, &graph);
+		if (ops->end_walk && ops->end_walk(data))
+			break;
 
 		/* Stop if not on irq stack */
 		if (!end_stack)
diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index 9ee98ee..a44de4d 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -47,10 +47,17 @@ save_stack_address_nosched(void *data, unsigned long addr, int reliable)
 	return __save_stack_address(data, addr, reliable, true);
 }
 
+static int save_stack_end(void *data)
+{
+	struct stack_trace *trace = data;
+	return trace->nr_entries >= trace->max_entries;
+}
+
 static const struct stacktrace_ops save_stack_ops = {
 	.stack		= save_stack_stack,
 	.address	= save_stack_address,
 	.walk_stack	= print_context_stack,
+	.end_walk	= save_stack_end,
 };
 
 static const struct stacktrace_ops save_stack_ops_nosched = {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
