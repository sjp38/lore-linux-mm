Return-Path: <linux-kernel-owner+w=401wt.eu-S1757348AbYLLAZn@vger.kernel.org>
Date: Fri, 12 Dec 2008 01:25:18 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch] SLQB slab allocator
Message-ID: <20081212002518.GH8294@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


(Re)introducing SLQB allocator. Q for queued, but in reality, SLAB and
SLUB also have queues of things as well, so "Q" is just a meaningless
differentiator :)

I've kept working on SLQB slab allocator because I don't agree with the
design choices in SLUB, and I'm worried about the push to make it the
one true allocator.

My primary goal in SLQB is performance, secondarily are order-0 page
allocations, and memory consumption.

I have worked with the Linux guys at Intel to ensure that SLQB is comparable
to SLAB in their OLTP performance benchmark. Recently that goal has been
reached -- so SLQB performs comparably well to SLAB on that test (it's
within the noise).

I've also been comparing SLQB with SLAB and SLUB in other benchmarks, and
trying to ensure it is as good or better. I don't know if that's always
the case, but nothing obvious has gone wrong (it's sometimes hard to find
meaningful benchmarks that exercise slab in interesting ways).

Now it isn't exactly complete -- debugging, tracking, stats, etc. code is
not always in the best shape, however I have been focusing on performance
of the core allocator. No matter how good the rest is if the core code is
poor... But it boots, works, is pretty stable.

SLQB, like SLUB and unlike SLAB, doesn't have greater than linear memory
consumption growth with the number of CPUs or nodes.

SLQB tries to be very page-size agnostic. And it tries very hard to use
order-0 pages. This is good for both page allocator fragmentation, and
slab fragmentation. I don't like that SLUB performs significantly worse
with order-0 pages in some workloads.

SLQB goes to some lengths to optimise remote-freeing cases (allocate on
one CPU, free on another). It seems to work well, but there are a *lot*
of possible ways this can be implemented especially when NUMA comes into
play, so I'd like to know of workloads where remote freeing happens a
lot, and perhaps look at alternative ways to do it.

SLQB initialistaion code attempts to be as simple and un-clever as possible.
There are no multiple phases where different things come up. There is no
weird self bootstrapping stuff. It just statically allocates the structures
required to create the slabs that allocate other slab structures.

I'm going to continue working on this as I get time, and I plan to soon ask
to have it merged. It would be great if people could comment or test it.

---
 arch/x86/include/asm/page.h |    1
 include/linux/mm.h          |    4
 include/linux/rcu_types.h   |   18
 include/linux/rcupdate.h    |   11
 include/linux/slab.h        |    6
 include/linux/slqb_def.h    |  258 ++++
 include/linux/vmstat.h      |   16
 init/Kconfig                |   10
 lib/Kconfig.debug           |   10
 mm/Makefile                 |    1
 mm/slqb.c                   | 2824 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmstat.c                 |   15
 12 files changed, 3161 insertions(+), 13 deletions(-)

Index: linux-2.6/include/linux/rcupdate.h
===================================================================
--- linux-2.6.orig/include/linux/rcupdate.h
+++ linux-2.6/include/linux/rcupdate.h
@@ -33,6 +33,7 @@
 #ifndef __LINUX_RCUPDATE_H
 #define __LINUX_RCUPDATE_H
 
+#include <linux/rcu_types.h>
 #include <linux/cache.h>
 #include <linux/spinlock.h>
 #include <linux/threads.h>
@@ -42,16 +43,6 @@
 #include <linux/lockdep.h>
 #include <linux/completion.h>
 
-/**
- * struct rcu_head - callback structure for use with RCU
- * @next: next update requests in a list
- * @func: actual update function to call after the grace period.
- */
-struct rcu_head {
-	struct rcu_head *next;
-	void (*func)(struct rcu_head *head);
-};
-
 #ifdef CONFIG_CLASSIC_RCU
 #include <linux/rcuclassic.h>
 #else /* #ifdef CONFIG_CLASSIC_RCU */
Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/slqb_def.h
@@ -0,0 +1,258 @@
+#ifndef _LINUX_SLQB_DEF_H
+#define _LINUX_SLQB_DEF_H
+
+/*
+ * SLQB : A slab allocator with object queues.
+ *
+ * (C) 2008 Nick Piggin <npiggin@suse.de>
+ */
+#include <linux/types.h>
+#include <linux/gfp.h>
+#include <linux/workqueue.h>
+#include <linux/kobject.h>
+#include <linux/rcu_types.h>
+#include <linux/mm_types.h>
+#include <linux/kernel.h>
+
+enum stat_item {
+	ALLOC_LOCAL,
+	ALLOC_OFFNODE,
+	ALLOC_FAILED,
+	ALLOC_NEWPAGE,
+	ALLOC_PROCESS_RFREE,
+	ALLOC_FREEPAGE,
+	FREE_LOCAL,
+	FREE_REMOTE,
+	FREE_FLUSH_RCACHE,
+	FREE_FREEPAGE,
+	NR_SLQB_STAT_ITEMS
+};
+
+struct kmem_cache_list;
+
+struct kmlist {
+	unsigned long nr;
+	void **head, **tail;
+};
+
+struct kmem_cache_remote_free {
+	spinlock_t lock;
+	struct kmlist list;
+} ____cacheline_aligned;
+
+struct kmem_cache_list {
+	struct kmlist freelist;
+#ifdef CONFIG_SMP
+	int remote_free_check;
+#endif
+
+	unsigned long nr_partial;
+	struct list_head partial;
+
+	unsigned long nr_slabs;
+
+	struct kmem_cache *cache;
+	//struct list_head full;
+
+#ifdef CONFIG_SMP
+	struct kmem_cache_remote_free remote_free;
+#endif
+} ____cacheline_aligned;
+
+struct kmem_cache_cpu {
+	struct kmem_cache_list list;
+
+#ifdef CONFIG_SMP
+	struct kmlist rlist;
+	struct kmem_cache_list *remote_cache_list;
+#endif
+
+#ifdef CONFIG_SLQB_STATS
+	unsigned stat[NR_SLQB_STAT_ITEMS];
+#endif
+} ____cacheline_aligned;
+
+struct kmem_cache_node {
+	struct kmem_cache_list list;
+	spinlock_t list_lock;	/* Protect partial list and nr_partial */
+} ____cacheline_aligned;
+
+/*
+ * Management object for a slab cache.
+ */
+struct kmem_cache {
+	/* Used for retriving partial slabs etc */
+	unsigned long flags;
+	int batch;		/* Freeing batch size */
+	int size;		/* The size of an object including meta data */
+	int objsize;		/* The size of an object without meta data */
+	int offset;		/* Free pointer offset. */
+	int order;
+
+	/* Allocation and freeing of slabs */
+	int objects;		/* Number of objects in slab */
+	gfp_t allocflags;	/* gfp flags to use on each alloc */
+	void (*ctor)(void *);
+	int inuse;		/* Offset to metadata */
+	int align;		/* Alignment */
+	const char *name;	/* Name (only for display!) */
+	struct list_head list;	/* List of slab caches */
+
+#ifdef CONFIG_NUMA
+	/*
+	 * Defragmentation by allocating from a remote node.
+	 */
+	int remote_node_defrag_ratio;
+	struct kmem_cache_node *node[MAX_NUMNODES];
+#endif
+#ifdef CONFIG_SMP
+	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
+#else
+	struct kmem_cache_cpu cpu_slab;
+#endif
+};
+
+/*
+ * Kmalloc subsystem.
+ */
+#if defined(ARCH_KMALLOC_MINALIGN) && ARCH_KMALLOC_MINALIGN > 8
+#define KMALLOC_MIN_SIZE ARCH_KMALLOC_MINALIGN
+#else
+#define KMALLOC_MIN_SIZE 8
+#endif
+
+#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)
+#define KMALLOC_SHIFT_SLQB_HIGH (PAGE_SHIFT + 9)
+
+/*
+ * We keep the general caches in an array of slab caches that are used for
+ * 2^x bytes of allocations.
+ */
+extern struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_SLQB_HIGH + 1];
+extern struct kmem_cache kmalloc_caches_dma[KMALLOC_SHIFT_SLQB_HIGH + 1];
+
+/*
+ * Sorry that the following has to be that ugly but some versions of GCC
+ * have trouble with constant propagation and loops.
+ */
+static __always_inline int kmalloc_index(size_t size)
+{
+	if (unlikely(!size))
+		return 0;
+	if (unlikely(size > 1UL << KMALLOC_SHIFT_SLQB_HIGH))
+		return 0;
+
+	if (unlikely(size <= KMALLOC_MIN_SIZE))
+		return KMALLOC_SHIFT_LOW;
+
+#if L1_CACHE_BYTES < 64
+	if (size > 64 && size <= 96)
+		return 1;
+#endif
+#if L1_CACHE_BYTES < 128
+	if (size > 128 && size <= 192)
+		return 2;
+#endif
+	if (size <=          8) return 3;
+	if (size <=         16) return 4;
+	if (size <=         32) return 5;
+	if (size <=         64) return 6;
+	if (size <=        128) return 7;
+	if (size <=        256) return 8;
+	if (size <=        512) return 9;
+	if (size <=       1024) return 10;
+	if (size <=   2 * 1024) return 11;
+	if (size <=   4 * 1024) return 12;
+	if (size <=   8 * 1024) return 13;
+	if (size <=  16 * 1024) return 14;
+	if (size <=  32 * 1024) return 15;
+	if (size <=  64 * 1024) return 16;
+	if (size <= 128 * 1024) return 17;
+	if (size <= 256 * 1024) return 18;
+	if (size <= 512 * 1024) return 19;
+	if (size <= 1024 * 1024) return 20;
+	if (size <=  2 * 1024 * 1024) return 21;
+	return -1;
+
+/*
+ * What we really wanted to do and cannot do because of compiler issues is:
+ *	int i;
+ *	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++)
+ *		if (size <= (1 << i))
+ *			return i;
+ */
+}
+
+#ifdef CONFIG_ZONE_DMA
+#define SLQB_DMA __GFP_DMA
+#else
+/* Disable DMA functionality */
+#define SLQB_DMA (__force gfp_t)0
+#endif
+
+/*
+ * Find the slab cache for a given combination of allocation flags and size.
+ *
+ * This ought to end up with a global pointer to the right cache
+ * in kmalloc_caches.
+ */
+static __always_inline struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
+{
+	int index = kmalloc_index(size);
+
+	if (unlikely(index == 0))
+		return NULL;
+
+	if (likely(!(flags & SLQB_DMA)))
+		return &kmalloc_caches[index];
+	else
+		return &kmalloc_caches_dma[index];
+}
+
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+void *__kmalloc(size_t size, gfp_t flags);
+
+#ifndef ARCH_KMALLOC_MINALIGN
+#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
+#endif
+
+#ifndef ARCH_SLAB_MINALIGN
+#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
+#endif
+
+#define KMALLOC_HEADER (ARCH_KMALLOC_MINALIGN < sizeof(void *) ? sizeof(void *) : ARCH_KMALLOC_MINALIGN)
+
+static __always_inline void *kmalloc(size_t size, gfp_t flags)
+{
+	if (__builtin_constant_p(size)) {
+		struct kmem_cache *s;
+
+		s = kmalloc_slab(size, flags);
+		if (unlikely(ZERO_OR_NULL_PTR(s)))
+			return s;
+
+		return kmem_cache_alloc(s, flags);
+	}
+	return __kmalloc(size, flags);
+}
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t flags, int node);
+void *kmem_cache_alloc_node(struct kmem_cache *, gfp_t flags, int node);
+
+static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	if (__builtin_constant_p(size)) {
+		struct kmem_cache *s;
+
+		s = kmalloc_slab(size, flags);
+		if (unlikely(ZERO_OR_NULL_PTR(s)))
+			return s;
+
+		return kmem_cache_alloc_node(s, flags, node);
+	}
+	return __kmalloc_node(size, flags, node);
+}
+#endif
+
+#endif /* _LINUX_SLQB_DEF_H */
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig
+++ linux-2.6/init/Kconfig
@@ -760,6 +760,11 @@ config SLUB_DEBUG
 	  SLUB sysfs support. /sys/slab will not exist and there will be
 	  no support for cache validation etc.
 
+config SLQB_DEBUG
+	default y
+	bool "Enable SLQB debugging support"
+	depends on SLQB
+
 choice
 	prompt "Choose SLAB allocator"
 	default SLUB
@@ -783,6 +788,9 @@ config SLUB
 	   and has enhanced diagnostics. SLUB is the default choice for
 	   a slab allocator.
 
