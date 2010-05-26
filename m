Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9AFE76B01B2
	for <linux-mm@kvack.org>; Wed, 26 May 2010 05:19:58 -0400 (EDT)
Message-ID: <4BFCE849.7090804@cn.fujitsu.com>
Date: Wed, 26 May 2010 17:22:17 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] tracing: Remove kmemtrace ftrace plugin
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We have been resisting new ftrace plugins and removing existing
ones, and kmemtrace has been superseded by kmem trace events
and perf-kmem, so we remove it.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 Documentation/ABI/testing/debugfs-kmemtrace |   71 ----
 Documentation/trace/kmemtrace.txt           |  126 -------
 MAINTAINERS                                 |    7 -
 include/linux/kmemtrace.h                   |   25 --
 include/linux/slab_def.h                    |    3 +-
 include/linux/slub_def.h                    |    3 +-
 init/main.c                                 |    2 -
 kernel/trace/Kconfig                        |   20 -
 kernel/trace/kmemtrace.c                    |  529 ---------------------------
 kernel/trace/trace.h                        |   13 -
 kernel/trace/trace_entries.h                |   35 --
 mm/slab.c                                   |    1 -
 mm/slub.c                                   |    1 -
 13 files changed, 4 insertions(+), 832 deletions(-)
 delete mode 100644 Documentation/ABI/testing/debugfs-kmemtrace
 delete mode 100644 Documentation/trace/kmemtrace.txt
 delete mode 100644 include/linux/kmemtrace.h
 delete mode 100644 kernel/trace/kmemtrace.c

