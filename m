Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 23B166B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 08:42:32 -0500 (EST)
Received: by po-out-1718.google.com with SMTP id c31so7315381poi.1
        for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:42:30 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 10 Feb 2009 21:42:29 +0800
Message-ID: <a5f59d880902100542x7243b13fuf40e7dd21faf7d7a@mail.gmail.com>
Subject: Using module private memory to simulate microkernel's memory
	protection
From: Pengfei Hu <hpfei.cn@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

C programming is prone to memory management bug and the worst case is
inter-module's bug,
which is one module access other module's memory accidentally. If the
access was write access
then it will be very difficult to find the real error. Beside bad
design the other reason
is using uni-allocator. In kernel, kmalloc is a kind's of
uni-allocator. Microkernel has
a advantage of process isolation. But microkernel will suffer
performence punishment.
I found a way to get microkernel's advantage and avoid its punishment.
As we know, memory
protection is supported by mmu and realized in page fault exception
handler. Process is
only a container and is not necessary. My solution is when module
initiate allocate ID for
it. When module allocate memory record module's ID for it. In page
fault exception handler,
check the memory if it belong to the current module. In some arch such
as MIPS. They don't
have hardware page table. It is not difficult to do this when TLB
miss. In X86 SMP, I use
a way to always clear present flag and very CPU use it's own TLB
access memory. Because module
is only a logical concept. Entering and leaveing one module don't like
process switch. We must
run km_set_handle explicit. If we modify compiler maybe it can be done
automatically. To avoid
performence punishment, I write this patch as a kernel hacking option.
All the check is only executed
when macro CONFIG_DEBUG_KM_PROTECT is set.

In this patch, an important goal is keep consistent with the current
code. Only new module which
use this feature will be affected. I add n new zone ZONE_PROTECT for
the private memory. New module
using private memory can allocate public memory as well. This patch
also encourage module's encapsulation.
Only if a module is well encapsulated, include data's allocating,
accessing and releasing. It can use
module private memory. Of course this can be optimized when
CONFIG_DEBUG_KM_PROTECT is not set. A big
problem is the current kenel code's object-oriented style may be
incompatible with this patch's. The kernel's
style is like C++. The child class derectly include its parent class's
data. Its advantage is high efficient.
But this make module hardly divided. If the child class and parent
class is divided in a whole module. Such as
fs and net, the granularity will be too big and don't have real value.
I suggest child class use pointer to
include parent class's data. So the child class and the parent can be
divided in individual module.

This patch is on 2.6.27. I have tested it roughly.

diff -Nurp old/arch/x86/Kconfig.debug new/arch/x86/Kconfig.debug
--- old/arch/x86/Kconfig.debug	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/Kconfig.debug	2008-12-07 19:19:40.000000000 +0800
@@ -67,6 +67,16 @@ config DEBUG_PAGEALLOC
 	  This results in a large slowdown, but helps to find certain types
 	  of memory corruptions.

+config DEBUG_KM_PROTECT
+        bool "Debug kernel memory protect"
+        depends on DEBUG_KERNEL
+        select DEBUG_PAGEALLOC
+        select SLUB
+        help
+          Change page table's present flag to prevent other module's accidental
+          access. This results in a large slowdown and waste more memory, but
+          helps to find certain types of memory corruptions.
+
 config DEBUG_PER_CPU_MAPS
 	bool "Debug access to per_cpu maps"
 	depends on DEBUG_KERNEL
diff -Nurp old/arch/x86/mm/fault.c new/arch/x86/mm/fault.c
--- old/arch/x86/mm/fault.c	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/mm/fault.c	2008-12-07 19:19:40.000000000 +0800
@@ -26,6 +26,7 @@
 #include <linux/kprobes.h>
 #include <linux/uaccess.h>
 #include <linux/kdebug.h>
+#include <linux/km_protect.h>

 #include <asm/system.h>
 #include <asm/desc.h>
@@ -844,6 +845,10 @@ no_context:
 	if (is_errata93(regs, address))
 		return;

