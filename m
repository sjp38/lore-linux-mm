Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 435566B0023
	for <linux-mm@kvack.org>; Tue,  3 May 2011 13:36:50 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] Eliminate task stack trace duplication.
Date: Tue,  3 May 2011 10:35:34 -0700
Message-Id: <1304444135-14128-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Salman Qazi <sqazi@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

The problem with small dmesg ring buffer like 512k is that only limited number
of task traces will be logged. Sometimes we lose important information only
because of too many duplicated stack traces.

This patch tries to reduce the duplication of task stack trace in the dump
message by hashing the task stack. The hashtable is a 32k pre-allocated buffer
during bootup.

Sample output:

[  491.283527] kworker/0:0     S 0000000000000000     0     4      2 0x00000000
[  491.283532]  ffff88082fcf5e80 0000000000000046 ffff88085fc0dfc0 ffff88085f805c00
[  491.283536]  ffff88082fcf4010 ffff88082fce9830 0000000000011940 ffff88082fcf5fd8
[  491.283539]  ffff88082fcf5fd8 0000000000011940 ffff88082fce8000 ffff88082fce9830
[  491.283543] Call Trace:
[  491.283546]  [<ffffffff8108417a>] worker_thread+0x24b/0x250
[  491.283549]  [<ffffffff81083f2f>] ? worker_thread+0x0/0x250
[  491.283552]  [<ffffffff810874dd>] kthread+0x82/0x8a
[  491.283555]  [<ffffffff814120d4>] kernel_thread_helper+0x4/0x10
[  491.283558]  [<ffffffff8108745b>] ? kthread+0x0/0x8a
[  491.283560]  [<ffffffff814120d0>] ? kernel_thread_helper+0x0/0x10

[  491.283630] kworker/1:0     S 0000000000000001     0     8      2 0x00000000
[  491.283636]  ffff88082fd27e80 0000000000000046 ffff88082fd27e20 ffff88082fd16080
[  491.283639]  ffff88082fd26010 ffff88082fceb870 0000000000011940 ffff88082fd27fd8
[  491.283643]  ffff88082fd27fd8 0000000000011940 ffff88082ffbd0a0 ffff88082fceb870
[  491.283647] Call Trace:
[  491.283648] <Same stack as pid 4>

[  491.283710] kworker/2:0     S 0000000000000002     0    12      2 0x00000000
[  491.283715]  ffff88082fd35e80 0000000000000046 ffff88082fd35e20 ffff88082fd16400
[  491.283719]  ffff88082fd34010 ffff88082fcee0c0 0000000000011940 ffff88082fd35fd8
[  491.283723]  ffff88082fd35fd8 0000000000011940 ffff88082ffbc890 ffff88082fcee0c0
[  491.283726] Call Trace:
[  491.283728] <Same stack as pid 4>

Signed-off-by: Ying Han <yinghan@google.com>
---
 arch/x86/Kconfig                  |    3 +
 arch/x86/include/asm/stacktrace.h |    4 +-
 arch/x86/kernel/dumpstack.c       |   18 ++++--
 arch/x86/kernel/dumpstack_32.c    |    6 +-
 arch/x86/kernel/dumpstack_64.c    |   10 +++-
 arch/x86/kernel/pci-gart_64.c     |    2 +-
 arch/x86/kernel/stacktrace.c      |  109 +++++++++++++++++++++++++++++++++++++
 drivers/tty/sysrq.c               |    2 +-
 include/linux/sched.h             |    9 +++-
 init/main.c                       |    1 +
 kernel/debug/kdb/kdb_bt.c         |    8 ++--
 kernel/rtmutex-debug.c            |    2 +-
 kernel/sched.c                    |   24 +++++++-
 13 files changed, 173 insertions(+), 25 deletions(-)

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
index 52b5c7e..f78ec95 100644
--- a/arch/x86/include/asm/stacktrace.h
+++ b/arch/x86/include/asm/stacktrace.h
@@ -86,11 +86,11 @@ stack_frame(struct task_struct *task, struct pt_regs *regs)
 
 extern void
 show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *stack, char *log_lvl);
+		   unsigned long *stack, char *log_lvl, int index);
 
 extern void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, char *log_lvl);
+		   unsigned long *sp, char *log_lvl, int index);
 
 extern unsigned int code_bytes;
 
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index b3f9a66..c93ac30 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -175,21 +175,27 @@ static const struct stacktrace_ops print_trace_ops = {
 
 void
 show_trace_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		unsigned long *stack, char *log_lvl)
+		unsigned long *stack, char *log_lvl, int index)
 {
-	printk("%sCall Trace:\n", log_lvl);
-	dump_trace(task, regs, stack, &print_trace_ops, log_lvl);
+	if (index) {
+		printk("%sCall Trace:\n", log_lvl);
+		printk("<Same stack as pid %d>\n\n", index);
+	} else {
+		printk("%sCall Trace:\n", log_lvl);
+		dump_trace(task, regs, stack, &print_trace_ops, log_lvl);
+	}
 }
 
 void show_trace(struct task_struct *task, struct pt_regs *regs,
 		unsigned long *stack)
 {
-	show_trace_log_lvl(task, regs, stack, "");
+	show_trace_log_lvl(task, regs, stack, "", 0);
 }
 
