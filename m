Received: by qw-out-1920.google.com with SMTP id 9so1128335qwj.44
        for <linux-mm@kvack.org>; Sun, 02 Nov 2008 22:20:28 -0800 (PST)
Message-ID: <a5f59d880811022220u5cd837fbj61c78f8a9e300f05@mail.gmail.com>
Date: Mon, 3 Nov 2008 14:20:28 +0800
From: "Pengfei Hu" <hpfei.cn@gmail.com>
Subject: [PATCH] 2.6.27: add a kernel hacking option to protect kernel memory between different modules
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At first I'm a newbie in linux kernel and my English is not so good.
So don't laugh at me:)
In linux kernel, there are only memory protections between user
processes and between user processes and kernel. There is no
protection between different kernel modules (common concept, not refer
loadable kernel). The reason is the kernel's requirement for
efficiency and simplicity. But now more and more embed application use
linux. In the traditional embed system, all the task run in kernel and
share the memory. Using kernel thread can immigrate these application
easily. So there will be many task run in the kernel. And there will
be more and more memory bugs. Vxworks 6.0 provide memory protection
between tasks. In linux, I write a patch adding a kernel hacking
option to do it.
Basicly, it allocate module ID for kernel memory. Only memory's owner
module can access it and avoid accidental access form other module. To
achieve this goal, the simplest way is setting page table's present
flag when enter the module. And clear present flag when leave the
module. But can't do it in SMP because page table is shared among all
CPU. Though we can use multi kernel page table, but it will make thing
very complex and hardly immigrate to other arch (MIPS) without
hardware page table. I use a way to always clear present flag and very
CPU use it's own TLB access memory. Maintain a address-module table.
When allocate page record it's owner module ID in the table and clear
present flag. In page fault, look at address-module table. If the page
belong the current module then set present flag and load TLB. And then
clear present flag again immediately but this time don't invalide TLB.
Keep the page in this CPU's TLB. Though there is a time window, it's
inevitable and not so serious.
Because only part of memory need protect and many memory shoud be
share in kernel. So it is necessary to allocate shared memory and
provide another set of interface for protected memory allocating. This
set of interface should be very simple and when turn off the kernel
hacking option it will equal to original interface. There are two
possible way to do this. One way is provide another functions such as
alloc_pages_p kmalloc_p for alloc_pages kmalloc. When turn off the
option, define the macro as alloc_pages kmalloc. This way will add
many function in kernel. The other way that I current use is use the
original interface, and add a set of bit flag. When turn off the
option define the flag as 0. Because kmap_high and vmalloc don't have
flag input parameter. We can use the most lower bit of kmap_high's
page parameter and the most higher bit of vmalloc's size parameter.
Because these bit can't be use normally.
I only modify the __alloc_pages_internal and __free_pages. Using it as
a basic, other function like slab and vmalloc can be modify easily.
And I only modify smp_apic_timer_interrupt and do_IRQ. I think it is
not very necessary to modify other interrupt handler.
This patch is on 2.6.27. It does not include PAE and x86-64. It's only
a conceptual thing. If everyone agree me then I'll finish it.
                                                     Pengfei Hu

diff -Naur old/arch/x86/Kconfig.debug new/arch/x86/Kconfig.debug
--- old/arch/x86/Kconfig.debug	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/Kconfig.debug	2008-11-01 17:56:01.000000000 +0800
@@ -67,6 +67,14 @@
 	  This results in a large slowdown, but helps to find certain types
 	  of memory corruptions.

+config DEBUG_KM_PROTECT
+        bool "Debug kernel memory protect"
+        depends on DEBUG_KERNEL && SLUB
+        help
+          Change page table's present flag to prevent other module's accidental
+          access. This results in a large slowdown and waste more memory, but
+          helps to find certain types of memory corruptions.
+
 config DEBUG_PER_CPU_MAPS
 	bool "Debug access to per_cpu maps"
 	depends on DEBUG_KERNEL
