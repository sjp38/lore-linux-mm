Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA9E90011E
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 04:23:04 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id p658Hqjx029753
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:17:52 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p658N0Da925812
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:23:00 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p658Mx7i029727
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:22:59 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 2/5] memref module to walk the process page table
Date: Tue,  5 Jul 2011 13:52:36 +0530
Message-Id: <1309854159-8277-3-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi,

This patch introduces the memref module that walks through the page tables
of all the required processes to capture the reference pattern information.
The module makes use of the walk_page_range routine provided by the kernel.
Further, the module walks through the page tables of all the tasks that are
its children and in the same thread group. One of the reasons why a core
kernel backend is needed is that some of the routines/data needed to walk
through all the process and kernel page tables are not exported for use by
kernel modules.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 arch/x86/mm/pgtable.c |    2 +
 arch/x86/mm/tlb.c     |    1 +
 drivers/misc/Kconfig  |    5 +
 drivers/misc/Makefile |    1 +
 drivers/misc/memref.c |  194 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/pid.c          |    1 +
 mm/memory.c           |    1 +
 mm/pagewalk.c         |    2 +
 8 files changed, 207 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/memref.c

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 8573b83..bc17d20 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -4,6 +4,7 @@
 #include <asm/pgtable.h>
 #include <asm/tlb.h>
 #include <asm/fixmap.h>
+#include <linux/module.h>
 
 #define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
 
@@ -300,6 +301,7 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 	paravirt_pgd_free(mm, pgd);
 	free_page((unsigned long)pgd);
 }
+EXPORT_SYMBOL_GPL(ptep_test_and_clear_young);
 
 int ptep_set_access_flags(struct vm_area_struct *vma,
 			  unsigned long address, pte_t *ptep,
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index d6c0418..f24c9f2 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -299,6 +299,7 @@ void flush_tlb_mm(struct mm_struct *mm)
 
 	preempt_enable();
 }
