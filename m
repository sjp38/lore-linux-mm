Date: Thu, 10 Apr 2008 21:31:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] SLQB v2
Message-ID: <20080410193137.GB9482@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

SLQB slab allocator for mainline.

This version fixes compiles on UP and had minor code cleanups.

---

Index: linux-2.6/include/linux/rcupdate.h
===================================================================
--- linux-2.6.orig/include/linux/rcupdate.h
+++ linux-2.6/include/linux/rcupdate.h
@@ -35,6 +35,7 @@
 
 #ifdef __KERNEL__
 
+#include <linux/rcu_types.h>
 #include <linux/cache.h>
 #include <linux/spinlock.h>
 #include <linux/threads.h>
@@ -43,16 +44,6 @@
 #include <linux/seqlock.h>
 #include <linux/lockdep.h>
 
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
Index: linux-2.6/arch/x86/kernel/nmi_64.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/nmi_64.c
+++ linux-2.6/arch/x86/kernel/nmi_64.c
@@ -28,7 +28,7 @@
 
 int unknown_nmi_panic;
 int nmi_watchdog_enabled;
-int panic_on_unrecovered_nmi;
+int panic_on_unrecovered_nmi = 1;
 
 static cpumask_t backtrace_mask = CPU_MASK_NONE;
 
Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/slqb_def.h
@@ -0,0 +1,264 @@
+#ifndef _LINUX_SLQB_DEF_H
+#define _LINUX_SLQB_DEF_H
+
+/*
+ * SLQB : A slab allocator with object queues.
+ *
+ * (C) 2008 Nick Piggin <npiggin@suse.de>
+ * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/types.h>
+#include <linux/gfp.h>
+#include <linux/workqueue.h>
+#include <linux/kobject.h>
+#include <linux/rcu_types.h>
+#include <linux/mm_types.h>
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
+/*
+ * We use struct slqb_page fields to manage some slob allocation aspects,
+ * however to avoid the horrible mess in include/linux/mm_types.h, we'll
+ * just define our own struct slqb_page type variant here.
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
+{ BUILD_BUG_ON(sizeof(struct slqb_page) != sizeof(struct slqb_page)); }
+
+struct kmlist {
+	void **head, **tail;
+};
+
+struct kmem_cache_remote_free {
+	spinlock_t lock;
+	unsigned long nr;
+	struct kmlist list[4];
+} ____cacheline_aligned;
+
+struct kmem_cache_list {
+	struct kmem_cache *cache;
+
+	unsigned long nr_partial;
+	unsigned long nr_free;
+	struct list_head partial;
+	struct list_head free;
+
+	int remote_free_check;
+
+	unsigned long nr_slabs;
+	struct list_head full;
+
+
+	struct kmem_cache_remote_free remote_free;
+};
+
+struct kmem_cache_cpu {
+	struct kmem_cache_list list;
+
+	unsigned long remote_nr;
+	struct kmlist remote_list[4];
+	struct kmem_cache_list *remote_cache_list;
+
+#ifdef CONFIG_SLQB_STATS
+	unsigned stat[NR_SLQB_STAT_ITEMS];
+#endif
+} ____cacheline_aligned;
+
+struct kmem_cache_node {
+	spinlock_t list_lock;	/* Protect partial list and nr_partial */
+	struct kmem_cache_list list;
+} ____cacheline_aligned;
+
+/*
+ * Slab cache management.
+ */
+struct kmem_cache {
+	/* Used for retriving partial slabs etc */
+	unsigned long flags;
+	int size;		/* The size of an object including meta data */
+	int objsize;		/* The size of an object without meta data */
+	int offset;		/* Free pointer offset. */
+	int order;
+
+	/* Allocation and freeing of slabs */
+	int objects;		/* Number of objects in slab */
+	gfp_t allocflags;	/* gfp flags to use on each alloc */
+	int refcount;		/* Refcount for slab cache destroy */
+	void (*ctor)(struct kmem_cache *, void *);
+	int inuse;		/* Offset to metadata */
+	int align;		/* Alignment */
+	const char *name;	/* Name (only for display!) */
+	struct list_head list;	/* List of slab caches */
+#ifdef CONFIG_SLQB_DEBUG
+	struct kobject kobj;	/* For sysfs */
+#endif
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
+#define KMALLOC_SHIFT_SLQB_HIGH (PAGE_SHIFT + 5)
+
+/*
+ * We keep the general caches in an array of slab caches that are used for
+ * 2^x bytes of allocations.
+ */
+extern struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_SLQB_HIGH + 1];
+
+/*
+ * Sorry that the following has to be that ugly but some versions of GCC
+ * have trouble with constant propagation and loops.
+ */
+static __always_inline int kmalloc_index(size_t size)
+{
+	if (!size)
+		return 0;
+
+	if (size <= KMALLOC_MIN_SIZE)
+		return KMALLOC_SHIFT_LOW;
+
+	if (size > 64 && size <= 96)
+		return 1;
+	if (size > 128 && size <= 192)
+		return 2;
+	if (size <=          8) return 3;
+	if (size <=         16) return 4;
+	if (size <=         32) return 5;
+	if (size <=         64) return 6;
+	if (size <=        128) return 7;
+	if (size <=        256) return 8;
+	if (size <=        512) return 9;
+	if (size <=       1024) return 10;
+	if (size <=   2 * 1024) return 11;
+/*
+ * The following is only needed to support architectures with a larger page
+ * size than 4k.
+ */
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
+/*
+ * Find the slab cache for a given combination of allocation flags and size.
+ *
+ * This ought to end up with a global pointer to the right cache
+ * in kmalloc_caches.
+ */
+static __always_inline struct kmem_cache *kmalloc_slab(size_t size)
+{
+	int index = kmalloc_index(size);
+
+	if (index == 0)
+		return NULL;
+
+	return &kmalloc_caches[index];
+}
+
+#ifdef CONFIG_ZONE_DMA
+#define SLQB_DMA __GFP_DMA
+#else
+/* Disable DMA functionality */
+#define SLQB_DMA (__force gfp_t)0
+#endif
+
+void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
+void *__kmalloc(size_t size, gfp_t flags);
+
+static __always_inline void *kmalloc(size_t size, gfp_t flags)
+{
+	if (__builtin_constant_p(size)) {
+		if (likely(!(flags & SLQB_DMA))) {
+			struct kmem_cache *s = kmalloc_slab(size);
+			if (!s)
+				return ZERO_SIZE_PTR;
+			return kmem_cache_alloc(s, flags);
+		}
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
+		if (likely(!(flags & SLQB_DMA))) {
+			struct kmem_cache *s = kmalloc_slab(size);
+			if (!s)
+				return ZERO_SIZE_PTR;
+			return kmem_cache_alloc_node(s, flags, node);
+		}
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
@@ -701,6 +701,11 @@ config SLUB_DEBUG
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
@@ -724,6 +729,9 @@ config SLUB
 	   of queues of objects. SLUB can use memory efficiently
 	   and has enhanced diagnostics.
 
+config SLQB
+	bool "SLQB (Qeued allocator)"
+
 config SLOB
 	depends on EMBEDDED
 	bool "SLOB (Simple Allocator)"
@@ -763,7 +771,7 @@ endmenu		# General setup
 config SLABINFO
 	bool
 	depends on PROC_FS
-	depends on SLAB || SLUB
+	depends on SLAB || SLUB || SLQB
 	default y
 
 config RT_MUTEXES
Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug
+++ linux-2.6/lib/Kconfig.debug
@@ -221,6 +221,16 @@ config SLUB_STATS
 	  out which slabs are relevant to a particular load.
 	  Try running: slabinfo -DA
 
+config SLQB_DEBUG_ON
+	bool "SLQB debugging on by default"
+	depends on SLQB_DEBUG
+	default n
+
+config SLQB_STATS
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
@@ -0,0 +1,4027 @@
+/*
+ * SLQB: A slab allocator that focuses on per-CPU scaling, and good performance
+ * with order-0 allocations. Fastpaths emphasis is placed on local allocaiton
+ * and freeing, and remote freeing (freeing on another CPU from that which
+ * allocated).
+ *
+ * Using ideas from mm/slab.c, mm/slob.c, and mm/slub.c,
+ *
+ * And parts of code from mm/slub.c
+ * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
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
+ * Lock order:
+ *   1. kmem_cache_node->list_lock
+ *    2. kmem_cache_remote_free->lock
+ *
+ *   Interrupts are disabled during allocation and deallocation in order to
+ *   make the slab allocator safe to use in the context of an irq. In addition
+ *   interrupts are disabled to ensure that the processor does not change
+ *   while handling per_cpu slabs, due to kernel preemption.
+ *
+ * SLIB assigns one slab for allocation to each processor.
+ * Allocations only occur from these slabs called cpu slabs.
+ *
+ * Slabs with free elements are kept on a partial list and during regular
+ * operations no list for full slabs is used. If an object in a full slab is
+ * freed then the slab will show up again on the partial lists.
+ * We track full slabs for debugging purposes though because otherwise we
+ * cannot scan all objects.
+ *
+ * Slabs are freed when they become empty. Teardown and setup is
+ * minimal so we rely on the page allocators per cpu caches for
+ * fast frees and allocs.
+ */
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
+	return page_to_nid(virt_to_page(addr));
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
+	__SetPageSlab(p);
+
+	return (struct slqb_page *)p;
+}
+
+static inline void put_slqb_page(struct slqb_page *page)
+{
+	put_page(&page->page);
+}
+
+static inline void __free_slqb_pages(struct slqb_page *page, unsigned int order)
+{
+	struct page *p = &page->page;
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
+#define DEFAULT_MAX_ORDER 1
+#define DEFAULT_MIN_OBJECTS 1
+
+#define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
+				SLAB_POISON | SLAB_STORE_USER)
+
+/*
+ * Set of flags that will prevent slab merging
+ */
+#define SLQB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+		SLAB_TRACE | SLAB_DESTROY_BY_RCU)
+
+#define SLQB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
+		SLAB_CACHE_DMA)
+
+#ifndef ARCH_KMALLOC_MINALIGN
+#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
+#endif
+
+#ifndef ARCH_SLAB_MINALIGN
+#define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
+#endif
+
+/* Internal SLQB flags */
+#define __OBJECT_POISON		0x80000000 /* Poison object */
+#define __SYSFS_ADD_DEFERRED	0x40000000 /* Not yet visible via sysfs */
+#define __KMALLOC_CACHE		0x20000000 /* objects freed using kfree */
+
+/* Not all arches define cache_line_size */
+#ifndef cache_line_size
+#define cache_line_size()	L1_CACHE_BYTES
+#endif
+
+static int kmem_size = sizeof(struct kmem_cache);
+
+#ifdef CONFIG_SMP
+static struct notifier_block slab_notifier;
+#endif
+
+static enum {
+	DOWN,		/* No slab functionality available */
+	PARTIAL,	/* kmem_cache_open() works but kmalloc does not */
+	UP,		/* Everything works but does not show up in sysfs */
+	SYSFS		/* Sysfs up */
+} slab_state = DOWN;
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
+#if defined(CONFIG_SYSFS) && defined(CONFIG_SLQB_DEBUG)
+static int sysfs_slab_add(struct kmem_cache *);
+static int sysfs_slab_alias(struct kmem_cache *, const char *);
+static void sysfs_slab_remove(struct kmem_cache *);
+
+#else
+static inline int sysfs_slab_add(struct kmem_cache *s) { return 0; }
+static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
+							{ return 0; }
+static inline void sysfs_slab_remove(struct kmem_cache *s)
+{
+	kfree(s);
+}
+
+#endif
+
+static inline void stat(struct kmem_cache_cpu *c, enum stat_item si)
+{
+#ifdef CONFIG_SLQB_STATS
+	c->stat[si]++;
+#endif
+}
+
+/********************************************************************
+ * 			Core slab cache functions
+ *******************************************************************/
+
+int slab_is_available(void)
+{
+	return slab_state >= UP;
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
+/*
+ * Slow version of get and set free pointer.
+ *
+ * This version requires touching the cache lines of kmem_cache which
+ * we avoid to do in the fast alloc free paths. There we obtain the offset
+ * from the page struct.
+ */
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
+static int slqb_debug = DEBUG_DEFAULT_FLAGS;
+#else
+static int slqb_debug;
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
+ *
+ * If slabcaches are merged then the objsize and inuse boundaries are mostly
+ * ignored. And therefore no slab options that rely on these boundaries
+ * may be used with merged slabcaches.
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
+	if (unlikely(s != page->list->cache)) {
+		if (!PageSlab(page)) {
+			slab_err(s, page, "Attempt to free object(0x%p) "
+				"outside of slab", object);
+		} else if (!page->list->cache) {
+			printk(KERN_ERR
+				"SLQB <none>: no slab for object 0x%p.\n",
+						object);
+			dump_stack();
+		} else
+			object_err(s, page, object,
+					"page slab pointer corrupt.");
+		goto fail;
+	}
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
+	void (*ctor)(struct kmem_cache *, void *))
+{
+	/*
+	 * The page->offset field is only 16 bit wide. This is an offset
+	 * in units of words from the beginning of an object. If the slab
+	 * size is bigger then we cannot move the free pointer behind the
+	 * object anymore.
+	 *
+	 * On 32 bit platforms the limit is 256k. On 64bit platforms
+	 * the limit is 512k.
+	 *
+	 * Debugging or ctor may create a need to move the free
+	 * pointer. Fail if this happens.
+	 */
+	if (objsize >= 65535 * sizeof(void *)) {
+		BUG_ON(flags & (SLAB_RED_ZONE | SLAB_POISON |
+				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
+		BUG_ON(ctor);
+	} else {
+		/*
+		 * Enable debugging if selected on the kernel commandline.
+		 */
+		if (slqb_debug && (!slqb_debug_slabs ||
+		    strncmp(slqb_debug_slabs, name,
+			strlen(slqb_debug_slabs)) == 0))
+				flags |= slqb_debug;
+	}
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
+	unsigned long flags, const char *name,
+	void (*ctor)(struct kmem_cache *, void *))
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
+		s->ctor(s, object);
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
+#if 0
+/*
+ * Try to allocate a partial slab from a specific node.
+ */
+static struct slqb_page *get_partial_node(struct kmem_cache_node *n)
+{
+	struct slqb_page *page;
+
+	/*
+	 * Racy check. If we mistakenly see no partial slabs then we
+	 * just allocate an empty slab. If we mistakenly try to get a
+	 * partial slab and there is none available then get_partials()
+	 * will return NULL.
+	 */
+	if (!n || !n->nr_partial)
+		return NULL;
+
+	spin_lock(&n->list_lock);
+	list_for_each_entry(page, &n->partial, lru)
+		if (lock_and_freeze_slab(n, page))
+			goto out;
+	page = NULL;
+out:
+	spin_unlock(&n->list_lock);
+	return page;
+}
+
+/*
+ * Get a page from somewhere. Search in increasing NUMA distances.
+ */
+static struct slqb_page *get_any_partial(struct kmem_cache *s, gfp_t flags)
+{
+#ifdef CONFIG_NUMA
+	struct zonelist *zonelist;
+	struct zone **z;
+	struct slqb_page *page;
+
+	/*
+	 * The defrag ratio allows a configuration of the tradeoffs between
+	 * inter node defragmentation and node local allocations. A lower
+	 * defrag_ratio increases the tendency to do local allocations
+	 * instead of attempting to obtain partial slabs from other nodes.
+	 *
+	 * If the defrag_ratio is set to 0 then kmalloc() always
+	 * returns node local objects. If the ratio is higher then kmalloc()
+	 * may return off node objects because partial slabs are obtained
+	 * from other nodes and filled up.
+	 *
+	 * If /sys/slab/xx/defrag_ratio is set to 100 (which makes
+	 * defrag_ratio = 1000) then every (well almost) allocation will
+	 * first attempt to defrag slab caches on other nodes. This means
+	 * scanning over all nodes to look for partial slabs which may be
+	 * expensive if we do it every time we are trying to find a slab
+	 * with available objects.
+	 */
+	if (!s->remote_node_defrag_ratio ||
+			get_cycles() % 1024 > s->remote_node_defrag_ratio)
+		return NULL;
+
+	zonelist = &NODE_DATA(
+		slab_node(current->mempolicy))->node_zonelists[gfp_zone(flags)];
+	for (z = zonelist->zones; *z; z++) {
+		struct kmem_cache_node *n;
+
+		n = get_node(s, zone_to_nid(*z));
+
+		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
+				n->nr_partial > MIN_PARTIAL) {
+			page = get_partial_node(n);
+			if (page)
+				return page;
+		}
+	}
+#endif
+	return NULL;
+}
+
+/*
+ * Get a partial page, lock it and return it.
+ */
+static struct slqb_page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct slqb_page *page;
+	int searchnode = (node == -1) ? numa_node_id() : node;
+
+	page = get_partial_node(get_node(s, searchnode));
+	if (page || (flags & __GFP_THISNODE))
+		return page;
+
+	return get_any_partial(s, flags);
+}
+#endif
+
+static void kmem_cache_free_free(struct kmem_cache *s, struct kmem_cache_list *l, int save)
+{
+	/* Could splice off the list and run outside lock */
+	while (l->nr_free > save) {
+		struct slqb_page *page;
+		page = list_entry(l->free.prev, struct slqb_page, lru);
+		list_del(&page->lru);
+		free_slab(s, page);
+		l->nr_slabs--;
+		l->nr_free--;
+	}
+}
+
+static __always_inline void free_object_to_page(struct kmem_cache *s, struct kmem_cache_list *l, struct slqb_page *page, void *object, int local)
+{
+	set_freepointer(s, object, page->freelist);
+	page->freelist = object;
+	page->inuse--;
+
+	if (unlikely(!page->inuse)) {
+		l->nr_free++;
+		if (likely(s->objects > 1)) {
+			l->nr_partial--;
+			list_del(&page->lru);
+		}
+		if (local)
+			list_add(&page->lru, &l->free);
+		else
+			list_add_tail(&page->lru, &l->free);
+	} else if (unlikely(page->inuse + 1 == s->objects)) {
+		l->nr_partial++;
+		if (local)
+			list_add(&page->lru, &l->partial);
+		else
+			list_add_tail(&page->lru, &l->partial);
+	}
+}
+
+static void flush_remote_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	void **head[4], **object;
+	struct slqb_page *page;
+	int nr, i;
+	int local;
+
+	VM_BUG_ON(!l->remote_free.list[0].head != !l->remote_free.list[0].tail);
+	VM_BUG_ON(!l->remote_free.list[1].head != !l->remote_free.list[1].tail);
+	VM_BUG_ON(!l->remote_free.list[2].head != !l->remote_free.list[2].tail);
+	VM_BUG_ON(!l->remote_free.list[3].head != !l->remote_free.list[3].tail);
+
+	nr = l->remote_free.nr;
+	if (!nr)
+		return;
+
+	prefetch(&l->remote_free.lock);
+	for (i = 0; i < 4; i++) {
+		object = l->remote_free.list[i].head;
+		if (!object)
+			break;
+		prefetch(((void *)object) + s->offset);
+		page = virt_to_head_slqb_page(object);
+		prefetch(page);
+	}
+
+	spin_lock(&l->remote_free.lock);
+	for (i = 0; i < 4; i++) {
+		head[i] = l->remote_free.list[i].head;
+		l->remote_free.list[i].head = NULL;
+		l->remote_free.list[i].tail = NULL;
+	}
+	l->remote_free_check = 0;
+	nr = l->remote_free.nr;
+	l->remote_free.nr = 0;
+	spin_unlock(&l->remote_free.lock);
+
+	local = 0;
+	if (s->size < cache_line_size()*2)
+		local = 1;
+
+	i = 0;
+	for (;;) {
+		int j;
+
+		for (j = 0; j < 4; j++) {
+
+			if (i + j == nr)
+				return;
+			object = head[j];
+			head[j] = get_freepointer(s, object);
+			page = virt_to_head_slqb_page(object);
+
+			free_object_to_page(s, l, page, object, local);
+		}
+
+		i += 4;
+
+		for (j = 0; j < 4; j++) {
+			if (i + j == nr)
+				break;
+			object = head[j];
+			prefetch(((void *)object) + s->offset);
+			page = virt_to_head_slqb_page(object);
+			prefetch(page);
+		}
+	}
+}
+
+static __always_inline void *__cache_list_get_page(struct kmem_cache *s, struct kmem_cache_list *l)
+{
+	struct slqb_page *page;
+
+	if (unlikely(l->remote_free_check)) {
+		flush_remote_free_list(s, l);
+		if (l->nr_free > 12)
+			kmem_cache_free_free(s, l, 4);
+	}
+
+	if (likely(l->nr_partial)) {
+		page = list_first_entry(&l->partial, struct slqb_page, lru);
+		VM_BUG_ON(!page->inuse);
+		VM_BUG_ON(page->inuse == s->objects);
+		/* XXX: delayed free? if free, move to free list and retry */
+		if (page->inuse + 1 == s->objects) {
+			l->nr_partial--;
+			list_del(&page->lru);
+/*XXX			list_move(&page->lru, &l->full); */
+		}
+	} else if (likely(l->nr_free)) {
+		page = list_first_entry(&l->free, struct slqb_page, lru);
+		VM_BUG_ON(page->inuse);
+		l->nr_free--;
+		list_del(&page->lru);
+		if (likely(s->objects > 1)) {
+			l->nr_partial++;
+			list_add(&page->lru, &l->partial);
+		} else {
+/*XXX			list_move(&page->lru, &l->full); */
+		}
+	} else {
+		return NULL;
+	}
+
+	VM_BUG_ON(!page->freelist);
+
+	return page;
+}
+
+/*
+ * Slow path. The lockless freelist is empty or we need to perform
+ * debugging duties.
+ *
+ * Interrupts are disabled.
+ *
+ * Processing is still very fast if new objects have been freed to the
+ * regular freelist. In that case we simply take over the regular freelist
+ * as the lockless freelist and zap the regular freelist.
+ *
+ * If that is not working then we fall back to the partial lists. We take the
+ * first element of the freelist as the object to allocate now and move the
+ * rest of the freelist to the lockless freelist.
+ *
+ * And if we were unable to get a new slab from the partial slab lists then
+ * we need to allocate a new slab. This is slowest path since we may sleep.
+ */
+static __always_inline void *__slab_alloc(struct kmem_cache *s,
+		gfp_t gfpflags, int node, void *addr)
+{
+	void *object;
+	struct slqb_page *page;
+	struct kmem_cache_cpu *c;
+	struct kmem_cache_list *l;
+#ifdef CONFIG_NUMA
+	struct kmem_cache_node *n;
+
+	if (unlikely(node != -1) && unlikely(node != numa_node_id())) {
+		n = s->node[node];
+		VM_BUG_ON(!n);
+		l = &n->list;
+
+		if (unlikely(!l->nr_partial && !l->nr_free && !l->remote_free_check))
+			goto alloc_new;
+
+		spin_lock(&n->list_lock);
+remote_list_have_object:
+		page = __cache_list_get_page(s, l);
+		if (unlikely(!page)) {
+			spin_unlock(&n->list_lock);
+			goto alloc_new;
+		}
+		VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
+
+remote_found:
+		object = page->freelist;
+		page->freelist = get_freepointer(s, object);
+		//prefetch(((void *)page->freelist) + s->offset);
+		page->inuse++;
+		VM_BUG_ON((page->inuse == s->objects) != (page->freelist == NULL));
+		spin_unlock(&n->list_lock);
+
+		return object;
+	}
+#endif
+
+	c = get_cpu_slab(s, smp_processor_id());
+	VM_BUG_ON(!c);
+	l = &c->list;
+	page = __cache_list_get_page(s, l);
+	if (unlikely(!page))
+		goto alloc_new;
+	VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
+
+local_found:
+	object = page->freelist;
+	page->freelist = get_freepointer(s, object);
+	//prefetch(((void *)page->freelist) + s->offset);
+	page->inuse++;
+	VM_BUG_ON((page->inuse == s->objects) != (page->freelist == NULL));
+
+	return object;
+
+alloc_new:
+#if 0
+	/* XXX: load any partial? */
+#endif
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
+		return NULL;
+
+	if (!NUMA_BUILD || likely(slqb_page_to_nid(page) == numa_node_id())) {
+		c = get_cpu_slab(s, smp_processor_id());
+		l = &c->list;
+		page->list = l;
+		l->nr_slabs++;
+		if (page->inuse + 1 < s->objects) {
+			list_add(&page->lru, &l->partial);
+			l->nr_partial++;
+		} else {
+/*XXX			list_add(&page->lru, &l->full); */
+		}
+		goto local_found;
+	} else {
+#ifdef CONFIG_NUMA
+		n = s->node[slqb_page_to_nid(page)];
+		spin_lock(&n->list_lock);
+		l = &n->list;
+
+		if (l->nr_free || l->nr_partial || l->remote_free_check) {
+			__free_slab(s, page);
+			goto remote_list_have_object;
+		}
+
+		l->nr_slabs++;
+		page->list = l;
+		if (page->inuse + 1 < s->objects) {
+			list_add(&page->lru, &l->partial);
+			l->nr_partial++;
+		} else {
+/*XXX			list_add(&page->lru, &l->full); */
+		}
+		goto remote_found;
+#endif
+	}
+}
+
+/*
+ * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
+ * have the fastpath folded into their functions. So no function call
+ * overhead for requests that can be satisfied on the fastpath.
+ *
+ * The fastpath works by first checking if the lockless freelist can be used.
+ * If not then __slab_alloc is called for slow processing.
+ *
+ * Otherwise we can simply pick the next object from the lockless free list.
+ */
+static __always_inline void *slab_alloc(struct kmem_cache *s,
+		gfp_t gfpflags, int node, void *addr)
+{
+	void *object;
+	unsigned long flags;
+
+again:
+	local_irq_save(flags);
+	object = __slab_alloc(s, gfpflags, node, addr);
+	local_irq_restore(flags);
+
+	if (unlikely(slab_debug(s))) {
+		if (unlikely(!alloc_debug_processing(s, object, addr)))
+			goto again;
+	}
+
+	if (unlikely((gfpflags & __GFP_ZERO) && object))
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
+static void flush_remote_free_cache(struct kmem_cache *s, struct kmem_cache_cpu *c)
+{
+	struct kmem_cache_list *dest = c->remote_cache_list;
+	int check = 0;
+	int sidx, didx;
+	int nr;
+	int i;
+
+	if (unlikely(!dest))
+		return;
+
+	spin_lock(&dest->remote_free.lock);
+
+	nr = c->remote_nr;
+	sidx = 0;
+	didx = dest->remote_free.nr % 4;
+	for (i = 0; i < min(nr, 4); i++) {
+		if (!dest->remote_free.list[didx].head)
+			dest->remote_free.list[didx].head = c->remote_list[sidx].head;
+		else
+			set_freepointer(s, dest->remote_free.list[didx].tail, c->remote_list[sidx].head);
+		dest->remote_free.list[didx].tail = c->remote_list[sidx].tail;
+
+		c->remote_list[sidx].head = NULL;
+		c->remote_list[sidx].tail = NULL;
+
+		sidx = (sidx + 1) % 4;
+		didx = (didx + 1) % 4;
+	}
+
+	nr += dest->remote_free.nr;
+	dest->remote_free.nr = nr;
+
+	c->remote_nr = 0;
+	if (nr > 1024 || (nr * s->size > 8*PAGE_SIZE)) {
+		if (!dest->remote_free_check)
+			check = 1;
+	}
+	spin_unlock(&dest->remote_free.lock);
+
+	if (check)
+		dest->remote_free_check = 1;
+}
+
+/*
+ * Slow patch handling. This may still be called frequently since objects
+ * have a longer lifetime than the cpu slabs in most processing loads.
+ *
+ * So we still attempt to reduce cache line usage. Just take the slab
+ * lock and free the item. If there is no additional partial page
+ * handling required then we can return immediately.
+ */
+static __always_inline void __slab_free(struct kmem_cache *s, struct slqb_page *page,
+				void *object, void *addr)
+{
+	struct kmem_cache_cpu *c;
+	struct kmem_cache_list *l;
+	int idx;
+
+	l = page->list;
+	c = get_cpu_slab(s, smp_processor_id());
+	if (likely(&c->list == l)) {
+		free_object_to_page(s, l, page, object, 1);
+		if (l->nr_free > 12)
+			kmem_cache_free_free(s, l, 4);
+		return;
+	}
+
+	if (l != c->remote_cache_list) {
+		flush_remote_free_cache(s, c);
+		c->remote_cache_list = l;
+	}
+
+	idx = c->remote_nr % 4;
+	if (!c->remote_list[idx].head)
+		c->remote_list[idx].head = object;
+	else
+		set_freepointer(s, c->remote_list[idx].tail, object);
+	c->remote_list[idx].tail = object;
+	c->remote_nr++;
+
+	if (c->remote_nr > 1024 || (c->remote_nr * s->size > 8*PAGE_SIZE))
+		flush_remote_free_cache(s, c);
+}
+
+/*
+ * Fastpath with forced inlining to produce a kfree and kmem_cache_free that
+ * can perform fastpath freeing without additional function calls.
+ *
+ * The fastpath is only possible if we are freeing to the current cpu slab
+ * of this processor. This typically the case if we have just allocated
+ * the item before.
+ *
+ * If fastpath is not possible then fall back to __slab_free where we deal
+ * with all sorts of special processing.
+ */
+static __always_inline void slab_free(struct kmem_cache *s,
+			struct slqb_page *page, void *object, void *addr)
+{
+	unsigned long flags;
+
+	debug_check_no_locks_freed(object, s->objsize);
+	if (unlikely(slab_debug(s))) {
+		if (unlikely(!free_debug_processing(s, object, addr)))
+			return;
+	}
+
+	local_irq_save(flags);
+	__slab_free(s, page, object, addr);
+	local_irq_restore(flags);
+}
+
+void kmem_cache_free(struct kmem_cache *s, void *x)
+{
+	struct slqb_page *page;
+
+	page = virt_to_head_slqb_page(x);
+
+	slab_free(s, page, x, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(kmem_cache_free);
+
+/* Figure out on which slab object the object resides */
+static struct slqb_page *get_object_page(const void *x)
+{
+	struct slqb_page *page = virt_to_head_slqb_page(x);
+
+	if (!PageSlab(page))
+		return NULL;
+
+	return page;
+}
+
+/*
+ * Object placement in a slab is made very easy because we always start at
+ * offset 0. If we tune the size of the object to the alignment then we can
+ * get the required alignment by putting one properly sized object after
+ * another.
+ *
+ * Notice that the allocation order determines the sizes of the per cpu
+ * caches. Each processor has always one slab available for allocations.
+ * Increasing the allocation order reduces the number of times that slabs
+ * must be moved on and off the partial lists and is therefore a factor in
+ * locking overhead.
+ */
+
+/*
+ * Mininum / Maximum order of slab pages. This influences locking overhead
+ * and slab fragmentation. A higher order reduces the number of partial slabs
+ * and increases the number of allocations possible without having to
+ * take the list_lock.
+ */
+static int slqb_min_order;
+static int slqb_max_order = DEFAULT_MAX_ORDER;
+
+/*
+ * Merge control. If this is set then no merging of slab caches will occur.
+ * (Could be removed. This was introduced to pacify the merge skeptics.)
+ */
+static int slqb_nomerge;
+
+/*
+ * Calculate the order of allocation given an slab object size.
+ *
+ * The order of allocation has significant impact on performance and other
+ * system components. Generally order 0 allocations should be preferred since
+ * order 0 does not cause fragmentation in the page allocator. Larger objects
+ * be problematic to put into order 0 slabs because there may be too much
+ * unused space left. We go to a higher order if more than 1/8th of the slab
+ * would be wasted.
+ *
+ * In order to reach satisfactory performance we must ensure that a minimum
+ * number of objects is in one slab. Otherwise we may generate too much
+ * activity on the partial lists which requires taking the list_lock. This is
+ * less a concern for large slabs though which are rarely used.
+ *
+ * slqb_max_order specifies the order where we begin to stop considering the
+ * number of objects in a slab as critical. If we reach slqb_max_order then
+ * we try to keep the page order as low as possible. So we accept more waste
+ * of space in favor of a small page order.
+ *
+ * Higher order allocations also allow the placement of more objects in a
+ * slab and thereby reduce object handling overhead. If the user has
+ * requested a higher mininum order then we start with that one instead of
+ * the smallest order which will fit the object.
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
+	 * Doh this slab cannot be placed using slqb_max_order.
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
+	int i;
+
+	l->cache = s;
+	l->nr_partial = 0;
+	l->nr_free = 0;
+	l->nr_slabs = 0;
+	INIT_LIST_HEAD(&l->partial);
+	INIT_LIST_HEAD(&l->free);
+	INIT_LIST_HEAD(&l->full);
+
+	l->remote_free_check = 0;
+	spin_lock_init(&l->remote_free.lock);
+	l->remote_free.nr = 0;
+	for (i = 0; i < 4; i++) {
+		l->remote_free.list[i].head = NULL;
+		l->remote_free.list[i].tail = NULL;
+	}
+}
+
+static void init_kmem_cache_cpu(struct kmem_cache *s,
+			struct kmem_cache_cpu *c)
+{
+	int i;
+
+	init_kmem_cache_list(s, &c->list);
+
+	c->remote_nr= 0;
+	for (i = 0; i < 4; i++) {
+		c->remote_list[i].head = NULL;
+		c->remote_list[i].tail = NULL;
+	}
+	c->remote_cache_list = NULL;
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
+#ifdef CONFIG_SMP
+/*
+ * Per cpu array for per cpu structures.
+ *
+ * The per cpu array places all kmem_cache_cpu structures from one processor
+ * close together meaning that it becomes possible that multiple per cpu
+ * structures are contained in one cacheline. This may be particularly
+ * beneficial for the kmalloc caches.
+ *
+ * A desktop system typically has around 60-80 slabs. With 100 here we are
+ * likely able to get per cpu structures for all caches from the array defined
+ * here. We must be able to cover all kmalloc caches during bootstrap.
+ *
+ * If the per cpu array is exhausted then fall back to kmalloc
+ * of individual cachelines. No sharing is possible then.
+ */
+static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s,
+							int cpu, gfp_t flags)
+{
+	struct kmem_cache_cpu *c;
+	struct page *p;
+
+	/* Table overflow: So allocate ourselves */
+//	c = kmalloc_node(
+//		ALIGN(sizeof(struct kmem_cache_cpu), cache_line_size()),
+//		flags, cpu_to_node(cpu));
+
+	p = alloc_pages_node(cpu_to_node(cpu), flags, 0);
+	if (!p) {
+		return NULL;
+	}
+	c = page_address(p);
+
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
+			s->cpu_slab[cpu] = NULL;
+//			kfree(c);
+			__free_pages(virt_to_page(c), 0);
+		}
+	}
+}
+
+static int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
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
+		c = alloc_kmem_cache_cpu(s, cpu, flags);
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
+static inline void free_kmem_cache_cpus(struct kmem_cache *s) {}
+
+static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
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
+		struct kmem_cache_node *n = s->node[node];
+		if (n) {
+//			kmem_cache_free(kmalloc_caches, n);
+			__free_pages(virt_to_page(n), 0);
+		}
+		s->node[node] = NULL;
+	}
+}
+
+static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
+{
+	int node;
+	int local_node;
+
+	if (slab_state >= UP)
+		local_node = virt_to_nid(s);
+	else
+		local_node = 0;
+
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct page *p;
+		struct kmem_cache_node *n;
+
+//		n = kmem_cache_alloc_node(kmalloc_caches, gfpflags, node);
+		p = alloc_pages_node(node, gfpflags, 0);
+		if (!p) {
+			free_kmem_cache_nodes(s);
+			return 0;
+		}
+		n = page_address(p);
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
+static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
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
+	if (slab_poison(s) && !(flags & SLAB_DESTROY_BY_RCU) &&
+			!s->ctor)
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
+	if (((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
+		s->ctor)) {
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
+	return !!s->objects;
+
+}
+
+static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
+		const char *name, size_t size,
+		size_t align, unsigned long flags,
+		void (*ctor)(struct kmem_cache *, void *))
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
+	s->refcount = 1;
+#ifdef CONFIG_NUMA
+	s->remote_node_defrag_ratio = 100;
+#endif
+	if (!init_kmem_cache_nodes(s, gfpflags & ~SLQB_DMA))
+		goto error;
+
+	if (alloc_kmem_cache_cpus(s, gfpflags & ~SLQB_DMA))
+		return 1;
+	free_kmem_cache_nodes(s);
+error:
+	if (flags & SLAB_PANIC)
+		panic("Cannot create slab %s size=%lu realsize=%u "
+			"order=%u offset=%u flags=%lx\n",
+			s->name, (unsigned long)size, s->size, s->order,
+			s->offset, flags);
+	return 0;
+}
+
+/*
+ * Check if a given pointer is valid
+ */
+int kmem_ptr_validate(struct kmem_cache *s, const void *object)
+{
+	struct slqb_page *page;
+
+	page = get_object_page(object);
+
+	if (!page || s != page->list->cache)
+		/* No slab or wrong slab */
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
+static inline int kmem_cache_close(struct kmem_cache *s)
+{
+	int ret = 0;
+#ifdef CONFIG_NUMA
+	int node;
+#endif
+	int cpu;
+
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+		if (!c->remote_nr)
+			continue;
+
+		flush_remote_free_cache(s, c);
+		if (c->remote_nr)
+			ret = 1;
+	}
+
+	for_each_online_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+		struct kmem_cache_list *l = &c->list;
+
+		flush_remote_free_list(s, l);
+
+		kmem_cache_free_free(s, l, 0);
+
+		if (l->nr_slabs)
+			ret = 1;
+		if (l->nr_partial)
+			ret = 1;
+		if (l->nr_free)
+			ret = 1;
+	}
+
+	free_kmem_cache_cpus(s);
+
+#ifdef CONFIG_NUMA
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_list *l = &n->list;
+
+		flush_remote_free_list(s, l);
+
+		kmem_cache_free_free(s, l, 0);
+
+		if (l->nr_slabs)
+			ret = 1;
+		if (l->nr_partial)
+			ret = 1;
+		if (l->nr_free)
+			ret = 1;
+	}
+
+	free_kmem_cache_nodes(s);
+#endif
+
+	return ret;
+}
+
+/*
+ * Close a cache and release the kmem_cache structure
+ * (must be used for caches created using kmem_cache_create)
+ */
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+	down_write(&slqb_lock);
+	s->refcount--;
+	if (!s->refcount) {
+		list_del(&s->list);
+		up_write(&slqb_lock);
+		if (kmem_cache_close(s))
+			WARN_ON(1);
+		sysfs_slab_remove(s);
+	} else
+		up_write(&slqb_lock);
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
+static struct kmem_cache *kmalloc_caches_dma[PAGE_SHIFT + 1] __cacheline_aligned;
+#endif
+
+static int __init setup_slqb_min_order(char *str)
+{
+	get_option(&str, &slqb_min_order);
+
+	return 1;
+}
+
+__setup("slqb_min_order=", setup_slqb_min_order);
+
+static int __init setup_slqb_max_order(char *str)
+{
+	get_option(&str, &slqb_max_order);
+
+	return 1;
+}
+
+__setup("slqb_max_order=", setup_slqb_max_order);
+
+static int __init setup_slqb_nomerge(char *str)
+{
+	slqb_nomerge = 1;
+	return 1;
+}
+
+__setup("slqb_nomerge", setup_slqb_nomerge);
+
+static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
+		const char *name, int size, gfp_t gfp_flags)
+{
+	unsigned int flags = 0;
+
+	if (gfp_flags & SLQB_DMA)
+		flags = SLAB_CACHE_DMA;
+
+	down_write(&slqb_lock);
+	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
+			flags | __KMALLOC_CACHE, NULL))
+		goto panic;
+
+	list_add(&s->list, &slab_caches);
+	up_write(&slqb_lock);
+	if (sysfs_slab_add(s))
+		goto panic;
+	return s;
+
+panic:
+	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);
+}
+
+#ifdef CONFIG_ZONE_DMA
+
+static void sysfs_add_func(struct work_struct *w)
+{
+	struct kmem_cache *s;
+
+	down_write(&slqb_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+		if (s->flags & __SYSFS_ADD_DEFERRED) {
+			s->flags &= ~__SYSFS_ADD_DEFERRED;
+			sysfs_slab_add(s);
+		}
+	}
+	up_write(&slqb_lock);
+}
+
+static DECLARE_WORK(sysfs_add_work, sysfs_add_func);
+
+static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
+{
+	struct kmem_cache *s;
+	char *text;
+	size_t realsize;
+
+	s = kmalloc_caches_dma[index];
+	if (s)
+		return s;
+
+	/* Dynamically create dma cache */
+	if (flags & __GFP_WAIT)
+		down_write(&slqb_lock);
+	else {
+		if (!down_write_trylock(&slqb_lock))
+			goto out;
+	}
+
+	if (kmalloc_caches_dma[index])
+		goto unlock_out;
+
+	realsize = kmalloc_caches[index].objsize;
+	text = kasprintf(flags & ~SLQB_DMA, "kmalloc_dma-%d",
+			 (unsigned int)realsize);
+	s = kmalloc(kmem_size, flags & ~SLQB_DMA);
+
+	if (!s || !text || !kmem_cache_open(s, flags, text,
+			realsize, ARCH_KMALLOC_MINALIGN,
+			SLAB_CACHE_DMA|__SYSFS_ADD_DEFERRED, NULL)) {
+		kfree(s);
+		kfree(text);
+		goto unlock_out;
+	}
+
+	list_add(&s->list, &slab_caches);
+	kmalloc_caches_dma[index] = s;
+
+	schedule_work(&sysfs_add_work);
+
+unlock_out:
+	up_write(&slqb_lock);
+out:
+	return kmalloc_caches_dma[index];
+}
+#else
+static inline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
+{
+	BUG();
+}
+#endif
+
+/*
+ * Conversion table for small slabs sizes / 8 to the index in the
+ * kmalloc array. This is necessary for slabs < 192 since we have non power
+ * of two cache sizes there. The size of larger slabs can be determined using
+ * fls.
+ */
+static s8 size_index[24] = {
+	3,	/* 8 */
+	4,	/* 16 */
+	5,	/* 24 */
+	5,	/* 32 */
+	6,	/* 40 */
+	6,	/* 48 */
+	6,	/* 56 */
+	6,	/* 64 */
+	1,	/* 72 */
+	1,	/* 80 */
+	1,	/* 88 */
+	1,	/* 96 */
+	7,	/* 104 */
+	7,	/* 112 */
+	7,	/* 120 */
+	7,	/* 128 */
+	2,	/* 136 */
+	2,	/* 144 */
+	2,	/* 152 */
+	2,	/* 160 */
+	2,	/* 168 */
+	2,	/* 176 */
+	2,	/* 184 */
+	2	/* 192 */
+};
+
+static struct kmem_cache *get_slab(size_t size, gfp_t flags)
+{
+	int index;
+
+	if (size <= 192) {
+		if (!size)
+			return ZERO_SIZE_PTR;
+
+		index = size_index[(size - 1) / 8];
+	} else
+		index = fls(size - 1);
+
+	if (unlikely((flags & SLQB_DMA)))
+		return dma_kmalloc_cache(index, flags);
+
+	return &kmalloc_caches[index];
+}
+
+void *__kmalloc(size_t size, gfp_t flags)
+{
+	struct kmem_cache *s;
+
+	s = get_slab(size, flags);
+
+	if (unlikely(ZERO_OR_NULL_PTR(s)))
+		return s;
+
+	return slab_alloc(s, flags, -1, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(__kmalloc);
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	struct kmem_cache *s;
+
+	s = get_slab(size, flags);
+
+	if (unlikely(ZERO_OR_NULL_PTR(s)))
+		return s;
+
+	return slab_alloc(s, flags, node, __builtin_return_address(0));
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
+	BUG_ON(!page);
+
+	if (unlikely(!PageSlab(page)))
+		return PAGE_SIZE << compound_order(&page->page);
+
+	s = page->list->cache;
+	BUG_ON(!s);
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
+void kfree(const void *x)
+{
+	struct slqb_page *page;
+	void *object = (void *)x;
+
+	if (unlikely(ZERO_OR_NULL_PTR(x)))
+		return;
+
+	page = virt_to_head_slqb_page(x);
+	slab_free(page->list->cache, page, object, __builtin_return_address(0));
+}
+EXPORT_SYMBOL(kfree);
+
+static void kmem_cache_shrink_percpu(void *arg)
+{
+	int cpu = smp_processor_id();
+	struct kmem_cache *s = arg;
+	struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+	struct kmem_cache_list *l = &c->list;
+
+	if (c->remote_nr)
+		flush_remote_free_cache(s, c);
+
+	flush_remote_free_list(s, l);
+	kmem_cache_free_free(s, l, 0);
+}
+
+static void kmem_cache_reap_percpu(void *arg)
+{
+	struct kmem_cache *s;
+
+	list_for_each_entry(s, &slab_caches, list)
+		kmem_cache_shrink(s);
+}
+
+void kmem_cache_reap(void)
+{
+#ifdef CONFIG_NUMA
+	struct kmem_cache *s;
+	int node;
+#endif
+
+	down_read(&slqb_lock);
+	/* XXX: should make the latency better? */
+	on_each_cpu(kmem_cache_reap_percpu, NULL, 0, 1);
+	on_each_cpu(kmem_cache_reap_percpu, NULL, 0, 1);
+
+#ifdef CONFIG_NUMA
+	list_for_each_entry(s, &slab_caches, list) {
+		for_each_node_state(node, N_NORMAL_MEMORY) {
+			struct kmem_cache_node *n = s->node[node];
+			struct kmem_cache_list *l = &n->list;
+
+			spin_lock_irq(&n->list_lock);
+			flush_remote_free_list(s, l);
+
+			kmem_cache_free_free(s, l, 0);
+			spin_unlock_irq(&n->list_lock);
+		}
+	}
+#endif
+	up_read(&slqb_lock);
+}
+
+/*
+ * kmem_cache_shrink removes empty slabs from the partial lists and sorts
+ * the remaining slabs by the number of items in use. The slabs with the
+ * most items in use come first. New allocations will then fill those up
+ * and thus they can be removed from the partial lists.
+ *
+ * The slabs with the least items are placed last. This results in them
+ * being allocated from last increasing the chance that the last objects
+ * are freed in them.
+ */
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+#ifdef CONFIG_NUMA
+	int node;
+#endif
+
+	on_each_cpu(kmem_cache_shrink_percpu, s, 0, 1);
+
+#ifdef CONFIG_NUMA
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n = s->node[node];
+		struct kmem_cache_list *l = &n->list;
+
+		spin_lock_irq(&n->list_lock);
+		flush_remote_free_list(s, l);
+
+		kmem_cache_free_free(s, l, 0);
+		spin_unlock_irq(&n->list_lock);
+	}
+#endif
+
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
+
+static void cache_reap(struct work_struct *w)
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
+		local_irq_disable();
+		kmem_cache_shrink_percpu(s);
+		local_irq_enable();
+
+#ifdef CONFIG_NUMA
+		if (1 /* XXX */) {
+			struct kmem_cache_node *n = s->node[node];
+			struct kmem_cache_list *l = &n->list;
+
+			spin_lock_irq(&n->list_lock);
+			flush_remote_free_list(s, l);
+
+			kmem_cache_free_free(s, l, 0);
+			spin_unlock_irq(&n->list_lock);
+		}
+#endif
+	}
+
+	up_read(&slqb_lock);
+out:
+	schedule_delayed_work(work, round_jiffies_relative(3*HZ));
+}
+
+static DEFINE_PER_CPU(struct delayed_work, reap_work);
+
+static void __cpuinit start_cpu_timer(int cpu)
+{
+	struct delayed_work *reap_work = &per_cpu(reap_work, cpu);
+
+	/*
+	 * When this gets called from do_initcalls via cpucache_init(),
+	 * init_workqueues() has already run, so keventd will be setup
+	 * at that time.
+	 */
+        if (keventd_up() && reap_work->work.func == NULL) {
+                INIT_DELAYED_WORK(reap_work, cache_reap);
+                schedule_delayed_work_on(cpu, reap_work,
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
+static int slab_mem_going_offline_callback(void *arg)
+{
+	kmem_cache_reap();
+
+	return 0;
+}
+
+static void slab_mem_offline_callback(void *arg)
+{
+	struct kmem_cache_node *n;
+	struct kmem_cache *s;
+	struct memory_notify *marg = arg;
+	int offline_node;
+
+	offline_node = marg->status_change_nid;
+
+	/*
+	 * If the node still has available memory. we need kmem_cache_node
+	 * for it yet.
+	 */
+	if (offline_node < 0)
+		return;
+
+	down_read(&slqb_lock);
+	list_for_each_entry(s, &slab_caches, list) {
+		n = get_node(s, offline_node);
+		if (n) {
+			/*
+			 * if n->nr_slabs > 0, slabs still exist on the node
+			 * that is going down. We were unable to free them,
+			 * and offline_pages() function shoudn't call this
+			 * callback. So, we must fail.
+			 */
+			BUG_ON(atomic_long_read(&n->nr_slabs));
+
+			s->node[offline_node] = NULL;
+			kmem_cache_free(kmalloc_caches, n);
+		}
+	}
+	up_read(&slqb_lock);
+}
+
+static int slab_mem_going_online_callback(void *arg)
+{
+	struct kmem_cache_node *n;
+	struct kmem_cache *s;
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
+		n = kmem_cache_alloc(kmalloc_caches, GFP_KERNEL);
+		if (!n) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		init_kmem_cache_node(n);
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
+		ret = slab_mem_going_offline_callback(arg);
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
+	int caches = 0;
+
+#ifdef CONFIG_NUMA
+	/*
+	 * Must first have the slab cache available for the allocations of the
+	 * struct kmem_cache_node's. There is special bootstrap code in
+	 * kmem_cache_open for slab_state == DOWN.
+	 */
+	create_kmalloc_cache(&kmalloc_caches[0], "kmem_cache_node",
+		sizeof(struct kmem_cache_node), GFP_KERNEL);
+	kmalloc_caches[0].refcount = -1;
+	caches++;
+
+	hotplug_memory_notifier(slab_memory_callback, 1);
+#endif
+
+	/* Able to allocate the per node structures */
+	slab_state = PARTIAL;
+
+	/* Caches that are not of the two-to-the-power-of size */
+	if (KMALLOC_MIN_SIZE <= 64) {
+		create_kmalloc_cache(&kmalloc_caches[1],
+				"kmalloc-96", 96, GFP_KERNEL);
+		caches++;
+	}
+	if (KMALLOC_MIN_SIZE <= 128) {
+		create_kmalloc_cache(&kmalloc_caches[2],
+				"kmalloc-192", 192, GFP_KERNEL);
+		caches++;
+	}
+
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_SLQB_HIGH; i++) {
+		create_kmalloc_cache(&kmalloc_caches[i],
+			"kmalloc", 1 << i, GFP_KERNEL);
+		caches++;
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
+	slab_state = UP;
+
+	/* Provide the correct kmalloc names now that the caches are up */
+	for (i = KMALLOC_SHIFT_LOW; i <= PAGE_SHIFT; i++)
+		kmalloc_caches[i]. name =
+			kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
+
+#ifdef CONFIG_SMP
+	register_cpu_notifier(&slab_notifier);
+	kmem_size = offsetof(struct kmem_cache, cpu_slab) +
+				nr_cpu_ids * sizeof(struct kmem_cache_cpu *);
+#else
+	kmem_size = sizeof(struct kmem_cache);
+#endif
+
+
+	printk(KERN_INFO
+		"SLQB: Genslabs=%d, HWalign=%d, Order=%d-%d,"
+		" CPUs=%d, Nodes=%d\n",
+		caches, cache_line_size(),
+		slqb_min_order, slqb_max_order, nr_cpu_ids, nr_node_ids);
+}
+
+/*
+ * Find a mergeable slab cache
+ */
+static int slab_unmergeable(struct kmem_cache *s)
+{
+	if (slqb_nomerge || (s->flags & SLQB_NEVER_MERGE))
+		return 1;
+
+	if (s->ctor)
+		return 1;
+
+	/*
+	 * We may have set a slab to be unmergeable during bootstrap.
+	 */
+	if (s->refcount < 0)
+		return 1;
+
+	return 0;
+}
+
+static struct kmem_cache *find_mergeable(size_t size,
+		size_t align, unsigned long flags, const char *name,
+		void (*ctor)(struct kmem_cache *, void *))
+{
+	struct kmem_cache *s;
+
+	if (slqb_nomerge || (flags & SLQB_NEVER_MERGE))
+		return NULL;
+
+	if (ctor)
+		return NULL;
+
+	size = ALIGN(size, sizeof(void *));
+	align = calculate_alignment(flags, align, size);
+	size = ALIGN(size, align);
+	flags = kmem_cache_flags(size, flags, name, NULL);
+
+	list_for_each_entry(s, &slab_caches, list) {
+		if (slab_unmergeable(s))
+			continue;
+
+		if (size > s->size)
+			continue;
+
+		if ((flags & SLQB_MERGE_SAME) != (s->flags & SLQB_MERGE_SAME))
+				continue;
+		/*
+		 * Check if alignment is compatible.
+		 * Courtesy of Adrian Drzewiecki
+		 */
+		if ((s->size & ~(align - 1)) != s->size)
+			continue;
+
+		if (s->size - size >= sizeof(void *))
+			continue;
+
+		return s;
+	}
+	return NULL;
+}
+
+struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+		size_t align, unsigned long flags,
+		void (*ctor)(struct kmem_cache *, void *))
+{
+	struct kmem_cache *s;
+
+	down_write(&slqb_lock);
+	s = find_mergeable(size, align, flags, name, ctor);
+	if (s) {
+		s->refcount++;
+		/*
+		 * Adjust the object sizes so that we clear
+		 * the complete object on kzalloc.
+		 */
+		s->objsize = max(s->objsize, (int)size);
+
+		s->inuse = max_t(int, s->inuse, ALIGN(size, sizeof(void *)));
+		up_write(&slqb_lock);
+		if (sysfs_slab_alias(s, name))
+			goto err;
+		return s;
+	}
+	s = kmalloc(kmem_size, GFP_KERNEL);
+	if (s) {
+		if (kmem_cache_open(s, GFP_KERNEL, name,
+				size, align, flags, ctor)) {
+			list_add(&s->list, &slab_caches);
+			up_write(&slqb_lock);
+			if (sysfs_slab_add(s))
+				goto err;
+			return s;
+		}
+		kfree(s);
+	}
+	up_write(&slqb_lock);
+
+err:
+	if (flags & SLAB_PANIC)
+		panic("Cannot create slabcache %s\n", name);
+	else
+		s = NULL;
+	return s;
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
+		list_for_each_entry(s, &slab_caches, list)
+			s->cpu_slab[cpu] = alloc_kmem_cache_cpu(s, cpu,
+							GFP_KERNEL);
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
+		cancel_rearming_delayed_work(&per_cpu(reap_work, cpu));
+		per_cpu(reap_work, cpu).work.func = NULL;
+		break;
+
+	case CPU_UP_CANCELED:
+	case CPU_UP_CANCELED_FROZEN:
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		down_read(&slqb_lock);
+		list_for_each_entry(s, &slab_caches, list) {
+			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+			kmem_cache_reap();
+
+			kfree(c);
+			s->cpu_slab[cpu] = NULL;
+		}
+		up_read(&slqb_lock);
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
+void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, void *caller)
+{
+	struct kmem_cache *s;
+
+	s = get_slab(size, gfpflags);
+
+	if (unlikely(ZERO_OR_NULL_PTR(s)))
+		return s;
+
+	return slab_alloc(s, gfpflags, -1, caller);
+}
+
+void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
+					int node, void *caller)
+{
+	struct kmem_cache *s;
+
+	s = get_slab(size, gfpflags);
+
+	if (unlikely(ZERO_OR_NULL_PTR(s)))
+		return s;
+
+	return slab_alloc(s, gfpflags, node, caller);
+}
+
+#if defined(CONFIG_SYSFS) && defined(CONFIG_SLQB_DEBUG)
+
+#if 0
+/*
+ * Generate lists of code addresses where slabcache objects are allocated
+ * and freed.
+ */
+struct location {
+	unsigned long count;
+	void *addr;
+	long long sum_time;
+	long min_time;
+	long max_time;
+	long min_pid;
+	long max_pid;
+	cpumask_t cpus;
+	nodemask_t nodes;
+};
+
+struct loc_track {
+	unsigned long max;
+	unsigned long count;
+	struct location *loc;
+};
+
+static void free_loc_track(struct loc_track *t)
+{
+	if (t->max)
+		free_pages((unsigned long)t->loc,
+			get_order(sizeof(struct location) * t->max));
+}
+
+static int alloc_loc_track(struct loc_track *t, unsigned long max, gfp_t flags)
+{
+	struct location *l;
+	int order;
+
+	order = get_order(sizeof(struct location) * max);
+
+	l = (void *)__get_free_pages(flags, order);
+	if (!l)
+		return 0;
+
+	if (t->count) {
+		memcpy(l, t->loc, sizeof(struct location) * t->count);
+		free_loc_track(t);
+	}
+	t->max = max;
+	t->loc = l;
+	return 1;
+}
+
+static int add_location(struct loc_track *t, struct kmem_cache *s,
+				const struct track *track)
+{
+	long start, end, pos;
+	struct location *l;
+	void *caddr;
+	unsigned long age = jiffies - track->when;
+
+	start = -1;
+	end = t->count;
+
+	for ( ; ; ) {
+		pos = start + (end - start + 1) / 2;
+
+		/*
+		 * There is nothing at "end". If we end up there
+		 * we need to add something to before end.
+		 */
+		if (pos == end)
+			break;
+
+		caddr = t->loc[pos].addr;
+		if (track->addr == caddr) {
+
+			l = &t->loc[pos];
+			l->count++;
+			if (track->when) {
+				l->sum_time += age;
+				if (age < l->min_time)
+					l->min_time = age;
+				if (age > l->max_time)
+					l->max_time = age;
+
+				if (track->pid < l->min_pid)
+					l->min_pid = track->pid;
+				if (track->pid > l->max_pid)
+					l->max_pid = track->pid;
+
+				cpu_set(track->cpu, l->cpus);
+			}
+			node_set(virt_to_nid(track), l->nodes);
+			return 1;
+		}
+
+		if (track->addr < caddr)
+			end = pos;
+		else
+			start = pos;
+	}
+
+	/*
+	 * Not found. Insert new tracking element.
+	 */
+	if (t->count >= t->max && !alloc_loc_track(t, 2 * t->max, GFP_ATOMIC))
+		return 0;
+
+	l = t->loc + pos;
+	if (pos < t->count)
+		memmove(l + 1, l,
+			(t->count - pos) * sizeof(struct location));
+	t->count++;
+	l->count = 1;
+	l->addr = track->addr;
+	l->sum_time = age;
+	l->min_time = age;
+	l->max_time = age;
+	l->min_pid = track->pid;
+	l->max_pid = track->pid;
+	cpus_clear(l->cpus);
+	cpu_set(track->cpu, l->cpus);
+	nodes_clear(l->nodes);
+	node_set(virt_to_nid(track), l->nodes);
+	return 1;
+}
+
+static void process_slab(struct loc_track *t, struct kmem_cache *s,
+		struct slqb_page *page, enum track_item alloc)
+{
+	void *addr = slqb_page_address(page);
+	DECLARE_BITMAP(map, s->objects);
+	void *p;
+
+	bitmap_zero(map, s->objects);
+	for_each_free_object(p, s, page->freelist)
+		set_bit(slab_index(p, s, addr), map);
+
+	for_each_object(p, s, addr)
+		if (!test_bit(slab_index(p, s, addr), map))
+			add_location(t, s, get_track(s, p, alloc));
+}
+
+static int list_locations(struct kmem_cache *s, char *buf,
+					enum track_item alloc)
+{
+	int len = 0;
+	unsigned long i;
+	struct loc_track t = { 0, 0, NULL };
+	int node;
+
+	if (!alloc_loc_track(&t, PAGE_SIZE / sizeof(struct location),
+			GFP_TEMPORARY))
+		return sprintf(buf, "Out of memory\n");
+
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n = get_node(s, node);
+		unsigned long flags;
+		struct slqb_page *page;
+
+		if (!atomic_long_read(&n->nr_slabs))
+			continue;
+
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry(page, &n->partial, lru)
+			process_slab(&t, s, page, alloc);
+		list_for_each_entry(page, &n->full, lru)
+			process_slab(&t, s, page, alloc);
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+
+	for (i = 0; i < t.count; i++) {
+		struct location *l = &t.loc[i];
+
+		if (len > PAGE_SIZE - 100)
+			break;
+		len += sprintf(buf + len, "%7ld ", l->count);
+
+		if (l->addr)
+			len += sprint_symbol(buf + len, (unsigned long)l->addr);
+		else
+			len += sprintf(buf + len, "<not-available>");
+
+		if (l->sum_time != l->min_time) {
+			unsigned long remainder;
+
+			len += sprintf(buf + len, " age=%ld/%ld/%ld",
+			l->min_time,
+			div_long_long_rem(l->sum_time, l->count, &remainder),
+			l->max_time);
+		} else
+			len += sprintf(buf + len, " age=%ld",
+				l->min_time);
+
+		if (l->min_pid != l->max_pid)
+			len += sprintf(buf + len, " pid=%ld-%ld",
+				l->min_pid, l->max_pid);
+		else
+			len += sprintf(buf + len, " pid=%ld",
+				l->min_pid);
+
+		if (num_online_cpus() > 1 && !cpus_empty(l->cpus) &&
+				len < PAGE_SIZE - 60) {
+			len += sprintf(buf + len, " cpus=");
+			len += cpulist_scnprintf(buf + len, PAGE_SIZE - len - 50,
+					l->cpus);
+		}
+
+		if (num_online_nodes() > 1 && !nodes_empty(l->nodes) &&
+				len < PAGE_SIZE - 60) {
+			len += sprintf(buf + len, " nodes=");
+			len += nodelist_scnprintf(buf + len, PAGE_SIZE - len - 50,
+					l->nodes);
+		}
+
+		len += sprintf(buf + len, "\n");
+	}
+
+	free_loc_track(&t);
+	if (!t.count)
+		len += sprintf(buf, "No data\n");
+	return len;
+}
+
+enum slab_stat_type {
+	SL_FULL,
+	SL_PARTIAL,
+	SL_CPU,
+	SL_OBJECTS
+};
+
+#define SO_FULL		(1 << SL_FULL)
+#define SO_PARTIAL	(1 << SL_PARTIAL)
+#define SO_CPU		(1 << SL_CPU)
+#define SO_OBJECTS	(1 << SL_OBJECTS)
+
+static unsigned long slab_objects(struct kmem_cache *s,
+			char *buf, unsigned long flags)
+{
+	unsigned long total = 0;
+	int cpu;
+	int node;
+	int x;
+	unsigned long *nodes;
+	unsigned long *per_cpu;
+
+	nodes = kzalloc(2 * sizeof(unsigned long) * nr_node_ids, GFP_KERNEL);
+	per_cpu = nodes + nr_node_ids;
+
+	for_each_possible_cpu(cpu) {
+		struct slqb_page *page;
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+
+		if (!c)
+			continue;
+
+		page = c->page;
+		node = c->node;
+		if (node < 0)
+			continue;
+		if (page) {
+			if (flags & SO_CPU) {
+				if (flags & SO_OBJECTS)
+					x = page->inuse;
+				else
+					x = 1;
+				total += x;
+				nodes[node] += x;
+			}
+			per_cpu[node]++;
+		}
+	}
+
+#if 0
+	for_each_node_state(node, N_NORMAL_MEMORY) {
+		struct kmem_cache_node *n = get_node(s, node);
+
+		if (flags & SO_PARTIAL) {
+			if (flags & SO_OBJECTS)
+				x = count_partial(n);
+			else
+				x = n->nr_partial;
+			total += x;
+			nodes[node] += x;
+		}
+
+		if (flags & SO_FULL) {
+			int full_slabs = atomic_long_read(&n->nr_slabs)
+					- per_cpu[node]
+					- n->nr_partial;
+
+			if (flags & SO_OBJECTS)
+				x = full_slabs * s->objects;
+			else
+				x = full_slabs;
+			total += x;
+			nodes[node] += x;
+		}
+	}
+#endif
+
+	x = sprintf(buf, "%lu", total);
+#ifdef CONFIG_NUMA
+	for_each_node_state(node, N_NORMAL_MEMORY)
+		if (nodes[node])
+			x += sprintf(buf + x, " N%d=%lu",
+					node, nodes[node]);
+#endif
+	kfree(nodes);
+	return x + sprintf(buf + x, "\n");
+}
+
+static int any_slab_objects(struct kmem_cache *s)
+{
+	int node;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+
+		if (c && c->page)
+			return 1;
+	}
+
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = get_node(s, node);
+
+		if (!n)
+			continue;
+
+		if (n->nr_partial || atomic_long_read(&n->nr_slabs))
+			return 1;
+	}
+	return 0;
+}
+
+#endif /* XXX */
+
+#define to_slab_attr(n) container_of(n, struct slab_attribute, attr)
+#define to_slab(n) container_of(n, struct kmem_cache, kobj);
+
+struct slab_attribute {
+	struct attribute attr;
+	ssize_t (*show)(struct kmem_cache *s, char *buf);
+	ssize_t (*store)(struct kmem_cache *s, const char *x, size_t count);
+};
+
+#if 0
+#define SLAB_ATTR_RO(_name) \
+	static struct slab_attribute _name##_attr = __ATTR_RO(_name)
+
+#define SLAB_ATTR(_name) \
+	static struct slab_attribute _name##_attr =  \
+	__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->size);
+}
+SLAB_ATTR_RO(slab_size);
+
+static ssize_t align_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->align);
+}
+SLAB_ATTR_RO(align);
+
+static ssize_t object_size_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->objsize);
+}
+SLAB_ATTR_RO(object_size);
+
+static ssize_t objs_per_slab_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->objects);
+}
+SLAB_ATTR_RO(objs_per_slab);
+
+static ssize_t order_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->order);
+}
+SLAB_ATTR_RO(order);
+
+static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+{
+	if (s->ctor) {
+		int n = sprint_symbol(buf, (unsigned long)s->ctor);
+
+		return n + sprintf(buf + n, "\n");
+	}
+	return 0;
+}
+SLAB_ATTR_RO(ctor);
+
+static ssize_t aliases_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->refcount - 1);
+}
+SLAB_ATTR_RO(aliases);
+
+static ssize_t slabs_show(struct kmem_cache *s, char *buf)
+{
+	return slab_objects(s, buf, SO_FULL|SO_PARTIAL|SO_CPU);
+}
+SLAB_ATTR_RO(slabs);
+
+static ssize_t partial_show(struct kmem_cache *s, char *buf)
+{
+	return slab_objects(s, buf, SO_PARTIAL);
+}
+SLAB_ATTR_RO(partial);
+
+static ssize_t cpu_slabs_show(struct kmem_cache *s, char *buf)
+{
+	return slab_objects(s, buf, SO_CPU);
+}
+SLAB_ATTR_RO(cpu_slabs);
+
+static ssize_t objects_show(struct kmem_cache *s, char *buf)
+{
+	return slab_objects(s, buf, SO_FULL|SO_PARTIAL|SO_CPU|SO_OBJECTS);
+}
+SLAB_ATTR_RO(objects);
+
+static ssize_t sanity_checks_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DEBUG_FREE));
+}
+
+static ssize_t sanity_checks_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	s->flags &= ~SLAB_DEBUG_FREE;
+	if (buf[0] == '1')
+		s->flags |= SLAB_DEBUG_FREE;
+	return length;
+}
+SLAB_ATTR(sanity_checks);
+
+static ssize_t trace_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_TRACE));
+}
+
+static ssize_t trace_store(struct kmem_cache *s, const char *buf,
+							size_t length)
+{
+	s->flags &= ~SLAB_TRACE;
+	if (buf[0] == '1')
+		s->flags |= SLAB_TRACE;
+	return length;
+}
+SLAB_ATTR(trace);
+
+static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_RECLAIM_ACCOUNT));
+}
+
+static ssize_t reclaim_account_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	s->flags &= ~SLAB_RECLAIM_ACCOUNT;
+	if (buf[0] == '1')
+		s->flags |= SLAB_RECLAIM_ACCOUNT;
+	return length;
+}
+SLAB_ATTR(reclaim_account);
+
+static ssize_t hwcache_align_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_HWCACHE_ALIGN));
+}
+SLAB_ATTR_RO(hwcache_align);
+
+#ifdef CONFIG_ZONE_DMA
+static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_CACHE_DMA));
+}
+SLAB_ATTR_RO(cache_dma);
+#endif
+
+static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_DESTROY_BY_RCU));
+}
+SLAB_ATTR_RO(destroy_by_rcu);
+
+static ssize_t red_zone_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_RED_ZONE));
+}
+
+static ssize_t red_zone_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	if (any_slab_objects(s))
+		return -EBUSY;
+
+	s->flags &= ~SLAB_RED_ZONE;
+	if (buf[0] == '1')
+		s->flags |= SLAB_RED_ZONE;
+	calculate_sizes(s);
+	return length;
+}
+SLAB_ATTR(red_zone);
+
+static ssize_t poison_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_POISON));
+}
+
+static ssize_t poison_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	if (any_slab_objects(s))
+		return -EBUSY;
+
+	s->flags &= ~SLAB_POISON;
+	if (buf[0] == '1')
+		s->flags |= SLAB_POISON;
+	calculate_sizes(s);
+	return length;
+}
+SLAB_ATTR(poison);
+
+static ssize_t store_user_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_STORE_USER));
+}
+
+static ssize_t store_user_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	if (any_slab_objects(s))
+		return -EBUSY;
+
+	s->flags &= ~SLAB_STORE_USER;
+	if (buf[0] == '1')
+		s->flags |= SLAB_STORE_USER;
+	calculate_sizes(s);
+	return length;
+}
+SLAB_ATTR(store_user);
+
+static ssize_t shrink_show(struct kmem_cache *s, char *buf)
+{
+	return 0;
+}
+
+static ssize_t shrink_store(struct kmem_cache *s,
+			const char *buf, size_t length)
+{
+	if (buf[0] == '1') {
+		int rc = kmem_cache_shrink(s);
+
+		if (rc)
+			return rc;
+	} else
+		return -EINVAL;
+	return length;
+}
+SLAB_ATTR(shrink);
+
+static ssize_t alloc_calls_show(struct kmem_cache *s, char *buf)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return -ENOSYS;
+	return list_locations(s, buf, TRACK_ALLOC);
+}
+SLAB_ATTR_RO(alloc_calls);
+
+static ssize_t free_calls_show(struct kmem_cache *s, char *buf)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return -ENOSYS;
+	return list_locations(s, buf, TRACK_FREE);
+}
+SLAB_ATTR_RO(free_calls);
+
+#ifdef CONFIG_NUMA
+static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", s->remote_node_defrag_ratio / 10);
+}
+
+static ssize_t remote_node_defrag_ratio_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	int n = simple_strtoul(buf, NULL, 10);
+
+	if (n < 100)
+		s->remote_node_defrag_ratio = n * 10;
+	return length;
+}
+SLAB_ATTR(remote_node_defrag_ratio);
+#endif
+#endif /* XXX */
+
+#ifdef CONFIG_SLQB_STATS
+
+static int show_stat(struct kmem_cache *s, char *buf, enum stat_item si)
+{
+	unsigned long sum  = 0;
+	int cpu;
+	int len;
+	int *data = kmalloc(nr_cpu_ids * sizeof(int), GFP_KERNEL);
+
+	if (!data)
+		return -ENOMEM;
+
+	for_each_online_cpu(cpu) {
+		unsigned x = get_cpu_slab(s, cpu)->stat[si];
+
+		data[cpu] = x;
+		sum += x;
+	}
+
+	len = sprintf(buf, "%lu", sum);
+
+	for_each_online_cpu(cpu) {
+		if (data[cpu] && len < PAGE_SIZE - 20)
+			len += sprintf(buf + len, " c%d=%u", cpu, data[cpu]);
+	}
+	kfree(data);
+	return len + sprintf(buf + len, "\n");
+}
+
+#define STAT_ATTR(si, text) 					\
+static ssize_t text##_show(struct kmem_cache *s, char *buf)	\
+{								\
+	return show_stat(s, buf, si);				\
+}								\
+SLAB_ATTR_RO(text);						\
+
+#endif
+
+static struct attribute *slab_attrs[] = {
+#if 0
+	&slab_size_attr.attr,
+	&object_size_attr.attr,
+	&objs_per_slab_attr.attr,
+	&order_attr.attr,
+	&objects_attr.attr,
+	&slabs_attr.attr,
+	&partial_attr.attr,
+	&cpu_slabs_attr.attr,
+	&ctor_attr.attr,
+	&aliases_attr.attr,
+	&align_attr.attr,
+	&sanity_checks_attr.attr,
+	&trace_attr.attr,
+	&hwcache_align_attr.attr,
+	&reclaim_account_attr.attr,
+	&destroy_by_rcu_attr.attr,
+	&red_zone_attr.attr,
+	&poison_attr.attr,
+	&store_user_attr.attr,
+	&validate_attr.attr,
+	&shrink_attr.attr,
+	&alloc_calls_attr.attr,
+	&free_calls_attr.attr,
+#ifdef CONFIG_ZONE_DMA
+	&cache_dma_attr.attr,
+#endif
+#ifdef CONFIG_NUMA
+	&remote_node_defrag_ratio_attr.attr,
+#endif
+#ifdef CONFIG_SLQB_STATS
+	&alloc_fastpath_attr.attr,
+	&alloc_slowpath_attr.attr,
+	&free_fastpath_attr.attr,
+	&free_slowpath_attr.attr,
+	&free_add_partial_attr.attr,
+	&free_remove_partial_attr.attr,
+	&alloc_from_partial_attr.attr,
+	&alloc_slab_attr.attr,
+	&alloc_refill_attr.attr,
+	&free_slab_attr.attr,
+	&cpuslab_flush_attr.attr,
+	&deactivate_full_attr.attr,
+	&deactivate_empty_attr.attr,
+	&deactivate_to_head_attr.attr,
+	&deactivate_to_tail_attr.attr,
+	&deactivate_remote_frees_attr.attr,
+#endif
+#endif /* XXX */
+	NULL
+};
+
+static struct attribute_group slab_attr_group = {
+	.attrs = slab_attrs,
+};
+
+static ssize_t slab_attr_show(struct kobject *kobj,
+				struct attribute *attr,
+				char *buf)
+{
+	struct slab_attribute *attribute;
+	struct kmem_cache *s;
+	int err;
+
+	attribute = to_slab_attr(attr);
+	s = to_slab(kobj);
+
+	if (!attribute->show)
+		return -EIO;
+
+	err = attribute->show(s, buf);
+
+	return err;
+}
+
+static ssize_t slab_attr_store(struct kobject *kobj,
+				struct attribute *attr,
+				const char *buf, size_t len)
+{
+	struct slab_attribute *attribute;
+	struct kmem_cache *s;
+	int err;
+
+	attribute = to_slab_attr(attr);
+	s = to_slab(kobj);
+
+	if (!attribute->store)
+		return -EIO;
+
+	err = attribute->store(s, buf, len);
+
+	return err;
+}
+
+static void kmem_cache_release(struct kobject *kobj)
+{
+	struct kmem_cache *s = to_slab(kobj);
+
+	kfree(s);
+}
+
+static struct sysfs_ops slab_sysfs_ops = {
+	.show = slab_attr_show,
+	.store = slab_attr_store,
+};
+
+static struct kobj_type slab_ktype = {
+	.sysfs_ops = &slab_sysfs_ops,
+	.release = kmem_cache_release
+};
+
+static int uevent_filter(struct kset *kset, struct kobject *kobj)
+{
+	struct kobj_type *ktype = get_ktype(kobj);
+
+	if (ktype == &slab_ktype)
+		return 1;
+	return 0;
+}
+
+static struct kset_uevent_ops slab_uevent_ops = {
+	.filter = uevent_filter,
+};
+
+static struct kset *slab_kset;
+
+#define ID_STR_LENGTH 64
+
+/* Create a unique string id for a slab cache:
+ * format
+ * :[flags-]size:[memory address of kmemcache]
+ */
+static char *create_unique_id(struct kmem_cache *s)
+{
+	char *name = kmalloc(ID_STR_LENGTH, GFP_KERNEL);
+	char *p = name;
+
+	BUG_ON(!name);
+
+	*p++ = ':';
+	/*
+	 * First flags affecting slabcache operations. We will only
+	 * get here for aliasable slabs so we do not need to support
+	 * too many flags. The flags here must cover all flags that
+	 * are matched during merging to guarantee that the id is
+	 * unique.
+	 */
+	if (s->flags & SLAB_CACHE_DMA)
+		*p++ = 'd';
+	if (s->flags & SLAB_RECLAIM_ACCOUNT)
+		*p++ = 'a';
+	if (s->flags & SLAB_DEBUG_FREE)
+		*p++ = 'F';
+	if (p != name + 1)
+		*p++ = '-';
+	p += sprintf(p, "%07d", s->size);
+	BUG_ON(p > name + ID_STR_LENGTH - 1);
+	return name;
+}
+
+static int sysfs_slab_add(struct kmem_cache *s)
+{
+	int err;
+	const char *name;
+	int unmergeable;
+
+	if (slab_state < SYSFS)
+		/* Defer until later */
+		return 0;
+
+	unmergeable = slab_unmergeable(s);
+	if (unmergeable) {
+		/*
+		 * Slabcache can never be merged so we can use the name proper.
+		 * This is typically the case for debug situations. In that
+		 * case we can catch duplicate names easily.
+		 */
+		sysfs_remove_link(&slab_kset->kobj, s->name);
+		name = s->name;
+	} else {
+		/*
+		 * Create a unique name for the slab as a target
+		 * for the symlinks.
+		 */
+		name = create_unique_id(s);
+	}
+
+	s->kobj.kset = slab_kset;
+	err = kobject_init_and_add(&s->kobj, &slab_ktype, NULL, name);
+	if (err) {
+		kobject_put(&s->kobj);
+		return err;
+	}
+
+	err = sysfs_create_group(&s->kobj, &slab_attr_group);
+	if (err)
+		return err;
+	kobject_uevent(&s->kobj, KOBJ_ADD);
+	if (!unmergeable) {
+		/* Setup first alias */
+		sysfs_slab_alias(s, s->name);
+		kfree(name);
+	}
+	return 0;
+}
+
+static void sysfs_slab_remove(struct kmem_cache *s)
+{
+	kobject_uevent(&s->kobj, KOBJ_REMOVE);
+	kobject_del(&s->kobj);
+	kobject_put(&s->kobj);
+}
+
+/*
+ * Need to buffer aliases during bootup until sysfs becomes
+ * available lest we loose that information.
+ */
+struct saved_alias {
+	struct kmem_cache *s;
+	const char *name;
+	struct saved_alias *next;
+};
+
+static struct saved_alias *alias_list;
+
+static int sysfs_slab_alias(struct kmem_cache *s, const char *name)
+{
+	struct saved_alias *al;
+
+	if (slab_state == SYSFS) {
+		/*
+		 * If we have a leftover link then remove it.
+		 */
+		sysfs_remove_link(&slab_kset->kobj, name);
+		return sysfs_create_link(&slab_kset->kobj, &s->kobj, name);
+	}
+
+	al = kmalloc(sizeof(struct saved_alias), GFP_KERNEL);
+	if (!al)
+		return -ENOMEM;
+
+	al->s = s;
+	al->name = name;
+	al->next = alias_list;
+	alias_list = al;
+	return 0;
+}
+
+static int __init slab_sysfs_init(void)
+{
+	struct kmem_cache *s;
+	int err;
+
+	slab_kset = kset_create_and_add("slab", &slab_uevent_ops, kernel_kobj);
+	if (!slab_kset) {
+		printk(KERN_ERR "Cannot register slab subsystem.\n");
+		return -ENOSYS;
+	}
+
+	slab_state = SYSFS;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		err = sysfs_slab_add(s);
+		if (err)
+			printk(KERN_ERR "SLQB: Unable to add boot slab %s"
+						" to sysfs\n", s->name);
+	}
+
+	while (alias_list) {
+		struct saved_alias *al = alias_list;
+
+		alias_list = alias_list->next;
+		err = sysfs_slab_alias(al->s, al->name);
+		if (err)
+			printk(KERN_ERR "SLQB: Unable to add boot slab alias"
+					" %s to sysfs\n", s->name);
+		kfree(al);
+	}
+
+	return 0;
+}
+
+__initcall(slab_sysfs_init);
+#endif
+
+/*
+ * The /proc/slabinfo ABI
+ */
+#ifdef CONFIG_SLABINFO
+
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
+	on_each_cpu(gather_stats, &stats, 0, 1);
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
+	seq_printf(m, " : tunables %4u %4u %4u", 0, 0, 0);
+	seq_printf(m, " : slabdata %6lu %6lu %6lu", stats.nr_slabs, stats.nr_slabs,
+		   0UL);
+	seq_putc(m, '\n');
+	return 0;
+}
+
+const struct seq_operations slabinfo_op = {
+	.start = s_start,
+	.next = s_next,
+	.stop = s_stop,
+	.show = s_show,
+};
+
+#endif /* CONFIG_SLABINFO */
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h
+++ linux-2.6/include/linux/slab.h
@@ -116,6 +116,8 @@ size_t ksize(const void *);
  */
 #ifdef CONFIG_SLUB
 #include <linux/slub_def.h>
+#elif defined(CONFIG_SLQB)
+#include <linux/slqb_def.h>
 #elif defined(CONFIG_SLOB)
 #include <linux/slob_def.h>
 #else
@@ -218,7 +220,7 @@ static inline void *kmem_cache_alloc_nod
  * allocator where we care about the real place the memory allocation
  * request comes from.
  */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || defined(CONFIG_SLQB)
 extern void *__kmalloc_track_caller(size_t, gfp_t, void*);
 #define kmalloc_track_caller(size, flags) \
 	__kmalloc_track_caller(size, flags, __builtin_return_address(0))
@@ -236,7 +238,7 @@ extern void *__kmalloc_track_caller(size
  * standard allocator where we care about the real place the memory
  * allocation request comes from.
  */
-#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || defined (CONFIG_SLQB)
 extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, void *);
 #define kmalloc_node_track_caller(size, flags, node) \
 	__kmalloc_node_track_caller(size, flags, node, \
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 obj-$(CONFIG_SLOB) += slob.o
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
