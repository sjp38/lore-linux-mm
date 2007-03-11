From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070311021016.19963.86409.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
References: <20070311021009.19963.11893.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 1/3] SLUB core
Date: Sat, 10 Mar 2007 18:10:16 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

- Single object slabs only for slabs > slub_max_order otherwise generate
  sufficient objects to avoid frequent use of the page allocator. This is
  necessary to compensate for fragmentation caused by frequent uses of
  the page allocator.

- Drop pass through to page allocator due to page allocator fragmenting
  memory. The buffering of large order allocations is done in SLUB.

- We need to update object sizes when merging slabs otherwise kzalloc
  will not initialize the full object.

- Padding checks before redzone checks so that we get messages when
  the whole slab is corrupted first.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc3/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.21-rc3.orig/fs/proc/proc_misc.c	2007-03-10 10:21:19.000000000 -0800
+++ linux-2.6.21-rc3/fs/proc/proc_misc.c	2007-03-10 10:22:24.000000000 -0800
@@ -397,6 +397,21 @@ static const struct file_operations proc
 };
 #endif
 
+#ifdef CONFIG_SLUB
+extern struct seq_operations slubinfo_op;
+static int slubinfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &slubinfo_op);
+}
+static const struct file_operations proc_slubinfo_operations = {
+	.open		= slubinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+#endif
+
+
 #ifdef CONFIG_SLAB
 extern struct seq_operations slabinfo_op;
 extern ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
@@ -708,6 +723,9 @@ void __init proc_misc_init(void)
 #endif
 	create_seq_entry("stat", 0, &proc_stat_operations);
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
+#ifdef CONFIG_SLUB
+	create_seq_entry("slubinfo",S_IWUSR|S_IRUGO,&proc_slubinfo_operations);
+#endif
 #ifdef CONFIG_SLAB
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 #ifdef CONFIG_DEBUG_SLAB_LEAK
Index: linux-2.6.21-rc3/include/linux/mm_types.h
===================================================================
--- linux-2.6.21-rc3.orig/include/linux/mm_types.h	2007-03-10 10:21:19.000000000 -0800
+++ linux-2.6.21-rc3/include/linux/mm_types.h	2007-03-10 10:22:24.000000000 -0800
@@ -19,10 +19,16 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	atomic_t _count;		/* Usage count, see below. */
-	atomic_t _mapcount;		/* Count of ptes mapped in mms,
+	union {
+		atomic_t _mapcount;	/* Count of ptes mapped in mms,
 					 * to show when page is mapped
 					 * & limit reverse map searches.
 					 */
+		struct {	/* SLUB uses */
+			short unsigned int inuse;
+			short unsigned int offset;
+		};
+	};
 	union {
 	    struct {
 		unsigned long private;		/* Mapping-private opaque data:
@@ -43,8 +49,15 @@ struct page {
 #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
 	    spinlock_t ptl;
 #endif
+	    struct {			/* SLUB uses */
+		struct page *first_page;	/* Compound pages */
+		struct kmem_cache *slab;	/* Pointer to slab */
+	    };
+	};
+	union {
+		pgoff_t index;		/* Our offset within mapping. */
+		void *freelist;		/* SLUB: pointer to free object */
 	};
-	pgoff_t index;			/* Our offset within mapping. */
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
Index: linux-2.6.21-rc3/include/linux/slab.h
===================================================================
--- linux-2.6.21-rc3.orig/include/linux/slab.h	2007-03-10 10:22:12.000000000 -0800
+++ linux-2.6.21-rc3/include/linux/slab.h	2007-03-10 10:22:24.000000000 -0800
@@ -32,6 +32,7 @@ typedef struct kmem_cache kmem_cache_t _
 #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
 #define SLAB_DESTROY_BY_RCU	0x00080000UL	/* Defer freeing slabs to RCU */
 #define SLAB_MEM_SPREAD		0x00100000UL	/* Spread some memory over cpuset */
+#define SLAB_TRACE		0x00200000UL	/* Trace allocations and frees */
 
 /* Flags passed to a constructor functions */
 #define SLAB_CTOR_CONSTRUCTOR	0x001UL		/* If not set, then deconstructor */
@@ -94,9 +95,14 @@ static inline void *kcalloc(size_t n, si
  * the appropriate general cache at compile time.
  */
 
-#ifdef CONFIG_SLAB
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
+#ifdef CONFIG_SLUB
+#include <linux/slub_def.h>
+#else
 #include <linux/slab_def.h>
+#endif /* !CONFIG_SLUB */
 #else
+
 /*
  * Fallback definitions for an allocator not wanting to provide
  * its own optimized kmalloc definitions (like SLOB).
Index: linux-2.6.21-rc3/include/linux/slub_def.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc3/include/linux/slub_def.h	2007-03-10 10:22:24.000000000 -0800
@@ -0,0 +1,177 @@
+#ifndef _LINUX_SLUB_DEF_H
+#define _LINUX_SLUB_DEF_H
+
+/*
+ * SLUB : A Slab allocator without object queues.
+ *
+ * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/types.h>
+#include <linux/gfp.h>
+#include <linux/workqueue.h>
+
+struct kmem_cache_node {
+	spinlock_t list_lock;	/* Protect partial list and nr_partial */
+	unsigned long nr_partial;
+	atomic_long_t nr_slabs;
+	struct list_head partial;
+};
+
+/*
+ * Slab cache management.
+ */
+struct kmem_cache {
+	int offset;		/* Free pointer offset. */
+	unsigned int order;
+	unsigned long flags;
+	int size;		/* Total size of an object */
+	int objects;		/* Number of objects in slab */
+	struct kmem_cache_node local_node;
+	int refcount;		/* Refcount for destroy */
+	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+	void (*dtor)(void *, struct kmem_cache *, unsigned long);
+
+	int objsize;		/* The size of an object that is in a chunk */
+	int inuse;		/* Used portion of the chunk */
+	const char *name;	/* Name (only for display!) */
+	char *aliases;		/* Slabs merged into this one */
+	struct list_head list;	/* List of slabs */
+#ifdef CONFIG_SMP
+	struct mutex flushing;
+	atomic_t cpu_slabs;	/*
+				 * if >0 then flusher is scheduled. Also used
+				 * to count remaining cpus if flushing
+				 */
+	struct delayed_work flush;
+#endif
+#ifdef CONFIG_NUMA
+	struct kmem_cache_node *node[MAX_NUMNODES];
+#endif
+	struct page *cpu_slab[NR_CPUS];
+};
+
+/*
+ * Kmalloc subsystem.
+ */
+#define KMALLOC_SHIFT_LOW 3
+
+#define KMALLOC_SHIFT_HIGH 18
+
+#if L1_CACHE_BYTES <= 64
+#define KMALLOC_EXTRAS 2
+#define KMALLOC_EXTRA
+#else
+#define KMALLOC_EXTRAS 0
+#endif
+
+#define KMALLOC_NR_CACHES (KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW \
+			 + 1 + KMALLOC_EXTRAS)
+/*
+ * We keep the general caches in an array of slab caches that are used for
+ * 2^x bytes of allocations.
+ */
+extern struct kmem_cache kmalloc_caches[KMALLOC_NR_CACHES];
+
+/*
+ * Sorry that the following has to be that ugly but some versions of GCC
+ * have trouble with constant propagation and loops.
+ */
+static inline int kmalloc_index(int size)
+{
+#ifdef KMALLOC_EXTRA
+	if (size > 64 && size <= 96)
+		return KMALLOC_SHIFT_HIGH + 1;
+	if (size > 128 && size <= 192)
+		return KMALLOC_SHIFT_HIGH + 2;
+#endif
+	if (size <          8) return 3;
+	if (size <         16) return 4;
+	if (size <         32) return 5;
+	if (size <         64) return 6;
+	if (size <        128) return 7;
+	if (size <        256) return 8;
+	if (size <        512) return 9;
+	if (size <       1024) return 10;
+	if (size <   2 * 1024) return 11;
+	if (size <   4 * 1024) return 12;
+	if (size <   8 * 1024) return 13;
+	if (size <  16 * 1024) return 14;
+	if (size <  32 * 1024) return 15;
+	if (size <  64 * 1024) return 16;
+	if (size < 128 * 1024) return 17;
+	if (size < 256 * 1024) return 18;
+
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
+static inline struct kmem_cache *kmalloc_slab(size_t size)
+{
+	int index = kmalloc_index(size) - KMALLOC_SHIFT_LOW;
+
+	if (index < 0) {
+		/*
+		 * Generate a link failure. Would be great if we could
+		 * do something to stop the compile here.
+		 */
+		extern void __kmalloc_size_too_large(void);
+		__kmalloc_size_too_large();
+	}
+	return &kmalloc_caches[index];
+}
+
+#ifdef CONFIG_ZONE_DMA
+#define SLUB_DMA __GFP_DMA
+#else
+/* Disable SLAB functionality */
+#define SLUB_DMA 0
+#endif
+
+static inline void *kmalloc(size_t size, gfp_t flags)
+{
+	if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
+		struct kmem_cache *s = kmalloc_slab(size);
+
+		return kmem_cache_alloc(s, flags);
+	} else
+		return __kmalloc(size, flags);
+}
+
+static inline void *kzalloc(size_t size, gfp_t flags)
+{
+	if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
+		struct kmem_cache *s = kmalloc_slab(size);
+
+		return kmem_cache_zalloc(s, flags);
+	} else
+		return __kzalloc(size, flags);
+}
+
+#ifdef CONFIG_NUMA
+extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
+		struct kmem_cache *s = kmalloc_slab(size);
+
+		return kmem_cache_alloc_node(s, flags, node);
+	} else
+		return __kmalloc_node(size, flags, node);
+}
+#endif
+
+#endif /* _LINUX_SLUB_DEF_H */
Index: linux-2.6.21-rc3/init/Kconfig
===================================================================
--- linux-2.6.21-rc3.orig/init/Kconfig	2007-03-10 10:21:19.000000000 -0800
+++ linux-2.6.21-rc3/init/Kconfig	2007-03-10 10:22:24.000000000 -0800
@@ -474,15 +474,6 @@ config SHMEM
 	  option replaces shmem and tmpfs with the much simpler ramfs code,
 	  which may be appropriate on small systems without swap.
 
