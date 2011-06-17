Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E3ACE6B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 20:20:06 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V3] Eliminate task stack trace duplication.
Date: Thu, 16 Jun 2011 17:19:15 -0700
Message-Id: <1308269955-1878-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The problem with small dmesg ring buffer like 512k is that only limited number
of task traces will be logged. Sometimes we lose important information only
because of too many duplicated stack traces. This problem occurs when dumping
lots of stacks in a single operation, such as sysrq-T.

This patch tries to reduce the duplication of task stack trace in the dump
message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
during bootup. Then we hash the task stack with stack_depth 32 for each stack
entry. Each time if we find the identical task trace in the task stack, we dump
only the pid of the task which has the task trace dumped. So it is easy to back
track to the full stack with the pid.

[   58.469730] kworker/0:0     S 0000000000000000     0     4      2 0x00000000
[   58.469735]  ffff88082fcfde80 0000000000000046 ffff88082e9d8000 ffff88082fcfc010
[   58.469739]  ffff88082fce9860 0000000000011440 ffff88082fcfdfd8 ffff88082fcfdfd8
[   58.469743]  0000000000011440 0000000000000000 ffff88082fcee180 ffff88082fce9860
[   58.469747] Call Trace:
[   58.469751]  [<ffffffff8108525a>] worker_thread+0x24b/0x250
[   58.469754]  [<ffffffff8108500f>] ? manage_workers+0x192/0x192
[   58.469757]  [<ffffffff810885bd>] kthread+0x82/0x8a
[   58.469760]  [<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
[   58.469763]  [<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
[   58.469765]  [<ffffffff8141aed0>] ? gs_change+0xb/0xb
[   58.469768] kworker/u:0     S 0000000000000004     0     5      2 0x00000000
[   58.469773]  ffff88082fcffe80 0000000000000046 ffff880800000000 ffff88082fcfe010
[   58.469777]  ffff88082fcea080 0000000000011440 ffff88082fcfffd8 ffff88082fcfffd8
[   58.469781]  0000000000011440 0000000000000000 ffff88082fd4e9a0 ffff88082fcea080
[   58.469785] Call Trace:
[   58.469786] <Same stack as pid 4>
[   58.470235] kworker/0:1     S 0000000000000000     0    13      2 0x00000000
[   58.470255]  ffff88082fd3fe80 0000000000000046 ffff880800000000 ffff88082fd3e010
[   58.470279]  ffff88082fcee180 0000000000011440 ffff88082fd3ffd8 ffff88082fd3ffd8
[   58.470301]  0000000000011440 0000000000000000 ffffffff8180b020 ffff88082fcee180
[   58.470325] Call Trace:
[   58.470332] <Same stack as pid 4>

changelog v3..v2:
1. again better documentation on the patch description.
2. make the stack_hash_table to be allocated at compile time.
3. have better name of variable index
4. move save_dup_stack_trace() in kernel/stacktrace.c

changelog v2..v1:
1. better documentation on the patch description
2. move the spinlock inside the hash lockup, so reducing the holding time.

Note:
1. sometimes we have garbage in the task stack (like ?) and doing memcmp might not
be the best solution. andrew suggested to use stack unwounding machinary. i wonder
the tradeoff of adding the complexity in the code.
2. with pid namespace, we might have same pid number for different processes. i
wonder how the stack trace (w/o dedup) handles the case, it uses tsk->pid as well
as far as i checked.

Signed-off-by: Ying Han <yinghan@google.com>
---
 arch/x86/Kconfig                  |    3 +
 arch/x86/include/asm/stacktrace.h |    6 +-
 arch/x86/kernel/dumpstack.c       |   24 ++++++--
 arch/x86/kernel/dumpstack_32.c    |    7 +-
 arch/x86/kernel/dumpstack_64.c    |   11 +++-
 arch/x86/kernel/pci-gart_64.c     |    2 +-
 arch/x86/kernel/stacktrace.c      |  110 +++++++++++++++++++++++++++++++++++++
 drivers/tty/sysrq.c               |    2 +-
 include/linux/sched.h             |    3 +-
 include/linux/stacktrace.h        |    2 +
 kernel/debug/kdb/kdb_bt.c         |    8 +-
 kernel/rtmutex-debug.c            |    2 +-
 kernel/sched.c                    |   20 ++++++-
 kernel/stacktrace.c               |   10 +++
 14 files changed, 185 insertions(+), 25 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cc6c53a..f0ff309 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -105,6 +105,9 @@ config LOCKDEP_SUPPORT
 config STACKTRACE_SUPPORT
 	def_bool y
 
+config STACKTRACE
+	def_bool y
+
 config HAVE_LATENCYTOP_SUPPORT
 	def_bool y
 
diff --git a/arch/x86/include/asm/stacktrace.h b/arch/x86/include/asm/stacktrace.h
index d7e89c8..5d89097 100644
--- a/arch/x86/include/asm/stacktrace.h
+++ b/arch/x86/include/asm/stacktrace.h
@@ -86,11 +86,13 @@ stack_frame(struct task_struct *task, struct pt_regs *regs)
 
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
index e2a3f06..2eb5805 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -173,23 +173,35 @@ static const struct stacktrace_ops print_trace_ops = {
 	.walk_stack		= print_context_stack,
 };
 
+/*
+ * The dup_stack_pid indicates whether or not a duplication of stack trace
+ * has been recorded. The non-zero value indicates the pid of the task with
+ * the same stack trace.
+ */
 void
 show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		unsigned long *stack, unsigned long bp, char *log_lvl)
+		unsigned long *stack, unsigned long bp, char *log_lvl,
+		pid_t dup_stack_pid)
 {
-	printk("%sCall Trace:\n", log_lvl);
-	dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl);
+	if (dup_stack_pid) {
+		printk("%sCall Trace:\n", log_lvl);
+		printk("<Same stack as pid %d>\n\n", dup_stack_pid);
+	} else {
+		printk("%sCall Trace:\n", log_lvl);
+		dump_trace(task, regs, stack, bp, &print_trace_ops, log_lvl);
+	}
 }
 
 void show_trace(struct task_struct *task, struct pt_regs *regs,
 		unsigned long *stack, unsigned long bp)
 {
-	show_trace_log_lvl(task, regs, stack, bp, "");
+	show_trace_log_lvl(task, regs, stack, bp, "", 0);
 }
 
