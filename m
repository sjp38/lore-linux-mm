Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7EC336B0035
	for <linux-mm@kvack.org>; Fri, 22 Aug 2014 16:56:31 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so16937795pad.37
        for <linux-mm@kvack.org>; Fri, 22 Aug 2014 13:56:31 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id gv10si42322936pbd.90.2014.08.22.13.56.27
        for <linux-mm@kvack.org>;
        Fri, 22 Aug 2014 13:56:27 -0700 (PDT)
Subject: [PATCH] [v4] warn on performance-impacting configs aka. TAINT_PERFORMANCE
From: Dave Hansen <dave@sr71.net>
Date: Fri, 22 Aug 2014 13:56:25 -0700
Message-Id: <20140822205625.657E9890@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org, davej@redhat.com


From: Dave Hansen <dave.hansen@linux.intel.com>

Changes from v3:
 * remove vestiges of TAINT_PERFORMANCE
 * change filename to check-configs
 * fix typos in description
 * print out CONFIG_FOO=y
 * tone down warning message
 * add KMEMCHECK and GCOV
 * add PROVE_LOCKING, but keep LOCKDEP since _anything_ selecting
   it will cause scalaing issues at least.  But, move LOCKDEP
   below LOCK_STAT and PROVE_LOCKING.
 * no more perfo-mance (missing an 'r')
 * temporary variable in lieu of multiple ARRAY_SIZE()
 * break early out of snprintf() loop

Changes from v2:
 * remove tainting and stack track
 * add debugfs file
 * added a little text to guide folks who want to add more
   options

Changes from v1:
 * remove schedstats
 * add DEBUG_PAGEALLOC and SLUB_DEBUG_ON

--

I have more than once myself been the victim of an accidentally-
enabled kernel config option being mistaken for a true
performance problem.

I'm sure I've also taken profiles or performance measurements
and assumed they were real-world when really I was measuring the
performance with an option that nobody turns on in production.

A warning like this late in boot will help remind folks when
these kinds of things are enabled.  We can also teach tooling to
look for and capture /sys/kernel/debug/config_debug .

As for the patch...

I originally wanted this for CONFIG_DEBUG_VM, but I think it also
applies to things like lockdep and slab debugging.  See the patch
for the list of offending config options.  I'm open to adding
more, but this seemed like a good list to start.

The compiler is smart enough to really trim down the code when
the array is empty.  An objdump -d looks like this:

	lib/check-configs.o:     file format elf64-x86-64

	Disassembly of section .init.text:

	000000000000000 <check_configs>:
	  0:	55                   	push   %rbp
	  1:	31 c0                	xor    %eax,%eax
	  3:	48 89 e5             	mov    %rsp,%rbp
	  6:	5d                   	pop    %rbp
	  7:	c3                   	retq

This could be done with Kconfig and an #ifdef to save us 8 bytes
of text and the entry in the late_initcall() section.  Doing it
this way lets us keep the list of these things in one spot, and
also gives us a convenient way to dump out the name of the
offending option.

For anybody that *really* cares, I put the whole thing under
CONFIG_DEBUG_KERNEL in the Makefile.

The messages look like this:

[    3.865297] INFO: Be careful when using this kernel for performance measurement.
[    3.868776] INFO: Potentially performance-altering options enabled:
[    3.871558] 	CONFIG_LOCKDEP=y
[    3.873326] 	CONFIG_SLUB_DEBUG_ON=y

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: ak@linux.intel.com
Cc: tim.c.chen@linux.intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: kirill@shutemov.name
Cc: lauraa@codeaurora.org
Cc: davej@redhat.com
---

 b/kernel/Makefile        |    1 
 b/kernel/check-configs.c |  128 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 129 insertions(+)

diff -puN kernel/Makefile~taint-performance kernel/Makefile
--- a/kernel/Makefile~taint-performance	2014-08-22 09:29:43.009121391 -0700
+++ b/kernel/Makefile	2014-08-22 09:29:43.014121620 -0700
@@ -96,6 +96,7 @@ obj-$(CONFIG_CRASH_DUMP) += crash_dump.o
 obj-$(CONFIG_JUMP_LABEL) += jump_label.o
 obj-$(CONFIG_CONTEXT_TRACKING) += context_tracking.o
 obj-$(CONFIG_TORTURE_TEST) += torture.o
+obj-$(CONFIG_DEBUG_KERNEL) += check-configs.o
 
 $(obj)/configs.o: $(obj)/config_data.h
 