-config SLAB
-	default y
-	bool "Use full SLAB allocator" if (EMBEDDED && !SMP && !SPARSEMEM)
-	help
-	  Disabling this replaces the advanced SLAB allocator and
-	  kmalloc support with the drastically simpler SLOB allocator.
-	  SLOB is more space efficient but does not scale well and is
-	  more susceptible to fragmentation.
-
 config VM_EVENT_COUNTERS
 	default y
 	bool "Enable VM event counters for /proc/vmstat" if EMBEDDED
@@ -492,6 +483,46 @@ config VM_EVENT_COUNTERS
 	  on EMBEDDED systems.  /proc/vmstat will only show page counts
 	  if VM event counters are disabled.
 
+choice
+	prompt "Choose SLAB allocator"
+	default SLAB
+	help
+	   This option allows to select a slab allocator.
+
+config SLAB
+	bool "SLAB"
+	help
+	  The regular slab allocator that is established and known to work
+	  well in all environments. It organizes chache hot objects in
+	  per cpu and per node queues. SLAB is the default choice for
+	  slab allocator.
+
+config SLUB
+	depends on EXPERIMENTAL
+	bool "SLUB (Unqueued Allocator)"
+	help
+	   SLUB is a slab allocator that minimizes cache line usage
+	   instead of managing queues of cached objects (SLAB approach).
+	   Per cpu caching is realized using slabs of objects instead
+	   of queues of objects. SLUB can use memory in the most efficient
+	   way and has enhanced diagnostics.
+
+config SLOB
+#
+#	SLOB cannot support SMP because SLAB_DESTROY_BY_RCU does not work
+#	properly.
+#
+	depends on EMBEDDED && !SMP && !SPARSEMEM
+	bool "SLOB (Simple Allocator)"
+	help
+	   SLOB replaces the SLAB allocator with a drastically simpler
+	   allocator.  SLOB is more space efficient that SLAB but does not
+	   scale well (single lock for all operations) and is more susceptible
+	   to fragmentation. SLOB it is a great choice to reduce
+	   memory usage and code size.
+
+endchoice
+
 endmenu		# General setup
 
 config RT_MUTEXES
@@ -507,10 +538,6 @@ config BASE_SMALL
 	default 0 if BASE_FULL
 	default 1 if !BASE_FULL
 
-config SLOB
-	default !SLAB
-	bool
-
 menu "Loadable module support"
 
 config MODULES