+config SLQB
+	bool "SLQB (Qeued allocator)"
+
 config SLOB
 	depends on EMBEDDED
 	bool "SLOB (Simple Allocator)"
@@ -823,7 +831,7 @@ config HAVE_GENERIC_DMA_COHERENT
 config SLABINFO
 	bool
 	depends on PROC_FS
-	depends on SLAB || SLUB_DEBUG
+	depends on SLAB || SLUB_DEBUG || SLQB
 	default y
 
 config RT_MUTEXES
Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug
+++ linux-2.6/lib/Kconfig.debug
@@ -290,6 +290,16 @@ config SLUB_STATS
 	  out which slabs are relevant to a particular load.
 	  Try running: slabinfo -DA
 
+config SLQB_DEBUG_ON
+	bool "SLQB debugging on by default"
+	depends on SLQB_DEBUG
+	default n
+
+config SLQB_STATS2
+	default n
+	bool "Enable SLQB performance statistics"
+	depends on SLQB
+
 config DEBUG_PREEMPT
 	bool "Debug preemptible kernel"
 	depends on DEBUG_KERNEL && PREEMPT && (TRACE_IRQFLAGS_SUPPORT || PPC64)
Index: linux-2.6/mm/slqb.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/slqb.c
@@ -0,0 +1,2824 @@
+/*
+ * SLQB: A slab allocator that focuses on per-CPU scaling, and good performance
+ * with order-0 allocations. Fastpaths emphasis is placed on local allocaiton
+ * and freeing, but with a secondary goal of good remote freeing (freeing on
+ * another CPU from that which allocated).
+ *
+ * Using ideas and code from mm/slab.c, mm/slob.c, and mm/slub.c.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/bit_spinlock.h>
+#include <linux/interrupt.h>
+#include <linux/bitops.h>
+#include <linux/slab.h>
+#include <linux/seq_file.h>
+#include <linux/cpu.h>
+#include <linux/cpuset.h>
+#include <linux/mempolicy.h>
+#include <linux/ctype.h>
+#include <linux/kallsyms.h>
+#include <linux/memory.h>
+
+/*
+ * slqb_page overloads struct page, and is used to manage some slob allocation
+ * aspects, however to avoid the horrible mess in include/linux/mm_types.h,
+ * we'll just define our own struct slqb_page type variant here.
+ */
+struct slqb_page {
+	union {
+		struct {
+			unsigned long flags;	/* mandatory */
+			atomic_t _count;	/* mandatory */
+			unsigned int inuse;	/* Nr of objects */
+		   	struct kmem_cache_list *list; /* Pointer to list */
+			void **freelist;	/* freelist req. slab lock */
+			union {
+				struct list_head lru; /* misc. list */
+				struct rcu_head rcu_head; /* for rcu freeing */
+			};
+		};
+		struct page page;
+	};
+};
+static inline void struct_slqb_page_wrong_size(void)
+{ BUILD_BUG_ON(sizeof(struct slqb_page) != sizeof(struct page)); }
+
+static int kmem_size __read_mostly;
+#ifdef CONFIG_NUMA
+static int numa_platform __read_mostly;
+#else
+#define numa_platform 0
+#endif
+
+/*
+ * Lock order:
+ * kmem_cache_node->list_lock
+ *   kmem_cache_remote_free->lock
+ *
+ * Data structures:
+ * SLQB is primarily per-cpu. For each kmem_cache, each CPU has:
+ *
+ * - A LIFO list of node-local objects. Allocation and freeing of node local
+ *   objects goes first to this list.
+ *
+ * - 2 Lists of slab pages, free and partial pages. If an allocation misses
+ *   the object list, it tries from the partial list, then the free list.
+ *   After freeing an object to the object list, if it is over a watermark,
+ *   some objects are freed back to pages. If an allocation misses these lists,
+ *   a new slab page is allocated from the page allocator. If the free list
+ *   reaches a watermark, some of its pages are returned to the page allocator.
+ *
+ * - A remote free queue, where objects freed that did not come from the local
+ *   node are queued to. When this reaches a watermark, the objects are flushed.
+ *
+ * - A remotely freed queue, where objects allocated from this CPU are flushed
+ *   to from other CPUs' remote free queues. kmem_cache_remote_free->lock is
+ *   used to protect access to this queue.
+ *
+ *   When the remotely freed queue reaches a watermark, a flag is set to tell
+ *   the owner CPU to check it. The owner CPU will then check the queue on the
+ *   next allocation that misses the object list. It will move all objects from
+ *   this list onto the object list and then allocate one.
+ *
+ *   This system of remote queueing is intended to reduce lock and remote
+ *   cacheline acquisitions, and give a cooling off period for remotely freed
+ *   objects before they are re-allocated.
+ *
+ * node specific allocations from somewhere other than the local node are handled
+ * by a per-node list which is the same as the above per-CPU data structures
+ * except for the following differences:
+ *
+ * - kmem_cache_node->list_lock is used to protect access for multiple CPUs to
+ *   allocate from a given node.
+ *
+ * - There is no remote free queue. Nodes don't free objects, CPUs do.
+ */
+
+#ifdef CONFIG_SLQB_STATS2
+#define count_slqb_event count_vm_event
+#define count_slqb_events count_vm_events
+#define __count_slqb_event __count_vm_event
+#define __count_slqb_events __count_vm_events
+#else
+#define count_slqb_event(x)
+#define count_slqb_events(x, nr)
+#define __count_slqb_event(x)
+#define __count_slqb_events(x, nr)
+#endif
+
+static inline int slqb_page_to_nid(struct slqb_page *page)
+{
+	return page_to_nid(&page->page);
+}
+
+static inline void *slqb_page_address(struct slqb_page *page)
+{
+	return page_address(&page->page);
+}
+
+static inline struct zone *slqb_page_zone(struct slqb_page *page)
+{
+	return page_zone(&page->page);
+}
+
+static inline int virt_to_nid(const void *addr)
+{
+#ifdef virt_to_page_fast
+	return page_to_nid(virt_to_page_fast(addr));
+#else
+	return page_to_nid(virt_to_page(addr));
+#endif
+}
+
+static inline struct slqb_page *virt_to_head_slqb_page(const void *addr)
+{
+	struct page *p;
+
+	p = virt_to_head_page(addr);
+	return (struct slqb_page *)p;
+}
+
+static inline struct slqb_page *alloc_slqb_pages_node(int nid, gfp_t flags,
+						unsigned int order)
+{
+	struct page *p;
+
+	if (nid == -1)
+		p = alloc_pages(flags, order);
+	else
+		p = alloc_pages_node(nid, flags, order);
+	if (p)
+		__SetPageSlab(p);
+
+	return (struct slqb_page *)p;
+}
+
+static inline void __free_slqb_pages(struct slqb_page *page, unsigned int order)
+{
+	struct page *p = &page->page;
+
+	reset_page_mapcount(p);
+	p->mapping = NULL;
+	VM_BUG_ON(!PageSlab(p));
+	__ClearPageSlab(p);
+
+	__free_pages(p, order);
+}
+
+#ifdef CONFIG_SLQB_DEBUG
+static inline int slab_debug(struct kmem_cache *s)
+{
+	return (s->flags &
+			(SLAB_DEBUG_FREE |
+			 SLAB_RED_ZONE |
+			 SLAB_POISON |
+			 SLAB_STORE_USER |
+			 SLAB_TRACE));
+}
+static inline int slab_poison(struct kmem_cache *s)
+{
+	return s->flags & SLAB_POISON;
+}
+#else
+static inline int slab_debug(struct kmem_cache *s)
+{
+	return 0;
+}
+static inline int slab_poison(struct kmem_cache *s)
+{
+	return 0;
+}
+#endif
+
+/*
+ * Issues still to be resolved:
+ *
+ * - Support PAGE_ALLOC_DEBUG. Should be easy to do.
+ *
+ * - Variable sizing of the per node arrays
+ */
+
+#define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
+				SLAB_POISON | SLAB_STORE_USER)
+
+/* Internal SLQB flags */
+#define __OBJECT_POISON		0x80000000 /* Poison object */
+
+/* Not all arches define cache_line_size */
+#ifndef cache_line_size
+#define cache_line_size()	L1_CACHE_BYTES
+#endif
+
+#ifdef CONFIG_SMP
+static struct notifier_block slab_notifier;
+#endif
+
+/* A list of all slab caches on the system */
+static DECLARE_RWSEM(slqb_lock);
+static LIST_HEAD(slab_caches);
+
+/*
+ * Tracking user of a slab.
+ */
+struct track {
+	void *addr;		/* Called from address */
+	int cpu;		/* Was running on cpu */
+	int pid;		/* Pid context */
+	unsigned long when;	/* When did the operation occur */
+};
+
+enum track_item { TRACK_ALLOC, TRACK_FREE };
+
+/********************************************************************
+ * 			Core slab cache functions
+ *******************************************************************/
+
+static int __slab_is_available __read_mostly;
+int slab_is_available(void)
+{
+	return __slab_is_available;
+}
+
+static inline struct kmem_cache_cpu *get_cpu_slab(struct kmem_cache *s, int cpu)
+{
+#ifdef CONFIG_SMP
+	VM_BUG_ON(!s->cpu_slab[cpu]);
+	return s->cpu_slab[cpu];
+#else
+	return &s->cpu_slab;
+#endif
+}
+
+static inline int check_valid_pointer(struct kmem_cache *s,
+				struct slqb_page *page, const void *object)
+{
+	void *base;
+
+	base = slqb_page_address(page);
+	if (object < base || object >= base + s->objects * s->size ||
+		(object - base) % s->size) {
+		return 0;
+	}
+
+	return 1;
+}
+
+static inline void *get_freepointer(struct kmem_cache *s, void *object)
+{
+	return *(void **)(object + s->offset);
+}
+
+static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
+{
+	*(void **)(object + s->offset) = fp;
+}
+
+/* Loop over all objects in a slab */
+#define for_each_object(__p, __s, __addr) \
+	for (__p = (__addr); __p < (__addr) + (__s)->objects * (__s)->size;\
+			__p += (__s)->size)
+
+/* Scan freelist */
+#define for_each_free_object(__p, __s, __free) \
+	for (__p = (__free); (__p) != NULL; __p = get_freepointer((__s),\
+		__p))
+
+/* Determine object index from a given position */
+static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
+{
+	return (p - addr) / s->size;
+}
+
+#ifdef CONFIG_SLQB_DEBUG
+/*
+ * Debug settings:
+ */
+#ifdef CONFIG_SLQB_DEBUG_ON
+static int slqb_debug __read_mostly = DEBUG_DEFAULT_FLAGS;
+#else
+static int slqb_debug __read_mostly;
+#endif
+
+static char *slqb_debug_slabs;
+
+/*
+ * Object debugging
+ */
+static void print_section(char *text, u8 *addr, unsigned int length)
+{
+	int i, offset;
+	int newline = 1;
+	char ascii[17];
+
+	ascii[16] = 0;
+
+	for (i = 0; i < length; i++) {
+		if (newline) {
+			printk(KERN_ERR "%8s 0x%p: ", text, addr + i);
+			newline = 0;
+		}
+		printk(KERN_CONT " %02x", addr[i]);
+		offset = i % 16;
+		ascii[offset] = isgraph(addr[i]) ? addr[i] : '.';
+		if (offset == 15) {
+			printk(KERN_CONT " %s\n", ascii);
+			newline = 1;
+		}
+	}
+	if (!newline) {
+		i %= 16;
+		while (i < 16) {
+			printk(KERN_CONT "   ");
+			ascii[i] = ' ';
+			i++;
+		}
+		printk(KERN_CONT " %s\n", ascii);
+	}
+}
+
+static struct track *get_track(struct kmem_cache *s, void *object,
+	enum track_item alloc)
+{
+	struct track *p;
+
+	if (s->offset)
+		p = object + s->offset + sizeof(void *);
+	else
+		p = object + s->inuse;
+
+	return p + alloc;
+}
+
+static void set_track(struct kmem_cache *s, void *object,
+				enum track_item alloc, void *addr)
+{
+	struct track *p;
+
+	if (s->offset)
+		p = object + s->offset + sizeof(void *);
+	else
+		p = object + s->inuse;
+
+	p += alloc;
+	if (addr) {
+		p->addr = addr;
+		p->cpu = raw_smp_processor_id();
+		p->pid = current ? current->pid : -1;
+		p->when = jiffies;
+	} else
+		memset(p, 0, sizeof(struct track));
+}
+
+static void init_tracking(struct kmem_cache *s, void *object)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
+	set_track(s, object, TRACK_FREE, NULL);
+	set_track(s, object, TRACK_ALLOC, NULL);
+}
+
+static void print_track(const char *s, struct track *t)
+{
+	if (!t->addr)
+		return;
+
+	printk(KERN_ERR "INFO: %s in ", s);
+	__print_symbol("%s", (unsigned long)t->addr);
+	printk(" age=%lu cpu=%u pid=%d\n", jiffies - t->when, t->cpu, t->pid);
+}
+
+static void print_tracking(struct kmem_cache *s, void *object)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return;
+
+	print_track("Allocated", get_track(s, object, TRACK_ALLOC));
+	print_track("Freed", get_track(s, object, TRACK_FREE));
+}
+
+static void print_page_info(struct slqb_page *page)
+{
+	printk(KERN_ERR "INFO: Slab 0x%p used=%u fp=0x%p flags=0x%04lx\n",
+		page, page->inuse, page->freelist, page->flags);
+
+}
+
+static void slab_bug(struct kmem_cache *s, char *fmt, ...)
+{
+	va_list args;
+	char buf[100];
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	printk(KERN_ERR "========================================"
+			"=====================================\n");
+	printk(KERN_ERR "BUG %s: %s\n", s->name, buf);
+	printk(KERN_ERR "----------------------------------------"
+			"-------------------------------------\n\n");
+}
+
+static void slab_fix(struct kmem_cache *s, char *fmt, ...)
+{
+	va_list args;
+	char buf[100];
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	printk(KERN_ERR "FIX %s: %s\n", s->name, buf);
+}
+
+static void print_trailer(struct kmem_cache *s, struct slqb_page *page, u8 *p)
+{
+	unsigned int off;	/* Offset of last byte */
+	u8 *addr = slqb_page_address(page);
+
+	print_tracking(s, p);
+
+	print_page_info(page);
+
+	printk(KERN_ERR "INFO: Object 0x%p @offset=%tu fp=0x%p\n\n",
+			p, p - addr, get_freepointer(s, p));
+
+	if (p > addr + 16)
+		print_section("Bytes b4", p - 16, 16);
+
+	print_section("Object", p, min(s->objsize, 128));
+
+	if (s->flags & SLAB_RED_ZONE)
+		print_section("Redzone", p + s->objsize,
+			s->inuse - s->objsize);
+
+	if (s->offset)
+		off = s->offset + sizeof(void *);
+	else
+		off = s->inuse;
+
+	if (s->flags & SLAB_STORE_USER)
+		off += 2 * sizeof(struct track);
+
+	if (off != s->size)
+		/* Beginning of the filler is the free pointer */
+		print_section("Padding", p + off, s->size - off);
+
+	dump_stack();
+}
+
+static void object_err(struct kmem_cache *s, struct slqb_page *page,
+			u8 *object, char *reason)
+{
+	slab_bug(s, reason);
+	print_trailer(s, page, object);
+}
+
+static void slab_err(struct kmem_cache *s, struct slqb_page *page, char *fmt, ...)
+{
+	va_list args;
+	char buf[100];
+
+	va_start(args, fmt);
+	vsnprintf(buf, sizeof(buf), fmt, args);
+	va_end(args);
+	slab_bug(s, fmt);
+	print_page_info(page);
+	dump_stack();
+}
+
+static void init_object(struct kmem_cache *s, void *object, int active)
+{
+	u8 *p = object;
+
+	if (s->flags & __OBJECT_POISON) {
+		memset(p, POISON_FREE, s->objsize - 1);
+		p[s->objsize - 1] = POISON_END;
+	}
+
+	if (s->flags & SLAB_RED_ZONE)
+		memset(p + s->objsize,
+			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE,
+			s->inuse - s->objsize);
+}
+
+static u8 *check_bytes(u8 *start, unsigned int value, unsigned int bytes)
+{
+	while (bytes) {
+		if (*start != (u8)value)
+			return start;
+		start++;
+		bytes--;
+	}
+	return NULL;
+}
+
+static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
+						void *from, void *to)
+{
+	slab_fix(s, "Restoring 0x%p-0x%p=0x%x\n", from, to - 1, data);
+	memset(from, data, to - from);
+}
+
+static int check_bytes_and_report(struct kmem_cache *s, struct slqb_page *page,
+			u8 *object, char *what,
+			u8 *start, unsigned int value, unsigned int bytes)
+{
+	u8 *fault;
+	u8 *end;
+
+	fault = check_bytes(start, value, bytes);
+	if (!fault)
+		return 1;
+
+	end = start + bytes;
+	while (end > fault && end[-1] == value)
+		end--;
+
+	slab_bug(s, "%s overwritten", what);
+	printk(KERN_ERR "INFO: 0x%p-0x%p. First byte 0x%x instead of 0x%x\n",
+					fault, end - 1, fault[0], value);
+	print_trailer(s, page, object);
+
+	restore_bytes(s, what, value, fault, end);
+	return 0;
+}
+
+/*
+ * Object layout:
+ *
+ * object address
+ * 	Bytes of the object to be managed.
+ * 	If the freepointer may overlay the object then the free
+ * 	pointer is the first word of the object.
+ *
+ * 	Poisoning uses 0x6b (POISON_FREE) and the last byte is
+ * 	0xa5 (POISON_END)
+ *
+ * object + s->objsize
+ * 	Padding to reach word boundary. This is also used for Redzoning.
+ * 	Padding is extended by another word if Redzoning is enabled and
+ * 	objsize == inuse.
+ *
+ * 	We fill with 0xbb (RED_INACTIVE) for inactive objects and with
+ * 	0xcc (RED_ACTIVE) for objects in use.
+ *
+ * object + s->inuse
+ * 	Meta data starts here.
+ *
+ * 	A. Free pointer (if we cannot overwrite object on free)
+ * 	B. Tracking data for SLAB_STORE_USER
+ * 	C. Padding to reach required alignment boundary or at mininum
+ * 		one word if debuggin is on to be able to detect writes
+ * 		before the word boundary.
+ *
+ *	Padding is done using 0x5a (POISON_INUSE)
+ *
+ * object + s->size
+ * 	Nothing is used beyond s->size.
+ */
+
+static int check_pad_bytes(struct kmem_cache *s, struct slqb_page *page, u8 *p)
+{
+	unsigned long off = s->inuse;	/* The end of info */
+
+	if (s->offset)
+		/* Freepointer is placed after the object. */
+		off += sizeof(void *);
+
+	if (s->flags & SLAB_STORE_USER)
+		/* We also have user information there */
+		off += 2 * sizeof(struct track);
+
+	if (s->size == off)
+		return 1;
+
+	return check_bytes_and_report(s, page, p, "Object padding",
+				p + off, POISON_INUSE, s->size - off);
+}
+
+static int slab_pad_check(struct kmem_cache *s, struct slqb_page *page)
+{
+	u8 *start;
+	u8 *fault;
+	u8 *end;
+	int length;
+	int remainder;
+
+	if (!(s->flags & SLAB_POISON))
+		return 1;
+
+	start = slqb_page_address(page);
+	end = start + (PAGE_SIZE << s->order);
+	length = s->objects * s->size;
+	remainder = end - (start + length);
+	if (!remainder)
+		return 1;
+
+	fault = check_bytes(start + length, POISON_INUSE, remainder);
+	if (!fault)
+		return 1;
+	while (end > fault && end[-1] == POISON_INUSE)
+		end--;
+
+	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
+	print_section("Padding", start, length);
+
+	restore_bytes(s, "slab padding", POISON_INUSE, start, end);
+	return 0;
+}
+
+static int check_object(struct kmem_cache *s, struct slqb_page *page,
+					void *object, int active)
+{
+	u8 *p = object;
+	u8 *endobject = object + s->objsize;
+	void *freepointer;
+
+	if (s->flags & SLAB_RED_ZONE) {
+		unsigned int red =
+			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE;
+
+		if (!check_bytes_and_report(s, page, object, "Redzone",
+			endobject, red, s->inuse - s->objsize))
+			return 0;
+	} else {
+		if ((s->flags & SLAB_POISON) && s->objsize < s->inuse) {
+			check_bytes_and_report(s, page, p, "Alignment padding",
+				endobject, POISON_INUSE, s->inuse - s->objsize);
+		}
+	}
+
+	if (s->flags & SLAB_POISON) {
+		if (!active && (s->flags & __OBJECT_POISON) &&
+			(!check_bytes_and_report(s, page, p, "Poison", p,
+					POISON_FREE, s->objsize - 1) ||
+			 !check_bytes_and_report(s, page, p, "Poison",
+				p + s->objsize - 1, POISON_END, 1)))
+			return 0;
+		/*
+		 * check_pad_bytes cleans up on its own.
+		 */
+		check_pad_bytes(s, page, p);
+	}
+
+#if 0
+	if (!s->offset && active)
+		/*
+		 * Object and freepointer overlap. Cannot check
+		 * freepointer while object is allocated.
+		 */
+		return 1;
+
+	freepointer = get_freepointer(s, p);
+	/* Check free pointer validity */
+	if (!check_valid_pointer(s, page, freepointer) && freepointer != NULL) {
+		object_err(s, page, p, "Freepointer corrupt");
+		/*
+		 * No choice but to zap it and thus loose the remainder
+		 * of the free objects in this slab. May cause
+		 * another error because the object count is now wrong.
+		 */
+		set_freepointer(s, p, NULL);
+		return 0;
+	}
+#endif
+	return 1;
+}
+
+static int check_slab(struct kmem_cache *s, struct slqb_page *page)
+{
+	if (!PageSlab(page)) {
+		slab_err(s, page, "Not a valid slab page");
+		return 0;
+	}
+	if (page->inuse == 0) {
+		slab_err(s, page, "inuse before free / after alloc", s->name);
+		return 0;
+	}
+	if (page->inuse > s->objects) {
+		slab_err(s, page, "inuse %u > max %u",
+			s->name, page->inuse, s->objects);
+		return 0;
+	}
+	/* Slab_pad_check fixes things up after itself */
+	slab_pad_check(s, page);
+	return 1;
+}
+
+static void trace(struct kmem_cache *s, struct slqb_page *page, void *object, int alloc)
+{
+	if (s->flags & SLAB_TRACE) {
+		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
+			s->name,
+			alloc ? "alloc" : "free",
+			object, page->inuse,
+			page->freelist);
+
+		if (!alloc)
+			print_section("Object", (void *)object, s->objsize);
+
+		dump_stack();
+	}
+}
+
+static void setup_object_debug(struct kmem_cache *s, struct slqb_page *page,
+								void *object)
+{
+	if (!slab_debug(s))
+		return;
+
+	if (!(s->flags & (SLAB_STORE_USER|SLAB_RED_ZONE|__OBJECT_POISON)))
+		return;
+
+	init_object(s, object, 0);
+	init_tracking(s, object);
+}
+
+static int alloc_debug_processing(struct kmem_cache *s, void *object, void *addr)
+{
+	struct slqb_page *page;
+	page = virt_to_head_slqb_page(object);
+
+	if (!check_slab(s, page))
+		goto bad;
+
+	if (!check_valid_pointer(s, page, object)) {
+		object_err(s, page, object, "Freelist Pointer check fails");
+		goto bad;
+	}
+
+	if (object && !check_object(s, page, object, 0))
+		goto bad;
+
+	/* Success perform special debug activities for allocs */
+	if (s->flags & SLAB_STORE_USER)
+		set_track(s, object, TRACK_ALLOC, addr);
+	trace(s, page, object, 1);
+	init_object(s, object, 1);
+	return 1;
+
+bad:
+	if (PageSlab(page)) {
+		/*
+		 * If this is a slab page then lets do the best we can
+		 * to avoid issues in the future. Marking all objects
+		 * as used avoids touching the remaining objects.
+		 */
+		slab_fix(s, "Marking all objects used");
+		page->inuse = s->objects;
+		page->freelist = NULL;
+	}
+	return 0;
+}
+
+static int free_debug_processing(struct kmem_cache *s, void *object, void *addr)
+{
+	struct slqb_page *page;
+	page = virt_to_head_slqb_page(object);
+
+	if (!check_slab(s, page))
+		goto fail;
+
+	if (!check_valid_pointer(s, page, object)) {
+		slab_err(s, page, "Invalid object pointer 0x%p", object);
+		goto fail;
+	}
+
+	if (!check_object(s, page, object, 1))
+		return 0;
+
+	/* Special debug activities for freeing objects */
+	if (s->flags & SLAB_STORE_USER)
+		set_track(s, object, TRACK_FREE, addr);
+	trace(s, page, object, 0);
+	init_object(s, object, 0);
+	return 1;
+
+fail:
+	slab_fix(s, "Object at 0x%p not freed", object);
+	return 0;
+}
+
+static int __init setup_slqb_debug(char *str)
+{
+	slqb_debug = DEBUG_DEFAULT_FLAGS;
+	if (*str++ != '=' || !*str)
+		/*
+		 * No options specified. Switch on full debugging.
+		 */
+		goto out;
+
+	if (*str == ',')
+		/*
+		 * No options but restriction on slabs. This means full
+		 * debugging for slabs matching a pattern.
+		 */
+		goto check_slabs;
+
+	slqb_debug = 0;
+	if (*str == '-')
+		/*
+		 * Switch off all debugging measures.
+		 */
+		goto out;
+
+	/*
+	 * Determine which debug features should be switched on
+	 */
+	for (; *str && *str != ','; str++) {
+		switch (tolower(*str)) {
+		case 'f':
+			slqb_debug |= SLAB_DEBUG_FREE;
+			break;
+		case 'z':
+			slqb_debug |= SLAB_RED_ZONE;
+			break;
+		case 'p':
+			slqb_debug |= SLAB_POISON;
+			break;
+		case 'u':
+			slqb_debug |= SLAB_STORE_USER;
+			break;
+		case 't':
+			slqb_debug |= SLAB_TRACE;
+			break;
+		default:
+			printk(KERN_ERR "slqb_debug option '%c' "
+				"unknown. skipped\n", *str);
+		}
+	}
+
+check_slabs:
+	if (*str == ',')
+		slqb_debug_slabs = str + 1;
+out:
+	return 1;
+}
+
+__setup("slqb_debug", setup_slqb_debug);
+
+static unsigned long kmem_cache_flags(unsigned long objsize,
+	unsigned long flags, const char *name,
+	void (*ctor)(void *))
+{
+	/*
+	 * Enable debugging if selected on the kernel commandline.
+	 */
+	if (slqb_debug && (!slqb_debug_slabs ||
+	    strncmp(slqb_debug_slabs, name,
+		strlen(slqb_debug_slabs)) == 0))
+			flags |= slqb_debug;
+
+	return flags;
+}
+#else
+static inline void setup_object_debug(struct kmem_cache *s,
+			struct slqb_page *page, void *object) {}
+
+static inline int alloc_debug_processing(struct kmem_cache *s,
+	void *object, void *addr) { return 0; }
+
+static inline int free_debug_processing(struct kmem_cache *s,
+	void *object, void *addr) { return 0; }
+
+static inline int slab_pad_check(struct kmem_cache *s, struct slqb_page *page)
+			{ return 1; }
+static inline int check_object(struct kmem_cache *s, struct slqb_page *page,
+			void *object, int active) { return 1; }
+static inline void add_full(struct kmem_cache_node *n, struct slqb_page *page) {}
+static inline unsigned long kmem_cache_flags(unsigned long objsize,
+	unsigned long flags, const char *name, void (*ctor)(void *))
+{
+	return flags;
+}
+#define slqb_debug 0
+#endif
+/*
+ * Slab allocation and freeing
+ */
+static struct slqb_page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct slqb_page *page;
+	int pages = 1 << s->order;
+
+	flags |= s->allocflags;
+
+	page = alloc_slqb_pages_node(node, flags, s->order);
+	if (!page)
+		return NULL;
+
+	mod_zone_page_state(slqb_page_zone(page),
+		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+		pages);
+
+	return page;
+}
+
+static void setup_object(struct kmem_cache *s, struct slqb_page *page,
+				void *object)
+{
+	setup_object_debug(s, page, object);
+	if (unlikely(s->ctor))
+		s->ctor(object);
+}
+
+static struct slqb_page *new_slab_page(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct slqb_page *page;
+	void *start;
+	void *last;
+	void *p;
+
+	BUG_ON(flags & GFP_SLAB_BUG_MASK);
+
+	page = allocate_slab(s,
+		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
+	if (!page)
+		goto out;
+
+	page->flags |= 1 << PG_slab;
+
+	start = page_address(&page->page);
+
+	if (unlikely(slab_poison(s)))
+		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
+
+	last = start;
+	for_each_object(p, s, start) {
+		setup_object(s, page, p);
+		set_freepointer(s, last, p);
+		last = p;
+	}
+	set_freepointer(s, last, NULL);
+
+	page->freelist = start;
+	page->inuse = 0;
+
+	count_slqb_events(SLQB_PAGE_ALLOC, 1UL << s->order);
+out:
+	return page;
+}
+
+static void __free_slab(struct kmem_cache *s, struct slqb_page *page)
+{
+	int pages = 1 << s->order;
+
+	if (unlikely(slab_debug(s))) {
+		void *p;
+
+		slab_pad_check(s, page);
+		for_each_object(p, s, slqb_page_address(page))
+			check_object(s, page, p, 0);
+	}
+
+	mod_zone_page_state(slqb_page_zone(page),
+		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+		-pages);
+
+	__free_slqb_pages(page, s->order);
+	count_slqb_events(SLQB_PAGE_FREE, 1UL << s->order);
+}
+
+static void rcu_free_slab(struct rcu_head *h)
+{
+	struct slqb_page *page;
+
+	page = container_of((struct list_head *)h, struct slqb_page, lru);
+	__free_slab(page->list->cache, page);
+}
+
+static void free_slab(struct kmem_cache *s, struct slqb_page *page)
+{
+	VM_BUG_ON(page->inuse);
+	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU))
+		call_rcu(&page->rcu_head, rcu_free_slab);
+	else
+		__free_slab(s, page);
+}
+
+static __always_inline int free_object_to_page(struct kmem_cache *s, struct kmem_cache_list *l, struct slqb_page *page, void *object)
+{
+	VM_BUG_ON(page->list != l);
+
+	set_freepointer(s, object, page->freelist);
+	page->freelist = object;
+	page->inuse--;
+
+	if (!page->inuse) {
+		if (likely(s->objects > 1)) {
+			l->nr_partial--;
+			list_del(&page->lru);
+		}
+		l->nr_slabs--;
+		free_slab(s, page);
+		__count_slqb_event(SLQB_PAGE_FREE_EMPTY);
+		return 1;
+	} else if (page->inuse + 1 == s->objects) {
+		__count_slqb_event(SLQB_PAGE_FREE_PARTIAL);
+		l->nr_partial++;
+		list_add(&page->lru, &l->partial);
+		return 0;
+	}
+	return 0;
+}
+
+#ifdef CONFIG_SMP
+static noinline void slab_free_to_remote(struct kmem_cache *s, struct slqb_page *page, void *object, struct kmem_cache_cpu *c);
+#endif
+static void flush_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	struct kmem_cache_cpu *c;
+	void **head;
+	int nr;
+
+	nr = l->freelist.nr;
+	if (unlikely(!nr))
+		return;
+
+	nr = min(s->batch, nr);
+	__count_slqb_events(SLQB_FLUSH_FREE_LIST, nr);
+
+	c = get_cpu_slab(s, smp_processor_id());
+
+	l->freelist.nr -= nr;
+	head = l->freelist.head;
+
+	do {
+		struct slqb_page *page;
+		void **object;
+
+		object = head;
+		VM_BUG_ON(!object);
+		head = get_freepointer(s, object);
+		page = virt_to_head_slqb_page(object);
+
+#ifdef CONFIG_SMP
+		if (page->list != l)
+			slab_free_to_remote(s, page, object, c);
+		else
+#endif
+			free_object_to_page(s, l, page, object);
+
+		nr--;
+	} while (nr);
+
+	l->freelist.head = head;
+	if (!l->freelist.nr)
+		l->freelist.tail = NULL;
+}
+
+static void flush_free_list_all(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	while (l->freelist.nr)
+		flush_free_list(s, l);
+}
+
+#ifdef CONFIG_SMP
+static void claim_remote_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	void **head, **tail;
+	int nr;
+
+	VM_BUG_ON(!l->remote_free.list.head != !l->remote_free.list.tail);
+
+	if (!l->remote_free.list.nr)
+		return;
+
+	__count_slqb_event(SLQB_CLAIM_REMOTE_FREE_CACHE);
+	l->remote_free_check = 0;
+	head = l->remote_free.list.head;
+	prefetchw(head);
+
+	spin_lock(&l->remote_free.lock);
+	l->remote_free.list.head = NULL;
+	tail = l->remote_free.list.tail;
+	l->remote_free.list.tail = NULL;
+	nr = l->remote_free.list.nr;
+	l->remote_free.list.nr = 0;
+	spin_unlock(&l->remote_free.lock);
+
+	if (!l->freelist.nr)
+		l->freelist.head = head;
+	else
+		set_freepointer(s, l->freelist.tail, head);
+	l->freelist.tail = tail;
+
+	l->freelist.nr += nr;
+}
+#endif
+
+static __always_inline void *__cache_list_get_object(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	void *object;
+
+	object = l->freelist.head;
+	if (likely(object)) {
+		void *next = get_freepointer(s, object);
+		VM_BUG_ON(!l->freelist.nr);
+		l->freelist.nr--;
+		l->freelist.head = next;
+//		prefetchw(next);
+		return object;
+	}
+	VM_BUG_ON(l->freelist.nr);
+
+#ifdef CONFIG_SMP
+	if (unlikely(l->remote_free_check)) {
+		claim_remote_free_list(s, l);
+
+		if (l->freelist.nr > (s->batch<<2))
+			flush_free_list(s, l);
+
+		/* repetition here helps gcc :( */
+		object = l->freelist.head;
+		if (likely(object)) {
+			void *next = get_freepointer(s, object);
+			VM_BUG_ON(!l->freelist.nr);
+			l->freelist.nr--;
+			l->freelist.head = next;
+//			prefetchw(next);
+			return object;
+		}
+		VM_BUG_ON(l->freelist.nr);
+	}
+#endif
+
+	return NULL;
+}
+
+static noinline void *__cache_list_get_page(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	struct slqb_page *page;
+
+	if (likely(l->nr_partial)) {
+		page = list_first_entry(&l->partial, struct slqb_page, lru);
+		VM_BUG_ON(page->inuse == s->objects);
+		if (page->inuse + 1 == s->objects) {
+			l->nr_partial--;
+			list_del(&page->lru);
+			__count_slqb_event(SLQB_PAGE_ALLOC_FULL);
+/*XXX			list_move(&page->lru, &l->full); */
+		}
+	} else {
+		return NULL;
+	}
+
+	VM_BUG_ON(!page->freelist);
+
+	page->inuse++;
+
+	return page;
+}
+
+static noinline int __slab_alloc_page(struct kmem_cache *s, gfp_t gfpflags, int node)
+{
+	struct slqb_page *page;
+	struct kmem_cache_list *l;
+
+	/* XXX: load any partial? */
+
+	/* Caller handles __GFP_ZERO */
+	gfpflags &= ~__GFP_ZERO;
+
+	if (gfpflags & __GFP_WAIT)
+		local_irq_enable();
+	page = new_slab_page(s, gfpflags, node);
+	if (gfpflags & __GFP_WAIT)
+		local_irq_disable();
+	if (unlikely(!page))
+		return 0;
+
+	/* XXX: might disobey node parameter here */
+	if (!NUMA_BUILD || likely(slqb_page_to_nid(page) == numa_node_id())) {
+		struct kmem_cache_cpu *c;
+		int cpu = smp_processor_id();
+
+		c = get_cpu_slab(s, cpu);
+		l = &c->list;
+		page->list = l;
+		l->nr_slabs++;
+		l->nr_partial++;
+		list_add(&page->lru, &l->partial);
+#ifdef CONFIG_NUMA
+	} else {
+		struct kmem_cache_node *n;
+
+		n = s->node[slqb_page_to_nid(page)];
+		l = &n->list;
+		page->list = l;
+
+		spin_lock(&n->list_lock);
+		if (unlikely(l->nr_partial)) {
+			spin_unlock(&n->list_lock);
+			__free_slqb_pages(page, s->order);
+			return 1;
+		}
+		l->nr_slabs++;
+		l->nr_partial++;
+		list_add(&page->lru, &l->partial);
+		spin_unlock(&n->list_lock);
+#endif
+	}
+	return 1;
+}
+
+#ifdef CONFIG_NUMA
+static noinline void *__remote_slab_alloc(struct kmem_cache *s, int node)
+{
+	struct kmem_cache_node *n;
+	struct kmem_cache_list *l;
+	void *object;
+
+	n = s->node[node];
+	VM_BUG_ON(!n);
+	l = &n->list;
+
+//	if (unlikely(!(l->freelist.nr | l->nr_partial | l->remote_free_check)))
+//		return NULL;
+
+	spin_lock(&n->list_lock);
+
+	object = __cache_list_get_object(s, l);
+	if (unlikely(!object)) {
+		struct slqb_page *page;
+
+		page = __cache_list_get_page(s, l);
+		if (unlikely(!page)) {
+			spin_unlock(&n->list_lock);
+			return NULL;
+		}
+		VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
+
+		object = page->freelist;
+		page->freelist = get_freepointer(s, object);
+		VM_BUG_ON((page->inuse == s->objects) != (page->freelist == NULL));
+		__count_slqb_event(SLQB_ALLOC_FROM_PAGE);
+
+	}
+	spin_unlock(&n->list_lock);
+	__count_slqb_event(SLQB_OFFNODE_ALLOC);
+	__count_slqb_event(SLQB_ALLOC);
+	return object;
+}
+#endif
+
+static __always_inline void *__slab_alloc(struct kmem_cache *s,
+		gfp_t gfpflags, int node)
+{
+	void *object;
+	struct kmem_cache_cpu *c;
+	struct kmem_cache_list *l;
+
+again:
+#ifdef CONFIG_NUMA
+	if (unlikely(node != -1) && unlikely(node != numa_node_id())) {
+		object = __remote_slab_alloc(s, node);
+		if (unlikely(!object))
+			goto alloc_new;
+		return object;
+	}
+#endif
+
+	c = get_cpu_slab(s, smp_processor_id());
+	VM_BUG_ON(!c);
+	l = &c->list;
+	object = __cache_list_get_object(s, l);
+	if (unlikely(!object)) {
+		struct slqb_page *page;
+		page = __cache_list_get_page(s, l);
+		if (unlikely(!page))
+			goto alloc_new;
+		object = page->freelist;
+		page->freelist = get_freepointer(s, object);
+		VM_BUG_ON((page->inuse == s->objects) != (page->freelist == NULL));
+		VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
+		__count_slqb_event(SLQB_ALLOC_FROM_PAGE);
+	}
+	__count_slqb_event(SLQB_ALLOC);
+	return object;
+
+alloc_new:
+	if (unlikely(!__slab_alloc_page(s, gfpflags, node)))
+		return NULL;
+	goto again;
+}
+
+static __always_inline void *slab_alloc(struct kmem_cache *s,
+		gfp_t gfpflags, int node, void *addr)
+{
+	void *object;
+	unsigned long flags;
+
+again:
+	local_irq_save(flags);
+	object = __slab_alloc(s, gfpflags, node);
+	local_irq_restore(flags);
+
+	if (unlikely(slab_debug(s)) && likely(object)) {
+		if (unlikely(!alloc_debug_processing(s, object, addr)))
+			goto again;
+	}
+
+	if (unlikely(gfpflags & __GFP_ZERO) && likely(object))
+		memset(object, 0, s->objsize);
+
+	return object;
+}
+
+void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
+{
+	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(kmem_cache_alloc);
+
+#ifdef CONFIG_NUMA
+void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
+{
+	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node);
+#endif
+
+#ifdef CONFIG_SMP
+static void flush_remote_free_cache(struct kmem_cache *s, struct kmem_cache_cpu *c)
+{
+	struct kmlist *src;
+	struct kmem_cache_list *dst;
+	unsigned int nr;
+	int set;
+
+	src = &c->rlist;
+	nr = src->nr;
+	if (unlikely(!nr))
+		return;
+
+	__count_slqb_event(SLQB_FLUSH_REMOTE_FREE_CACHE);
+
+	dst = c->remote_cache_list;
+
+	spin_lock(&dst->remote_free.lock);
+	if (!dst->remote_free.list.head)
+		dst->remote_free.list.head = src->head;
+	else
+		set_freepointer(s, dst->remote_free.list.tail, src->head);
+	dst->remote_free.list.tail = src->tail;
+
+	src->head = NULL;
+	src->tail = NULL;
+	src->nr = 0;
+
+	if (dst->remote_free.list.nr < s->batch)
+		set = 1;
+	else
+		set = 0;
+
+	dst->remote_free.list.nr += nr;
+
+	if (unlikely(dst->remote_free.list.nr >= s->batch && set))
+		dst->remote_free_check = 1;
+
+	spin_unlock(&dst->remote_free.lock);
+}
+
+static noinline void slab_free_to_remote(struct kmem_cache *s, struct slqb_page *page, void *object, struct kmem_cache_cpu *c)
+{
+	struct kmlist *r;
+
+	__count_slqb_event(SLQB_REMOTE_FREE);
+
+	if (page->list != c->remote_cache_list) {
+		flush_remote_free_cache(s, c);
+		c->remote_cache_list = page->list;
+	}
+
+	r = &c->rlist;
+	if (!r->head)
+		r->head = object;
+	else
+		set_freepointer(s, r->tail, object);
+	set_freepointer(s, object, NULL);
+	r->tail = object;
+	r->nr++;
+
+	if (unlikely(r->nr > s->batch))
+		flush_remote_free_cache(s, c);
+}
+#endif
+ 
+static __always_inline void __slab_free(struct kmem_cache *s, struct slqb_page *page, void *object)
+{
+	struct kmem_cache_cpu *c;
+	struct kmem_cache_list *l;
+	int thiscpu = smp_processor_id();
+
+	__count_slqb_event(SLQB_FREE);
+
+	c = get_cpu_slab(s, thiscpu);
+	l = &c->list;
+
+	if (!NUMA_BUILD || !numa_platform ||
+			likely(slqb_page_to_nid(page) == numa_node_id())) {
+
+#if 0 // FIFO
+		if (!l->freelist.nr) {
+			l->freelist.head = object;
+		} else
+			set_freepointer(s, l->freelist.tail, object);
+		set_freepointer(s, object, NULL);
+		l->freelist.tail = object;
+#else // LIFO
+		set_freepointer(s, object, l->freelist.head);
+		l->freelist.head = object;
+		if (!l->freelist.nr)
+			l->freelist.tail = object;
+#endif
+		l->freelist.nr++;
+
+		if (unlikely(l->freelist.nr > (s->batch<<2)))
+			flush_free_list(s, l);
+
+#ifdef CONFIG_SMP
+	} else {
+		slab_free_to_remote(s, page, object, c);
+#endif
+	}
+}
+
+void kmem_cache_free(struct kmem_cache *s, void *object)
+{
+	struct page *p;
+	unsigned long flags;
+
+	p = NULL;
+	if (numa_platform) {
+		p = virt_to_page(object);
+		prefetch(p);
+	}
+	prefetchw(object);
+
+	debug_check_no_locks_freed(object, s->objsize);
+	if (likely(object) && unlikely(slab_debug(s))) {
+		if (unlikely(!free_debug_processing(s, object, __builtin_return_address(0))))
+			return;
+	}
+
+	local_irq_save(flags);
+	if (numa_platform)
+		p = compound_head(p);
+	__slab_free(s, (struct slqb_page *)p, object);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(kmem_cache_free);
+
+/*
+ * Calculate the order of allocation given an slab object size.
+ *
+ * Order 0 allocations are preferred since order 0 does not cause fragmentation
+ * in the page allocator, and they have fastpaths in the page allocator. But
+ * also minimise external fragmentation with large objects.
+ */
+static inline int slab_order(int size, int max_order, int frac)
+{
+	int order;
+
+	if (fls(size - 1) <= PAGE_SHIFT)
+		order = 0;
+	else
+		order = fls(size - 1) - PAGE_SHIFT;
+	while (order <= max_order) {
+		unsigned long slab_size = PAGE_SIZE << order;
+		unsigned long objects;
+		unsigned long waste;
+
+		objects = slab_size / size;
+		if (!objects)
+			continue;
+
+		waste = slab_size - (objects * size);
+
+		if (waste * frac <= slab_size)
+			break;
+
+		order++;
+	}
+
+	return order;
+}
+
+static inline int calculate_order(int size)
+{
+	int order;
+
+	/*
+	 * Attempt to find best configuration for a slab. This
+	 * works by first attempting to generate a layout with
+	 * the best configuration and backing off gradually.
+	 */
+	order = slab_order(size, 1, 4);
+	if (order <= 1)
+		return order;
+
+	/*
+	 * This size cannot fit in order-1. Allow bigger orders, but
+	 * forget about trying to save space.
+	 */
+	order = slab_order(size, MAX_ORDER, 0);
+	if (order <= MAX_ORDER)
+		return order;
+
+	return -ENOSYS;
+}
+
+/*
+ * Figure out what the alignment of the objects will be.
+ */
+static unsigned long calculate_alignment(unsigned long flags,
+		unsigned long align, unsigned long size)
+{
+	/*
+	 * If the user wants hardware cache aligned objects then follow that
+	 * suggestion if the object is sufficiently large.
+	 *
+	 * The hardware cache alignment cannot override the specified
+	 * alignment though. If that is greater then use it.
+	 */
+	if (flags & SLAB_HWCACHE_ALIGN) {
+		unsigned long ralign = cache_line_size();
+		while (size <= ralign / 2)
+			ralign /= 2;
+		align = max(align, ralign);
+	}
+
+	if (align < ARCH_SLAB_MINALIGN)
+		align = ARCH_SLAB_MINALIGN;
+
+	return ALIGN(align, sizeof(void *));
+}
+
+static void init_kmem_cache_list(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	l->cache = s;
+	l->freelist.nr = 0;
+	l->freelist.head = NULL;
+	l->freelist.tail = NULL;
+	l->nr_partial = 0;
+	l->nr_slabs = 0;
+	INIT_LIST_HEAD(&l->partial);
+//	INIT_LIST_HEAD(&l->full);
+
+#ifdef CONFIG_SMP
+	l->remote_free_check = 0;
+	spin_lock_init(&l->remote_free.lock);
+	l->remote_free.list.nr = 0;
+	l->remote_free.list.head = NULL;
+	l->remote_free.list.tail = NULL;
+#endif
+}
+
+static void init_kmem_cache_cpu(struct kmem_cache *s,
+			struct kmem_cache_cpu *c)
+{
+	init_kmem_cache_list(s, &c->list);
+
+#ifdef CONFIG_SMP
+	c->rlist.nr = 0;
+	c->rlist.head = NULL;
+	c->rlist.tail = NULL;
+	c->remote_cache_list = NULL;
+#endif
+
+#ifdef CONFIG_SLQB_STATS
+	memset(c->stat, 0, sizeof(c->stat));
+#endif
+}
+
+#ifdef CONFIG_NUMA
+static void init_kmem_cache_node(struct kmem_cache *s, struct kmem_cache_node *n)
+{
+	spin_lock_init(&n->list_lock);
+	init_kmem_cache_list(s, &n->list);
+}
+#endif
+
+/* Initial slabs */
+static struct kmem_cache kmem_cache_cache;
+#ifdef CONFIG_SMP
+static struct kmem_cache_cpu kmem_cache_cpus[NR_CPUS];
+#endif
+#ifdef CONFIG_NUMA
+static struct kmem_cache_node kmem_cache_nodes[MAX_NUMNODES];
+#endif
+
+#ifdef CONFIG_SMP
+static struct kmem_cache kmem_cpu_cache;
+static struct kmem_cache_cpu kmem_cpu_cpus[NR_CPUS];
+#ifdef CONFIG_NUMA
+static struct kmem_cache_node kmem_cpu_nodes[MAX_NUMNODES];
+#endif
+#endif
+
+#ifdef CONFIG_NUMA
+static struct kmem_cache kmem_node_cache;
+static struct kmem_cache_cpu kmem_node_cpus[NR_CPUS];
+static struct kmem_cache_node kmem_node_nodes[MAX_NUMNODES];
+#endif
+
+#ifdef CONFIG_SMP
+static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int cpu)
+{
+	struct kmem_cache_cpu *c;
+
+	c = kmem_cache_alloc_node(&kmem_cpu_cache, GFP_KERNEL, cpu_to_node(cpu));
+	if (!c)
+		return NULL;
+
+	init_kmem_cache_cpu(s, c);
+	return c;
+}
+
+static void free_kmem_cache_cpus(struct kmem_cache *s)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c;
+
+		c = s->cpu_slab[cpu];
+		if (c) {
+			kmem_cache_free(&kmem_cpu_cache, c);
+			s->cpu_slab[cpu] = NULL;
+		}
+	}
+}
+
+static int alloc_kmem_cache_cpus(struct kmem_cache *s)
+{
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c;
+
+		c = s->cpu_slab[cpu];
+		if (c)
+			continue;
+
+		c = alloc_kmem_cache_cpu(s, cpu);
+		if (!c) {
+			free_kmem_cache_cpus(s);
+			return 0;
+		}
+		s->cpu_slab[cpu] = c;
+	}
+	return 1;
+}
+
+#else
+static inline void free_kmem_cache_cpus(struct kmem_cache *s)
+{
+}
+
+static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
+{
+	init_kmem_cache_cpu(s, &s->cpu_slab);
+	return 1;
+}
+#endif
+
+#ifdef CONFIG_NUMA
+static void free_kmem_cache_nodes(struct kmem_cache *s)
+{
+	int node;
+
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n;
+
+		n = s->node[node];
+		if (n) {
+			kmem_cache_free(&kmem_node_cache, n);
+			s->node[node] = NULL;
+		}
+	}
+}
+
+static int alloc_kmem_cache_nodes(struct kmem_cache *s)
+{
+	int node;
+
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n;
+
+		n = kmem_cache_alloc_node(&kmem_node_cache, GFP_KERNEL, node);
+		if (!n) {
+			free_kmem_cache_nodes(s);
+			return 0;
+		}
+		init_kmem_cache_node(s, n);
+		s->node[node] = n;
+	}
+	return 1;
+}
+#else
+static void free_kmem_cache_nodes(struct kmem_cache *s)
+{
+}
+
+static int alloc_kmem_cache_nodes(struct kmem_cache *s)
+{
+	return 1;
+}
+#endif
+
+/*
+ * calculate_sizes() determines the order and the distribution of data within
+ * a slab object.
+ */
+static int calculate_sizes(struct kmem_cache *s)
+{
+	unsigned long flags = s->flags;
+	unsigned long size = s->objsize;
+	unsigned long align = s->align;
+
+	/*
+	 * Determine if we can poison the object itself. If the user of
+	 * the slab may touch the object after free or before allocation
+	 * then we should never poison the object itself.
+	 */
+	if (slab_poison(s) && !(flags & SLAB_DESTROY_BY_RCU) && !s->ctor)
+		s->flags |= __OBJECT_POISON;
+	else
+		s->flags &= ~__OBJECT_POISON;
+
+	/*
+	 * Round up object size to the next word boundary. We can only
+	 * place the free pointer at word boundaries and this determines
+	 * the possible location of the free pointer.
+	 */
+	size = ALIGN(size, sizeof(void *));
+
+#ifdef CONFIG_SLQB_DEBUG
+	/*
+	 * If we are Redzoning then check if there is some space between the
+	 * end of the object and the free pointer. If not then add an
+	 * additional word to have some bytes to store Redzone information.
+	 */
+	if ((flags & SLAB_RED_ZONE) && size == s->objsize)
+		size += sizeof(void *);
+#endif
+
+	/*
+	 * With that we have determined the number of bytes in actual use
+	 * by the object. This is the potential offset to the free pointer.
+	 */
+	s->inuse = size;
+
+	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) || s->ctor)) {
+		/*
+		 * Relocate free pointer after the object if it is not
+		 * permitted to overwrite the first word of the object on
+		 * kmem_cache_free.
+		 *
+		 * This is the case if we do RCU, have a constructor or
+		 * destructor or are poisoning the objects.
+		 */
+		s->offset = size;
+		size += sizeof(void *);
+	}
+
+#ifdef CONFIG_SLQB_DEBUG
+	if (flags & SLAB_STORE_USER)
+		/*
+		 * Need to store information about allocs and frees after
+		 * the object.
+		 */
+		size += 2 * sizeof(struct track);
+
+	if (flags & SLAB_RED_ZONE)
+		/*
+		 * Add some empty padding so that we can catch
+		 * overwrites from earlier objects rather than let
+		 * tracking information or the free pointer be
+		 * corrupted if an user writes before the start
+		 * of the object.
+		 */
+		size += sizeof(void *);
+#endif
+
+	/*
+	 * Determine the alignment based on various parameters that the
+	 * user specified and the dynamic determination of cache line size
+	 * on bootup.
+	 */
+	align = calculate_alignment(flags, align, s->objsize);
+
+	/*
+	 * SLQB stores one object immediately after another beginning from
+	 * offset 0. In order to align the objects we have to simply size
+	 * each object to conform to the alignment.
+	 */
+	size = ALIGN(size, align);
+	s->size = size;
+	s->order = calculate_order(size);
+
+	if (s->order < 0)
+		return 0;
+
+	s->allocflags = 0;
+	if (s->order)
+		s->allocflags |= __GFP_COMP;
+
+	if (s->flags & SLAB_CACHE_DMA)
+		s->allocflags |= SLQB_DMA;
+
+	if (s->flags & SLAB_RECLAIM_ACCOUNT)
+		s->allocflags |= __GFP_RECLAIMABLE;
+
+	/*
+	 * Determine the number of objects per slab
+	 */
+	s->objects = (PAGE_SIZE << s->order) / size;
+
+	s->batch = max(4*PAGE_SIZE / size, min(256, 64*PAGE_SIZE / size));
+	if (!s->batch)
+		s->batch = 1;
+
+	return !!s->objects;
+
+}
+
+static int kmem_cache_open(struct kmem_cache *s,
+		const char *name, size_t size,
+		size_t align, unsigned long flags,
+		void (*ctor)(void *), int alloc)
+{
+	memset(s, 0, kmem_size);
+	s->name = name;
+	s->ctor = ctor;
+	s->objsize = size;
+	s->align = align;
+	s->flags = kmem_cache_flags(size, flags, name, ctor);
+
+	if (!calculate_sizes(s))
+		goto error;
+
+#ifdef CONFIG_NUMA
+	s->remote_node_defrag_ratio = 100;
+#endif
+
+	if (likely(alloc)) {
+		if (!alloc_kmem_cache_nodes(s))
+			goto error;
+
+		if (!alloc_kmem_cache_cpus(s))
+			goto error_nodes;
+	}
+
+	/* XXX: perform some basic checks like SLAB does, eg. duplicate names */
+	down_write(&slqb_lock);
+	list_add(&s->list, &slab_caches);
+	up_write(&slqb_lock);
+
+	return 1;
+
+error_nodes:
+	free_kmem_cache_nodes(s);
+error:
+	if (flags & SLAB_PANIC)
+		panic("kmem_cache_create(): failed to create slab `%s'\n",name);
+	return 0;
+}
+
+/*
+ * Check if a given pointer is valid
+ */
+int kmem_ptr_validate(struct kmem_cache *s, const void *object)
+{
+	struct slqb_page *page = virt_to_head_slqb_page(object);
+
+	if (!PageSlab(page))
+		return 0;
+
+	if (!check_valid_pointer(s, page, object))
+		return 0;
+
+	/*
+	 * We could also check if the object is on the slabs freelist.
+	 * But this would be too expensive and it seems that the main
+	 * purpose of kmem_ptr_valid is to check if the object belongs
+	 * to a certain slab.
+	 */
+	return 1;
+}
+EXPORT_SYMBOL(kmem_ptr_validate);
+
+/*
+ * Determine the size of a slab object
+ */
+unsigned int kmem_cache_size(struct kmem_cache *s)
+{
+	return s->objsize;
+}
+EXPORT_SYMBOL(kmem_cache_size);
+
+const char *kmem_cache_name(struct kmem_cache *s)
+{
+	return s->name;
+}
+EXPORT_SYMBOL(kmem_cache_name);
+
+/*
+ * Release all resources used by a slab cache. No more concurrency on the
+ * slab, so we can touch remote kmem_cache_cpu structures.
+ */
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+#ifdef CONFIG_NUMA
+	int node;
+#endif
+	int cpu;
+
+	down_write(&slqb_lock);
+	list_del(&s->list);
+	up_write(&slqb_lock);
+
+#ifdef CONFIG_SMP
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+		struct kmem_cache_list *l = &c->list;
+
+		flush_free_list_all(s, l);
+		flush_remote_free_cache(s, c);
+	}
+#endif
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+		struct kmem_cache_list *l = &c->list;
+
+#ifdef CONFIG_SMP
+		claim_remote_free_list(s, l);
+#endif
+		flush_free_list_all(s, l);
+
+		WARN_ON(l->freelist.nr);
+		WARN_ON(l->nr_slabs);
+		WARN_ON(l->nr_partial);
+	}
+
+	free_kmem_cache_cpus(s);
+
+#ifdef CONFIG_NUMA
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_list *l = &n->list;
+
+		claim_remote_free_list(s, l);
+		flush_free_list_all(s, l);
+
+		WARN_ON(l->freelist.nr);
+		WARN_ON(l->nr_slabs);
+		WARN_ON(l->nr_partial);
+	}
+
+	free_kmem_cache_nodes(s);
+#endif
+
+	kmem_cache_free(&kmem_cache_cache, s);
+}
+EXPORT_SYMBOL(kmem_cache_destroy);
+
+/********************************************************************
+ *		Kmalloc subsystem
+ *******************************************************************/
+
+struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_SLQB_HIGH + 1] __cacheline_aligned;
+EXPORT_SYMBOL(kmalloc_caches);
+
+#ifdef CONFIG_ZONE_DMA
+struct kmem_cache kmalloc_caches_dma[KMALLOC_SHIFT_SLQB_HIGH + 1] __cacheline_aligned;
+EXPORT_SYMBOL(kmalloc_caches_dma);
+#endif
+
+#ifndef ARCH_KMALLOC_FLAGS
+#define ARCH_KMALLOC_FLAGS SLAB_HWCACHE_ALIGN
+#endif
+
+static struct kmem_cache *open_kmalloc_cache(struct kmem_cache *s,
+		const char *name, int size, gfp_t gfp_flags)
+{
+	unsigned int flags = ARCH_KMALLOC_FLAGS | SLAB_PANIC;
+
+	if (gfp_flags & SLQB_DMA)
+		flags |= SLAB_CACHE_DMA;
+
+	kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN, flags, NULL, 1);
+
+	return s;
+}
+
+/*
+ * Conversion table for small slabs sizes / 8 to the index in the
+ * kmalloc array. This is necessary for slabs < 192 since we have non power
+ * of two cache sizes there. The size of larger slabs can be determined using
+ * fls.
+ */
+static s8 size_index[24] __cacheline_aligned = {
+	3,	/* 8 */
+	4,	/* 16 */
+	5,	/* 24 */
+	5,	/* 32 */
+	6,	/* 40 */
+	6,	/* 48 */
+	6,	/* 56 */
+	6,	/* 64 */
+#if L1_CACHE_BYTES < 64
+	1,	/* 72 */
+	1,	/* 80 */
+	1,	/* 88 */
+	1,	/* 96 */
+#else
+	7,
+	7,
+	7,
+	7,
+#endif
+	7,	/* 104 */
+	7,	/* 112 */
+	7,	/* 120 */
+	7,	/* 128 */
+#if L1_CACHE_BYTES < 128
+	2,	/* 136 */
+	2,	/* 144 */
+	2,	/* 152 */
+	2,	/* 160 */
+	2,	/* 168 */
+	2,	/* 176 */
+	2,	/* 184 */
+	2	/* 192 */
+#else
+	-1,
+	-1,
+	-1,
+	-1,
+	-1,
+	-1,
+	-1,
+	-1
+#endif
+};
+
+static struct kmem_cache *get_slab(size_t size, gfp_t flags)
+{
+	int index;
+
+#if L1_CACHE_BYTES >= 128
+	if (size <= 128) {
+#else
+	if (size <= 192) {
+#endif
+		if (unlikely(!size))
+			return ZERO_SIZE_PTR;
+
+		index = size_index[(size - 1) / 8];
+	} else
+		index = fls(size - 1);
+
+	if (unlikely((flags & SLQB_DMA)))
+		return &kmalloc_caches_dma[index];
+	else
+		return &kmalloc_caches[index];
+}
+
+static __always_inline void *____kmalloc(size_t size, gfp_t flags, int node, void *addr)
+{
+	struct kmem_cache *s;
+
+	s = get_slab(size, flags);
+
+	if (unlikely(ZERO_OR_NULL_PTR(s)))
+		return s;
+
+	return slab_alloc(s, flags, node, addr);
+}
+
+void *__kmalloc(size_t size, gfp_t flags)
+{
+	return ____kmalloc(size, flags, -1, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(__kmalloc);
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return ____kmalloc(size, flags, node, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(__kmalloc_node);
+#endif
+
+size_t ksize(const void *object)
+{
+	struct slqb_page *page;
+	struct kmem_cache *s;
+
+	BUG_ON(!object);
+	if (unlikely(object == ZERO_SIZE_PTR))
+		return 0;
+
+	page = virt_to_head_slqb_page(object);
+	BUG_ON(!PageSlab(page));
+
+	s = page->list->cache;
+
+	/*
+	 * Debugging requires use of the padding between object
+	 * and whatever may come after it.
+	 */
+	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
+		return s->objsize;
+
+	/*
+	 * If we have the need to store the freelist pointer
+	 * back there or track user information then we can
+	 * only use the space before that information.
+	 */
+	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+		return s->inuse;
+
+	/*
+	 * Else we can use all the padding etc for the allocation
+	 */
+	return s->size;
+}
+EXPORT_SYMBOL(ksize);
+
+void kfree(const void *object)
+{
+	struct kmem_cache *s;
+	struct page *p;
+	struct slqb_page *page;
+	unsigned long flags;
+
+	if (unlikely(ZERO_OR_NULL_PTR(object)))
+		return;
+
+	p = virt_to_page(object);
+	prefetch(p);
+	prefetchw(object);
+
+#ifdef CONFIG_SLQB_DEBUG
+	page = (struct slqb_page *)compound_head(p);
+	s = page->list->cache;
+	debug_check_no_locks_freed(object, s->objsize);
+	if (likely(object) && unlikely(slab_debug(s))) {
+		if (unlikely(!free_debug_processing(s, object, __builtin_return_address(0))))
+			return;
+	}
+#endif
+
+	local_irq_save(flags);
+#ifndef CONFIG_SLQB_DEBUG
+	page = (struct slqb_page *)compound_head(p);
+	s = page->list->cache;
+#endif
+	__slab_free(s, page, object);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(kfree);
+
+static void kmem_cache_trim_percpu(void *arg)
+{
+	int cpu = smp_processor_id();
+	struct kmem_cache *s = arg;
+	struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+	struct kmem_cache_list *l = &c->list;
+
+#ifdef CONFIG_SMP
+	claim_remote_free_list(s, l);
+#endif
+	flush_free_list(s, l);
+#ifdef CONFIG_SMP
+	flush_remote_free_cache(s, c);
+#endif
+}
+
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+#ifdef CONFIG_NUMA
+	int node;
+#endif
+
+	on_each_cpu(kmem_cache_trim_percpu, s, 1);
+
+#ifdef CONFIG_NUMA
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_list *l = &n->list;
+
+		spin_lock_irq(&n->list_lock);
+		claim_remote_free_list(s, l);
+		flush_free_list(s, l);
+		spin_unlock_irq(&n->list_lock);
+	}
+#endif
+
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
+
+#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
+static void kmem_cache_reap_percpu(void *arg)
+{
+	int cpu = smp_processor_id();
+	struct kmem_cache *s;
+	long phase = (long)arg;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+		struct kmem_cache_list *l = &c->list;
+
+		if (phase == 0) {
+			flush_free_list_all(s, l);
+			flush_remote_free_cache(s, c);
+		}
+
+		if (phase == 1) {
+			claim_remote_free_list(s, l);
+			flush_free_list_all(s, l);
+		}
+	}
+}
+
+static void kmem_cache_reap(void)
+{
+	struct kmem_cache *s;
+	int node;
+
+	down_read(&slqb_lock);
+	on_each_cpu(kmem_cache_reap_percpu, (void *)0, 1);
+	on_each_cpu(kmem_cache_reap_percpu, (void *)1, 1);
+
+	list_for_each_entry(s, &slab_caches, list) {
+		for_each_node_state(node, N_NORMAL_MEMORY) {
+			struct kmem_cache_node *n = s->node[node];
+			struct kmem_cache_list *l = &n->list;
+
+			spin_lock_irq(&n->list_lock);
+			claim_remote_free_list(s, l);
+			flush_free_list_all(s, l);
+			spin_unlock_irq(&n->list_lock);
+		}
+	}
+	up_read(&slqb_lock);
+}
+#endif
+
+static void cache_trim_worker(struct work_struct *w)
+{
+        struct delayed_work *work =
+                container_of(w, struct delayed_work, work);
+	struct kmem_cache *s;
+	int node;
+
+	if (!down_read_trylock(&slqb_lock))
+		goto out;
+
+	node = numa_node_id();
+	list_for_each_entry(s, &slab_caches, list) {
+#ifdef CONFIG_NUMA
+		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_list *l = &n->list;
+
+		spin_lock_irq(&n->list_lock);
+		claim_remote_free_list(s, l);
+		flush_free_list(s, l);
+		spin_unlock_irq(&n->list_lock);
+#endif
+
+		local_irq_disable();
+		kmem_cache_trim_percpu(s);
+		local_irq_enable();
+	}
+
+	up_read(&slqb_lock);
+out:
+	schedule_delayed_work(work, round_jiffies_relative(3*HZ));
+}
+
+static DEFINE_PER_CPU(struct delayed_work, cache_trim_work);
+
+static void __cpuinit start_cpu_timer(int cpu)
+{
+	struct delayed_work *cache_trim_work = &per_cpu(cache_trim_work, cpu);
+
+	/*
+	 * When this gets called from do_initcalls via cpucache_init(),
+	 * init_workqueues() has already run, so keventd will be setup
+	 * at that time.
+	 */
+        if (keventd_up() && cache_trim_work->work.func == NULL) {
+                INIT_DELAYED_WORK(cache_trim_work, cache_trim_worker);
+                schedule_delayed_work_on(cpu, cache_trim_work,
+                                        __round_jiffies_relative(HZ, cpu));
+        }
+}
+
+static int __init cpucache_init(void)
+{
+        int cpu;
+
+        for_each_online_cpu(cpu)
+                start_cpu_timer(cpu);
+        return 0;
+}
+__initcall(cpucache_init);
+
+
+#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
+static void slab_mem_going_offline_callback(void *arg)
+{
+	kmem_cache_reap();
+}
+
+static void slab_mem_offline_callback(void *arg)
+{
+	struct kmem_cache *s;
+	struct kmem_cache_node *n;
+	struct memory_notify *marg = arg;
+	int nid = marg->status_change_nid;
+
+	/*
+	 * If the node still has available memory. we need kmem_cache_node
+	 * for it yet.
+	 */
+	if (nid < 0)
+		return;
+
+#if 0 // XXX: see cpu offline comment
+	down_read(&slqb_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+		n = s->node[nid];
+		if (n) {
+			s->node[nid] = NULL;
+			kmem_cache_free(&kmem_node_cache, n);
+		}
+	}
+	up_read(&slqb_lock);
+#endif
+}
+
+static int slab_mem_going_online_callback(void *arg)
+{
+	struct kmem_cache *s;
+	struct kmem_cache_node *n;
+	struct memory_notify *marg = arg;
+	int nid = marg->status_change_nid;
+	int ret = 0;
+
+	/*
+	 * If the node's memory is already available, then kmem_cache_node is
+	 * already created. Nothing to do.
+	 */
+	if (nid < 0)
+		return 0;
+
+	/*
+	 * We are bringing a node online. No memory is availabe yet. We must
+	 * allocate a kmem_cache_node structure in order to bring the node
+	 * online.
+	 */
+	down_read(&slqb_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+		/*
+		 * XXX: kmem_cache_alloc_node will fallback to other nodes
+		 *      since memory is not yet available from the node that
+		 *      is brought up.
+		 */
+		n = kmem_cache_alloc(&kmem_node_cache, GFP_KERNEL);
+		if (!n) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		init_kmem_cache_node(s, n);
+		s->node[nid] = n;
+	}
+out:
+	up_read(&slqb_lock);
+	return ret;
+}
+
+static int slab_memory_callback(struct notifier_block *self,
+				unsigned long action, void *arg)
+{
+	int ret = 0;
+
+	switch (action) {
+	case MEM_GOING_ONLINE:
+		ret = slab_mem_going_online_callback(arg);
+		break;
+	case MEM_GOING_OFFLINE:
+		slab_mem_going_offline_callback(arg);
+		break;
+	case MEM_OFFLINE:
+	case MEM_CANCEL_ONLINE:
+		slab_mem_offline_callback(arg);
+		break;
+	case MEM_ONLINE:
+	case MEM_CANCEL_OFFLINE:
+		break;
+	}
+
+	ret = notifier_from_errno(ret);
+	return ret;
+}
+
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
+/********************************************************************
+ *			Basic setup of slabs
+ *******************************************************************/
+
+void __init kmem_cache_init(void)
+{
+	int i;
+	unsigned int flags = SLAB_HWCACHE_ALIGN|SLAB_PANIC;
+
+#ifdef CONFIG_NUMA
+	if (num_possible_nodes() == 1)
+		numa_platform = 0;
+#endif
+
+#ifdef CONFIG_SMP
+	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
+				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
+#else
+	kmem_size = sizeof(struct kmem_cache);
+#endif
+
+	kmem_cache_open(&kmem_cache_cache, "kmem_cache", kmem_size, 0, flags, NULL, 0);
+#ifdef CONFIG_SMP
+	kmem_cache_open(&kmem_cpu_cache, "kmem_cache_cpu", sizeof(struct kmem_cache_cpu), 0, flags, NULL, 0);
+#endif
+#ifdef CONFIG_NUMA
+	kmem_cache_open(&kmem_node_cache, "kmem_cache_node", sizeof(struct kmem_cache_node), 0, flags, NULL, 0);
+#endif
+
+#ifdef CONFIG_SMP
+	for_each_possible_cpu(i) {
+		init_kmem_cache_cpu(&kmem_cache_cache, &kmem_cache_cpus[i]);
+		kmem_cache_cache.cpu_slab[i] = &kmem_cache_cpus[i];
+
+		init_kmem_cache_cpu(&kmem_cpu_cache, &kmem_cpu_cpus[i]);
+		kmem_cpu_cache.cpu_slab[i] = &kmem_cpu_cpus[i];
+
+#ifdef CONFIG_NUMA
+		init_kmem_cache_cpu(&kmem_node_cache, &kmem_node_cpus[i]);
+		kmem_node_cache.cpu_slab[i] = &kmem_node_cpus[i];
+#endif
+	}
+#else
+	init_kmem_cache_cpu(&kmem_cache_cache, &kmem_cache_cache.cpu_slab);
+#endif
+
+#ifdef CONFIG_NUMA
+	for_each_node_state(i, N_NORMAL_MEMORY) {
+		init_kmem_cache_node(&kmem_cache_cache, &kmem_cache_nodes[i]);
+		kmem_cache_cache.node[i] = &kmem_cache_nodes[i];
+
+		init_kmem_cache_node(&kmem_cpu_cache, &kmem_cpu_nodes[i]);
+		kmem_cpu_cache.node[i] = &kmem_cpu_nodes[i];
+
+		init_kmem_cache_node(&kmem_node_cache, &kmem_node_nodes[i]);
+		kmem_node_cache.node[i] = &kmem_node_nodes[i];
+	}
+#endif
+
+	/* Caches that are not of the two-to-the-power-of size */
+	if (L1_CACHE_BYTES < 64 && KMALLOC_MIN_SIZE <= 64) {
+		open_kmalloc_cache(&kmalloc_caches[1],
+				"kmalloc-96", 96, GFP_KERNEL);
+#ifdef CONFIG_ZONE_DMA
+		open_kmalloc_cache(&kmalloc_caches_dma[1],
+				"kmalloc_dma-96", 96, GFP_KERNEL|SLQB_DMA);
+#endif
+	}
+	if (L1_CACHE_BYTES < 128 && KMALLOC_MIN_SIZE <= 128) {
+		open_kmalloc_cache(&kmalloc_caches[2],
+				"kmalloc-192", 192, GFP_KERNEL);
+#ifdef CONFIG_ZONE_DMA
+		open_kmalloc_cache(&kmalloc_caches_dma[2],
+				"kmalloc_dma-192", 192, GFP_KERNEL|SLQB_DMA);
+#endif
+	}
+
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_SLQB_HIGH; i++) {
+		open_kmalloc_cache(&kmalloc_caches[i],
+			"kmalloc", 1 << i, GFP_KERNEL);
+#ifdef CONFIG_ZONE_DMA
+		open_kmalloc_cache(&kmalloc_caches_dma[i],
+				"kmalloc_dma", 1 << i, GFP_KERNEL|SLQB_DMA);
+#endif
+	}
+
+
+	/*
+	 * Patch up the size_index table if we have strange large alignment
+	 * requirements for the kmalloc array. This is only the case for
+	 * mips it seems. The standard arches will not generate any code here.
+	 *
+	 * Largest permitted alignment is 256 bytes due to the way we
+	 * handle the index determination for the smaller caches.
+	 *
+	 * Make sure that nothing crazy happens if someone starts tinkering
+	 * around with ARCH_KMALLOC_MINALIGN
+	 */
+	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
+		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
+
+	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
+		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;
+
+	/* Provide the correct kmalloc names now that the caches are up */
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_SLQB_HIGH; i++) {
+		kmalloc_caches[i].name =
+			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
+#ifdef CONFIG_ZONE_DMA
+		kmalloc_caches_dma[i].name =
+			kasprintf(GFP_KERNEL, "kmalloc_dma-%d", 1 << i);
+#endif
+	}
+
+#ifdef CONFIG_SMP
+	register_cpu_notifier(&slab_notifier);
+#endif
+#ifdef CONFIG_NUMA
+	hotplug_memory_notifier(slab_memory_callback, 1);
+#endif
+	/*
+	 * smp_init() has not yet been called, so no worries about memory
+	 * ordering here (eg. slab_is_available vs numa_platform)
+	 */
+	__slab_is_available = 1;
+}
+
+struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+		size_t align, unsigned long flags, void (*ctor)(void *))
+{
+	struct kmem_cache *s;
+
+	s = kmem_cache_alloc(&kmem_cache_cache, GFP_KERNEL);
+	if (!s)
+		goto err;
+
+	if (kmem_cache_open(s, name, size, align, flags, ctor, 1))
+		return s;
+
+	kmem_cache_free(&kmem_cache_cache, s);
+
+err:
+	if (flags & SLAB_PANIC)
+		panic("kmem_cache_create(): failed to create slab `%s'\n",name);
+	return NULL;
+}
+EXPORT_SYMBOL(kmem_cache_create);
+
+#ifdef CONFIG_SMP
+/*
+ * Use the cpu notifier to insure that the cpu slabs are flushed when
+ * necessary.
+ */
+static int __cpuinit slab_cpuup_callback(struct notifier_block *nfb,
+		unsigned long action, void *hcpu)
+{
+	long cpu = (long)hcpu;
+	struct kmem_cache *s;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		down_read(&slqb_lock);
+		list_for_each_entry(s, &slab_caches, list) {
+			s->cpu_slab[cpu] = alloc_kmem_cache_cpu(s, cpu);
+			if (!s->cpu_slab[cpu]) {
+				up_read(&slqb_lock);
+				return NOTIFY_BAD;
+			}
+		}
+		up_read(&slqb_lock);
+		break;
+
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+	case CPU_DOWN_FAILED:
+	case CPU_DOWN_FAILED_FROZEN:
+		start_cpu_timer(cpu);
+		break;
+
+	case CPU_DOWN_PREPARE:
+	case CPU_DOWN_PREPARE_FROZEN:
+		cancel_rearming_delayed_work(&per_cpu(cache_trim_work, cpu));
+		per_cpu(cache_trim_work, cpu).work.func = NULL;
+		break;
+
+	case CPU_UP_CANCELED:
+	case CPU_UP_CANCELED_FROZEN:
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+#if 0
+		down_read(&slqb_lock);
+		/* XXX: this doesn't work because objects can still be on this
+		 * CPU's list. periodic timer needs to check if a CPU is offline
+		 * and then try to cleanup from there. Same for node offline.
+		 */
+		list_for_each_entry(s, &slab_caches, list) {
+			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+			if (c) {
+				kmem_cache_free(&kmem_cpu_cache, c);
+				s->cpu_slab[cpu] = NULL;
+			}
+		}
+
+		up_read(&slqb_lock);
+#endif
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block __cpuinitdata slab_notifier = {
+	.notifier_call = slab_cpuup_callback
+};
+
+#endif
+
+#ifdef CONFIG_SLQB_DEBUG
+void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, void *caller)
+{
+	return ____kmalloc(size, gfpflags, -1, caller);
+}
+
+void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
+					int node, void *caller)
+{
+	return ____kmalloc(size, gfpflags, node, caller);
+}
+#endif
+
+/*
+ * The /proc/slabinfo ABI
+ */
+#ifdef CONFIG_SLABINFO
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+ssize_t slabinfo_write(struct file *file, const char __user * buffer,
+                       size_t count, loff_t *ppos)
+{
+	return -EINVAL;
+}
+
+
+static void print_slabinfo_header(struct seq_file *m)
+{
+	seq_puts(m, "slabinfo - version: 2.1\n");
+	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> "
+		 "<objperslab> <pagesperslab>");
+	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
+	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
+	seq_putc(m, '\n');
+}
+
+static void *s_start(struct seq_file *m, loff_t *pos)
+{
+	loff_t n = *pos;
+
+	down_read(&slqb_lock);
+	if (!n)
+		print_slabinfo_header(m);
+
+	return seq_list_start(&slab_caches, *pos);
+}
+
+static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	return seq_list_next(p, &slab_caches, pos);
+}
+
+static void s_stop(struct seq_file *m, void *p)
+{
+	up_read(&slqb_lock);
+}
+
+struct stats_gather {
+	struct kmem_cache *s;
+	spinlock_t lock;
+	unsigned long nr_slabs;
+	unsigned long nr_partial;
+	unsigned long nr_inuse;
+};
+
+static void gather_stats(void *arg)
+{
+	unsigned long nr_slabs;
+	unsigned long nr_partial;
+	unsigned long nr_inuse;
+	struct stats_gather *gather = arg;
+	int cpu = smp_processor_id();
+	struct kmem_cache *s = gather->s;
+	struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+	struct kmem_cache_list *l = &c->list;
+	struct slqb_page *page;
+
+	nr_slabs = l->nr_slabs;
+	nr_partial = l->nr_partial;
+	nr_inuse = (nr_slabs - nr_partial) * s->objects;
+
+	list_for_each_entry(page, &l->partial, lru) {
+		nr_inuse += page->inuse;
+	}
+
+	spin_lock(&gather->lock);
+	gather->nr_slabs += nr_slabs;
+	gather->nr_partial += nr_partial;
+	gather->nr_inuse += nr_inuse;
+	spin_unlock(&gather->lock);
+}
+
+static int s_show(struct seq_file *m, void *p)
+{
+	struct stats_gather stats;
+	unsigned long nr_objs;
+	struct kmem_cache *s;
+#ifdef CONFIG_NUMA
+	int node;
+#endif
+
+	s = list_entry(p, struct kmem_cache, list);
+
+	stats.s = s;
+	spin_lock_init(&stats.lock);
+	stats.nr_slabs = 0;
+	stats.nr_partial = 0;
+	stats.nr_inuse = 0;
+
+	on_each_cpu(gather_stats, &stats, 1);
+
+#ifdef CONFIG_NUMA
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_list *l = &n->list;
+		struct slqb_page *page;
+		unsigned long flags;
+
+		spin_lock_irqsave(&n->list_lock, flags);
+		stats.nr_slabs += l->nr_slabs;
+		stats.nr_partial += l->nr_partial;
+		stats.nr_inuse += (l->nr_slabs - l->nr_partial) * s->objects;
+
+		list_for_each_entry(page, &l->partial, lru) {
+			stats.nr_inuse += page->inuse;
+		}
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+#endif
+
+	nr_objs = stats.nr_slabs * s->objects;
+
+	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, stats.nr_inuse,
+		   nr_objs, s->size, s->objects, (1 << s->order));
+	seq_printf(m, " : tunables %4u %4u %4u", s->batch, 0, 0);
+	seq_printf(m, " : slabdata %6lu %6lu %6lu", stats.nr_slabs, stats.nr_slabs,
+		   0UL);
+	seq_putc(m, '\n');
+	return 0;
+}
+
+static const struct seq_operations slabinfo_op = {
+	.start = s_start,
+	.next = s_next,
+	.stop = s_stop,
+	.show = s_show,
+};
+
+static int slabinfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &slabinfo_op);
+}
+
+static const struct file_operations proc_slabinfo_operations = {
+	.open		= slabinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int __init slab_proc_init(void)
+{
+	proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
+	return 0;
+}
+module_init(slab_proc_init);
+#endif /* CONFIG_SLABINFO */
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -150,6 +150,8 @@ size_t ksize(const void *);
  */
 #ifdef CONFIG_SLUB
 #include <linux/slub_def.h>
+#elif defined(CONFIG_SLQB)
+#include <linux/slqb_def.h>
 #elif defined(CONFIG_SLOB)
 #include <linux/slob_def.h>
 #else
@@ -252,7 +254,7 @@ static inline void *kmem_cache_alloc_nod
  * allocator where we care about the real place the memory allocation
  * request comes from.
  */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || defined(CONFIG_SLQB_DEBUG)
 extern void *__kmalloc_track_caller(size_t, gfp_t, void*);
 #define kmalloc_track_caller(size, flags) \
 	__kmalloc_track_caller(size, flags, __builtin_return_address(0))
@@ -270,7 +272,7 @@ extern void *__kmalloc_track_caller(size
  * standard allocator where we care about the real place the memory
  * allocation request comes from.
  */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || defined (CONFIG_SLQB_DEBUG)
 extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
 #define kmalloc_node_track_caller(size, flags, node) \
 	__kmalloc_node_track_caller(size, flags, node, \
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -28,6 +28,7 @@ obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_MMU_NOTIFIER) += mmu_notifier.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_SLUB) += slub.o
+obj-$(CONFIG_SLQB) += slqb.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
Index: linux-2.6/include/linux/rcu_types.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/rcu_types.h
@@ -0,0 +1,18 @@
+#ifndef __LINUX_RCU_TYPES_H
+#define __LINUX_RCU_TYPES_H
+
+#ifdef __KERNEL__
+
+/**
+ * struct rcu_head - callback structure for use with RCU
+ * @next: next update requests in a list
+ * @func: actual update function to call after the grace period.
+ */
+struct rcu_head {
+	struct rcu_head *next;
+	void (*func)(struct rcu_head *head);
+};
+
+#endif
+
+#endif
Index: linux-2.6/include/linux/vmstat.h
===================================================================
--- linux-2.6.orig/include/linux/vmstat.h
+++ linux-2.6/include/linux/vmstat.h
@@ -51,6 +51,22 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
 		UNEVICTABLE_MLOCKFREED,
 #endif
+		SLQB_ALLOC,
+		SLQB_ALLOC_FROM_PAGE,
+		SLQB_OFFNODE_ALLOC,
+		SLQB_FREE,
+		SLQB_REMOTE_FREE,
+		SLQB_OFFNODE_FREE,
+		SLQB_FLUSH_REMOTE_FREE_CACHE,
+		SLQB_CLAIM_REMOTE_FREE_CACHE,
+		SLQB_FLUSH_FREE_LIST,
+		SLQB_PAGE_FREE_PARTIAL,
+		SLQB_PAGE_FREE_EMPTY,
+		SLQB_PAGE_ALLOC_PARTIAL,
+		SLQB_PAGE_ALLOC_FULL,
+		SLQB_PAGE_ALLOC,
+		SLQB_PAGE_FREE,
+
 		NR_VM_EVENT_ITEMS
 };
 
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c
+++ linux-2.6/mm/vmstat.c
@@ -716,6 +716,21 @@ static const char * const vmstat_text[]
 	"unevictable_pgs_mlockfreed",
 #endif
 #endif
