Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 4E48B6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:45:24 -0400 (EDT)
Received: by wibhq7 with SMTP id hq7so44389wib.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 11:45:22 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V8] Eliminate task stack trace duplication
Date: Fri,  6 Apr 2012 11:45:20 -0700
Message-Id: <1333737920-17555-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The problem with small dmesg ring buffer like 512k is that only limited number
of task traces will be logged. Sometimes we lose important information only
because of too many duplicated stack traces. This problem occurs when dumping
lots of stacks in a single operation, such as sysrq-T.

This patch tries to reduce the duplication of task stack trace in the dump
message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
during bootup. Each time if we find the identical task trace in the task stack,
we dump only the pid of the task which has the task trace dumped. So it is easy
to back track to the full stack with the pid.

When we do the hashing, we eliminate garbage entries from stack traces. Those
entries are still being printed in the dump to provide more debugging
informations.

[   53.510162] kworker/0:0     S ffffffff8161d820     0     4      2 0x00000000
[   53.517237]  ffff88027547de60 0000000000000046 ffffffff812ab840 0000000000000000
[   53.524663]  ffff880275460080 ffff88027547dfd8 ffff88027547dfd8 ffff88027547dfd8
[   53.532092]  ffffffff81813020 ffff880275460080 0000000000000000 ffff8808758670c0
[   53.539521] Call Trace:
[   53.541974]  [<ffffffff812ab840>] ? cfq_init_queue+0x350/0x350
[   53.547791]  [<ffffffff81524d49>] schedule+0x29/0x70
[   53.552761]  [<ffffffff810945a3>] worker_thread+0x233/0x380
[   53.558318]  [<ffffffff81094370>] ? manage_workers.isra.28+0x230/0x230
[   53.564839]  [<ffffffff81099a73>] kthread+0x93/0xa0
[   53.569714]  [<ffffffff8152e6d4>] kernel_thread_helper+0x4/0x10
[   53.575628]  [<ffffffff810999e0>] ? kthread_worker_fn+0x140/0x140
[   53.581714]  [<ffffffff8152e6d0>] ? gs_change+0xb/0xb
[   53.586762] kworker/u:0     S ffffffff8161d820     0     5      2 0x00000000
[   53.593858]  ffff88027547fe60 0000000000000046 ffffffffa005cc70 0000000000000000
[   53.601307]  ffff8802754627d0 ffff88027547ffd8 ffff88027547ffd8 ffff88027547ffd8
[   53.608788]  ffffffff81813020 ffff8802754627d0 0000000000011fc0 ffff8804758670c0
[   53.616232] Call Trace:
[   53.618676] <Same stack as pid 4>

changelog v8..v7:
1. rebase on v3.4-rc1.

changelog v7..v6:
1. rebase on v3.3_rc2, the only change is moving changes from kernel/sched.c
to kernel/sched/core.c

changelog v6..v5:
1. clear saved stack trace before printing a set of stacks. this ensures the printed
stack traces are not omitted messages.
2. add log level in printing duplicate stack.
3. remove the show_stack() API change, and non-x86 arch won't need further change.
4. add more inline documentations.

changelog v5..v4:
1. removed changes to Kconfig file
2. changed hashtable to keep only hash value and length of stack
3. simplified hashtable lookup

changelog v4..v3:
1. improve de-duplication by eliminating garbage entries from stack traces.
with this change 793/825 stack traces were recognized as duplicates. in v3
only 482/839 were duplicates.

changelog v3..v2:
1. again better documentation on the patch description.
2. make the stack_hash_table to be allocated at compile time.
3. have better name of variable index
4. move save_dup_stack_trace() in kernel/stacktrace.c

changelog v2..v1:
1. better documentation on the patch description
2. move the spinlock inside the hash lockup, so reducing the holding time.

Note:
1. with pid namespace, we might have same pid number for different processes. i
wonder how the stack trace (w/o dedup) handles the case, it uses tsk->pid as well
as far as I checked.
2. the core functionality is in x86-specific code, this could be moved out to
support other architectures.
3. Andrew made the suggestion of doing appending to stack_hash_table[].

Signed-off-by: Ying Han <yinghan@google.com>
---
 arch/x86/include/asm/stacktrace.h |   11 +++-
 arch/x86/kernel/dumpstack.c       |   24 ++++++-
 arch/x86/kernel/dumpstack_32.c    |    7 +-
 arch/x86/kernel/dumpstack_64.c    |    7 +-
 arch/x86/kernel/stacktrace.c      |  123 +++++++++++++++++++++++++++++++++++++
 include/linux/sched.h             |    3 +
 include/linux/stacktrace.h        |    4 +
 kernel/sched/core.c               |   32 +++++++++-
 kernel/stacktrace.c               |   15 +++++
 9 files changed, 211 insertions(+), 15 deletions(-)