diff -Naur old/arch/x86/kernel/apic_32.c new/arch/x86/kernel/apic_32.c
--- old/arch/x86/kernel/apic_32.c	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/kernel/apic_32.c	2008-11-02 12:08:16.000000000 +0800
@@ -28,6 +28,7 @@
 #include <linux/acpi_pmtmr.h>
 #include <linux/module.h>
 #include <linux/dmi.h>
+#include <linux/km_protect.h>

 #include <asm/atomic.h>
 #include <asm/smp.h>
@@ -618,6 +619,9 @@
 void smp_apic_timer_interrupt(struct pt_regs *regs)
 {
 	struct pt_regs *old_regs = set_irq_regs(regs);
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	unsigned short temp = km_set_id(0);
+#endif

 	/*
 	 * NOTE! We'd better ACK the irq immediately,
@@ -634,6 +638,9 @@
 	irq_exit();

 	set_irq_regs(old_regs);
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	km_set_id(temp);
+#endif
 }

 int setup_profiling_timer(unsigned int multiplier)
diff -Naur old/arch/x86/kernel/irq_32.c new/arch/x86/kernel/irq_32.c
--- old/arch/x86/kernel/irq_32.c	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/kernel/irq_32.c	2008-11-02 12:08:17.000000000 +0800
@@ -15,6 +15,7 @@
 #include <linux/notifier.h>
 #include <linux/cpu.h>
 #include <linux/delay.h>
+#include <linux/km_protect.h>

 #include <asm/apic.h>
 #include <asm/uaccess.h>
@@ -225,6 +226,9 @@
 	/* high bit used in ret_from_ code */
 	int overflow, irq = ~regs->orig_ax;
 	struct irq_desc *desc = irq_desc + irq;
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	unsigned short temp = km_set_id(0);
+#endif

 	if (unlikely((unsigned)irq >= NR_IRQS)) {
 		printk(KERN_EMERG "%s: cannot handle IRQ %d\n",
@@ -245,6 +249,9 @@

 	irq_exit();
 	set_irq_regs(old_regs);
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	km_set_id(temp);
+#endif
 	return 1;
 }

diff -Naur old/arch/x86/mm/fault.c new/arch/x86/mm/fault.c
--- old/arch/x86/mm/fault.c	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/mm/fault.c	2008-11-01 17:56:01.000000000 +0800
@@ -26,6 +26,7 @@
 #include <linux/kprobes.h>
 #include <linux/uaccess.h>
 #include <linux/kdebug.h>
+#include <linux/km_protect.h>

 #include <asm/system.h>
 #include <asm/desc.h>
@@ -844,6 +845,10 @@
 	if (is_errata93(regs, address))
 		return;

+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if ((0 != tsk->km_id) && km_valid_addr(address))
+		return;
+#endif
 /*
  * Oops. The kernel tried to access some bad page. We'll have to
  * terminate things with extreme prejudice.
diff -Naur old/arch/x86/mm/km_protect.c new/arch/x86/mm/km_protect.c
--- old/arch/x86/mm/km_protect.c	1970-01-01 08:00:00.000000000 +0800
+++ new/arch/x86/mm/km_protect.c	2008-11-02 18:13:55.000000000 +0800
@@ -0,0 +1,169 @@
+/*
+ * (C) 2008, Pengfei Hu
+ */
+
+#include <linux/bootmem.h>
+#include <linux/proc_fs.h>
+#include <linux/buffer_head.h>
+#include <linux/km_protect.h>
+
+unsigned short cur_km_id;
+unsigned short *km_table;
+
+void km_test1(void)
+{
+	volatile int val;
+	unsigned long addr;
+	unsigned short km_id = km_alloc_id();
+	km_set_id(km_id);
+	addr = __get_free_page(GFP_KERNEL | __GFP_KM_PROTECT);
+	if (addr) {
+		val = *(int *)addr;
+		km_set_id(0);
+		printk(KERN_EMERG "After km_set_id(0):\n");
+		val = *(int *)addr;
+		free_pages(addr, 1);
+	}
+	else {
+		printk(KERN_EMERG "__get_free_page failed\n");
+	}
+}
+unsigned long km_test_addr;
+unsigned short km_test_id;
+spinlock_t km_test_lock;
+
+int km_thread1(void * arg)
+{
+	volatile int val;
+	struct task_struct *tsk = current;
+	set_task_comm(tsk, "km_thread1");
+	printk(KERN_INFO "PID: %x\n", current->pid);
+	spin_lock(&km_test_lock);
+	if (0 == km_test_id) {
+		km_test_id = km_alloc_id();
+		km_set_id(km_test_id);
+		km_test_addr = __get_free_page(GFP_KERNEL | __GFP_KM_PROTECT);
+		if (!km_test_addr) {
+			printk(KERN_INFO "__get_free_page failed\n");
+			goto no_mem;
+		}
+	}
+	else {
+		if (!km_test_addr)
+			goto no_mem;
+		km_set_id(km_test_id);
+	}
+	spin_unlock(&km_test_lock);
+	while(1) {
+		val = *(int *)km_test_addr;
+		udelay(1000);
+	}
+no_mem:	
+	spin_unlock(&km_test_lock);
+	return -1;
+}
+int km_thread2(void * arg)
+{
+	volatile int val;
+	struct task_struct *tsk = current;
+	set_task_comm(tsk, "km_thread2");
+	int i;
+	printk(KERN_INFO "PID: %x\n", current->pid);
+	for(i = 0; i++; i < 100)
+		udelay(20000);
+	while(1) {
+		if (km_test_addr)
+			val = *(int *)km_test_addr;
+		udelay(1000);
+	}
+	return 0;
+}
+void km_test2(void)
+{
+	spin_lock_init(&km_test_lock);
+	kernel_thread(km_thread1, 0, CLONE_FS | CLONE_SIGHAND);
+	kernel_thread(km_thread1, 0, CLONE_FS | CLONE_SIGHAND);
+	kernel_thread(km_thread2, 0, CLONE_FS | CLONE_SIGHAND);
+}
+int km_protect_write(struct file *file, const char __user * buffer,
+		unsigned long count, void *data)
+{
+	char buf[8];
+	unsigned long len = min((unsigned long)sizeof(buf) - 1, count);
+	unsigned long cmd;
+	if (copy_from_user(buf, buffer, len))
+		return count;
+	buf[len] = 0;
+	sscanf(buf, "%li", &cmd);
+	switch (cmd) {
+	case 1:
+		km_test1();
+		break;
+	case 2:
+		km_test2();
+		break;
+	default:
+		printk(KERN_INFO "Command error!\n");
+	}
+	return strnlen(buf, len);
+}
+int km_protect_read(char *buf, char **start, off_t offset,
+		int count, int *eof, void *data)
+{
+	*eof = 1;
+	return sprintf(buf, "\n");
+}
+void __init km_protect_init(void)
+{
+	km_table = (unsigned short *)alloc_bootmem(KM_TABLE_SIZE);
+	if (!km_table) {
+		printk(KERN_EMERG "km_protect: alloc km_table failed!\n");
+		return;
+	}
+	memset(km_table, 0, KM_TABLE_SIZE);
+}
+void __init km_protect_dbginit(void)
+{
+	struct proc_dir_entry *e;
+	e = create_proc_entry("km_protect", 0, NULL);
+	if (!e) {
+		printk(KERN_EMERG "km_protect: Create proc file failed!\n");
+		return;
+	}
+	e->read_proc = km_protect_read;
+	e->write_proc = km_protect_write;
+	e->data = NULL;
+}
+void km_protect_addr(unsigned long addr, int numpages)
+{
+	pte_t *kpte;
+	unsigned int level;
+	WARN_ON(0 == current->km_id);
+	while (numpages > 0)
+	{
+		kpte = lookup_address(addr, &level);
+		km_table[__pa(addr) >> PAGE_SHIFT] = current->km_id;
+		kpte->pte &= ~(_PAGE_PRESENT);
+		__flush_tlb_one(addr);
+		numpages--;
+		addr += PAGE_SIZE;
+	}
+}
+void km_unprotect_addr(unsigned long addr, int numpages)
+{
+	pte_t *kpte;
+	unsigned int level;
+	if (0 == km_table[__pa(addr) >> PAGE_SHIFT])
+		return;
+	while (numpages > 0)
+	{
+		WARN_ON(km_table[__pa(addr) >> PAGE_SHIFT] != current->km_id);
+		kpte = lookup_address(addr, &level);
+		kpte->pte |= _PAGE_PRESENT;
+		__flush_tlb_one(addr);
+		km_table[__pa(addr) >> PAGE_SHIFT] = 0;
+		numpages--;
+		addr += PAGE_SIZE;
+	}
+}
+
diff -Naur old/arch/x86/mm/Makefile new/arch/x86/mm/Makefile
--- old/arch/x86/mm/Makefile	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/mm/Makefile	2008-11-01 17:56:01.000000000 +0800
@@ -22,3 +22,4 @@
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o

 obj-$(CONFIG_MEMTEST)		+= memtest.o
+obj-$(CONFIG_DEBUG_KM_PROTECT) += km_protect.o
diff -Naur old/include/linux/gfp.h new/include/linux/gfp.h
--- old/include/linux/gfp.h	2008-10-10 06:13:53.000000000 +0800
+++ new/include/linux/gfp.h	2008-11-01 17:56:01.000000000 +0800
@@ -43,6 +43,11 @@
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* See above */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* See above */
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* See above */
+#ifdef CONFIG_DEBUG_KM_PROTECT
+#define __GFP_KM_PROTECT	((__force gfp_t)0x2000u)/* Kernel memory protect */
+#else
+#define __GFP_KM_PROTECT	((__force gfp_t)0x0u)/* Kernel memory protect */
+#endif
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use
emergency reserves */
diff -Naur old/include/linux/km_protect.h new/include/linux/km_protect.h
--- old/include/linux/km_protect.h	1970-01-01 08:00:00.000000000 +0800
+++ new/include/linux/km_protect.h	2008-11-02 12:18:47.000000000 +0800
@@ -0,0 +1,76 @@
+/*
+ * (C) 2008, Pengfei Hu
+ */
+
+#ifndef _LINUX_KM_PROTECT_H
+#define	_LINUX_KM_PROTECT_H
+
+#include <asm/tlbflush.h>
+#include <asm/pgtable.h>
+#include <asm/current.h>
+
+#define MAX_KM_ID 65535
+#define KM_TABLE_SIZE 256*1024*sizeof(unsigned short)
+
+extern unsigned short cur_km_id;
+extern unsigned short *km_table;
+
+#ifdef CONFIG_DEBUG_KM_PROTECT
+
+void __init km_protect_init(void);
+void __init km_protect_dbginit(void);
+void km_protect_addr(unsigned long addr, int numpages);
+void km_unprotect_addr(unsigned long addr, int numpages);
+static inline unsigned short km_alloc_id(void)
+{
+	if(cur_km_id < MAX_KM_ID)
+		return ++cur_km_id;
+	return 0;
+}
+static inline unsigned short km_set_id(unsigned short km_id)
+{
+	if (current->km_id != km_id) {
+		unsigned short prev = current->km_id;
+		current->km_id = km_id;
+		if (prev != 0)
+			__flush_tlb_all();
+		return prev;
+	}
+	return km_id;
+}
+static inline bool km_valid_addr(unsigned long addr)
+{
+	pte_t *kpte;
+	unsigned int level;
+	volatile int v;
+	if (km_table[__pa(addr) >> PAGE_SHIFT] != current->km_id)
+		return false;
+	kpte = lookup_address(addr, &level);
+	kpte->pte |= _PAGE_PRESENT;
+//	set_pte_atomic(kpte, pfn_pte(pte_pfn(*kpte),
__pgprot(pgprot_val(pte_pgprot(*kpte)) |
pgprot_val(__pgprot(_PAGE_PRESENT)))));
+	__flush_tlb_one(addr);
+	/* Load page into tlb */
+	v = *(int *)addr;
+	kpte->pte &= ~(_PAGE_PRESENT);
+	return true;
+}
+#else /* CONFIG_DEBUG_KM_PROTECT */
+
+static inline void __init km_protect_init(void)
+{
+}
+static inline void __init km_protect_dbginit(void)
+{
+}
+static inline unsigned short km_alloc_id()
+{
+	return 0;
+}
+static inline unsigned short km_set_id(unsigned short km_id)
+{
+	return 0;
+}
+
+#endif /* CONFIG_DEBUG_KM_PROTECT */
+
+#endif	/* _LINUX_KM_PROTECT_H */
diff -Naur old/include/linux/sched.h new/include/linux/sched.h
--- old/include/linux/sched.h	2008-10-10 06:13:53.000000000 +0800
+++ new/include/linux/sched.h	2008-11-01 17:56:01.000000000 +0800
@@ -1060,6 +1060,9 @@
 	 */
 	unsigned char fpu_counter;
 	s8 oomkilladj; /* OOM kill score adjustment (bit shift). */
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	unsigned short km_id;
+#endif
 #ifdef CONFIG_BLK_DEV_IO_TRACE
 	unsigned int btrace_seq;
 #endif