+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if ((NULL != tsk->km_handle) && km_valid_addr(address))
+		return;
+#endif
 /*
  * Oops. The kernel tried to access some bad page. We'll have to
  * terminate things with extreme prejudice.
diff -Nurp old/arch/x86/mm/init_32.c new/arch/x86/mm/init_32.c
--- old/arch/x86/mm/init_32.c	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/mm/init_32.c	2008-12-26 22:25:05.000000000 +0800
@@ -557,6 +557,19 @@ static void __init set_nx(void)
 /* user-defined highmem size */
 static unsigned int highmem_pages = -1;

+/* user-defined protectmem size */
+static unsigned int protectmem_pages;
+
+static int __init parse_protectmem(char *arg)
+{
+	if (!arg)
+		return -EINVAL;
+
+	protectmem_pages = memparse(arg, &arg) >> PAGE_SHIFT;
+	return 0;
+}
+early_param("protectmem", parse_protectmem);
+
 /*
  * highmem=size forces highmem to be exactly 'size' bytes.
  * This works even on boxes that have no highmem otherwise.
@@ -572,6 +585,25 @@ static int __init parse_highmem(char *ar
 }
 early_param("highmem", parse_highmem);

+#ifdef CONFIG_DEBUG_KM_PROTECT
+/* user-defined protectmem size */
+unsigned int protectmem_pages = 1024;
+unsigned long protectmem_lowest_pfn;
+unsigned long protectmem_highest_pfn;
+extern unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
+extern unsigned long __meminitdata
arch_zone_highest_possible_pfn[MAX_NR_ZONES];
+
+static int __init parse_protectmem(char *arg)
+{
+	if (!arg)
+		return -EINVAL;
+
+	protectmem_pages = memparse(arg, &arg) >> PAGE_SHIFT;
+	return 0;
+}
+early_param("protectmem", parse_protectmem);
+#endif
+
 /*
  * Determine low and high memory ranges:
  */
@@ -680,11 +712,19 @@ static void __init zone_sizes_init(void)
 	max_zone_pfns[ZONE_DMA] =
 		virt_to_phys((char *)MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	max_zone_pfns[ZONE_NORMAL] = max_low_pfn;
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	max_zone_pfns[ZONE_NORMAL] -= protectmem_pages;
+	max_zone_pfns[ZONE_PROTECT] = max_low_pfn;
+#endif
 #ifdef CONFIG_HIGHMEM
 	max_zone_pfns[ZONE_HIGHMEM] = highend_pfn;
 #endif

 	free_area_init_nodes(max_zone_pfns);
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	protectmem_lowest_pfn = arch_zone_lowest_possible_pfn[ZONE_PROTECT];
+	protectmem_highest_pfn = arch_zone_highest_possible_pfn[ZONE_PROTECT];
+#endif
 }

 void __init setup_bootmem_allocator(void)
