Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAIJeA5C005091
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 14:40:10 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAIJdsT9073708
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:39:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAIJeAGi014369
	for <linux-mm@kvack.org>; Fri, 18 Nov 2005 12:40:10 -0700
Message-ID: <437E2E17.9020805@us.ibm.com>
Date: Fri, 18 Nov 2005 11:40:07 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 3/8] Slab cleanup
References: <437E2C69.4000708@us.ibm.com>
In-Reply-To: <437E2C69.4000708@us.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------070001090005060600060604"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070001090005060600060604
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

This patch isn't strictly necessary for the series, but the patch to add
critical pool support to the slab allocator is based on top of these
cleanups.  If any/all of the cleanup work is rejected (discussed in a
seperate, earlier thread), then I will rebase the following patches as
necessary.

-Matt

--------------070001090005060600060604
Content-Type: text/x-patch;
 name="slab_cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slab_cleanup.patch"

Index: linux-2.6.15-rc1+slab_cleanup/include/linux/percpu.h
===================================================================
--- linux-2.6.15-rc1+slab_cleanup.orig/include/linux/percpu.h	2005-11-15 15:21:47.659921992 -0800
+++ linux-2.6.15-rc1+slab_cleanup/include/linux/percpu.h	2005-11-15 15:23:47.699673176 -0800
@@ -33,14 +33,14 @@ struct percpu_data {
         (__typeof__(ptr))__p->ptrs[(cpu)];	\
 })
 
-extern void *__alloc_percpu(size_t size, size_t align);
+extern void *__alloc_percpu(size_t size);
 extern void free_percpu(const void *);
 
 #else /* CONFIG_SMP */
 
 #define per_cpu_ptr(ptr, cpu) (ptr)
 
-static inline void *__alloc_percpu(size_t size, size_t align)
+static inline void *__alloc_percpu(size_t size)
 {
 	void *ret = kmalloc(size, GFP_KERNEL);
 	if (ret)
@@ -55,7 +55,6 @@ static inline void free_percpu(const voi
 #endif /* CONFIG_SMP */
 
 /* Simple wrapper for the common case: zeros memory. */
-#define alloc_percpu(type) \
-	((type *)(__alloc_percpu(sizeof(type), __alignof__(type))))
+#define alloc_percpu(type)	((type *)(__alloc_percpu(sizeof(type))))
 
 #endif /* __LINUX_PERCPU_H */
Index: linux-2.6.15-rc1+slab_cleanup/mm/slab.c
===================================================================
--- linux-2.6.15-rc1+slab_cleanup.orig/mm/slab.c	2005-11-15 14:42:52.871863728 -0800
+++ linux-2.6.15-rc1+slab_cleanup/mm/slab.c	2005-11-15 15:23:52.131999360 -0800
@@ -50,7 +50,7 @@
  * The head array is strictly LIFO and should improve the cache hit rates.
  * On SMP, it additionally reduces the spinlock operations.
  *
- * The c_cpuarray may not be read with enabled local interrupts - 
+ * The c_cpuarray may not be read with enabled local interrupts -
  * it's changed with a smp_call_function().
  *
  * SMP synchronization:
@@ -73,7 +73,7 @@
  *	can never happen inside an interrupt (kmem_cache_create(),
  *	kmem_cache_shrink() and kmem_cache_reap()).
  *
- *	At present, each engine can be growing a cache.  This should be blocked.
+ *	At present each engine can be growing a cache.  This should be blocked.
  *
  * 15 March 2005. NUMA slab allocator.
  *	Shai Fultheim <shai@scalex86.org>.
@@ -86,53 +86,52 @@
  *	All object allocations for a node occur from node specific slab lists.
  */
 
-#include	<linux/config.h>
-#include	<linux/slab.h>
-#include	<linux/mm.h>
-#include	<linux/swap.h>
-#include	<linux/cache.h>
-#include	<linux/interrupt.h>
-#include	<linux/init.h>
-#include	<linux/compiler.h>
-#include	<linux/seq_file.h>
-#include	<linux/notifier.h>
-#include	<linux/kallsyms.h>
-#include	<linux/cpu.h>
-#include	<linux/sysctl.h>
-#include	<linux/module.h>
-#include	<linux/rcupdate.h>
-#include	<linux/string.h>
-#include	<linux/nodemask.h>
-
-#include	<asm/uaccess.h>
-#include	<asm/cacheflush.h>
-#include	<asm/tlbflush.h>
-#include	<asm/page.h>
+#include <linux/config.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/cache.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/compiler.h>
+#include <linux/seq_file.h>
+#include <linux/notifier.h>
+#include <linux/kallsyms.h>
+#include <linux/cpu.h>
+#include <linux/sysctl.h>
+#include <linux/module.h>
+#include <linux/rcupdate.h>
+#include <linux/string.h>
+#include <linux/nodemask.h>
+
+#include <asm/uaccess.h>
+#include <asm/cacheflush.h>
+#include <asm/tlbflush.h>
+#include <asm/page.h>
 
 /*
  * DEBUG	- 1 for kmem_cache_create() to honour; SLAB_DEBUG_INITIAL,
  *		  SLAB_RED_ZONE & SLAB_POISON.
- *		  0 for faster, smaller code (especially in the critical paths).
+ *		  0 for faster, smaller code (especially in the critical paths)
  *
  * STATS	- 1 to collect stats for /proc/slabinfo.
- *		  0 for faster, smaller code (especially in the critical paths).
+ *		  0 for faster, smaller code (especially in the critical paths)
  *
  * FORCED_DEBUG	- 1 enables SLAB_RED_ZONE and SLAB_POISON (if possible)
  */
-
 #ifdef CONFIG_DEBUG_SLAB
-#define	DEBUG		1
-#define	STATS		1
-#define	FORCED_DEBUG	1
+#define DEBUG		1
+#define STATS		1
+#define FORCED_DEBUG	1
 #else
-#define	DEBUG		0
-#define	STATS		0
-#define	FORCED_DEBUG	0
+#define DEBUG		0
+#define STATS		0
+#define FORCED_DEBUG	0
 #endif
 
 
 /* Shouldn't this be in a header file somewhere? */
-#define	BYTES_PER_WORD		sizeof(void *)
+#define BYTES_PER_WORD		sizeof(void *)
 
 #ifndef cache_line_size
 #define cache_line_size()	L1_CACHE_BYTES
@@ -180,7 +179,7 @@
 			 SLAB_DESTROY_BY_RCU)
 #endif
 
-/*
+/**
  * kmem_bufctl_t:
  *
  * Bufctl's are used for linking objs within a slab
@@ -198,13 +197,13 @@
  * Note: This limit can be raised by introducing a general cache whose size
  * is less than 512 (PAGE_SIZE<<3), but greater than 256.
  */
-
 typedef unsigned int kmem_bufctl_t;
 #define BUFCTL_END	(((kmem_bufctl_t)(~0U))-0)
 #define BUFCTL_FREE	(((kmem_bufctl_t)(~0U))-1)
-#define	SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-2)
+#define SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-2)
 
-/* Max number of objs-per-slab for caches which use off-slab slabs.
+/*
+ * Max number of objs-per-slab for caches which use off-slab slabs.
  * Needed to avoid a possible looping condition in cache_grow().
  */
 static unsigned long offslab_limit;
@@ -220,9 +219,9 @@ struct slab {
 	struct list_head	list;
 	unsigned long		colouroff;
 	void			*s_mem;		/* including colour offset */
-	unsigned int		inuse;		/* num of objs active in slab */
+	unsigned int		inuse;		/* # of objs active in slab */
 	kmem_bufctl_t		free;
-	unsigned short          nodeid;
+	unsigned short          nid;		/* node number slab is on */
 };
 
 /*
@@ -264,36 +263,38 @@ struct array_cache {
 	unsigned int limit;
 	unsigned int batchcount;
 	unsigned int touched;
-	spinlock_t lock;
-	void *entry[0];		/*
-				 * Must have this definition in here for the proper
-				 * alignment of array_cache. Also simplifies accessing
-				 * the entries.
-				 * [0] is for gcc 2.95. It should really be [].
-				 */
+	spinlock_t   lock;
+	/*
+	 * Must have this definition in here for the proper alignment of
+	 * array_cache.  Also simplifies accessing the entries.
+	 * [0] is for gcc 2.95. It should really be [].
+	 */
+	void         *entry[0];
 };
 
-/* bootstrap: The caches do not work without cpuarrays anymore,
+/*
+ * bootstrap: The caches do not work without cpuarrays anymore,
  * but the cpuarrays are allocated from the generic caches...
  */
 #define BOOT_CPUCACHE_ENTRIES	1
 struct arraycache_init {
 	struct array_cache cache;
-	void * entries[BOOT_CPUCACHE_ENTRIES];
+	void *entries[BOOT_CPUCACHE_ENTRIES];
 };
 
 /*
  * The slab lists for all objects.
  */
 struct kmem_list3 {
-	struct list_head	slabs_partial;	/* partial list first, better asm code */
+	/* place the partial list first for better assembly code */
+	struct list_head	slabs_partial;
 	struct list_head	slabs_full;
 	struct list_head	slabs_free;
-	unsigned long	free_objects;
-	unsigned long	next_reap;
-	int		free_touched;
-	unsigned int 	free_limit;
-	spinlock_t      list_lock;
+	unsigned long		free_objects;
+	unsigned long		next_reap;
+	int			free_touched;
+	unsigned int		free_limit;
+	spinlock_t		list_lock;
 	struct array_cache	*shared;	/* shared per node */
 	struct array_cache	**alien;	/* on other nodes */
 };