diff --git a/arch/x86/include/asm/stacktrace.h b/arch/x86/include/asm/stacktrace.h
index 70bbe39..32557fe 100644
--- a/arch/x86/include/asm/stacktrace.h
+++ b/arch/x86/include/asm/stacktrace.h
@@ -81,13 +81,20 @@ stack_frame(struct task_struct *task, struct pt_regs *regs)
 }
 #endif
 
+/*
+ * The parameter dup_stack_pid is used for task stack deduplication.
+ * The non-zero value of dup_stack_pid indicates the pid of the
+ * task with the same stack trace.
+ */
 extern void
 show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *stack, unsigned long bp, char *log_lvl);
+		   unsigned long *stack, unsigned long bp, char *log_lvl,
+		   pid_t dup_stack_pid);
 
 extern void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, unsigned long bp, char *log_lvl);
+		   unsigned long *sp, unsigned long bp, char *log_lvl,
+		   pid_t dup_stack_pid);
 
 extern unsigned int code_bytes;
 
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index 1b81839..589c4f0 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -162,21 +162,37 @@ static const struct stacktrace_ops print_trace_ops = {
 
 void
 show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		unsigned long *stack, unsigned long bp, char *log_lvl)
+		unsigned long *stack, unsigned long bp, char *log_lvl,
+		pid_t dup_stack_pid)
 {
 	printk("%sCall Trace:\n", log_lvl);
-	dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl);
+	if (dup_stack_pid)
+		printk("%s<Same stack as pid %d>", log_lvl, dup_stack_pid);
+	else
+		dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl);
 }
 
 void show_trace(struct task_struct *task, struct pt_regs *regs,
 		unsigned long *stack, unsigned long bp)
 {
-	show_trace_log_lvl(task, regs, stack, bp, "");
+	show_trace_log_lvl(task, regs, stack, bp, "", 0);
 }
 
 void show_stack(struct task_struct *task, unsigned long *sp)
 {
-	show_stack_log_lvl(task, NULL, sp, 0, "");
+	show_stack_log_lvl(task, NULL, sp, 0, "", 0);
+}
+
+/*
+ * Similar to show_stack except accepting the dup_stack_pid parameter.
+ * The parameter indicates whether or not the caller side tries to do
+ * a stack dedup, and the non-zero value indicates the pid of the
+ * task with the same stack trace.
+ */
+void show_stack_dedup(struct task_struct *task, unsigned long *sp,
+			pid_t dup_stack_pid)
+{
+	show_stack_log_lvl(task, NULL, sp, 0, "", dup_stack_pid);
 }
 
 /*
diff --git a/arch/x86/kernel/dumpstack_32.c b/arch/x86/kernel/dumpstack_32.c
index 88ec912..575b019 100644
--- a/arch/x86/kernel/dumpstack_32.c
+++ b/arch/x86/kernel/dumpstack_32.c
@@ -56,7 +56,8 @@ EXPORT_SYMBOL(dump_trace);
 
 void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, unsigned long bp, char *log_lvl)
+		   unsigned long *sp, unsigned long bp, char *log_lvl,
+		   pid_t dup_stack_pid)
 {
 	unsigned long *stack;
 	int i;
@@ -78,7 +79,7 @@ show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
 		touch_nmi_watchdog();
 	}
 	printk(KERN_CONT "\n");
-	show_trace_log_lvl(task, regs, sp, bp, log_lvl);
+	show_trace_log_lvl(task, regs, sp, bp, log_lvl, dup_stack_pid);
 }
 
 
@@ -103,7 +104,7 @@ void show_registers(struct pt_regs *regs)
 		u8 *ip;
 
 		printk(KERN_EMERG "Stack:\n");
-		show_stack_log_lvl(NULL, regs, &regs->sp, 0, KERN_EMERG);
+		show_stack_log_lvl(NULL, regs, &regs->sp, 0, KERN_EMERG, 0);
 
 		printk(KERN_EMERG "Code: ");
 
diff --git a/arch/x86/kernel/dumpstack_64.c b/arch/x86/kernel/dumpstack_64.c
index 17107bd..8f059d0 100644
--- a/arch/x86/kernel/dumpstack_64.c
+++ b/arch/x86/kernel/dumpstack_64.c
@@ -198,7 +198,8 @@ EXPORT_SYMBOL(dump_trace);
 
 void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, unsigned long bp, char *log_lvl)
+		   unsigned long *sp, unsigned long bp, char *log_lvl,
+		   pid_t dup_stack_pid)
 {
 	unsigned long *irq_stack_end;
 	unsigned long *irq_stack;
@@ -242,7 +243,7 @@ show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
 	preempt_enable();
 
 	printk(KERN_CONT "\n");
-	show_trace_log_lvl(task, regs, sp, bp, log_lvl);
+	show_trace_log_lvl(task, regs, sp, bp, log_lvl, dup_stack_pid);
 }
 
 void show_registers(struct pt_regs *regs)
@@ -271,7 +272,7 @@ void show_registers(struct pt_regs *regs)
 
 		printk(KERN_DEFAULT "Stack:\n");
 		show_stack_log_lvl(NULL, regs, (unsigned long *)sp,
-				   0, KERN_DEFAULT);
+				   0, KERN_DEFAULT, 0);
 
 		printk(KERN_DEFAULT "Code: ");
 
diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index fdd0c64..6bee992 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -7,6 +7,7 @@
 #include <linux/stacktrace.h>
 #include <linux/module.h>
 #include <linux/uaccess.h>
+#include <linux/jhash.h>
 #include <asm/stacktrace.h>
 
 static int save_stack_stack(void *data, char *name)
@@ -81,6 +82,128 @@ void save_stack_trace_tsk(struct task_struct *tsk, struct stack_trace *trace)
 }
 EXPORT_SYMBOL_GPL(save_stack_trace_tsk);
 
+/*
+ * The implementation of stack trace dedup.
+ *
+ * It tries to reduce the duplication of task stack trace in the dump by hashing
+ * the stack trace. Each time if an identical trace is found in the stack, we
+ * dump only the pid of previous task. So it is easy to back track to the full
+ * stack with the pid.
+ *
+ * Note this chould be moved out of x86-specific code for all architectures
+ * use.
+ */
+
+/*
+ * DEDUP_STACK_HASH: pre-allocated buffer size of the hashtable.
+ * DEDUP_STACK_ENTRIES: number of task stack entries in hashtable.
+ * DEDUP_HASH_MAX_ITERATIONS: in hashtable lookup, retry serveral entries if
+ * there is a collision.
+ */
+#define DEDUP_STACK_HASH 32768
+#define DEDUP_STACK_ENTRIES (DEDUP_STACK_HASH/sizeof(struct task_stack))
+#define DEDUP_HASH_MAX_ITERATIONS 10
+
+/*
+ * The data structure of each hashtable entry
+ */
+struct task_stack {
+	/* the pid of the task of the stack trace */
+	pid_t pid;
+
+	/* the length of the stack entries */
+	int len;
+
+	/* the hash value of the stack trace*/
+	unsigned long hash;
+};
+
+static struct task_stack stack_hash_table[DEDUP_STACK_ENTRIES];
+static struct task_stack cur_stack;
+static __cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
+
+/*
+ * The stack hashtable uses linear probing to resolve collisions.
+ * We consider two stacks to be the same if their hash values and lengths
+ * are equal.
+ */
+static unsigned int stack_trace_lookup(void)
+{
+	int j;
+	int index;
+	unsigned int ret = 0;
+	struct task_stack *stack;
+
+	index = cur_stack.hash % DEDUP_STACK_ENTRIES;
+
+	for (j = 0; j < DEDUP_HASH_MAX_ITERATIONS; j++) {
+		stack = stack_hash_table + (index + j) % DEDUP_STACK_ENTRIES;
+		if (stack->hash == 0) {
+			*stack = cur_stack;
+			ret = 0;
+			break;
+		} else {
+			if (stack->hash == cur_stack.hash &&
+			    stack->len == cur_stack.len) {
+				ret = stack->pid;
+				break;
+			}
+		}
+	}
+	if (j == DEDUP_HASH_MAX_ITERATIONS)
+		stack_hash_table[index] = cur_stack;
+
+	memset(&cur_stack, 0, sizeof(cur_stack));
+
+	return ret;
+}
+
+static int save_dup_stack_stack(void *data, char *name)
+{
+	return 0;
+}
+
+static void save_dup_stack_address(void *data, unsigned long addr, int reliable)
+{
+	/*
+	 * To improve de-duplication, we'll only record reliable entries
+	 * in the stack trace.
+	 */
+	if (!reliable)
+		return;
+	cur_stack.hash = jhash(&addr, sizeof(addr), cur_stack.hash);
+	cur_stack.len++;
+}
+
+static const struct stacktrace_ops save_dup_stack_ops = {
+	.stack = save_dup_stack_stack,
+	.address = save_dup_stack_address,
+	.walk_stack = print_context_stack,
+};
+
+/*
+ * Clear previously saved stack traces to ensure that later printed stacks do
+ * not reference previously printed stacks.
+ */
+void clear_dup_stack_traces(void)
+{
+	memset(stack_hash_table, 0, sizeof(stack_hash_table));
+}
+
+unsigned int save_dup_stack_trace(struct task_struct *tsk)
+{
+	unsigned int ret = 0;
+	unsigned int dummy = 0;
+
+	spin_lock(&stack_hash_lock);
+	dump_trace(tsk, NULL, NULL, 0, &save_dup_stack_ops, &dummy);
+	cur_stack.pid = tsk->pid;
+	ret = stack_trace_lookup();
+	spin_unlock(&stack_hash_lock);
+
+	return ret;
+}
+
 /* Userspace stacktrace - based on kernel/trace/trace_sysprof.c */
 
 struct stack_frame_user {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 81a173c..7ac80e1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -298,6 +298,9 @@ extern void show_regs(struct pt_regs *);
  */
 extern void show_stack(struct task_struct *task, unsigned long *sp);
 
+extern void show_stack_dedup(struct task_struct *task, unsigned long *sp,
+				pid_t dup_stack_pid);
+
 void io_schedule(void);
 long io_schedule_timeout(long timeout);
 
diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index 115b570..c137416 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -21,6 +21,8 @@ extern void save_stack_trace_tsk(struct task_struct *tsk,
 
 extern void print_stack_trace(struct stack_trace *trace, int spaces);
 
+extern void clear_dup_stack_traces(void);
+extern unsigned int save_dup_stack_trace(struct task_struct *tsk);
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
 #else
@@ -32,6 +34,8 @@ extern void save_stack_trace_user(struct stack_trace *trace);
 # define save_stack_trace_tsk(tsk, trace)		do { } while (0)
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
+# define clear_dup_stack_traces()			do { } while (0)
+# define save_dup_stack_trace(tsk)			do { } while (0)
 #endif
 
 #endif
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 4603b9d..30c685b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -71,6 +71,7 @@
 #include <linux/ftrace.h>
 #include <linux/slab.h>
 #include <linux/init_task.h>
+#include <linux/stacktrace.h>
 #include <linux/binfmts.h>
 
 #include <asm/switch_to.h>
@@ -4828,10 +4829,11 @@ out_unlock:
 
 static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
 
-void sched_show_task(struct task_struct *p)
+void _sched_show_task(struct task_struct *p, int dedup)
 {
 	unsigned long free = 0;
 	unsigned state;
+	pid_t dup_stack_pid = 0;
 
 	state = p->state ? __ffs(p->state) + 1 : 0;
 	printk(KERN_INFO "%-15.15s %c", p->comm,
@@ -4854,13 +4856,37 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), task_pid_nr(rcu_dereference(p->real_parent)),
 		(unsigned long)task_thread_info(p)->flags);
 
-	show_stack(p, NULL);
+	if (dedup) {
+		dup_stack_pid = save_dup_stack_trace(p);
+		show_stack_dedup(p, NULL, dup_stack_pid);
+	} else
+		show_stack(p, NULL);
+}
+
+void sched_show_task(struct task_struct *p)
+{
+	_sched_show_task(p, 0);
+}
+
+/*
+ * Eliminate task stack trace duplication in multi-task stackdump.
+ * Note only x86-specific code now implements the feature.
+ */
+void sched_show_task_dedup(struct task_struct *p)
+{
+	_sched_show_task(p, 1);
 }
 
 void show_state_filter(unsigned long state_filter)
 {
 	struct task_struct *g, *p;
 
+	/*
+	 * Prevent below printed stack traces from referring to previously
+	 * printed ones.
+	 */
+	clear_dup_stack_traces();
+
 #if BITS_PER_LONG == 32
 	printk(KERN_INFO
 		"  task                PC stack   pid father\n");
@@ -4876,7 +4902,7 @@ void show_state_filter(unsigned long state_filter)
 		 */
 		touch_nmi_watchdog();
 		if (!state_filter || (p->state & state_filter))
-			sched_show_task(p);
+			sched_show_task_dedup(p);
 	} while_each_thread(g, p);
 
 	touch_all_softlockup_watchdogs();
diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index 00fe55c..85afece 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -41,3 +41,18 @@ save_stack_trace_regs(struct pt_regs *regs, struct stack_trace *trace)
 {
 	WARN_ONCE(1, KERN_INFO "save_stack_trace_regs() not implemented yet.\n");
 }
+
+/*
+ * Architectures that do not implement the task stack dedup will fallback to
+ * the default functionality.
+ */
+__weak void
+clear_dup_stack_traces(void)
+{
+}
+
+__weak unsigned int
+save_dup_stack_trace(struct task_struct *tsk)
+{
+	return 0;
+}
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
