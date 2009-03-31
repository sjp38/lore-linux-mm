Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5454C6B004D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:52:37 -0400 (EDT)
Subject: Detailed Stack Information Patch [3/3]
From: Stefani Seibold <stefani@seibold.net>
Content-Type: text/plain
Date: Tue, 31 Mar 2009 16:58:33 +0200
Message-Id: <1238511513.364.63.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

diff -u -N -r linux-2.6.29.orig/init/Kconfig linux-2.6.29/init/Kconfig
--- linux-2.6.29.orig/init/Kconfig	2009-03-31 16:09:42.000000000 +0200
+++ linux-2.6.29/init/Kconfig	2009-03-31 16:09:58.000000000 +0200
@@ -974,6 +974,18 @@
 	  Disabling these interfaces will reduce the size of the kernel by
 	  approximately 2kb.
 
+config PROC_STACK_DEBUG
+ 	default n
+	depends on PROC_STACK
+	tristate "Enable stack monitoring debug" if EMBEDDED
+ 	help
+	  This enables a stack monitoring debug interface. Each process or
+	  thread which exceeds the stack limit will receive a SIGTRAP.
+	  Attaching a debugger to the process will give you the ability to
+	  examinate the stack usage.
+	  Disabling these interfaces will reduce the size of the kernel by
+	  approximately 2kb.
+
 endmenu		# General setup
 
 config HAVE_GENERIC_DMA_COHERENT
