Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C964A90011E
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 04:22:59 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p658GaMg001970
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:16:36 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p658MtCw507954
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:22:55 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p658MtmQ029577
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:22:55 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 1/5] Core kernel backend to capture the memory reference pattern
Date: Tue,  5 Jul 2011 13:52:35 +0530
Message-Id: <1309854159-8277-2-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi,

This patch adds data structure and memory for the capturing the
reference pattern.  At system boot time, an array memtrace_memblock is
created with information about memory blocks of size 64MB. Memory
references are captured at the granularity of these memory blocks. Even
when a single page within a memory block is referred in sampling interval,
the complete block of memory is marked as being referenced by the kernel.
Whether to mark the block as being referenced or not is indicated by the
kernel module, introduced in patch 2/3.

TODO:
- The access_flag field of the memtrace_block_accessed array can be used as
  a count of the number of times the pages in that memory block were accessed,
  instead of a simple 1 or 0 value

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 include/linux/memtrace.h |   29 ++++++++++++
 include/linux/sched.h    |    4 ++
 kernel/fork.c            |    6 +++
 lib/Kconfig.debug        |    4 ++
 lib/Makefile             |    1 +
 lib/memtrace.c           |  108 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 152 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/memtrace.h
 create mode 100644 lib/memtrace.c

diff --git a/include/linux/memtrace.h b/include/linux/memtrace.h
new file mode 100644
index 0000000..0fa15e0
--- /dev/null
+++ b/include/linux/memtrace.h
@@ -0,0 +1,29 @@
+#ifndef _LINUX_MEMTRACE_H
+#define _LINUX_MEMTRACE_H
+
+#include <linux/types.h>
+#include <linux/sched.h>
+
+extern pid_t pg_trace_pid;
+
+struct memtrace_block {
+	unsigned int    seq;
+	unsigned long	access_flag;
+};
+
+#define MAX_MEMTRACE_BLOCK 512
+
+pid_t get_pg_trace_pid(void);
+void set_pg_trace_pid(pid_t pid);
+void set_mem_trace(struct task_struct *tsk, int flag);
+void set_task_seq(struct task_struct *tsk, unsigned int seq);
+unsigned int get_task_seq(struct task_struct *tsk);
+void init_seq_number(void);
+unsigned int get_seq_number(void);
+unsigned int inc_seq_number(void);
+void set_memtrace_block_sz(int sz);
+void mark_memtrace_block_accessed(unsigned long paddr);
+void init_memtrace_blocks(void);
+void update_and_log_data(void);
+
+#endif /* _LINUX_MEMTRACE_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index a837b20..bbf6973 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1473,6 +1473,10 @@ struct task_struct {
 	u64 acct_vm_mem1;	/* accumulated virtual memory usage */
 	cputime_t acct_timexpd;	/* stime + utime since last update */
 #endif
+#if defined(CONFIG_MEMTRACE)
+	unsigned int mem_trace;
+	unsigned int seq;
+#endif
 #ifdef CONFIG_CPUSETS
 	nodemask_t mems_allowed;	/* Protected by alloc_lock */
 	int mems_allowed_change_disable;
diff --git a/kernel/fork.c b/kernel/fork.c
index 0276c30..361413d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1153,6 +1153,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	p->default_timer_slack_ns = current->timer_slack_ns;
 
+#ifdef CONFIG_MEMTRACE
+	if(current->mem_trace) {
+		p->mem_trace = 1;
+		p->seq = 0;
+	}
+#endif
 	task_io_accounting_init(&p->ioac);
 	acct_clear_integrals(p);
 
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index dd373c8..9955a40 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -748,6 +748,10 @@ config DEBUG_VIRTUAL
 
 	  If unsure, say N.
 
+config MEMTRACE
+	bool "Memory Reference Tracing"
+	default n
+
 config DEBUG_NOMMU_REGIONS
 	bool "Debug the global anon/private NOMMU mapping region tree"
 	depends on DEBUG_KERNEL && !MMU
