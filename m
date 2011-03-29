Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A53338D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:29:00 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] Stack trace dedup
Date: Tue, 29 Mar 2011 10:28:16 -0700
Message-Id: <1301419696-2045-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

This doesn't build.
---
 arch/x86/Kconfig                  |    3 +
 arch/x86/include/asm/stacktrace.h |    2 +-
 arch/x86/kernel/dumpstack.c       |    5 +-
 arch/x86/kernel/dumpstack_64.c    |   10 +++-
 arch/x86/kernel/stacktrace.c      |  108 +++++++++++++++++++++++++++++++++++++
 include/linux/sched.h             |   10 +++-
 init/main.c                       |    1 +
 kernel/sched.c                    |   25 ++++++++-
 8 files changed, 154 insertions(+), 10 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 46d5be2..38597f2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -103,6 +103,9 @@ config LOCKDEP_SUPPORT
 config STACKTRACE_SUPPORT
 	def_bool y
 
+config STACKTRACE
+	def_bool y
+
 config HAVE_LATENCYTOP_SUPPORT
 	def_bool y
 
diff --git a/arch/x86/include/asm/stacktrace.h b/arch/x86/include/asm/stacktrace.h
index 52b5c7e..313be96 100644
--- a/arch/x86/include/asm/stacktrace.h
+++ b/arch/x86/include/asm/stacktrace.h
@@ -90,7 +90,7 @@ show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
 
 extern void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, char *log_lvl);
+		   unsigned long *sp, char *log_lvl, int index);
 
 extern unsigned int code_bytes;
 
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index b3f9a66..c7475da 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -187,9 +187,10 @@ void show_trace(struct task_struct *task, struct pt_regs *regs,
 	show_trace_log_lvl(task, regs, stack, "");
 }
 
-void show_stack(struct task_struct *task, unsigned long *sp)
+void show_stack(struct task_struct *task, unsigned long *sp,
+		int index)
 {
-	show_stack_log_lvl(task, NULL, sp, "");
+	show_stack_log_lvl(task, NULL, sp, "", index);
 }
 
 /*
diff --git a/arch/x86/kernel/dumpstack_64.c b/arch/x86/kernel/dumpstack_64.c
index a6b6fcf..956c074 100644
--- a/arch/x86/kernel/dumpstack_64.c
+++ b/arch/x86/kernel/dumpstack_64.c
@@ -225,7 +225,7 @@ EXPORT_SYMBOL(dump_trace);
 
 void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, char *log_lvl)
+		   unsigned long *sp, char *log_lvl, int index)
 {
 	unsigned long *irq_stack_end;
 	unsigned long *irq_stack;
@@ -269,7 +269,11 @@ show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
 	preempt_enable();
 
 	printk(KERN_CONT "\n");
-	show_trace_log_lvl(task, regs, sp, log_lvl);
+	if (index) {
+		printk(KERN_CONT "%sCall Trace:\n", log_lvl);
+		printk(KERN_CONT "<Same stack as pid %d>\n\n", index);
+	} else
+		show_trace_log_lvl(task, regs, sp, log_lvl);
 }
 
 void show_registers(struct pt_regs *regs)
@@ -298,7 +302,7 @@ void show_registers(struct pt_regs *regs)
 
 		printk(KERN_EMERG "Stack:\n");
 		show_stack_log_lvl(NULL, regs, (unsigned long *)sp,
-				   KERN_EMERG);
+				   KERN_EMERG, 0);
 
 		printk(KERN_EMERG "Code: ");
 
diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index 938c8e1..1475141 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/uaccess.h>
 #include <asm/stacktrace.h>
+#include <linux/jhash.h>
 
 static void save_stack_warning(void *data, char *msg)
 {
@@ -94,6 +95,113 @@ void save_stack_trace_tsk(struct task_struct *tsk, struct stack_trace *trace)
 }
 EXPORT_SYMBOL_GPL(save_stack_trace_tsk);
 
+#define DEDUP_MAX_STACK_DEPTH 32
+#define DEDUP_STACK_HASH 32768
+#define DEDUP_STACK_ENTRY (DEDUP_STACK_HASH/sizeof(struct task_stack) - 1)
+
+struct task_stack {
+	pid_t pid;
+	unsigned long entries[DEDUP_MAX_STACK_DEPTH];
+};
+
+struct task_stack *stack_hash_table;
+static struct task_stack *cur_stack;
+__cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
+
+void __init stack_trace_hash_init(void)
+{
+	stack_hash_table = vmalloc(DEDUP_STACK_HASH);
+	cur_stack = stack_hash_table + DEDUP_STACK_ENTRY;
+}
+
+void stack_trace_hash_clean(void)
+{
+	memset(stack_hash_table, 0, DEDUP_STACK_HASH);
+}
+
+static inline u32 task_stack_hash(struct task_stack *stack, int len)
+{
+	u32 index = jhash(stack->entries, len * sizeof(unsigned long), 0);
+
+	return index;
+}
+
+static unsigned int stack_trace_lookup(int len)
+{
+	int j;
+	int index = 0;
+	unsigned int ret = 0;
+	struct task_stack *stack;
+
+	index = task_stack_hash(cur_stack, len) % DEDUP_STACK_ENTRY;
+
+	for (j = 0; j < 10; j++) {
+		stack = stack_hash_table + (index + (1 << j)) % DEDUP_STACK_ENTRY;
+		if (stack->entries[0] == 0x0) {
+			memcpy(stack, cur_stack, sizeof(*cur_stack));
+			ret = 0;
+			break;
+		} else {
+			if (memcmp(stack->entries, cur_stack->entries,
+						sizeof(stack->entries)) == 0) {
+				ret = stack->pid;
+				break;
+			}
+		}
+	}
+	memset(cur_stack, 0, sizeof(struct task_stack));
+
+	return ret;
+}
+
+static void save_dup_stack_warning(void *data, char *msg)
+{
+}
+
+static void
+save_dup_stack_warning_symbol(void *data, char *msg, unsigned long symbol)
+{
+}
+
+static int save_dup_stack_stack(void *data, char *name)
+{
+	return -1;
+}
+
+static void save_dup_stack_address(void *data, unsigned long addr, int reliable)
+{
+	unsigned int *len = data;
+
+	if (*len < DEDUP_MAX_STACK_DEPTH)
+		cur_stack->entries[*len] = addr;
+	(*len)++;
+}
+
+static const struct stacktrace_ops save_dup_stack_ops = {
+	.warning = save_dup_stack_warning,
+	.warning_symbol = save_dup_stack_warning_symbol,
+	.stack = save_dup_stack_stack,
+	.address = save_dup_stack_address,
+};
+
+unsigned int save_dup_stack_trace(struct stack_trace *trace)
+{
+	unsigned int ret = 0;
+	int len = 0;
+
+
+	dump_trace(tsk, NULL, NULL, &save_dup_stack_ops, trace);
+	if (len >= DEDUP_MAX_STACK_DEPTH) {
+		memset(cur_stack, 0, sizeof(struct task_stack));
+		return ret;
+	}
+
+	ur_stack->pid = tsk->pid;
+	ret = stack_trace_lookup(len);
+
+	return ret;
+}
+
 /* Userspace stacktrace - based on kernel/trace/trace_sysprof.c */
 
 struct stack_frame_user {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 98fc7ed..1d01f51 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -277,6 +277,13 @@ extern int get_nohz_timer_target(void);
 static inline void select_nohz_load_balancer(int stop_tick) { }
 #endif
 
+extern void __init stack_trace_hash_init(void);
+extern void stack_trace_hash_clean(void);
+extern unsigned int save_dup_stack_trace(struct task_struct *tsk);
+
+extern spinlock_t stack_hash_lock;
+extern struct task_stack *stack_hash_table;
+
 /*
  * Only dump TASK_* tasks. (0 for all tasks)
  */
@@ -294,7 +301,7 @@ extern void show_regs(struct pt_regs *);
  * task), SP is the stack pointer of the first frame that should be shown in the back
  * trace (or NULL if the entire call-chain of the task should be shown).
  */
