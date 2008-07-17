Received: by ag-out-0708.google.com with SMTP id 22so4236995agd.8
        for <linux-mm@kvack.org>; Wed, 16 Jul 2008 17:48:18 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 1/4] kmemtrace: Core implementation.
Date: Thu, 17 Jul 2008 03:46:45 +0300
Message-Id: <4472a3f883b0d9026bb2d8c490233b3eadf9b55e.1216255035.git.eduard.munteanu@linux360.ro>
In-Reply-To: <cover.1216255034.git.eduard.munteanu@linux360.ro>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro>
In-Reply-To: <cover.1216255034.git.eduard.munteanu@linux360.ro>
References: <cover.1216255034.git.eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

kmemtrace provides tracing for slab allocator functions, such as kmalloc,
kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected data is then fed
to the userspace application in order to analyse allocation hotspots,
internal fragmentation and so on, making it possible to see how well an
allocator performs, as well as debug and profile kernel code.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 Documentation/kernel-parameters.txt |    6 +
 Documentation/vm/kmemtrace.txt      |   96 ++++++++++++++++
 MAINTAINERS                         |    6 +
 include/linux/kmemtrace.h           |  110 ++++++++++++++++++
 init/main.c                         |    2 +
 lib/Kconfig.debug                   |    4 +
 mm/Makefile                         |    2 +-
 mm/kmemtrace.c                      |  208 +++++++++++++++++++++++++++++++++++
 8 files changed, 433 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/vm/kmemtrace.txt
 create mode 100644 include/linux/kmemtrace.h
 create mode 100644 mm/kmemtrace.c

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index b52f47d..b230aff 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -49,6 +49,7 @@ parameter is applicable:
 	ISAPNP	ISA PnP code is enabled.
 	ISDN	Appropriate ISDN support is enabled.
 	JOY	Appropriate joystick support is enabled.
+	KMEMTRACE kmemtrace is enabled.
 	LIBATA  Libata driver is enabled
 	LP	Printer support is enabled.
 	LOOP	Loopback device support is enabled.
@@ -941,6 +942,11 @@ and is between 256 and 4096 characters. It is defined in the file
 			use the HighMem zone if it exists, and the Normal
 			zone if it does not.
 
+	kmemtrace.subbufs=n	[KNL,KMEMTRACE] Overrides the number of
+			subbufs kmemtrace's relay channel has. Set this
+			higher than default (KMEMTRACE_N_SUBBUFS in code) if
+			you experience buffer overruns.
+
 	movablecore=nn[KMG]	[KNL,X86-32,IA-64,PPC,X86-64] This parameter
 			is similar to kernelcore except it specifies the
 			amount of memory used for migratable allocations.