diff -Nurp old/arch/x86/mm/km_protect.c new/arch/x86/mm/km_protect.c
--- old/arch/x86/mm/km_protect.c	1970-01-01 08:00:00.000000000 +0800
+++ new/arch/x86/mm/km_protect.c	2008-12-26 22:25:05.000000000 +0800
@@ -0,0 +1,352 @@
+/*
+ * (C) 2008, Pengfei Hu
+ */
+
+#include <linux/bootmem.h>
+#include <linux/proc_fs.h>
+#include <linux/buffer_head.h>
+#include <asm/tlbflush.h>
+#include <asm/pgtable.h>
+#include <asm/current.h>
+#include <linux/km_protect.h>
+#include <linux/kthread.h>
+
+unsigned short cur_km_id;
+#ifndef CONFIG_X86_PAE
+unsigned short *km_table;
+#endif
+
+static unsigned long km_test_addr;
+static struct km_struct *km_handle;
+void km_test1(void)
+{
+	volatile int val;
+	unsigned long addr;
+	struct km_struct *prev;
+	km_alloc_handle("test1", &km_handle);
+	km_set_handle(km_handle, &prev);
+	addr = __get_free_page(GFP_KERNEL | __GFP_PROTECT);
+	printk("addr: %lx pfn: %lx\n", addr, __pa(addr) >> PAGE_SHIFT);
+	if (addr) {
+		val = *(int *)addr;
+		km_set_handle(prev, NULL);
+		val = *(int *)addr;
+		free_page(addr);
+	}
+	else
+		printk("__get_free_page failed\n");
+}
+
+int km_thread1(void * arg)
+{
+	volatile int val;
+	printk("PID: %d\n", current->pid);
+	km_set_handle(km_handle, NULL);
+	while(1) {
+		val = *(int *)km_test_addr;
+		schedule();
+	}
+	return 0;
+}
+int km_thread2(void * arg)
+{
+	int i;
+	volatile int val;
+	printk("PID: %d\n", current->pid);
+	for(i = 0; i < 200; i++) {
+		udelay(20000);
+		schedule();
+	}
+	while(1) {
+		val = *(int *)km_test_addr;
+		schedule();
+	}
+	return 0;
+}
+void km_test2(void)
+{
+	struct task_struct *p1, *p2, *p3;
+	struct km_struct *prev;
+	km_alloc_handle("test2", &km_handle);
+	km_set_handle(km_handle, &prev);
+	km_test_addr = __get_free_page(GFP_KERNEL | __GFP_PROTECT);
+	if (!km_test_addr) {
+		printk("__get_free_page failed\n");
+		return;
+	}
+	km_set_handle(prev, NULL);
+	p1 = kthread_create(km_thread1, NULL, "km_thread1_1");
+	p2 = kthread_create(km_thread1, NULL, "km_thread1_2");
+	p3 = kthread_create(km_thread2, NULL, "km_thread2");
+	if (!IS_ERR(p1))
+		wake_up_process(p1);
+	else
+		WARN_ON(1);
+	if (!IS_ERR(p2))
+		wake_up_process(p2);
+	else
+		WARN_ON(1);
+	if (!IS_ERR(p3))
+		wake_up_process(p3);
+	else
+		WARN_ON(1);
+}
+void km_test3(void)
+{
+	volatile int val;
+	struct km_struct *prev;
+	struct kmem_cache *cache;
+	void *addr;
+	km_alloc_handle("test3", &km_handle);
+	km_set_handle(km_handle, &prev);
+	cache = kmem_cache_create("test3", 100, 0, SLAB_PROTECT | SLAB_PANIC, NULL);
+	addr = kmem_cache_alloc(cache, GFP_KERNEL);
+	printk("%p\n", addr);
+	val = *(int *)addr;
+	km_set_handle(prev, NULL);
+	val = *(int *)addr;
+	kmem_cache_free(cache, addr);
+	kmem_cache_destroy(cache);
+}
+void km_test4(void)
+{
+	volatile int val;
+	struct km_struct *prev;
+	void *addr, *addr2;
+	km_alloc_handle("test4", &km_handle);
+	km_set_handle(km_handle, &prev);
+	addr = kmalloc(4, GFP_KERNEL);
+	printk("addr: %p\n", addr);
+	addr2 = kmalloc(4, GFP_KERNEL | __GFP_PROTECT);
+	printk("addr2: %p\n", addr2);
+	val = *(int *)addr2;
+	km_set_handle(prev, NULL);
+	val = *(int *)addr;
+	kfree(addr);
+	val = *(int *)addr2;
+	kfree(addr2);
+}
+void km_test5(void)
+{
+	km_free_handle(km_handle);
+}
+void km_test6(void)
+{
+}
+void km_test7(void)
+{
+}
+void km_test8(void)
+{
+}
+int km_protect_write(struct file *file, const char __user * buffer,
+		unsigned long count, void *data)
+{
+	char buf[8];
+	unsigned long len = min((unsigned long)sizeof(buf) - 1, count);
+	unsigned long cmd;
+	printk("PID: %d pgd: %p\n", current->pid, current->mm->pgd);
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
+	case 3:
+		km_test3();
+		break;
+	case 4:
+		km_test4();
+		break;
+	case 5:
+		km_test5();
+		break;
+	case 6:
+		km_test6();
+		break;
+	case 7:
+		km_test7();
+		break;
+	case 8:
+		km_test8();
+		break;
+	default:
+		printk("Command error!\n");
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
+#ifndef CONFIG_X86_PAE
+	km_table = (unsigned short *)alloc_bootmem(KM_TABLE_SIZE);
+	if (!km_table) {
+		printk(KERN_EMERG "km_protect: alloc km_table failed!\n");
+		return;
+	}
+	memset(km_table, 0, KM_TABLE_SIZE);
+#endif
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
+void km_alloc_handle(const char *name, struct km_struct **handle)
+{
+	int i, size;
+	struct km_struct *p;
+	char buf[8];
+	if(cur_km_id >= MAX_KM_ID)
+		panic("%s: Exceed MAX_KM_ID\n", name);
+	size = strlen(name) + 6;
+	p = kmalloc(sizeof(struct km_struct) + size * PAGE_SHIFT, GFP_KERNEL
| __GFP_ZERO);
+	if (!p)
+		panic("Cannot alloc km handle %s\n", name);
+	p->id = ++cur_km_id;
+	for(i = 0; i < PAGE_SHIFT; i++)
+		strcpy(&p->name[size * i], name);
+	if (KMALLOC_MIN_SIZE <= 64) {
+		strcat(&p->name[0], "-96");
+		p->kmalloc_caches[0] = kmem_cache_create(&p->name[0], 96, 0,
SLAB_PROTECT | SLAB_PANIC, NULL);
+		strcat(&p->name[size], "-192");
+		p->kmalloc_caches[1] = kmem_cache_create(&p->name[size], 192, 0,
SLAB_PROTECT | SLAB_PANIC, NULL);
+	}
+	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++) {
+		sprintf(buf, "-%d", 1 << i);
+		strcat(&p->name[size * (i - 1)], buf);
+		p->kmalloc_caches[i - 1] = kmem_cache_create(&p->name[size * (i -
1)], 1 << i, 0, SLAB_PROTECT | SLAB_PANIC, NULL);
+	}
+	*handle = p;
+}
+void km_free_handle(struct km_struct *handle)
+{
+	int i;
+	if (KMALLOC_MIN_SIZE <= 64) {
+		kmem_cache_destroy(handle->kmalloc_caches[0]);
+		kmem_cache_destroy(handle->kmalloc_caches[1]);
+	}
+	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++)
+		kmem_cache_destroy(handle->kmalloc_caches[i - 1]);
+	kfree(handle);
+}
+void km_set_handle(struct km_struct *handle, struct km_struct **prev)
+{
+	if (NULL != prev)
+		*prev = current->km_handle;
+	if (current->km_handle != handle) {
+		if (current->km_handle != NULL)
+			__flush_tlb_all();
+		current->km_handle = handle;
+	}
+}
+void km_protect_addr(unsigned long addr, int numpages)
+{
+	unsigned long pfn = __pa(addr) >> PAGE_SHIFT;
+#ifndef CONFIG_X86_PAE
+	unsigned long i = pfn - protectmem_lowest_pfn;
+#else
+	pte_t *kpte;
+	unsigned int level;
+	u64 id;
+#endif
+	WARN_ON(0 == current->km_handle->id);
+	WARN_ON(pfn < protectmem_lowest_pfn ||pfn > protectmem_highest_pfn);
+	while (numpages > 0) {
+		__set_pages_np(virt_to_page(addr), 1);
+		__flush_tlb_one(addr);
+#ifndef CONFIG_X86_PAE
+		WARN_ON(km_table[i] != 0);
+		km_table[i] = current->km_handle->id;
+		i++;
+#else
+		kpte = lookup_address(addr, &level);
+		WARN_ON((kpte->pte & ~__PHYSICAL_MASK) != 0);
+		id = current->km_handle->id;
+		id <<= __PHYSICAL_MASK_SHIFT;
+		kpte->pte |= id;
+#endif
+		numpages--;
+		addr += PAGE_SIZE;
+	}
+}
+void km_unprotect_addr(unsigned long addr, int numpages)
+{
+	unsigned long pfn = __pa(addr) >> PAGE_SHIFT;
+#ifndef CONFIG_X86_PAE
+	unsigned long i = pfn - protectmem_lowest_pfn;
+#else
+		pte_t *kpte;
+		unsigned int level;
+		u64 id;
+#endif
+	if (pfn < protectmem_lowest_pfn ||pfn > protectmem_highest_pfn)
+		return;
+	while (numpages > 0) {
+#ifndef CONFIG_X86_PAE
+		WARN_ON((km_table[i] != 0) && (km_table[i] != current->km_handle->id));
+		km_table[i] = 0;
+		i++;
+#else
+		kpte = lookup_address(addr, &level);
+		id = kpte->pte & ~__PHYSICAL_MASK;
+		WARN_ON((id != 0) && (id != current->km_handle->id));
+		kpte->pte &= __PHYSICAL_MASK;
+#endif
+		numpages--;
+		addr += PAGE_SIZE;
+	}
+}
+bool km_valid_addr(unsigned long addr)
+{
+	volatile int v;
+#ifndef CONFIG_X86_PAE
+	unsigned long i;
+#else
+	pte_t *kpte;
+	unsigned int level;
+	u64 id;
+#endif
+	unsigned long pfn = __pa(addr) >> PAGE_SHIFT;
+	WARN_ON(0 == current->km_handle->id);
+	if (pfn < protectmem_lowest_pfn ||pfn > protectmem_highest_pfn)
+		return false;
+#ifndef CONFIG_X86_PAE
+	i = pfn - protectmem_lowest_pfn;
+	if (km_table[i] != current->km_handle->id)
+		return false;
+#else
+	kpte = lookup_address(addr, &level);
+	id = kpte->pte & ~__PHYSICAL_MASK;
+	if (id >> __PHYSICAL_MASK_SHIFT != current->km_handle->id)
+		return false;
+	kpte->pte &= __PHYSICAL_MASK;
+#endif
+	__set_pages_p(virt_to_page(addr), 1);
+	__flush_tlb_one(addr);
+	/* Load page into tlb */
+	v = *(int *)addr;
+	__set_pages_np(virt_to_page(addr), 1);
+#ifdef CONFIG_X86_PAE
+		kpte->pte |= id;
+#endif
+	return true;
+}
+
diff -Nurp old/arch/x86/mm/Makefile new/arch/x86/mm/Makefile
--- old/arch/x86/mm/Makefile	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/mm/Makefile	2008-11-01 17:56:01.000000000 +0800
@@ -22,3 +22,4 @@ endif
 obj-$(CONFIG_ACPI_NUMA)		+= srat_$(BITS).o

 obj-$(CONFIG_MEMTEST)		+= memtest.o
