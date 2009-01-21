Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F37B36B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 11:56:06 -0500 (EST)
Date: Wed, 21 Jan 2009 17:56:00 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090121165600.GA16695@wotan.suse.de>
References: <20090121143008.GV24891@wotan.suse.de> <20090121145918.GA11311@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121145918.GA11311@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 21, 2009 at 03:59:18PM +0100, Ingo Molnar wrote:
> 
> Mind if i nitpick a bit about minor style issues? Since this is going to 
> be the next Linux SLAB allocator we might as well do it perfectly :-)

Well here is an incremental patch which should get most of the issues you
pointed out, most of the sane ones that checkpatch pointed out, and a
few of my own ;)

---
 include/linux/slqb_def.h |   90 +++++-----
 mm/slqb.c                |  386 +++++++++++++++++++++++++----------------------
 2 files changed, 261 insertions(+), 215 deletions(-)

Index: linux-2.6/include/linux/slqb_def.h
===================================================================
--- linux-2.6.orig/include/linux/slqb_def.h
+++ linux-2.6/include/linux/slqb_def.h
@@ -37,8 +37,9 @@ enum stat_item {
  * Singly-linked list with head, tail, and nr
  */
 struct kmlist {
-	unsigned long nr;
-	void **head, **tail;
+	unsigned long	nr;
+	void 		**head;
+	void		**tail;
 };
 
 /*
@@ -46,8 +47,8 @@ struct kmlist {
  * objects can be returned to the kmem_cache_list from remote CPUs.
  */
 struct kmem_cache_remote_free {
-	spinlock_t lock;
-	struct kmlist list;
+	spinlock_t	lock;
+	struct kmlist	list;
 } ____cacheline_aligned;
 
 /*
@@ -56,18 +57,23 @@ struct kmem_cache_remote_free {
  * kmem_cache_lists allow off-node allocations (but require locking).
  */
 struct kmem_cache_list {
-	struct kmlist freelist;	/* Fastpath LIFO freelist of objects */
+				/* Fastpath LIFO freelist of objects */
+	struct kmlist		freelist;
 #ifdef CONFIG_SMP
-	int remote_free_check;	/* remote_free has reached a watermark */
+				/* remote_free has reached a watermark */
+	int			remote_free_check;
 #endif
-	struct kmem_cache *cache; /* kmem_cache corresponding to this list */
+				/* kmem_cache corresponding to this list */
+	struct kmem_cache	*cache;
 
-	unsigned long nr_partial; /* Number of partial slabs (pages) */
-	struct list_head partial; /* Slabs which have some free objects */
+				/* Number of partial slabs (pages) */
+	unsigned long		nr_partial;
 
-	unsigned long nr_slabs;	/* Total number of slabs allocated */
+				/* Slabs which have some free objects */
+	struct list_head	partial;
 
-	//struct list_head full;
+				/* Total number of slabs allocated */
+	unsigned long		nr_slabs;
 
 #ifdef CONFIG_SMP
 	/*
@@ -79,7 +85,7 @@ struct kmem_cache_list {
 #endif
 
 #ifdef CONFIG_SLQB_STATS
-	unsigned long stats[NR_SLQB_STAT_ITEMS];
+	unsigned long		stats[NR_SLQB_STAT_ITEMS];
 #endif
 } ____cacheline_aligned;
 
@@ -87,9 +93,8 @@ struct kmem_cache_list {
  * Primary per-cpu, per-kmem_cache structure.
  */
 struct kmem_cache_cpu {
-	struct kmem_cache_list list; /* List for node-local slabs. */
-
-	unsigned int colour_next;
+	struct kmem_cache_list	list;		/* List for node-local slabs */
+	unsigned int		colour_next;	/* Next colour offset to use */
 
 #ifdef CONFIG_SMP
 	/*
@@ -101,53 +106,53 @@ struct kmem_cache_cpu {
 	 * An NR_CPUS or MAX_NUMNODES array would be nice here, but then we
 	 * get to O(NR_CPUS^2) memory consumption situation.
 	 */
-	struct kmlist rlist;
-	struct kmem_cache_list *remote_cache_list;
+	struct kmlist		rlist;
+	struct kmem_cache_list	*remote_cache_list;
 #endif
 } ____cacheline_aligned;
 
 /*
- * Per-node, per-kmem_cache structure.
+ * Per-node, per-kmem_cache structure. Used for node-specific allocations.
  */
 struct kmem_cache_node {
-	struct kmem_cache_list list;
-	spinlock_t list_lock; /* protects access to list */
+	struct kmem_cache_list	list;
+	spinlock_t		list_lock;	/* protects access to list */
 } ____cacheline_aligned;
 
 /*
  * Management object for a slab cache.
  */
 struct kmem_cache {
-	unsigned long flags;
-	int hiwater;		/* LIFO list high watermark */
-	int freebatch;		/* LIFO freelist batch flush size */
-	int objsize;		/* The size of an object without meta data */
-	int offset;		/* Free pointer offset. */
-	int objects;		/* Number of objects in slab */
-
-	int size;		/* The size of an object including meta data */
-	int order;		/* Allocation order */
-	gfp_t allocflags;	/* gfp flags to use on allocation */
-	unsigned int colour_range;	/* range of colour counter */
-	unsigned int colour_off;		/* offset per colour */
-	void (*ctor)(void *);
+	unsigned long	flags;
+	int		hiwater;	/* LIFO list high watermark */
+	int		freebatch;	/* LIFO freelist batch flush size */
+	int		objsize;	/* Size of object without meta data */
+	int		offset;		/* Free pointer offset. */
+	int		objects;	/* Number of objects in slab */
+
+	int		size;		/* Size of object including meta data */
+	int		order;		/* Allocation order */
+	gfp_t		allocflags;	/* gfp flags to use on allocation */
+	unsigned int	colour_range;	/* range of colour counter */
+	unsigned int	colour_off;	/* offset per colour */
+	void		(*ctor)(void *);
 
-	const char *name;	/* Name (only for display!) */
-	struct list_head list;	/* List of slab caches */
+	const char	*name;		/* Name (only for display!) */
+	struct list_head list;		/* List of slab caches */
 
-	int align;		/* Alignment */
-	int inuse;		/* Offset to metadata */
+	int		align;		/* Alignment */
+	int		inuse;		/* Offset to metadata */
 
 #ifdef CONFIG_SLQB_SYSFS
-	struct kobject kobj;	/* For sysfs */
+	struct kobject	kobj;		/* For sysfs */
 #endif
 #ifdef CONFIG_NUMA
-	struct kmem_cache_node *node[MAX_NUMNODES];
+	struct kmem_cache_node	*node[MAX_NUMNODES];
 #endif
 #ifdef CONFIG_SMP
-	struct kmem_cache_cpu *cpu_slab[NR_CPUS];
+	struct kmem_cache_cpu	*cpu_slab[NR_CPUS];
 #else
-	struct kmem_cache_cpu cpu_slab;
+	struct kmem_cache_cpu	cpu_slab;
 #endif
 };
 
@@ -245,7 +250,8 @@ void *__kmalloc(size_t size, gfp_t flags
 #define ARCH_SLAB_MINALIGN __alignof__(unsigned long long)
 #endif
 
-#define KMALLOC_HEADER (ARCH_KMALLOC_MINALIGN < sizeof(void *) ? sizeof(void *) : ARCH_KMALLOC_MINALIGN)
+#define KMALLOC_HEADER (ARCH_KMALLOC_MINALIGN < sizeof(void *) ?	\
+				sizeof(void *) : ARCH_KMALLOC_MINALIGN)
 
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c
+++ linux-2.6/mm/slqb.c
@@ -40,13 +40,13 @@
 struct slqb_page {
 	union {
 		struct {
-			unsigned long flags;	/* mandatory */
-			atomic_t _count;	/* mandatory */
-			unsigned int inuse;	/* Nr of objects */
-		   	struct kmem_cache_list *list; /* Pointer to list */
-			void **freelist;	/* freelist req. slab lock */
+			unsigned long	flags;		/* mandatory */
+			atomic_t	_count;		/* mandatory */
+			unsigned int	inuse;		/* Nr of objects */
+			struct kmem_cache_list *list;	/* Pointer to list */
+			void		 **freelist;	/* LIFO freelist */
 			union {
-				struct list_head lru; /* misc. list */
+				struct list_head lru;	/* misc. list */
 				struct rcu_head rcu_head; /* for rcu freeing */
 			};
 		};
@@ -62,7 +62,7 @@ static int kmem_size __read_mostly;
 #ifdef CONFIG_NUMA
 static int numa_platform __read_mostly;
 #else
-#define numa_platform 0
+static const int numa_platform = 0;
 #endif
 
 static inline int slab_hiwater(struct kmem_cache *s)
@@ -120,15 +120,16 @@ static inline int slab_freebatch(struct
  * - There is no remote free queue. Nodes don't free objects, CPUs do.
  */
 
-static inline void slqb_stat_inc(struct kmem_cache_list *list, enum stat_item si)
+static inline void slqb_stat_inc(struct kmem_cache_list *list,
+				enum stat_item si)
 {
 #ifdef CONFIG_SLQB_STATS
 	list->stats[si]++;
 #endif
 }
 
-static inline void slqb_stat_add(struct kmem_cache_list *list, enum stat_item si,
-					unsigned long nr)
+static inline void slqb_stat_add(struct kmem_cache_list *list,
+				enum stat_item si, unsigned long nr)
 {
 #ifdef CONFIG_SLQB_STATS
 	list->stats[si] += nr;
@@ -433,10 +434,11 @@ static void print_page_info(struct slqb_
 
 }
 
+#define MAX_ERR_STR 100
 static void slab_bug(struct kmem_cache *s, char *fmt, ...)
 {
 	va_list args;
-	char buf[100];
+	char buf[MAX_ERR_STR];
 
 	va_start(args, fmt);
 	vsnprintf(buf, sizeof(buf), fmt, args);
@@ -477,8 +479,7 @@ static void print_trailer(struct kmem_ca
 	print_section("Object", p, min(s->objsize, 128));
 
 	if (s->flags & SLAB_RED_ZONE)
-		print_section("Redzone", p + s->objsize,
-			s->inuse - s->objsize);
+		print_section("Redzone", p + s->objsize, s->inuse - s->objsize);
 
 	if (s->offset)
 		off = s->offset + sizeof(void *);
@@ -488,9 +489,10 @@ static void print_trailer(struct kmem_ca
 	if (s->flags & SLAB_STORE_USER)
 		off += 2 * sizeof(struct track);
 
-	if (off != s->size)
+	if (off != s->size) {
 		/* Beginning of the filler is the free pointer */
 		print_section("Padding", p + off, s->size - off);
+	}
 
 	dump_stack();
 }
@@ -502,14 +504,9 @@ static void object_err(struct kmem_cache
 	print_trailer(s, page, object);
 }
 
-static void slab_err(struct kmem_cache *s, struct slqb_page *page, char *fmt, ...)
+static void slab_err(struct kmem_cache *s, struct slqb_page *page,
+			char *fmt, ...)
 {
-	va_list args;
-	char buf[100];
-
-	va_start(args, fmt);
-	vsnprintf(buf, sizeof(buf), fmt, args);
-	va_end(args);
 	slab_bug(s, fmt);
 	print_page_info(page);
 	dump_stack();
@@ -524,10 +521,11 @@ static void init_object(struct kmem_cach
 		p[s->objsize - 1] = POISON_END;
 	}
 
-	if (s->flags & SLAB_RED_ZONE)
+	if (s->flags & SLAB_RED_ZONE) {
 		memset(p + s->objsize,
 			active ? SLUB_RED_ACTIVE : SLUB_RED_INACTIVE,
 			s->inuse - s->objsize);
+	}
 }
 
 static u8 *check_bytes(u8 *start, unsigned int value, unsigned int bytes)
@@ -542,7 +540,7 @@ static u8 *check_bytes(u8 *start, unsign
 }
 
 static void restore_bytes(struct kmem_cache *s, char *message, u8 data,
-						void *from, void *to)
+				void *from, void *to)
 {
 	slab_fix(s, "Restoring 0x%p-0x%p=0x%x\n", from, to - 1, data);
 	memset(from, data, to - from);
@@ -610,13 +608,15 @@ static int check_pad_bytes(struct kmem_c
 {
 	unsigned long off = s->inuse;	/* The end of info */
 
-	if (s->offset)
+	if (s->offset) {
 		/* Freepointer is placed after the object. */
 		off += sizeof(void *);
+	}
 
-	if (s->flags & SLAB_STORE_USER)
+	if (s->flags & SLAB_STORE_USER) {
 		/* We also have user information there */
 		off += 2 * sizeof(struct track);
+	}
 
 	if (s->size == off)
 		return 1;
@@ -646,6 +646,7 @@ static int slab_pad_check(struct kmem_ca
 	fault = check_bytes(start + length, POISON_INUSE, remainder);
 	if (!fault)
 		return 1;
+
 	while (end > fault && end[-1] == POISON_INUSE)
 		end--;
 
@@ -677,12 +678,16 @@ static int check_object(struct kmem_cach
 	}
 
 	if (s->flags & SLAB_POISON) {
-		if (!active && (s->flags & __OBJECT_POISON) &&
-			(!check_bytes_and_report(s, page, p, "Poison", p,
-					POISON_FREE, s->objsize - 1) ||
-			 !check_bytes_and_report(s, page, p, "Poison",
-				p + s->objsize - 1, POISON_END, 1)))
-			return 0;
+		if (!active && (s->flags & __OBJECT_POISON)) {
+			if (!check_bytes_and_report(s, page, p, "Poison", p,
+					POISON_FREE, s->objsize - 1))
+				return 0;
+
+			if (!check_bytes_and_report(s, page, p, "Poison",
+					p + s->objsize - 1, POISON_END, 1))
+				return 0;
+		}
+
 		/*
 		 * check_pad_bytes cleans up on its own.
 		 */
@@ -712,7 +717,8 @@ static int check_slab(struct kmem_cache
 	return 1;
 }
 
-static void trace(struct kmem_cache *s, struct slqb_page *page, void *object, int alloc)
+static void trace(struct kmem_cache *s, struct slqb_page *page,
+			void *object, int alloc)
 {
 	if (s->flags & SLAB_TRACE) {
 		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
@@ -729,7 +735,7 @@ static void trace(struct kmem_cache *s,
 }
 
 static void setup_object_debug(struct kmem_cache *s, struct slqb_page *page,
-								void *object)
+				void *object)
 {
 	if (!slab_debug(s))
 		return;
@@ -741,7 +747,8 @@ static void setup_object_debug(struct km
 	init_tracking(s, object);
 }
 
-static int alloc_debug_processing(struct kmem_cache *s, void *object, void *addr)
+static int alloc_debug_processing(struct kmem_cache *s,
+					void *object, void *addr)
 {
 	struct slqb_page *page;
 	page = virt_to_head_slqb_page(object);
@@ -768,7 +775,8 @@ bad:
 	return 0;
 }
 
-static int free_debug_processing(struct kmem_cache *s, void *object, void *addr)
+static int free_debug_processing(struct kmem_cache *s,
+					void *object, void *addr)
 {
 	struct slqb_page *page;
 	page = virt_to_head_slqb_page(object);
@@ -799,25 +807,28 @@ fail:
 static int __init setup_slqb_debug(char *str)
 {
 	slqb_debug = DEBUG_DEFAULT_FLAGS;
-	if (*str++ != '=' || !*str)
+	if (*str++ != '=' || !*str) {
 		/*
 		 * No options specified. Switch on full debugging.
 		 */
 		goto out;
+	}
 
-	if (*str == ',')
+	if (*str == ',') {
 		/*
 		 * No options but restriction on slabs. This means full
 		 * debugging for slabs matching a pattern.
 		 */
 		goto check_slabs;
+	}
 
 	slqb_debug = 0;
-	if (*str == '-')
+	if (*str == '-') {
 		/*
 		 * Switch off all debugging measures.
 		 */
 		goto out;
+	}
 
 	/*
 	 * Determine which debug features should be switched on
@@ -855,8 +866,8 @@ out:
 __setup("slqb_debug", setup_slqb_debug);
 
 static unsigned long kmem_cache_flags(unsigned long objsize,
-	unsigned long flags, const char *name,
-	void (*ctor)(void *))
+				unsigned long flags, const char *name,
+				void (*ctor)(void *))
 {
 	/*
 	 * Enable debugging if selected on the kernel commandline.
@@ -870,31 +881,51 @@ static unsigned long kmem_cache_flags(un
 }
 #else
 static inline void setup_object_debug(struct kmem_cache *s,
-			struct slqb_page *page, void *object) {}
+			struct slqb_page *page, void *object)
+{
+}
 
 static inline int alloc_debug_processing(struct kmem_cache *s,
-	void *object, void *addr) { return 0; }
+			void *object, void *addr)
+{
+	return 0;
+}
 
 static inline int free_debug_processing(struct kmem_cache *s,
-	void *object, void *addr) { return 0; }
+			void *object, void *addr)
+{
+	return 0;
+}
 
 static inline int slab_pad_check(struct kmem_cache *s, struct slqb_page *page)
-			{ return 1; }
+{
+	return 1;
+}
+
 static inline int check_object(struct kmem_cache *s, struct slqb_page *page,
-			void *object, int active) { return 1; }
-static inline void add_full(struct kmem_cache_node *n, struct slqb_page *page) {}
+			void *object, int active)
+{
+	return 1;
+}
+
+static inline void add_full(struct kmem_cache_node *n, struct slqb_page *page)
+{
+}
+
 static inline unsigned long kmem_cache_flags(unsigned long objsize,
 	unsigned long flags, const char *name, void (*ctor)(void *))
 {
 	return flags;
 }
-#define slqb_debug 0
+
+static const int slqb_debug = 0;
 #endif
 
 /*
  * allocate a new slab (return its corresponding struct slqb_page)
  */
-static struct slqb_page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct slqb_page *allocate_slab(struct kmem_cache *s,
+					gfp_t flags, int node)
 {
 	struct slqb_page *page;
 	int pages = 1 << s->order;
@@ -916,8 +947,8 @@ static struct slqb_page *allocate_slab(s
 /*
  * Called once for each object on a new slab page
  */
-static void setup_object(struct kmem_cache *s, struct slqb_page *page,
-				void *object)
+static void setup_object(struct kmem_cache *s,
+				struct slqb_page *page, void *object)
 {
 	setup_object_debug(s, page, object);
 	if (unlikely(s->ctor))
@@ -927,7 +958,8 @@ static void setup_object(struct kmem_cac
 /*
  * Allocate a new slab, set up its object list.
  */
-static struct slqb_page *new_slab_page(struct kmem_cache *s, gfp_t flags, int node, unsigned int colour)
+static struct slqb_page *new_slab_page(struct kmem_cache *s,
+				gfp_t flags, int node, unsigned int colour)
 {
 	struct slqb_page *page;
 	void *start;
@@ -1010,7 +1042,9 @@ static void free_slab(struct kmem_cache
  * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
  * list_lock in the case of per-node list.
  */
-static int free_object_to_page(struct kmem_cache *s, struct kmem_cache_list *l, struct slqb_page *page, void *object)
+static int free_object_to_page(struct kmem_cache *s,
+			struct kmem_cache_list *l, struct slqb_page *page,
+			void *object)
 {
 	VM_BUG_ON(page->list != l);
 
@@ -1027,6 +1061,7 @@ static int free_object_to_page(struct km
 		free_slab(s, page);
 		slqb_stat_inc(l, FLUSH_SLAB_FREE);
 		return 1;
+
 	} else if (page->inuse + 1 == s->objects) {
 		l->nr_partial++;
 		list_add(&page->lru, &l->partial);
@@ -1037,7 +1072,8 @@ static int free_object_to_page(struct km
 }
 
 #ifdef CONFIG_SMP
-static noinline void slab_free_to_remote(struct kmem_cache *s, struct slqb_page *page, void *object, struct kmem_cache_cpu *c);
+static void slab_free_to_remote(struct kmem_cache *s, struct slqb_page *page,
+				void *object, struct kmem_cache_cpu *c);
 #endif
 
 /*
@@ -1110,7 +1146,8 @@ static void flush_free_list_all(struct k
  * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
  * list_lock in the case of per-node list.
  */
-static void claim_remote_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
+static void claim_remote_free_list(struct kmem_cache *s,
+					struct kmem_cache_list *l)
 {
 	void **head, **tail;
 	int nr;
@@ -1126,11 +1163,13 @@ static void claim_remote_free_list(struc
 	prefetchw(head);
 
 	spin_lock(&l->remote_free.lock);
+
 	l->remote_free.list.head = NULL;
 	tail = l->remote_free.list.tail;
 	l->remote_free.list.tail = NULL;
 	nr = l->remote_free.list.nr;
 	l->remote_free.list.nr = 0;
+
 	spin_unlock(&l->remote_free.lock);
 
 	if (!l->freelist.nr)
@@ -1153,18 +1192,19 @@ static void claim_remote_free_list(struc
  * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
  * list_lock in the case of per-node list.
  */
-static __always_inline void *__cache_list_get_object(struct kmem_cache *s, struct kmem_cache_list *l)
+static __always_inline void *__cache_list_get_object(struct kmem_cache *s,
+						struct kmem_cache_list *l)
 {
 	void *object;
 
 	object = l->freelist.head;
 	if (likely(object)) {
 		void *next = get_freepointer(s, object);
+
 		VM_BUG_ON(!l->freelist.nr);
 		l->freelist.nr--;
 		l->freelist.head = next;
-//		if (next)
-//			prefetchw(next);
+
 		return object;
 	}
 	VM_BUG_ON(l->freelist.nr);
@@ -1180,11 +1220,11 @@ static __always_inline void *__cache_lis
 		object = l->freelist.head;
 		if (likely(object)) {
 			void *next = get_freepointer(s, object);
+
 			VM_BUG_ON(!l->freelist.nr);
 			l->freelist.nr--;
 			l->freelist.head = next;
-//			if (next)
-//				prefetchw(next);
+
 			return object;
 		}
 		VM_BUG_ON(l->freelist.nr);
@@ -1203,7 +1243,8 @@ static __always_inline void *__cache_lis
  * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
  * list_lock in the case of per-node list.
  */
-static noinline void *__cache_list_get_page(struct kmem_cache *s, struct kmem_cache_list *l)
+static noinline void *__cache_list_get_page(struct kmem_cache *s,
+				struct kmem_cache_list *l)
 {
 	struct slqb_page *page;
 	void *object;
@@ -1216,15 +1257,12 @@ static noinline void *__cache_list_get_p
 	if (page->inuse + 1 == s->objects) {
 		l->nr_partial--;
 		list_del(&page->lru);
-/*XXX		list_move(&page->lru, &l->full); */
 	}
 
 	VM_BUG_ON(!page->freelist);
 
 	page->inuse++;
 
-//	VM_BUG_ON(node != -1 && node != slqb_page_to_nid(page));
-
 	object = page->freelist;
 	page->freelist = get_freepointer(s, object);
 	if (page->freelist)
@@ -1244,7 +1282,8 @@ static noinline void *__cache_list_get_p
  *
  * Must be called with interrupts disabled.
  */
-static noinline void *__slab_alloc_page(struct kmem_cache *s, gfp_t gfpflags, int node)
+static noinline void *__slab_alloc_page(struct kmem_cache *s,
+				gfp_t gfpflags, int node)
 {
 	struct slqb_page *page;
 	struct kmem_cache_list *l;
@@ -1285,8 +1324,8 @@ static noinline void *__slab_alloc_page(
 		slqb_stat_inc(l, ALLOC);
 		slqb_stat_inc(l, ALLOC_SLAB_NEW);
 		object = __cache_list_get_page(s, l);
-#ifdef CONFIG_NUMA
 	} else {
+#ifdef CONFIG_NUMA
 		struct kmem_cache_node *n;
 
 		n = s->node[slqb_page_to_nid(page)];
@@ -1308,7 +1347,8 @@ static noinline void *__slab_alloc_page(
 }
 
 #ifdef CONFIG_NUMA
-static noinline int alternate_nid(struct kmem_cache *s, gfp_t gfpflags, int node)
+static noinline int alternate_nid(struct kmem_cache *s,
+				gfp_t gfpflags, int node)
 {
 	if (in_interrupt() || (gfpflags & __GFP_THISNODE))
 		return node;
@@ -1326,7 +1366,7 @@ static noinline int alternate_nid(struct
  * Must be called with interrupts disabled.
  */
 static noinline void *__remote_slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node)
+				gfp_t gfpflags, int node)
 {
 	struct kmem_cache_node *n;
 	struct kmem_cache_list *l;
@@ -1337,9 +1377,6 @@ static noinline void *__remote_slab_allo
 		return NULL;
 	l = &n->list;
 
-//	if (unlikely(!(l->freelist.nr | l->nr_partial | l->remote_free_check)))
-//		return NULL;
-
 	spin_lock(&n->list_lock);
 
 	object = __cache_list_get_object(s, l);
@@ -1363,7 +1400,7 @@ static noinline void *__remote_slab_allo
  * Must be called with interrupts disabled.
  */
 static __always_inline void *__slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node)
+				gfp_t gfpflags, int node)
 {
 	void *object;
 	struct kmem_cache_cpu *c;
@@ -1393,7 +1430,7 @@ static __always_inline void *__slab_allo
  * (debug checking and memset()ing).
  */
 static __always_inline void *slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node, void *addr)
+				gfp_t gfpflags, int node, void *addr)
 {
 	void *object;
 	unsigned long flags;
@@ -1414,7 +1451,8 @@ again:
 	return object;
 }
 
-static __always_inline void *__kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags, void *caller)
+static __always_inline void *__kmem_cache_alloc(struct kmem_cache *s,
+				gfp_t gfpflags, void *caller)
 {
 	int node = -1;
 #ifdef CONFIG_NUMA
@@ -1449,7 +1487,8 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
  *
  * Must be called with interrupts disabled.
  */
-static void flush_remote_free_cache(struct kmem_cache *s, struct kmem_cache_cpu *c)
+static void flush_remote_free_cache(struct kmem_cache *s,
+				struct kmem_cache_cpu *c)
 {
 	struct kmlist *src;
 	struct kmem_cache_list *dst;
@@ -1464,6 +1503,7 @@ static void flush_remote_free_cache(stru
 #ifdef CONFIG_SLQB_STATS
 	{
 		struct kmem_cache_list *l = &c->list;
+
 		slqb_stat_inc(l, FLUSH_RFREE_LIST);
 		slqb_stat_add(l, FLUSH_RFREE_LIST_OBJECTS, nr);
 	}
@@ -1472,6 +1512,7 @@ static void flush_remote_free_cache(stru
 	dst = c->remote_cache_list;
 
 	spin_lock(&dst->remote_free.lock);
+
 	if (!dst->remote_free.list.head)
 		dst->remote_free.list.head = src->head;
 	else
@@ -1500,7 +1541,9 @@ static void flush_remote_free_cache(stru
  *
  * Must be called with interrupts disabled.
  */
-static noinline void slab_free_to_remote(struct kmem_cache *s, struct slqb_page *page, void *object, struct kmem_cache_cpu *c)
+static noinline void slab_free_to_remote(struct kmem_cache *s,
+				struct slqb_page *page, void *object,
+				struct kmem_cache_cpu *c)
 {
 	struct kmlist *r;
 
@@ -1526,14 +1569,14 @@ static noinline void slab_free_to_remote
 		flush_remote_free_cache(s, c);
 }
 #endif
- 
+
 /*
  * Main freeing path. Return an object, or NULL on allocation failure.
  *
  * Must be called with interrupts disabled.
  */
 static __always_inline void __slab_free(struct kmem_cache *s,
-		struct slqb_page *page, void *object)
+				struct slqb_page *page, void *object)
 {
 	struct kmem_cache_cpu *c;
 	struct kmem_cache_list *l;
@@ -1561,8 +1604,8 @@ static __always_inline void __slab_free(
 		if (unlikely(l->freelist.nr > slab_hiwater(s)))
 			flush_free_list(s, l);
 
-#ifdef CONFIG_NUMA
 	} else {
+#ifdef CONFIG_NUMA
 		/*
 		 * Freeing an object that was allocated on a remote node.
 		 */
@@ -1577,7 +1620,7 @@ static __always_inline void __slab_free(
  * (debug checking).
  */
 static __always_inline void slab_free(struct kmem_cache *s,
-		struct slqb_page *page, void *object)
+				struct slqb_page *page, void *object)
 {
 	unsigned long flags;
 
@@ -1597,6 +1640,7 @@ static __always_inline void slab_free(st
 void kmem_cache_free(struct kmem_cache *s, void *object)
 {
 	struct slqb_page *page = NULL;
+
 	if (numa_platform)
 		page = virt_to_head_slqb_page(object);
 	slab_free(s, page, object);
@@ -1610,7 +1654,7 @@ EXPORT_SYMBOL(kmem_cache_free);
  * in the page allocator, and they have fastpaths in the page allocator. But
  * also minimise external fragmentation with large objects.
  */
-static inline int slab_order(int size, int max_order, int frac)
+static int slab_order(int size, int max_order, int frac)
 {
 	int order;
 
@@ -1618,6 +1662,7 @@ static inline int slab_order(int size, i
 		order = 0;
 	else
 		order = fls(size - 1) - PAGE_SHIFT;
+
 	while (order <= max_order) {
 		unsigned long slab_size = PAGE_SIZE << order;
 		unsigned long objects;
@@ -1638,7 +1683,7 @@ static inline int slab_order(int size, i
 	return order;
 }
 
-static inline int calculate_order(int size)
+static int calculate_order(int size)
 {
 	int order;
 
@@ -1666,7 +1711,7 @@ static inline int calculate_order(int si
  * Figure out what the alignment of the objects will be.
  */
 static unsigned long calculate_alignment(unsigned long flags,
-		unsigned long align, unsigned long size)
+				unsigned long align, unsigned long size)
 {
 	/*
 	 * If the user wants hardware cache aligned objects then follow that
@@ -1677,6 +1722,7 @@ static unsigned long calculate_alignment
 	 */
 	if (flags & SLAB_HWCACHE_ALIGN) {
 		unsigned long ralign = cache_line_size();
+
 		while (size <= ralign / 2)
 			ralign /= 2;
 		align = max(align, ralign);
@@ -1688,21 +1734,21 @@ static unsigned long calculate_alignment
 	return ALIGN(align, sizeof(void *));
 }
 
-static void init_kmem_cache_list(struct kmem_cache *s, struct kmem_cache_list *l)
+static void init_kmem_cache_list(struct kmem_cache *s,
+				struct kmem_cache_list *l)
 {
-	l->cache = s;
-	l->freelist.nr = 0;
-	l->freelist.head = NULL;
-	l->freelist.tail = NULL;
-	l->nr_partial = 0;
-	l->nr_slabs = 0;
+	l->cache		= s;
+	l->freelist.nr		= 0;
+	l->freelist.head	= NULL;
+	l->freelist.tail	= NULL;
+	l->nr_partial		= 0;
+	l->nr_slabs		= 0;
 	INIT_LIST_HEAD(&l->partial);
-//	INIT_LIST_HEAD(&l->full);
 
 #ifdef CONFIG_SMP
-	l->remote_free_check = 0;
+	l->remote_free_check	= 0;
 	spin_lock_init(&l->remote_free.lock);
-	l->remote_free.list.nr = 0;
+	l->remote_free.list.nr	= 0;
 	l->remote_free.list.head = NULL;
 	l->remote_free.list.tail = NULL;
 #endif
@@ -1713,21 +1759,22 @@ static void init_kmem_cache_list(struct
 }
 
 static void init_kmem_cache_cpu(struct kmem_cache *s,
-			struct kmem_cache_cpu *c)
+				struct kmem_cache_cpu *c)
 {
 	init_kmem_cache_list(s, &c->list);
 
-	c->colour_next = 0;
+	c->colour_next		= 0;
 #ifdef CONFIG_SMP
-	c->rlist.nr = 0;
-	c->rlist.head = NULL;
-	c->rlist.tail = NULL;
-	c->remote_cache_list = NULL;
+	c->rlist.nr		= 0;
+	c->rlist.head		= NULL;
+	c->rlist.tail		= NULL;
+	c->remote_cache_list	= NULL;
 #endif
 }
 
 #ifdef CONFIG_NUMA
-static void init_kmem_cache_node(struct kmem_cache *s, struct kmem_cache_node *n)
+static void init_kmem_cache_node(struct kmem_cache *s,
+				struct kmem_cache_node *n)
 {
 	spin_lock_init(&n->list_lock);
 	init_kmem_cache_list(s, &n->list);
@@ -1757,7 +1804,8 @@ static struct kmem_cache_node kmem_node_
 #endif
 
 #ifdef CONFIG_SMP
-static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s, int cpu)
+static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s,
+				int cpu)
 {
 	struct kmem_cache_cpu *c;
 
@@ -1918,14 +1966,15 @@ static int calculate_sizes(struct kmem_c
 	}
 
 #ifdef CONFIG_SLQB_DEBUG
-	if (flags & SLAB_STORE_USER)
+	if (flags & SLAB_STORE_USER) {
 		/*
 		 * Need to store information about allocs and frees after
 		 * the object.
 		 */
 		size += 2 * sizeof(struct track);
+	}
 
-	if (flags & SLAB_RED_ZONE)
+	if (flags & SLAB_RED_ZONE) {
 		/*
 		 * Add some empty padding so that we can catch
 		 * overwrites from earlier objects rather than let
@@ -1934,6 +1983,7 @@ static int calculate_sizes(struct kmem_c
 		 * of the object.
 		 */
 		size += sizeof(void *);
+	}
 #endif
 
 	/*
@@ -1970,7 +2020,8 @@ static int calculate_sizes(struct kmem_c
 	 */
 	s->objects = (PAGE_SIZE << s->order) / size;
 
-	s->freebatch = max(4UL*PAGE_SIZE / size, min(256UL, 64*PAGE_SIZE / size));
+	s->freebatch = max(4UL*PAGE_SIZE / size,
+				min(256UL, 64*PAGE_SIZE / size));
 	if (!s->freebatch)
 		s->freebatch = 1;
 	s->hiwater = s->freebatch << 2;
@@ -1980,9 +2031,8 @@ static int calculate_sizes(struct kmem_c
 }
 
 static int kmem_cache_open(struct kmem_cache *s,
-		const char *name, size_t size,
-		size_t align, unsigned long flags,
-		void (*ctor)(void *), int alloc)
+			const char *name, size_t size, size_t align,
+			unsigned long flags, void (*ctor)(void *), int alloc)
 {
 	unsigned int left_over;
 
@@ -2024,7 +2074,7 @@ error_nodes:
 	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
-		panic("kmem_cache_create(): failed to create slab `%s'\n",name);
+		panic("kmem_cache_create(): failed to create slab `%s'\n", name);
 	return 0;
 }
 
@@ -2141,7 +2191,7 @@ EXPORT_SYMBOL(kmalloc_caches_dma);
 #endif
 
 static struct kmem_cache *open_kmalloc_cache(struct kmem_cache *s,
-		const char *name, int size, gfp_t gfp_flags)
+				const char *name, int size, gfp_t gfp_flags)
 {
 	unsigned int flags = ARCH_KMALLOC_FLAGS | SLAB_PANIC;
 
@@ -2446,10 +2496,10 @@ static int __init cpucache_init(void)
 
 	for_each_online_cpu(cpu)
 		start_cpu_timer(cpu);
+
 	return 0;
 }
-__initcall(cpucache_init);
-
+device_initcall(cpucache_init);
 
 #if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
 static void slab_mem_going_offline_callback(void *arg)
@@ -2459,29 +2509,7 @@ static void slab_mem_going_offline_callb
 
 static void slab_mem_offline_callback(void *arg)
 {
-	struct kmem_cache *s;
-	struct memory_notify *marg = arg;
-	int nid = marg->status_change_nid;
-
-	/*
-	 * If the node still has available memory. we need kmem_cache_node
-	 * for it yet.
-	 */
-	if (nid < 0)
-		return;
-
-#if 0 // XXX: see cpu offline comment
-	down_read(&slqb_lock);
-	list_for_each_entry(s, &slab_caches, list) {
-		struct kmem_cache_node *n;
-		n = s->node[nid];
-		if (n) {
-			s->node[nid] = NULL;
-			kmem_cache_free(&kmem_node_cache, n);
-		}
-	}
-	up_read(&slqb_lock);
-#endif
+	/* XXX: should release structures, see CPU offline comment */
 }
 
 static int slab_mem_going_online_callback(void *arg)
@@ -2562,6 +2590,10 @@ void __init kmem_cache_init(void)
 	int i;
 	unsigned int flags = SLAB_HWCACHE_ALIGN|SLAB_PANIC;
 
+	/*
+	 * All the ifdefs are rather ugly here, but it's just the setup code,
+	 * so it doesn't have to be too readable :)
+	 */
 #ifdef CONFIG_NUMA
 	if (num_possible_nodes() == 1)
 		numa_platform = 0;
@@ -2576,12 +2608,15 @@ void __init kmem_cache_init(void)
 	kmem_size = sizeof(struct kmem_cache);
 #endif
 
-	kmem_cache_open(&kmem_cache_cache, "kmem_cache", kmem_size, 0, flags, NULL, 0);
+	kmem_cache_open(&kmem_cache_cache, "kmem_cache",
+			kmem_size, 0, flags, NULL, 0);
 #ifdef CONFIG_SMP
-	kmem_cache_open(&kmem_cpu_cache, "kmem_cache_cpu", sizeof(struct kmem_cache_cpu), 0, flags, NULL, 0);
+	kmem_cache_open(&kmem_cpu_cache, "kmem_cache_cpu",
+			sizeof(struct kmem_cache_cpu), 0, flags, NULL, 0);
 #endif
 #ifdef CONFIG_NUMA
-	kmem_cache_open(&kmem_node_cache, "kmem_cache_node", sizeof(struct kmem_cache_node), 0, flags, NULL, 0);
+	kmem_cache_open(&kmem_node_cache, "kmem_cache_node",
+			sizeof(struct kmem_cache_node), 0, flags, NULL, 0);
 #endif
 
 #ifdef CONFIG_SMP
@@ -2634,14 +2669,13 @@ void __init kmem_cache_init(void)
 
 	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_SLQB_HIGH; i++) {
 		open_kmalloc_cache(&kmalloc_caches[i],
-			"kmalloc", 1 << i, GFP_KERNEL);
+				"kmalloc", 1 << i, GFP_KERNEL);
 #ifdef CONFIG_ZONE_DMA
 		open_kmalloc_cache(&kmalloc_caches_dma[i],
 				"kmalloc_dma", 1 << i, GFP_KERNEL|SLQB_DMA);
 #endif
 	}
 
-
 	/*
 	 * Patch up the size_index table if we have strange large alignment
 	 * requirements for the kmalloc array. This is only the case for
@@ -2697,10 +2731,12 @@ static int kmem_cache_create_ok(const ch
 		printk(KERN_ERR "kmem_cache_create(): early error in slab %s\n",
 				name);
 		dump_stack();
+
 		return 0;
 	}
 
 	down_read(&slqb_lock);
+
 	list_for_each_entry(tmp, &slab_caches, list) {
 		char x;
 		int res;
@@ -2723,9 +2759,11 @@ static int kmem_cache_create_ok(const ch
 			       "kmem_cache_create(): duplicate cache %s\n", name);
 			dump_stack();
 			up_read(&slqb_lock);
+
 			return 0;
 		}
 	}
+
 	up_read(&slqb_lock);
 
 	WARN_ON(strchr(name, ' '));	/* It confuses parsers */
@@ -2754,7 +2792,8 @@ struct kmem_cache *kmem_cache_create(con
 
 err:
 	if (flags & SLAB_PANIC)
-		panic("kmem_cache_create(): failed to create slab `%s'\n",name);
+		panic("kmem_cache_create(): failed to create slab `%s'\n", name);
+
 	return NULL;
 }
 EXPORT_SYMBOL(kmem_cache_create);
@@ -2765,7 +2804,7 @@ EXPORT_SYMBOL(kmem_cache_create);
  * necessary.
  */
 static int __cpuinit slab_cpuup_callback(struct notifier_block *nfb,
-		unsigned long action, void *hcpu)
+				unsigned long action, void *hcpu)
 {
 	long cpu = (long)hcpu;
 	struct kmem_cache *s;
@@ -2803,23 +2842,12 @@ static int __cpuinit slab_cpuup_callback
 	case CPU_UP_CANCELED_FROZEN:
 	case CPU_DEAD:
 	case CPU_DEAD_FROZEN:
-#if 0
-		down_read(&slqb_lock);
-		/* XXX: this doesn't work because objects can still be on this
-		 * CPU's list. periodic timer needs to check if a CPU is offline
-		 * and then try to cleanup from there. Same for node offline.
+		/*
+		 * XXX: Freeing here doesn't work because objects can still be
+		 * on this CPU's list. periodic timer needs to check if a CPU
+		 * is offline and then try to cleanup from there. Same for node
+		 * offline.
 		 */
-		list_for_each_entry(s, &slab_caches, list) {
-			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
-			if (c) {
-				kmem_cache_free(&kmem_cpu_cache, c);
-				s->cpu_slab[cpu] = NULL;
-			}
-		}
-
-		up_read(&slqb_lock);
-#endif
-		break;
 	default:
 		break;
 	}
@@ -2904,9 +2932,8 @@ static void __gather_stats(void *arg)
 	gather->nr_partial += nr_partial;
 	gather->nr_inuse += nr_inuse;
 #ifdef CONFIG_SLQB_STATS
-	for (i = 0; i < NR_SLQB_STAT_ITEMS; i++) {
+	for (i = 0; i < NR_SLQB_STAT_ITEMS; i++)
 		gather->stats[i] += l->stats[i];
-	}
 #endif
 	spin_unlock(&gather->lock);
 }
@@ -2935,9 +2962,8 @@ static void gather_stats(struct kmem_cac
 
 		spin_lock_irqsave(&n->list_lock, flags);
 #ifdef CONFIG_SLQB_STATS
-		for (i = 0; i < NR_SLQB_STAT_ITEMS; i++) {
+		for (i = 0; i < NR_SLQB_STAT_ITEMS; i++)
 			stats->stats[i] += l->stats[i];
-		}
 #endif
 		stats->nr_slabs += l->nr_slabs;
 		stats->nr_partial += l->nr_partial;
@@ -3007,10 +3033,11 @@ static int s_show(struct seq_file *m, vo
 	gather_stats(s, &stats);
 
 	seq_printf(m, "%-17s %6lu %6lu %6u %4u %4d", s->name, stats.nr_inuse,
-		   stats.nr_objects, s->size, s->objects, (1 << s->order));
-	seq_printf(m, " : tunables %4u %4u %4u", slab_hiwater(s), slab_freebatch(s), 0);
-	seq_printf(m, " : slabdata %6lu %6lu %6lu", stats.nr_slabs, stats.nr_slabs,
-		   0UL);
+			stats.nr_objects, s->size, s->objects, (1 << s->order));
+	seq_printf(m, " : tunables %4u %4u %4u", slab_hiwater(s),
+			slab_freebatch(s), 0);
+	seq_printf(m, " : slabdata %6lu %6lu %6lu", stats.nr_slabs,
+			stats.nr_slabs, 0UL);
 	seq_putc(m, '\n');
 	return 0;
 }
@@ -3036,7 +3063,8 @@ static const struct file_operations proc
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
+	proc_create("slabinfo", S_IWUSR|S_IRUGO, NULL,
+			&proc_slabinfo_operations);
 	return 0;
 }
 module_init(slab_proc_init);
@@ -3106,7 +3134,9 @@ SLAB_ATTR_RO(ctor);
 static ssize_t slabs_show(struct kmem_cache *s, char *buf)
 {
 	struct stats_gather stats;
+
 	gather_stats(s, &stats);
+
 	return sprintf(buf, "%lu\n", stats.nr_slabs);
 }
 SLAB_ATTR_RO(slabs);
@@ -3114,7 +3144,9 @@ SLAB_ATTR_RO(slabs);
 static ssize_t objects_show(struct kmem_cache *s, char *buf)
 {
 	struct stats_gather stats;
+
 	gather_stats(s, &stats);
+
 	return sprintf(buf, "%lu\n", stats.nr_inuse);
 }
 SLAB_ATTR_RO(objects);
@@ -3122,7 +3154,9 @@ SLAB_ATTR_RO(objects);
 static ssize_t total_objects_show(struct kmem_cache *s, char *buf)
 {
 	struct stats_gather stats;
+
 	gather_stats(s, &stats);
+
 	return sprintf(buf, "%lu\n", stats.nr_objects);
 }
 SLAB_ATTR_RO(total_objects);
@@ -3171,7 +3205,8 @@ static ssize_t store_user_show(struct km
 }
 SLAB_ATTR_RO(store_user);
 
-static ssize_t hiwater_store(struct kmem_cache *s, const char *buf, size_t length)
+static ssize_t hiwater_store(struct kmem_cache *s,
+				const char *buf, size_t length)
 {
 	long hiwater;
 	int err;
@@ -3194,7 +3229,8 @@ static ssize_t hiwater_show(struct kmem_
 }
 SLAB_ATTR(hiwater);
 
-static ssize_t freebatch_store(struct kmem_cache *s, const char *buf, size_t length)
+static ssize_t freebatch_store(struct kmem_cache *s,
+				const char *buf, size_t length)
 {
 	long freebatch;
 	int err;
@@ -3216,6 +3252,7 @@ static ssize_t freebatch_show(struct kme
 	return sprintf(buf, "%d\n", slab_freebatch(s));
 }
 SLAB_ATTR(freebatch);
+
 #ifdef CONFIG_SLQB_STATS
 static int show_stat(struct kmem_cache *s, char *buf, enum stat_item si)
 {
@@ -3233,8 +3270,9 @@ static int show_stat(struct kmem_cache *
 	for_each_online_cpu(cpu) {
 		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
 		struct kmem_cache_list *l = &c->list;
+
 		if (len < PAGE_SIZE - 20)
-			len += sprintf(buf + len, " C%d=%lu", cpu, l->stats[si]);
+			len += sprintf(buf+len, " C%d=%lu", cpu, l->stats[si]);
 	}
 #endif
 	return len + sprintf(buf + len, "\n");
@@ -3308,8 +3346,7 @@ static struct attribute_group slab_attr_
 };
 
 static ssize_t slab_attr_show(struct kobject *kobj,
-				struct attribute *attr,
-				char *buf)
+				struct attribute *attr, char *buf)
 {
 	struct slab_attribute *attribute;
 	struct kmem_cache *s;
@@ -3327,8 +3364,7 @@ static ssize_t slab_attr_show(struct kob
 }
 
 static ssize_t slab_attr_store(struct kobject *kobj,
-				struct attribute *attr,
-				const char *buf, size_t len)
+			struct attribute *attr, const char *buf, size_t len)
 {
 	struct slab_attribute *attribute;
 	struct kmem_cache *s;
@@ -3396,6 +3432,7 @@ static int sysfs_slab_add(struct kmem_ca
 	err = sysfs_create_group(&s->kobj, &slab_attr_group);
 	if (err)
 		return err;
+
 	kobject_uevent(&s->kobj, KOBJ_ADD);
 
 	return 0;
@@ -3420,17 +3457,20 @@ static int __init slab_sysfs_init(void)
 	}
 
 	down_write(&slqb_lock);
+
 	sysfs_available = 1;
+
 	list_for_each_entry(s, &slab_caches, list) {
 		err = sysfs_slab_add(s);
 		if (err)
 			printk(KERN_ERR "SLQB: Unable to add boot slab %s"
 						" to sysfs\n", s->name);
 	}
+
 	up_write(&slqb_lock);
 
 	return 0;
 }
+device_initcall(slab_sysfs_init);
 
-__initcall(slab_sysfs_init);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