@@ -301,11 +302,11 @@ struct kmem_list3 {
 /*
  * Need this for bootstrapping a per node allocator.
  */
-#define NUM_INIT_LISTS (2 * MAX_NUMNODES + 1)
+#define NUM_INIT_LISTS	(2 * MAX_NUMNODES + 1)
 struct kmem_list3 __initdata initkmem_list3[NUM_INIT_LISTS];
-#define	CACHE_CACHE 0
-#define	SIZE_AC 1
-#define	SIZE_L3 (1 + MAX_NUMNODES)
+#define CACHE_CACHE	0
+#define SIZE_AC		1
+#define SIZE_L3		(1 + MAX_NUMNODES)
 
 /*
  * This function must be completely optimized away if
@@ -318,10 +319,10 @@ static __always_inline int index_of(cons
 	if (__builtin_constant_p(size)) {
 		int i = 0;
 
-#define CACHE(x) \
-	if (size <=x) \
-		return i; \
-	else \
+#define CACHE(x)		\
+	if (size <= x)		\
+		return i;	\
+	else			\
 		i++;
 #include "linux/kmalloc_sizes.h"
 #undef CACHE
@@ -349,17 +350,17 @@ static inline void kmem_list3_init(struc
 	parent->free_touched = 0;
 }
 
-#define MAKE_LIST(cachep, listp, slab, nodeid)	\
-	do {	\
-		INIT_LIST_HEAD(listp);		\
-		list_splice(&(cachep->nodelists[nodeid]->slab), listp); \
+#define MAKE_LIST(cachep, listp, slab, nid)				\
+	do {								\
+		INIT_LIST_HEAD(listp);					\
+		list_splice(&(cachep->nodelists[nid]->slab), listp);	\
 	} while (0)
 
-#define	MAKE_ALL_LISTS(cachep, ptr, nodeid)			\
-	do {					\
-	MAKE_LIST((cachep), (&(ptr)->slabs_full), slabs_full, nodeid);	\
-	MAKE_LIST((cachep), (&(ptr)->slabs_partial), slabs_partial, nodeid); \
-	MAKE_LIST((cachep), (&(ptr)->slabs_free), slabs_free, nodeid);	\
+#define MAKE_ALL_LISTS(cachep, ptr, nid)				\
+	do {								\
+	MAKE_LIST((cachep), &(ptr)->slabs_full, slabs_full, nid);	\
+	MAKE_LIST((cachep), &(ptr)->slabs_partial, slabs_partial, nid);\
+	MAKE_LIST((cachep), &(ptr)->slabs_free, slabs_free, nid);	\
 	} while (0)
 
 /*
@@ -367,7 +368,6 @@ static inline void kmem_list3_init(struc
  *
  * manages a cache.
  */
-	
 struct kmem_cache {
 /* 1) per-cpu data, touched during every alloc/free */
 	struct array_cache	*array[NR_CPUS];
@@ -428,10 +428,11 @@ struct kmem_cache {
 };
 
 #define CFLGS_OFF_SLAB		(0x80000000UL)
-#define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
+#define OFF_SLAB(x)		((x)->flags & CFLGS_OFF_SLAB)
 
 #define BATCHREFILL_LIMIT	16
-/* Optimization question: fewer reaps means less 
+/*
+ * Optimization question: fewer reaps means less
  * probability for unnessary cpucache drain/refill cycles.
  *
  * OTOH the cpuarrays can contain lots of objects,
@@ -441,20 +442,19 @@ struct kmem_cache {
 #define REAPTIMEOUT_LIST3	(4*HZ)
 
 #if STATS
-#define	STATS_INC_ACTIVE(x)	((x)->num_active++)
-#define	STATS_DEC_ACTIVE(x)	((x)->num_active--)
-#define	STATS_INC_ALLOCED(x)	((x)->num_allocations++)
-#define	STATS_INC_GROWN(x)	((x)->grown++)
-#define	STATS_INC_REAPED(x)	((x)->reaped++)
-#define	STATS_SET_HIGH(x)	do { if ((x)->num_active > (x)->high_mark) \
-					(x)->high_mark = (x)->num_active; \
+#define STATS_INC_ACTIVE(x)	((x)->num_active++)
+#define STATS_DEC_ACTIVE(x)	((x)->num_active--)
+#define STATS_INC_ALLOCED(x)	((x)->num_allocations++)
+#define STATS_INC_GROWN(x)	((x)->grown++)
+#define STATS_INC_REAPED(x)	((x)->reaped++)
+#define STATS_SET_HIGH(x)	do { if ((x)->num_active > (x)->high_mark) \
+					(x)->high_mark = (x)->num_active;  \
 				} while (0)
-#define	STATS_INC_ERR(x)	((x)->errors++)
-#define	STATS_INC_NODEALLOCS(x)	((x)->node_allocs++)
-#define	STATS_INC_NODEFREES(x)	((x)->node_frees++)
-#define	STATS_SET_FREEABLE(x, i) \
-				do { if ((x)->max_freeable < i) \
-					(x)->max_freeable = i; \
+#define STATS_INC_ERR(x)	((x)->errors++)
+#define STATS_INC_NODEALLOCS(x)	((x)->node_allocs++)
+#define STATS_INC_NODEFREES(x)	((x)->node_frees++)
+#define STATS_SET_FREEABLE(x,i)	do { if ((x)->max_freeable < i)	\
+					(x)->max_freeable = i;	\
 				} while (0)
 
 #define STATS_INC_ALLOCHIT(x)	atomic_inc(&(x)->allochit)
@@ -462,18 +462,16 @@ struct kmem_cache {
 #define STATS_INC_FREEHIT(x)	atomic_inc(&(x)->freehit)
 #define STATS_INC_FREEMISS(x)	atomic_inc(&(x)->freemiss)
 #else
-#define	STATS_INC_ACTIVE(x)	do { } while (0)
-#define	STATS_DEC_ACTIVE(x)	do { } while (0)
-#define	STATS_INC_ALLOCED(x)	do { } while (0)
-#define	STATS_INC_GROWN(x)	do { } while (0)
-#define	STATS_INC_REAPED(x)	do { } while (0)
-#define	STATS_SET_HIGH(x)	do { } while (0)
-#define	STATS_INC_ERR(x)	do { } while (0)
-#define	STATS_INC_NODEALLOCS(x)	do { } while (0)
-#define	STATS_INC_NODEFREES(x)	do { } while (0)
-#define	STATS_SET_FREEABLE(x, i) \
-				do { } while (0)
-
+#define STATS_INC_ACTIVE(x)	do { } while (0)
+#define STATS_DEC_ACTIVE(x)	do { } while (0)
+#define STATS_INC_ALLOCED(x)	do { } while (0)
+#define STATS_INC_GROWN(x)	do { } while (0)
+#define STATS_INC_REAPED(x)	do { } while (0)
+#define STATS_SET_HIGH(x)	do { } while (0)
+#define STATS_INC_ERR(x)	do { } while (0)
+#define STATS_INC_NODEALLOCS(x)	do { } while (0)
+#define STATS_INC_NODEFREES(x)	do { } while (0)
+#define STATS_SET_FREEABLE(x,i)	do { } while (0)
 #define STATS_INC_ALLOCHIT(x)	do { } while (0)
 #define STATS_INC_ALLOCMISS(x)	do { } while (0)
 #define STATS_INC_FREEHIT(x)	do { } while (0)
@@ -481,27 +479,31 @@ struct kmem_cache {
 #endif
 
 #if DEBUG
-/* Magic nums for obj red zoning.
+/*
+ * Magic nums for obj red zoning.
  * Placed in the first word before and the first word after an obj.
  */
-#define	RED_INACTIVE	0x5A2CF071UL	/* when obj is inactive */
-#define	RED_ACTIVE	0x170FC2A5UL	/* when obj is active */
+#define RED_INACTIVE	0x5A2CF071UL	/* when obj is inactive */
+#define RED_ACTIVE	0x170FC2A5UL	/* when obj is active */
 
 /* ...and for poisoning */
-#define	POISON_INUSE	0x5a	/* for use-uninitialised poisoning */
+#define POISON_INUSE	0x5a	/* for use-uninitialised poisoning */
 #define POISON_FREE	0x6b	/* for use-after-free poisoning */
-#define	POISON_END	0xa5	/* end-byte of poisoning */
+#define POISON_END	0xa5	/* end-byte of poisoning */
 
-/* memory layout of objects:
+/* Don't use red zoning for ojects greater than this size */
+#define RED_ZONE_LIMIT	4096
+
+/*
+ * memory layout of objects:
  * 0		: objp
- * 0 .. cachep->dbghead - BYTES_PER_WORD - 1: padding. This ensures that
+ * 0 .. cachep->dbghead - BYTES_PER_WORD-1: padding. This ensures that
  * 		the end of an object is aligned with the end of the real
  * 		allocation. Catches writes behind the end of the allocation.
- * cachep->dbghead - BYTES_PER_WORD .. cachep->dbghead - 1:
- * 		redzone word.
+ * cachep->dbghead - BYTES_PER_WORD .. cachep->dbghead - 1: redzone word.
  * cachep->dbghead: The real object.
- * cachep->objsize - 2* BYTES_PER_WORD: redzone word [BYTES_PER_WORD long]
- * cachep->objsize - 1* BYTES_PER_WORD: last caller address [BYTES_PER_WORD long]
+ * cachep->objsize - 2*BYTES_PER_WORD: redzone word [BYTES_PER_WORD long]
+ * cachep->objsize - 1*BYTES_PER_WORD: last caller addr [BYTES_PER_WORD long]
  */
 static int obj_dbghead(kmem_cache_t *cachep)
 {
@@ -516,24 +518,24 @@ static int obj_reallen(kmem_cache_t *cac
 static unsigned long *dbg_redzone1(kmem_cache_t *cachep, void *objp)
 {
 	BUG_ON(!(cachep->flags & SLAB_RED_ZONE));
-	return (unsigned long*) (objp+obj_dbghead(cachep)-BYTES_PER_WORD);
+	return (unsigned long *) (objp + obj_dbghead(cachep) - BYTES_PER_WORD);
 }
 
 static unsigned long *dbg_redzone2(kmem_cache_t *cachep, void *objp)
 {
 	BUG_ON(!(cachep->flags & SLAB_RED_ZONE));
 	if (cachep->flags & SLAB_STORE_USER)
-		return (unsigned long*) (objp+cachep->objsize-2*BYTES_PER_WORD);
-	return (unsigned long*) (objp+cachep->objsize-BYTES_PER_WORD);
+		return (objp + cachep->objsize - 2 * BYTES_PER_WORD);
+	return (objp + cachep->objsize - BYTES_PER_WORD);
 }
 
 static void **dbg_userword(kmem_cache_t *cachep, void *objp)
 {
 	BUG_ON(!(cachep->flags & SLAB_STORE_USER));
-	return (void**)(objp+cachep->objsize-BYTES_PER_WORD);
+	return (void **)(objp + cachep->objsize - BYTES_PER_WORD);
 }
 
-#else
+#else /* !DEBUG */
 
 #define obj_dbghead(x)			0
 #define obj_reallen(cachep)		(cachep->objsize)
@@ -541,40 +543,41 @@ static void **dbg_userword(kmem_cache_t 
 #define dbg_redzone2(cachep, objp)	({BUG(); (unsigned long *)NULL;})
 #define dbg_userword(cachep, objp)	({BUG(); (void **)NULL;})
 
-#endif
+#endif /* DEBUG */
 
 /*
  * Maximum size of an obj (in 2^order pages)
  * and absolute limit for the gfp order.
  */
 #if defined(CONFIG_LARGE_ALLOCS)
-#define	MAX_OBJ_ORDER	13	/* up to 32Mb */
-#define	MAX_GFP_ORDER	13	/* up to 32Mb */
+#define MAX_OBJ_ORDER	13	/* up to 32Mb */
+#define MAX_GFP_ORDER	13	/* up to 32Mb */
 #elif defined(CONFIG_MMU)
-#define	MAX_OBJ_ORDER	5	/* 32 pages */
-#define	MAX_GFP_ORDER	5	/* 32 pages */
+#define MAX_OBJ_ORDER	5	/* 32 pages */
+#define MAX_GFP_ORDER	5	/* 32 pages */
 #else
-#define	MAX_OBJ_ORDER	8	/* up to 1Mb */
-#define	MAX_GFP_ORDER	8	/* up to 1Mb */
+#define MAX_OBJ_ORDER	8	/* up to 1Mb */
+#define MAX_GFP_ORDER	8	/* up to 1Mb */
 #endif
 
 /*
  * Do not go above this order unless 0 objects fit into the slab.
  */
-#define	BREAK_GFP_ORDER_HI	1
-#define	BREAK_GFP_ORDER_LO	0
+#define BREAK_GFP_ORDER_HI	1
+#define BREAK_GFP_ORDER_LO	0
 static int slab_break_gfp_order = BREAK_GFP_ORDER_LO;
 
-/* Macros for storing/retrieving the cachep and or slab from the
+/*
+ * Macros for storing/retrieving the cachep and or slab from the
  * global 'mem_map'. These are used to find the slab an obj belongs to.
  * With kfree(), these are used to find the cache which an obj belongs to.
  */
-#define	SET_PAGE_CACHE(pg,x)  ((pg)->lru.next = (struct list_head *)(x))
-#define	GET_PAGE_CACHE(pg)    ((kmem_cache_t *)(pg)->lru.next)
-#define	SET_PAGE_SLAB(pg,x)   ((pg)->lru.prev = (struct list_head *)(x))
-#define	GET_PAGE_SLAB(pg)     ((struct slab *)(pg)->lru.prev)
+#define SET_PAGE_CACHE(pg,x)  ((pg)->lru.next = (struct list_head *)(x))
+#define GET_PAGE_CACHE(pg)    ((kmem_cache_t *)(pg)->lru.next)
+#define SET_PAGE_SLAB(pg,x)   ((pg)->lru.prev = (struct list_head *)(x))
+#define GET_PAGE_SLAB(pg)     ((struct slab *)(pg)->lru.prev)
 
-/* These are the default caches for kmalloc. Custom caches can have other sizes. */
+/* These are the default kmalloc caches. Custom caches can have other sizes. */
 struct cache_sizes malloc_sizes[] = {
 #define CACHE(x) { .cs_size = (x) },
 #include <linux/kmalloc_sizes.h>
@@ -616,7 +619,7 @@ static kmem_cache_t cache_cache = {
 };
 
 /* Guard access to the cache-chain. */
-static struct semaphore	cache_chain_sem;
+static struct semaphore cache_chain_sem;
 static struct list_head cache_chain;
 
 /*
@@ -640,10 +643,10 @@ static enum {
 
 static DEFINE_PER_CPU(struct work_struct, reap_work);
 
-static void free_block(kmem_cache_t* cachep, void** objpp, int len, int node);
+static void free_block(kmem_cache_t *cachep, void **objpp, int len, int nid);
 static void enable_cpucache (kmem_cache_t *cachep);
 static void cache_reap (void *unused);
-static int __node_shrink(kmem_cache_t *cachep, int node);
+static int __node_shrink(kmem_cache_t *cachep, int nid);
 
 static inline struct array_cache *ac_data(kmem_cache_t *cachep)
 {
@@ -655,19 +658,19 @@ static inline kmem_cache_t *__find_gener
 	struct cache_sizes *csizep = malloc_sizes;
 
 #if DEBUG
-	/* This happens if someone tries to call
- 	* kmem_cache_create(), or __kmalloc(), before
- 	* the generic caches are initialized.
- 	*/
+	/*
+	 * This happens if someone calls kmem_cache_create() or __kmalloc()
+	 * before the generic caches are initialized
+	 */
 	BUG_ON(malloc_sizes[INDEX_AC].cs_cachep == NULL);
 #endif
 	while (size > csizep->cs_size)
 		csizep++;
 
 	/*
-	 * Really subtle: The last entry with cs->cs_size==ULONG_MAX
-	 * has cs_{dma,}cachep==NULL. Thus no special case
-	 * for large kmalloc calls required.
+	 * Really subtle: The last entry with cs->cs_size == ULONG_MAX has
+	 * cs_{dma,}cachep == NULL, thus no special case for large kmalloc
+	 * calls is required.
 	 */
 	if (unlikely(gfpflags & GFP_DMA))
 		return csizep->cs_dmacachep;
@@ -680,12 +683,12 @@ kmem_cache_t *kmem_find_general_cachep(s
 }
 EXPORT_SYMBOL(kmem_find_general_cachep);
 
-/* Cal the num objs, wastage, and bytes left over for a given slab size. */
+/* Calculate the num objs, wastage, & bytes left over for a given slab size. */
 static void cache_estimate(unsigned long gfporder, size_t size, size_t align,
-		 int flags, size_t *left_over, unsigned int *num)
+			   int flags, size_t *left_over, unsigned int *num)
 {
 	int i;
-	size_t wastage = PAGE_SIZE<<gfporder;
+	size_t wastage = PAGE_SIZE << gfporder;
 	size_t extra = 0;
 	size_t base = 0;
 
@@ -694,7 +697,7 @@ static void cache_estimate(unsigned long
 		extra = sizeof(kmem_bufctl_t);
 	}
 	i = 0;
-	while (i*size + ALIGN(base+i*extra, align) <= wastage)
+	while (i * size + ALIGN(base + i * extra, align) <= wastage)
 		i++;
 	if (i > 0)
 		i--;
@@ -703,8 +706,8 @@ static void cache_estimate(unsigned long
 		i = SLAB_LIMIT;
 
 	*num = i;
-	wastage -= i*size;
-	wastage -= ALIGN(base+i*extra, align);
+	wastage -= i * size;
+	wastage -= ALIGN(base + i * extra, align);
 	*left_over = wastage;
 }
 
@@ -718,7 +721,7 @@ static void __slab_error(const char *fun
 }
 
 /*
- * Initiate the reap timer running on the target CPU.  We run at around 1 to 2Hz
+ * Initiate the reap timer running on the target CPU.  We run at around 1-2Hz
  * via the workqueue/eventd.
  * Add the CPU number into the expiration time to minimize the possibility of
  * the CPUs getting into lockstep and contending for the global cache chain
@@ -739,13 +742,13 @@ static void __devinit start_cpu_timer(in
 	}
 }
 
-static struct array_cache *alloc_arraycache(int node, int entries,
-						int batchcount)
+static struct array_cache *alloc_arraycache(int nid, int entries,
+					    int batchcount)
 {
-	int memsize = sizeof(void*)*entries+sizeof(struct array_cache);
+	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);
 	struct array_cache *nc = NULL;
 
-	nc = kmalloc_node(memsize, GFP_KERNEL, node);
+	nc = kmalloc_node(memsize, GFP_KERNEL, nid);
 	if (nc) {
 		nc->avail = 0;
 		nc->limit = entries;
@@ -757,24 +760,24 @@ static struct array_cache *alloc_arrayca
 }
 
 #ifdef CONFIG_NUMA
-static inline struct array_cache **alloc_alien_cache(int node, int limit)
+static inline struct array_cache **alloc_alien_cache(int nid, int limit)
 {
 	struct array_cache **ac_ptr;
-	int memsize = sizeof(void*)*MAX_NUMNODES;
+	int memsize = sizeof(void *) * MAX_NUMNODES;
 	int i;
 
 	if (limit > 1)
 		limit = 12;
-	ac_ptr = kmalloc_node(memsize, GFP_KERNEL, node);
+	ac_ptr = kmalloc_node(memsize, GFP_KERNEL, nid);
 	if (ac_ptr) {
 		for_each_node(i) {
-			if (i == node || !node_online(i)) {
+			if (i == nid || !node_online(i)) {
 				ac_ptr[i] = NULL;
 				continue;
 			}
-			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d);
+			ac_ptr[i] = alloc_arraycache(nid, limit, 0xbaadf00d);
 			if (!ac_ptr[i]) {
-				for (i--; i <=0; i--)
+				for (i--; i <= 0; i--)
 					kfree(ac_ptr[i]);
 				kfree(ac_ptr);
 				return NULL;
@@ -797,13 +800,14 @@ static inline void free_alien_cache(stru
 	kfree(ac_ptr);
 }
 
-static inline void __drain_alien_cache(kmem_cache_t *cachep, struct array_cache *ac, int node)
+static inline void __drain_alien_cache(kmem_cache_t *cachep,
+				       struct array_cache *ac, int nid)
 {
-	struct kmem_list3 *rl3 = cachep->nodelists[node];
+	struct kmem_list3 *rl3 = cachep->nodelists[nid];
 
 	if (ac->avail) {
 		spin_lock(&rl3->list_lock);
-		free_block(cachep, ac->entry, ac->avail, node);
+		free_block(cachep, ac->entry, ac->avail, nid);
 		ac->avail = 0;
 		spin_unlock(&rl3->list_lock);
 	}
@@ -811,7 +815,7 @@ static inline void __drain_alien_cache(k
 
 static void drain_alien_cache(kmem_cache_t *cachep, struct kmem_list3 *l3)
 {
-	int i=0;
+	int i = 0;
 	struct array_cache *ac;
 	unsigned long flags;
 
@@ -825,72 +829,74 @@ static void drain_alien_cache(kmem_cache
 	}
 }
 #else
-#define alloc_alien_cache(node, limit) do { } while (0)
-#define free_alien_cache(ac_ptr) do { } while (0)
-#define drain_alien_cache(cachep, l3) do { } while (0)
+#define alloc_alien_cache(nid, limit)	do { } while (0)
+#define free_alien_cache(ac_ptr)	do { } while (0)
+#define drain_alien_cache(cachep, l3)	do { } while (0)
 #endif
 
 static int __devinit cpuup_callback(struct notifier_block *nfb,
-				  unsigned long action, void *hcpu)
+				    unsigned long action, void *hcpu)
 {
 	long cpu = (long)hcpu;
-	kmem_cache_t* cachep;
+	kmem_cache_t *cachep;
 	struct kmem_list3 *l3 = NULL;
-	int node = cpu_to_node(cpu);
+	int nid = cpu_to_node(cpu);
 	int memsize = sizeof(struct kmem_list3);
 	struct array_cache *nc = NULL;
 
 	switch (action) {
 	case CPU_UP_PREPARE:
 		down(&cache_chain_sem);
-		/* we need to do this right in the beginning since
+		/*
+		 * we need to do this right in the beginning since
 		 * alloc_arraycache's are going to use this list.
 		 * kmalloc_node allows us to add the slab to the right
 		 * kmem_list3 and not this cpu's kmem_list3
 		 */
-
 		list_for_each_entry(cachep, &cache_chain, next) {
-			/* setup the size64 kmemlist for cpu before we can
+			/*
+			 * setup the size64 kmemlist for cpu before we can
 			 * begin anything. Make sure some other cpu on this
 			 * node has not already allocated this
 			 */
-			if (!cachep->nodelists[node]) {
-				if (!(l3 = kmalloc_node(memsize,
-						GFP_KERNEL, node)))
+			if (!cachep->nodelists[nid]) {
+				if (!(l3 = kmalloc_node(memsize, GFP_KERNEL,
+							nid)))
 					goto bad;
 				kmem_list3_init(l3);
 				l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
-				  ((unsigned long)cachep)%REAPTIMEOUT_LIST3;
+				  ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 
-				cachep->nodelists[node] = l3;
+				cachep->nodelists[nid] = l3;
 			}
 
-			spin_lock_irq(&cachep->nodelists[node]->list_lock);
-			cachep->nodelists[node]->free_limit =
-				(1 + nr_cpus_node(node)) *
+			spin_lock_irq(&cachep->nodelists[nid]->list_lock);
+			cachep->nodelists[nid]->free_limit =
+				(1 + nr_cpus_node(nid)) *
 				cachep->batchcount + cachep->num;
-			spin_unlock_irq(&cachep->nodelists[node]->list_lock);
+			spin_unlock_irq(&cachep->nodelists[nid]->list_lock);
 		}
 
-		/* Now we can go ahead with allocating the shared array's
-		  & array cache's */
+		/* Now we can allocate the shared arrays & array caches */
 		list_for_each_entry(cachep, &cache_chain, next) {
-			nc = alloc_arraycache(node, cachep->limit,
-					cachep->batchcount);
+			nc = alloc_arraycache(nid, cachep->limit,
+					      cachep->batchcount);
 			if (!nc)
 				goto bad;
 			cachep->array[cpu] = nc;
 
-			l3 = cachep->nodelists[node];
+			l3 = cachep->nodelists[nid];
 			BUG_ON(!l3);
 			if (!l3->shared) {
-				if (!(nc = alloc_arraycache(node,
-					cachep->shared*cachep->batchcount,
+				if (!(nc = alloc_arraycache(nid,
+					cachep->shared * cachep->batchcount,
 					0xbaadf00d)))
-					goto  bad;
+					goto bad;
 
-				/* we are serialised from CPU_DEAD or
-				  CPU_UP_CANCELLED by the cpucontrol lock */
+				/*
+				 * we are serialised from CPU_DEAD or
+				 * CPU_UP_CANCELLED by the cpucontrol lock
+				 */
 				l3->shared = nc;
 			}
 		}
@@ -909,12 +915,12 @@ static int __devinit cpuup_callback(stru
 			struct array_cache *nc;
 			cpumask_t mask;
 
-			mask = node_to_cpumask(node);
+			mask = node_to_cpumask(nid);
 			spin_lock_irq(&cachep->spinlock);
 			/* cpu is dead; no one can alloc from it. */
 			nc = cachep->array[cpu];
 			cachep->array[cpu] = NULL;
-			l3 = cachep->nodelists[node];
+			l3 = cachep->nodelists[nid];
 
 			if (!l3)
 				goto unlock_cache;
@@ -924,16 +930,16 @@ static int __devinit cpuup_callback(stru
 			/* Free limit for this kmem_list3 */
 			l3->free_limit -= cachep->batchcount;
 			if (nc)
-				free_block(cachep, nc->entry, nc->avail, node);
+				free_block(cachep, nc->entry, nc->avail, nid);
 
 			if (!cpus_empty(mask)) {
-                                spin_unlock(&l3->list_lock);
-                                goto unlock_cache;
-                        }
+				spin_unlock(&l3->list_lock);
+				goto unlock_cache;
+			}
 
 			if (l3->shared) {
 				free_block(cachep, l3->shared->entry,
-						l3->shared->avail, node);
+					   l3->shared->avail, nid);
 				kfree(l3->shared);
 				l3->shared = NULL;
 			}
@@ -944,8 +950,8 @@ static int __devinit cpuup_callback(stru
 			}
 
 			/* free slabs belonging to this node */
-			if (__node_shrink(cachep, node)) {
-				cachep->nodelists[node] = NULL;
+			if (__node_shrink(cachep, nid)) {
+				cachep->nodelists[nid] = NULL;
 				spin_unlock(&l3->list_lock);
 				kfree(l3);
 			} else {
@@ -970,23 +976,23 @@ static struct notifier_block cpucache_no
 /*
  * swap the static kmem_list3 with kmalloced memory
  */
-static void init_list(kmem_cache_t *cachep, struct kmem_list3 *list,
-		int nodeid)
+static void init_list(kmem_cache_t *cachep, struct kmem_list3 *list, int nid)
 {
 	struct kmem_list3 *ptr;
 
-	BUG_ON(cachep->nodelists[nodeid] != list);
-	ptr = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, nodeid);
+	BUG_ON(cachep->nodelists[nid] != list);
+	ptr = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, nid);
 	BUG_ON(!ptr);
 
 	local_irq_disable();
 	memcpy(ptr, list, sizeof(struct kmem_list3));
-	MAKE_ALL_LISTS(cachep, ptr, nodeid);
-	cachep->nodelists[nodeid] = ptr;
+	MAKE_ALL_LISTS(cachep, ptr, nid);
+	cachep->nodelists[nid] = ptr;
 	local_irq_enable();
 }
 
-/* Initialisation.
+/*
+ * Initialization.
  * Called after the gfp() functions have been enabled, and before smp_init().
  */
 void __init kmem_cache_init(void)
@@ -1009,7 +1015,8 @@ void __init kmem_cache_init(void)
 	if (num_physpages > (32 << 20) >> PAGE_SHIFT)
 		slab_break_gfp_order = BREAK_GFP_ORDER_HI;
 
-	/* Bootstrap is tricky, because several objects are allocated
+	/*
+	 * Bootstrap is tricky, because several objects are allocated
 	 * from caches that do not exist yet:
 	 * 1) initialize the cache_cache cache: it contains the kmem_cache_t
 	 *    structures of all caches, except cache_cache itself: cache_cache
@@ -1026,7 +1033,7 @@ void __init kmem_cache_init(void)
 	 *    kmalloc cache with kmalloc allocated arrays.
 	 * 5) Replace the __init data for kmem_list3 for cache_cache and
 	 *    the other cache's with kmalloc allocated memory.
-	 * 6) Resize the head arrays of the kmalloc caches to their final sizes.
+	 * 6) Resize head arrays of the kmalloc caches to their final sizes.
 	 */
 
 	/* 1) create the cache_cache */
@@ -1040,24 +1047,24 @@ void __init kmem_cache_init(void)
 	cache_cache.objsize = ALIGN(cache_cache.objsize, cache_line_size());
 
 	cache_estimate(0, cache_cache.objsize, cache_line_size(), 0,
-				&left_over, &cache_cache.num);
+		       &left_over, &cache_cache.num);
 	if (!cache_cache.num)
 		BUG();
 
-	cache_cache.colour = left_over/cache_cache.colour_off;
+	cache_cache.colour = left_over / cache_cache.colour_off;
 	cache_cache.colour_next = 0;
-	cache_cache.slab_size = ALIGN(cache_cache.num*sizeof(kmem_bufctl_t) +
+	cache_cache.slab_size = ALIGN(cache_cache.num * sizeof(kmem_bufctl_t) +
 				sizeof(struct slab), cache_line_size());
 
 	/* 2+3) create the kmalloc caches */
 	sizes = malloc_sizes;
 	names = cache_names;
 
-	/* Initialize the caches that provide memory for the array cache
+	/*
+	 * Initialize the caches that provide memory for the array cache
 	 * and the kmem_list3 structures first.
 	 * Without this, further allocations will bug
 	 */
-
 	sizes[INDEX_AC].cs_cachep = kmem_cache_create(names[INDEX_AC].name,
 				sizes[INDEX_AC].cs_size, ARCH_KMALLOC_MINALIGN,
 				(ARCH_KMALLOC_FLAGS | SLAB_PANIC), NULL, NULL);
@@ -1097,44 +1104,42 @@ void __init kmem_cache_init(void)
 	}
 	/* 4) Replace the bootstrap head arrays */
 	{
-		void * ptr;
+		void *ptr;
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_KERNEL);
 
 		local_irq_disable();
 		BUG_ON(ac_data(&cache_cache) != &initarray_cache.cache);
 		memcpy(ptr, ac_data(&cache_cache),
-				sizeof(struct arraycache_init));
+		       sizeof(struct arraycache_init));
 		cache_cache.array[smp_processor_id()] = ptr;
 		local_irq_enable();
 
 		ptr = kmalloc(sizeof(struct arraycache_init), GFP_KERNEL);
 
 		local_irq_disable();
-		BUG_ON(ac_data(malloc_sizes[INDEX_AC].cs_cachep)
-				!= &initarray_generic.cache);
+		BUG_ON(ac_data(malloc_sizes[INDEX_AC].cs_cachep) !=
+		       &initarray_generic.cache);
 		memcpy(ptr, ac_data(malloc_sizes[INDEX_AC].cs_cachep),
-				sizeof(struct arraycache_init));
+		       sizeof(struct arraycache_init));
 		malloc_sizes[INDEX_AC].cs_cachep->array[smp_processor_id()] =
-						ptr;
+			ptr;
 		local_irq_enable();
 	}
 	/* 5) Replace the bootstrap kmem_list3's */
 	{
-		int node;
+		int nid;
 		/* Replace the static kmem_list3 structures for the boot cpu */
 		init_list(&cache_cache, &initkmem_list3[CACHE_CACHE],
-				numa_node_id());
+			  numa_node_id());
 
-		for_each_online_node(node) {
+		for_each_online_node(nid) {
 			init_list(malloc_sizes[INDEX_AC].cs_cachep,
-					&initkmem_list3[SIZE_AC+node], node);
+				  &initkmem_list3[SIZE_AC+nid], nid);
 
-			if (INDEX_AC != INDEX_L3) {
+			if (INDEX_AC != INDEX_L3)
 				init_list(malloc_sizes[INDEX_L3].cs_cachep,
-						&initkmem_list3[SIZE_L3+node],
-						node);
-			}
+					  &initkmem_list3[SIZE_L3+nid], nid);
 		}
 	}
 
@@ -1150,12 +1155,14 @@ void __init kmem_cache_init(void)
 	/* Done! */
 	g_cpucache_up = FULL;
 
-	/* Register a cpu startup notifier callback
+	/*
+	 * Register a cpu startup notifier callback
 	 * that initializes ac_data for all new cpus
 	 */
 	register_cpu_notifier(&cpucache_notifier);
 
-	/* The reap timers are started later, with a module init call:
+	/*
+	 * The reap timers are started later, with a module init call:
 	 * That part of the kernel is not yet operational.
 	 */
 }
@@ -1164,16 +1171,12 @@ static int __init cpucache_init(void)
 {
 	int cpu;
 
-	/* 
-	 * Register the timers that return unneeded
-	 * pages to gfp.
-	 */
+	/* Register the timers that return unneeded pages to gfp */
 	for_each_online_cpu(cpu)
 		start_cpu_timer(cpu);
 
 	return 0;
 }
-
 __initcall(cpucache_init);
 
 /*
@@ -1183,23 +1186,22 @@ __initcall(cpucache_init);
  * did not request dmaable memory, we might get it, but that
  * would be relatively rare and ignorable.
  */
-static void *kmem_getpages(kmem_cache_t *cachep, gfp_t flags, int nodeid)
+static void *kmem_getpages(kmem_cache_t *cachep, gfp_t flags, int nid)
 {
 	struct page *page;
 	void *addr;
 	int i;
 
 	flags |= cachep->gfpflags;
-	if (likely(nodeid == -1)) {
+	if (likely(nid == -1))
 		page = alloc_pages(flags, cachep->gfporder);
-	} else {
-		page = alloc_pages_node(nodeid, flags, cachep->gfporder);
-	}
+	else
+		page = alloc_pages_node(nid, flags, cachep->gfporder);
 	if (!page)
 		return NULL;
 	addr = page_address(page);
 
-	i = (1 << cachep->gfporder);
+	i = 1 << cachep->gfporder;
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		atomic_add(i, &slab_reclaim_pages);
 	add_page_state(nr_slab, i);
@@ -1215,7 +1217,7 @@ static void *kmem_getpages(kmem_cache_t 
  */
 static void kmem_freepages(kmem_cache_t *cachep, void *addr)
 {
-	unsigned long i = (1<<cachep->gfporder);
+	unsigned long i = 1 << cachep->gfporder;
 	struct page *page = virt_to_page(addr);
 	const unsigned long nr_freed = i;
 
@@ -1228,13 +1230,13 @@ static void kmem_freepages(kmem_cache_t 
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += nr_freed;
 	free_pages((unsigned long)addr, cachep->gfporder);
-	if (cachep->flags & SLAB_RECLAIM_ACCOUNT) 
-		atomic_sub(1<<cachep->gfporder, &slab_reclaim_pages);
+	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
+		atomic_sub(1 << cachep->gfporder, &slab_reclaim_pages);
 }
 
 static void kmem_rcu_free(struct rcu_head *head)
 {
-	struct slab_rcu *slab_rcu = (struct slab_rcu *) head;
+	struct slab_rcu *slab_rcu = (struct slab_rcu *)head;
 	kmem_cache_t *cachep = slab_rcu->cachep;
 
 	kmem_freepages(cachep, slab_rcu->addr);
@@ -1246,19 +1248,19 @@ static void kmem_rcu_free(struct rcu_hea
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 static void store_stackinfo(kmem_cache_t *cachep, unsigned long *addr,
-				unsigned long caller)
+			    unsigned long caller)
 {
 	int size = obj_reallen(cachep);
 
-	addr = (unsigned long *)&((char*)addr)[obj_dbghead(cachep)];
+	addr = (unsigned long *)&((char *)addr)[obj_dbghead(cachep)];
 
-	if (size < 5*sizeof(unsigned long))
+	if (size < 5 * sizeof(unsigned long))
 		return;
 
-	*addr++=0x12345678;
-	*addr++=caller;
-	*addr++=smp_processor_id();
-	size -= 3*sizeof(unsigned long);
+	*addr++ = 0x12345678;
+	*addr++ = caller;
+	*addr++ = smp_processor_id();
+	size -= 3 * sizeof(unsigned long);
 	{
 		unsigned long *sptr = &caller;
 		unsigned long svalue;
@@ -1266,34 +1268,32 @@ static void store_stackinfo(kmem_cache_t
 		while (!kstack_end(sptr)) {
 			svalue = *sptr++;
 			if (kernel_text_address(svalue)) {
-				*addr++=svalue;
+				*addr++ = svalue;
 				size -= sizeof(unsigned long);
 				if (size <= sizeof(unsigned long))
 					break;
 			}
 		}
-
 	}
-	*addr++=0x87654321;
+	*addr++ = 0x87654321;
 }
 #endif
 
 static void poison_obj(kmem_cache_t *cachep, void *addr, unsigned char val)
 {
 	int size = obj_reallen(cachep);
-	addr = &((char*)addr)[obj_dbghead(cachep)];
+	addr = &((char *)addr)[obj_dbghead(cachep)];
 
 	memset(addr, val, size);
-	*(unsigned char *)(addr+size-1) = POISON_END;
+	*(unsigned char *)(addr + size - 1) = POISON_END;
 }
 
 static void dump_line(char *data, int offset, int limit)
 {
 	int i;
 	printk(KERN_ERR "%03x:", offset);
-	for (i=0;i<limit;i++) {
+	for (i = 0; i < limit; i++)
 		printk(" %02x", (unsigned char)data[offset+i]);
-	}
 	printk("\n");
 }
 #endif
@@ -1307,24 +1307,24 @@ static void print_objinfo(kmem_cache_t *
 
 	if (cachep->flags & SLAB_RED_ZONE) {
 		printk(KERN_ERR "Redzone: 0x%lx/0x%lx.\n",
-			*dbg_redzone1(cachep, objp),
-			*dbg_redzone2(cachep, objp));
+		       *dbg_redzone1(cachep, objp),
+		       *dbg_redzone2(cachep, objp));
 	}
 
 	if (cachep->flags & SLAB_STORE_USER) {
 		printk(KERN_ERR "Last user: [<%p>]",
-				*dbg_userword(cachep, objp));
+		       *dbg_userword(cachep, objp));
 		print_symbol("(%s)",
 				(unsigned long)*dbg_userword(cachep, objp));
 		printk("\n");
 	}
-	realobj = (char*)objp+obj_dbghead(cachep);
+	realobj = (char *)objp + obj_dbghead(cachep);
 	size = obj_reallen(cachep);
-	for (i=0; i<size && lines;i+=16, lines--) {
+	for (i = 0; i < size && lines; i += 16, lines--) {
 		int limit;
 		limit = 16;
-		if (i+limit > size)
-			limit = size-i;
+		if (i + limit > size)
+			limit = size - i;
 		dump_line(realobj, i, limit);
 	}
 }
@@ -1335,27 +1335,27 @@ static void check_poison_obj(kmem_cache_
 	int size, i;
 	int lines = 0;
 
-	realobj = (char*)objp+obj_dbghead(cachep);
+	realobj = (char *)objp + obj_dbghead(cachep);
 	size = obj_reallen(cachep);
 
-	for (i=0;i<size;i++) {
+	for (i = 0; i < size; i++) {
 		char exp = POISON_FREE;
-		if (i == size-1)
+		if (i == size - 1)
 			exp = POISON_END;
 		if (realobj[i] != exp) {
 			int limit;
 			/* Mismatch ! */
 			/* Print header */
 			if (lines == 0) {
-				printk(KERN_ERR "Slab corruption: start=%p, len=%d\n",
-						realobj, size);
+				printk(KERN_ERR "Slab corruption: start=%p, "
+				       "len=%d\n", realobj, size);
 				print_objinfo(cachep, objp, 0);
 			}
 			/* Hexdump the affected line */
-			i = (i/16)*16;
+			i = (i / 16) * 16;
 			limit = 16;
-			if (i+limit > size)
-				limit = size-i;
+			if (i + limit > size)
+				limit = size - i;
 			dump_line(realobj, i, limit);
 			i += 16;
 			lines++;
@@ -1365,36 +1365,35 @@ static void check_poison_obj(kmem_cache_
 		}
 	}
 	if (lines != 0) {
-		/* Print some data about the neighboring objects, if they
-		 * exist:
-		 */
+		/* Print data about the neighboring objects, if they exist */
 		struct slab *slabp = GET_PAGE_SLAB(virt_to_page(objp));
 		int objnr;
 
-		objnr = (objp-slabp->s_mem)/cachep->objsize;
+		objnr = (objp - slabp->s_mem) / cachep->objsize;
 		if (objnr) {
-			objp = slabp->s_mem+(objnr-1)*cachep->objsize;
-			realobj = (char*)objp+obj_dbghead(cachep);
+			objp = slabp->s_mem + (objnr - 1) * cachep->objsize;
+			realobj = (char *)objp + obj_dbghead(cachep);
 			printk(KERN_ERR "Prev obj: start=%p, len=%d\n",
-						realobj, size);
+			       realobj, size);
 			print_objinfo(cachep, objp, 2);
 		}
-		if (objnr+1 < cachep->num) {
-			objp = slabp->s_mem+(objnr+1)*cachep->objsize;
-			realobj = (char*)objp+obj_dbghead(cachep);
+		if (objnr + 1 < cachep->num) {
+			objp = slabp->s_mem + (objnr + 1) * cachep->objsize;
+			realobj = (char *)objp + obj_dbghead(cachep);
 			printk(KERN_ERR "Next obj: start=%p, len=%d\n",
-						realobj, size);
+			       realobj, size);
 			print_objinfo(cachep, objp, 2);
 		}
 	}
 }
 #endif
 
-/* Destroy all the objs in a slab, and release the mem back to the system.
+/*
+ * Destroy all the objs in a slab, and release the mem back to the system.
  * Before calling the slab must have been unlinked from the cache.
  * The cache-lock is not held/needed.
  */
-static void slab_destroy (kmem_cache_t *cachep, struct slab *slabp)
+static void slab_destroy(kmem_cache_t *cachep, struct slab *slabp)
 {
 	void *addr = slabp->s_mem - slabp->colouroff;
 
@@ -1405,8 +1404,10 @@ static void slab_destroy (kmem_cache_t *
 
 		if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
-			if ((cachep->objsize%PAGE_SIZE)==0 && OFF_SLAB(cachep))
-				kernel_map_pages(virt_to_page(objp), cachep->objsize/PAGE_SIZE,1);
+			if ((cachep->objsize % PAGE_SIZE) == 0 &&
+			    OFF_SLAB(cachep))
+				kernel_map_pages(virt_to_page(objp),
+						 cachep->objsize/PAGE_SIZE, 1);
 			else
 				check_poison_obj(cachep, objp);
 #else
@@ -1422,13 +1423,13 @@ static void slab_destroy (kmem_cache_t *
 							"was overwritten");
 		}
 		if (cachep->dtor && !(cachep->flags & SLAB_POISON))
-			(cachep->dtor)(objp+obj_dbghead(cachep), cachep, 0);
+			(cachep->dtor)(objp + obj_dbghead(cachep), cachep, 0);
 	}
 #else
 	if (cachep->dtor) {
 		int i;
 		for (i = 0; i < cachep->num; i++) {
-			void* objp = slabp->s_mem+cachep->objsize*i;
+			void *objp = slabp->s_mem + cachep->objsize * i;
 			(cachep->dtor)(objp, cachep, 0);
 		}
 	}
@@ -1437,7 +1438,7 @@ static void slab_destroy (kmem_cache_t *
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
 		struct slab_rcu *slab_rcu;
 
-		slab_rcu = (struct slab_rcu *) slabp;
+		slab_rcu = (struct slab_rcu *)slabp;
 		slab_rcu->cachep = cachep;
 		slab_rcu->addr = addr;
 		call_rcu(&slab_rcu->head, kmem_rcu_free);
@@ -1448,21 +1449,70 @@ static void slab_destroy (kmem_cache_t *
 	}
 }
 
-/* For setting up all the kmem_list3s for cache whose objsize is same
-   as size of kmem_list3. */
+/*
+ * For setting up all the kmem_list3s for cache whose objsize is same
+ * as size of kmem_list3.
+ */
 static inline void set_up_list3s(kmem_cache_t *cachep, int index)
 {
-	int node;
+	int nid;
 
-	for_each_online_node(node) {
-		cachep->nodelists[node] = &initkmem_list3[index+node];
-		cachep->nodelists[node]->next_reap = jiffies +
+	for_each_online_node(nid) {
+		cachep->nodelists[nid] = &initkmem_list3[index + nid];
+		cachep->nodelists[nid]->next_reap = jiffies +
 			REAPTIMEOUT_LIST3 +
-			((unsigned long)cachep)%REAPTIMEOUT_LIST3;
+			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 	}
 }
 
 /**
+ * calculate_slab_order - calculate size (page order) of slabs and the number
+ *                        of objects per slab.
+ *
+ * This could be made much more intelligent.  For now, try to avoid using
+ * high order pages for slabs.  When the gfp() functions are more friendly
+ * towards high-order requests, this should be changed.
+ */
+static inline size_t calculate_slab_order(kmem_cache_t *cachep, size_t size,
+					  size_t align, gfp_t flags)
+{
+	size_t left_over = 0;
+
+	for ( ; ; cachep->gfporder++) {
+		unsigned int num;
+		size_t remainder;
+
+		if (cachep->gfporder > MAX_GFP_ORDER) {
+			cachep->num = 0;
+			break;
+		}
+
+		cache_estimate(cachep->gfporder, size, align, flags,
+			       &remainder, &num);
+		if (!num)
+			continue;
+		/* More than offslab_limit objects will cause problems */
+		if (flags & CFLGS_OFF_SLAB && cachep->num > offslab_limit)
+			break; 
+
+		cachep->num = num;
+		left_over = remainder;
+
+		/*
+		 * Large number of objects is good, but very large slabs are
+		 * currently bad for the gfp()s.
+		 */
+		if (cachep->gfporder >= slab_break_gfp_order)
+			break;
+
+		if ((left_over * 8) <= (PAGE_SIZE << cachep->gfporder))
+			break;	/* Acceptable internal fragmentation */
+	}
+
+	return left_over;
+}
+
+/**
  * kmem_cache_create - Create a cache.
  * @name: A string which is used in /proc/slabinfo to identify this cache.
  * @size: The size of objects to be created in this cache.
@@ -1477,9 +1527,9 @@ static inline void set_up_list3s(kmem_ca
  * and the @dtor is run before the pages are handed back.
  *
  * @name must be valid until the cache is destroyed. This implies that
- * the module calling this has to destroy the cache before getting 
+ * the module calling this has to destroy the cache before getting
  * unloaded.
- * 
+ *
  * The flags are
  *
  * %SLAB_POISON - Poison the slab with a known test pattern (a5a5a5a5)
@@ -1495,32 +1545,28 @@ static inline void set_up_list3s(kmem_ca
  * cacheline.  This can be beneficial if you're counting cycles as closely
  * as davem.
  */
-kmem_cache_t *
-kmem_cache_create (const char *name, size_t size, size_t align,
-	unsigned long flags, void (*ctor)(void*, kmem_cache_t *, unsigned long),
-	void (*dtor)(void*, kmem_cache_t *, unsigned long))
+kmem_cache_t *kmem_cache_create(const char *name, size_t size, size_t align,
+				unsigned long flags,
+				void (*ctor)(void *, kmem_cache_t *, unsigned long),
+				void (*dtor)(void *, kmem_cache_t *, unsigned long))
 {
-	size_t left_over, slab_size, ralign;
+	size_t left_over, slab_size, aligned_slab_size, ralign;
 	kmem_cache_t *cachep = NULL;
-	struct list_head *p;
+	kmem_cache_t *pc;
 
 	/*
 	 * Sanity checks... these are all serious usage bugs.
 	 */
-	if ((!name) ||
-		in_interrupt() ||
-		(size < BYTES_PER_WORD) ||
-		(size > (1<<MAX_OBJ_ORDER)*PAGE_SIZE) ||
-		(dtor && !ctor)) {
-			printk(KERN_ERR "%s: Early error in slab %s\n",
-					__FUNCTION__, name);
-			BUG();
-		}
+	if (!name || in_interrupt() || (size < BYTES_PER_WORD) ||
+	    (size > (1 << MAX_OBJ_ORDER) * PAGE_SIZE) || (dtor && !ctor)) {
+		printk(KERN_ERR "%s: Early error in slab %s\n",
+		       __FUNCTION__, name);
+		BUG();
+	}
 
 	down(&cache_chain_sem);
 
-	list_for_each(p, &cache_chain) {
-		kmem_cache_t *pc = list_entry(p, kmem_cache_t, next);
+	list_for_each_entry(pc, &cache_chain, next) {
 		mm_segment_t old_fs = get_fs();
 		char tmp;
 		int res;
@@ -1542,7 +1588,7 @@ kmem_cache_create (const char *name, siz
 		if (!strcmp(pc->name,name)) {
 			printk("kmem_cache_create: duplicate cache %s\n", name);
 			dump_stack();
-			goto oops;
+			goto out;
 		}
 	}
 
@@ -1562,7 +1608,8 @@ kmem_cache_create (const char *name, siz
 	 * above the next power of two: caches with object sizes just above a
 	 * power of two have a significant amount of internal fragmentation.
 	 */
-	if ((size < 4096 || fls(size-1) == fls(size-1+3*BYTES_PER_WORD)))
+	if (size < RED_ZONE_LIMIT ||
+	    fls(size - 1) == fls(size - 1 + 3 * BYTES_PER_WORD))
 		flags |= SLAB_RED_ZONE|SLAB_STORE_USER;
 	if (!(flags & SLAB_DESTROY_BY_RCU))
 		flags |= SLAB_POISON;
@@ -1580,24 +1627,26 @@ kmem_cache_create (const char *name, siz
 	if (flags & ~CREATE_MASK)
 		BUG();
 
-	/* Check that size is in terms of words.  This is needed to avoid
+	/*
+	 * Check that size is in terms of words.  This is needed to avoid
 	 * unaligned accesses for some archs when redzoning is used, and makes
 	 * sure any on-slab bufctl's are also correctly aligned.
 	 */
-	if (size & (BYTES_PER_WORD-1)) {
-		size += (BYTES_PER_WORD-1);
-		size &= ~(BYTES_PER_WORD-1);
+	if (size & (BYTES_PER_WORD - 1)) {
+		size += (BYTES_PER_WORD - 1);
+		size &= ~(BYTES_PER_WORD - 1);
 	}
 
 	/* calculate out the final buffer alignment: */
 	/* 1) arch recommendation: can be overridden for debug */
 	if (flags & SLAB_HWCACHE_ALIGN) {
-		/* Default alignment: as specified by the arch code.
+		/*
+		 * Default alignment: as specified by the arch code.
 		 * Except if an object is really small, then squeeze multiple
 		 * objects into one cacheline.
 		 */
 		ralign = cache_line_size();
-		while (size <= ralign/2)
+		while (size <= ralign / 2)
 			ralign /= 2;
 	} else {
 		ralign = BYTES_PER_WORD;
@@ -1614,7 +1663,8 @@ kmem_cache_create (const char *name, siz
 		if (ralign > BYTES_PER_WORD)
 			flags &= ~(SLAB_RED_ZONE|SLAB_STORE_USER);
 	}
-	/* 4) Store it. Note that the debug code below can reduce
+	/*
+	 * 4) Store it. Note that the debug code below can reduce
 	 *    the alignment to BYTES_PER_WORD.
 	 */
 	align = ralign;
@@ -1622,7 +1672,7 @@ kmem_cache_create (const char *name, siz
 	/* Get cache's description obj. */
 	cachep = (kmem_cache_t *) kmem_cache_alloc(&cache_cache, SLAB_KERNEL);
 	if (!cachep)
-		goto oops;
+		goto out;
 	memset(cachep, 0, sizeof(kmem_cache_t));
 
 #if DEBUG
@@ -1634,10 +1684,11 @@ kmem_cache_create (const char *name, siz
 
 		/* add space for red zone words */
 		cachep->dbghead += BYTES_PER_WORD;
-		size += 2*BYTES_PER_WORD;
+		size += 2 * BYTES_PER_WORD;
 	}
 	if (flags & SLAB_STORE_USER) {
-		/* user store requires word alignment and
+		/*
+		 * user store requires word alignment and
 		 * one word storage behind the end of the real
 		 * object.
 		 */
@@ -1645,7 +1696,8 @@ kmem_cache_create (const char *name, siz
 		size += BYTES_PER_WORD;
 	}
 #if FORCED_DEBUG && defined(CONFIG_DEBUG_PAGEALLOC)
-	if (size >= malloc_sizes[INDEX_L3+1].cs_size && cachep->reallen > cache_line_size() && size < PAGE_SIZE) {
+	if (size >= malloc_sizes[INDEX_L3+1].cs_size &&
+	    cachep->reallen > cache_line_size() && size < PAGE_SIZE) {
 		cachep->dbghead += PAGE_SIZE - size;
 		size = PAGE_SIZE;
 	}
@@ -1653,7 +1705,7 @@ kmem_cache_create (const char *name, siz
 #endif
 
 	/* Determine if the slab management is 'on' or 'off' slab. */
-	if (size >= (PAGE_SIZE>>3))
+	if (size >= (PAGE_SIZE >> 3))
 		/*
 		 * Size is large, assume best to place the slab management obj
 		 * off-slab (should allow better packing of objs).
@@ -1665,75 +1717,35 @@ kmem_cache_create (const char *name, siz
 	if ((flags & SLAB_RECLAIM_ACCOUNT) && size <= PAGE_SIZE) {
 		/*
 		 * A VFS-reclaimable slab tends to have most allocations
-		 * as GFP_NOFS and we really don't want to have to be allocating
+		 * as GFP_NOFS & we really don't want to have to be allocating
 		 * higher-order pages when we are unable to shrink dcache.
 		 */
 		cachep->gfporder = 0;
 		cache_estimate(cachep->gfporder, size, align, flags,
-					&left_over, &cachep->num);
-	} else {
-		/*
-		 * Calculate size (in pages) of slabs, and the num of objs per
-		 * slab.  This could be made much more intelligent.  For now,
-		 * try to avoid using high page-orders for slabs.  When the
-		 * gfp() funcs are more friendly towards high-order requests,
-		 * this should be changed.
-		 */
-		do {
-			unsigned int break_flag = 0;
-cal_wastage:
-			cache_estimate(cachep->gfporder, size, align, flags,
-						&left_over, &cachep->num);
-			if (break_flag)
-				break;
-			if (cachep->gfporder >= MAX_GFP_ORDER)
-				break;
-			if (!cachep->num)
-				goto next;
-			if (flags & CFLGS_OFF_SLAB &&
-					cachep->num > offslab_limit) {
-				/* This num of objs will cause problems. */
-				cachep->gfporder--;
-				break_flag++;
-				goto cal_wastage;
-			}
-
-			/*
-			 * Large num of objs is good, but v. large slabs are
-			 * currently bad for the gfp()s.
-			 */
-			if (cachep->gfporder >= slab_break_gfp_order)
-				break;
-
-			if ((left_over*8) <= (PAGE_SIZE<<cachep->gfporder))
-				break;	/* Acceptable internal fragmentation. */
-next:
-			cachep->gfporder++;
-		} while (1);
-	}
+			       &left_over, &cachep->num);
+	} else
+		left_over = calculate_slab_order(cachep, size, align, flags);
 
 	if (!cachep->num) {
 		printk("kmem_cache_create: couldn't create cache %s.\n", name);
 		kmem_cache_free(&cache_cache, cachep);
 		cachep = NULL;
-		goto oops;
+		goto out;
 	}
-	slab_size = ALIGN(cachep->num*sizeof(kmem_bufctl_t)
-				+ sizeof(struct slab), align);
+	slab_size = cachep->num * sizeof(kmem_bufctl_t) + sizeof(struct slab);
+	aligned_slab_size = ALIGN(slab_size, align);
 
 	/*
 	 * If the slab has been placed off-slab, and we have enough space then
 	 * move it on-slab. This is at the expense of any extra colouring.
 	 */
-	if (flags & CFLGS_OFF_SLAB && left_over >= slab_size) {
+	if (flags & CFLGS_OFF_SLAB && left_over >= aligned_slab_size) {
 		flags &= ~CFLGS_OFF_SLAB;
-		left_over -= slab_size;
-	}
-
-	if (flags & CFLGS_OFF_SLAB) {
-		/* really off slab. No need for manual alignment */
-		slab_size = cachep->num*sizeof(kmem_bufctl_t)+sizeof(struct slab);
+		left_over -= aligned_slab_size;
 	}
+	/* On slab, need manual alignment */
+	if (!(flags & CFLGS_OFF_SLAB))
+		slab_size = aligned_slab_size;
 
 	cachep->colour_off = cache_line_size();
 	/* Offset must be a multiple of the alignment. */
@@ -1761,14 +1773,16 @@ next:
 		enable_cpucache(cachep);
 	} else {
 		if (g_cpucache_up == NONE) {
-			/* Note: the first kmem_cache_create must create
+			/*
+			 * Note: the first kmem_cache_create must create
 			 * the cache that's used by kmalloc(24), otherwise
 			 * the creation of further caches will BUG().
 			 */
 			cachep->array[smp_processor_id()] =
 				&initarray_generic.cache;
 
-			/* If the cache that's used by
+			/*
+			 * If the cache that's used by
 			 * kmalloc(sizeof(kmem_list3)) is the first cache,
 			 * then we need to set up all its list3s, otherwise
 			 * the creation of further caches will BUG().
@@ -1787,14 +1801,13 @@ next:
 				set_up_list3s(cachep, SIZE_L3);
 				g_cpucache_up = PARTIAL_L3;
 			} else {
-				int node;
-				for_each_online_node(node) {
-
-					cachep->nodelists[node] =
+				int nid;
+				for_each_online_node(nid) {
+					cachep->nodelists[nid] =
 						kmalloc_node(sizeof(struct kmem_list3),
-								GFP_KERNEL, node);
-					BUG_ON(!cachep->nodelists[node]);
-					kmem_list3_init(cachep->nodelists[node]);
+							     GFP_KERNEL, nid);
+					BUG_ON(!cachep->nodelists[nid]);
+					kmem_list3_init(cachep->nodelists[nid]);
 				}
 			}
 		}
@@ -1809,15 +1822,14 @@ next:
 		ac_data(cachep)->touched = 0;
 		cachep->batchcount = 1;
 		cachep->limit = BOOT_CPUCACHE_ENTRIES;
-	} 
+	}
 
 	/* cache setup completed, link it into the list */
 	list_add(&cachep->next, &cache_chain);
 	unlock_cpu_hotplug();
-oops:
+out:
 	if (!cachep && (flags & SLAB_PANIC))
-		panic("kmem_cache_create(): failed to create slab `%s'\n",
-			name);
+		panic("%s: failed to create slab `%s'\n", __FUNCTION__, name);
 	up(&cache_chain_sem);
 	return cachep;
 }
@@ -1842,25 +1854,25 @@ static void check_spinlock_acquired(kmem
 #endif
 }
 
-static inline void check_spinlock_acquired_node(kmem_cache_t *cachep, int node)
+static inline void check_spinlock_acquired_node(kmem_cache_t *cachep, int nid)
 {
 #ifdef CONFIG_SMP
 	check_irq_off();
-	assert_spin_locked(&cachep->nodelists[node]->list_lock);
+	assert_spin_locked(&cachep->nodelists[nid]->list_lock);
 #endif
 }
 
 #else
-#define check_irq_off()	do { } while(0)
-#define check_irq_on()	do { } while(0)
-#define check_spinlock_acquired(x) do { } while(0)
-#define check_spinlock_acquired_node(x, y) do { } while(0)
+#define check_irq_off()				do { } while(0)
+#define check_irq_on()				do { } while(0)
+#define check_spinlock_acquired(x)		do { } while(0)
+#define check_spinlock_acquired_node(x, y)	do { } while(0)
 #endif
 
 /*
  * Waits for all CPUs to execute func().
  */
-static void smp_call_function_all_cpus(void (*func) (void *arg), void *arg)
+static void smp_call_function_all_cpus(void (*func)(void *arg), void *arg)
 {
 	check_irq_on();
 	preempt_disable();
@@ -1875,36 +1887,36 @@ static void smp_call_function_all_cpus(v
 	preempt_enable();
 }
 
-static void drain_array_locked(kmem_cache_t* cachep,
-				struct array_cache *ac, int force, int node);
+static void drain_array_locked(kmem_cache_t *cachep, struct array_cache *ac,
+			       int force, int nid);
 
 static void do_drain(void *arg)
 {
-	kmem_cache_t *cachep = (kmem_cache_t*)arg;
+	kmem_cache_t *cachep = (kmem_cache_t *)arg;
 	struct array_cache *ac;
-	int node = numa_node_id();
+	int nid = numa_node_id();
 
 	check_irq_off();
 	ac = ac_data(cachep);
-	spin_lock(&cachep->nodelists[node]->list_lock);
-	free_block(cachep, ac->entry, ac->avail, node);
-	spin_unlock(&cachep->nodelists[node]->list_lock);
+	spin_lock(&cachep->nodelists[nid]->list_lock);
+	free_block(cachep, ac->entry, ac->avail, nid);
+	spin_unlock(&cachep->nodelists[nid]->list_lock);
 	ac->avail = 0;
 }
 
 static void drain_cpu_caches(kmem_cache_t *cachep)
 {
 	struct kmem_list3 *l3;
-	int node;
+	int nid;
 
 	smp_call_function_all_cpus(do_drain, cachep);
 	check_irq_on();
 	spin_lock_irq(&cachep->spinlock);
-	for_each_online_node(node)  {
-		l3 = cachep->nodelists[node];
+	for_each_online_node(nid) {
+		l3 = cachep->nodelists[nid];
 		if (l3) {
 			spin_lock(&l3->list_lock);
-			drain_array_locked(cachep, l3->shared, 1, node);
+			drain_array_locked(cachep, l3->shared, 1, nid);
 			spin_unlock(&l3->list_lock);
 			if (l3->alien)
 				drain_alien_cache(cachep, l3);
@@ -1913,10 +1925,10 @@ static void drain_cpu_caches(kmem_cache_
 	spin_unlock_irq(&cachep->spinlock);
 }
 
-static int __node_shrink(kmem_cache_t *cachep, int node)
+static int __node_shrink(kmem_cache_t *cachep, int nid)
 {
 	struct slab *slabp;
-	struct kmem_list3 *l3 = cachep->nodelists[node];
+	struct kmem_list3 *l3 = cachep->nodelists[nid];
 	int ret;
 
 	for (;;) {
@@ -1938,11 +1950,17 @@ static int __node_shrink(kmem_cache_t *c
 		slab_destroy(cachep, slabp);
 		spin_lock_irq(&l3->list_lock);
 	}
-	ret = !list_empty(&l3->slabs_full) ||
-		!list_empty(&l3->slabs_partial);
+	ret = !list_empty(&l3->slabs_full) || !list_empty(&l3->slabs_partial);
 	return ret;
 }
 
+/**
+ * __cache_shrink - Release all free slabs
+ * @cachep: The cache to shrink.
+ *
+ * Return 1 if there are still partial or full slabs belonging to this cache
+ * Return 0 if there are no more slabs belonging to this cache
+ */
 static int __cache_shrink(kmem_cache_t *cachep)
 {
 	int ret = 0, i = 0;
@@ -1959,7 +1977,7 @@ static int __cache_shrink(kmem_cache_t *
 			spin_unlock_irq(&l3->list_lock);
 		}
 	}
-	return (ret ? 1 : 0);
+	return ret ? 1 : 0;
 }
 
 /**
@@ -1995,7 +2013,7 @@ EXPORT_SYMBOL(kmem_cache_shrink);
  * The caller must guarantee that noone will allocate memory from the cache
  * during the kmem_cache_destroy().
  */
-int kmem_cache_destroy(kmem_cache_t * cachep)
+int kmem_cache_destroy(kmem_cache_t *cachep)
 {
 	int i;
 	struct kmem_list3 *l3;
@@ -2008,9 +2026,7 @@ int kmem_cache_destroy(kmem_cache_t * ca
 
 	/* Find the cache in the chain of caches. */
 	down(&cache_chain_sem);
-	/*
-	 * the chain is never empty, cache_cache is never destroyed
-	 */
+	/* the chain is never empty, cache_cache is never destroyed */
 	list_del(&cachep->next);
 	up(&cache_chain_sem);
 
@@ -2046,8 +2062,8 @@ int kmem_cache_destroy(kmem_cache_t * ca
 EXPORT_SYMBOL(kmem_cache_destroy);
 
 /* Get the memory for a slab management obj. */
-static struct slab* alloc_slabmgmt(kmem_cache_t *cachep, void *objp,
-			int colour_off, gfp_t local_flags)
+static struct slab *alloc_slabmgmt(kmem_cache_t *cachep, void *objp,
+				   int colour_off, gfp_t local_flags)
 {
 	struct slab *slabp;
 	
@@ -2057,28 +2073,28 @@ static struct slab* alloc_slabmgmt(kmem_
 		if (!slabp)
 			return NULL;
 	} else {
-		slabp = objp+colour_off;
+		slabp = objp + colour_off;
 		colour_off += cachep->slab_size;
 	}
 	slabp->inuse = 0;
 	slabp->colouroff = colour_off;
-	slabp->s_mem = objp+colour_off;
+	slabp->s_mem = objp + colour_off;
 
 	return slabp;
 }
 
 static inline kmem_bufctl_t *slab_bufctl(struct slab *slabp)
 {
-	return (kmem_bufctl_t *)(slabp+1);
+	return (kmem_bufctl_t *)(slabp + 1);
 }
 
-static void cache_init_objs(kmem_cache_t *cachep,
-			struct slab *slabp, unsigned long ctor_flags)
+static void cache_init_objs(kmem_cache_t *cachep, struct slab *slabp,
+			    unsigned long ctor_flags)
 {
 	int i;
 
 	for (i = 0; i < cachep->num; i++) {
-		void *objp = slabp->s_mem+cachep->objsize*i;
+		void *objp = slabp->s_mem + cachep->objsize * i;
 #if DEBUG
 		/* need to poison the objs? */
 		if (cachep->flags & SLAB_POISON)
@@ -2096,7 +2112,8 @@ static void cache_init_objs(kmem_cache_t
 		 * Otherwise, deadlock. They must also be threaded.
 		 */
 		if (cachep->ctor && !(cachep->flags & SLAB_POISON))
-			cachep->ctor(objp+obj_dbghead(cachep), cachep, ctor_flags);
+			cachep->ctor(objp + obj_dbghead(cachep), cachep,
+				     ctor_flags);
 
 		if (cachep->flags & SLAB_RED_ZONE) {
 			if (*dbg_redzone2(cachep, objp) != RED_INACTIVE)
@@ -2106,15 +2123,17 @@ static void cache_init_objs(kmem_cache_t
 				slab_error(cachep, "constructor overwrote the"
 							" start of an object");
 		}
-		if ((cachep->objsize % PAGE_SIZE) == 0 && OFF_SLAB(cachep) && cachep->flags & SLAB_POISON)
-	       		kernel_map_pages(virt_to_page(objp), cachep->objsize/PAGE_SIZE, 0);
+		if ((cachep->objsize % PAGE_SIZE) == 0 && OFF_SLAB(cachep) &&
+		    cachep->flags & SLAB_POISON)
+			kernel_map_pages(virt_to_page(objp),
+					 cachep->objsize / PAGE_SIZE, 0);
 #else
 		if (cachep->ctor)
 			cachep->ctor(objp, cachep, ctor_flags);
 #endif
-		slab_bufctl(slabp)[i] = i+1;
+		slab_bufctl(slabp)[i] = i + 1;
 	}
-	slab_bufctl(slabp)[i-1] = BUFCTL_END;
+	slab_bufctl(slabp)[i - 1] = BUFCTL_END;
 	slabp->free = 0;
 }
 
@@ -2134,31 +2153,31 @@ static void set_slab_attr(kmem_cache_t *
 	int i;
 	struct page *page;
 
-	/* Nasty!!!!!! I hope this is OK. */
 	i = 1 << cachep->gfporder;
 	page = virt_to_page(objp);
-	do {
+	while (i--) {
 		SET_PAGE_CACHE(page, cachep);
 		SET_PAGE_SLAB(page, slabp);
 		page++;
-	} while (--i);
+	}
 }
 
 /*
  * Grow (by 1) the number of slabs within a cache.  This is called by
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
-static int cache_grow(kmem_cache_t *cachep, gfp_t flags, int nodeid)
+static int cache_grow(kmem_cache_t *cachep, gfp_t flags, int nid)
 {
-	struct slab	*slabp;
-	void		*objp;
-	size_t		 offset;
-	gfp_t	 	 local_flags;
-	unsigned long	 ctor_flags;
+	struct slab *slabp;
+	void *objp;
+	size_t offset;
+	gfp_t local_flags;
+	unsigned long ctor_flags;
 	struct kmem_list3 *l3;
 
-	/* Be lazy and only check for valid flags here,
- 	 * keeping it out of the critical path in kmem_cache_alloc().
+	/*
+	 * Be lazy and only check for valid flags here,
+	 * keeping it out of the critical path in kmem_cache_alloc().
 	 */
 	if (flags & ~(SLAB_DMA|SLAB_LEVEL_MASK|SLAB_NO_GROW))
 		BUG();
@@ -2192,24 +2211,22 @@ static int cache_grow(kmem_cache_t *cach
 		local_irq_enable();
 
 	/*
-	 * The test for missing atomic flag is performed here, rather than
-	 * the more obvious place, simply to reduce the critical path length
-	 * in kmem_cache_alloc(). If a caller is seriously mis-behaving they
-	 * will eventually be caught here (where it matters).
+	 * Ensure caller isn't asking for DMA memory if the slab wasn't created
+	 * with the SLAB_DMA flag.
+	 * Also ensure the caller *is* asking for DMA memory if the slab was
+	 * created with the SLAB_DMA flag.
 	 */
 	kmem_flagcheck(cachep, flags);
 
-	/* Get mem for the objs.
-	 * Attempt to allocate a physical page from 'nodeid',
-	 */
-	if (!(objp = kmem_getpages(cachep, flags, nodeid)))
-		goto failed;
+	/* Get mem for the objects by allocating a physical page from 'nid' */
+	if (!(objp = kmem_getpages(cachep, flags, nid)))
+		goto out_nomem;
 
 	/* Get slab management. */
 	if (!(slabp = alloc_slabmgmt(cachep, objp, offset, local_flags)))
-		goto opps1;
+		goto out_freepages;
 
-	slabp->nodeid = nodeid;
+	slabp->nid = nid;
 	set_slab_attr(cachep, slabp, objp);
 
 	cache_init_objs(cachep, slabp, ctor_flags);
@@ -2217,7 +2234,7 @@ static int cache_grow(kmem_cache_t *cach
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	check_irq_off();
-	l3 = cachep->nodelists[nodeid];
+	l3 = cachep->nodelists[nid];
 	spin_lock(&l3->list_lock);
 
 	/* Make slab active. */
@@ -2226,16 +2243,15 @@ static int cache_grow(kmem_cache_t *cach
 	l3->free_objects += cachep->num;
 	spin_unlock(&l3->list_lock);
 	return 1;
-opps1:
+out_freepages:
 	kmem_freepages(cachep, objp);
-failed:
+out_nomem:
 	if (local_flags & __GFP_WAIT)
 		local_irq_disable();
 	return 0;
 }
 
 #if DEBUG
-
 /*
  * Perform extra freeing checks:
  * - detect bad pointers.
@@ -2248,18 +2264,19 @@ static void kfree_debugcheck(const void 
 
 	if (!virt_addr_valid(objp)) {
 		printk(KERN_ERR "kfree_debugcheck: out of range ptr %lxh.\n",
-			(unsigned long)objp);	
-		BUG();	
+		       (unsigned long)objp);
+		BUG();
 	}
 	page = virt_to_page(objp);
 	if (!PageSlab(page)) {
-		printk(KERN_ERR "kfree_debugcheck: bad ptr %lxh.\n", (unsigned long)objp);
+		printk(KERN_ERR "kfree_debugcheck: bad ptr %lxh.\n",
+		       (unsigned long)objp);
 		BUG();
 	}
 }
 
 static void *cache_free_debugcheck(kmem_cache_t *cachep, void *objp,
-					void *caller)
+				   void *caller)
 {
 	struct page *page;
 	unsigned int objnr;
@@ -2270,20 +2287,25 @@ static void *cache_free_debugcheck(kmem_
 	page = virt_to_page(objp);
 
 	if (GET_PAGE_CACHE(page) != cachep) {
-		printk(KERN_ERR "mismatch in kmem_cache_free: expected cache %p, got %p\n",
-				GET_PAGE_CACHE(page),cachep);
+		printk(KERN_ERR "mismatch in kmem_cache_free: "
+		       "expected cache %p, got %p\n",
+		       GET_PAGE_CACHE(page), cachep);
 		printk(KERN_ERR "%p is %s.\n", cachep, cachep->name);
-		printk(KERN_ERR "%p is %s.\n", GET_PAGE_CACHE(page), GET_PAGE_CACHE(page)->name);
+		printk(KERN_ERR "%p is %s.\n", GET_PAGE_CACHE(page),
+		       GET_PAGE_CACHE(page)->name);
 		WARN_ON(1);
 	}
 	slabp = GET_PAGE_SLAB(page);
 
 	if (cachep->flags & SLAB_RED_ZONE) {
-		if (*dbg_redzone1(cachep, objp) != RED_ACTIVE || *dbg_redzone2(cachep, objp) != RED_ACTIVE) {
+		if (*dbg_redzone1(cachep, objp) != RED_ACTIVE ||
+		    *dbg_redzone2(cachep, objp) != RED_ACTIVE) {
 			slab_error(cachep, "double free, or memory outside"
-						" object was overwritten");
-			printk(KERN_ERR "%p: redzone 1: 0x%lx, redzone 2: 0x%lx.\n",
-					objp, *dbg_redzone1(cachep, objp), *dbg_redzone2(cachep, objp));
+				   " object was overwritten");
+			printk(KERN_ERR "%p: redzone 1: 0x%lx, "
+			       "redzone 2: 0x%lx.\n", objp,
+			       *dbg_redzone1(cachep, objp),
+			       *dbg_redzone2(cachep, objp));
 		}
 		*dbg_redzone1(cachep, objp) = RED_INACTIVE;
 		*dbg_redzone2(cachep, objp) = RED_INACTIVE;
@@ -2294,27 +2316,30 @@ static void *cache_free_debugcheck(kmem_
 	objnr = (objp-slabp->s_mem)/cachep->objsize;
 
 	BUG_ON(objnr >= cachep->num);
-	BUG_ON(objp != slabp->s_mem + objnr*cachep->objsize);
+	BUG_ON(objp != slabp->s_mem + objnr * cachep->objsize);
 
 	if (cachep->flags & SLAB_DEBUG_INITIAL) {
-		/* Need to call the slab's constructor so the
+		/*
+		 * Need to call the slab's constructor so the
 		 * caller can perform a verify of its state (debugging).
 		 * Called without the cache-lock held.
 		 */
-		cachep->ctor(objp+obj_dbghead(cachep),
-					cachep, SLAB_CTOR_CONSTRUCTOR|SLAB_CTOR_VERIFY);
+		cachep->ctor(objp + obj_dbghead(cachep), cachep,
+			     SLAB_CTOR_CONSTRUCTOR|SLAB_CTOR_VERIFY);
 	}
 	if (cachep->flags & SLAB_POISON && cachep->dtor) {
-		/* we want to cache poison the object,
+		/*
+		 * we want to cache poison the object,
 		 * call the destruction callback
 		 */
-		cachep->dtor(objp+obj_dbghead(cachep), cachep, 0);
+		cachep->dtor(objp + obj_dbghead(cachep), cachep, 0);
 	}
 	if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
 		if ((cachep->objsize % PAGE_SIZE) == 0 && OFF_SLAB(cachep)) {
 			store_stackinfo(cachep, objp, (unsigned long)caller);
-	       		kernel_map_pages(virt_to_page(objp), cachep->objsize/PAGE_SIZE, 0);
+			kernel_map_pages(virt_to_page(objp),
+					 cachep->objsize / PAGE_SIZE, 0);
 		} else {
 			poison_obj(cachep, objp, POISON_FREE);
 		}
@@ -2338,10 +2363,13 @@ static void check_slabp(kmem_cache_t *ca
 	}
 	if (entries != cachep->num - slabp->inuse) {
 bad:
-		printk(KERN_ERR "slab: Internal list corruption detected in cache '%s'(%d), slabp %p(%d). Hexdump:\n",
-				cachep->name, cachep->num, slabp, slabp->inuse);
-		for (i=0;i<sizeof(slabp)+cachep->num*sizeof(kmem_bufctl_t);i++) {
-			if ((i%16)==0)
+		printk(KERN_ERR "slab: Internal list corruption detected in "
+		       "cache '%s'(%d), slabp %p(%d). Hexdump:\n",
+		       cachep->name, cachep->num, slabp, slabp->inuse);
+		for (i = 0;
+		     i < sizeof(slabp) + cachep->num * sizeof(kmem_bufctl_t);
+		     i++) {
+			if ((i % 16) == 0)
 				printk("\n%03x:", i);
 			printk(" %02x", ((unsigned char*)slabp)[i]);
 		}
@@ -2350,9 +2378,9 @@ bad:
 	}
 }
 #else
-#define kfree_debugcheck(x) do { } while(0)
-#define cache_free_debugcheck(x,objp,z) (objp)
-#define check_slabp(x,y) do { } while(0)
+#define kfree_debugcheck(x)			do { } while(0)
+#define cache_free_debugcheck(x,objp,z)		(objp)
+#define check_slabp(x,y)			do { } while(0)
 #endif
 
 static void *cache_alloc_refill(kmem_cache_t *cachep, gfp_t flags)
@@ -2366,7 +2394,8 @@ static void *cache_alloc_refill(kmem_cac
 retry:
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
-		/* if there was little recent activity on this
+		/*
+		 * if there was little recent activity on this
 		 * cache, then perform only a partial refill.
 		 * Otherwise we could generate refill bouncing.
 		 */
@@ -2385,8 +2414,8 @@ retry:
 			shared_array->avail -= batchcount;
 			ac->avail = batchcount;
 			memcpy(ac->entry,
-				&(shared_array->entry[shared_array->avail]),
-				sizeof(void*)*batchcount);
+			       &(shared_array->entry[shared_array->avail]),
+			       sizeof(void *) * batchcount);
 			shared_array->touched = 1;
 			goto alloc_done;
 		}
@@ -2420,9 +2449,9 @@ retry:
 			next = slab_bufctl(slabp)[slabp->free];
 #if DEBUG
 			slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-			WARN_ON(numa_node_id() != slabp->nodeid);
+			WARN_ON(numa_node_id() != slabp->nid);
 #endif
-		       	slabp->free = next;
+			slabp->free = next;
 		}
 		check_slabp(cachep, slabp);
 
@@ -2443,20 +2472,20 @@ alloc_done:
 		int x;
 		x = cache_grow(cachep, flags, numa_node_id());
 
-		// cache_grow can reenable interrupts, then ac could change.
+		/* cache_grow can reenable interrupts, then ac could change. */
 		ac = ac_data(cachep);
-		if (!x && ac->avail == 0)	// no objects in sight? abort
+		if (!x && ac->avail == 0) /* no objects in sight? abort      */
 			return NULL;
 
-		if (!ac->avail)		// objects refilled by interrupt?
+		if (!ac->avail)		  /* objects refilled by interrupt?  */
 			goto retry;
 	}
 	ac->touched = 1;
 	return ac->entry[--ac->avail];
 }
 
-static inline void
-cache_alloc_debugcheck_before(kmem_cache_t *cachep, gfp_t flags)
+static inline void cache_alloc_debugcheck_before(kmem_cache_t *cachep,
+						 gfp_t flags)
 {
 	might_sleep_if(flags & __GFP_WAIT);
 #if DEBUG
@@ -2465,16 +2494,16 @@ cache_alloc_debugcheck_before(kmem_cache
 }
 
 #if DEBUG
-static void *
-cache_alloc_debugcheck_after(kmem_cache_t *cachep,
-			gfp_t flags, void *objp, void *caller)
+static void *cache_alloc_debugcheck_after(kmem_cache_t *cachep, gfp_t flags,
+					  void *objp, void *caller)
 {
-	if (!objp)	
+	if (!objp)
 		return objp;
- 	if (cachep->flags & SLAB_POISON) {
+	if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
 		if ((cachep->objsize % PAGE_SIZE) == 0 && OFF_SLAB(cachep))
-			kernel_map_pages(virt_to_page(objp), cachep->objsize/PAGE_SIZE, 1);
+			kernel_map_pages(virt_to_page(objp),
+					 cachep->objsize / PAGE_SIZE, 1);
 		else
 			check_poison_obj(cachep, objp);
 #else
@@ -2486,24 +2515,27 @@ cache_alloc_debugcheck_after(kmem_cache_
 		*dbg_userword(cachep, objp) = caller;
 
 	if (cachep->flags & SLAB_RED_ZONE) {
-		if (*dbg_redzone1(cachep, objp) != RED_INACTIVE || *dbg_redzone2(cachep, objp) != RED_INACTIVE) {
-			slab_error(cachep, "double free, or memory outside"
-						" object was overwritten");
-			printk(KERN_ERR "%p: redzone 1: 0x%lx, redzone 2: 0x%lx.\n",
-					objp, *dbg_redzone1(cachep, objp), *dbg_redzone2(cachep, objp));
+		if (*dbg_redzone1(cachep, objp) != RED_INACTIVE ||
+		    *dbg_redzone2(cachep, objp) != RED_INACTIVE) {
+			slab_error(cachep, "double free, or memory outside "
+				   "object was overwritten");
+			printk(KERN_ERR "%p: redzone 1: 0x%lx, "
+			       "redzone 2: 0x%lx.\n", objp,
+			       *dbg_redzone1(cachep, objp),
+			       *dbg_redzone2(cachep, objp));
 		}
 		*dbg_redzone1(cachep, objp) = RED_ACTIVE;
 		*dbg_redzone2(cachep, objp) = RED_ACTIVE;
 	}
 	objp += obj_dbghead(cachep);
 	if (cachep->ctor && cachep->flags & SLAB_POISON) {
-		unsigned long	ctor_flags = SLAB_CTOR_CONSTRUCTOR;
+		unsigned long ctor_flags = SLAB_CTOR_CONSTRUCTOR;
 
 		if (!(flags & __GFP_WAIT))
 			ctor_flags |= SLAB_CTOR_ATOMIC;
 
 		cachep->ctor(objp, cachep, ctor_flags);
-	}	
+	}
 	return objp;
 }
 #else
@@ -2531,7 +2563,7 @@ static inline void *____cache_alloc(kmem
 static inline void *__cache_alloc(kmem_cache_t *cachep, gfp_t flags)
 {
 	unsigned long save_flags;
-	void* objp;
+	void *objp;
 
 	cache_alloc_debugcheck_before(cachep, flags);
 
@@ -2539,86 +2571,87 @@ static inline void *__cache_alloc(kmem_c
 	objp = ____cache_alloc(cachep, flags);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp,
-					__builtin_return_address(0));
+					    __builtin_return_address(0));
 	prefetchw(objp);
 	return objp;
 }
 
 #ifdef CONFIG_NUMA
 /*
- * A interface to enable slab creation on nodeid
+ * A interface to enable slab creation on nid
  */
-static void *__cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int nodeid)
+static void *__cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int nid)
 {
 	struct list_head *entry;
- 	struct slab *slabp;
- 	struct kmem_list3 *l3;
- 	void *obj;
- 	kmem_bufctl_t next;
- 	int x;
+	struct slab *slabp;
+	struct kmem_list3 *l3;
+	void *obj;
+	kmem_bufctl_t next;
+	int x;
 
- 	l3 = cachep->nodelists[nodeid];
- 	BUG_ON(!l3);
+	l3 = cachep->nodelists[nid];
+	BUG_ON(!l3);
 
 retry:
- 	spin_lock(&l3->list_lock);
- 	entry = l3->slabs_partial.next;
- 	if (entry == &l3->slabs_partial) {
- 		l3->free_touched = 1;
- 		entry = l3->slabs_free.next;
- 		if (entry == &l3->slabs_free)
- 			goto must_grow;
- 	}
-
- 	slabp = list_entry(entry, struct slab, list);
- 	check_spinlock_acquired_node(cachep, nodeid);
- 	check_slabp(cachep, slabp);
-
- 	STATS_INC_NODEALLOCS(cachep);
- 	STATS_INC_ACTIVE(cachep);
- 	STATS_SET_HIGH(cachep);
-
- 	BUG_ON(slabp->inuse == cachep->num);
-
- 	/* get obj pointer */
- 	obj =  slabp->s_mem + slabp->free*cachep->objsize;
- 	slabp->inuse++;
- 	next = slab_bufctl(slabp)[slabp->free];
-#if DEBUG
- 	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-#endif
- 	slabp->free = next;
- 	check_slabp(cachep, slabp);
- 	l3->free_objects--;
- 	/* move slabp to correct slabp list: */
- 	list_del(&slabp->list);
-
- 	if (slabp->free == BUFCTL_END) {
- 		list_add(&slabp->list, &l3->slabs_full);
- 	} else {
- 		list_add(&slabp->list, &l3->slabs_partial);
- 	}
+	spin_lock(&l3->list_lock);
+	entry = l3->slabs_partial.next;
+	if (entry == &l3->slabs_partial) {
+		l3->free_touched = 1;
+		entry = l3->slabs_free.next;
+		if (entry == &l3->slabs_free)
+			goto must_grow;
+	}
+
+	slabp = list_entry(entry, struct slab, list);
+	check_spinlock_acquired_node(cachep, nid);
+	check_slabp(cachep, slabp);
+
+	STATS_INC_NODEALLOCS(cachep);
+	STATS_INC_ACTIVE(cachep);
+	STATS_SET_HIGH(cachep);
+
+	BUG_ON(slabp->inuse == cachep->num);
+
+	/* get obj pointer */
+	obj =  slabp->s_mem + slabp->free * cachep->objsize;
+	slabp->inuse++;
+	next = slab_bufctl(slabp)[slabp->free];
+#if DEBUG
+	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
+#endif
+	slabp->free = next;
+	check_slabp(cachep, slabp);
+	l3->free_objects--;
+	/* move slabp to correct slabp list: */
+	list_del(&slabp->list);
+
+	if (slabp->free == BUFCTL_END) {
+		list_add(&slabp->list, &l3->slabs_full);
+	} else {
+		list_add(&slabp->list, &l3->slabs_partial);
+	}
 
- 	spin_unlock(&l3->list_lock);
- 	goto done;
+	spin_unlock(&l3->list_lock);
+	goto done;
 
 must_grow:
- 	spin_unlock(&l3->list_lock);
- 	x = cache_grow(cachep, flags, nodeid);
+	spin_unlock(&l3->list_lock);
+	x = cache_grow(cachep, flags, nid);
 
- 	if (!x)
- 		return NULL;
+	if (!x)
+		return NULL;
 
- 	goto retry;
+	goto retry;
 done:
- 	return obj;
+	return obj;
 }
 #endif
 
 /*
  * Caller needs to acquire correct kmem_list's list_lock
  */
-static void free_block(kmem_cache_t *cachep, void **objpp, int nr_objects, int node)
+static void free_block(kmem_cache_t *cachep, void **objpp, int nr_objects,
+		       int nid)
 {
 	int i;
 	struct kmem_list3 *l3;
@@ -2629,15 +2662,15 @@ static void free_block(kmem_cache_t *cac
 		unsigned int objnr;
 
 		slabp = GET_PAGE_SLAB(virt_to_page(objp));
-		l3 = cachep->nodelists[node];
+		l3 = cachep->nodelists[nid];
 		list_del(&slabp->list);
 		objnr = (objp - slabp->s_mem) / cachep->objsize;
-		check_spinlock_acquired_node(cachep, node);
+		check_spinlock_acquired_node(cachep, nid);
 		check_slabp(cachep, slabp);
 
 #if DEBUG
 		/* Verify that the slab belongs to the intended node */
-		WARN_ON(slabp->nodeid != node);
+		WARN_ON(slabp->nid != nid);
 
 		if (slab_bufctl(slabp)[objnr] != BUFCTL_FREE) {
 			printk(KERN_ERR "slab: double free detected in cache "
@@ -2661,7 +2694,8 @@ static void free_block(kmem_cache_t *cac
 				list_add(&slabp->list, &l3->slabs_free);
 			}
 		} else {
-			/* Unconditionally move a slab to the end of the
+			/*
+			 * Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
 			 * other objects to be freed, too.
 			 */
@@ -2674,30 +2708,29 @@ static void cache_flusharray(kmem_cache_
 {
 	int batchcount;
 	struct kmem_list3 *l3;
-	int node = numa_node_id();
+	int nid = numa_node_id();
 
 	batchcount = ac->batchcount;
 #if DEBUG
 	BUG_ON(!batchcount || batchcount > ac->avail);
 #endif
 	check_irq_off();
-	l3 = cachep->nodelists[node];
+	l3 = cachep->nodelists[nid];
 	spin_lock(&l3->list_lock);
 	if (l3->shared) {
 		struct array_cache *shared_array = l3->shared;
-		int max = shared_array->limit-shared_array->avail;
+		int max = shared_array->limit - shared_array->avail;
 		if (max) {
 			if (batchcount > max)
 				batchcount = max;
 			memcpy(&(shared_array->entry[shared_array->avail]),
-					ac->entry,
-					sizeof(void*)*batchcount);
+			       ac->entry, sizeof(void *) * batchcount);
 			shared_array->avail += batchcount;
 			goto free_done;
 		}
 	}
 
-	free_block(cachep, ac->entry, batchcount, node);
+	free_block(cachep, ac->entry, batchcount, nid);
 free_done:
 #if STATS
 	{
@@ -2720,11 +2753,11 @@ free_done:
 	spin_unlock(&l3->list_lock);
 	ac->avail -= batchcount;
 	memmove(ac->entry, &(ac->entry[batchcount]),
-			sizeof(void*)*ac->avail);
+		sizeof(void *) * ac->avail);
 }
 
 
-/*
+/**
  * __cache_free
  * Release an obj back to its cache. If the obj has a constructed
  * state, it must be in this state _before_ it is released.
@@ -2738,33 +2771,32 @@ static inline void __cache_free(kmem_cac
 	check_irq_off();
 	objp = cache_free_debugcheck(cachep, objp, __builtin_return_address(0));
 
-	/* Make sure we are not freeing a object from another
+	/*
+	 * Make sure we are not freeing a object from another
 	 * node to the array cache on this cpu.
 	 */
 #ifdef CONFIG_NUMA
 	{
 		struct slab *slabp;
 		slabp = GET_PAGE_SLAB(virt_to_page(objp));
-		if (unlikely(slabp->nodeid != numa_node_id())) {
+		if (unlikely(slabp->nid != numa_node_id())) {
 			struct array_cache *alien = NULL;
-			int nodeid = slabp->nodeid;
-			struct kmem_list3 *l3 = cachep->nodelists[numa_node_id()];
+			int nid = slabp->nid;
+			struct kmem_list3 *l3 =
+				cachep->nodelists[numa_node_id()];
 
 			STATS_INC_NODEFREES(cachep);
-			if (l3->alien && l3->alien[nodeid]) {
-				alien = l3->alien[nodeid];
+			if (l3->alien && l3->alien[nid]) {
+				alien = l3->alien[nid];
 				spin_lock(&alien->lock);
 				if (unlikely(alien->avail == alien->limit))
-					__drain_alien_cache(cachep,
-							alien, nodeid);
+					__drain_alien_cache(cachep, alien, nid);
 				alien->entry[alien->avail++] = objp;
 				spin_unlock(&alien->lock);
 			} else {
-				spin_lock(&(cachep->nodelists[nodeid])->
-						list_lock);
-				free_block(cachep, &objp, 1, nodeid);
-				spin_unlock(&(cachep->nodelists[nodeid])->
-						list_lock);
+				spin_lock(&(cachep->nodelists[nid])->list_lock);
+				free_block(cachep, &objp, 1, nid);
+				spin_unlock(&(cachep->nodelists[nid])->list_lock);
 			}
 			return;
 		}
@@ -2796,8 +2828,7 @@ void *kmem_cache_alloc(kmem_cache_t *cac
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 /**
- * kmem_ptr_validate - check if an untrusted pointer might
- *	be a slab entry.
+ * kmem_ptr_validate - check if an untrusted pointer might be a slab entry.
  * @cachep: the cache we're checking against
  * @ptr: pointer to validate
  *
@@ -2811,7 +2842,7 @@ EXPORT_SYMBOL(kmem_cache_alloc);
  */
 int fastcall kmem_ptr_validate(kmem_cache_t *cachep, void *ptr)
 {
-	unsigned long addr = (unsigned long) ptr;
+	unsigned long addr = (unsigned long)ptr;
 	unsigned long min_addr = PAGE_OFFSET;
 	unsigned long align_mask = BYTES_PER_WORD-1;
 	unsigned long size = cachep->objsize;
@@ -2842,7 +2873,7 @@ out:
  * kmem_cache_alloc_node - Allocate an object on the specified node
  * @cachep: The cache to allocate from.
  * @flags: See kmalloc().
- * @nodeid: node number of the target node.
+ * @nid: node number of the target node.
  *
  * Identical to kmem_cache_alloc, except that this function is slow
  * and can sleep. And it will allocate memory on the given node, which
@@ -2850,41 +2881,43 @@ out:
  * New and improved: it will now make sure that the object gets
  * put on the correct node list so that there is no false sharing.
  */
-void *kmem_cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int nodeid)
+void *kmem_cache_alloc_node(kmem_cache_t *cachep, gfp_t flags, int nid)
 {
 	unsigned long save_flags;
 	void *ptr;
 
-	if (nodeid == -1)
+	if (nid == -1)
 		return __cache_alloc(cachep, flags);
 
-	if (unlikely(!cachep->nodelists[nodeid])) {
+	if (unlikely(!cachep->nodelists[nid])) {
 		/* Fall back to __cache_alloc if we run into trouble */
-		printk(KERN_WARNING "slab: not allocating in inactive node %d for cache %s\n", nodeid, cachep->name);
+		printk(KERN_WARNING "slab: not allocating in inactive node %d "
+		       "for cache %s\n", nid, cachep->name);
 		return __cache_alloc(cachep,flags);
 	}
 
 	cache_alloc_debugcheck_before(cachep, flags);
 	local_irq_save(save_flags);
-	if (nodeid == numa_node_id())
+	if (nid == numa_node_id())
 		ptr = ____cache_alloc(cachep, flags);
 	else
-		ptr = __cache_alloc_node(cachep, flags, nodeid);
+		ptr = __cache_alloc_node(cachep, flags, nid);
 	local_irq_restore(save_flags);
-	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, __builtin_return_address(0));
+	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr,
+					   __builtin_return_address(0));
 
 	return ptr;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
-void *kmalloc_node(size_t size, gfp_t flags, int node)
+void *kmalloc_node(size_t size, gfp_t flags, int nid)
 {
 	kmem_cache_t *cachep;
 
 	cachep = kmem_find_general_cachep(size, flags);
 	if (unlikely(cachep == NULL))
 		return NULL;
-	return kmem_cache_alloc_node(cachep, flags, node);
+	return kmem_cache_alloc_node(cachep, flags, nid);
 }
 EXPORT_SYMBOL(kmalloc_node);
 #endif
@@ -2914,10 +2947,9 @@ void *__kmalloc(size_t size, gfp_t flags
 {
 	kmem_cache_t *cachep;
 
-	/* If you want to save a few bytes .text space: replace
-	 * __ with kmem_.
-	 * Then kmalloc uses the uninlined functions instead of the inline
-	 * functions.
+	/*
+	 * If you want to save a few bytes .text space: replace __ with kmem_
+	 * Then kmalloc uses the uninlined functions vs. the inline functions
 	 */
 	cachep = __find_general_cachep(size, flags);
 	if (unlikely(cachep == NULL))
@@ -2933,12 +2965,11 @@ EXPORT_SYMBOL(__kmalloc);
  * Objects should be dereferenced using the per_cpu_ptr macro only.
  *
  * @size: how many bytes of memory are required.
- * @align: the alignment, which can't be greater than SMP_CACHE_BYTES.
  */
-void *__alloc_percpu(size_t size, size_t align)
+void *__alloc_percpu(size_t size)
 {
 	int i;
-	struct percpu_data *pdata = kmalloc(sizeof (*pdata), GFP_KERNEL);
+	struct percpu_data *pdata = kzalloc(sizeof(*pdata), GFP_KERNEL);
 
 	if (!pdata)
 		return NULL;
@@ -2949,10 +2980,10 @@ void *__alloc_percpu(size_t size, size_t
 	 * that we have allocated then....
 	 */
 	for_each_cpu(i) {
-		int node = cpu_to_node(i);
+		int nid = cpu_to_node(i);
 
-		if (node_online(node))
-			pdata->ptrs[i] = kmalloc_node(size, GFP_KERNEL, node);
+		if (node_online(nid))
+			pdata->ptrs[i] = kmalloc_node(size, GFP_KERNEL, nid);
 		else
 			pdata->ptrs[i] = kmalloc(size, GFP_KERNEL);
 
@@ -2962,14 +2993,11 @@ void *__alloc_percpu(size_t size, size_t
 	}
 
 	/* Catch derefs w/o wrappers */
-	return (void *) (~(unsigned long) pdata);
+	return (void *)(~(unsigned long) pdata);
 
 unwind_oom:
-	while (--i >= 0) {
-		if (!cpu_possible(i))
-			continue;
+	while (--i >= 0)
 		kfree(pdata->ptrs[i]);
-	}
 	kfree(pdata);
 	return NULL;
 }
@@ -3027,7 +3055,7 @@ void kfree(const void *objp)
 	local_irq_save(flags);
 	kfree_debugcheck(objp);
 	c = GET_PAGE_CACHE(virt_to_page(objp));
-	__cache_free(c, (void*)objp);
+	__cache_free(c, (void *)objp);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(kfree);
@@ -3040,11 +3068,10 @@ EXPORT_SYMBOL(kfree);
  * Don't free memory not originally allocated by alloc_percpu()
  * The complemented objp is to check for that.
  */
-void
-free_percpu(const void *objp)
+void free_percpu(const void *objp)
 {
 	int i;
-	struct percpu_data *p = (struct percpu_data *) (~(unsigned long) objp);
+	struct percpu_data *p = (struct percpu_data *)(~(unsigned long)objp);
 
 	/*
 	 * We allocate for all cpus so we cannot use for online cpu here.
@@ -3073,52 +3100,50 @@ EXPORT_SYMBOL_GPL(kmem_cache_name);
  */
 static int alloc_kmemlist(kmem_cache_t *cachep)
 {
-	int node;
+	int nid;
 	struct kmem_list3 *l3;
 	int err = 0;
 
-	for_each_online_node(node) {
+	for_each_online_node(nid) {
 		struct array_cache *nc = NULL, *new;
 		struct array_cache **new_alien = NULL;
 #ifdef CONFIG_NUMA
-		if (!(new_alien = alloc_alien_cache(node, cachep->limit)))
+		if (!(new_alien = alloc_alien_cache(nid, cachep->limit)))
 			goto fail;
 #endif
-		if (!(new = alloc_arraycache(node, (cachep->shared*
-				cachep->batchcount), 0xbaadf00d)))
+		if (!(new = alloc_arraycache(nid, cachep->shared *
+					     cachep->batchcount, 0xbaadf00d)))
 			goto fail;
-		if ((l3 = cachep->nodelists[node])) {
-
+		if ((l3 = cachep->nodelists[nid])) {
 			spin_lock_irq(&l3->list_lock);
 
-			if ((nc = cachep->nodelists[node]->shared))
-				free_block(cachep, nc->entry,
-							nc->avail, node);
+			if ((nc = cachep->nodelists[nid]->shared))
+				free_block(cachep, nc->entry, nc->avail, nid);
 
 			l3->shared = new;
-			if (!cachep->nodelists[node]->alien) {
+			if (!cachep->nodelists[nid]->alien) {
 				l3->alien = new_alien;
 				new_alien = NULL;
 			}
-			l3->free_limit = (1 + nr_cpus_node(node))*
-				cachep->batchcount + cachep->num;
+			l3->free_limit = cachep->num +
+				(1 + nr_cpus_node(nid)) * cachep->batchcount;
 			spin_unlock_irq(&l3->list_lock);
 			kfree(nc);
 			free_alien_cache(new_alien);
 			continue;
 		}
 		if (!(l3 = kmalloc_node(sizeof(struct kmem_list3),
-						GFP_KERNEL, node)))
+					GFP_KERNEL, nid)))
 			goto fail;
 
 		kmem_list3_init(l3);
 		l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
-			((unsigned long)cachep)%REAPTIMEOUT_LIST3;
+			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
 		l3->shared = new;
 		l3->alien = new_alien;
-		l3->free_limit = (1 + nr_cpus_node(node))*
-			cachep->batchcount + cachep->num;
-		cachep->nodelists[node] = l3;
+		l3->free_limit = cachep->num +
+			(1 + nr_cpus_node(nid)) * cachep->batchcount;
+		cachep->nodelists[nid] = l3;
 	}
 	return err;
 fail:
@@ -3145,16 +3170,18 @@ static void do_ccupdate_local(void *info
 
 
 static int do_tune_cpucache(kmem_cache_t *cachep, int limit, int batchcount,
-				int shared)
+			    int shared)
 {
 	struct ccupdate_struct new;
 	int i, err;
 
-	memset(&new.new,0,sizeof(new.new));
+	memset(&new.new, 0, sizeof(new.new));
 	for_each_online_cpu(i) {
-		new.new[i] = alloc_arraycache(cpu_to_node(i), limit, batchcount);
+		new.new[i] = alloc_arraycache(cpu_to_node(i), limit,
+					      batchcount);
 		if (!new.new[i]) {
-			for (i--; i >= 0; i--) kfree(new.new[i]);
+			for (i--; i >= 0; i--)
+				kfree(new.new[i]);
 			return -ENOMEM;
 		}
 	}
@@ -3182,7 +3209,7 @@ static int do_tune_cpucache(kmem_cache_t
 	err = alloc_kmemlist(cachep);
 	if (err) {
 		printk(KERN_ERR "alloc_kmemlist failed for %s, error %d.\n",
-				cachep->name, -err);
+		       cachep->name, -err);
 		BUG();
 	}
 	return 0;
@@ -3194,10 +3221,11 @@ static void enable_cpucache(kmem_cache_t
 	int err;
 	int limit, shared;
 
-	/* The head array serves three purposes:
+	/*
+	 * The head array serves three purposes:
 	 * - create a LIFO ordering, i.e. return objects that are cache-warm
 	 * - reduce the number of spinlock operations.
-	 * - reduce the number of linked list operations on the slab and 
+	 * - reduce the number of linked list operations on the slab and
 	 *   bufctl chains: array operations are cheaper.
 	 * The numbers are guessed, we should auto-tune as described by
 	 * Bonwick.
@@ -3213,7 +3241,8 @@ static void enable_cpucache(kmem_cache_t
 	else
 		limit = 120;
 
-	/* Cpu bound tasks (e.g. network routing) can exhibit cpu bound
+	/*
+	 * Cpu bound tasks (e.g. network routing) can exhibit cpu bound
 	 * allocation behaviour: Most allocs on one cpu, most free operations
 	 * on another cpu. For these cases, an efficient object passing between
 	 * cpus is necessary. This is provided by a shared array. The array
@@ -3228,36 +3257,37 @@ static void enable_cpucache(kmem_cache_t
 #endif
 
 #if DEBUG
-	/* With debugging enabled, large batchcount lead to excessively
-	 * long periods with disabled local interrupts. Limit the 
+	/*
+	 * With debugging enabled, large batchcount lead to excessively
+	 * long periods with disabled local interrupts. Limit the
 	 * batchcount
 	 */
 	if (limit > 32)
 		limit = 32;
 #endif
-	err = do_tune_cpucache(cachep, limit, (limit+1)/2, shared);
+	err = do_tune_cpucache(cachep, limit, (limit + 1) / 2, shared);
 	if (err)
 		printk(KERN_ERR "enable_cpucache failed for %s, error %d.\n",
-					cachep->name, -err);
+		       cachep->name, -err);
 }
 
-static void drain_array_locked(kmem_cache_t *cachep,
-				struct array_cache *ac, int force, int node)
+static void drain_array_locked(kmem_cache_t *cachep, struct array_cache *ac,
+			       int force, int nid)
 {
 	int tofree;
 
-	check_spinlock_acquired_node(cachep, node);
+	check_spinlock_acquired_node(cachep, nid);
 	if (ac->touched && !force) {
 		ac->touched = 0;
 	} else if (ac->avail) {
-		tofree = force ? ac->avail : (ac->limit+4)/5;
+		tofree = force ? ac->avail : (ac->limit + 4) / 5;
 		if (tofree > ac->avail) {
-			tofree = (ac->avail+1)/2;
+			tofree = (ac->avail + 1) / 2;
 		}
-		free_block(cachep, ac->entry, tofree, node);
+		free_block(cachep, ac->entry, tofree, nid);
 		ac->avail -= tofree;
 		memmove(ac->entry, &(ac->entry[tofree]),
-					sizeof(void*)*ac->avail);
+			sizeof(void *) * ac->avail);
 	}
 }
 
@@ -3275,53 +3305,44 @@ static void drain_array_locked(kmem_cach
  */
 static void cache_reap(void *unused)
 {
-	struct list_head *walk;
-	struct kmem_list3 *l3;
-
-	if (down_trylock(&cache_chain_sem)) {
-		/* Give up. Setup the next iteration. */
-		schedule_delayed_work(&__get_cpu_var(reap_work), REAPTIMEOUT_CPUC);
-		return;
-	}
+	kmem_cache_t *searchp;
 
-	list_for_each(walk, &cache_chain) {
-		kmem_cache_t *searchp;
-		struct list_head* p;
-		int tofree;
-		struct slab *slabp;
+	if (down_trylock(&cache_chain_sem))
+		goto out;
 
-		searchp = list_entry(walk, kmem_cache_t, next);
+	list_for_each_entry(searchp, &cache_chain, next) {
+		struct kmem_list3 *l3;
+		int tofree, nid = numa_node_id();
 
 		if (searchp->flags & SLAB_NO_REAP)
 			goto next;
 
 		check_irq_on();
-
-		l3 = searchp->nodelists[numa_node_id()];
+		l3 = searchp->nodelists[nid];
 		if (l3->alien)
 			drain_alien_cache(searchp, l3);
 		spin_lock_irq(&l3->list_lock);
 
-		drain_array_locked(searchp, ac_data(searchp), 0,
-				numa_node_id());
+		drain_array_locked(searchp, ac_data(searchp), 0, nid);
 
 		if (time_after(l3->next_reap, jiffies))
 			goto next_unlock;
-
 		l3->next_reap = jiffies + REAPTIMEOUT_LIST3;
 
 		if (l3->shared)
-			drain_array_locked(searchp, l3->shared, 0,
-				numa_node_id());
+			drain_array_locked(searchp, l3->shared, 0, nid);
 
 		if (l3->free_touched) {
 			l3->free_touched = 0;
 			goto next_unlock;
 		}
 
-		tofree = (l3->free_limit+5*searchp->num-1)/(5*searchp->num);
+		tofree = 5 * searchp->num;
+		tofree = (l3->free_limit + tofree - 1) / tofree;
 		do {
-			p = l3->slabs_free.next;
+			struct list_head *p = l3->slabs_free.next;
+			struct slab *slabp;
+
 			if (p == &(l3->slabs_free))
 				break;
 
@@ -3330,10 +3351,10 @@ static void cache_reap(void *unused)
 			list_del(&slabp->list);
 			STATS_INC_REAPED(searchp);
 
-			/* Safe to drop the lock. The slab is no longer
-			 * linked to the cache.
-			 * searchp cannot disappear, we hold
-			 * cache_chain_lock
+			/*
+			 * Safe to drop the lock:
+			 * The slab is no longer linked to the cache
+			 * searchp cannot disappear, we hold cache_chain_lock
 			 */
 			l3->free_objects -= searchp->num;
 			spin_unlock_irq(&l3->list_lock);
@@ -3348,38 +3369,44 @@ next:
 	check_irq_on();
 	up(&cache_chain_sem);
 	drain_remote_pages();
+out:
 	/* Setup the next iteration */
 	schedule_delayed_work(&__get_cpu_var(reap_work), REAPTIMEOUT_CPUC);
 }
 
 #ifdef CONFIG_PROC_FS
 
-static void *s_start(struct seq_file *m, loff_t *pos)
+static inline void print_slabinfo_header(struct seq_file *m)
 {
-	loff_t n = *pos;
-	struct list_head *p;
-
-	down(&cache_chain_sem);
-	if (!n) {
-		/*
-		 * Output format version, so at least we can change it
-		 * without _too_ many complaints.
-		 */
+	/*
+	 * Output format version, so at least we can change it
+	 * without _too_ many complaints.
+	 */
 #if STATS
-		seq_puts(m, "slabinfo - version: 2.1 (statistics)\n");
+	seq_puts(m, "slabinfo - version: 2.1 (statistics)\n");
 #else
-		seq_puts(m, "slabinfo - version: 2.1\n");
+	seq_puts(m, "slabinfo - version: 2.1\n");
 #endif
-		seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
-		seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
-		seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
+	seq_puts(m, "# name            <active_objs> <num_objs> <objsize> "
+		 "<objperslab> <pagesperslab>");
+	seq_puts(m, " : tunables <limit> <batchcount> <sharedfactor>");
+	seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
 #if STATS
-		seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped>"
-				" <error> <maxfreeable> <nodeallocs> <remotefrees>");
-		seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
+	seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> "
+		 "<error> <maxfreeable> <nodeallocs> <remotefrees>");
+	seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
 #endif
-		seq_putc(m, '\n');
-	}
+	seq_putc(m, '\n');
+}
+
+static void *s_start(struct seq_file *m, loff_t *pos)
+{
+	loff_t n = *pos;
+	struct list_head *p;
+
+	down(&cache_chain_sem);
+	if (!n)
+		print_slabinfo_header(m);
 	p = cache_chain.next;
 	while (n--) {
 		p = p->next;
@@ -3393,8 +3420,8 @@ static void *s_next(struct seq_file *m, 
 {
 	kmem_cache_t *cachep = p;
 	++*pos;
-	return cachep->next.next == &cache_chain ? NULL
-		: list_entry(cachep->next.next, kmem_cache_t, next);
+	return cachep->next.next == &cache_chain ? NULL :
+		list_entry(cachep->next.next, kmem_cache_t, next);
 }
 
 static void s_stop(struct seq_file *m, void *p)
@@ -3406,22 +3433,20 @@ static int s_show(struct seq_file *m, vo
 {
 	kmem_cache_t *cachep = p;
 	struct list_head *q;
-	struct slab	*slabp;
-	unsigned long	active_objs;
-	unsigned long	num_objs;
-	unsigned long	active_slabs = 0;
-	unsigned long	num_slabs, free_objects = 0, shared_avail = 0;
+	struct slab *slabp;
+	unsigned long active_objs, num_objs, active_slabs = 0;
+	unsigned long num_slabs, free_objects = 0, shared_avail = 0;
 	const char *name;
 	char *error = NULL;
-	int node;
+	int nid;
 	struct kmem_list3 *l3;
 
 	check_irq_on();
 	spin_lock_irq(&cachep->spinlock);
 	active_objs = 0;
 	num_slabs = 0;
-	for_each_online_node(node) {
-		l3 = cachep->nodelists[node];
+	for_each_online_node(nid) {
+		l3 = cachep->nodelists[nid];
 		if (!l3)
 			continue;
 
@@ -3437,7 +3462,7 @@ static int s_show(struct seq_file *m, vo
 		list_for_each(q,&l3->slabs_partial) {
 			slabp = list_entry(q, struct slab, list);
 			if (slabp->inuse == cachep->num && !error)
-				error = "slabs_partial inuse accounting error";
+				error = "slabs_partial/inuse accounting error";
 			if (!slabp->inuse && !error)
 				error = "slabs_partial/inuse accounting error";
 			active_objs += slabp->inuse;
@@ -3454,23 +3479,23 @@ static int s_show(struct seq_file *m, vo
 
 		spin_unlock(&l3->list_lock);
 	}
-	num_slabs+=active_slabs;
-	num_objs = num_slabs*cachep->num;
+	num_slabs += active_slabs;
+	num_objs = num_slabs * cachep->num;
 	if (num_objs - active_objs != free_objects && !error)
 		error = "free_objects accounting error";
 
-	name = cachep->name; 
+	name = cachep->name;
 	if (error)
 		printk(KERN_ERR "slab: cache %s error: %s\n", name, error);
 
-	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d",
-		name, active_objs, num_objs, cachep->objsize,
-		cachep->num, (1<<cachep->gfporder));
+	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", name, active_objs,
+		   num_objs, cachep->objsize, cachep->num,
+		   (1 << cachep->gfporder));
 	seq_printf(m, " : tunables %4u %4u %4u",
-			cachep->limit, cachep->batchcount,
-			cachep->shared);
+		   cachep->limit, cachep->batchcount,
+		   cachep->shared);
 	seq_printf(m, " : slabdata %6lu %6lu %6lu",
-			active_slabs, num_slabs, shared_avail);
+		   active_slabs, num_slabs, shared_avail);
 #if STATS
 	{	/* list3 stats */
 		unsigned long high = cachep->high_mark;
@@ -3483,9 +3508,9 @@ static int s_show(struct seq_file *m, vo
 		unsigned long node_frees = cachep->node_frees;
 
 		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu \
-				%4lu %4lu %4lu %4lu",
-				allocs, high, grown, reaped, errors,
-				max_freeable, node_allocs, node_frees);
+				%4lu %4lu %4lu %4lu", allocs, high, grown,
+			   reaped, errors, max_freeable, node_allocs,
+			   node_frees);
 	}
 	/* cpu stats */
 	{
@@ -3495,7 +3520,7 @@ static int s_show(struct seq_file *m, vo
 		unsigned long freemiss = atomic_read(&cachep->freemiss);
 
 		seq_printf(m, " : cpustat %6lu %6lu %6lu %6lu",
-			allochit, allocmiss, freehit, freemiss);
+			   allochit, allocmiss, freehit, freemiss);
 	}
 #endif
 	seq_putc(m, '\n');
@@ -3516,7 +3541,6 @@ static int s_show(struct seq_file *m, vo
  * num-pages-per-slab
  * + further values on SMP and with statistics enabled
  */
-
 struct seq_operations slabinfo_op = {
 	.start	= s_start,
 	.next	= s_next,
@@ -3533,17 +3557,17 @@ struct seq_operations slabinfo_op = {
  * @ppos: unused
  */
 ssize_t slabinfo_write(struct file *file, const char __user *buffer,
-				size_t count, loff_t *ppos)
+		       size_t count, loff_t *ppos)
 {
 	char kbuf[MAX_SLABINFO_WRITE+1], *tmp;
 	int limit, batchcount, shared, res;
 	struct list_head *p;
-	
+
 	if (count > MAX_SLABINFO_WRITE)
 		return -EINVAL;
 	if (copy_from_user(&kbuf, buffer, count))
 		return -EFAULT;
-	kbuf[MAX_SLABINFO_WRITE] = '\0'; 
+	kbuf[MAX_SLABINFO_WRITE] = '\0';
 
 	tmp = strchr(kbuf, ' ');
 	if (!tmp)
@@ -3552,32 +3576,26 @@ ssize_t slabinfo_write(struct file *file
 	tmp++;
 	if (sscanf(tmp, " %d %d %d", &limit, &batchcount, &shared) != 3)
 		return -EINVAL;
+	if (limit < 1 || batchcount < 1 || batchcount > limit || shared < 0)
+		return 0;
 
 	/* Find the cache in the chain of caches. */
 	down(&cache_chain_sem);
 	res = -EINVAL;
 	list_for_each(p,&cache_chain) {
 		kmem_cache_t *cachep = list_entry(p, kmem_cache_t, next);
+		if (strcmp(cachep->name, kbuf))
+			continue;
 
-		if (!strcmp(cachep->name, kbuf)) {
-			if (limit < 1 ||
-			    batchcount < 1 ||
-			    batchcount > limit ||
-			    shared < 0) {
-				res = 0;
-			} else {
-				res = do_tune_cpucache(cachep, limit,
-							batchcount, shared);
-			}
-			break;
-		}
+		res = do_tune_cpucache(cachep, limit, batchcount, shared);
+		if (res >= 0)
+			res = count;	
+		break;
 	}
 	up(&cache_chain_sem);
-	if (res >= 0)
-		res = count;
 	return res;
 }
-#endif
+#endif /* CONFIG_PROC_FS */
 
 /**
  * ksize - get the actual amount of memory allocated for a given object
@@ -3600,7 +3618,7 @@ unsigned int ksize(const void *objp)
 }
 
 
-/*
+/**
  * kstrdup - allocate space for and copy an existing string
  *
  * @s: the string to duplicate
Index: linux-2.6.15-rc1+slab_cleanup/net/ipv6/af_inet6.c
===================================================================
--- linux-2.6.15-rc1+slab_cleanup.orig/net/ipv6/af_inet6.c	2005-11-15 15:21:47.659921992 -0800
+++ linux-2.6.15-rc1+slab_cleanup/net/ipv6/af_inet6.c	2005-11-15 15:23:47.707671960 -0800
@@ -596,11 +596,11 @@ snmp6_mib_init(void *ptr[2], size_t mibs
 	if (ptr == NULL)
 		return -EINVAL;
 
-	ptr[0] = __alloc_percpu(mibsize, mibalign);
+	ptr[0] = __alloc_percpu(mibsize);
 	if (!ptr[0])
 		goto err0;
 
-	ptr[1] = __alloc_percpu(mibsize, mibalign);
+	ptr[1] = __alloc_percpu(mibsize);
 	if (!ptr[1])
 		goto err1;
 

--------------070001090005060600060604--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