+obj-$(CONFIG_DEBUG_KM_PROTECT) += km_protect.o
diff -Nurp old/arch/x86/mm/pageattr.c new/arch/x86/mm/pageattr.c
--- old/arch/x86/mm/pageattr.c	2008-10-10 06:13:53.000000000 +0800
+++ new/arch/x86/mm/pageattr.c	2008-12-12 21:19:53.000000000 +0800
@@ -971,7 +971,7 @@ int set_pages_rw(struct page *page, int

 #ifdef CONFIG_DEBUG_PAGEALLOC

-static int __set_pages_p(struct page *page, int numpages)
+int __set_pages_p(struct page *page, int numpages)
 {
 	struct cpa_data cpa = { .vaddr = (unsigned long) page_address(page),
 				.numpages = numpages,
@@ -981,7 +981,7 @@ static int __set_pages_p(struct page *pa
 	return __change_page_attr_set_clr(&cpa, 1);
 }

-static int __set_pages_np(struct page *page, int numpages)
+int __set_pages_np(struct page *page, int numpages)
 {
 	struct cpa_data cpa = { .vaddr = (unsigned long) page_address(page),
 				.numpages = numpages,
diff -Nurp old/include/linux/gfp.h new/include/linux/gfp.h
--- old/include/linux/gfp.h	2008-10-10 06:13:53.000000000 +0800
+++ new/include/linux/gfp.h	2008-11-17 11:39:04.000000000 +0800
@@ -19,6 +19,11 @@ struct vm_area_struct;
 #define __GFP_DMA	((__force gfp_t)0x01u)
 #define __GFP_HIGHMEM	((__force gfp_t)0x02u)
 #define __GFP_DMA32	((__force gfp_t)0x04u)
+#ifdef CONFIG_DEBUG_KM_PROTECT
+#define __GFP_PROTECT	((__force gfp_t)0x08u)/* Kernel memory protect */
+#else
+#define __GFP_PROTECT	((__force gfp_t)0x0u)
+#endif

 /*
  * Action modifiers - doesn't change the zoning
@@ -134,6 +139,10 @@ static inline enum zone_type gfp_zone(gf
 	if (flags & __GFP_HIGHMEM)
 		return ZONE_HIGHMEM;
 #endif
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if (flags & __GFP_PROTECT)
+		return ZONE_PROTECT;
+#endif
 	return ZONE_NORMAL;
 }

diff -Nurp old/include/linux/km_protect.h new/include/linux/km_protect.h
--- old/include/linux/km_protect.h	1970-01-01 08:00:00.000000000 +0800
+++ new/include/linux/km_protect.h	2008-12-26 22:25:39.000000000 +0800
@@ -0,0 +1,53 @@
+/*
+ * (C) 2008, Pengfei Hu
+ */
+
+#ifndef _LINUX_KM_PROTECT_H
+#define	_LINUX_KM_PROTECT_H
+
+#ifdef CONFIG_DEBUG_KM_PROTECT
+
+extern unsigned int protectmem_pages;
+extern unsigned long protectmem_lowest_pfn;
+extern unsigned long protectmem_highest_pfn;
+#ifndef CONFIG_X86_PAE
+extern unsigned short *km_table;
+#define KM_TABLE_SIZE protectmem_pages*sizeof(unsigned short)
+#endif
+int __set_pages_p(struct page *page, int numpages);
+int __set_pages_np(struct page *page, int numpages);
+
+#define MAX_KM_ID 0xffff
+extern unsigned short cur_km_id;
+
+struct km_struct {
+	unsigned short id;
+	struct kmem_cache *kmalloc_caches[PAGE_SHIFT];
+	char name[0];
+};
+
+void __init km_protect_init(void);
+void __init km_protect_dbginit(void);
+void km_protect_addr(unsigned long addr, int numpages);
+void km_unprotect_addr(unsigned long addr, int numpages);
+void km_alloc_handle(const char *name, struct km_struct **handle);
+void km_free_handle(struct km_struct *handle);
+void km_set_handle(struct km_struct *handle, struct km_struct **prev);
+bool km_valid_addr(unsigned long addr);
+
+#else /* CONFIG_DEBUG_KM_PROTECT */
+
+#define km_alloc_handle(name, handle)
+#define km_free_handle(handle)
+#define km_set_handle(handle, prev)
+
+static inline void __init km_protect_init(void)
+{
+}
+static inline void __init km_protect_dbginit(void)
+{
+}
+
+#endif /* CONFIG_DEBUG_KM_PROTECT */
+
+#endif	/* _LINUX_KM_PROTECT_H */
diff -Nurp old/include/linux/mmzone.h new/include/linux/mmzone.h
--- old/include/linux/mmzone.h	2008-10-10 06:13:53.000000000 +0800
+++ new/include/linux/mmzone.h	2008-11-17 11:34:06.000000000 +0800
@@ -169,6 +169,12 @@ enum zone_type {
 	 * transfers to all addressable memory.
 	 */
 	ZONE_NORMAL,
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	/*
+	 * ZONE_PROTECT is used only when allocate page with __GFP_KM_PROTECT.
+	 */
+	ZONE_PROTECT,
+#endif
 #ifdef CONFIG_HIGHMEM
 	/*
 	 * A memory area that is only addressable by the kernel through
@@ -198,7 +204,7 @@ enum zone_type {
 #define ZONES_SHIFT 0
 #elif MAX_NR_ZONES <= 2
 #define ZONES_SHIFT 1
-#elif MAX_NR_ZONES <= 4
+#elif MAX_NR_ZONES <= 5
 #define ZONES_SHIFT 2
 #else
 #error ZONES_SHIFT -- too many zones configured adjust calculation
diff -Nurp old/include/linux/sched.h new/include/linux/sched.h
--- old/include/linux/sched.h	2008-10-10 06:13:53.000000000 +0800
+++ new/include/linux/sched.h	2008-12-07 19:19:40.000000000 +0800
@@ -1060,6 +1060,9 @@ struct task_struct {
 	 */
 	unsigned char fpu_counter;
 	s8 oomkilladj; /* OOM kill score adjustment (bit shift). */
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	struct km_struct *km_handle;
+#endif
 #ifdef CONFIG_BLK_DEV_IO_TRACE
 	unsigned int btrace_seq;
 #endif
diff -Nurp old/include/linux/slab.h new/include/linux/slab.h
--- old/include/linux/slab.h	2008-10-10 06:13:53.000000000 +0800
+++ new/include/linux/slab.h	2008-12-07 19:19:40.000000000 +0800
@@ -37,6 +37,12 @@
 /* The following flags affect the page allocator grouping pages by mobility */
 #define SLAB_RECLAIM_ACCOUNT	0x00020000UL		/* Objects are reclaimable */
 #define SLAB_TEMPORARY		SLAB_RECLAIM_ACCOUNT	/* Objects are short-lived */
+
+#ifdef CONFIG_DEBUG_KM_PROTECT
+#define SLAB_PROTECT	0x00000200UL	/* Kernel memory protect */
+#else
+#define SLAB_PROTECT	0x00000000UL
+#endif
 /*
  * ZERO_SIZE_PTR will be returned for zero sized kmalloc requests.
  *
diff -Nurp old/include/linux/slub_def.h new/include/linux/slub_def.h
--- old/include/linux/slub_def.h	2008-10-10 06:13:53.000000000 +0800
+++ new/include/linux/slub_def.h	2008-12-14 21:24:48.000000000 +0800
@@ -211,7 +211,7 @@ static __always_inline void *kmalloc_lar

 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
-	if (__builtin_constant_p(size)) {
+	if (__builtin_constant_p(size) && (!(flags & __GFP_PROTECT))) {
 		if (size > PAGE_SIZE)
 			return kmalloc_large(size, flags);

diff -Nurp old/init/main.c new/init/main.c
--- old/init/main.c	2008-10-10 06:13:53.000000000 +0800
+++ new/init/main.c	2008-11-01 17:56:01.000000000 +0800
@@ -60,6 +60,7 @@
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/idr.h>
+#include <linux/km_protect.h>

 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -644,6 +645,7 @@ asmlinkage void __init start_kernel(void
 #endif
 	vfs_caches_init_early();
 	cpuset_init_early();
+	km_protect_init();
 	mem_init();
 	enable_debug_pagealloc();
 	cpu_hotplug_init();
@@ -678,6 +680,7 @@ asmlinkage void __init start_kernel(void
 #ifdef CONFIG_PROC_FS
 	proc_root_init();
 #endif
+	km_protect_dbginit();
 	cgroup_init();
 	cpuset_init();
 	taskstats_init_early();
diff -Nurp old/kernel/fork.c new/kernel/fork.c
--- old/kernel/fork.c	2008-10-10 06:13:53.000000000 +0800
+++ new/kernel/fork.c	2008-12-07 19:19:40.000000000 +0800
@@ -932,6 +932,9 @@ static struct task_struct *copy_process(
 	if (!p)
 		goto fork_out;

+#ifdef CONFIG_DEBUG_KM_PROTECT
+	p->km_handle = NULL;
+#endif
 	rt_mutex_init_task(p);

 #ifdef CONFIG_PROVE_LOCKING
diff -Nurp old/kernel/sched.c new/kernel/sched.c
--- old/kernel/sched.c	2008-10-10 06:13:53.000000000 +0800
+++ new/kernel/sched.c	2008-12-07 19:19:40.000000000 +0800
@@ -2606,6 +2606,10 @@ context_switch(struct rq *rq, struct tas
 	 */
 	arch_enter_lazy_cpu_mode();

+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if (prev->km_handle != NULL)
+		__flush_tlb_all();
+#endif
 	if (unlikely(!mm)) {
 		next->active_mm = oldmm;
 		atomic_inc(&oldmm->mm_count);
diff -Nurp old/mm/page_alloc.c new/mm/page_alloc.c
--- old/mm/page_alloc.c	2008-10-10 06:13:53.000000000 +0800
+++ new/mm/page_alloc.c	2008-12-07 19:19:40.000000000 +0800
@@ -46,6 +46,7 @@
 #include <linux/page-isolation.h>
 #include <linux/memcontrol.h>
 #include <linux/debugobjects.h>
+#include <linux/km_protect.h>

 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -112,6 +113,9 @@ static char * const zone_names[MAX_NR_ZO
 	 "DMA32",
 #endif
 	 "Normal",
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	 "Protect",
+#endif
 #ifdef CONFIG_HIGHMEM
 	 "HighMem",
 #endif
@@ -147,8 +151,8 @@ static unsigned long __meminitdata dma_r

   static struct node_active_region __meminitdata
early_node_map[MAX_ACTIVE_REGIONS];
   static int __meminitdata nr_nodemap_entries;
-  static unsigned long __meminitdata
arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
-  static unsigned long __meminitdata
arch_zone_highest_possible_pfn[MAX_NR_ZONES];
+  unsigned long __meminitdata arch_zone_lowest_possible_pfn[MAX_NR_ZONES];
+  unsigned long __meminitdata arch_zone_highest_possible_pfn[MAX_NR_ZONES];
 #ifdef CONFIG_MEMORY_HOTPLUG_RESERVE
   static unsigned long __meminitdata node_boundary_start_pfn[MAX_NUMNODES];
   static unsigned long __meminitdata node_boundary_end_pfn[MAX_NUMNODES];
@@ -1411,6 +1415,14 @@ zonelist_scan:
 			}
 		}

+#ifdef CONFIG_DEBUG_KM_PROTECT
+		if (ZONE_PROTECT == z->zone_idx) {
+			if (gfp_mask & __GFP_PROTECT)
+				return buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
+			else
+				continue;
+		}
+#endif
 		page = buffered_rmqueue(preferred_zone, zone, order, gfp_mask);
 		if (page)
 			break;
@@ -1638,6 +1650,10 @@ nopage:
 		show_mem();
 	}
 got_pg:
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if (gfp_mask & __GFP_PROTECT)
+		km_protect_addr((unsigned long)page_address(page), (1 << order));
+#endif
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_internal);
@@ -1689,6 +1705,10 @@ void __free_pages(struct page *page, uns
 			free_hot_page(page);
 		else
 			__free_pages_ok(page, order);
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if (!PageHighMem(page))
+		km_unprotect_addr((unsigned long)page_address(page), (1 << order));
+#endif
 	}
 }

diff -Nurp old/mm/slub.c new/mm/slub.c
--- old/mm/slub.c	2008-10-10 06:13:53.000000000 +0800
+++ new/mm/slub.c	2008-12-12 21:12:03.000000000 +0800
@@ -23,6 +23,7 @@
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
 #include <linux/math64.h>
+#include <linux/km_protect.h>

 /*
  * Lock order:
@@ -139,7 +140,7 @@
  * Set of flags that will prevent slab merging
  */
 #define SLUB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
-		SLAB_TRACE | SLAB_DESTROY_BY_RCU)
+		SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_PROTECT)

 #define SLUB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
 		SLAB_CACHE_DMA)
@@ -2284,6 +2285,9 @@ static int calculate_sizes(struct kmem_c
 	if (s->flags & SLAB_RECLAIM_ACCOUNT)
 		s->allocflags |= __GFP_RECLAIMABLE;

+	if (s->flags & SLAB_PROTECT)
+		s->allocflags |= __GFP_PROTECT;
+
 	/*
 	 * Determine the number of objects per slab
 	 */
@@ -2643,6 +2647,10 @@ static struct kmem_cache *get_slab(size_
 		return dma_kmalloc_cache(index, flags);

 #endif
+#ifdef CONFIG_DEBUG_KM_PROTECT
+	if (unlikely(flags & __GFP_PROTECT))
+		return current->km_handle->kmalloc_caches[index - 1];
+#endif
 	return &kmalloc_caches[index];
 }


Regards,
Pengfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