-extern void show_stack(struct task_struct *task, unsigned long *sp);
+extern void show_stack(struct task_struct *task, unsigned long *sp, int index);
 
 void io_schedule(void);
 long io_schedule_timeout(long timeout);
@@ -305,6 +312,7 @@ extern void update_process_times(int user);
 extern void scheduler_tick(void);
 
 extern void sched_show_task(struct task_struct *p);
+extern void sched_show_task_dedup(struct task_struct *p);
 
 #ifdef CONFIG_LOCKUP_DETECTOR
 extern void touch_softlockup_watchdog(void);
diff --git a/init/main.c b/init/main.c
index 4a9479e..8255ac5 100644
--- a/init/main.c
+++ b/init/main.c
@@ -614,6 +614,7 @@ asmlinkage void __init start_kernel(void)
 	taskstats_init_early();
 	delayacct_init();
 
+	stack_trace_hash_init();
 	check_bugs();
 
 	acpi_early_init(); /* before LAPIC and SMP init */
diff --git a/kernel/sched.c b/kernel/sched.c
index f4c2ec2..bba538a 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5648,10 +5648,11 @@ out_unlock:
 
 static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
 
-void sched_show_task(struct task_struct *p)
+void _sched_show_task(struct task_struct *p, int dedup)
 {
 	unsigned long free = 0;
 	unsigned state;
+	int index = 0;
 
 	state = p->state ? __ffs(p->state) + 1 : 0;
 	printk(KERN_INFO "%-15.15s %c", p->comm,
@@ -5674,7 +5675,20 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), task_pid_nr(p->real_parent),
 		(unsigned long)task_thread_info(p)->flags);
 
-	show_stack(p, NULL);
+//	show_stack(p, NULL);
+	if (dedup && stack_hash_table)
+		index = save_dup_stack_trace(p);
+	show_stack(p, NULL, index);
+}
+
+void sched_show_task(struct task_struct *p)
+{
+	_sched_show_task(p, 0);
+}
+
+void sched_show_task_dedup(struct task_struct *p)
+{
+	_sched_show_task(p, 1);
 }
 
 void show_state_filter(unsigned long state_filter)
@@ -5689,6 +5703,10 @@ void show_state_filter(unsigned long state_filter)
 		"  task                        PC stack   pid father\n");
 #endif
 	read_lock(&tasklist_lock);
+
+	spin_lock(&stack_hash_lock);
+	stack_trace_hash_clean();
+
 	do_each_thread(g, p) {
 		/*
 		 * reset the NMI-timeout, listing all files on a slow
@@ -5696,9 +5714,10 @@ void show_state_filter(unsigned long state_filter)
 		 */
 		touch_nmi_watchdog();
 		if (!state_filter || (p->state & state_filter))
-			sched_show_task(p);
+			sched_show_task_dedup(p);
 	} while_each_thread(g, p);
 
+	spin_unlock(&stack_hash_lock);
 	touch_all_softlockup_watchdogs();
 
 #ifdef CONFIG_SCHED_DEBUG
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