-void show_stack(struct task_struct *task, unsigned long *sp)
+void show_stack(struct task_struct *task, unsigned long *sp,
+		pid_t dup_stack_pid)
 {
-	show_stack_log_lvl(task, NULL, sp, 0, "");
+	show_stack_log_lvl(task, NULL, sp, 0, "", dup_stack_pid);
 }
 
 /*
diff --git a/arch/x86/kernel/dumpstack_32.c b/arch/x86/kernel/dumpstack_32.c
index 3b97a80..bd06106 100644
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
index e71c98d..1d274b8 100644
--- a/arch/x86/kernel/dumpstack_64.c
+++ b/arch/x86/kernel/dumpstack_64.c
@@ -225,7 +225,8 @@ EXPORT_SYMBOL(dump_trace);
 
 void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, unsigned long bp, char *log_lvl)
+		   unsigned long *sp, unsigned long bp, char *log_lvl,
+		   pid_t dup_stack_pid)
 {
 	unsigned long *irq_stack_end;
 	unsigned long *irq_stack;
@@ -269,7 +270,11 @@ show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
 	preempt_enable();
 
 	printk(KERN_CONT "\n");
-	show_trace_log_lvl(task, regs, sp, bp, log_lvl);
+	if (dup_stack_pid) {
+		printk(KERN_CONT "%sCall Trace:\n", log_lvl);
+		printk(KERN_CONT "<Same stack as pid %d>\n\n", dup_stack_pid);
+	} else
+		show_trace_log_lvl(task, regs, sp, bp, log_lvl, dup_stack_pid);
 }
 
 void show_registers(struct pt_regs *regs)
@@ -298,7 +303,7 @@ void show_registers(struct pt_regs *regs)
 
 		printk(KERN_EMERG "Stack:\n");
 		show_stack_log_lvl(NULL, regs, (unsigned long *)sp,
-				   0, KERN_EMERG);
+				   0, KERN_EMERG, 0);
 
 		printk(KERN_EMERG "Code: ");
 
diff --git a/arch/x86/kernel/pci-gart_64.c b/arch/x86/kernel/pci-gart_64.c
index b117efd..cc4a70d 100644
--- a/arch/x86/kernel/pci-gart_64.c
+++ b/arch/x86/kernel/pci-gart_64.c
@@ -165,7 +165,7 @@ static void dump_leak(void)
 		return;
 	dump = 1;
 
-	show_stack(NULL, NULL);
+	show_stack(NULL, NULL, 0);
 	debug_dma_dump_mappings(NULL);
 }
 #endif
diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index 6515733..112a30e 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/uaccess.h>
 #include <asm/stacktrace.h>
+#include <linux/jhash.h>
 
 static void save_stack_warning(void *data, char *msg)
 {
@@ -94,6 +95,115 @@ void save_stack_trace_tsk(struct task_struct *tsk, struct stack_trace *trace)
 }
 EXPORT_SYMBOL_GPL(save_stack_trace_tsk);
 
+/*
+ * The implementation of stack trace dedup. It tries to reduce the duplication
+ * of task stack trace in the dump by hashing the stack trace. The hashtable is
+ * 32k pre-allocated buffer. Then we hash the task stack with stack_depth
+ * DEDUP_MAX_STACK_DEPTH for each stack entry. Each time if an identical trace
+ * is found in the stack, we dump only the pid of previous task. So it is easy
+ * to back track to the full stack with the pid.
+ */
+#define DEDUP_MAX_STACK_DEPTH 32
+#define DEDUP_STACK_HASH 32768
+#define DEDUP_STACK_ENTRY (DEDUP_STACK_HASH/sizeof(struct task_stack))
+#define DEDUP_STACK_LAST_ENTRY (DEDUP_STACK_ENTRY - 1)
+
+struct task_stack {
+	pid_t pid;
+	unsigned long entries[DEDUP_MAX_STACK_DEPTH];
+};
+
+struct task_stack stack_hash_table[DEDUP_STACK_ENTRY];
+static struct task_stack *cur_stack = stack_hash_table + DEDUP_STACK_LAST_ENTRY;
+__cacheline_aligned_in_smp DEFINE_SPINLOCK(stack_hash_lock);
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
+	index = task_stack_hash(cur_stack, len) % DEDUP_STACK_LAST_ENTRY;
+
+	for (j = 0; j < 10; j++) {
+		stack = stack_hash_table + (index + (1 << j)) %
+						DEDUP_STACK_LAST_ENTRY;
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
+	return 0;
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
+	.walk_stack = print_context_stack,
+};
+
+unsigned int save_dup_stack_trace(struct task_struct *tsk)
+{
+	unsigned int ret = 0;
+	int len = 0;
+
+	spin_lock(&stack_hash_lock);
+	dump_trace(tsk, NULL, NULL, 0, &save_dup_stack_ops, &len);
+	if (len >= DEDUP_MAX_STACK_DEPTH) {
+		memset(cur_stack, 0, sizeof(struct task_stack));
+		spin_unlock(&stack_hash_lock);
+		return ret;
+	}
+
+	cur_stack->pid = tsk->pid;
+	ret = stack_trace_lookup(len);
+	spin_unlock(&stack_hash_lock);
+
+	return ret;
+}
+
 /* Userspace stacktrace - based on kernel/trace/trace_sysprof.c */
 
 struct stack_frame_user {
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 43db715..1165464 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -214,7 +214,7 @@ static void showacpu(void *dummy)
 
 	spin_lock_irqsave(&show_lock, flags);
 	printk(KERN_INFO "CPU%d:\n", smp_processor_id());
-	show_stack(NULL, NULL);
+	show_stack(NULL, NULL, 0);
 	spin_unlock_irqrestore(&show_lock, flags);
 }
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 781abd1..ef86213 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -295,7 +295,8 @@ extern void show_regs(struct pt_regs *);
  * task), SP is the stack pointer of the first frame that should be shown in the back
  * trace (or NULL if the entire call-chain of the task should be shown).
  */