diff --git a/Documentation/vm/kmemtrace.txt b/Documentation/vm/kmemtrace.txt
new file mode 100644
index 0000000..1147ecb
--- /dev/null
+++ b/Documentation/vm/kmemtrace.txt
@@ -0,0 +1,96 @@
+			kmemtrace - Kernel Memory Tracer
+
+			  by Eduard - Gabriel Munteanu
+			     <eduard.munteanu@linux360.ro>
+
+
+I. Design and goals
+===================
+
+kmemtrace was designed to handle rather large amounts of data. Thus, it uses
+the relay interface to export whatever is logged to userspace, which then
+stores it. Analysis and reporting is done asynchronously, that is, after the
+data is collected and stored. By design, it allows one to log and analyse
+on different machines and different arches.
+
+As this is a debugging feature, kmemtrace's ABI is not designed to be very
+stable, although this may happen in the future if it's deemed mature and
+sufficient. So the userspace tool does not contain a copy of the kernel
+header. Instead, the ABI allows checking if the logged data matches the
+userspace tool. Well, what I said about ABI stability isn't totally true:
+while I've tried hard to cover all possible (and useful) use cases, I don't
+want it frozen in the current state. I anticipate the ABI will be _quite_
+stable, even across multiple stable kernel versions, but I don't make any
+guarantees regarding this matter.
+
+Summary of design goals:
+	- allow logging and analysis to be done across different machines
+	- be fast and anticipate usage in high-load environments (*)
+	- be reasonably extensible
+	- have a _reasonably_ (not completely) stable ABI
+
+(*) - one of the reasons Pekka Enberg's original userspace data analysis
+    tool's code was rewritten from Perl to C (although this is more than a
+    simple conversion)
+
+
+II. Quick usage guide
+=====================
+
+1) Get a kernel that supports kmemtrace and build it accordingly (i.e. enable
+CONFIG_KMEMTRACE).
+
+2) Get the userspace tool and build it:
+$ git-clone git://repo.or.cz/kmemtrace-user.git		# current repository
+$ cd kmemtrace-user/
+$ autoreconf
+$ ./configure		# Supply KERNEL_SOURCES=/path/to/sources/ if you're
+			# _not_ running this on a kmemtrace-enabled kernel.
+$ make
+
+3) Boot the kmemtrace-enabled kernel if you haven't, preferably in the
+'single' runlevel (so that relay buffers don't fill up easily), and run
+kmemtrace:
+# '$' does not mean user, but root here.
+$ mount -t debugfs none /debug
+$ mount -t proc none /proc
+$ cd path/to/kmemtrace-user/
+$ ./kmemtraced
+Wait a bit, then stop it with CTRL+C.
+$ cat /debug/kmemtrace/total_overruns	# Check if we didn't overrun, should
+					# be zero.
+$ (Optionally) [Run kmemtrace_check separately on each cpu[0-9]*.out file to
+		check its correctness]
+$ ./kmemtrace-report
+
+Now you should have a nice and short summary of how the allocator performs.
+
+III. FAQ and known issues
+=========================
+Q: 'cat /debug/kmemtrace/total_overruns' is non-zero, how do I fix this?
+Should I worry?
+A: If it's non-zero, this affects kmemtrace's accuracy, depending on how
+large the number is. You can fix it by supplying a higher
+'kmemtrace.subbufs=N' kernel parameter.
+---
+
+Q: kmemtrace_check reports errors, how do I fix this? Should I worry?
+A: This is a bug and should be reported. It can occur for a variety of
+reasons:
+	- possible bugs in relay code
+	- possible misuse of relay by kmemtrace
+	- timestamps being collected unorderly
+Or you may fix it yourself and send us a patch.
+---
+
+Q: kmemtrace_report shows many errors, how do I fix this? Should I worry?
+A: This is a known issue and I'm working on it. These might be true errors
+in kernel code, which may have inconsistent behavior (e.g. allocating memory
+with kmem_cache_alloc() and freeing it with kfree()). Pekka Enberg pointed
+out this behavior may work with SLAB, but may fail with other allocators.
+
+It may also be due to lack of tracing in some unusual allocator functions.
+
+We don't want bug reports regarding this issue yet.
+---
+
diff --git a/MAINTAINERS b/MAINTAINERS
index 56a2f67..e967bc2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2425,6 +2425,12 @@ M:	jason.wessel@windriver.com
 L:	kgdb-bugreport@lists.sourceforge.net
 S:	Maintained
 
+KMEMTRACE
+P:	Eduard - Gabriel Munteanu
+M:	eduard.munteanu@linux360.ro
+L:	linux-kernel@vger.kernel.org
+S:	Maintained
+
 KPROBES
 P:	Ananth N Mavinakayanahalli
 M:	ananth@in.ibm.com
diff --git a/include/linux/kmemtrace.h b/include/linux/kmemtrace.h
new file mode 100644
index 0000000..da69d22
--- /dev/null
+++ b/include/linux/kmemtrace.h
@@ -0,0 +1,110 @@
+/*
+ * Copyright (C) 2008 Eduard - Gabriel Munteanu
+ *
+ * This file is released under GPL version 2.
+ */
+
+#ifndef _LINUX_KMEMTRACE_H
+#define _LINUX_KMEMTRACE_H
+
+#include <linux/types.h>
+
+/* ABI definition starts here. */
+
+#define KMEMTRACE_ABI_VERSION		1
+
+enum kmemtrace_event_id {
+	KMEMTRACE_EVENT_NULL = 0,	/* Erroneous event. */
+	KMEMTRACE_EVENT_ALLOC,
+	KMEMTRACE_EVENT_FREE,
+};
+
+enum kmemtrace_type_id {
+	KMEMTRACE_TYPE_KERNEL = 0,	/* kmalloc() / kfree(). */
+	KMEMTRACE_TYPE_CACHE,		/* kmem_cache_*(). */
+	KMEMTRACE_TYPE_PAGES,		/* __get_free_pages() and friends. */
+};
+
+struct kmemtrace_event {
+	__u16		event_id;	/* Allocate or free? */
+	__u16		type_id;	/* Kind of allocation/free. */
+	__s32		node;		/* Target CPU. */
+	__u64		call_site;	/* Caller address. */
+	__u64		ptr;		/* Pointer to allocation. */
+	__u64		bytes_req;	/* Number of bytes requested. */
+	__u64		bytes_alloc;	/* Number of bytes allocated. */
+	__u64		gfp_flags;	/* Requested flags. */
+	__s64		timestamp;	/* When the operation occured in ns. */
+} __attribute__ ((__packed__));
+
+/* End of ABI definition. */
+
+#ifdef __KERNEL__
+
+#include <linux/marker.h>
+
+#ifdef CONFIG_KMEMTRACE
+
+extern void kmemtrace_init(void);
+
+static inline void kmemtrace_mark_alloc_node(enum kmemtrace_type_id type_id,
+					     unsigned long call_site,
+					     const void *ptr,
+					     size_t bytes_req,
+					     size_t bytes_alloc,
+					     unsigned long gfp_flags,
+					     int node)
+{
+	trace_mark(kmemtrace_alloc, "type_id %d call_site %lu ptr %lu "
+		   "bytes_req %lu bytes_alloc %lu gfp_flags %lu node %d",
+		   type_id, call_site, (unsigned long) ptr,
+		   bytes_req, bytes_alloc, gfp_flags, node);
+}
+
+static inline void kmemtrace_mark_free(enum kmemtrace_type_id type_id,
+				       unsigned long call_site,
+				       const void *ptr)
+{
+	trace_mark(kmemtrace_free, "type_id %d call_site %lu ptr %lu",
+		   type_id, call_site, (unsigned long) ptr);
+}
+
+#else /* CONFIG_KMEMTRACE */
+
+static inline void kmemtrace_init(void)
+{
+}
+
+static inline void kmemtrace_mark_alloc_node(enum kmemtrace_type_id type_id,
+					     unsigned long call_site,
+					     const void *ptr,
+					     size_t bytes_req,
+					     size_t bytes_alloc,
+					     unsigned long gfp_flags,
+					     int node)
+{
+}
+
+static inline void kmemtrace_mark_free(enum kmemtrace_type_id type_id,
+				       unsigned long call_site,
+				       const void *ptr)
+{
+}
+
+#endif /* CONFIG_KMEMTRACE */
+
+static inline void kmemtrace_mark_alloc(enum kmemtrace_type_id type_id,
+					unsigned long call_site,
+					const void *ptr,
+					size_t bytes_req,
+					size_t bytes_alloc,
+					unsigned long gfp_flags)
+{
+	kmemtrace_mark_alloc_node(type_id, call_site, ptr,
+				  bytes_req, bytes_alloc, gfp_flags, -1);
+}
+
+#endif /* __KERNEL__ */
+
+#endif /* _LINUX_KMEMTRACE_H */
+
diff --git a/init/main.c b/init/main.c
index 057f364..c00659c 100644
--- a/init/main.c
+++ b/init/main.c
@@ -66,6 +66,7 @@
 #include <asm/setup.h>
 #include <asm/sections.h>
 #include <asm/cacheflush.h>
+#include <linux/kmemtrace.h>
 
 #ifdef CONFIG_X86_LOCAL_APIC
 #include <asm/smp.h>
@@ -641,6 +642,7 @@ asmlinkage void __init start_kernel(void)
 	enable_debug_pagealloc();
 	cpu_hotplug_init();
 	kmem_cache_init();
+	kmemtrace_init();
 	debug_objects_mem_init();
 	idr_init_cache();
 	setup_per_cpu_pageset();
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index d2099f4..6bacab5 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -674,6 +674,10 @@ config FIREWIRE_OHCI_REMOTE_DMA
 
 	  If unsure, say N.
 
+config KMEMTRACE
+	bool "Kernel memory tracer"
+	depends on RELAY && DEBUG_FS && MARKERS
+
 source "samples/Kconfig"
 
 source "lib/Kconfig.kgdb"
diff --git a/mm/Makefile b/mm/Makefile
index 18c143b..d88a3bc 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -33,4 +33,4 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o
-
+obj-$(CONFIG_KMEMTRACE) += kmemtrace.o
diff --git a/mm/kmemtrace.c b/mm/kmemtrace.c
new file mode 100644
index 0000000..9258010
--- /dev/null
+++ b/mm/kmemtrace.c
@@ -0,0 +1,208 @@
+/*
+ * Copyright (C) 2008 Pekka Enberg, Eduard - Gabriel Munteanu
+ *
+ * This file is released under GPL version 2.
+ */
+
+#include <linux/string.h>
+#include <linux/debugfs.h>
+#include <linux/relay.h>
+#include <linux/module.h>
+#include <linux/marker.h>
+#include <linux/gfp.h>
+#include <linux/kmemtrace.h>
+
+#define KMEMTRACE_SUBBUF_SIZE	(8192 * sizeof(struct kmemtrace_event))
+#define KMEMTRACE_N_SUBBUFS	20
+
+static struct rchan *kmemtrace_chan;
+static u32 kmemtrace_buf_overruns;
+static unsigned int kmemtrace_n_subbufs;
+
+static inline void kmemtrace_log_event(struct kmemtrace_event *event)
+{
+	relay_write(kmemtrace_chan, event, sizeof(struct kmemtrace_event));
+}
+
+static void kmemtrace_probe_alloc(void *probe_data, void *call_data,
+				  const char *format, va_list *args)
+{
+	unsigned long flags;
+	struct kmemtrace_event ev;
+
+	/*
+	 * Don't convert this to use structure initializers,
+	 * C99 does not guarantee the rvalues evaluation order.
+	 */
+	ev.event_id = KMEMTRACE_EVENT_ALLOC;
+	ev.type_id = va_arg(*args, int);
+	ev.call_site = va_arg(*args, unsigned long);
+	ev.ptr = va_arg(*args, unsigned long);
+	/* Don't trace ignored allocations. */
+	if (!ev.ptr)
+		return;
+	ev.bytes_req = va_arg(*args, unsigned long);
+	ev.bytes_alloc = va_arg(*args, unsigned long);
+	/* ev.timestamp set below, to preserve event ordering. */
+	ev.gfp_flags = va_arg(*args, unsigned long);
+	ev.node = va_arg(*args, int);
+
+	local_irq_save(flags);
+	ev.timestamp = ktime_to_ns(ktime_get());
+	kmemtrace_log_event(&ev);
+	local_irq_restore(flags);
+}
+
+static void kmemtrace_probe_free(void *probe_data, void *call_data,
+				 const char *format, va_list *args)
+{
+	unsigned long flags;
+	struct kmemtrace_event ev;
+
+	/*
+	 * Don't convert this to use structure initializers,
+	 * C99 does not guarantee the rvalues evaluation order.
+	 */
+	ev.event_id = KMEMTRACE_EVENT_FREE;
+	ev.type_id = va_arg(*args, int);
+	ev.call_site = va_arg(*args, unsigned long);
+	ev.ptr = va_arg(*args, unsigned long);
+	/* Don't trace ignored allocations. */
+	if (!ev.ptr)
+		return;
+	/* ev.timestamp set below, to preserve event ordering. */
+
+	local_irq_save(flags);
+	ev.timestamp = ktime_to_ns(ktime_get());
+	kmemtrace_log_event(&ev);
+	local_irq_restore(flags);
+}
+
+static struct dentry *
+kmemtrace_create_buf_file(const char *filename, struct dentry *parent,
+			  int mode, struct rchan_buf *buf, int *is_global)
+{
+	return debugfs_create_file(filename, mode, parent, buf,
+				   &relay_file_operations);
+}
+
+static int kmemtrace_remove_buf_file(struct dentry *dentry)
+{
+	debugfs_remove(dentry);
+
+	return 0;
+}
+
+static int kmemtrace_count_overruns(struct rchan_buf *buf,
+				    void *subbuf, void *prev_subbuf,
+				    size_t prev_padding)
+{
+	if (relay_buf_full(buf)) {
+		kmemtrace_buf_overruns++;
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct rchan_callbacks relay_callbacks = {
+	.create_buf_file = kmemtrace_create_buf_file,
+	.remove_buf_file = kmemtrace_remove_buf_file,
+	.subbuf_start = kmemtrace_count_overruns,
+};
+
+static struct dentry *kmemtrace_dir;
+static struct dentry *kmemtrace_overruns_dentry;
+
+static void kmemtrace_cleanup(void)
+{
+	relay_close(kmemtrace_chan);
+	marker_probe_unregister("kmemtrace_alloc",
+				kmemtrace_probe_alloc, NULL);
+	marker_probe_unregister("kmemtrace_free",
+				kmemtrace_probe_free, NULL);
+	if (kmemtrace_overruns_dentry)
+		debugfs_remove(kmemtrace_overruns_dentry);
+}
+
+static int __init kmemtrace_setup_late(void)
+{
+	if (!kmemtrace_chan)
+		goto failed;
+
+	kmemtrace_dir = debugfs_create_dir("kmemtrace", NULL);
+	if (!kmemtrace_dir)
+		goto cleanup;
+
+	kmemtrace_overruns_dentry =
+		debugfs_create_u32("total_overruns", S_IRUSR,
+				   kmemtrace_dir, &kmemtrace_buf_overruns);
+	if (!kmemtrace_overruns_dentry)
+		goto dir_cleanup;
+
+	if (relay_late_setup_files(kmemtrace_chan, "cpu", kmemtrace_dir))
+		goto overrun_cleanup;
+
+	printk(KERN_INFO "kmemtrace: fully up.\n");
+
+	return 0;
+
+overrun_cleanup:
+	debugfs_remove(kmemtrace_overruns_dentry);
+	kmemtrace_overruns_dentry = NULL;
+dir_cleanup:
+	debugfs_remove(kmemtrace_dir);
+cleanup:
+	kmemtrace_cleanup();
+failed:
+	return 1;
+}
+late_initcall(kmemtrace_setup_late);
+
+static int __init kmemtrace_set_subbuf_size(char *str)
+{
+	get_option(&str, &kmemtrace_n_subbufs);
+	return 0;
+}
+early_param("kmemtrace.subbufs", kmemtrace_set_subbuf_size);
+
+void kmemtrace_init(void)
+{
+	int err;
+
+	if (!kmemtrace_n_subbufs)
+		kmemtrace_n_subbufs = KMEMTRACE_N_SUBBUFS;
+
+	kmemtrace_chan = relay_open(NULL, NULL, KMEMTRACE_SUBBUF_SIZE,
+				    kmemtrace_n_subbufs, &relay_callbacks,
+				    NULL);
+	if (!kmemtrace_chan) {
+		printk(KERN_INFO "kmemtrace: could not open relay channel\n");
+		return;
+	}
+
+	err = marker_probe_register("kmemtrace_alloc", "type_id %d "
+				    "call_site %lu ptr %lu "
+				    "bytes_req %lu bytes_alloc %lu "
+				    "gfp_flags %lu node %d",
+				    kmemtrace_probe_alloc, NULL);
+	if (err)
+		goto probe_alloc_fail;
+	err = marker_probe_register("kmemtrace_free", "type_id %d "
+				    "call_site %lu ptr %lu",
+				    kmemtrace_probe_free, NULL);
+	if (err)
+		goto probe_free_fail;
+
+	printk(KERN_INFO "kmemtrace: early init successful.\n");
+	return;
+
+probe_free_fail:
+	err = marker_probe_unregister("kmemtrace_alloc",
+				      kmemtrace_probe_alloc, NULL);
+	printk(KERN_INFO "kmemtrace: could not register marker probes!\n");
+probe_alloc_fail:
+	relay_close(kmemtrace_chan);
+	kmemtrace_chan = NULL;
+}
+
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