diff -u -N -r linux-2.6.29.orig/mm/Makefile linux-2.6.29/mm/Makefile
--- linux-2.6.29.orig/mm/Makefile	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/mm/Makefile	2009-03-31 16:09:58.000000000 +0200
@@ -33,3 +33,4 @@
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_PROC_STACK_DEBUG) += stackdbg.o
diff -u -N -r linux-2.6.29.orig/mm/stackdbg.c linux-2.6.29/mm/stackdbg.c
--- linux-2.6.29.orig/mm/stackdbg.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.29/mm/stackdbg.c	2009-03-31 16:09:58.000000000 +0200
@@ -0,0 +1,319 @@
+/*
+ * stack monitoring debugger
+ *
+ *	Copyright (C) 2009 Stefani Seibold for NSN
+ *     This Source is under GPL Licence
+ *
+ * enabled when CONFIG_PROC_STACK_DEBUG is set
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/pagemap.h>
+#include <linux/init.h>
+#include <linux/stddef.h>
+#include <linux/kthread.h>
+#include <linux/freezer.h>
+
+#define XSTR(x)         #x
+#define STR(x)          XSTR(x)
+
+#define	DEF_STACKSIZE	256
+#define	DEF_MODE	0
+#define	DEF_TICKS	1
+
+static struct task_struct	*thread;
+
+static unsigned long	mode = DEF_MODE;
+static unsigned long	stacksize = DEF_STACKSIZE;
+static unsigned long	ticks = DEF_TICKS;
+
+#ifdef MODULE
+module_param(stacksize, ulong, 0);
+MODULE_PARM_DESC(stacksize, "maximum stack size in kb to trigger"
+			"[default=" STR(DEF_STACKSIZE) "]");
+
+module_param(mode, ulong, 0);
+MODULE_PARM_DESC(mode, "monitor mode: 0=disabled, 1=enabled"
+			"[default=" STR(DEF_MODE) "]");
+
+module_param(ticks, ulong, 0);
+MODULE_PARM_DESC(ticks, "monitoring interval in ticks"
+			"[default=" STR(DEF_TICKS) "]");
+#else
+static int __init stackmon_setup(char *opt)
+{
+	u_long	v;
+	char	*p;
+
+	if (!opt || !*opt)
+		return 1;
+
+	v = simple_strtoul(opt, &p, 10);
+	if (opt == p)
+		return 1;
+	stacksize = v;
+
+	if (*p != ':')
+		return 1;
+	opt = p;
+
+	v = simple_strtoul(opt, &p, 10);
+	if (opt == p)
+		return 1;
+	mode = v;
+
+	if (*p != ':')
+		return 1;
+	opt = p;
+
+	v = simple_strtoul(opt, &p, 10);
+	if (opt == p)
+		return 1;
+	ticks = v;
+
+	return 1;
+}
+
+__setup("stackmon=", stackmon_setup);
+#endif
+
+static inline void check_stack(struct task_struct *t)
+{
+	struct vm_area_struct	*vma;
+	struct mm_struct	*mm;
+	unsigned long		cur_stack;
+	unsigned long		esp;
+
+	mm = get_task_mm(t);
+
+	if (mm == NULL)
+		return;
+
+	vma = find_vma(mm, t->stack_start);
+
+	if (vma) {
+		esp = KSTK_ESP(t);
+
+#ifdef CONFIG_STACK_GROWSUP
+		cur_stack = esp-t->stack_start;
+#else
+		cur_stack = t->stack_start-esp;
+#endif
+
+		if (
+			(cur_stack >= stacksize*1024) &&
+			(!task_is_stopped_or_traced(t->group_leader))
+		) {
+			printk(
+			"pid:%d (%s) tid:%d stack size %lu "
+			"exceeds max stack size.\n"
+			"esp:%08lx eip:%08lx vm_start:%08lx vm_end:%08lx\n",
+			t->tgid,
+			t->comm,
+			t->pid,
+			cur_stack,
+			esp,
+			KSTK_EIP(t),
+			vma->vm_start,
+			vma->vm_end
+			);
+			force_sig(SIGTRAP, t->group_leader);
+		}
+	}
+	mmput(mm);
+}
+
+static int stackmon_thread(void *data)
+{
+	struct task_struct	*g;
+	struct task_struct	*t;
+
+	set_freezable();
+	for (;;) {
+		if (try_to_freeze())
+			continue;
+
+		schedule_timeout(ticks);
+
+		if (kthread_should_stop())
+			break;
+
+		if (mode == 0)
+			continue;
+
+		read_lock(&tasklist_lock);
+
+		do_each_thread(g, t) {
+			task_lock(t);
+			check_stack(t);
+			task_unlock(t);
+		} while_each_thread(g, t);
+
+		read_unlock(&tasklist_lock);
+
+	}
+	thread = NULL;
+
+	return 0;
+}
+
+static void stackmon_enable(void)
+{
+	mode = 1;
+
+	thread = kthread_run(stackmon_thread, NULL, "stackmon");
+
+	if (IS_ERR(thread)) {
+		thread = 0;
+
+		return;
+	}
+	printk(KERN_INFO "stack watch driver enabled with max stack %lu kb.\n",
+		stacksize);
+}
+
+
+static void stackmon_disable(void)
+{
+	mode = 0;
+
+	if (thread) {
+		kthread_stop(thread);
+
+		printk(KERN_INFO "stack watch driver disabled.\n");
+	}
+}
+
+static ssize_t mode_store(struct kobject *kobj, struct kobj_attribute *attr,
+				const char *buf, size_t count)
+{
+	unsigned long	new_mode;
+
+	new_mode = simple_strtoul(buf, NULL, 0);
+
+	if (!new_mode) {
+		if (mode)
+			stackmon_disable();
+	} else {
+		if (mode == 0)
+			stackmon_enable();
+	}
+
+	return count;
+}
+
+
+
+static ssize_t mode_show(struct kobject *kobj, struct kobj_attribute *attr,
+				char *buf)
+{
+	return sprintf(buf, "%lu\n", mode);
+}
+
+static ssize_t stacksize_store(struct kobject *kobj,
+					struct kobj_attribute *attr,
+					const char *buf, size_t count)
+{
+	unsigned long	new_stacksize;
+
+	new_stacksize = simple_strtoul(buf, NULL, 0);
+
+	if (new_stacksize > 0)
+		stacksize = new_stacksize;
+
+	return count;
+}
+
+static ssize_t stacksize_show(struct kobject *kobj,
+				struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lu\n", stacksize);
+}
+
+static ssize_t ticks_store(struct kobject *kobj, struct kobj_attribute *attr,
+				const char *buf, size_t count)
+{
+	unsigned long	new_ticks;
+
+	new_ticks = simple_strtoul(buf, NULL, 0);
+
+	if (new_ticks > 0)
+		ticks = new_ticks;
+
+	return count;
+}
+
+static ssize_t ticks_show(struct kobject *kobj, struct kobj_attribute *attr,
+				char *buf)
+{
+	return sprintf(buf, "%lu\n", ticks);
+}
+
+static struct kobj_attribute mode_attr =
+	__ATTR(mode, 0644, mode_show, mode_store);
+static struct kobj_attribute stacksize_attr =
+	__ATTR(stacksize, 0644, stacksize_show, stacksize_store);
+static struct kobj_attribute ticks_attr =
+	__ATTR(ticks, 0644, ticks_show, ticks_store);
+
+static struct attribute *stackmon_attrs[] = {
+	&mode_attr.attr,
+	&stacksize_attr.attr,
+	&ticks_attr.attr,
+	NULL
+};
+
+static struct attribute_group stackmon_attr_group = {
+	.attrs = stackmon_attrs,
+};
+
+static struct kobject *stackmon_kobj;
+
+static int __init stackmon_init(void)
+{
+	int ret = 0;
+
+	stackmon_kobj = kobject_create_and_add("stackmon", kernel_kobj);
+
+	if (!stackmon_kobj)
+		goto exit;
+
+	ret = sysfs_create_group(stackmon_kobj, &stackmon_attr_group);
+
+	if (ret)
+		goto exit_kobject;
+
+	if (mode)
+		stackmon_enable();
+	else
+		stackmon_disable();
+
+	return ret;
+
+exit_kobject:
+	kobject_put(stackmon_kobj);
+exit:
+	return -ENOMEM;
+}
+
+static void __exit stackmon_exit(void)
+{
+	kobject_uevent(stackmon_kobj, KOBJ_REMOVE);
+	kobject_del(stackmon_kobj);
+	kobject_put(stackmon_kobj);
+}
+
+module_init(stackmon_init);
+module_exit(stackmon_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Stefani Seibold <stefani@seibold.net>");
+MODULE_DESCRIPTION("stack monitoring debugger");
+


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