-extern void show_stack(struct task_struct *task, unsigned long *sp);
+extern void show_stack(struct task_struct *task, unsigned long *sp,
+			pid_t dup_stack_pid);
 
 void io_schedule(void);
 long io_schedule_timeout(long timeout);
diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index 25310f1..ce4d187 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -21,6 +21,7 @@ extern void save_stack_trace_tsk(struct task_struct *tsk,
 
 extern void print_stack_trace(struct stack_trace *trace, int spaces);
 
+extern unsigned int save_dup_stack_trace(struct task_struct *tsk);
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
 #else
@@ -32,6 +33,7 @@ extern void save_stack_trace_user(struct stack_trace *trace);
 # define save_stack_trace_tsk(tsk, trace)		do { } while (0)
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
+# define save_dup_stack_trace(tsk)			do { } while (0)
 #endif
 
 #endif
diff --git a/kernel/debug/kdb/kdb_bt.c b/kernel/debug/kdb/kdb_bt.c
index 2f62fe8..ff8c6ad 100644
--- a/kernel/debug/kdb/kdb_bt.c
+++ b/kernel/debug/kdb/kdb_bt.c
@@ -26,15 +26,15 @@ static void kdb_show_stack(struct task_struct *p, void *addr)
 	kdb_trap_printk++;
 	kdb_set_current_task(p);
 	if (addr) {
-		show_stack((struct task_struct *)p, addr);
+		show_stack((struct task_struct *)p, addr, 0);
 	} else if (kdb_current_regs) {
 #ifdef CONFIG_X86
-		show_stack(p, &kdb_current_regs->sp);
+		show_stack(p, &kdb_current_regs->sp, 0);
 #else
-		show_stack(p, NULL);
+		show_stack(p, NULL, 0);
 #endif
 	} else {
-		show_stack(p, NULL);
+		show_stack(p, NULL, 0);
 	}
 	console_loglevel = old_lvl;
 	kdb_trap_printk--;
diff --git a/kernel/rtmutex-debug.c b/kernel/rtmutex-debug.c
index 3c7cbc2..e636067 100644
--- a/kernel/rtmutex-debug.c
+++ b/kernel/rtmutex-debug.c
@@ -171,7 +171,7 @@ void debug_rt_mutex_print_deadlock(struct rt_mutex_waiter *waiter)
 
 	printk("\n%s/%d's [blocked] stackdump:\n\n",
 		task->comm, task_pid_nr(task));
-	show_stack(task, NULL);
+	show_stack(task, NULL, 0);
 	printk("\n%s/%d's [current] stackdump:\n\n",
 		current->comm, task_pid_nr(current));
 	dump_stack();
diff --git a/kernel/sched.c b/kernel/sched.c
index 312f8b9..9167d29 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -5672,10 +5672,11 @@ out_unlock:
 
 static const char stat_nam[] = TASK_STATE_TO_CHAR_STR;
 
-void sched_show_task(struct task_struct *p)
+void _sched_show_task(struct task_struct *p, int dedup)
 {
 	unsigned long free = 0;
 	unsigned state;
+	pid_t dup_stack_pid = 0;
 
 	state = p->state ? __ffs(p->state) + 1 : 0;
 	printk(KERN_INFO "%-15.15s %c", p->comm,
@@ -5698,7 +5699,19 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), task_pid_nr(p->real_parent),
 		(unsigned long)task_thread_info(p)->flags);
 
-	show_stack(p, NULL);
+	if (dedup)
+		dup_stack_pid = save_dup_stack_trace(p);
+	show_stack(p, NULL, dup_stack_pid);
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
@@ -5713,6 +5726,7 @@ void show_state_filter(unsigned long state_filter)
 		"  task                        PC stack   pid father\n");
 #endif
 	read_lock(&tasklist_lock);
+
 	do_each_thread(g, p) {
 		/*
 		 * reset the NMI-timeout, listing all files on a slow
@@ -5720,7 +5734,7 @@ void show_state_filter(unsigned long state_filter)
 		 */
 		touch_nmi_watchdog();
 		if (!state_filter || (p->state & state_filter))
-			sched_show_task(p);
+			sched_show_task_dedup(p);
 	} while_each_thread(g, p);
 
 	touch_all_softlockup_watchdogs();
diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index eb212f8..39f17e7 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -35,3 +35,13 @@ save_stack_trace_tsk(struct task_struct *tsk, struct stack_trace *trace)
 {
 	WARN_ONCE(1, KERN_INFO "save_stack_trace_tsk() not implemented yet.\n");
 }
+
+/*
+ * Architectures that do not implement the task stack dedup will fallback to
+ * the default functionality.
+ */
+__weak unsigned int
+save_dup_stack_trace(struct task_struct *tsk)
+{
+	return 0;
+}
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
