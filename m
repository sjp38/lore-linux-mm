Date: Wed, 21 Feb 2007 23:00:30 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: The unqueued Slab allocator
Message-ID: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a new slab allocator which was motivated by the complexity of the
existing code in mm/slab.c. It attempts to address a variety of concerns 
with the existing implementation.

A. Management of object queues

   A particular concern was the complex management of the numerous object
   queues in SLAB. SLUB has no such queues. Instead we dedicate a slab for
   each cpus allocating and use a slab directly instead of objects
   from queues.

B. Storage overhead of object queues

   SLAB Object queues exist per node, per cpu. The alien cache queue even
   has a queue array that contain a queue for each processor on each
   node. For very large systems the number of queues and the number of 
   objects that may be caught in those queues grows exponentially. On our
   systems with 1k nodes / processors we have several gigabytes just tied up
   for storing references to objects for those queues  This does not include
   the objects that could be on those queues. One fears that the whole
   memory of the machine could one day be consumed by those queues.

C. SLAB metadata overhead

   SLAB has overhead at the beginning of each slab. This means that data
   cannot be naturally aligned at the beginning of a slab block. SLUB keeps
   all metadata in the corresponding page_struct. Objects can be naturally
   aligned in the slab. F.e. a 128 byte object will be aligned at 128 byte
   boundaries and can fit tightly into a 4k page with no bytes left over. 
   SLAB cannot do this.

D. SLAB has a complex cache reaper

   SLUB does not need a cache reaper for UP systems. On SMP systems
   the per cpu slab may be pushed back into partial list but that
   operation is simple and does not require an iteration over a list
   of objects. SLAB expires per cpu, shared and alien object queues 
   during cache reaping which may cause strange holdoffs.

E. SLAB's has a complex NUMA policy layer support.

   SLUB pushes NUMA policy handling into the page allocator. This means that
   allocation is coarser (SLUB does interleave on a page level) but that
   situation was also present before 2.6.13. SLABs application of 
   policies to individual slab objects allocated in SLAB is 
   certainly a performance concern due to the frequent references to
   memory policies which may lead a sequence of objects to come from
   one node after another. SLUB will get a slab full of objects
   from one node and then will switch to the next.

F. Reduction of the size of partial slab lists

   SLAB has per node partial lists. This means that over time a large
   number of partial slabs may accumulate on those lists. These can
   only be reused if allocator occur on specific nodes. SLUB has a global
   pool of partial slabs and will consume slabs from that pool to
   decrease fragmentation.

G. Tunables

   SLAB has sophisticated tuning abilities for each slab cache. One can
   manipulate the queue sizes in detail. However, filling the queues still
   requires the uses of the spinlock to check out slabs. SLUB has a global
   parameter (min_slab_order) for tuning. Increasing the minimum slab
   order can decrease the locking overhead. The bigger the slab order the
   less motions of pages between per cpu and partial lists occur and the
   better SLUB will be scaling.

G. Slab merging

   We often have slab caches with similar parameters. SLUB detects those
   on bootup and merges them into the corresponding general caches. This
   leads to more effective memory use.

The patch here is only the core portion. There are various add-ons
that may become ready later when this one has matured a bit. SLUB should
be fine for UP and SMP. No NUMA optimizations have been done so far so
it works but it does not scale to the high processor and node numbers yet.

To use SLUB: Apply this patch and then select SLUB as the default slab
allocator. The output of /proc/slabinfo will then change. Here is a
sample (this is an UP/SMP format. The NUMA display will show on which nodes
the slabs were allocated):

slubinfo - version: 1.0
# name            <objects> <order> <objsize> <slabs>/<partial>/<cpu> <flags>
radix_tree_node         5574 0     560      797/0/1    CP
bdev_cache                 5 0     768        2/1/1 CSrPa
sysfs_dir_cache         5946 0      80      117/0/1
inode_cache             2690 0     536      386/3/1  CSrP
dentry_cache            7735 0     192      369/1/1   SrP
idr_layer_cache           79 0     536       12/0/1     C
buffer_head             5427 0     112      151/0/1  CSrP
mm_struct                 37 1     832        6/5/1    Pa
vm_area_struct          1734 0     168       73/3/1     P
files_cache               37 0     640        8/6/1    Pa
signal_cache              63 0     640       12/4/1    Pa
sighand_cache             63 2    2112       11/4/1  CRPa
task_struct               75 2    1728       11/6/1     P
anon_vma                 590 0      24        4/3/1   CRP
kmalloc-192              424 0     192       21/0/1
kmalloc-96              1150 0      96       28/3/1
kmalloc-262144             0 6  262144        0/0/0
kmalloc-131072             0 5  131072        0/0/0
kmalloc-65536              0 4   65536        0/0/0
kmalloc-32768              0 3   32768        0/0/0
kmalloc-16384              0 2   16384        0/0/0
kmalloc-8192              15 1    8192       15/0/0
kmalloc-4096              89 0    4096       89/0/0
kmalloc-2048             175 0    2048       89/3/1
kmalloc-1024             725 0    1024      183/3/1
kmalloc-512              127 0     512       17/2/1
kmalloc-256              781 0     256      51/14/1
kmalloc-128              429 0     128       15/2/1
kmalloc-64              2570 0      64      44/17/1
kmalloc-32               632 0      32        5/0/1
kmalloc-16              2791 0      16       11/1/1
kmalloc-8                412 0       8        1/0/1