diff -puN /dev/null kernel/check-configs.c
--- /dev/null	2014-04-10 11:28:14.066815724 -0700
+++ b/kernel/check-configs.c	2014-08-22 11:20:14.679463265 -0700
@@ -0,0 +1,128 @@
+#include <linux/bug.h>
+#include <linux/debugfs.h>
+#include <linux/gfp.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+
+/*
+ * This should list any kernel options that can substantially
+ * affect performance.  This is intended to give a loud
+ * warning during bootup so that folks have a fighting chance
+ * of noticing these things.
+ *
+ * This is fairly subjective, but a good rule of thumb for these
+ * is: if it is enabled widely in production, then it does not
+ * belong here.  If a major enterprise kernel enables a feature
+ * for a non-debug kernel, it _really_ does not belong.
+ */
+static const char * const performance_killing_configs[] = {
+#ifdef CONFIG_PROVE_LOCKING
+	"PROVE_LOCKING",
+#endif
+#ifdef CONFIG_LOCK_STAT
+	"LOCK_STAT",
+#endif
+#ifdef CONFIG_LOCKDEP
+	"LOCKDEP",
+#endif
+#ifdef CONFIG_DEBUG_VM
+	"DEBUG_VM",
+#endif
+#ifdef CONFIG_DEBUG_VM_VMACACHE
+	"DEBUG_VM_VMACACHE",
+#endif
+#ifdef CONFIG_DEBUG_VM_RB
+	"DEBUG_VM_RB",
+#endif
+#ifdef CONFIG_DEBUG_SLAB
+	"DEBUG_SLAB",
+#endif
+#ifdef CONFIG_SLUB_DEBUG_ON
+	"SLUB_DEBUG_ON",
+#endif
+#ifdef CONFIG_DEBUG_KMEMLEAK
+	"DEBUG_KMEMLEAK",
+#endif
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	"DEBUG_PAGEALLOC",
+#endif
+#ifdef CONFIG_KMEMCHECK
+	"DEBUG_KMEMCHECK",
+#endif
+#ifdef CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT
+	"DEBUG_OBJECTS_ENABLE_DEFAULT",
+#endif
+#ifdef CONFIG_GCOV_KERNEL
+	"GCOV_KERNEL",
+#endif
+};
+
+static const char config_prefix[] = "CONFIG_";
+static const char config_postfix[] = "=y\n";
+/*
+ * Dump out the list of the offending config options to a file
+ * in debugfs so that tooling can look for and capture it.
+ */
+static ssize_t performance_check_read(struct file *file, char __user *user_buf,
+			size_t count, loff_t *ppos)
+{
+	int i;
+	int ret;
+	char *buf;
+	size_t buf_written = 0;
+	size_t buf_left;
+	size_t buf_len;
+	int nr_configs = ARRAY_SIZE(performance_killing_configs);
+
+	if (!nr_configs)
+		return 0;
+
+	buf_len = 1;
+	for (i = 0; i < nr_configs; i++)
+		buf_len += strlen(config_prefix) +
+			   strlen(performance_killing_configs[i]);
+	/* Add space for the end of the line for each entry */
+	buf_len += nr_configs * strlen(config_postfix);
+
+	buf = kmalloc(buf_len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	buf_left = buf_len;
+	for (i = 0; i < nr_configs; i++) {
+		buf_written += snprintf(buf + buf_written, buf_left,
+					"%s%s%s", config_prefix,
+					performance_killing_configs[i],
+					config_postfix);
+		buf_left = buf_len - buf_written;
+		if (buf_left <= 0)
+			break;
+	}
+	ret = simple_read_from_buffer(user_buf, buf_written, ppos, buf, buf_len);
+	kfree(buf);
+	return ret;
+}
+
+static const struct file_operations fops_performance_check = {
+	.read = performance_check_read,
+	.llseek = default_llseek,
+};
+
+static int __init check_configs(void)
+{
+	int i;
+
+	if (!ARRAY_SIZE(performance_killing_configs))
+		return 0;
+
+	pr_info("INFO: Be careful when using this kernel for performance measurement.\n");
+	pr_info("INFO: Potentially performance-altering options present:\n");
+	for (i = 0; i < ARRAY_SIZE(performance_killing_configs); i++) {
+		pr_warn("\t%s%s%s", config_prefix,
+				performance_killing_configs[i], config_postfix);
+	}
+	debugfs_create_file("config_debug", S_IRUSR | S_IWUSR,
+				NULL, NULL, &fops_performance_check);
+	return 0;
+}
+late_initcall(check_configs);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
