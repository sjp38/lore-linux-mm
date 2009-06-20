From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 14/15] HWPOISON: Add simple debugfs interface to inject hwpoison on arbitary PFNs
Date: Sat, 20 Jun 2009 11:16:22 +0800
Message-ID: <20090620031626.631590814@intel.com>
References: <20090620031608.624240019@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A0FC76B0062
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 23:19:30 -0400 (EDT)
Content-Disposition: inline; filename=pfn-inject
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "Wu, Fengguang" <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

From: Andi Kleen <ak@linux.intel.com>

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

--- /dev/null
+++ sound-2.6/mm/hwpoison-inject.c
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
--- sound-2.6.orig/mm/Kconfig
+++ sound-2.6/mm/Kconfig
@@ -242,6 +242,10 @@ config KSM
 config MEMORY_FAILURE
 	bool
 
+config HWPOISON_INJECT
+	tristate "Hardware poison pages injector"
+	depends on MEMORY_FAILURE && DEBUG_KERNEL
+
 config NOMMU_INITIAL_TRIM_EXCESS
 	int "Turn on mmap() excess space trimming before booting"
 	depends on !MMU
--- sound-2.6.orig/mm/Makefile
+++ sound-2.6/mm/Makefile
@@ -43,5 +43,6 @@ endif
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
 obj-$(CONFIG_MEMORY_FAILURE) += memory-failure.o
+obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