diff --git a/Documentation/ABI/testing/debugfs-kmemtrace b/Documentation/ABI/testing/debugfs-kmemtrace
deleted file mode 100644
index 5e6a92a..0000000
--- a/Documentation/ABI/testing/debugfs-kmemtrace
+++ /dev/null
@@ -1,71 +0,0 @@
-What:		/sys/kernel/debug/kmemtrace/
-Date:		July 2008
-Contact:	Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
-Description:
-
-In kmemtrace-enabled kernels, the following files are created:
-
-/sys/kernel/debug/kmemtrace/
-	cpu<n>		(0400)	Per-CPU tracing data, see below. (binary)
-	total_overruns	(0400)	Total number of bytes which were dropped from
-				cpu<n> files because of full buffer condition,
-				non-binary. (text)
-	abi_version	(0400)	Kernel's kmemtrace ABI version. (text)
-
-Each per-CPU file should be read according to the relay interface. That is,
-the reader should set affinity to that specific CPU and, as currently done by
-the userspace application (though there are other methods), use poll() with
-an infinite timeout before every read(). Otherwise, erroneous data may be
-read. The binary data has the following _core_ format:
-
-	Event ID	(1 byte)	Unsigned integer, one of:
-		0 - represents an allocation (KMEMTRACE_EVENT_ALLOC)
-		1 - represents a freeing of previously allocated memory
-		    (KMEMTRACE_EVENT_FREE)
-	Type ID		(1 byte)	Unsigned integer, one of:
-		0 - this is a kmalloc() / kfree()
-		1 - this is a kmem_cache_alloc() / kmem_cache_free()
-		2 - this is a __get_free_pages() et al.
-	Event size	(2 bytes)	Unsigned integer representing the
-					size of this event. Used to extend
-					kmemtrace. Discard the bytes you
-					don't know about.
-	Sequence number	(4 bytes)	Signed integer used to reorder data
-					logged on SMP machines. Wraparound
-					must be taken into account, although
-					it is unlikely.
-	Caller address	(8 bytes)	Return address to the caller.
-	Pointer to mem	(8 bytes)	Pointer to target memory area. Can be
-					NULL, but not all such calls might be
-					recorded.
-
-In case of KMEMTRACE_EVENT_ALLOC events, the next fields follow:
-
-	Requested bytes	(8 bytes)	Total number of requested bytes,
-					unsigned, must not be zero.
-	Allocated bytes (8 bytes)	Total number of actually allocated
-					bytes, unsigned, must not be lower
-					than requested bytes.
-	Requested flags	(4 bytes)	GFP flags supplied by the caller.
-	Target CPU	(4 bytes)	Signed integer, valid for event id 1.
-					If equal to -1, target CPU is the same
-					as origin CPU, but the reverse might
-					not be true.
-
-The data is made available in the same endianness the machine has.
-
-Other event ids and type ids may be defined and added. Other fields may be
-added by increasing event size, but see below for details.
-Every modification to the ABI, including new id definitions, are followed
-by bumping the ABI version by one.
-
-Adding new data to the packet (features) is done at the end of the mandatory
-data:
-	Feature size	(2 byte)
-	Feature ID	(1 byte)
-	Feature data	(Feature size - 3 bytes)
-
-
-Users:
-	kmemtrace-user - git://repo.or.cz/kmemtrace-user.git
-
diff --git a/Documentation/trace/kmemtrace.txt b/Documentation/trace/kmemtrace.txt
deleted file mode 100644
index 6308735..0000000
--- a/Documentation/trace/kmemtrace.txt
+++ /dev/null
@@ -1,126 +0,0 @@
-			kmemtrace - Kernel Memory Tracer
-
-			  by Eduard - Gabriel Munteanu
-			     <eduard.munteanu@linux360.ro>
-
-I. Introduction
-===============
-
-kmemtrace helps kernel developers figure out two things:
-1) how different allocators (SLAB, SLUB etc.) perform
-2) how kernel code allocates memory and how much
-
-To do this, we trace every allocation and export information to the userspace
-through the relay interface. We export things such as the number of requested
-bytes, the number of bytes actually allocated (i.e. including internal
-fragmentation), whether this is a slab allocation or a plain kmalloc() and so
-on.
-
-The actual analysis is performed by a userspace tool (see section III for
-details on where to get it from). It logs the data exported by the kernel,
-processes it and (as of writing this) can provide the following information:
-- the total amount of memory allocated and fragmentation per call-site
-- the amount of memory allocated and fragmentation per allocation
-- total memory allocated and fragmentation in the collected dataset
-- number of cross-CPU allocation and frees (makes sense in NUMA environments)
-
-Moreover, it can potentially find inconsistent and erroneous behavior in
-kernel code, such as using slab free functions on kmalloc'ed memory or
-allocating less memory than requested (but not truly failed allocations).
-
-kmemtrace also makes provisions for tracing on some arch and analysing the
-data on another.
-
-II. Design and goals
-====================
-
-kmemtrace was designed to handle rather large amounts of data. Thus, it uses
-the relay interface to export whatever is logged to userspace, which then
-stores it. Analysis and reporting is done asynchronously, that is, after the
-data is collected and stored. By design, it allows one to log and analyse
-on different machines and different arches.
-
-As of writing this, the ABI is not considered stable, though it might not
-change much. However, no guarantees are made about compatibility yet. When
-deemed stable, the ABI should still allow easy extension while maintaining
-backward compatibility. This is described further in Documentation/ABI.
-
-Summary of design goals:
-	- allow logging and analysis to be done across different machines
-	- be fast and anticipate usage in high-load environments (*)
-	- be reasonably extensible
-	- make it possible for GNU/Linux distributions to have kmemtrace
-	included in their repositories
-
-(*) - one of the reasons Pekka Enberg's original userspace data analysis
-    tool's code was rewritten from Perl to C (although this is more than a
-    simple conversion)
-
-
-III. Quick usage guide
-======================
-
-1) Get a kernel that supports kmemtrace and build it accordingly (i.e. enable
-CONFIG_KMEMTRACE).
-
-2) Get the userspace tool and build it:
-$ git clone git://repo.or.cz/kmemtrace-user.git		# current repository
-$ cd kmemtrace-user/
-$ ./autogen.sh
-$ ./configure
-$ make
-
-3) Boot the kmemtrace-enabled kernel if you haven't, preferably in the
-'single' runlevel (so that relay buffers don't fill up easily), and run
-kmemtrace:
-# '$' does not mean user, but root here.
-$ mount -t debugfs none /sys/kernel/debug
-$ mount -t proc none /proc
-$ cd path/to/kmemtrace-user/
-$ ./kmemtraced
-Wait a bit, then stop it with CTRL+C.
-$ cat /sys/kernel/debug/kmemtrace/total_overruns	# Check if we didn't
-							# overrun, should
-							# be zero.
-$ (Optionally) [Run kmemtrace_check separately on each cpu[0-9]*.out file to
-		check its correctness]
-$ ./kmemtrace-report
-
-Now you should have a nice and short summary of how the allocator performs.
-
-IV. FAQ and known issues
-========================
-
-Q: 'cat /sys/kernel/debug/kmemtrace/total_overruns' is non-zero, how do I fix
-this? Should I worry?
-A: If it's non-zero, this affects kmemtrace's accuracy, depending on how
-large the number is. You can fix it by supplying a higher
-'kmemtrace.subbufs=N' kernel parameter.
----
-
-Q: kmemtrace_check reports errors, how do I fix this? Should I worry?
-A: This is a bug and should be reported. It can occur for a variety of
-reasons:
-	- possible bugs in relay code
-	- possible misuse of relay by kmemtrace
-	- timestamps being collected unorderly
-Or you may fix it yourself and send us a patch.
----
-
-Q: kmemtrace_report shows many errors, how do I fix this? Should I worry?
-A: This is a known issue and I'm working on it. These might be true errors
-in kernel code, which may have inconsistent behavior (e.g. allocating memory
-with kmem_cache_alloc() and freeing it with kfree()). Pekka Enberg pointed
-out this behavior may work with SLAB, but may fail with other allocators.
-
-It may also be due to lack of tracing in some unusual allocator functions.
-
-We don't want bug reports regarding this issue yet.
----
-
-V. See also
-===========
-
-Documentation/kernel-parameters.txt
-Documentation/ABI/testing/debugfs-kmemtrace
-
diff --git a/MAINTAINERS b/MAINTAINERS
index a8fe9b4..5be9ccf 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3349,13 +3349,6 @@ F:	include/linux/kmemleak.h
 F:	mm/kmemleak.c
 F:	mm/kmemleak-test.c
 
-KMEMTRACE
-M:	Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
-S:	Maintained
-F:	Documentation/trace/kmemtrace.txt
-F:	include/linux/kmemtrace.h
-F:	kernel/trace/kmemtrace.c
-
 KPROBES
 M:	Ananth N Mavinakayanahalli <ananth@in.ibm.com>
 M:	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>
diff --git a/include/linux/kmemtrace.h b/include/linux/kmemtrace.h
deleted file mode 100644
index b616d39..0000000
--- a/include/linux/kmemtrace.h
+++ /dev/null
@@ -1,25 +0,0 @@
-/*
- * Copyright (C) 2008 Eduard - Gabriel Munteanu
- *
- * This file is released under GPL version 2.
- */
-
-#ifndef _LINUX_KMEMTRACE_H
-#define _LINUX_KMEMTRACE_H
-
-#ifdef __KERNEL__
-
-#include <trace/events/kmem.h>
-
-#ifdef CONFIG_KMEMTRACE
-extern void kmemtrace_init(void);
-#else
-static inline void kmemtrace_init(void)
-{
-}
-#endif
-
-#endif /* __KERNEL__ */
-
-#endif /* _LINUX_KMEMTRACE_H */
-
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 1812dac..1acfa73 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -14,7 +14,8 @@
 #include <asm/page.h>		/* kmalloc_sizes.h needs PAGE_SIZE */
 #include <asm/cache.h>		/* kmalloc_sizes.h needs L1_CACHE_BYTES */
 #include <linux/compiler.h>
-#include <linux/kmemtrace.h>
+
+#include <trace/events/kmem.h>
 
 #ifndef ARCH_KMALLOC_MINALIGN
 /*
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 55695c8..2345d3a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -10,9 +10,10 @@
 #include <linux/gfp.h>
 #include <linux/workqueue.h>
 #include <linux/kobject.h>
-#include <linux/kmemtrace.h>
 #include <linux/kmemleak.h>
 
+#include <trace/events/kmem.h>
+
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
 	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
diff --git a/init/main.c b/init/main.c
index 3bdb152..1ec21e9 100644
--- a/init/main.c
+++ b/init/main.c
@@ -66,7 +66,6 @@
 #include <linux/ftrace.h>
 #include <linux/async.h>
 #include <linux/kmemcheck.h>
-#include <linux/kmemtrace.h>
 #include <linux/sfi.h>
 #include <linux/shmem_fs.h>
 #include <linux/slab.h>
@@ -653,7 +652,6 @@ asmlinkage void __init start_kernel(void)
 #endif
 	page_cgroup_init();
 	enable_debug_pagealloc();
-	kmemtrace_init();
 	kmemleak_init();
 	debug_objects_mem_init();
 	idr_init_cache();
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 8b1797c..ece5cdb 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -371,26 +371,6 @@ config STACK_TRACER
 
 	  Say N if unsure.
 
-config KMEMTRACE
-	bool "Trace SLAB allocations"
-	select GENERIC_TRACER
-	help
-	  kmemtrace provides tracing for slab allocator functions, such as
-	  kmalloc, kfree, kmem_cache_alloc, kmem_cache_free, etc. Collected
-	  data is then fed to the userspace application in order to analyse
-	  allocation hotspots, internal fragmentation and so on, making it
-	  possible to see how well an allocator performs, as well as debug
-	  and profile kernel code.
-
-	  This requires an userspace application to use. See
-	  Documentation/trace/kmemtrace.txt for more information.
-
-	  Saying Y will make the kernel somewhat larger and slower. However,
-	  if you disable kmemtrace at run-time or boot-time, the performance
-	  impact is minimal (depending on the arch the kernel is built for).
-
-	  If unsure, say N.
-
 config WORKQUEUE_TRACER
 	bool "Trace workqueues"
 	select GENERIC_TRACER
diff --git a/kernel/trace/kmemtrace.c b/kernel/trace/kmemtrace.c
deleted file mode 100644
index bbfc1bb..0000000
--- a/kernel/trace/kmemtrace.c
+++ /dev/null
@@ -1,529 +0,0 @@
-/*
- * Memory allocator tracing
- *
- * Copyright (C) 2008 Eduard - Gabriel Munteanu
- * Copyright (C) 2008 Pekka Enberg <penberg@cs.helsinki.fi>
- * Copyright (C) 2008 Frederic Weisbecker <fweisbec@gmail.com>
- */
-
-#include <linux/tracepoint.h>
-#include <linux/seq_file.h>
-#include <linux/debugfs.h>
-#include <linux/dcache.h>
-#include <linux/fs.h>
-
-#include <linux/kmemtrace.h>
-
-#include "trace_output.h"
-#include "trace.h"
-
-/* Select an alternative, minimalistic output than the original one */
-#define TRACE_KMEM_OPT_MINIMAL	0x1
-
-static struct tracer_opt kmem_opts[] = {
-	/* Default disable the minimalistic output */
-	{ TRACER_OPT(kmem_minimalistic, TRACE_KMEM_OPT_MINIMAL) },
-	{ }
-};
-
-static struct tracer_flags kmem_tracer_flags = {
-	.val			= 0,
-	.opts			= kmem_opts
-};
-
-static struct trace_array *kmemtrace_array;
-
-/* Trace allocations */
-static inline void kmemtrace_alloc(enum kmemtrace_type_id type_id,
-				   unsigned long call_site,
-				   const void *ptr,
-				   size_t bytes_req,
-				   size_t bytes_alloc,
-				   gfp_t gfp_flags,
-				   int node)
-{
-	struct ftrace_event_call *call = &event_kmem_alloc;
-	struct trace_array *tr = kmemtrace_array;
-	struct kmemtrace_alloc_entry *entry;
-	struct ring_buffer_event *event;
-
-	event = ring_buffer_lock_reserve(tr->buffer, sizeof(*entry));
-	if (!event)
-		return;
-
-	entry = ring_buffer_event_data(event);
-	tracing_generic_entry_update(&entry->ent, 0, 0);
-
-	entry->ent.type		= TRACE_KMEM_ALLOC;
-	entry->type_id		= type_id;
-	entry->call_site	= call_site;
-	entry->ptr		= ptr;
-	entry->bytes_req	= bytes_req;
-	entry->bytes_alloc	= bytes_alloc;
-	entry->gfp_flags	= gfp_flags;
-	entry->node		= node;
-
-	if (!filter_check_discard(call, entry, tr->buffer, event))
-		ring_buffer_unlock_commit(tr->buffer, event);
-
-	trace_wake_up();
-}
-
-static inline void kmemtrace_free(enum kmemtrace_type_id type_id,
-				  unsigned long call_site,
-				  const void *ptr)
-{
-	struct ftrace_event_call *call = &event_kmem_free;
-	struct trace_array *tr = kmemtrace_array;
-	struct kmemtrace_free_entry *entry;
-	struct ring_buffer_event *event;
-
-	event = ring_buffer_lock_reserve(tr->buffer, sizeof(*entry));
-	if (!event)
-		return;
-	entry	= ring_buffer_event_data(event);
-	tracing_generic_entry_update(&entry->ent, 0, 0);
-
-	entry->ent.type		= TRACE_KMEM_FREE;
-	entry->type_id		= type_id;
-	entry->call_site	= call_site;
-	entry->ptr		= ptr;
-
-	if (!filter_check_discard(call, entry, tr->buffer, event))
-		ring_buffer_unlock_commit(tr->buffer, event);
-
-	trace_wake_up();
-}
-
-static void kmemtrace_kmalloc(void *ignore,
-			      unsigned long call_site,
-			      const void *ptr,
-			      size_t bytes_req,
-			      size_t bytes_alloc,
-			      gfp_t gfp_flags)
-{
-	kmemtrace_alloc(KMEMTRACE_TYPE_KMALLOC, call_site, ptr,
-			bytes_req, bytes_alloc, gfp_flags, -1);
-}
-
-static void kmemtrace_kmem_cache_alloc(void *ignore,
-				       unsigned long call_site,
-				       const void *ptr,
-				       size_t bytes_req,
-				       size_t bytes_alloc,
-				       gfp_t gfp_flags)
-{
-	kmemtrace_alloc(KMEMTRACE_TYPE_CACHE, call_site, ptr,
-			bytes_req, bytes_alloc, gfp_flags, -1);
-}
-
-static void kmemtrace_kmalloc_node(void *ignore,
-				   unsigned long call_site,
-				   const void *ptr,
-				   size_t bytes_req,
-				   size_t bytes_alloc,
-				   gfp_t gfp_flags,
-				   int node)
-{
-	kmemtrace_alloc(KMEMTRACE_TYPE_KMALLOC, call_site, ptr,
-			bytes_req, bytes_alloc, gfp_flags, node);
-}
-
-static void kmemtrace_kmem_cache_alloc_node(void *ignore,
-					    unsigned long call_site,
-					    const void *ptr,
-					    size_t bytes_req,
-					    size_t bytes_alloc,
-					    gfp_t gfp_flags,
-					    int node)
-{
-	kmemtrace_alloc(KMEMTRACE_TYPE_CACHE, call_site, ptr,
-			bytes_req, bytes_alloc, gfp_flags, node);
-}
-
-static void
-kmemtrace_kfree(void *ignore, unsigned long call_site, const void *ptr)
-{
-	kmemtrace_free(KMEMTRACE_TYPE_KMALLOC, call_site, ptr);
-}
-
-static void kmemtrace_kmem_cache_free(void *ignore,
-				      unsigned long call_site, const void *ptr)
-{
-	kmemtrace_free(KMEMTRACE_TYPE_CACHE, call_site, ptr);
-}
-
-static int kmemtrace_start_probes(void)
-{
-	int err;
-
-	err = register_trace_kmalloc(kmemtrace_kmalloc, NULL);
-	if (err)
-		return err;
-	err = register_trace_kmem_cache_alloc(kmemtrace_kmem_cache_alloc, NULL);
-	if (err)
-		return err;
-	err = register_trace_kmalloc_node(kmemtrace_kmalloc_node, NULL);
-	if (err)
-		return err;
-	err = register_trace_kmem_cache_alloc_node(kmemtrace_kmem_cache_alloc_node, NULL);
-	if (err)
-		return err;
-	err = register_trace_kfree(kmemtrace_kfree, NULL);
-	if (err)
-		return err;
-	err = register_trace_kmem_cache_free(kmemtrace_kmem_cache_free, NULL);
-
-	return err;
-}
-
-static void kmemtrace_stop_probes(void)
-{
-	unregister_trace_kmalloc(kmemtrace_kmalloc, NULL);
-	unregister_trace_kmem_cache_alloc(kmemtrace_kmem_cache_alloc, NULL);
-	unregister_trace_kmalloc_node(kmemtrace_kmalloc_node, NULL);
-	unregister_trace_kmem_cache_alloc_node(kmemtrace_kmem_cache_alloc_node, NULL);
-	unregister_trace_kfree(kmemtrace_kfree, NULL);
-	unregister_trace_kmem_cache_free(kmemtrace_kmem_cache_free, NULL);
-}
-
-static int kmem_trace_init(struct trace_array *tr)
-{
-	kmemtrace_array = tr;
-
-	tracing_reset_online_cpus(tr);
-
-	kmemtrace_start_probes();
-
-	return 0;
-}
-
-static void kmem_trace_reset(struct trace_array *tr)
-{
-	kmemtrace_stop_probes();
-}
-
-static void kmemtrace_headers(struct seq_file *s)
-{
-	/* Don't need headers for the original kmemtrace output */
-	if (!(kmem_tracer_flags.val & TRACE_KMEM_OPT_MINIMAL))
-		return;
-
-	seq_printf(s, "#\n");
-	seq_printf(s, "# ALLOC  TYPE  REQ   GIVEN  FLAGS     "
-			"      POINTER         NODE    CALLER\n");
-	seq_printf(s, "# FREE   |      |     |       |       "
-			"       |   |            |        |\n");
-	seq_printf(s, "# |\n\n");
-}
-
-/*
- * The following functions give the original output from kmemtrace,
- * plus the origin CPU, since reordering occurs in-kernel now.
- */
-
-#define KMEMTRACE_USER_ALLOC	0
-#define KMEMTRACE_USER_FREE	1
-
-struct kmemtrace_user_event {
-	u8			event_id;
-	u8			type_id;
-	u16			event_size;
-	u32			cpu;
-	u64			timestamp;
-	unsigned long		call_site;
-	unsigned long		ptr;
-};
-
-struct kmemtrace_user_event_alloc {
-	size_t			bytes_req;
-	size_t			bytes_alloc;
-	unsigned		gfp_flags;
-	int			node;
-};
-
-static enum print_line_t
-kmemtrace_print_alloc(struct trace_iterator *iter, int flags,
-		      struct trace_event *event)
-{
-	struct trace_seq *s = &iter->seq;
-	struct kmemtrace_alloc_entry *entry;
-	int ret;
-
-	trace_assign_type(entry, iter->ent);
-
-	ret = trace_seq_printf(s, "type_id %d call_site %pF ptr %lu "
-	    "bytes_req %lu bytes_alloc %lu gfp_flags %lu node %d\n",
-	    entry->type_id, (void *)entry->call_site, (unsigned long)entry->ptr,
-	    (unsigned long)entry->bytes_req, (unsigned long)entry->bytes_alloc,
-	    (unsigned long)entry->gfp_flags, entry->node);
-
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-	return TRACE_TYPE_HANDLED;
-}
-
-static enum print_line_t
-kmemtrace_print_free(struct trace_iterator *iter, int flags,
-		     struct trace_event *event)
-{
-	struct trace_seq *s = &iter->seq;
-	struct kmemtrace_free_entry *entry;
-	int ret;
-
-	trace_assign_type(entry, iter->ent);
-
-	ret = trace_seq_printf(s, "type_id %d call_site %pF ptr %lu\n",
-			       entry->type_id, (void *)entry->call_site,
-			       (unsigned long)entry->ptr);
-
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-	return TRACE_TYPE_HANDLED;
-}
-
-static enum print_line_t
-kmemtrace_print_alloc_user(struct trace_iterator *iter, int flags,
-			   struct trace_event *event)
-{
-	struct trace_seq *s = &iter->seq;
-	struct kmemtrace_alloc_entry *entry;
-	struct kmemtrace_user_event *ev;
-	struct kmemtrace_user_event_alloc *ev_alloc;
-
-	trace_assign_type(entry, iter->ent);
-
-	ev = trace_seq_reserve(s, sizeof(*ev));
-	if (!ev)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	ev->event_id		= KMEMTRACE_USER_ALLOC;
-	ev->type_id		= entry->type_id;
-	ev->event_size		= sizeof(*ev) + sizeof(*ev_alloc);
-	ev->cpu			= iter->cpu;
-	ev->timestamp		= iter->ts;
-	ev->call_site		= entry->call_site;
-	ev->ptr			= (unsigned long)entry->ptr;
-
-	ev_alloc = trace_seq_reserve(s, sizeof(*ev_alloc));
-	if (!ev_alloc)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	ev_alloc->bytes_req	= entry->bytes_req;
-	ev_alloc->bytes_alloc	= entry->bytes_alloc;
-	ev_alloc->gfp_flags	= entry->gfp_flags;
-	ev_alloc->node		= entry->node;
-
-	return TRACE_TYPE_HANDLED;
-}
-
-static enum print_line_t
-kmemtrace_print_free_user(struct trace_iterator *iter, int flags,
-			  struct trace_event *event)
-{
-	struct trace_seq *s = &iter->seq;
-	struct kmemtrace_free_entry *entry;
-	struct kmemtrace_user_event *ev;
-
-	trace_assign_type(entry, iter->ent);
-
-	ev = trace_seq_reserve(s, sizeof(*ev));
-	if (!ev)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	ev->event_id		= KMEMTRACE_USER_FREE;
-	ev->type_id		= entry->type_id;
-	ev->event_size		= sizeof(*ev);
-	ev->cpu			= iter->cpu;
-	ev->timestamp		= iter->ts;
-	ev->call_site		= entry->call_site;
-	ev->ptr			= (unsigned long)entry->ptr;
-
-	return TRACE_TYPE_HANDLED;
-}
-
-/* The two other following provide a more minimalistic output */
-static enum print_line_t
-kmemtrace_print_alloc_compress(struct trace_iterator *iter)
-{
-	struct kmemtrace_alloc_entry *entry;
-	struct trace_seq *s = &iter->seq;
-	int ret;
-
-	trace_assign_type(entry, iter->ent);
-
-	/* Alloc entry */
-	ret = trace_seq_printf(s, "  +      ");
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Type */
-	switch (entry->type_id) {
-	case KMEMTRACE_TYPE_KMALLOC:
-		ret = trace_seq_printf(s, "K   ");
-		break;
-	case KMEMTRACE_TYPE_CACHE:
-		ret = trace_seq_printf(s, "C   ");
-		break;
-	case KMEMTRACE_TYPE_PAGES:
-		ret = trace_seq_printf(s, "P   ");
-		break;
-	default:
-		ret = trace_seq_printf(s, "?   ");
-	}
-
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Requested */
-	ret = trace_seq_printf(s, "%4zu   ", entry->bytes_req);
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Allocated */
-	ret = trace_seq_printf(s, "%4zu   ", entry->bytes_alloc);
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Flags
-	 * TODO: would be better to see the name of the GFP flag names
-	 */
-	ret = trace_seq_printf(s, "%08x   ", entry->gfp_flags);
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Pointer to allocated */
-	ret = trace_seq_printf(s, "0x%tx   ", (ptrdiff_t)entry->ptr);
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Node and call site*/
-	ret = trace_seq_printf(s, "%4d   %pf\n", entry->node,
-						 (void *)entry->call_site);
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	return TRACE_TYPE_HANDLED;
-}
-
-static enum print_line_t
-kmemtrace_print_free_compress(struct trace_iterator *iter)
-{
-	struct kmemtrace_free_entry *entry;
-	struct trace_seq *s = &iter->seq;
-	int ret;
-
-	trace_assign_type(entry, iter->ent);
-
-	/* Free entry */
-	ret = trace_seq_printf(s, "  -      ");
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Type */
-	switch (entry->type_id) {
-	case KMEMTRACE_TYPE_KMALLOC:
-		ret = trace_seq_printf(s, "K     ");
-		break;
-	case KMEMTRACE_TYPE_CACHE:
-		ret = trace_seq_printf(s, "C     ");
-		break;
-	case KMEMTRACE_TYPE_PAGES:
-		ret = trace_seq_printf(s, "P     ");
-		break;
-	default:
-		ret = trace_seq_printf(s, "?     ");
-	}
-
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Skip requested/allocated/flags */
-	ret = trace_seq_printf(s, "                       ");
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Pointer to allocated */
-	ret = trace_seq_printf(s, "0x%tx   ", (ptrdiff_t)entry->ptr);
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	/* Skip node and print call site*/
-	ret = trace_seq_printf(s, "       %pf\n", (void *)entry->call_site);
-	if (!ret)
-		return TRACE_TYPE_PARTIAL_LINE;
-
-	return TRACE_TYPE_HANDLED;
-}
-
-static enum print_line_t kmemtrace_print_line(struct trace_iterator *iter)
-{
-	struct trace_entry *entry = iter->ent;
-
-	if (!(kmem_tracer_flags.val & TRACE_KMEM_OPT_MINIMAL))
-		return TRACE_TYPE_UNHANDLED;
-
-	switch (entry->type) {
-	case TRACE_KMEM_ALLOC:
-		return kmemtrace_print_alloc_compress(iter);
-	case TRACE_KMEM_FREE:
-		return kmemtrace_print_free_compress(iter);
-	default:
-		return TRACE_TYPE_UNHANDLED;
-	}
-}
-
-static struct trace_event_functions kmem_trace_alloc_funcs = {
-	.trace			= kmemtrace_print_alloc,
-	.binary			= kmemtrace_print_alloc_user,
-};
-
-static struct trace_event kmem_trace_alloc = {
-	.type			= TRACE_KMEM_ALLOC,
-	.funcs			= &kmem_trace_alloc_funcs,
-};
-
-static struct trace_event_functions kmem_trace_free_funcs = {
-	.trace			= kmemtrace_print_free,
-	.binary			= kmemtrace_print_free_user,
-};
-
-static struct trace_event kmem_trace_free = {
-	.type			= TRACE_KMEM_FREE,
-	.funcs			= &kmem_trace_free_funcs,
-};
-
-static struct tracer kmem_tracer __read_mostly = {
-	.name			= "kmemtrace",
-	.init			= kmem_trace_init,
-	.reset			= kmem_trace_reset,
-	.print_line		= kmemtrace_print_line,
-	.print_header		= kmemtrace_headers,
-	.flags			= &kmem_tracer_flags
-};
-
-void kmemtrace_init(void)
-{
-	/* earliest opportunity to start kmem tracing */
-}
-
-static int __init init_kmem_tracer(void)
-{
-	if (!register_ftrace_event(&kmem_trace_alloc)) {
-		pr_warning("Warning: could not register kmem events\n");
-		return 1;
-	}
-
-	if (!register_ftrace_event(&kmem_trace_free)) {
-		pr_warning("Warning: could not register kmem events\n");
-		return 1;
-	}
-
-	if (register_tracer(&kmem_tracer) != 0) {
-		pr_warning("Warning: could not register the kmem tracer\n");
-		return 1;
-	}
-
-	return 0;
-}
-device_initcall(init_kmem_tracer);
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 2cd9639..d402efc 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -10,7 +10,6 @@
 #include <linux/tracepoint.h>
 #include <linux/ftrace.h>
 #include <trace/boot.h>
-#include <linux/kmemtrace.h>
 #include <linux/hw_breakpoint.h>
 
 #include <linux/trace_seq.h>
@@ -34,20 +33,12 @@ enum trace_type {
 	TRACE_GRAPH_RET,
 	TRACE_GRAPH_ENT,
 	TRACE_USER_STACK,
-	TRACE_KMEM_ALLOC,
-	TRACE_KMEM_FREE,
 	TRACE_BLK,
 	TRACE_KSYM,
 
 	__TRACE_LAST_TYPE,
 };
 
-enum kmemtrace_type_id {
-	KMEMTRACE_TYPE_KMALLOC = 0,	/* kmalloc() or kfree(). */
-	KMEMTRACE_TYPE_CACHE,		/* kmem_cache_*(). */
-	KMEMTRACE_TYPE_PAGES,		/* __get_free_pages() and friends. */
-};
-
 extern struct tracer boot_tracer;
 
 #undef __field
@@ -216,10 +207,6 @@ extern void __ftrace_bad_type(void);
 			  TRACE_GRAPH_ENT);		\
 		IF_ASSIGN(var, ent, struct ftrace_graph_ret_entry,	\
 			  TRACE_GRAPH_RET);		\
