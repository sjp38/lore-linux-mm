Subject: [RFC][PATCH 1/5] RSS accounting setup
Message-Id: <20070205132408.0E9281B676@openx4.frec.bull.fr>
Date: Mon, 5 Feb 2007 14:24:08 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, menage@google.com
List-ID: <linux-mm.kvack.org>

Basic setup for a memory controller written for resource groups.
This patch registers a dummy controller.

Signed-off-by: Patrick Le Dot <Patrick.Le-Dot@bull.net>
---

 include/linux/memctlr.h    |   33 +++++++++++++++
 init/Kconfig               |   11 +++++
 kernel/res_group/Makefile  |    1
 kernel/res_group/memctlr.c |   98 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 143 insertions(+)

diff -puN /dev/null b/include/linux/memctlr.h
--- /dev/null	2004-02-23 22:02:56.000000000 +0100
+++ b/include/linux/memctlr.h	2006-12-08 07:25:42.000000000 +0100
@@ -0,0 +1,33 @@
+/*
+ * Memory controller - "Resource Groups Memory Usage Accounting"
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2006
+ * Copyright (C) BULL SAS, 2006
+ *
+ * Author: Balbir Singh <balbir@in.ibm.com>
+ *         Patrick Le Dot <Patrick.Le-Dot@bull.net>
+ *
+ */
+
+#ifndef _LINUX_MEMCTRL_H
+#define _LINUX_MEMCTRL_H
+
+#ifdef CONFIG_RES_GROUPS_MEMORY
+#include <linux/res_group_rc.h>
+#endif /* CONFIG_RES_GROUPS_MEMORY */
+
+#endif /* _LINUX_MEMCTRL_H */
diff -puN a/init/Kconfig b/init/Kconfig
--- a/init/Kconfig	2006-12-08 07:10:24.000000000 +0100
+++ b/init/Kconfig	2006-12-08 07:11:54.000000000 +0100
@@ -332,6 +332,17 @@ config RES_GROUPS_NUMTASKS
 
 	  Say N if unsure, Y to use the feature.
 
+config RES_GROUPS_MEMORY
+	bool "Memory Controller for RSS"
+	depends on RES_GROUPS
+	default y
+	help
+	  Provides a Resource Controller for Resource Groups.
+	  It limits the resident pages of the tasks belonging to the resource
+	  group.
+
+	  Say N if unsure, Y to use the feature.
+
 endmenu
 config SYSCTL
 	bool
diff -puN a/kernel/res_group/Makefile b/kernel/res_group/Makefile
--- a/kernel/res_group/Makefile	2006-12-08 07:10:24.000000000 +0100
+++ b/kernel/res_group/Makefile	2006-12-08 07:11:03.000000000 +0100
@@ -1,2 +1,3 @@
 obj-y = res_group.o shares.o rgcs.o
 obj-$(CONFIG_RES_GROUPS_NUMTASKS) += numtasks.o
+obj-$(CONFIG_RES_GROUPS_MEMORY) += memctlr.o
diff -puN /dev/null b/kernel/res_group/memctlr.c
--- /dev/null	2004-02-23 22:02:56.000000000 +0100
+++ b/kernel/res_group/memctlr.c	2006-12-08 08:56:30.000000000 +0100
@@ -0,0 +1,98 @@
+/*
+ * Memory controller - "Resource Groups Memory Usage Accounting"
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ *
+ * Copyright (C) IBM Corporation, 2006
+ * Copyright (C) BULL SAS, 2006
+ *
+ * Author: Balbir Singh <balbir@in.ibm.com>
+ *         Patrick Le Dot <Patrick.Le-Dot@bull.net>
+ *
+ */
+
+/*
+ * Simple memory controller with a sane accounting.
+ * First implementation : only pages in VMAs are concerned.
+ * Limits and guarantees will be supported later.
+ *
+ * Tasks are group'ed virtually by thread groups - Add more details
+ */
+
+#include <linux/module.h>
+#include <linux/res_group_rc.h>
+#include <linux/memctlr.h>
+
+static const char res_ctlr_name[] = "memctlr";
+static struct resource_group *root_rgroup;
+
+/*
+ * this struct is used in mm_struct
+ */
+struct mem_counter {
+	atomic_long_t	rss;	
+};
+
+/*
+ * one memctlr per group then counter is the group's rss value
+ */
+struct memctlr {
+	struct res_shares shares;	/* My shares		  */
+	struct mem_counter counter;	/* Accounting information */
+};
+
+struct res_controller memctlr_rg;
+
+static struct memctlr *get_memctlr_from_shares(struct res_shares *shares)
+{
+	if (shares)
+		return container_of(shares, struct memctlr, shares);
+	return NULL;
+}
+
+static struct memctlr *get_memctlr(struct resource_group *rgroup)
+{
+	return get_memctlr_from_shares(get_controller_shares(rgroup,
+								&memctlr_rg));
+}
+
+struct res_controller memctlr_rg = {
+	.name = res_ctlr_name,
+	.ctlr_id = NO_RES_ID,
+	.alloc_shares_struct = NULL,
+	.free_shares_struct = NULL,
+	.move_task = NULL,
+	.shares_changed = NULL,
+	.show_stats = NULL,
+};
+
+int __init memctlr_init(void)
+{
+	if (memctlr_rg.ctlr_id != NO_RES_ID)
+		return -EBUSY;	/* already registered */
+	return register_controller(&memctlr_rg);
+}
+
+void __exit memctlr_exit(void)
+{
+	int rc;
+	do {
+		rc = unregister_controller(&memctlr_rg);
+	} while (rc == -EBUSY);
+	BUG_ON(rc != 0);
+}
+
+module_init(memctlr_init);
+module_exit(memctlr_exit);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