diff -Naur old/init/main.c new/init/main.c
--- old/init/main.c	2008-10-10 06:13:53.000000000 +0800
+++ new/init/main.c	2008-11-01 17:56:01.000000000 +0800
@@ -60,6 +60,7 @@
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/idr.h>
+#include <linux/km_protect.h>

 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -644,6 +645,7 @@
 #endif
 	vfs_caches_init_early();
 	cpuset_init_early();
+	km_protect_init();
 	mem_init();
 	enable_debug_pagealloc();
 	cpu_hotplug_init();
@@ -678,6 +680,7 @@
 #ifdef CONFIG_PROC_FS
 	proc_root_init();
 #endif
+	km_protect_dbginit();
 	cgroup_init();
 	cpuset_init();
 	taskstats_init_early();
diff -Naur old/kernel/fork.c new/kernel/fork.c
--- old/kernel/fork.c	2008-10-10 06:13:53.000000000 +0800
+++ new/kernel/fork.c	2008-11-01 17:56:01.000000000 +0800
@@ -932,6 +932,9 @@
 	if (!p)
 		goto fork_out;

+#ifdef CONFIG_DEBUG_KM_PROTECT
+	p->km_id = 0;
+#endif
 	rt_mutex_init_task(p);

 #ifdef CONFIG_PROVE_LOCKING
