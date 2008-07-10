Date: Thu, 10 Jul 2008 21:05:57 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [RFC PATCH 1/5] kmemtrace: Core implementation.
Message-ID: <20080710210557.5777979c@linux360.ro>
In-Reply-To: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
References: <1215712946-23572-1-git-send-email-eduard.munteanu@linux360.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kmemtrace provides tracing for slab allocator functions, such as kmalloc,
kfree, kmem_cache_alloc, kmem_cache_free etc.. Collected data is then fed
to the userspace application in order to analyse allocation hotspots,
internal fragmentation and so on, making it possible to see how well an
allocator performs, as well as debug and profile kernel code.

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 MAINTAINERS               |    6 ++
 include/linux/kmemtrace.h |  110 +++++++++++++++++++++++
 init/main.c               |    2 +
 lib/Kconfig.debug         |    4 +
 mm/Makefile               |    2 +-
 mm/kmemtrace.c            |  213 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 336 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/kmemtrace.h
 create mode 100644 mm/kmemtrace.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 6476125..87a743a 100644
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
index 0000000..11cd8e2
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
+enum kmemtrace_kind_id {
+	KMEMTRACE_KIND_KERNEL = 0,	/* kmalloc() / kfree(). */
+	KMEMTRACE_KIND_CACHE,		/* kmem_cache_*(). */
+	KMEMTRACE_KIND_PAGES,		/* __get_free_pages() and friends. */
+};
+
+struct kmemtrace_event {
+	__u16		event_id;	/* Allocate or free? */
+	__u16		kind_id;	/* Kind of allocation/free. */
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
+static inline void kmemtrace_mark_alloc_node(enum kmemtrace_kind_id kind_id,
+					     unsigned long call_site,
+					     const void *ptr,
+					     size_t bytes_req,
+					     size_t bytes_alloc,
+					     unsigned long gfp_flags,
+					     int node)
+{
+	trace_mark(kmemtrace_alloc, "kind_id %d call_site %lu ptr %lu "
+		   "bytes_req %lu bytes_alloc %lu gfp_flags %lu node %d",
+		   kind_id, call_site, (unsigned long) ptr,
+		   bytes_req, bytes_alloc, gfp_flags, node);
+}
+
+static inline void kmemtrace_mark_free(enum kmemtrace_kind_id kind_id,
+				       unsigned long call_site,
+				       const void *ptr)
+{
+	trace_mark(kmemtrace_free, "kind_id %d call_site %lu ptr %lu",
+		   kind_id, call_site, (unsigned long) ptr);
+}
+
+#else /* CONFIG_KMEMTRACE */
+
+static inline void kmemtrace_init(void)
+{
+}
+
+static inline void kmemtrace_mark_alloc_node(enum kmemtrace_kind_id kind_id,
+					     unsigned long call_site,
+					     const void *ptr,
+					     size_t bytes_req,
+					     size_t bytes_alloc,
+					     unsigned long gfp_flags,
+					     int node)
+{
+}
+
+static inline void kmemtrace_mark_free(enum kmemtrace_kind_id kind_id,
+				       unsigned long call_site,
+				       const void *ptr)
+{
+}
+
+#endif /* CONFIG_KMEMTRACE */
+
+static inline void kmemtrace_mark_alloc(enum kmemtrace_kind_id kind_id,
+					unsigned long call_site,
+					const void *ptr,
+					size_t bytes_req,
+					size_t bytes_alloc,
+					unsigned long gfp_flags)
+{
+	kmemtrace_mark_alloc_node(kind_id, call_site, ptr,
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
index 0000000..13d37b3
--- /dev/null
+++ b/mm/kmemtrace.c
@@ -0,0 +1,213 @@
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
+#define KMEMTRACE_SUBBUF_SIZE	8192 * sizeof(struct kmemtrace_event)
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
+	ev.kind_id = va_arg(*args, int);
+	ev.call_site = va_arg(*args, unsigned long);
+	ev.ptr = va_arg(*args, unsigned long);
+	/* Don't trace ignored allocations. */
+	if (!ev.ptr)
+		return;
+	ev.bytes_req = va_arg(*args, unsigned long);
+	ev.bytes_alloc = va_arg(*args, unsigned long);
+	/* ev.timestamp set below, to preserve event ordering. */
+	ev.gfp_flags = va_arg(*args, unsigned long);
+	/* Don't trace ignored allocations. */
+	if (ev.gfp_flags & __GFP_NOTRACE)
+		return;
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
+	ev.kind_id = va_arg(*args, int);
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
+
+late_initcall(kmemtrace_setup_late);
+
+static int __init kmemtrace_set_subbuf_size(char *str)
+{
+	get_option(&str, &kmemtrace_n_subbufs);
+	return 0;
+}
+
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
+	err = marker_probe_register("kmemtrace_alloc", "kind_id %d "
+				    "call_site %lu ptr %lu "
+				    "bytes_req %lu bytes_alloc %lu "
+				    "gfp_flags %lu node %d",
+				    kmemtrace_probe_alloc, NULL);
+	if (err)
+		goto probe_alloc_fail;
+	err = marker_probe_register("kmemtrace_free", "kind_id %d "
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