+	"slqb_alloc",
+	"slqb_alloc_from_page",
+	"slqb_offnode_alloc",
+	"slqb_free",
+	"slqb_remote_free",
+	"slqb_offnode_free",
+	"slqb_flush_remote_free_cache",
+	"slqb_claim_remote_free_cache",
+	"slqb_flush_free_list",
+	"slqb_page_free_partial",
+	"slqb_page_free_empty",
+	"slqb_page_alloc_partial",
+	"slqb_page_alloc_full",
+	"slqb_page_alloc",
+	"slqb_page_free",
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
Index: linux-2.6/arch/x86/include/asm/page.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/page.h
+++ linux-2.6/arch/x86/include/asm/page.h
@@ -194,6 +194,7 @@ static inline pteval_t native_pte_flags(
  * virt_addr_valid(kaddr) returns true.
  */
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
+#define virt_to_page_fast(kaddr) pfn_to_page(((unsigned long)(kaddr) - PAGE_OFFSET) >> PAGE_SHIFT)
 #define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
 extern bool __virt_addr_valid(unsigned long kaddr);
 #define virt_addr_valid(kaddr)	__virt_addr_valid((unsigned long) (kaddr))
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -299,7 +299,11 @@ static inline void get_page(struct page
 
 static inline struct page *virt_to_head_page(const void *x)
 {
+#ifdef virt_to_page_fast
+	struct page *page = virt_to_page_fast(x);
+#else
 	struct page *page = virt_to_page(x);
+#endif
 	return compound_head(page);
 }
 