diff -Naur old/kernel/sched.c new/kernel/sched.c
--- old/kernel/sched.c	2008-10-10 06:13:53.000000000 +0800
+++ new/kernel/sched.c	2008-11-01 17:56:01.000000000 +0800
@@ -2606,6 +2606,10 @@
 	 */
 	arch_enter_lazy_cpu_mode();

+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if (prev->km_id != 0)
+		__flush_tlb_all();
+#endif
 	if (unlikely(!mm)) {
 		next->active_mm = oldmm;
 		atomic_inc(&oldmm->mm_count);
diff -Naur old/mm/page_alloc.c new/mm/page_alloc.c
--- old/mm/page_alloc.c	2008-10-10 06:13:53.000000000 +0800
+++ new/mm/page_alloc.c	2008-11-01 17:56:01.000000000 +0800
@@ -46,6 +46,7 @@
 #include <linux/page-isolation.h>
 #include <linux/memcontrol.h>
 #include <linux/debugobjects.h>
+#include <linux/km_protect.h>

 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1638,6 +1639,10 @@
 		show_mem();
 	}
 got_pg:
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if ((gfp_mask & __GFP_KM_PROTECT) && (!PageHighMem(page)))
+		km_protect_addr((unsigned long)page_address(page), (1 << order));
+#endif
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_internal);
@@ -1689,6 +1694,10 @@
 			free_hot_page(page);
 		else
 			__free_pages_ok(page, order);
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if (!PageHighMem(page))
+		km_unprotect_addr((unsigned long)page_address(page), (1 << order));
+#endif
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
