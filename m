Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81ED66B008C
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 17:28:52 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
References: <200906041128.112757038@firstfloor.org>
In-Reply-To: <200906041128.112757038@firstfloor.org>
Subject: [PATCH] [15/15] HWPOISON: Add simple debugfs interface to inject hwpoison on arbitary PFNs
Message-Id: <20090604212827.7661E1D0294@basil.firstfloor.org>
Date: Thu,  4 Jun 2009 23:28:27 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Useful for some testing scenarios, although specific testing is often
done better through MADV_POISON

This can be done with the x86 level MCE injector too, but this interface
allows it to do independently from low level x86 changes.

Open issues: 

Should be disabled for cgroups.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/Kconfig           |    4 ++++
 mm/Makefile          |    1 +
 mm/hwpoison-inject.c |   41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 46 insertions(+)

Index: linux/mm/hwpoison-inject.c
===================================================================
--- /dev/null
+++ linux/mm/hwpoison-inject.c
@@ -0,0 +1,41 @@
+/* Inject a hwpoison memory failure on a arbitary pfn */
+#include <linux/module.h>
+#include <linux/debugfs.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+
+static struct dentry *hwpoison_dir, *corrupt_pfn;
+
+static int hwpoison_inject(void *data, u64 val)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	printk(KERN_INFO "Injecting memory failure at pfn %Lx\n", val);
+	memory_failure(val, 18);
+	return 0;
+}
+
+DEFINE_SIMPLE_ATTRIBUTE(hwpoison_fops, NULL, hwpoison_inject, "%lli\n");
+
+static void pfn_inject_exit(void)
+{
+	if (hwpoison_dir)
+		debugfs_remove_recursive(hwpoison_dir);
+}
+
+static int pfn_inject_init(void)
+{
+	hwpoison_dir = debugfs_create_dir("hwpoison", NULL);
+	if (hwpoison_dir == NULL)
+		return -ENOMEM;
+	corrupt_pfn = debugfs_create_file("corrupt-pfn", 0600, hwpoison_dir,
+					  NULL, &hwpoison_fops);
+	if (corrupt_pfn == NULL) {
+		pfn_inject_exit();
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+module_init(pfn_inject_init);
+module_exit(pfn_inject_exit);
Index: linux/mm/Kconfig
===================================================================
--- linux.orig/mm/Kconfig
+++ linux/mm/Kconfig
@@ -225,6 +225,10 @@ config MEMORY_FAILURE
 	default y
 	depends on MMU
 
+config HWPOISON_INJECT
+	tristate "Poison pages injector"
+	depends on MEMORY_FAILURE && DEBUG_KERNEL
+
 config NOMMU_INITIAL_TRIM_EXCESS
 	int "Turn on mmap() excess space trimming before booting"
 	depends on !MMU
Index: linux/mm/Makefile
===================================================================
--- linux.orig/mm/Makefile
+++ linux/mm/Makefile
@@ -43,5 +43,6 @@ endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
+obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