-void show_stack(struct task_struct *task, unsigned long *sp)
+void show_stack(struct task_struct *task, unsigned long *sp,
+		int index)
 {
-	show_stack_log_lvl(task, NULL, sp, "");
+	show_stack_log_lvl(task, NULL, sp, "", index);
 }
 
 /*
diff --git a/arch/x86/kernel/dumpstack_32.c b/arch/x86/kernel/dumpstack_32.c
index 74cc1ed..b824a13 100644
--- a/arch/x86/kernel/dumpstack_32.c
+++ b/arch/x86/kernel/dumpstack_32.c
@@ -55,7 +55,7 @@ EXPORT_SYMBOL(dump_trace);
 
 void
 show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
-		   unsigned long *sp, char *log_lvl)
+		   unsigned long *sp, char *log_lvl, int index)
 {
 	unsigned long *stack;
 	int i;
@@ -77,7 +77,7 @@ show_stack_log_lvl(struct task_struct *task, struct pt_regs *regs,
 		touch_nmi_watchdog();
 	}
 	printk(KERN_CONT "\n");
-	show_trace_log_lvl(task, regs, sp, log_lvl);
+	show_trace_log_lvl(task, regs, sp, log_lvl, index);
 }
 
 
@@ -102,7 +102,7 @@ void show_registers(struct pt_regs *regs)
 		u8 *ip;
 
 		printk(KERN_EMERG "Stack:\n");
-		show_stack_log_lvl(NULL, regs, &regs->sp, KERN_EMERG);
+		show_stack_log_lvl(NULL, regs, &regs->sp, KERN_EMERG, 0);
 
 		printk(KERN_EMERG "Code: ");
 
diff --git a/arch/x86/kernel/dumpstack_64.c b/arch/x86/kernel/dumpstack_64.c
index a6b6fcf..46bef00 100644
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
+		show_trace_log_lvl(task, regs, sp, log_lvl, index);
 }
 
 void show_registers(struct pt_regs *regs)
@@ -298,7 +302,7 @@ void show_registers(struct pt_regs *regs)
 
 		printk(KERN_EMERG "Stack:\n");
 		show_stack_log_lvl(NULL, regs, (unsigned long *)sp,
-				   KERN_EMERG);
+				   KERN_EMERG, 0);
 
 		printk(KERN_EMERG "Code: ");
 
diff --git a/arch/x86/kernel/pci-gart_64.c b/arch/x86/kernel/pci-gart_64.c
index c01ffa5..3b8f523 100644
--- a/arch/x86/kernel/pci-gart_64.c
+++ b/arch/x86/kernel/pci-gart_64.c
@@ -162,7 +162,7 @@ static void dump_leak(void)
 		return;
 	dump = 1;
 
-	show_stack(NULL, NULL);
+	show_stack(NULL, NULL, 0);
 	debug_dma_dump_mappings(NULL);
 }
 #endif
diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index 938c8e1..a600ce6 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -8,6 +8,7 @@
 #include <linux/module.h>
 #include <linux/uaccess.h>
 #include <asm/stacktrace.h>
+#include <linux/jhash.h>
 
 static void save_stack_warning(void *data, char *msg)
 {
@@ -94,6 +95,114 @@ void save_stack_trace_tsk(struct task_struct *tsk, struct stack_trace *trace)
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
+		stack = stack_hash_table + (index + (1 << j)) %
+						DEDUP_STACK_ENTRY;
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
+	dump_trace(tsk, NULL, NULL, &save_dup_stack_ops, &len);
+	if (len >= DEDUP_MAX_STACK_DEPTH) {
+		memset(cur_stack, 0, sizeof(struct task_stack));
+		return ret;
+	}
+
+	cur_stack->pid = tsk->pid;
+	ret = stack_trace_lookup(len);
+
+	return ret;
+}
+
 /* Userspace stacktrace - based on kernel/trace/trace_sysprof.c */
 
 struct stack_frame_user {
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index 81f1395..38f4669 100644
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
index 98fc7ed..8066c39 100644
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
index f4c2ec2..b7d66ff 100644
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
@@ -5674,7 +5675,19 @@ void sched_show_task(struct task_struct *p)
 		task_pid_nr(p), task_pid_nr(p->real_parent),
 		(unsigned long)task_thread_info(p)->flags);
 
-	show_stack(p, NULL);
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
@@ -5689,6 +5702,10 @@ void show_state_filter(unsigned long state_filter)
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
@@ -5696,9 +5713,10 @@ void show_state_filter(unsigned long state_filter)
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