+EXPORT_SYMBOL_GPL(flush_tlb_mm);
 
 void flush_tlb_page(struct vm_area_struct *vma, unsigned long va)
 {
diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 4e349cd..bca5977 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -314,6 +314,11 @@ config SGI_GRU_DEBUG
 	This option enables addition debugging code for the SGI GRU driver. If
 	you are unsure, say N.
 
+config MEMREF
+	tristate "Memory Reference Tracing module"
+	select MEMTRACE
+	default n
+
 config APDS9802ALS
 	tristate "Medfield Avago APDS9802 ALS Sensor module"
 	depends on I2C
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 5f03172..c878486 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -46,3 +46,4 @@ obj-y				+= ti-st/
 obj-$(CONFIG_AB8500_PWM)	+= ab8500-pwm.o
 obj-y				+= lis3lv02d/
 obj-y				+= carma/
+obj-$(CONFIG_MEMREF)		+= memref.o
diff --git a/drivers/misc/memref.c b/drivers/misc/memref.c
new file mode 100644
index 0000000..4e8785f
--- /dev/null
+++ b/drivers/misc/memref.c
@@ -0,0 +1,194 @@
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/moduleparam.h>
+#include <asm/pgtable.h>
+#include <linux/connector.h>
+#include <linux/mm.h>
+#include <linux/highmem.h>
+#include <linux/hugetlb.h>
+#include <asm/tlbflush.h>
+#include <linux/types.h>
+#include <asm/page.h>
+#include <linux/kthread.h>
+#include <linux/memtrace.h>
+
+struct task_struct *memref_thr;
+struct task_struct *tsk;
+unsigned int seq;
+struct mm_struct *k_mm;
+
+static pid_t trace_pid = -1;
+static int interval = 10;
+static int memtrace_block_size = 64;
+
+#define LIMIT 1024
+int top = -1;
+struct task_struct *stack[LIMIT];
+
+module_param(trace_pid, int, 0664);
+MODULE_PARM_DESC(trace_pid, "Pid of app to be traced");
+module_param(interval, int, 0664);
+MODULE_PARM_DESC(interval, "Sampling interval in milliseconds");
+module_param(memtrace_block_size, int, 0664);
+MODULE_PARM_DESC(memtrace_block_size, "Memory Block Size");
+
+static int check_and_clear_task_pages(pmd_t *pmd, unsigned long addr,
+				unsigned long end, struct mm_walk *walk)
+{
+	struct vm_area_struct *vma = walk->private;
+	unsigned long pfn;
+	pte_t *pte, ptent;
+	spinlock_t *ptl;
+	struct page *page;
+	unsigned long paddr;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		ptent = *pte;
+		if (!pte_present(ptent) || pte_none(*pte) || pte_huge(*pte))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		/* this is where need to check if reference bit was set,
+		 * if found to be set, make a note of it and then clear it
+		 */
+		if(ptep_test_and_clear_young(vma, addr, pte)) {
+			ClearPageReferenced(page);
+			pfn = pte_pfn(ptent);
+			if(pfn_valid(pfn)) {
+				paddr = pfn << PAGE_SHIFT;
+				mark_memtrace_block_accessed(paddr);
+			}
+		}
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	return 0;
+}
+
+static void walk_task_pages(struct mm_struct *mm)
+{
+	struct vm_area_struct *vma;
+
+	if (mm) {
+		struct mm_walk walk_task_pages = {
+			.pmd_entry = check_and_clear_task_pages,
+			.mm = mm,
+		};
+		down_read(&mm->mmap_sem);
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			walk_task_pages.private = vma;
+			if (!is_vm_hugetlb_page(vma)) ;
+				walk_page_range(vma->vm_start, vma->vm_end,
+						&walk_task_pages);
+		}
+		flush_tlb_mm(mm);
+		up_read(&mm->mmap_sem);
+		mmput(mm);
+	}
+}
+
+static int is_list_empty(void)
+{
+	if(top == -1)
+		return 1;
+	return 0;
+}
+
+static void insert_into_list(struct task_struct *v)
+{
+	if(top == LIMIT)
+		return;
+	top++;
+	stack[top] = v;
+}
+
+static struct task_struct* del_from_list(void)
+{
+	struct task_struct *t;
+
+	if(is_list_empty())
+		return NULL;
+	t = stack[top];
+	top--;
+	return t;
+}
+
+static void walk_tasks(struct task_struct *p)
+{
+	struct task_struct *t, *c;
+	struct mm_struct *mm_task;
+
+	if(!p)
+		return;
+
+	insert_into_list(p);
+
+	while(!is_list_empty()) {
+		c = del_from_list();
+		set_mem_trace(c, 1);
+		if(!thread_group_leader(c))
+			continue;
+		set_task_seq(c, seq);
+		mm_task = get_task_mm(c);
+		if(mm_task)
+			walk_task_pages(mm_task);
+
+		list_for_each_entry(t, &c->children, sibling)
+			if(get_task_seq(t) != seq)
+				insert_into_list(t);
+	}
+	return;
+}
+
+static int memref_thread(void *data)
+{
+	struct task_struct *task = data;
+
+	while(!kthread_should_stop() && task) {
+		seq = inc_seq_number();
+
+		walk_tasks(task);
+		update_and_log_data();
+		msleep(interval);
+	}
+	return 0;
+}
+
+static int memref_start(void)
+{
+
+	rcu_read_lock();
+	set_pg_trace_pid(trace_pid);
+	init_seq_number();
+	set_memtrace_block_sz(memtrace_block_size);
+
+	tsk = find_task_by_vpid(trace_pid);
+	if(!tsk) {
+		printk("No task with pid %d found \n", trace_pid);
+		tsk = ERR_PTR(-ESRCH);
+		return -EINVAL;
+	}
+
+	set_mem_trace(tsk, 1);
+	rcu_read_unlock();
+	memref_thr = kthread_create(memref_thread, tsk, "memref");
+	wake_up_process(memref_thr);
+	return 0;
+}
+
+static void memref_stop(void)
+{
+	if(memref_thr)
+		kthread_stop(memref_thr);
+	set_pg_trace_pid(-1);
+	set_mem_trace(tsk, 0);
+	return;
+}
+
+module_init(memref_start);
+module_exit(memref_stop);
+MODULE_LICENSE("GPL");
diff --git a/kernel/pid.c b/kernel/pid.c
index 57a8346..abfb4a6 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -427,6 +427,7 @@ struct task_struct *find_task_by_vpid(pid_t vnr)
 {
 	return find_task_by_pid_ns(vnr, current->nsproxy->pid_ns);
 }
+EXPORT_SYMBOL_GPL(find_task_by_vpid);
 
 struct pid *get_task_pid(struct task_struct *task, enum pid_type type)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 87d9353..a1fbd62 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -843,6 +843,7 @@ check_pfn:
 out:
 	return pfn_to_page(pfn);
 }
+EXPORT_SYMBOL_GPL(vm_normal_page);
 
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index c3450d5..f29d1cb 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -2,6 +2,7 @@
 #include <linux/highmem.h>
 #include <linux/sched.h>
 #include <linux/hugetlb.h>
+#include <linux/module.h>
 
 static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			  struct mm_walk *walk)
@@ -210,3 +211,4 @@ int walk_page_range(unsigned long addr, unsigned long end,
 
 	return err;
 }
+EXPORT_SYMBOL_GPL(walk_page_range);
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
