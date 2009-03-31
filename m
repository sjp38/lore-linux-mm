Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2E05F6B0047
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:52:31 -0400 (EDT)
Subject: Detailed Stack Information Patch [2/3]
From: Stefani Seibold <stefani@seibold.net>
Content-Type: text/plain
Date: Tue, 31 Mar 2009 16:58:27 +0200
Message-Id: <1238511507.364.62.camel@matrix>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Joerg Engel <joern@logfs.org>
List-ID: <linux-mm.kvack.org>

diff -u -N -r linux-2.6.29.orig/fs/proc/Makefile linux-2.6.29/fs/proc/Makefile
--- linux-2.6.29.orig/fs/proc/Makefile	2009-03-24 00:12:14.000000000 +0100
+++ linux-2.6.29/fs/proc/Makefile	2009-03-31 16:08:26.000000000 +0200
@@ -25,3 +25,4 @@
 proc-$(CONFIG_PROC_DEVICETREE)	+= proc_devtree.o
 proc-$(CONFIG_PRINTK)	+= kmsg.o
 proc-$(CONFIG_PROC_PAGE_MONITOR)	+= page.o
+proc-$(CONFIG_PROC_STACK_MONITOR) += stackmon.o
diff -u -N -r linux-2.6.29.orig/fs/proc/stackmon.c linux-2.6.29/fs/proc/stackmon.c
--- linux-2.6.29.orig/fs/proc/stackmon.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.29/fs/proc/stackmon.c	2009-03-31 16:08:26.000000000 +0200
@@ -0,0 +1,254 @@
+/*
+ * detailed stack monitoring
+ *
+ *	Copyright (C) 2009 Stefani Seibold for NSN
+ *	This Source is under GPL Licence
+ *
+ * enabled when CONFIG_PROC_STACK_MONITOR is set
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
+#include <linux/proc_fs.h>
+#include <linux/pagemap.h>
+#include <linux/init.h>
+#include <linux/stddef.h>
+#include <linux/mutex.h>
+#include <linux/kthread.h>
+#include <linux/freezer.h>
+#include <linux/seq_file.h>
+
+#define	PROC_STACKMON	"stackmon"
+
+#define	BUF_SIZE	1024
+
+static struct mutex		lock;
+
+static struct proc_dir_entry	*proc_ent;
+
+#ifdef CONFIG_STACK_GROWSUP
+static inline unsigned long get_top(struct vm_area_struct *vma,
+					unsigned long end)
+{
+	unsigned long	i;
+	struct page	*page;
+
+	for (i = vma->vm_end; i-PAGE_SIZE > end; i -= PAGE_SIZE) {
+
+		page = follow_page(vma, i-PAGE_SIZE, 0);
+
+		if ((!IS_ERR(page) == 0) || (page))
+			break;
+	}
+	return (i-end)/PAGE_SIZE;
+}
+#else
+static inline unsigned long get_top(struct vm_area_struct *vma,
+					unsigned long end)
+{
+	unsigned long	i;
+	struct page	*page;
+
+	for (i = vma->vm_start; i+PAGE_SIZE <= end; i += PAGE_SIZE) {
+
+		page = follow_page(vma, i, 0);
+
+		if ((!IS_ERR(page) == 0) || (page))
+			break;
+	}
+	return (end-i)/PAGE_SIZE;
+}
+#endif
+
+#ifdef CONFIG_STACK_GROWSUP
+#define STACK_PAGE(x)	(((x)+PAGE_SIZE-1)/PAGE_SIZE)
+#else
+#define STACK_PAGE(x)	(((x)-PAGE_SIZE-1)/PAGE_SIZE)
+#endif
+
+static inline int dump_usage(struct task_struct *t, char *buf)
+{
+	struct vm_area_struct	*vma;
+	struct mm_struct	*mm;
+
+	*buf = 0;
+
+	mm = get_task_mm(t);
+
+	if (mm) {
+		vma = find_vma(mm, t->stack_start);
+
+		if (vma) {
+			unsigned long	esp;
+			unsigned long	cur_stack;
+			unsigned long	real_stack;
+
+			esp = KSTK_ESP(t);
+
+#ifdef CONFIG_STACK_GROWSUP
+			cur_stack = esp-t->stack_start;
+			real_stack =
+				STACK_PAGE(esp)-STACK_PAGE(t->stack_start)+1;
+#else
+			cur_stack = t->stack_start-esp;
+			real_stack =
+				STACK_PAGE(t->stack_start)-STACK_PAGE(esp)+1;
+#endif
+			snprintf(
+				buf,
+				BUF_SIZE,
+				" %7lu %7lu %7lu  %08lx-%08lx pid:%5d "
+				"tid:%5d %s\n",
+				cur_stack,
+				real_stack,
+				(real_stack+get_top(vma, esp)),
+				vma->vm_start,
+				vma->vm_end,
+				t->tgid,
+				t->pid,
+				t->comm
+			);
+		}
+		mmput(mm);
+	}
+	return 0;
+}
+
+static void *stackmon_find(loff_t pos, char *buf)
+{
+	struct task_struct *g;
+	struct task_struct *t;
+
+	loff_t off = 0;
+
+	read_lock(&tasklist_lock);
+
+	do_each_thread(g, t) {
+		if (pos == off++)
+			goto found;
+	} while_each_thread(g, t);
+
+	read_unlock(&tasklist_lock);
+	return 0;
+found:
+	task_lock(t);
+	dump_usage(t, buf);
+	task_unlock(t);
+	read_unlock(&tasklist_lock);
+	return buf;
+}
+
+static void *stackmon_seq_start(struct seq_file *s, loff_t *pos)
+{
+	if (*pos == 0)
+		return SEQ_START_TOKEN;
+
+	return stackmon_find(*pos, s->private);
+}
+
+
+static void *stackmon_seq_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	++*pos;
+
+	return stackmon_find(*pos, s->private);
+}
+
+static int stackmon_seq_show(struct seq_file *s, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		return seq_puts(s,
+			"   bytes   pages maxpages vm_start vm_end   "
+			"processid threadid  name\n");
+	}
+
+	return seq_puts(s, v);
+}
+
+static void stackmon_seq_stop(struct seq_file *s, void *v)
+{
+}
+
+static const struct seq_operations stackmon_seq_ops = {
+	.start	= stackmon_seq_start,
+	.next	= stackmon_seq_next,
+	.stop	= stackmon_seq_stop,
+	.show	= stackmon_seq_show
+};
+
+static int stackmon_open(struct inode *inode, struct file *file)
+{
+	int	ret;
+	char	*buffer;
+	struct seq_file *s;
+
+	ret = -ENOMEM;
+
+	buffer = kmalloc(BUF_SIZE, GFP_KERNEL);
+	if (!buffer)
+		goto out;
+
+	ret = seq_open(file, &stackmon_seq_ops);
+	if (ret)
+		goto out_kfree;
+
+	s = file->private_data;
+	s->private = buffer;
+
+out:
+	return ret;
+
+out_kfree:
+	kfree(buffer);
+	return ret;
+}
+
+static const struct file_operations stackmon_file_ops = {
+	.owner		= THIS_MODULE,
+	.open		= stackmon_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+
+static int __init stackmon_init(void)
+{
+	int ret = 0;
+
+	mutex_init(&lock);
+
+	proc_ent = create_proc_entry(PROC_STACKMON, 0440, NULL);
+
+	if (proc_ent == NULL)
+		goto exit;
+
+	proc_ent->owner = THIS_MODULE;
+	proc_ent->data = NULL;
+	proc_ent->proc_fops = &stackmon_file_ops;
+
+	return ret;
+
+exit:
+	return -ENOMEM;
+}
+
+static void __exit stackmon_exit(void)
+{
+	mutex_lock(&lock);
+	remove_proc_entry(PROC_STACKMON, NULL);
+	mutex_unlock(&lock);
+}
+
+module_init(stackmon_init);
+module_exit(stackmon_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Stefani Seibold <stefani@seibold.net>");
+MODULE_DESCRIPTION("detailed stack monitoring");
+
diff -u -N -r linux-2.6.29.orig/init/Kconfig linux-2.6.29/init/Kconfig
--- linux-2.6.29.orig/init/Kconfig	2009-03-31 16:08:11.000000000 +0200
+++ linux-2.6.29/init/Kconfig	2009-03-31 16:08:26.000000000 +0200
@@ -964,6 +964,16 @@
 	  Disabling these interfaces will reduce the size of the kernel by
 	  approximately 1kb.
 
+config PROC_STACK_MONITOR
+ 	default y
+	depends on PROC_STACK
+	bool "Enable /proc/stackmon detailed stack monitoring"
+ 	help
+	  This enables detailed monitoring of process and thread stack
+	  utilization via the /proc/stackmon interface.
+	  Disabling these interfaces will reduce the size of the kernel by
+	  approximately 2kb.
+
 endmenu		# General setup
 
 config HAVE_GENERIC_DMA_COHERENT


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