I am having a hard time getting all the work on this one done. Things 
keep slipping as other issues come up. I hope that this can go into
mm and benefit there from the attention by others. There are certainly 
numerous issues still to be ironed out.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.20-mm2/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.20-mm2.orig/fs/proc/proc_misc.c	2007-02-21 21:58:50.000000000 -0800
+++ linux-2.6.20-mm2/fs/proc/proc_misc.c	2007-02-21 22:00:24.000000000 -0800
@@ -399,7 +399,7 @@
 };
 #endif
 
-#ifdef CONFIG_SLAB
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 extern struct seq_operations slabinfo_op;
 extern ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
 static int slabinfo_open(struct inode *inode, struct file *file)
@@ -409,7 +409,9 @@
 static const struct file_operations proc_slabinfo_operations = {
 	.open		= slabinfo_open,
 	.read		= seq_read,
+#ifdef CONFIG_SLAB
 	.write		= slabinfo_write,
+#endif
 	.llseek		= seq_lseek,
 	.release	= seq_release,
 };
@@ -791,7 +793,7 @@
 #endif
 	create_seq_entry("stat", 0, &proc_stat_operations);
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
-#ifdef CONFIG_SLAB
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 	create_seq_entry("slab_allocators", 0 ,&proc_slabstats_operations);
Index: linux-2.6.20-mm2/include/linux/mm_types.h
===================================================================
--- linux-2.6.20-mm2.orig/include/linux/mm_types.h	2007-02-21 21:58:50.000000000 -0800
+++ linux-2.6.20-mm2/include/linux/mm_types.h	2007-02-21 22:07:08.000000000 -0800
@@ -19,10 +19,16 @@
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
@@ -43,8 +49,15 @@
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
Index: linux-2.6.20-mm2/include/linux/slab.h
===================================================================
--- linux-2.6.20-mm2.orig/include/linux/slab.h	2007-02-21 21:58:50.000000000 -0800
+++ linux-2.6.20-mm2/include/linux/slab.h	2007-02-21 22:05:16.000000000 -0800
@@ -94,9 +94,14 @@
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
Index: linux-2.6.20-mm2/include/linux/slub_def.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-mm2/include/linux/slub_def.h	2007-02-21 22:00:24.000000000 -0800
@@ -0,0 +1,159 @@
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
+/*
+ * Slab cache management.
+ */
+struct kmem_cache {
+	spinlock_t list_lock;	/* Protecty partial list and nr_partial */
+	struct list_head partial;
+	unsigned long nr_partial;
+	int offset;		/* Free pointer offset. */
+	struct page *cpu_slab[NR_CPUS];
+	atomic_long_t nr_slabs[MAX_NUMNODES];
+	unsigned int order;
+	unsigned long flags;
+	int size;		/* Total size of an object */
+	int objects;		/* Number of objects in slab */
+	atomic_t refcount;	/* Refcount for destroy */
+	int align;
+	void (*ctor)(void *, struct kmem_cache *, unsigned long);
+	void (*dtor)(void *, struct kmem_cache *, unsigned long);
+
+	int objsize;		/* The size of an object that is in a chunk */
+	int inuse;		/* Used portion of the chunk */
+	const char *name;	/* Name (only for display!) */
+	struct list_head list;	/* List of slabs */
+#ifdef CONFIG_SMP
+	struct mutex flushing;
+	atomic_t cpu_slabs;	/* if >0 then flusher is scheduled */
+	struct delayed_work flush;
+#endif
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
+ * 2^x bytes of allocations. For each size we generate a DMA and a
+ * non DMA cache (DMA simply means memory for legacy I/O. The regular
+ * caches can be used for devices that can DMA to all of memory).
+ */
+extern struct kmem_cache kmalloc_caches[KMALLOC_NR_CACHES];
+
+/*
+ * Sorry that the following has to be that ugly but GCC has trouble
+ * with constant propagation and loops.
+ */
+static inline int kmalloc_index(int size)
+{
+	if (size <=    8) return 3;
+	if (size <=   16) return 4;
+	if (size <=   32) return 5;
+	if (size <=   64) return 6;
+#ifdef KMALLOC_EXTRA
+	if (size <=   96) return KMALLOC_SHIFT_HIGH + 1;
+#endif
+	if (size <=  128) return 7;
+#ifdef KMALLOC_EXTRA
+	if (size <=  192) return KMALLOC_SHIFT_HIGH + 2;
+#endif
+	if (size <=  256) return 8;
+	if (size <=  512) return 9;
+	if (size <= 1024) return 10;
+	if (size <= 2048) return 11;
+	if (size <= 4096) return 12;
+	if (size <=   8 * 1024) return 13;
+	if (size <=  16 * 1024) return 14;
+	if (size <=  32 * 1024) return 15;
+	if (size <=  64 * 1024) return 16;
+	if (size <= 128 * 1024) return 17;
+	if (size <= 256 * 1024) return 18;
+	return -1;
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
Index: linux-2.6.20-mm2/init/Kconfig
===================================================================
--- linux-2.6.20-mm2.orig/init/Kconfig	2007-02-21 21:58:50.000000000 -0800
+++ linux-2.6.20-mm2/init/Kconfig	2007-02-21 22:00:24.000000000 -0800
@@ -481,15 +481,6 @@
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
@@ -537,6 +528,44 @@
 	  Say Y here if you want to enable RCU tracing
 	  Say N if you are unsure.
 
+choice
+	prompt "Choose SLAB allocator"
+	default SLAB
+	help
+	   This options allows the use of alternate SLAB allocators.
+
+config SLAB
+	bool "Regular SLAB Allocator"
+	help
+	  The regular slab allocator that is established and known to work
+	  well in all environments. It organizes chache hot objects in
+	  per cpu and per node queues. SLAB has advanced debugging
+	  capabilities. SLAB is the default choice for slab allocator.
+
+config SLUB
+	depends on EXPERIMENTAL
+	bool "SLUB (EXPERIMENTAL Unqueued Allocator)"
+	help
+	   SLUB is a slab allocator that minimizes cache line usage
+	   instead of managing queues of cached objects (SLAB approach).
+	   Per cpu caching is realized using slabs of objects instead
+	   of queues of objects.
+
+config SLOB
+#
+#	SLOB does not support SMP because SLAB_DESTROY_BY_RCU is not support.
+#
+	depends on EMBEDDED && !SMP
+	bool "SLOB (Simple Allocator)"
+	help
+	   SLOB replaces the SLAB allocator with a drastically simpler
+	   allocator.  SLOB is more space efficient but does not scale
+	   well (single lock for all operations) and is more susceptible
+	   to fragmentation. SLOB it is a great choice to reduce
+	   memory usage and code size.
+
+endchoice
+
 endmenu		# General setup
 
 config RT_MUTEXES
@@ -552,10 +581,6 @@
 	default 0 if BASE_FULL
 	default 1 if !BASE_FULL
 
-config SLOB
-	default !SLAB
-	bool
-
 menu "Loadable module support"
 
 config MODULES
Index: linux-2.6.20-mm2/mm/Makefile
===================================================================
--- linux-2.6.20-mm2.orig/mm/Makefile	2007-02-21 21:58:50.000000000 -0800
+++ linux-2.6.20-mm2/mm/Makefile	2007-02-21 22:00:24.000000000 -0800
@@ -26,6 +26,7 @@
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_SLAB) += slab.o
+obj-$(CONFIG_SLUB) += slub.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
Index: linux-2.6.20-mm2/mm/slub.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-mm2/mm/slub.c	2007-02-21 22:12:51.000000000 -0800
@@ -0,0 +1,1610 @@
+/*
+ * SLUB: A slab allocator that limits cache line use instead of queuing
+ * objects in per cpu and per node lists.
+ *
+ * The allocator synchronizes using per slab locks and only
+ * uses a centralized lock to manage a pool of partial slabs.
+ *
+ * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
+ *
+ * This is only a (hopefully) safe core implementation.
+ * Pending pieces:
+ *
+ * 	A. Slab defragmentation support
+ * 	B. NUMA cache line optimizations and per node partial lists.
+ * 	C. Lockless allocs via separate freelists for cpu slabs
+ * 	D. Lockless partial list handling
+ *
+ *  Futher issues to solve:
+ *
+ * 	1. Support the Slab debugging options
+ * 	2. Move logic for draining page allocator queues
+ * 	   into the page allocator.
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
+
+/*
+ * Overloading of page flags that are otherwise used for LRU management.
+ *
+ * PageActive 		The slab is used as an cpu cache. Allocations
+ * 			may be performed from the slab. The slab is not
+ * 			on a partial list.
+ *
+ * PageReferenced	The per cpu slab was used recently. This is used
+ * 			to push back per cpu slabs if they are unused
+ * 			for a longer time period.
+ *
+ * PagePrivate		Only a single object exists per slab. Objects are not
+ * 			cached instead we use the page allocator for
+ * 			object allocation and freeing.
+ */
+
+/*
+ * Flags from the regular SLAB that we have not implemented
+ */
+#define SLUB_UNIMPLEMENTED (SLAB_DEBUG_FREE | SLAB_DEBUG_INITIAL | \
+	SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
+
+/*
+ * Enabling SLUB_DEBUG results in internal consistency checks
+ * being enabled.
+ */
+#undef SLUB_DEBUG
+
+/*
+ * SLUB_DEBUG_KFREE enabled checking for double frees. In order to do this
+ * we have to look through the free lists of object in a slab on kfree which
+ * may slightly reduce performance.
+ */
+#define SLUB_DEBUG_KFREE
+
+/*
+ * SLUB_MERGE causes multiple slabs that have the same object size to be
+ * combined. This reduces the number of _labs significantly. This in turn
+ * increases the chance of finding cache hot objects. However, the slab
+ * statistics are only kept per slab and thus one will not be able to
+ * separate out the uses of various slabs.
+ */
+#ifndef SLUB_DEBUG
+#define SLUB_MERGE
+#endif
+
+/*
+ * Set of flags that will prohibit slab merging
+ */
+#define SLUB_NO_MERGE (SLAB_RECLAIM_ACCOUNT | SLAB_DESTROY_BY_RCU | \
+	SLAB_CACHE_DMA | SLAB_DEBUG_FREE | SLAB_DEBUG_INITIAL | \
+	SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
+
+#ifndef ARCH_KMALLOC_MINALIGN
+#define ARCH_KMALLOC_MINALIGN sizeof(void *)
+#endif
+
+#ifndef ARCH_SLAB_MINALIGN
+#define ARCH_SLAB_MINALIGN sizeof(void *)
+#endif
+
+/*
+ * Forward declarations
+ */
+static void register_slab(struct kmem_cache *s);
+static void unregister_slab(struct kmem_cache *s);
+
+#ifdef CONFIG_SMP
+static struct notifier_block slab_notifier;
+#endif
+
+/********************************************************************
+ * 			Core slab cache functions
+ *******************************************************************/
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
+ * Leftover slabs with free elements are kept on a partial list.
+ * There is no list for full slabs. If an object in a full slab is
+ * freed then the slab will show up again on the partial lists.
+ * Otherwise there is no need to track full slabs (but we keep a counter).
+ *
+ * Slabs are freed when they become empty. Teardown and setup is
+ * minimal so we rely on the page allocators per cpu caches for
+ * fast frees and allocs.
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
+	if (unlikely(s->ctor)) {
+		void *start = page_address(page);
+		void *end = start + (pages << PAGE_SHIFT);
+		void *p;
+		int mode = 1;
+
+		if (!(flags & __GFP_WAIT))
+			mode |= 2;
+
+		for (p = start; p <= end - s->size; p += s->size)
+			s->ctor(p, s, mode);
+	}
+	return page;
+}
+
+static void __free_slab(struct kmem_cache *s, struct page *page)
+{
+	int pages = 1 << s->order;
+
+	if (unlikely(s->dtor)) {
+		void *start = page_address(page);
+		void *end = start + (pages << PAGE_SHIFT);
+		void *p;
+
+		for (p = start; p <= end - s->size; p += s->size)
+			s->dtor(p, s, 0);
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
+	s = (struct kmem_cache *)page->mapping;
+	page->mapping = NULL;
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
+/*
+ * Locking for each individual slab using the pagelock
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
+	spin_lock(&s->list_lock);
+	s->nr_partial++;
+	list_add_tail(&page->lru, &s->partial);
+	spin_unlock(&s->list_lock);
+}
+
+static void __always_inline remove_partial(struct kmem_cache *s,
+						struct page *page)
+{
+	spin_lock(&s->list_lock);
+	list_del(&page->lru);
+	s->nr_partial--;
+	spin_unlock(&s->list_lock);
+}
+
+/*
+ * Lock page and remove it from the partial list
+ *
+ * Must hold list_lock
+ */
+static __always_inline int lock_and_del_slab(struct kmem_cache *s,
+						struct page *page)
+{
+	if (slab_trylock(page)) {
+		list_del(&page->lru);
+		s->nr_partial--;
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * Get a partial page, lock it and return it.
+ */
+#ifdef CONFIG_NUMA
+static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct page *page;
+	int searchnode = (node == -1) ? numa_node_id() : node;
+
+	if (!s->nr_partial)
+		return NULL;
+
+	spin_lock(&s->list_lock);
+	/*
+	 * Search for slab on the right node
+	 */
+	list_for_each_entry(page, &s->partial, lru)
+		if (likely(page_to_nid(page) == searchnode) &&
+			lock_and_del_slab(s, page))
+				goto out;
+
+	if (likely(!(flags & __GFP_THISNODE))) {
+		/*
+		 * We can fall back to any other node in order to
+		 * reduce the size of the partial list.
+		 */
+		list_for_each_entry(page, &s->partial, lru)
+			if (likely(lock_and_del_slab(s, page)))
+				goto out;
+	}
+
+	/* Nothing found */
+	page = NULL;
+out:
+	spin_unlock(&s->list_lock);
+	return page;
+}
+#else
+static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct page *page;
+
+	/*
+	 * Racy check. If we mistakenly see no partial slabs then we
+	 * just allocate an empty slab.
+	 */
+	if (!s->nr_partial)
+		return NULL;
+
+	spin_lock(&s->list_lock);
+	list_for_each_entry(page, &s->partial, lru)
+		if (likely(lock_and_del_slab(s, page)))
+			goto out;
+
+	/* No slab or all slabs busy */
+	page = NULL;
+out:
+	spin_unlock(&s->list_lock);
+	return page;
+}
+#endif
+
+/*
+ * Debugging checks
+ */
+static void check_slab(struct page *page)
+{
+#ifdef SLUB_DEBUG
+	if (!PageSlab(page)) {
+		printk(KERN_CRIT "Not a valid slab page @%p flags=%lx"
+			" mapping=%p count=%d \n",
+			page, page->flags, page->mapping, page_count(page));
+		BUG();
+	}
+#endif
+}
+
+static int check_valid_pointer(struct kmem_cache *s, struct page *page,
+					 void *object, void *origin)
+{
+#ifdef SLUB_DEBUG
+	void *base = page_address(page);
+
+	if (object < base || object >= base + s->objects * s->size) {
+		printk(KERN_CRIT "slab %s size %d: pointer %p->%p\nnot in"
+			" range (%p-%p) in page %p\n", s->name, s->size,
+			origin, object, base, base + s->objects * s->size,
+			page);
+		return 0;
+	}
+
+	if ((object - base) % s->size) {
+		printk(KERN_CRIT "slab %s size %d: pointer %p->%p\n"
+			"does not properly point"
+			"to an object in page %p\n",
+			s->name, s->size, origin, object, page);
+		return 0;
+	}
+#endif
+	return 1;
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
+	void **object = page->freelist;
+	void *origin = &page->lru;
+
+	if (PagePrivate(page))
+		return 0;
+
+	check_slab(page);
+
+	while (object && nr <= s->objects) {
+		if (object == search)
+			return 1;
+		if (!check_valid_pointer(s, page, object, origin))
+			goto try_recover;
+		origin = object;
+		object = object[s->offset];
+		nr++;
+	}
+
+	if (page->inuse != s->objects - nr) {
+		printk(KERN_CRIT "slab %s: page %p wrong object count."
+			" counter is %d but counted were %d\n",
+			s->name, page, page->inuse,
+			s->objects - nr);
+try_recover:
+		printk(KERN_CRIT "****** Trying to continue by marking "
+			"all objects in the slab used (memory leak!)\n");
+		page->inuse = s->objects;
+		page->freelist =  NULL;
+	}
+	return 0;
+}
+
+void check_free_chain(struct kmem_cache *s, struct page *page)
+{
+#ifdef SLUB_DEBUG
+	on_freelist(s, page, NULL);
+#endif
+}
+
+static void discard_slab(struct kmem_cache *s, struct page *page)
+{
+	atomic_long_dec(&s->nr_slabs[page_to_nid(page)]);
+
+	page->mapping = NULL;
+	reset_page_mapcount(page);
+	__ClearPageSlab(page);
+	__ClearPagePrivate(page);
+
+	free_slab(s, page);
+}
+
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+{
+	struct page *page;
+
+	if (flags & __GFP_WAIT)
+		local_irq_enable();
+
+	page = allocate_slab(s, flags, node);
+	if (!page)
+		goto out;
+
+	page->offset = s->offset;
+
+	atomic_long_inc(&s->nr_slabs[page_to_nid(page)]);
+
+	page->slab = (struct kmem_cache *)s;
+	__SetPageSlab(page);
+
+	if (s->objects > 1) {
+		void *start = page_address(page);
+		void *end = start + s->objects * s->size;
+		void **last = start;
+		void *p = start + s->size;
+
+		while (p < end) {
+			last[s->offset] = p;
+			last = p;
+			p += s->size;
+		}
+		last[s->offset] = NULL;
+		page->freelist = start;
+		page->inuse = 0;
+		check_free_chain(s, page);
+	} else
+		__SetPagePrivate(page);
+
+out:
+	if (flags & __GFP_WAIT)
+		local_irq_disable();
+	return page;
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
+/*
+ * Flush cpu slab
+ * Called from IPI handler with interrupts disabled.
+ */
+static void __flush_cpu_slab(struct kmem_cache *s, int cpu)
+{
+	struct page *page = s->cpu_slab[cpu];
+
+	if (likely(page)) {
+		slab_lock(page);
+		deactivate_slab(s, page, cpu);
+	}
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
+ * Called from IPI during flushing to check and flush cpu slabs.
+ */
+void check_flush_cpu_slab(void *d)
+{
+	struct kmem_cache *s = d;
+	int cpu = smp_processor_id();
+	struct page *page = s->cpu_slab[cpu];
+
+	if (!page)
+		return;
+
+	if (PageReferenced(page)) {
+		ClearPageReferenced(page);
+		atomic_inc(&s->cpu_slabs);
+	} else {
+		slab_lock(page);
+		deactivate_slab(s, page, cpu);
+	}
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
+		schedule_delayed_work(&s->flush, 2 * HZ);
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
+static __always_inline void *__slab_alloc(struct kmem_cache *s,
+					gfp_t gfpflags, int node)
+{
+	struct page *page;
+	void **object;
+	void *next_object;
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
+	check_free_chain(s, page);
+	if (unlikely(!page->freelist))
+		goto another_slab;
+
+	if (unlikely(node != -1 && page_to_nid(page) != node))
+		goto another_slab;
+redo:
+	page->inuse++;
+	object = page->freelist;
+	page->freelist = next_object = object[page->offset];
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
+	if (page)
+		goto gotpage;
+
+	page = new_slab(s, flags, node);
+	if (!page) {
+		local_irq_restore(flags);
+		return NULL;
+	}
+
+	/*
+	 * There is no point in putting single object slabs
+	 * on a partial list.
+	 */
+	if (unlikely(s->objects == 1)) {
+		local_irq_restore(flags);
+		return page_address(page);
+	}
+
+	slab_lock(page);
+
+gotpage:
+	if (s->cpu_slab[cpu]) {
+		slab_unlock(page);
+		discard_slab(s, page);
+		page = s->cpu_slab[cpu];
+		slab_lock(page);
+	} else
+		s->cpu_slab[cpu] = page;
+
+	SetPageActive(page);
+	check_free_chain(s, page);
+
+#ifdef CONFIG_SMP
+	if (keventd_up() && !atomic_read(&s->cpu_slabs)) {
+		atomic_inc(&s->cpu_slabs);
+		schedule_delayed_work(&s->flush, 2 * HZ);
+	}
+#endif
+	goto redo;
+}
+
+void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
+{
+	return __slab_alloc(s, gfpflags, -1);
+}
+EXPORT_SYMBOL(kmem_cache_alloc);
+
+#ifdef CONFIG_NUMA
+void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
+{
+	return __slab_alloc(s, gfpflags, node);
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
+#ifdef SLUB_DEBUG
+	if (unlikely(s != page->slab))
+		goto slab_mismatch;
+	if (unlikely(!check_valid_pointer(s, page, object, NULL)))
+		goto dumpret;
+#endif
+
+	local_irq_save(flags);
+	if (unlikely(PagePrivate(page)))
+		goto single_object_slab;
+	slab_lock(page);
+
+#ifdef SLUB_DEBUG_KFREE
+	if (on_freelist(s, page, object))
+		goto double_free;
+#endif
+
+	prior = object[page->offset] = page->freelist;
+	page->freelist = object;
+	page->inuse--;
+
+	if (likely(PageActive(page) || (page->inuse && prior))) {
+out_unlock:
+		slab_unlock(page);
+		local_irq_restore(flags);
+		return;
+	}
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
+#ifdef SLUB_DEBUG_KFREE
+double_free:
+	printk(KERN_CRIT "slab_free %s: object %p already free.\n",
+					s->name, object);
+	dump_stack();
+	goto out_unlock;
+#endif
+
+#ifdef SLUB_DEBUG
+slab_mismatch:
+	if (!PageSlab(page)) {
+		printk(KERN_CRIT "slab_free %s size %d: attempt to free "
+			"object(%p) outside of slab.\n",
+			s->name, s->size, object);
+		goto dumpret;
+	}
+
+	if (!page->slab) {
+		printk(KERN_CRIT
+			"slab_free : no slab(NULL) for object %p.\n",
+					object);
+			goto dumpret;
+	}
+
+	printk(KERN_CRIT "slab_free %s(%d): object at %p"
+			" belongs to slab %s(%d)\n",
+			s->name, s->size, object,
+			page->slab->name, page->slab->size);
+
+dumpret:
+	dump_stack();
+	printk(KERN_CRIT "***** Trying to continue by not "
+			"freeing object.\n");
+	return;
+#endif
+}
+EXPORT_SYMBOL(kmem_cache_free);
+
+/* Figure out on which slab object the object resides */
+static __always_inline struct page *get_object_page(const void *x)
+{
+	struct page * page = virt_to_page(x);
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
+ * kmem_cache_open produces objects aligned at size and the first object
+ * is placed at offset 0 in the slab (We have no metainformation on the
+ * slab, all slabs are in essence off slab).
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
+static int slab_min_order = 0;
+
+static int calculate_order(int size)
+{
+	int order;
+	int rem;
+
+	if ((size & (size -1)) == 0) {
+		/*
+		 * We can use the page allocator if the requested size
+		 * is compatible with the page sizes supported.
+		 */
+		int order = fls(size) -1 - PAGE_SHIFT;
+
+		if (order >= 0)
+			return order;
+	}
+
+	for (order = max(slab_min_order, fls(size - 1) - PAGE_SHIFT);
+			order < MAX_ORDER; order++) {
+		unsigned long slab_size = PAGE_SIZE << order;
+
+		if (slab_size < size)
+			continue;
+
+		rem = slab_size % size;
+
+		if (rem * 8 <= PAGE_SIZE << order)
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
+	if (flags & (SLAB_MUST_HWCACHE_ALIGN|SLAB_HWCACHE_ALIGN))
+		return L1_CACHE_BYTES;
+
+	if (align < ARCH_SLAB_MINALIGN)
+		return ARCH_SLAB_MINALIGN;
+
+	return ALIGN(align, sizeof(void *));
+}
+
+int kmem_cache_open(struct kmem_cache *s,
+		const char *name, size_t size,
+		size_t align, unsigned long flags,
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+	int cpu;
+	int node;
+
+	BUG_ON(flags & SLUB_UNIMPLEMENTED);
+	memset(s, 0, sizeof(struct kmem_cache));
+	for_each_node(node)
+		atomic_long_set(&s->nr_slabs[node], 0);
+	atomic_set(&s->refcount, 1);
+	spin_lock_init(&s->list_lock);
+	for_each_possible_cpu(cpu)
+		s->cpu_slab[cpu] = NULL;
+	INIT_LIST_HEAD(&s->partial);
+#ifdef CONFIG_SMP
+	mutex_init(&s->flushing);
+	atomic_set(&s->cpu_slabs, 0);
+	INIT_DELAYED_WORK(&s->flush, flusher);
+#endif
+	s->name = name;
+	s->ctor = ctor;
+	s->dtor = dtor;
+	s->objsize = size;
+	s->flags = flags;
+
+	/*
+	 * Here is the place to add other management type information
+	 * to the end of the object F.e. debug info
+	 */
+	size = ALIGN(size, sizeof(void *));
+	s->inuse = size;
+
+	if (size * 2 < (PAGE_SIZE << calculate_order(size)) &&
+		((flags & SLAB_DESTROY_BY_RCU) || ctor || dtor)) {
+		/*
+		 * Relocate free pointer after the object if it is not
+		 * permitted to overwrite the first word of the object on
+		 * kmem_cache_free.
+		 *
+		 * This is the case if we do RCU, have a constructor or
+		 * destructor.
+		*/
+		s->offset = size / sizeof(void *);
+		size += sizeof(void *);
+	}
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
+	BUG_ON(s->objects > 65535);
+	if (!s->objects)
+		goto error;
+
+	register_slab(s);
+	return 1;
+
+error:
+	if (flags & SLAB_PANIC)
+		panic("Cannot create slab %s size=%ld realsize=%d "
+			"order=%d offset=%d flags=%lx\n",
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
+static int free_list(struct kmem_cache *s, struct list_head *list)
+{
+	int slabs_inuse = 0;
+	unsigned long flags;
+	struct page *page, *h;
+
+	spin_lock_irqsave(&s->list_lock, flags);
+	list_for_each_entry_safe(page, h, list, lru)
+		if (!page->inuse) {
+			list_del(&s->partial);
+			discard_slab(s, page);
+		} else
+			slabs_inuse++;
+	spin_unlock_irqrestore(&s->list_lock, flags);
+	return slabs_inuse;
+}
+
+/*
+ * Release all resources used by slab cache
+ * (Use with caches setup using kmem_cache_setup)
+ */
+int kmem_cache_close(struct kmem_cache *s)
+{
+	int node;
+
+	if (!atomic_dec_and_test(&s->refcount))
+		return 0;
+
+	flush_all(s);
+	free_list(s, &s->partial);
+
+	for_each_online_node(node)
+		if (atomic_long_read(&s->nr_slabs[node]))
+			return 1;
+
+	unregister_slab(s);
+	return 0;
+}
+EXPORT_SYMBOL(kmem_cache_close);
+
+/*
+ * Close a cache and release the kmem_cache structure
+ * (must be used for caches created using kmem_cache_create
+ */
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+	BUG_ON(kmem_cache_close(s));
+	kfree(s);
+}
+EXPORT_SYMBOL(kmem_cache_destroy);
+
+
+static unsigned long count_objects(struct kmem_cache *s,
+	struct list_head *list, unsigned long *nodes)
+{
+	int count = 0;
+	struct page *page;
+	unsigned long flags;
+
+	spin_lock_irqsave(&s->list_lock, flags);
+	list_for_each_entry(page, list, lru) {
+		count += page->inuse;
+		nodes[page_to_nid(page)]++;
+	}
+	spin_unlock_irqrestore(&s->list_lock, flags);
+	return count;
+}
+
+static unsigned long slab_objects(struct kmem_cache *s,
+	unsigned long *p_total, unsigned long *p_cpu_slabs,
+	unsigned long *p_partial, unsigned long *nodes)
+{
+	int in_partial_slabs = count_objects(s, &s->partial, nodes);
+	int nr_slabs = 0;
+	int cpu_slabs = 0;
+	int nr_in_cpu_slabs = 0;
+	int cpu;
+	int node;
+
+	for_each_online_node(node)
+		nr_slabs += nodes[node] = atomic_read(&s->nr_slabs[node]);
+
+	for_each_possible_cpu(cpu) {
+		struct page *page = s->cpu_slab[cpu];
+
+		if (page) {
+			cpu_slabs++;
+			nr_in_cpu_slabs += page->inuse;
+			nodes[page_to_nid(page)]++;
+		}
+	}
+
+	if (p_partial)
+		*p_partial = s->nr_partial;
+
+	if (p_cpu_slabs)
+		*p_cpu_slabs = cpu_slabs;
+
+	if (p_total)
+		*p_total = nr_slabs;
+
+	return in_partial_slabs + nr_in_cpu_slabs +
+		(nr_slabs - s->nr_partial - cpu_slabs) * s->objects;
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
+static int __init setup_slab_min_order(char *str)
+{
+	get_option (&str, &slab_min_order);
+
+	return 1;
+}
+
+__setup("slab_min_order=", setup_slab_min_order);
+
+static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
+		const char *name, int size)
+{
+
+	if (!kmem_cache_open(s, name, size, ARCH_KMALLOC_MINALIGN,
+			0, NULL, NULL))
+		panic("Creation of kmalloc slab %s size=%d failed.\n",
+			name, size);
+	return s;
+}
+
+static struct kmem_cache *get_slab(size_t size, gfp_t flags)
+{
+	int index = kmalloc_index(size) - KMALLOC_SHIFT_LOW;
+	struct kmem_cache *s;
+	struct kmem_cache *x;
+	size_t realsize;
+
+	BUG_ON(size < 0);
+
+	if (!(flags & SLUB_DMA))
+		return &kmalloc_caches[index];
+
+	s = kmalloc_caches_dma[index];
+	if (s)
+		return s;
+
+	/* Dynamically create dma cache */
+	x = kmalloc(sizeof(struct kmem_cache), flags & ~(__GFP_DMA));
+
+	if (!x)
+		panic("Unable to allocate memory for dma cache\n");
+
+#ifdef KMALLOC_EXTRA
+	if (index <= KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW)
+#endif
+		realsize = 1 << index;
+#ifdef KMALLOC_EXTRA
+	else if (index == KMALLOC_EXTRAS)
+		realsize = 96;
+	else
+		realsize = 192;
+#endif
+
+	s = create_kmalloc_cache(x, "kmalloc_dma", realsize);
+	kmalloc_caches_dma[index] = s;
+	return s;
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
+unsigned int ksize(const void *object)
+{
+	struct page *page = get_object_page(object);
+	struct kmem_cache *s;
+
+	BUG_ON(!page);
+	s = page->slab;
+	BUG_ON(!s);
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
+/********************************************************************
+ *			Basic setup of slabs
+ *******************************************************************/
+
+#define SLAB_MAX_ORDER 4
+
+/*
+ * We can actually operate slabs any time after the page allocator is up.
+ * slab_is_available() merely means that the kmalloc array is available.
+ */
+static enum { DOWN, PARTIAL, UP } slab_state = DOWN;
+
+int slab_is_available(void) {
+	return slab_state == UP;
+}
+
+void __init kmem_cache_init(void)
+{
+	int i;
+
+	for (i =  KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
+		create_kmalloc_cache(
+			&kmalloc_caches[i - KMALLOC_SHIFT_LOW],
+			"kmalloc", 1 << i);
+	}
+#ifdef KMALLOC_EXTRA
+	slab_state = PARTIAL;
+
+	/* Caches that are not of the two-to-the-power-of size */
+	create_kmalloc_cache(&kmalloc_caches
+		[KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW + 1],
+				"kmalloc-96", 96);
+	create_kmalloc_cache(&kmalloc_caches
+		[KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW + 2],
+				"kmalloc-192", 192);
+#endif
+	slab_state = UP;
+
+	/* Provide the correct kmalloc names now that the caches are up */
+	for (i = 0; i <= KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW; i++) {
+		char *name = kasprintf(GFP_KERNEL, "kmalloc-%d",
+					kmalloc_caches[i].size);
+		BUG_ON(!name);
+		kmalloc_caches[i].name = name;
+	};
+
+#ifdef CONFIG_SMP
+	register_cpu_notifier(&slab_notifier);
+#endif
+}
+
+#ifdef SLUB_MERGE
+static struct kmem_cache *kmem_cache_dup(struct kmem_cache *s)
+{
+	atomic_inc(&s->refcount);
+	return s;
+}
+
+
+static struct kmem_cache *__kmalloc_slab(size_t size)
+{
+	int index = kmalloc_index(size) - KMALLOC_SHIFT_LOW;
+
+	if (index < 0)
+		return NULL;
+	return &kmalloc_caches[index];
+}
+#endif
+
+struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+		size_t align, unsigned long flags,
+		void (*ctor)(void *, struct kmem_cache *, unsigned long),
+		void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+	struct kmem_cache *s;
+
+#ifdef SLUB_MERGE
+	if (!ctor && !dtor && !(flags & SLUB_NO_MERGE) &&
+			align <= ARCH_SLAB_MINALIGN) {
+		int sz = ALIGN(size, calculate_alignment(flags, align));
+
+		/* Find the kmalloc slab that would be used for this size */
+		s = __kmalloc_slab(sz);
+		if (!s)
+			return NULL;
+
+		/*
+		 * Check if there would be less than a word difference
+		 * between the size of the slab and the kmalloc slab.
+		 * If so then just use the kmalloc array and avoid creating
+		 * a new slab.
+		 */
+		if (s->size - sz <= sizeof(void *)) {
+			printk(KERN_INFO "SLUB: Merging slab_cache %s size %d"
+				" into kmalloc array size %d\n",
+				name, (int)size, (int)s->size);
+			return kmem_cache_dup(s);
+		}
+	}
+#endif
+
+	s = kmalloc(sizeof(struct kmem_cache), GFP_KERNEL);
+	if (!s)
+		return NULL;
+
+	if (!kmem_cache_open(s, name, size, align, flags, ctor, dtor)) {
+		kfree(s);
+		return NULL;
+	}
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
+static DECLARE_RWSEM(slabstat_sem);
+
+LIST_HEAD(slab_caches);
+
+void for_all_slabs(void (*func)(struct kmem_cache *, int), int cpu)
+{
+	struct list_head *h;
+
+	down_read(&slabstat_sem);
+	list_for_each(h, &slab_caches) {
+		struct kmem_cache *s =
+			container_of(h, struct kmem_cache, list);
+
+	func(s, cpu);
+	}
+	up_read(&slabstat_sem);
+}
+
+
+void register_slab(struct kmem_cache *s)
+{
+	down_write(&slabstat_sem);
+	list_add(&s->list, &slab_caches);
+	up_write(&slabstat_sem);
+}
+
+void unregister_slab(struct kmem_cache *s)
+{
+	down_write(&slabstat_sem);
+	list_add(&s->list, &slab_caches);
+	up_write(&slabstat_sem);
+}
+
+static void print_slabinfo_header(struct seq_file *m)
+{
+	/*
+	 * Output format version, so at least we can change it
+	 * without _too_ many complaints.
+	 */
+	seq_puts(m, "slubinfo - version: 1.0\n");
+	seq_puts(m, "# name            <objects> <order> <objsize>"
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
+	down_read(&slabstat_sem);
+	if (!n)
+		print_slabinfo_header(m);
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
+	up_read(&slabstat_sem);
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
+	unsigned char options[13];
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
+		*d++ = 'P';
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
+
+	*d = 0;
+
+	x = kasprintf(GFP_KERNEL, "%lu/%lu/%lu", total_slabs, partial_slabs,
+						cpu_slabs);
+
+	seq_printf(m, "%-21s %6lu %1d %7u %12s %5s",
+		s->name, objects, s->order, s->size, x, options);
+
+	kfree(x);
+	display_nodes(m, nodes);
+	seq_putc(m, '\n');
+	return 0;
+}
+
+/*
+ * slabinfo_op - iterator that generates /proc/slabinfo
+ */
+struct seq_operations slabinfo_op = {
+	.start = s_start,
+	.next = s_next,
+	.stop = s_stop,
+	.show = s_show,
+};
+
+#ifdef CONFIG_SMP
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
+ * (the cpu slabs are reaped by a per processor workqueue).
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