diff --git a/lib/Makefile b/lib/Makefile
index 6b597fd..652c5fa 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -89,6 +89,7 @@ obj-$(CONFIG_SWIOTLB) += swiotlb.o
 obj-$(CONFIG_IOMMU_HELPER) += iommu-helper.o
 obj-$(CONFIG_FAULT_INJECTION) += fault-inject.o
 obj-$(CONFIG_CPU_NOTIFIER_ERROR_INJECT) += cpu-notifier-error-inject.o
+obj-$(CONFIG_MEMTRACE) += memtrace.o
 
 lib-$(CONFIG_GENERIC_BUG) += bug.o
 
diff --git a/lib/memtrace.c b/lib/memtrace.c
new file mode 100644
index 0000000..5ebd7c8
--- /dev/null
+++ b/lib/memtrace.c
@@ -0,0 +1,108 @@
+#include <asm/atomic.h>
+#include <linux/memtrace.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+
+/* Trace Unique identifier */
+atomic_t trace_sequence_number;
+pid_t pg_trace_pid;
+int memtrace_block_sz;
+int total_block_count;
+
+#define MB_SHIFT	20
+
+/* TODO: Dynamically allocate this array depending on the amount of memory
+ * present on the system
+ */
+struct memtrace_block memtrace_block_accessed[MAX_MEMTRACE_BLOCK+1];
+
+/* App being traced */
+pid_t get_pg_trace_pid(void)
+{
+	return pg_trace_pid;
+}
+EXPORT_SYMBOL_GPL(get_pg_trace_pid);
+
+void set_pg_trace_pid(pid_t pid)
+{
+	pg_trace_pid = pid;
+}
+EXPORT_SYMBOL_GPL(set_pg_trace_pid);
+
+void set_mem_trace(struct task_struct *tsk, int flag)
+{
+	tsk->mem_trace = flag;
+}
+EXPORT_SYMBOL_GPL(set_mem_trace);
+
+void set_task_seq(struct task_struct *tsk, unsigned int seq)
+{
+	tsk->seq = seq;
+}
+EXPORT_SYMBOL_GPL(set_task_seq);
+
+unsigned int get_task_seq(struct task_struct *tsk)
+{
+	return (tsk->seq);
+}
+EXPORT_SYMBOL_GPL(get_task_seq);
+
+void init_seq_number(void)
+{
+	return (atomic_set(&trace_sequence_number, 0));
+}
+EXPORT_SYMBOL_GPL(init_seq_number);
+
+unsigned int get_seq_number(void)
+{
+	return atomic_read(&trace_sequence_number);
+}
+EXPORT_SYMBOL_GPL(get_seq_number);
+
+unsigned int inc_seq_number(void)
+{
+	return (atomic_inc_return(&trace_sequence_number));
+}
+EXPORT_SYMBOL_GPL(inc_seq_number);
+
+void set_memtrace_block_sz(int sz)
+{
+	memtrace_block_sz = sz;
+	total_block_count = (totalram_pages << PAGE_SHIFT) / (memtrace_block_sz << MB_SHIFT );
+}
+EXPORT_SYMBOL_GPL(set_memtrace_block_sz);
+
+void mark_memtrace_block_accessed(unsigned long paddr)
+ {
+	int memtrace_block;
+	unsigned long paddr_mb;
+
+	paddr_mb = paddr >> MB_SHIFT;
+
+	memtrace_block = ((int) paddr_mb/memtrace_block_sz) + 1;
+	memtrace_block_accessed[memtrace_block].seq = get_seq_number();
+	memtrace_block_accessed[memtrace_block].access_flag = 1;
+}
+EXPORT_SYMBOL_GPL(mark_memtrace_block_accessed);
+
+void update_and_log_data(void)
+{
+ 	int i;
+	unsigned int seq;
+	unsigned long base_addr, access_flag;
+
+	for (i = 1; i <= total_block_count; i++) {
+		seq = memtrace_block_accessed[i].seq;
+		base_addr = i * memtrace_block_sz;
+		access_flag = memtrace_block_accessed[i].access_flag;
+		/*
+		 *  Log trace data
+		 *  Can modify to dump only blocks that have been marked
+		 *  accessed
+		 */
+		memtrace_block_accessed[i].access_flag = 0;
+ 	}
+
+	return;
+}
+EXPORT_SYMBOL_GPL(update_and_log_data);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
