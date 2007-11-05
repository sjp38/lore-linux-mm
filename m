Received: by ug-out-1314.google.com with SMTP id h3so965471ugf
        for <linux-mm@kvack.org>; Mon, 05 Nov 2007 06:47:59 -0800 (PST)
Date: Mon, 05 Nov 2007 15:47:53 +0100
Subject: [RFC Patch] Thrashing notification
From: =?utf-8?Q?Daniel_Sp=C3=A5ng?= <daniel.spang@gmail.com>
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-ID: <op.t1bp13jkk4ild9@bingo>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: marcelo@kvack.org, drepper@redhat.com, riel@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com, 7eggert@gmx.de
List-ID: <linux-mm.kvack.org>

This patch provides a way to notify user applications when the system
is about to thrash. It checks the scanning priority of the inactive
lru list and notifies user applications via sysfs when the priority
reaches a threshold. In comparison to Marcelo Tosatti's oom
notification patch, this patch also works on systems without swap.

Applications can poll() on this sysfs file and can then free memory in
one way or another to prevent an oom situation.

Using a test application http://spng.se/oomtest/ that uses multiple
allocator threads and a single release thread one can see that this
works fairly well. See http://spng.se/oomtest/ for more details
and graphs.

Signed-off-by: Daniel SpAJPYng <daniel.spang@gmail.com>

diff -purN linux-2.6.23.1-mm1/include/linux/thrashing_notify.h linux-2.6.23.1-mm1_thrashing/include/linux/thrashing_notify.h
--- linux-2.6.23.1-mm1/include/linux/thrashing_notify.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.23.1-mm1_thrashing/include/linux/thrashing_notify.h	2007-11-05 14:23:26.000000000 +0100
@@ -0,0 +1,8 @@
+#ifndef _LINUX_THRASHING_NOTIFY_H
+#define _LINUX_THRASHING_NOTIFY_H
+
+void thrashing_notify(int priority);
+
+extern int thrashing_notifier_threshold;
+
+#endif /* _LINUX_THRASHING_NOTIFY_H */
diff -purN linux-2.6.23.1-mm1/kernel/sysctl.c linux-2.6.23.1-mm1_thrashing/kernel/sysctl.c
--- linux-2.6.23.1-mm1/kernel/sysctl.c	2007-11-01 14:59:16.000000000 +0100
+++ linux-2.6.23.1-mm1_thrashing/kernel/sysctl.c	2007-11-05 14:22:29.000000000 +0100
@@ -46,6 +46,7 @@
 #include <linux/nfs_fs.h>
 #include <linux/acpi.h>
 #include <linux/reboot.h>
+#include <linux/thrashing_notify.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -102,6 +103,7 @@ static int minolduid;
 static int min_percpu_pagelist_fract = 8;
 
 static int ngroups_max = NGROUPS_MAX;
+static int def_priority = DEF_PRIORITY;
 
 #ifdef CONFIG_KMOD
 extern char modprobe_path[];
@@ -1071,6 +1073,16 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 #endif
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "thrashing_notifier_threshold",
+		.data		= &thrashing_notifier_threshold,
+		.maxlen		= sizeof thrashing_notifier_threshold,
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &def_priority,
+	},
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
diff -purN linux-2.6.23.1-mm1/mm/Makefile linux-2.6.23.1-mm1_thrashing/mm/Makefile
--- linux-2.6.23.1-mm1/mm/Makefile	2007-11-01 14:59:16.000000000 +0100
+++ linux-2.6.23.1-mm1_thrashing/mm/Makefile	2007-11-05 14:22:11.000000000 +0100
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o $(mmu-y)
+			   page_isolation.o thrashing_notify.o $(mmu-y)
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
diff -purN linux-2.6.23.1-mm1/mm/thrashing_notify.c linux-2.6.23.1-mm1_thrashing/mm/thrashing_notify.c
--- linux-2.6.23.1-mm1/mm/thrashing_notify.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.23.1-mm1_thrashing/mm/thrashing_notify.c	2007-11-05 14:22:46.000000000 +0100
@@ -0,0 +1,56 @@
+/*
+ * mm/thrashing_notify.c
+ *
+ * Copyright (C) 2007 Daniel SpAJPYng <daniel.spang@gmail.com>
+ *
+ * Released under the GPL, see the file COPYING for details.
+ */
+
+#include <linux/thrashing_notify.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/mman.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/kobject.h>
+#include <linux/sysfs.h>
+
+/*
+ * The count of thrashing occasions.
+ *
+ * Published to userspace at /sys/kernel/nr_thrashing
+ */
+int nr_thrashing = 0;
+
+int thrashing_notifier_threshold = 4;
+
+static ssize_t nr_thrashing_show(struct kset *kset, char *page)
+{
+	return sprintf(page, "%u\n", nr_thrashing);
+}
+
+static struct subsys_attribute nr_thrashing_attr = __ATTR_RO(nr_thrashing);
+
+static struct attribute *nr_thrashing_attrs[] = {
+	&nr_thrashing_attr.attr,
+	NULL,
+};
+
+static struct attribute_group nr_thrashing_attr_group = {
+	.attrs  = nr_thrashing_attrs,
+};
+
+void thrashing_notify(int priority)
+{
+	nr_thrashing++;
+	sysfs_notify(&kernel_subsys.kobj, NULL, "nr_thrashing");
+}
+
+static int __init thrashing_init(void)
+{
+	return sysfs_create_group(&kernel_subsys.kobj,
+			       &nr_thrashing_attr_group);
+}
+
+module_init(thrashing_init)
+
diff -purN linux-2.6.23.1-mm1/mm/vmscan.c linux-2.6.23.1-mm1_thrashing/mm/vmscan.c
--- linux-2.6.23.1-mm1/mm/vmscan.c	2007-11-01 14:59:16.000000000 +0100
+++ linux-2.6.23.1-mm1_thrashing/mm/vmscan.c	2007-11-05 14:21:55.000000000 +0100
@@ -39,6 +39,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/memcontrol.h>
+#include <linux/thrashing_notify.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1285,6 +1286,9 @@ static unsigned long do_try_to_free_page
 		sc->nr_io_pages = 0;
 		if (!priority)
 			disable_swap_token();
+		if (priority == thrashing_notifier_threshold)
+			thrashing_notify(priority);
 		nr_reclaimed += shrink_zones(priority, zones, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
@@ -1448,7 +1452,9 @@ loop_again:
 		/* The swap token gets in the way of swapout... */
 		if (!priority)
 			disable_swap_token();
+		if (priority == thrashing_notifier_threshold)
+			thrashing_notify(priority);
 		sc.nr_io_pages = 0;
 		all_zones_ok = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