-		IF_ASSIGN(var, ent, struct kmemtrace_alloc_entry,	\
-			  TRACE_KMEM_ALLOC);	\
-		IF_ASSIGN(var, ent, struct kmemtrace_free_entry,	\
-			  TRACE_KMEM_FREE);	\
 		IF_ASSIGN(var, ent, struct ksym_trace_entry, TRACE_KSYM);\
 		__ftrace_bad_type();					\
 	} while (0)
diff --git a/kernel/trace/trace_entries.h b/kernel/trace/trace_entries.h
index dc008c1..08b3a29 100644
--- a/kernel/trace/trace_entries.h
+++ b/kernel/trace/trace_entries.h
@@ -318,41 +318,6 @@ FTRACE_ENTRY(branch, trace_branch,
 		 __entry->func, __entry->file, __entry->correct)
 );
 
-FTRACE_ENTRY(kmem_alloc, kmemtrace_alloc_entry,
-
-	TRACE_KMEM_ALLOC,
-
-	F_STRUCT(
-		__field(	enum kmemtrace_type_id,	type_id		)
-		__field(	unsigned long,		call_site	)
-		__field(	const void *,		ptr		)
-		__field(	size_t,			bytes_req	)
-		__field(	size_t,			bytes_alloc	)
-		__field(	gfp_t,			gfp_flags	)
-		__field(	int,			node		)
-	),
-
-	F_printk("type:%u call_site:%lx ptr:%p req:%zi alloc:%zi"
-		 " flags:%x node:%d",
-		 __entry->type_id, __entry->call_site, __entry->ptr,
-		 __entry->bytes_req, __entry->bytes_alloc,
-		 __entry->gfp_flags, __entry->node)
-);
-
-FTRACE_ENTRY(kmem_free, kmemtrace_free_entry,
-
-	TRACE_KMEM_FREE,
-
-	F_STRUCT(
-		__field(	enum kmemtrace_type_id,	type_id		)
-		__field(	unsigned long,		call_site	)
-		__field(	const void *,		ptr		)
-	),
-
-	F_printk("type:%u call_site:%lx ptr:%p",
-		 __entry->type_id, __entry->call_site, __entry->ptr)
-);
-
 FTRACE_ENTRY(ksym_trace, ksym_trace_entry,
 
 	TRACE_KSYM,
diff --git a/mm/slab.c b/mm/slab.c
index 02786e1..2dba2d4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -102,7 +102,6 @@
 #include	<linux/cpu.h>
 #include	<linux/sysctl.h>
 #include	<linux/module.h>
-#include	<linux/kmemtrace.h>
 #include	<linux/rcupdate.h>
 #include	<linux/string.h>
 #include	<linux/uaccess.h>
diff --git a/mm/slub.c b/mm/slub.c
index 26f0cb9..a61f1aa 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -17,7 +17,6 @@
 #include <linux/slab.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-#include <linux/kmemtrace.h>
 #include <linux/kmemcheck.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
