Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id ECBC86B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 16:24:30 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so15118285pad.25
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 13:24:30 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id gm1si37838753pbd.183.2014.08.21.13.24.26
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 13:24:26 -0700 (PDT)
Subject: [PATCH] [v3] warn on performance-impacting configs aka. TAINT_PERFORMANCE
From: Dave Hansen <dave@sr71.net>
Date: Thu, 21 Aug 2014 13:24:24 -0700
Message-Id: <20140821202424.7ED66A50@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, peterz@infradead.org, mingo@redhat.com, ak@linux.intel.com, tim.c.chen@linux.intel.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, linux-mm@kvack.org, kirill@shutemov.name, lauraa@codeaurora.org


From: Dave Hansen <dave.hansen@linux.intel.com>

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
and assumed they were real-world when really I was measuing the
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

	lib/perf-configs.o:     file format elf64-x86-64

	Disassembly of section .init.text:

	0000000000000000 <performance_taint>:
	   0:   55                      push   %rbp
	   1:   31 c0                   xor    %eax,%eax
	   3:   48 89 e5                mov    %rsp,%rbp
	   6:   5d                      pop    %rbp
	   7:   c3                      retq

This could be done with Kconfig and an #ifdef to save us 8 bytes
of text and the entry in the late_initcall() section.  Doing it
this way lets us keep the list of these things in one spot, and
also gives us a convenient way to dump out the name of the
offending option.

For anybody that *really* cares, I put the whole thing under
CONFIG_DEBUG_KERNEL in the Makefile.

The messages look like this:

[    3.865297] WARNING: Do not use this kernel for performance measurement.
[    3.868776] WARNING: Potentially performance-altering options:
[    3.871558] 	CONFIG_LOCKDEP enabled
[    3.873326] 	CONFIG_SLUB_DEBUG_ON enabled

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
---

 b/include/linux/kernel.h |    1 
 b/kernel/panic.c         |    1 
 b/lib/Makefile           |    1 
 b/lib/perf-configs.c     |  114 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 117 insertions(+)

diff -puN include/linux/kernel.h~taint-performance include/linux/kernel.h
--- a/include/linux/kernel.h~taint-performance	2014-08-19 11:38:07.424005355 -0700
+++ b/include/linux/kernel.h	2014-08-19 11:38:20.960615904 -0700
@@ -471,6 +471,7 @@ extern enum system_states {
 #define TAINT_OOT_MODULE		12
 #define TAINT_UNSIGNED_MODULE		13
 #define TAINT_SOFTLOCKUP		14
+#define TAINT_PERFORMANCE		15
 
 extern const char hex_asc[];
 #define hex_asc_lo(x)	hex_asc[((x) & 0x0f)]
diff -puN kernel/panic.c~taint-performance kernel/panic.c
--- a/kernel/panic.c~taint-performance	2014-08-19 11:38:28.928975233 -0700
+++ b/kernel/panic.c	2014-08-20 09:56:29.528471033 -0700
@@ -225,6 +225,7 @@ static const struct tnt tnts[] = {
 	{ TAINT_OOT_MODULE,		'O', ' ' },
 	{ TAINT_UNSIGNED_MODULE,	'E', ' ' },
 	{ TAINT_SOFTLOCKUP,		'L', ' ' },
+	{ TAINT_PERFORMANCE,		'Q', ' ' },
 };
 
 /**
diff -puN /dev/null lib/perf-configs.c
--- /dev/null	2014-04-10 11:28:14.066815724 -0700
+++ b/lib/perf-configs.c	2014-08-21 13:22:25.586598278 -0700
@@ -0,0 +1,114 @@
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
+static const char * const perfomance_killing_configs[] = {
+#ifdef CONFIG_LOCKDEP
+	"LOCKDEP",
+#endif
+#ifdef CONFIG_LOCK_STAT
+	"LOCK_STAT",
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
+#ifdef CONFIG_DEBUG_OBJECTS_FREE
+	"DEBUG_OBJECTS_FREE",
+#endif
+#ifdef CONFIG_DEBUG_KMEMLEAK
+	"DEBUG_KMEMLEAK",
+#endif
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	"DEBUG_PAGEALLOC",
+#endif
+};
+
+static const char config_prefix[] = "CONFIG_";
+/*
+ * Dump out the list of the offending config options to a file
+ * in debugfs so that tooling can look for and capture it.
+ */
+static ssize_t performance_taint_read(struct file *file, char __user *user_buf,
+			size_t count, loff_t *ppos)
+{
+	int i;
+	int ret;
+	char *buf;
+	size_t buf_written = 0;
+	size_t buf_left;
+	size_t buf_len;
+
+	if (!ARRAY_SIZE(perfomance_killing_configs))
+		return 0;
+
+	buf_len = 1;
+	for (i = 0; i < ARRAY_SIZE(perfomance_killing_configs); i++)
+		buf_len += strlen(config_prefix) +
+			   strlen(perfomance_killing_configs[i]);
+	/* Add a byte for for each entry in the array for a \n */
+	buf_len += ARRAY_SIZE(perfomance_killing_configs);
+
+	buf = kmalloc(buf_len, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	buf_left = buf_len;
+	for (i = 0; i < ARRAY_SIZE(perfomance_killing_configs); i++) {
+		buf_written += snprintf(buf + buf_written, buf_left,
+					"%s%s\n", config_prefix,
+					perfomance_killing_configs[i]);
+		buf_left = buf_len - buf_written;
+	}
+	ret = simple_read_from_buffer(user_buf, buf_written, ppos, buf, buf_len);
+	kfree(buf);
+	return ret;
+}
+
+static const struct file_operations fops_perf_taint = {
+	.read = performance_taint_read,
+	.llseek = default_llseek,
+};
+
+static int __init performance_taint(void)
+{
+	int i;
+
+	if (!ARRAY_SIZE(perfomance_killing_configs))
+		return 0;
+
+	pr_warn("WARNING: Do not use this kernel for performance measurement.\n");
+	pr_warn("WARNING: Potentially performance-altering options:\n");
+	for (i = 0; i < ARRAY_SIZE(perfomance_killing_configs); i++) {
+		pr_warn("\t%s%s enabled\n", config_prefix,
+					   perfomance_killing_configs[i]);
+	}
+	debugfs_create_file("config_debug", S_IRUSR | S_IWUSR,
+				NULL, NULL, &fops_perf_taint);
+	return 0;
+}
+late_initcall(performance_taint);
diff -puN lib/Makefile~taint-performance lib/Makefile
--- a/lib/Makefile~taint-performance	2014-08-20 11:02:54.130548350 -0700
+++ b/lib/Makefile	2014-08-20 11:06:18.231744868 -0700
@@ -54,6 +54,7 @@ obj-$(CONFIG_GENERIC_HWEIGHT) += hweight
 obj-$(CONFIG_BTREE) += btree.o
 obj-$(CONFIG_INTERVAL_TREE) += interval_tree.o
 obj-$(CONFIG_ASSOCIATIVE_ARRAY) += assoc_array.o
+obj-$(CONFIG_DEBUG_KERNEL) += perf-configs.o
 obj-$(CONFIG_DEBUG_PREEMPT) += smp_processor_id.o
 obj-$(CONFIG_DEBUG_LIST) += list_debug.o
 obj-$(CONFIG_DEBUG_OBJECTS) += debugobjects.o
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