Index: linux-2.6.21-rc3/mm/Makefile
===================================================================
--- linux-2.6.21-rc3.orig/mm/Makefile	2007-03-10 10:21:19.000000000 -0800
+++ linux-2.6.21-rc3/mm/Makefile	2007-03-10 13:13:33.000000000 -0800
@@ -25,6 +25,7 @@ obj-$(CONFIG_TMPFS_POSIX_ACL) += shmem_a
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_SLAB) += slab.o
+obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
Index: linux-2.6.21-rc3/mm/slub.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc3/mm/slub.c	2007-03-10 13:14:01.000000000 -0800
@@ -0,0 +1,2293 @@
+/*
+ * SLUB: A slab allocator that limits cache line use instead of queuing
+ * objects in per cpu and per node lists.
+ *
+ * The allocator synchronizes using per slab locks and only
+ * uses a centralized lock to manage a pool of partial slabs.
+ *
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
+
+/*
+ * Lock order:
+ *   1. slab_lock(page)
+ *   2. slab->list_lock
+ *
+ * SLUB assigns one slab for allocation to each processor.
+ * Allocations only occur from these slabs called cpu slabs.
+ *
+ * If a cpu slab exists then a workqueue thread checks every 10
+ * seconds if the cpu slab is still in use. The cpu slab is pushed back
+ * to the list if inactive [only needed for SMP].
+ *
+ * Slabs with free elements are kept on a partial list.
+ * There is no list for full slabs. If an object in a full slab is
+ * freed then the slab will show up again on the partial lists.
+ * Otherwise there is no need to track full slabs (but we keep a counter).
+ *
+ * Slabs are freed when they become empty. Teardown and setup is
+ * minimal so we rely on the page allocators per cpu caches for
+ * fast frees and allocs.
+ *
+ * Overloading of page flags that are otherwise used for LRU management.
+ *
+ * PageActive 		The slab is used as a cpu cache. Allocations
+ * 			may be performed from the slab. The slab is not
+ * 			on a partial list.
+ *
+ * PageReferenced	The per cpu slab was used recently. This is used
+ * 			to push back per cpu slabs if they are unused
+ * 			for a longer time period.
+ *
+ * PageError		Slab requires special handling due to debug
+ * 			options set or a single page slab. This moves
+ * 			slab handling out of the fast path.
+ */
+
+/*
+ * Flags from the regular SLAB that SLUB does not support:
+ */
+#define SLUB_UNIMPLEMENTED (SLAB_DEBUG_INITIAL)
+
+#define DEBUG_DEFAULT_FLAGS (SLAB_DEBUG_FREE | SLAB_RED_ZONE | \
+				SLAB_POISON)
+/*
+ * Set of flags that will prevent slab merging
+ */
+#define SLUB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+		SLAB_TRACE | SLAB_DESTROY_BY_RCU)
+
+#define SLUB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
+		SLAB_CACHE_DMA)
+
+#ifndef ARCH_KMALLOC_MINALIGN
+#define ARCH_KMALLOC_MINALIGN sizeof(void *)
+#endif
+
+#ifndef ARCH_SLAB_MINALIGN
+#define ARCH_SLAB_MINALIGN sizeof(void *)
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
+	UP		/* Everything works */
+} slab_state = DOWN;
+
+int slab_is_available(void) {
+	return slab_state == UP;
+}
+
+/* A list of all slab caches on the system */
+static DECLARE_RWSEM(slub_lock);
+LIST_HEAD(slab_caches);
+
+/********************************************************************
+ * 			Core slab cache functions
+ *******************************************************************/
+
+struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
+{
+#ifdef CONFIG_NUMA
+	return s->node[node];
+#else
+	return &s->local_node;
+#endif
+}
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
+	if (length > 128)
+		length = 128;
+	ascii[16] = 0;
+
+	for (i = 0; i < length; i++) {
+		if (newline) {
+			printk(KERN_ERR "%10s %p: ", text, addr + i);
+			newline = 0;
+		}
+		printk(" %02x", addr[i]);
+		offset = i % 16;
+		ascii[offset] = isgraph(addr[i]) ? addr[i] : '.';
+		if (offset == 15) {
+			printk(" %s\n",ascii);
+			newline = 1;
+		}
+	}
+	if (!newline) {
+		i %= 16;
+		while (i < 16) {
+			printk("   ");
+			ascii[i] = ' ';
+			i++;
+		}
+		printk(" %s\n", ascii);
+	}
+}
+
+/*
+ * Slow version of get and set free pointer.
+ *
+ * This requires touching the cache lines of kmem_cache.
+ * The offset can also be obtained from the page. In that
+ * case it is in the cacheline that we already need to touch.
+ */
+static void *get_freepointer(struct kmem_cache *s, void *object)
+{
+	return *(void **)(object + s->offset);
+}
+
+static void set_freepointer(struct kmem_cache *s, void *object, void *fp)
+{
+	*(void **)(object + s->offset) = fp;
+}
+
+/*
+ * Tracking user of a slab.
+ */
+static void *get_track(struct kmem_cache *s, void *object, int alloc)
+{
+	void **p = object + s->inuse + sizeof(void *);
+
+	return p[alloc];
+}
+
+static void set_track(struct kmem_cache *s, void *object,
+				int alloc, void *addr)
+{
+	void **p = object + s->inuse + sizeof(void *);
+
+	p[alloc] = addr;
+}
+
+#define set_tracking(__s, __o, __a) set_track(__s, __o, __a, \
+			__builtin_return_address(0))
+
+static void init_tracking(struct kmem_cache *s, void *object)
+{
+	if (s->flags & SLAB_STORE_USER) {
+		set_track(s, object, 0, NULL);
+		set_track(s, object, 1, NULL);
+	}
+}
+
+static void print_trailer(struct kmem_cache *s, u8 *p)
+{
+	unsigned int off;	/* Offset of last byte */
+
+	if (s->offset)
+		off = s->offset + sizeof(void *);
+	else
+		off = s->inuse;
+
+	if (s->flags & SLAB_RED_ZONE)
+		print_section("Redzone", p + s->objsize,
+			s->inuse - s->objsize);
+
+	printk(KERN_ERR "FreePointer %p: %p\n",
+			p + s->offset,
+			get_freepointer(s, p));
+
+	if (s->flags & SLAB_STORE_USER) {
+		printk(KERN_ERR "Last Allocate from %p. Last Free from %p\n",
+			get_track(s, p, 0), get_track(s, p, 1));
+		off += 2 * sizeof(void *);
+	}
+
+	if (off != s->size)
+		/* Beginning of the filler is the free pointer */
+		print_section("Filler", p + off, s->size - off);
+}
+
+static void object_err(struct kmem_cache *s, struct page *page,
+			u8 *object, char *reason)
+{
+	u8 *addr = page_address(page);
+
+	printk(KERN_ERR "*** SLUB: %s in %s@%p Slab %p\n",
+			reason, s->name, object, page);
+	printk(KERN_ERR "    offset=%u flags=%04lx inuse=%u freelist=%p\n",
+		(int)(object - addr), page->flags, page->inuse, page->freelist);
+	if (object > addr + 16)
+		print_section("Bytes b4", object - 16, 16);
+	print_section("Object", object, s->objsize);
+	print_trailer(s, object);
+	dump_stack();
+}
+
+static void init_object(struct kmem_cache *s, void *object, int active)
+{
+	u8 *p = object;
+
+	if (s->objects == 1)
+		return;
+
+	if (s->flags & SLAB_POISON) {
+		memset(p, POISON_FREE, s->objsize -1);
+		p[s->objsize -1] = POISON_END;
+	}
+
+	if (s->flags & SLAB_RED_ZONE)
+		memset(p + s->objsize,
+			active ? RED_ACTIVE : RED_INACTIVE,
+			s->inuse - s->objsize);
+}
+
+static int check_bytes(u8 *start, unsigned int value, unsigned int bytes)
+{
+	while (bytes) {
+		if (*start != (u8)value)
+			return 0;
+		start++;
+		bytes--;
+	}
+	return 1;
+}
+
+
+static int check_valid_pointer(struct kmem_cache *s, struct page *page,
+					 void *object)
+{
+	void *base;
+
+	if (!object)
+		return 1;
+
+	base = page_address(page);
+	if (object < base || object >= base + s->objects * s->size ||
+		(object - base) % s->size) {
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Object layout:
+ *
+ * object address
+ * 		Bytes of the object to be managed.
+ * 		If the freepointer may overlay the object then the free
+ * 		pointer is the first word of the object.
+ * 		Poisoning uses 0x6b (POISON_FREE) and the last byte is
+ * 		0xa5 (POISON_END)
+ *
+ * object + s->objsize
+ * 		Padding to reach word boundary. This is also used for Redzoning.
+ * 		Padding is extended to word size if Redzoning is enabled
+ * 		and objsize == inuse.
+ * 		We fill with 0x71 (RED_INACTIVE) for inactive objects and with
+ * 		0xa5 (RED_ACTIVE) for objects in use.
+ *
+ * object + s->inuse
+ * 		A. Free pointer (if we cannot overwrite object on free)
+ * 		B. Tracking data for SLAB_STORE_USER
+ * 		C. Padding to reach required alignment boundary
+ * 			Padding is done using 0x5a (POISON_INUSE)
+ *
+ * object + s->size
+ *
+ * If slabcaches are merged then the objsize and inuse boundaries are to be ignored.
+ * And therefore no slab options that rely on these boundaries may be used with
+ * merged slabcaches.
+ */
+
+static int check_pad_bytes(struct kmem_cache *s, struct page *page, u8 *p)
+{
+	unsigned long off = s->inuse;	/* The end of info */
+
+	if (s->offset)
+		/* Freepointer is placed after the object. */
+		off += sizeof(void *);
+
+	if (s->flags & SLAB_STORE_USER)
+		/* We also have user information there */
+		off += 2 * sizeof(void *);
+
+	if (s->size == off)
+		return 1;
+
+	if (check_bytes(p + off, POISON_INUSE, s->size - off))
+		return 1;
+
+	object_err(s, page, p, "Object padding check fails");
+	return 0;
+}
+
+static int slab_pad_check(struct kmem_cache *s, struct page *page)
+{
+	u8 *p;
+	int length, remainder;
+
+	if (!s->flags & SLAB_POISON)
+		return 1;
+
+	p = page_address(page);
+	length = s->objects * s->size;
+	remainder = (PAGE_SIZE << s->order) - length;
+	if (!remainder)
+		return 1;
+
+	if (!check_bytes(p + length, POISON_INUSE, remainder)) {
+		printk(KERN_ERR "SLUB: %s slab %p: Padding fails check\n",
+			s->name, p);
+		print_section("Slab Pad", p + length, remainder);
+		return 0;
+	}
+	return 1;
+}
+
+static int check_object(struct kmem_cache *s, struct page *page,
+					void *object, int active)
+{
+	u8 *p = object;
+	u8 *endobject = object + s->objsize;
+
+	/* Single object slabs do not get policed */
+	if (s->objects == 1)
+		return 1;
+
+	if (s->flags & SLAB_RED_ZONE) {
+		if (!check_bytes(endobject,
+			active ? RED_ACTIVE : RED_INACTIVE,
+			s->inuse - s->objsize)) {
+				object_err(s, page, object,
+				active ? "Redzone Active check fails" :
+					"Redzone Inactive check fails");
+				return 0;
+		}
+	} else
+	if ((s->flags & SLAB_POISON) &&
+		s->objsize < s->inuse &&
+		!check_bytes(endobject, POISON_INUSE, s->inuse - s->objsize))
+			object_err(s, page, p, "Alignment padding check fails");
+
+	if (s->flags & SLAB_POISON) {
+		if (!active && (!check_bytes(p, POISON_FREE, s->objsize - 1) ||
+				p[s->objsize -1] != POISON_END)) {
+			object_err(s, page, p, "Poison");
+			return 0;
+		}
+		if (!check_pad_bytes(s, page, p))
+			return 0;
+	}
+
+	if (!s->offset && active)
+		/*
+		 * Object and freepointer overlap. Cannot check
+		 * freepointer while object is allocated.
+		 */
+		return 1;
+
+	/* Check free pointer validity */
+	if (!check_valid_pointer(s, page, get_freepointer(s, p))) {
+			object_err(s, page, p, "Freepointer corrupt");
+			/*
+			 * No choice but to zap it. This may cause
+			 * another error because the object count
+			 * is now wrong.
+			 */
+			set_freepointer(s, p, NULL);
+			return 0;
+	}
+	return 1;
+}
+
+static int check_slab(struct kmem_cache *s, struct page *page)
+{
+	if (!PageSlab(page)) {
+		printk(KERN_CRIT "SLUB: %s Not a valid slab page @%p flags=%lx"
+			" mapping=%p count=%d \n",
+			s->name, page, page->flags, page->mapping,
+			page_count(page));
+		return 0;
+	}
+	if (page->offset * sizeof(void *) != s->offset) {
+		printk(KERN_CRIT "SLUB: %s Corrupted offset %lu in slab @%p"
+			" flags=%lx mapping=%p count=%d\n",
+			s->name,
+			(unsigned long)(page->offset * sizeof(void *)),
+			page,
+			page->flags,
+			page->mapping,
+			page_count(page));
+		return 0;
+	}
+	if (page->inuse > s->objects) {
+		printk(KERN_CRIT "SLUB: %s Inuse %u > max %u in slab page @%p"
+			" flags=%lx mapping=%p count=%d\n",
+			s->name, page->inuse, s->objects, page, page->flags,
+			page->mapping, page_count(page));
+		return 0;
+	}
+	return slab_pad_check(s, page);
+}
+
+/*
+ * Determine if a certain object on a page is on the freelist and
+ * therefore free. Must hold the slab lock for cpu slabs to
+ * guarantee that the chains are consistent.
+ */
+static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
+{
+	int nr = 0;
+	void *fp = page->freelist;
+	void *object = NULL;
+
+	if (s->objects == 1)
+		return 0;
+
+	while (fp && nr <= s->objects) {
+		if (fp == search)
+			return 1;
+		if (!check_valid_pointer(s, page, fp)) {
+			if (object) {
+				object_err(s, page, object, "Freechain corrupt");
+				set_freepointer(s, object, NULL);
+				break;
+			} else {
+				printk(KERN_ERR "SLUB: %s slab %p freepointer %p corrupted.\n",
+					s->name, page, fp);
+				dump_stack();
+				page->freelist = NULL;
+				page->inuse = s->objects;
+				return 0;
+			}
+			break;
+		}
+		object = fp;
+		fp = get_freepointer(s, object);
+		nr++;
+	}
+
+	if (page->inuse != s->objects - nr) {
+		printk(KERN_CRIT "slab %s: page %p wrong object count."
+			" counter is %d but counted were %d\n",
+			s->name, page, page->inuse,
+			s->objects - nr);
+		page->inuse = s->objects - nr;
+	}
+	return 0;
+}
+
+static int alloc_object_checks(struct kmem_cache *s, struct page *page,
+							void *object)
+{
+	if (!check_slab(s, page))
+		goto bad;
+
+	if (object && !on_freelist(s, page, object)) {
+		printk(KERN_ERR "SLAB: %s Object %p@%p already allocated.\n",
+			s->name, object, page);
+		goto dump;
+	}
+
+	if (!check_valid_pointer(s, page, object)) {
+		object_err(s, page, object, "Freelist Pointer check fails");
+		goto dump;
+	}
+
+	if (!object)
+		return 1;
+
+	if (!check_object(s, page, object, 0))
+		goto bad;
+	init_object(s, object, 1);
+
+	if (s->flags & SLAB_TRACE) {
+		printk("SLUB-Trace %s alloc object=%p slab=%p inuse=%d"
+			" freelist=%p\n",
+			s->name, object, page, page->inuse,
+			page->freelist);
+		dump_stack();
+	}
+	return 1;
+dump:
+	dump_stack();
+bad:
+	/* Mark slab full */
+	page->inuse = s->objects;
+	page->freelist = NULL;
+	return 0;
+}
+
+static int free_object_checks(struct kmem_cache *s, struct page *page, void *object)
+{
+	if (!check_slab(s, page)) {
+		goto fail;
+	}
+
+	if (!check_valid_pointer(s, page, object)) {
+		printk(KERN_ERR "SLUB: %s slab %p invalid object pointer %p\n",
+			s->name, page, object);
+		goto fail;
+	}
+
+	if (on_freelist(s, page, object)) {
+		printk(KERN_CRIT "SLUB: %s slab %p object %p already free.\n",
+					s->name, page, object);
+		goto fail;
+	}
+
+	if (!check_object(s, page, object, 1))
+		return 0;
+
+	if (unlikely(s != page->slab)) {
+		if (!PageSlab(page))
+			printk(KERN_CRIT "slab_free %s size %d: attempt to"
+				"free object(%p) outside of slab.\n",
+				s->name, s->size, object);
+		else
+		if (!page->slab)
+			printk(KERN_CRIT
+				"slab_free : no slab(NULL) for object %p.\n",
+						object);
+		else
+		printk(KERN_CRIT "slab_free %s(%d): object at %p"
+				" belongs to slab %s(%d)\n",
+				s->name, s->size, object,
+				page->slab->name, page->slab->size);
+		goto fail;
+	}
+	if (s->flags & SLAB_TRACE) {
+		printk("SLUB-Trace %s free object=%p slab=%p"
+			"inuse=%d freelist=%p\n",
+			s->name, object, page, page->inuse,
+			page->freelist);
+		print_section("SLUB-Trace", object, s->objsize);
+		dump_stack();
+	}
+	init_object(s, object, 0);
+	return 1;
+fail:
+	dump_stack();
+	return 0;
+}
+
+/*
+ * Slab allocation and freeing
+ */
+static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct page * page;
+	int pages = 1 << s->order;
+
+	if (s->order)
+		flags |= __GFP_COMP;
+
+	if (s->flags & SLUB_DMA)
+		flags |= GFP_DMA;
+
+	if (node == -1)
+		page = alloc_pages(flags, s->order);
+	else
+		page = alloc_pages_node(node, flags, s->order);
+
+	if (!page)
+		return NULL;
+
+	mod_zone_page_state(page_zone(page),
+		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+		pages);
+
+	return page;
+}
+
+static void setup_object(struct kmem_cache *s, struct page *page,
+				void *object)
+{
+	if (PageError(page)) {
+		init_object(s, object, 0);
+		init_tracking(s, object);
+	}
+
+	if (unlikely(s->ctor)) {
+		int mode = SLAB_CTOR_CONSTRUCTOR;
+
+		if (!(s->flags & __GFP_WAIT))
+			mode |= SLAB_CTOR_ATOMIC;
+
+		s->ctor(object, s, mode);
+	}
+}
+
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct page *page;
+	struct kmem_cache_node *n;
+
+	BUG_ON(flags & ~(GFP_DMA | GFP_LEVEL_MASK | __GFP_NO_GROW));
+	if (flags & __GFP_NO_GROW)
+		return NULL;
+
+	if (flags & __GFP_WAIT)
+		local_irq_enable();
+
+	page = allocate_slab(s, flags & GFP_LEVEL_MASK, node);
+	if (!page)
+		goto out;
+
+	n = get_node(s, page_to_nid(page));
+	if (n)
+		atomic_long_inc(&n->nr_slabs);
+	page->offset = s->offset / sizeof(void *);
+	page->slab = s;
+	page->flags |= 1 << PG_slab;
+	if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
+			SLAB_STORE_USER | SLAB_TRACE) ||
+			s->objects == 1)
+		page->flags |= 1 << PG_error;
+
+	if (s->objects > 1) {
+		void *start = page_address(page);
+		void *end = start + s->objects * s->size;
+		void *last = start;
+		void *p = start + s->size;
+
+		if (unlikely(s->flags & SLAB_POISON))
+			memset(start, POISON_INUSE, PAGE_SIZE << s->order);
+
+		while (p < end) {
+			setup_object(s, page, last);
+			set_freepointer(s, last, p);
+			last = p;
+			p += s->size;
+		}
+
+		setup_object(s, page, last);
+		set_freepointer(s, last, NULL);
+		page->freelist = start;
+		page->inuse = 0;
+	}
+out:
+	if (flags & __GFP_WAIT)
+		local_irq_disable();
+	return page;
+}
+
+static void __free_slab(struct kmem_cache *s, struct page *page)
+{
+	int pages = 1 << s->order;
+
+	if (unlikely(PageError(page) || s->dtor)) {
+		void *start = page_address(page);
+		void *end = start + (pages << PAGE_SHIFT);
+		void *p;
+
+		slab_pad_check(s, page);
+		for (p = start; p <= end - s->size; p += s->size) {
+			if (s->dtor)
+				s->dtor(p, s, 0);
+			check_object(s, page, p, 0);
+		}
+	}
+
+	mod_zone_page_state(page_zone(page),
+		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+		- pages);
+
+	__free_pages(page, s->order);
+}
+
+static void rcu_free_slab(struct rcu_head *h)
+{
+	struct page *page;
+	struct kmem_cache *s;
+
+	page = container_of((struct list_head *)h, struct page, lru);
+	s = page->slab;
+	page->slab = NULL;	/* This is actually page->mapping .... */
+	__free_slab(s, page);
+}
+
+static void free_slab(struct kmem_cache *s, struct page *page)
+{
+	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
+		/*
+		 * RCU free overloads the RCU head over the LRU
+		 */
+		struct rcu_head *head = (void *)&page->lru;
+
+		page->mapping = (void *)s;
+		call_rcu(head, rcu_free_slab);
+	} else
+		__free_slab(s, page);
+}
+
+static void discard_slab(struct kmem_cache *s, struct page *page)
+{
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
+	atomic_long_dec(&n->nr_slabs);
+
+	page->mapping = NULL;
+	reset_page_mapcount(page);
+	page->flags &= ~(1 << PG_slab | 1 << PG_error);
+	free_slab(s, page);
+}
+
+/*
+ * Per slab locking using the pagelock
+ */
+static __always_inline void slab_lock(struct page *page)
+{
+#ifdef CONFIG_SMP
+	bit_spin_lock(PG_locked, &page->flags);
+#endif
+}
+
+static __always_inline void slab_unlock(struct page *page)
+{
+#ifdef CONFIG_SMP
+	bit_spin_unlock(PG_locked, &page->flags);
+#endif
+}
+
+static __always_inline int slab_trylock(struct page *page)
+{
+	int rc = 1;
+#ifdef CONFIG_SMP
+	rc = bit_spin_trylock(PG_locked, &page->flags);
+#endif
+	return rc;
+}
+
+/*
+ * Management of partially allocated slabs
+ */
+static void __always_inline add_partial(struct kmem_cache *s, struct page *page)
+{
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
+	spin_lock(&n->list_lock);
+	n->nr_partial++;
+	list_add_tail(&page->lru, &n->partial);
+	spin_unlock(&n->list_lock);
+}
+
+static void __always_inline remove_partial(struct kmem_cache *s,
+						struct page *page)
+{
+	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+
+	spin_lock(&n->list_lock);
+	list_del(&page->lru);
+	n->nr_partial--;
+	spin_unlock(&n->list_lock);
+}
+
+/*
+ * Lock page and remove it from the partial list
+ *
+ * Must hold list_lock
+ */
+static __always_inline int lock_and_del_slab(struct kmem_cache_node *n,
+						struct page *page)
+{
+	if (slab_trylock(page)) {
+		list_del(&page->lru);
+		n->nr_partial--;
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * Try to get a partial slab from a specific node
+ */
+static struct page *get_partial_node(struct kmem_cache_node *n)
+{
+	struct page *page;
+
+	/*
+	 * Racy check. If we mistakenly see no partial slabs then we
+	 * just allocate an empty slab. If we mistakenly try to get a
+	 * partial slab then get_partials() will return NULL.
+	 */
+	if (!n || !n->nr_partial)
+		return NULL;
+
+	spin_lock(&n->list_lock);
+	list_for_each_entry(page, &n->partial, lru)
+		if (lock_and_del_slab(n, page))
+			goto out;
+	page = NULL;
+out:
+	spin_unlock(&n->list_lock);
+	return page;
+}
+
+/*
+ * Get a page from somewhere. Search in increasing NUMA
+ * distances.
+ */
+static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
+{
+#ifdef CONFIG_NUMA
+	struct zonelist *zonelist = &NODE_DATA(slab_node(current->mempolicy))
+					->node_zonelists[gfp_zone(flags)];
+	struct zone **z;
+	struct page *page;
+
+	for (z = zonelist->zones; *z; z++) {
+		struct kmem_cache_node *n;
+
+		n = get_node(s, zone_to_nid(*z));
+
+		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
+				n->nr_partial > 2) {
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
+static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct page *page;
+	int searchnode = (node == -1) ? numa_node_id() : node;
+
+	page = get_partial_node(get_node(s, searchnode));
+	if (page || (flags & __GFP_THISNODE))
+		return page;
+
+	return get_any_partial(s, flags);
+}
+
+/*
+ * Move a page back to the lists.
+ *
+ * Must be called with the slab lock held.
+ *
+ * On exit the slab lock will have been dropped.
+ */
+static void __always_inline putback_slab(struct kmem_cache *s, struct page *page)
+{
+	if (page->inuse) {
+		if (page->inuse < s->objects)
+			add_partial(s, page);
+		slab_unlock(page);
+	} else {
+		slab_unlock(page);
+		discard_slab(s, page);
+	}
+}
+
+/*
+ * Remove the cpu slab
+ */
+static void __always_inline deactivate_slab(struct kmem_cache *s,
+						struct page *page, int cpu)
+{
+	s->cpu_slab[cpu] = NULL;
+	ClearPageActive(page);
+	ClearPageReferenced(page);
+
+	putback_slab(s, page);
+}
+
+static void flush_slab(struct kmem_cache *s, struct page *page, int cpu)
+{
+	slab_lock(page);
+	deactivate_slab(s, page, cpu);
+}
+
+/*
+ * Flush cpu slab.
+ * Called from IPI handler with interrupts disabled.
+ */
+static void __flush_cpu_slab(struct kmem_cache *s, int cpu)
+{
+	struct page *page = s->cpu_slab[cpu];
+
+	if (likely(page))
+		flush_slab(s, page, cpu);
+}
+
+static void flush_cpu_slab(void *d)
+{
+	struct kmem_cache *s = d;
+	int cpu = smp_processor_id();
+
+	__flush_cpu_slab(s, cpu);
+}
+
+#ifdef CONFIG_SMP
+/*
+ * Called from IPI to check and flush cpu slabs.
+ */
+static void check_flush_cpu_slab(void *private)
+{
+	struct kmem_cache *s = private;
+	int cpu = smp_processor_id();
+	struct page *page = s->cpu_slab[cpu];
+
+	if (page) {
+		if (!TestClearPageReferenced(page))
+			return;
+		flush_slab(s, page, cpu);
+	}
+	atomic_dec(&s->cpu_slabs);
+}
+
+/*
+ * Called from eventd
+ */
+static void flusher(struct work_struct *w)
+{
+	struct kmem_cache *s = container_of(w, struct kmem_cache, flush.work);
+
+	if (!mutex_trylock(&s->flushing))
+		return;
+
+	atomic_set(&s->cpu_slabs, num_online_cpus());
+	on_each_cpu(check_flush_cpu_slab, s, 1, 1);
+	if (atomic_read(&s->cpu_slabs))
+		schedule_delayed_work(&s->flush, 30 * HZ);
+	mutex_unlock(&s->flushing);
+}
+
+static void flush_all(struct kmem_cache *s)
+{
+	if (atomic_read(&s->cpu_slabs)) {
+		mutex_lock(&s->flushing);
+		cancel_delayed_work(&s->flush);
+		atomic_set(&s->cpu_slabs, 0);
+		on_each_cpu(flush_cpu_slab, s, 1, 1);
+		mutex_unlock(&s->flushing);
+	}
+}
+#else
+static void flush_all(struct kmem_cache *s)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	flush_cpu_slab(s);
+	local_irq_restore(flags);
+}
+#endif
+
+static __always_inline void *slab_alloc(struct kmem_cache *s,
+					gfp_t gfpflags, int node)
+{
+	struct page *page;
+	void **object;
+	unsigned long flags;
+	int cpu;
+
+	local_irq_save(flags);
+	cpu = smp_processor_id();
+	page = s->cpu_slab[cpu];
+	if (!page)
+		goto new_slab;
+
+	slab_lock(page);
+	if (unlikely(node != -1 && page_to_nid(page) != node))
+		goto another_slab;
+redo:
+	if (unlikely(!page->freelist))
+		goto another_slab;
+	object = page->freelist;
+	if (unlikely(PageError(page))) {
+		if (!alloc_object_checks(s, page, object))
+			goto another_slab;
+		if (s->flags & SLAB_STORE_USER)
+			set_tracking(s, object, 0);
+	}
+	page->inuse++;
+	page->freelist = object[page->offset];
+	SetPageReferenced(page);
+	slab_unlock(page);
+	local_irq_restore(flags);
+	return object;
+
+another_slab:
+	deactivate_slab(s, page, cpu);
+
+new_slab:
+	page = get_partial(s, gfpflags, node);
+	if (unlikely(!page)) {
+
+		page = new_slab(s, gfpflags, node);
+		if (!page) {
+			local_irq_restore(flags);
+			return NULL;
+		}
+
+		if (s->objects == 1) {
+			local_irq_restore(flags);
+			return page_address(page);
+		}
+
+		if (s->cpu_slab[cpu]) {
+			/*
+			 * Someone else populated the cpu_slab while
+			 * we enabled interrupts. The page may not
+			 * be on the required node.
+			 */
+			if (node == -1 ||
+				page_to_nid(s->cpu_slab[cpu]) == node) {
+				/*
+				 * Current cpuslab is acceptable and we
+				 * want the current one since its cache hot
+				 */
+				discard_slab(s, page);
+				page = s->cpu_slab[cpu];
+				slab_lock(page);
+				goto redo;
+			}
+			flush_slab(s, s->cpu_slab[cpu], cpu);
+		}
+		slab_lock(page);
+	}
+
+	s->cpu_slab[cpu] = page;
+	SetPageActive(page);
+
+#ifdef CONFIG_SMP
+	if (!atomic_read(&s->cpu_slabs) && keventd_up()) {
+		atomic_inc(&s->cpu_slabs);
+		schedule_delayed_work(&s->flush, 30 * HZ);
+	}
+#endif
+	goto redo;
+}
+
+void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
+{
+	return slab_alloc(s, gfpflags, -1);
+}
+EXPORT_SYMBOL(kmem_cache_alloc);
+
+#ifdef CONFIG_NUMA
+void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
+{
+	return slab_alloc(s, gfpflags, node);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node);
+#endif
+
+void kmem_cache_free(struct kmem_cache *s, void *x)
+{
+	struct page * page;
+	void *prior;
+	void **object = (void *)x;
+	unsigned long flags;
+
+	if (!object)
+		return;
+
+	page = virt_to_page(x);
+
+	if (unlikely(PageCompound(page)))
+		page = page->first_page;
+
+	if (!s)
+		s = page->slab;
+
+	local_irq_save(flags);
+
+	if (unlikely(PageError(page)) && s->objects == 1)
+		goto single_object_slab;
+
+	slab_lock(page);
+
+	if (unlikely(PageError(page))) {
+		if (!free_object_checks(s, page, x))
+			goto out_unlock;
+		if (s->flags & SLAB_STORE_USER)
+			set_tracking(s, object, 1);
+	}
+
+	prior = object[page->offset] = page->freelist;
+	page->freelist = object;
+	page->inuse--;
+
+	if (likely(PageActive(page) || (page->inuse && prior)))
+		goto out_unlock;
+
+	if (!prior) {
+		/*
+		 * The slab was full before. It will have one free
+		 * object now. So move to the partial list.
+		 */
+		add_partial(s, page);
+		goto out_unlock;
+	}
+
+	/*
+	 * All object have been freed.
+	 */
+	remove_partial(s, page);
+	slab_unlock(page);
+single_object_slab:
+	discard_slab(s, page);
+	local_irq_restore(flags);
+	return;
+
+out_unlock:
+	slab_unlock(page);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(kmem_cache_free);
+
+/* Figure out on which slab object the object resides */
+static __always_inline struct page *get_object_page(const void *x)
+{
+	struct page *page = virt_to_page(x);
+
+	if (unlikely(PageCompound(page)))
+		page = page->first_page;
+
+	if (!PageSlab(page))
+		return NULL;
+
+	return page;
+}
+
+/*
+ * kmem_cache_open produces objects aligned at "size" and the first object
+ * is placed at offset 0 in the slab (We have no metainformation on the
+ * slab, all slabs are in essence "off slab").
+ *
+ * In order to get the desired alignment one just needs to align the
+ * size.
+ *
+ * Notice that the allocation order determines the sizes of the per cpu
+ * caches. Each processor has always one slab available for allocations.
+ * Increasing the allocation order reduces the number of times that slabs
+ * must be moved on and off the partial lists and therefore may influence
+ * locking overhead.
+ *
+ * The offset is used to relocate the free list link in each object. It is
+ * therefore possible to move the free list link behind the object. This
+ * is necessary for RCU to work properly and also useful for debugging.
+ *
+ * No freelists are necessary if there is only one element per slab.
+ */
+
+/*
+ * Mininum order of slab pages. This influences locking overhead and slab
+ * fragmentation. A higher order reduces the number of partial slabs
+ * and increases the number of allocations possible without having to
+ * take the list_lock.
+ */
+static int slub_min_order = 0;
+
+/*
+ * Minimum number of objects per slab. This is necessary in order to
+ * reduce locking overhead. Similar to the queue size in SLAB.
+ */
+static int slub_min_objects = 8;
+
+/*
+ * Merge control. If this is set then no merging of slab caches will occur.
+ */
+static int slub_nomerge = 0;
+
+/*
+ * Debug settings:
+ */
+static int slub_debug = 0;
+
+static char *slub_debug_slabs = NULL;
+
+static int calculate_order(int size)
+{
+	int order;
+	int rem;
+
+	/*
+	 * If this is an order 0 page then there are no issues with
+	 * fragmentation. We can then create a slab with a single object.
+	 * We need this to support the i386 arch code that uses our
+	 * freelist field (index field) for a list pointer. We neveri
+	 * touch the freelist pointer if we just have one object
+	 */
+	if (size == PAGE_SIZE)
+		return 0;
+
+	for (order = max(slub_min_order, fls(size - 1) - PAGE_SHIFT);
+			order < MAX_ORDER; order++) {
+		unsigned long slab_size = PAGE_SIZE << order;
+
+		if (slab_size < slub_min_objects * size)
+			continue;
+
+		rem = slab_size % size;
+
+		if (rem <= (PAGE_SIZE << order) / 8)
+			break;
+
+	}
+	if (order >= MAX_ORDER)
+		return -E2BIG;
+	return order;
+}
+
+static unsigned long calculate_alignment(unsigned long flags,
+		unsigned long align)
+{
+	if (flags & SLAB_HWCACHE_ALIGN)
+		return L1_CACHE_BYTES;
+	if (flags & SLAB_MUST_HWCACHE_ALIGN)
+		return max(align, (unsigned long)L1_CACHE_BYTES);
+
+	if (align < ARCH_SLAB_MINALIGN)
+		return ARCH_SLAB_MINALIGN;
+
+	return ALIGN(align, sizeof(void *));
+}
+
+static void free_kmem_cache_nodes(struct kmem_cache *s)
+{
+#ifdef CONFIG_NUMA
+	int node;
+
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = s->node[node];
+		if (n && n != &s->local_node)
+			kfree(n);
+		s->node[node] = NULL;
+	}
+#endif
+}
+
+static void init_kmem_cache_node(struct kmem_cache_node *n)
+{
+	memset(n, 0, sizeof(struct kmem_cache_node));
+	atomic_long_set(&n->nr_slabs, 0);
+	spin_lock_init(&n->list_lock);
+	INIT_LIST_HEAD(&n->partial);
+}
+
+static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
+{
+#ifdef CONFIG_NUMA
+	int node;
+	int local_node;
+
+	if (slab_state == UP)
+		local_node = page_to_nid(virt_to_page(s));
+	else
+		local_node = 0;
+
+	for_each_online_node(node) {
+		struct kmem_cache_node *n;
+
+		if (local_node == node)
+			n = &s->local_node;
+		else
+		if (slab_state == DOWN) {
+			/*
+			 * No kmalloc_node yet so do it by hand.
+			 * We know that this is the first slab on the
+			 * node for this slabcache. There are no concurrent
+			 * accesses possible. Which simplifies things.
+			 */
+			unsigned long flags;
+			struct page *page;
+
+			BUG_ON(s->size < sizeof(struct kmem_cache_node));
+			local_irq_save(flags);
+			page = new_slab(s, gfpflags, node);
+
+			BUG_ON(!page);
+			n = page->freelist;
+			page->freelist = *(void **)page->freelist;
+			page->inuse++;
+			local_irq_restore(flags);
+		} else
+			n = kmalloc_node(sizeof(struct kmem_cache_node),
+				gfpflags, node);
+
+		if (!n) {
+			free_kmem_cache_nodes(s);
+			return 0;
+		}
+
+		s->node[node] = n;
+		init_kmem_cache_node(n);
+
+		if (slab_state == DOWN)
+			atomic_long_inc(&n->nr_slabs);
+	}
+#else
+	init_kmem_cache_node(&s->local_node);
+#endif
+	return 1;
+}
+
+static int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
+		const char *name, size_t size,
+		size_t align, unsigned long flags,
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+	int tentative_size;
+
+	memset(s, 0, kmem_size);
+	BUG_ON(flags & SLUB_UNIMPLEMENTED);
+
+	/*
+	 * Enable debugging if selected on the kernel commandline.
+	 */
+	if (slub_debug &&
+		(!slub_debug_slabs ||
+		strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs)) == 0))
+			flags |= slub_debug;
+
+	if ((flags & SLAB_POISON) &&((flags & SLAB_DESTROY_BY_RCU) ||
+			ctor || dtor)) {
+		if (!(slub_debug & SLAB_POISON))
+			printk(KERN_WARNING "SLUB %s: Clearing SLAB_POISON "
+				"because de/constructor exists.\n",
+				s->name);
+		flags &= ~SLAB_POISON;
+	}
+
+	tentative_size = ALIGN(size, calculate_alignment(align, flags));
+
+	/*
+	 * PAGE_SIZE slabs are special in that they are passed through
+	 * to the page allocator. Do not do any debugging in order to avoid
+	 * increasing the size of the object.
+	 */
+	if (size == PAGE_SIZE)
+		flags &= ~(SLAB_RED_ZONE| SLAB_DEBUG_FREE | \
+			SLAB_STORE_USER | SLAB_POISON);
+
+	s->name = name;
+	s->ctor = ctor;
+	s->dtor = dtor;
+	s->objsize = size;
+	s->flags = flags;
+
+	size = ALIGN(size, sizeof(void *));
+
+	/*
+	 * If we redzone then check if we have space through above
+	 * alignment. If not then add an additional word, so
+	 * that we have a guard value to check for overwrites.
+	 */
+	if ((s->flags & SLAB_RED_ZONE) && size == s->objsize)
+		size += sizeof(void *);
+
+	s->inuse = size;
+
+	if (size * 2 < (PAGE_SIZE << calculate_order(size)) &&
+		((flags & (SLAB_DESTROY_BY_RCU | SLAB_POISON)) ||
+		ctor || dtor)) {
+		/*
+		 * Relocate free pointer after the object if it is not
+		 * permitted to overwrite the first word of the object on
+		 * kmem_cache_free.
+		 *
+		 * This is the case if we do RCU, have a constructor or
+		 * destructor or are poisoning the objects.
+		*/
+		s->offset = size;
+		size += sizeof(void *);
+	}
+
+	if (flags & SLAB_STORE_USER)
+		size += 2 * sizeof(void *);
+
+	align = calculate_alignment(flags, align);
+
+	size = ALIGN(size, align);
+	s->size = size;
+
+	s->order = calculate_order(size);
+	if (s->order < 0)
+		goto error;
+
+	s->objects = (PAGE_SIZE << s->order) / size;
+	if (!s->objects || s->objects > 65535)
+		goto error;
+
+	s->refcount = 1;
+
+#ifdef CONFIG_SMP
+	mutex_init(&s->flushing);
+	atomic_set(&s->cpu_slabs, 0);
+	INIT_DELAYED_WORK(&s->flush, flusher);
+#endif
+	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA)) {
+		return 1;
+	}
+error:
+	if (flags & SLAB_PANIC)
+		panic("Cannot create slab %s size=%lu realsize=%u "
+			"order=%u offset=%u flags=%lx\n",
+			s->name, (unsigned long)size, s->size, s->order,
+			s->offset, flags);
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_open);
+
+/*
+ * Check if a given pointer is valid
+ */
+int kmem_ptr_validate(struct kmem_cache *s, const void *object)
+{
+	struct page * page;
+	void *addr;
+
+	page = get_object_page(object);
+
+	if (!page || s != page->slab)
+		/* No slab or wrong slab */
+		return 0;
+
+	addr = page_address(page);
+	if (object < addr || object >= addr + s->objects * s->size)
+		/* Out of bounds */
+		return 0;
+
+	if ((object - addr) & s->size)
+		/* Improperly aligned */
+		return 0;
+
+	/*
+	 * We could also check here if the object is on the slabs freelist.
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
+static int free_list(struct kmem_cache *s, struct kmem_cache_node *n,
+			struct list_head *list)
+{
+	int slabs_inuse = 0;
+	unsigned long flags;
+	struct page *page, *h;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, h, list, lru)
+		if (!page->inuse) {
+			list_del(&page->lru);
+			discard_slab(s, page);
+		} else
+			slabs_inuse++;
+	spin_unlock_irqrestore(&n->list_lock, flags);
+	return slabs_inuse;
+}
+
+/*
+ * Release all resources used by slab cache
+ * (if possible...)
+ */
+static int kmem_cache_close(struct kmem_cache *s)
+{
+	int node;
+
+	flush_all(s);
+
+	/* Attempt to free all objects */
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = get_node(s, node);
+
+		free_list(s, n, &n->partial);
+		if (atomic_long_read(&n->nr_slabs))
+			return 1;
+	}
+	free_kmem_cache_nodes(s);
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_close);
+
+/*
+ * Close a cache and release the kmem_cache structure
+ * (must be used for caches created using kmem_cache_create)
+ */
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+	down_write(&slub_lock);
+	if (s->refcount)
+		s->refcount--;
+	else {
+		list_del(&s->list);
+		BUG_ON(kmem_cache_close(s));
+		kfree(s);
+	}
+	up_write(&slub_lock);
+}
+EXPORT_SYMBOL(kmem_cache_destroy);
+
+static unsigned long slab_objects(struct kmem_cache *s,
+	unsigned long *p_total, unsigned long *p_cpu_slabs,
+	unsigned long *p_partial, unsigned long *nodes)
+{
+	int nr_slabs = 0;
+	int nr_partial_slabs = 0;
+	int nr_cpu_slabs = 0;
+	int in_cpu_slabs = 0;
+	int in_partial_slabs = 0;
+	int cpu;
+	int node;
+	unsigned long flags;
+	struct page *page;
+
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = get_node(s, node);
+
+		nr_slabs += atomic_read(&n->nr_slabs);
+		nr_partial_slabs += n->nr_partial;
+
+		nodes[node] = atomic_read(&n->nr_slabs) +
+				n->nr_partial;
+
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry(page, &n->partial, lru)
+			in_partial_slabs += page->inuse;
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+
+	for_each_possible_cpu(cpu) {
+		page = s->cpu_slab[cpu];
+		if (page) {
+			nr_cpu_slabs++;
+			in_cpu_slabs += page->inuse;
+			nodes[page_to_nid(page)]++;
+		}
+	}
+
+	if (p_partial)
+		*p_partial = nr_partial_slabs;
+
+	if (p_cpu_slabs)
+		*p_cpu_slabs = nr_cpu_slabs;
+
+	if (p_total)
+		*p_total = nr_slabs;
+
+	return in_partial_slabs + in_cpu_slabs +
+		(nr_slabs - nr_partial_slabs - nr_cpu_slabs) * s->objects;
+}
+
+/********************************************************************
+ *		Kmalloc subsystem
+ *******************************************************************/
+
+struct kmem_cache kmalloc_caches[KMALLOC_NR_CACHES] __cacheline_aligned;
+EXPORT_SYMBOL(kmalloc_caches);
+
+#ifdef CONFIG_ZONE_DMA
+static struct kmem_cache *kmalloc_caches_dma[KMALLOC_NR_CACHES];
+#endif
+
+static int __init setup_slub_min_order(char *str)
+{
+	get_option (&str, &slub_min_order);
+
+	return 1;
+}
+
+__setup("slub_min_order=", setup_slub_min_order);
+
+static int __init setup_slub_min_objects(char *str)
+{
+	get_option (&str, &slub_min_objects);
+
+	return 1;
+}
+
+__setup("slub_min_objects=", setup_slub_min_objects);
+
+static int __init setup_slub_nomerge(char *str)
+{
+	slub_nomerge = 1;
+	return 1;
+}
+
+__setup("slub_nomerge", setup_slub_nomerge);
+
+static int __init setup_slub_debug(char *str)
+{
+	if (!str || *str != '=')
+		slub_debug = DEBUG_DEFAULT_FLAGS;
+	else {
+		str++;
+		if (*str == 0 || *str == ',')
+			slub_debug = DEBUG_DEFAULT_FLAGS;
+		else
+		for( ;*str && *str != ','; str++)
+			switch (*str) {
+			case 'f' : case 'F' : slub_debug |= SLAB_DEBUG_FREE;break;
+			case 'z' : case 'Z' : slub_debug |= SLAB_RED_ZONE;break;
+			case 'p' : case 'P' : slub_debug |= SLAB_POISON;break;
+			case 'u' : case 'U' : slub_debug |= SLAB_STORE_USER;break;
+			case 't' : case 'T' : slub_debug |= SLAB_TRACE;break;
+			default:
+				printk(KERN_CRIT "slub_debug option '%c' unknown. skipped\n",*str);
+			}
+	}
+
+	if (*str == ',')
+		slub_debug_slabs = str + 1;
+	return 1;
+}
+
+__setup("slub_debug", setup_slub_debug);
+
+static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
+		const char *name, int size, gfp_t gfp_flags)
+{
+	unsigned int flags = 0;
+
+	if (gfp_flags & SLUB_DMA)
+		flags = SLAB_CACHE_DMA;
+
+	down_write(&slub_lock);
+	if (!kmem_cache_open(s, gfp_flags, name, size, ARCH_KMALLOC_MINALIGN,
+			flags, NULL, NULL))
+		panic("Creation of kmalloc slab %s size=%d failed.\n",
+			name, size);
+	list_add(&s->list, &slab_caches);
+	up_write(&slub_lock);
+	return s;
+}
+
+static struct kmem_cache *get_slab(size_t size, gfp_t flags)
+{
+	int index = kmalloc_index(size) - KMALLOC_SHIFT_LOW;
+
+	/* SLAB allows allocations with zero size. So warn on those */
+	WARN_ON(size == 0);
+	/* Allocation too large? */
+	BUG_ON(index < 0);
+
+#ifdef CONFIG_ZONE_DMA
+	if ((flags & SLUB_DMA)) {
+		struct kmem_cache *s;
+		struct kmem_cache *x;
+		char *text;
+		size_t realsize;
+
+		s = kmalloc_caches_dma[index];
+		if (s)
+			return s;
+
+		/* Dynamically create dma cache */
+		x = kmalloc(kmem_size, flags & ~SLUB_DMA);
+		if (!x)
+			panic("Unable to allocate memory for dma cache\n");
+
+#ifdef KMALLOC_EXTRA
+		if (index <= KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW)
+#endif
+			realsize = 1 << (index + KMALLOC_SHIFT_LOW);
+#ifdef KMALLOC_EXTRA
+		else {
+			index -= KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW +1;
+			if (!index)
+				realsize = 96;
+			else
+				realsize = 192;
+		}
+#endif
+
+		text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
+				(unsigned int)realsize);
+		s = create_kmalloc_cache(x, text, realsize, flags);
+		kmalloc_caches_dma[index] = s;
+		return s;
+	}
+#endif
+	return &kmalloc_caches[index];
+}
+
+void *__kmalloc(size_t size, gfp_t flags)
+{
+	return kmem_cache_alloc(get_slab(size, flags), flags);
+}
+EXPORT_SYMBOL(__kmalloc);
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+	return kmem_cache_alloc_node(get_slab(size, flags),
+							flags, node);
+}
+EXPORT_SYMBOL(__kmalloc_node);
+#endif
+
+size_t ksize(const void *object)
+{
+	struct page *page = get_object_page(object);
+	struct kmem_cache *s;
+
+	BUG_ON(!page);
+	s = page->slab;
+	BUG_ON(!s);
+	/*
+	 * Debugging requires use of the padding between object
+	 * and whatever may come after it.
+	 */
+	if (s->flags & (SLAB_RED_ZONE | SLAB_POISON))
+		return s->objsize;
+	/*
+	 * If we have the need to store the freelist pointer
+	 * back there or track user information then we can
+	 * only use the space before that information.
+	 */
+	if (s->flags & (SLAB_DESTROY_BY_RCU | SLAB_STORE_USER))
+		return s->inuse;
+	/*
+	 * Else we can use all the padding etc for the allocation
+	 */
+	return s->size;
+}
+EXPORT_SYMBOL(ksize);
+
+void kfree(const void *object)
+{
+	kmem_cache_free(NULL, (void *)object);
+}
+EXPORT_SYMBOL(kfree);
+
+/**
+ * krealloc - reallocate memory. The contents will remain unchanged.
+ *
+ * @p: object to reallocate memory for.
+ * @new_size: how many bytes of memory are required.
+ * @flags: the type of memory to allocate.
+ *
+ * The contents of the object pointed to are preserved up to the
+ * lesser of the new and old sizes.  If @p is %NULL, krealloc()
+ * behaves exactly like kmalloc().  If @size is 0 and @p is not a
+ * %NULL pointer, the object pointed to is freed.
+ */
+void *krealloc(const void *p, size_t new_size, gfp_t flags)
+{
+	struct kmem_cache *new_cache;
+	void *ret;
+	struct page *page;
+
+	if (unlikely(!p))
+		return kmalloc(new_size, flags);
+
+	if (unlikely(!new_size)) {
+		kfree(p);
+		return NULL;
+	}
+
+	page = virt_to_page(p);
+
+	if (unlikely(PageCompound(page)))
+		page = page->first_page;
+
+	new_cache = get_slab(new_size, flags);
+
+	/*
+ 	 * If new size fits in the current cache, bail out.
+ 	 */
+	if (likely(page->slab == new_cache))
+		return (void *)p;
+
+	/*
+ 	 * We are on the slow-path here so do not use __cache_alloc
+ 	 * because it bloats kernel text.
+ 	 */
+	ret = kmalloc(new_size, flags);
+	if (ret) {
+		memcpy(ret, p, min(new_size, ksize(p)));
+		kfree(p);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(krealloc);
+
+/********************************************************************
+ *			Basic setup of slabs
+ *******************************************************************/
+
+void __init kmem_cache_init(void)
+{
+	int i;
+	int kmem_cache_node_cache =
+		kmalloc_index(sizeof(struct kmem_cache_node));
+
+	BUG_ON(kmem_cache_node_cache < 0 ||
+		kmem_cache_node_cache > KMALLOC_SHIFT_HIGH);
+
+	/*
+	 * Must first have the slab cache available for the allocations of the
+	 * struct kmalloc_cache_node's. There is special bootstrap code in
+	 * kmem_cache_open for the situation when slab_state == DOWN.
+	 */
+	create_kmalloc_cache(&kmalloc_caches[kmem_cache_node_cache
+			- KMALLOC_SHIFT_LOW],
+			"kmalloc",
+			1 << kmem_cache_node_cache,
+			GFP_KERNEL);
+
+	/* Now we are able to allocate the per node structures */
+	slab_state = PARTIAL;
+
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
+		if (i == kmem_cache_node_cache)
+			continue;
+		create_kmalloc_cache(
+			&kmalloc_caches[i - KMALLOC_SHIFT_LOW],
+			"kmalloc", 1 << i, GFP_KERNEL);
+	}
+
+#ifdef KMALLOC_EXTRA
+	/* Caches that are not of the two-to-the-power-of size */
+	create_kmalloc_cache(&kmalloc_caches
+		[KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW + 1],
+				"kmalloc-96", 96, GFP_KERNEL);
+	create_kmalloc_cache(&kmalloc_caches
+		[KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW + 2],
+				"kmalloc-192", 192, GFP_KERNEL);
+#endif
+	slab_state = UP;
+
+	/* Provide the correct kmalloc names now that the caches are up */
+	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
+		char *name = kasprintf(GFP_KERNEL, "kmalloc-%d", 1 << i);
+
+		BUG_ON(!name);
+		kmalloc_caches[i - KMALLOC_SHIFT_LOW].name = name;
+	};
+
+#ifdef CONFIG_SMP
+	register_cpu_notifier(&slab_notifier);
+#endif
+	if (nr_cpu_ids)	/* Remove when nr_cpu_ids was fixed ! */
+	kmem_size = offsetof(struct kmem_cache, cpu_slab)
+		 + nr_cpu_ids * sizeof(struct page *);
+
+	printk(KERN_INFO "SLUB V5: General Slabs=%ld, HW alignment=%d, "
+		"Processors=%d, Nodes=%d\n",
+		(unsigned long)KMALLOC_SHIFT_HIGH + KMALLOC_EXTRAS + 1
+			- KMALLOC_SHIFT_LOW,
+		L1_CACHE_BYTES,
+		nr_cpu_ids,
+		nr_node_ids);
+}
+
+/*
+ * Find a mergeable slab cache
+ */
+static struct kmem_cache *find_mergeable(size_t size,
+		size_t align, unsigned long flags,
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+	struct list_head *h;
+
+	if (slub_nomerge || (flags & SLUB_NEVER_MERGE))
+		return NULL;
+
+	if (ctor || dtor)
+		return NULL;
+
+	size = ALIGN(size, sizeof(void *));
+	align = calculate_alignment(flags, align);
+	size = ALIGN(size, align);
+
+	list_for_each(h, &slab_caches) {
+		struct kmem_cache *s =
+			container_of(h, struct kmem_cache, list);
+
+		if (size > s->size)
+			continue;
+
+		if (s->flags & SLUB_NEVER_MERGE)
+			continue;
+
+		if (s->dtor || s->ctor)
+			continue;
+
+		if (((flags | slub_debug) & SLUB_MERGE_SAME) !=
+			(s->flags & SLUB_MERGE_SAME))
+				continue;
+		/*
+		 * Check if alignment is compatible.
+		 * Courtesy of Adrian Drzewiecki
+		 */
+		if ((s->size & ~(align -1)) != s->size)
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
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+	struct kmem_cache *s;
+
+	down_write(&slub_lock);
+	s = find_mergeable(size, align, flags, dtor, ctor);
+	if (s) {
+		s->refcount++;
+		if (!s->aliases)
+			s->aliases = kstrdup(name, flags);
+		else {
+			char *x = s->aliases;
+
+			s->aliases = kasprintf(flags, "%s/%s", x, name);
+			kfree(x);
+		}
+
+		/*
+		 * Adjust the object sizes so that we clear
+		 * the complete object on kzalloc.
+		 */
+		s->objsize = max(s->objsize, (int)size);
+		s->inuse = max(s->inuse, (int)ALIGN(size, sizeof(void *)));
+	} else {
+		s = kmalloc(kmem_size, GFP_KERNEL);
+		if (s && kmem_cache_open(s, GFP_KERNEL, name,
+				size, align, flags, ctor, dtor)) {
+			list_add(&s->list, &slab_caches);
+		} else
+			kfree(s);
+	}
+	up_write(&slub_lock);
+	return s;
+}
+EXPORT_SYMBOL(kmem_cache_create);
+
+void *kmem_cache_zalloc(struct kmem_cache *s, gfp_t flags)
+{
+	void *x;
+
+	x = kmem_cache_alloc(s, flags);
+	if (x)
+		memset(x, 0, s->objsize);
+	return x;
+}
+EXPORT_SYMBOL(kmem_cache_zalloc);
+
+/********************************************************************
+ *			Slab proc interface
+ *******************************************************************/
+
+static void print_slubinfo_header(struct seq_file *m)
+{
+	/*
+	 * Output format version, so at least we can change it
+	 * without _too_ many complaints.
+	 */
+	seq_puts(m, "slubinfo - version: 1.0\n");
+	seq_puts(m, "# name            <objects> <order> <objsize> <objperslab>"
+		" <slabs>/<partial>/<cpu> <flags>");
+#ifdef CONFIG_NUMA
+	seq_puts(m, " <nodes>");
+#endif
+	seq_putc(m, '\n');
+}
+
+static void *s_start(struct seq_file *m, loff_t *pos)
+{
+	loff_t n = *pos;
+	struct list_head *p;
+
+	down_read(&slub_lock);
+	if (!n)
+		print_slubinfo_header(m);
+	p = slab_caches.next;
+	while (n--) {
+		p = p->next;
+		if (p == &slab_caches)
+			return NULL;
+	}
+	return list_entry(p, struct kmem_cache, list);
+}
+
+static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	struct kmem_cache *s = p;
+	++*pos;
+	return s->list.next == &slab_caches ?
+		NULL : list_entry(s->list.next, struct kmem_cache, list);
+}
+
+static void s_stop(struct seq_file *m, void *p)
+{
+	up_read(&slub_lock);
+}
+
+static void display_nodes(struct seq_file *m, unsigned long *nodes)
+{
+#ifdef CONFIG_NUMA
+	int node;
+
+	for_each_online_node(node)
+		if (nodes[node])
+			seq_printf(m, " N%d=%lu", node, nodes[node]);
+#endif
+}
+
+static int s_show(struct seq_file *m, void *p)
+{
+	struct kmem_cache *s = p;
+	unsigned long total_slabs;
+	unsigned long cpu_slabs;
+	unsigned long partial_slabs;
+	unsigned long objects;
+	unsigned char options[17];
+	char *d = options;
+	char *x;
+	unsigned long nodes[nr_node_ids];
+
+	objects = slab_objects(s, &total_slabs, &cpu_slabs,
+					&partial_slabs, nodes);
+	if (s->ctor)
+		*d++ = 'C';
+	if (s->dtor)
+		*d++ = 'D';
+	if (s->flags & SLAB_DESTROY_BY_RCU)
+		*d++ = 'R';
+	if (s->flags & SLAB_MEM_SPREAD)
+		*d++ = 'S';
+	if (s->flags & SLAB_CACHE_DMA)
+		*d++ = 'd';
+	if (s->flags & SLAB_RECLAIM_ACCOUNT)
+		*d++ = 'r';
+	if (s->flags & SLAB_PANIC)
+		*d++ = 'p';
+	if (s->flags & SLAB_HWCACHE_ALIGN)
+		*d++ = 'a';
+	if (s->flags & SLAB_MUST_HWCACHE_ALIGN)
+		*d++ = 'A';
+	if (s->flags & SLAB_DEBUG_FREE)
+		*d++ = 'F';
+	if (s->flags & SLAB_DEBUG_INITIAL)
+		*d++ = 'I';
+	if (s->flags & SLAB_STORE_USER)
+		*d++ = 'U';
+	if (s->flags & SLAB_RED_ZONE)
+		*d++ = 'Z';
+	if (s->flags & SLAB_POISON)
+		*d++ = 'P';
+	if (s->flags & SLAB_TRACE)
+		*d++ = 'T';
+
+	*d = 0;
+
+	x = kasprintf(GFP_KERNEL, "%lu/%lu/%lu", total_slabs, partial_slabs,
+						cpu_slabs);
+
+	seq_printf(m, "%-21s %6lu %1d %6u %4d %12s %7s",
+		s->name, objects, s->order, s->objsize, s->objects, x, options);
+
+	kfree(x);
+	display_nodes(m, nodes);
+	if (s->aliases) {
+		seq_putc(m, ' ');
+		seq_puts(m, s->aliases);
+	}
+	seq_putc(m, '\n');
+	return 0;
+}
+
+/*
+ * slabinfo_op - iterator that generates /proc/slabinfo
+ */
+struct seq_operations slubinfo_op = {
+	.start = s_start,
+	.next = s_next,
+	.stop = s_stop,
+	.show = s_show,
+};
+
+#ifdef CONFIG_SMP
+static void for_all_slabs(void (*func)(struct kmem_cache *, int), int cpu)
+{
+	struct list_head *h;
+
+	down_read(&slub_lock);
+	list_for_each(h, &slab_caches) {
+		struct kmem_cache *s =
+			container_of(h, struct kmem_cache, list);
+
+		func(s, cpu);
+	}
+	up_read(&slub_lock);
+}
+
+/*
+ * Use the cpu notifier to insure that the thresholds are recalculated
+ * when necessary.
+ */
+static int __cpuinit slab_cpuup_callback(struct notifier_block *nfb,
+		unsigned long action, void *hcpu)
+{
+	long cpu = (long)hcpu;
+
+	switch (action) {
+	case CPU_UP_CANCELED:
+	case CPU_DEAD:
+		for_all_slabs(__flush_cpu_slab, cpu);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block __cpuinitdata slab_notifier =
+	{ &slab_cpuup_callback, NULL, 0 };
+
+#endif
+
+/***************************************************************
+ *	Compatiblility definitions
+ **************************************************************/
+
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+	flush_all(s);
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
+
+#ifdef CONFIG_NUMA
+
+/*****************************************************************
+ * Generic reaper used to support the page allocator
+ * (the cpu slabs are reaped by a per slab workqueue).
+ *
+ * Maybe move this to the page allocator?
+ ****************************************************************/
+
+static DEFINE_PER_CPU(unsigned long, reap_node);
+
+static void init_reap_node(int cpu)
+{
+	int node;
+
+	node = next_node(cpu_to_node(cpu), node_online_map);
+	if (node == MAX_NUMNODES)
+		node = first_node(node_online_map);
+
+	__get_cpu_var(reap_node) = node;
+}
+
+static void next_reap_node(void)
+{
+	int node = __get_cpu_var(reap_node);
+
+	/*
+	 * Also drain per cpu pages on remote zones
+	 */
+	if (node != numa_node_id())
+		drain_node_pages(node);
+
+	node = next_node(node, node_online_map);
+	if (unlikely(node >= MAX_NUMNODES))
+		node = first_node(node_online_map);
+	__get_cpu_var(reap_node) = node;
+}
+#else
+#define init_reap_node(cpu) do { } while (0)
+#define next_reap_node(void) do { } while (0)
+#endif
+
+#define REAPTIMEOUT_CPUC	(2*HZ)
+
+#ifdef CONFIG_SMP
+static DEFINE_PER_CPU(struct delayed_work, reap_work);
+
+static void cache_reap(struct work_struct *unused)
+{
+	next_reap_node();
+	refresh_cpu_vm_stats(smp_processor_id());
+	schedule_delayed_work(&__get_cpu_var(reap_work),
+				      REAPTIMEOUT_CPUC);
+}
+
+static void __devinit start_cpu_timer(int cpu)
+{
+	struct delayed_work *reap_work = &per_cpu(reap_work, cpu);
+
+	/*
+	 * When this gets called from do_initcalls via cpucache_init(),
+	 * init_workqueues() has already run, so keventd will be setup
+	 * at that time.
+	 */
+	if (keventd_up() && reap_work->work.func == NULL) {
+		init_reap_node(cpu);
+		INIT_DELAYED_WORK(reap_work, cache_reap);
+		schedule_delayed_work_on(cpu, reap_work, HZ + 3 * cpu);
+	}
+}
+
+static int __init cpucache_init(void)
+{
+	int cpu;
+
+	/*
+	 * Register the timers that drain pcp pages and update vm statistics
+	 */
+	for_each_online_cpu(cpu)
+		start_cpu_timer(cpu);
+	return 0;
+}
+__initcall(cpucache_init);
+#endif
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
