Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1E63E6B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 12:40:33 -0500 (EST)
Date: Wed, 21 Jan 2009 18:40:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] SLQB slab allocator
Message-ID: <20090121174010.GA2998@elte.hu>
References: <20090121143008.GV24891@wotan.suse.de> <20090121145918.GA11311@elte.hu> <20090121165600.GA16695@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090121165600.GA16695@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Christoph Lameter <clameter@engr.sgi.com>
List-ID: <linux-mm.kvack.org>


* Nick Piggin <npiggin@suse.de> wrote:

> On Wed, Jan 21, 2009 at 03:59:18PM +0100, Ingo Molnar wrote:
> > 
> > Mind if i nitpick a bit about minor style issues? Since this is going to 
> > be the next Linux SLAB allocator we might as well do it perfectly :-)
> 
> Well here is an incremental patch which should get most of the issues 
> you pointed out, most of the sane ones that checkpatch pointed out, and 
> a few of my own ;)

here's an incremental one ontop of your incremental patch, enhancing some 
more issues. I now find the code very readable! :-)

( in case you are wondering about the placement of bit_spinlock.h - that 
  file needs fixing, just move it to the top of the file and see the build 
  break. But that's a separate patch.)

	Ingo

------------------->
Subject: slbq: cleanup
From: Ingo Molnar <mingo@elte.hu>
Date: Wed Jan 21 18:10:20 CET 2009

mm/slqb.o:

   text	   data	    bss	    dec	    hex	filename
  17655	  54159	 200456	 272270	  4278e	slqb.o.before
  17653	  54159	 200456	 272268	  4278c	slqb.o.after

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 mm/slqb.c |  588 ++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 308 insertions(+), 280 deletions(-)

Index: linux/mm/slqb.c
===================================================================
--- linux.orig/mm/slqb.c
+++ linux/mm/slqb.c
@@ -7,19 +7,20 @@
  * Using ideas and code from mm/slab.c, mm/slob.c, and mm/slub.c.
  */
 
-#include <linux/mm.h>
-#include <linux/module.h>
-#include <linux/bit_spinlock.h>
 #include <linux/interrupt.h>
-#include <linux/bitops.h>
-#include <linux/slab.h>
-#include <linux/seq_file.h>
-#include <linux/cpu.h>
-#include <linux/cpuset.h>
 #include <linux/mempolicy.h>
-#include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include <linux/seq_file.h>
+#include <linux/bitops.h>
+#include <linux/cpuset.h>
 #include <linux/memory.h>
+#include <linux/module.h>
+#include <linux/ctype.h>
+#include <linux/slab.h>
+#include <linux/cpu.h>
+#include <linux/mm.h>
+
+#include <linux/bit_spinlock.h>
 
 /*
  * TODO
@@ -40,14 +41,14 @@
 struct slqb_page {
 	union {
 		struct {
-			unsigned long	flags;		/* mandatory */
-			atomic_t	_count;		/* mandatory */
-			unsigned int	inuse;		/* Nr of objects */
+			unsigned long	flags;		/* mandatory	   */
+			atomic_t	_count;		/* mandatory	   */
+			unsigned int	inuse;		/* Nr of objects   */
 			struct kmem_cache_list *list;	/* Pointer to list */
-			void		 **freelist;	/* LIFO freelist */
+			void		 **freelist;	/* LIFO freelist   */
 			union {
-				struct list_head lru;	/* misc. list */
-				struct rcu_head rcu_head; /* for rcu freeing */
+				struct list_head lru;	/* misc. list	   */
+				struct rcu_head	rcu_head; /* for rcu freeing */
 			};
 		};
 		struct page page;
@@ -120,16 +121,16 @@ static inline int slab_freebatch(struct 
  * - There is no remote free queue. Nodes don't free objects, CPUs do.
  */
 
-static inline void slqb_stat_inc(struct kmem_cache_list *list,
-				enum stat_item si)
+static inline void
+slqb_stat_inc(struct kmem_cache_list *list, enum stat_item si)
 {
 #ifdef CONFIG_SLQB_STATS
 	list->stats[si]++;
 #endif
 }
 
-static inline void slqb_stat_add(struct kmem_cache_list *list,
-				enum stat_item si, unsigned long nr)
+static inline void
+slqb_stat_add(struct kmem_cache_list *list, enum stat_item si, unsigned long nr)
 {
 #ifdef CONFIG_SLQB_STATS
 	list->stats[si] += nr;
@@ -196,12 +197,12 @@ static inline void __free_slqb_pages(str
 #ifdef CONFIG_SLQB_DEBUG
 static inline int slab_debug(struct kmem_cache *s)
 {
-	return (s->flags &
+	return s->flags &
 			(SLAB_DEBUG_FREE |
 			 SLAB_RED_ZONE |
 			 SLAB_POISON |
 			 SLAB_STORE_USER |
-			 SLAB_TRACE));
+			 SLAB_TRACE);
 }
 static inline int slab_poison(struct kmem_cache *s)
 {
@@ -574,34 +575,34 @@ static int check_bytes_and_report(struct
  * Object layout:
  *
  * object address
- * 	Bytes of the object to be managed.
- * 	If the freepointer may overlay the object then the free
- * 	pointer is the first word of the object.
+ *	Bytes of the object to be managed.
+ *	If the freepointer may overlay the object then the free
+ *	pointer is the first word of the object.
  *
- * 	Poisoning uses 0x6b (POISON_FREE) and the last byte is
- * 	0xa5 (POISON_END)
+ *	Poisoning uses 0x6b (POISON_FREE) and the last byte is
+ *	0xa5 (POISON_END)
  *
  * object + s->objsize
- * 	Padding to reach word boundary. This is also used for Redzoning.
- * 	Padding is extended by another word if Redzoning is enabled and
- * 	objsize == inuse.
+ *	Padding to reach word boundary. This is also used for Redzoning.
+ *	Padding is extended by another word if Redzoning is enabled and
+ *	objsize == inuse.
  *
- * 	We fill with 0xbb (RED_INACTIVE) for inactive objects and with
- * 	0xcc (RED_ACTIVE) for objects in use.
+ *	We fill with 0xbb (RED_INACTIVE) for inactive objects and with
+ *	0xcc (RED_ACTIVE) for objects in use.
  *
  * object + s->inuse
- * 	Meta data starts here.
+ *	Meta data starts here.
  *
- * 	A. Free pointer (if we cannot overwrite object on free)
- * 	B. Tracking data for SLAB_STORE_USER
- * 	C. Padding to reach required alignment boundary or at mininum
- * 		one word if debuggin is on to be able to detect writes
- * 		before the word boundary.
+ *	A. Free pointer (if we cannot overwrite object on free)
+ *	B. Tracking data for SLAB_STORE_USER
+ *	C. Padding to reach required alignment boundary or at mininum
+ *		one word if debuggin is on to be able to detect writes
+ *		before the word boundary.
  *
  *	Padding is done using 0x5a (POISON_INUSE)
  *
  * object + s->size
- * 	Nothing is used beyond s->size.
+ *	Nothing is used beyond s->size.
  */
 
 static int check_pad_bytes(struct kmem_cache *s, struct slqb_page *page, u8 *p)
@@ -717,25 +718,26 @@ static int check_slab(struct kmem_cache 
 	return 1;
 }
 
-static void trace(struct kmem_cache *s, struct slqb_page *page,
-			void *object, int alloc)
+static void
+trace(struct kmem_cache *s, struct slqb_page *page, void *object, int alloc)
 {
-	if (s->flags & SLAB_TRACE) {
-		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
-			s->name,
-			alloc ? "alloc" : "free",
-			object, page->inuse,
-			page->freelist);
+	if (likely(!(s->flags & SLAB_TRACE)))
+		return;
 
-		if (!alloc)
-			print_section("Object", (void *)object, s->objsize);
+	printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
+		s->name,
+		alloc ? "alloc" : "free",
+		object, page->inuse,
+		page->freelist);
 
-		dump_stack();
-	}
+	if (!alloc)
+		print_section("Object", (void *)object, s->objsize);
+
+	dump_stack();
 }
 
-static void setup_object_debug(struct kmem_cache *s, struct slqb_page *page,
-				void *object)
+static void
+setup_object_debug(struct kmem_cache *s, struct slqb_page *page, void *object)
 {
 	if (!slab_debug(s))
 		return;
@@ -747,11 +749,10 @@ static void setup_object_debug(struct km
 	init_tracking(s, object);
 }
 
-static int alloc_debug_processing(struct kmem_cache *s,
-					void *object, void *addr)
+static int
+alloc_debug_processing(struct kmem_cache *s, void *object, void *addr)
 {
-	struct slqb_page *page;
-	page = virt_to_head_slqb_page(object);
+	struct slqb_page *page = virt_to_head_slqb_page(object);
 
 	if (!check_slab(s, page))
 		goto bad;
@@ -767,6 +768,7 @@ static int alloc_debug_processing(struct
 	/* Success perform special debug activities for allocs */
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_ALLOC, addr);
+
 	trace(s, page, object, 1);
 	init_object(s, object, 1);
 	return 1;
@@ -775,11 +777,9 @@ bad:
 	return 0;
 }
 
-static int free_debug_processing(struct kmem_cache *s,
-					void *object, void *addr)
+static int free_debug_processing(struct kmem_cache *s, void *object, void *addr)
 {
-	struct slqb_page *page;
-	page = virt_to_head_slqb_page(object);
+	struct slqb_page *page = virt_to_head_slqb_page(object);
 
 	if (!check_slab(s, page))
 		goto fail;
@@ -870,29 +870,34 @@ static unsigned long kmem_cache_flags(un
 				void (*ctor)(void *))
 {
 	/*
-	 * Enable debugging if selected on the kernel commandline.
+	 * Enable debugging if selected on the kernel commandline:
 	 */
-	if (slqb_debug && (!slqb_debug_slabs ||
-	    strncmp(slqb_debug_slabs, name,
-		strlen(slqb_debug_slabs)) == 0))
-			flags |= slqb_debug;
+
+	if (!slqb_debug)
+		return flags;
+
+	if (slqb_debug_slabs)
+		return flags | slqb_debug;
+
+	if (!strncmp(slqb_debug_slabs, name, strlen(slqb_debug_slabs)))
+		return flags | slqb_debug;
 
 	return flags;
 }
 #else
-static inline void setup_object_debug(struct kmem_cache *s,
-			struct slqb_page *page, void *object)
+static inline void
+setup_object_debug(struct kmem_cache *s, struct slqb_page *page, void *object)
 {
 }
 
-static inline int alloc_debug_processing(struct kmem_cache *s,
-			void *object, void *addr)
+static inline int
+alloc_debug_processing(struct kmem_cache *s, void *object, void *addr)
 {
 	return 0;
 }
 
-static inline int free_debug_processing(struct kmem_cache *s,
-			void *object, void *addr)
+static inline int
+free_debug_processing(struct kmem_cache *s, void *object, void *addr)
 {
 	return 0;
 }
@@ -903,7 +908,7 @@ static inline int slab_pad_check(struct 
 }
 
 static inline int check_object(struct kmem_cache *s, struct slqb_page *page,
-			void *object, int active)
+			       void *object, int active)
 {
 	return 1;
 }
@@ -924,11 +929,11 @@ static const int slqb_debug = 0;
 /*
  * allocate a new slab (return its corresponding struct slqb_page)
  */
-static struct slqb_page *allocate_slab(struct kmem_cache *s,
-					gfp_t flags, int node)
+static struct slqb_page *
+allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
-	struct slqb_page *page;
 	int pages = 1 << s->order;
+	struct slqb_page *page;
 
 	flags |= s->allocflags;
 
@@ -947,8 +952,8 @@ static struct slqb_page *allocate_slab(s
 /*
  * Called once for each object on a new slab page
  */
-static void setup_object(struct kmem_cache *s,
-				struct slqb_page *page, void *object)
+static void
+setup_object(struct kmem_cache *s, struct slqb_page *page, void *object)
 {
 	setup_object_debug(s, page, object);
 	if (unlikely(s->ctor))
@@ -958,8 +963,8 @@ static void setup_object(struct kmem_cac
 /*
  * Allocate a new slab, set up its object list.
  */
-static struct slqb_page *new_slab_page(struct kmem_cache *s,
-				gfp_t flags, int node, unsigned int colour)
+static struct slqb_page *
+new_slab_page(struct kmem_cache *s, gfp_t flags, int node, unsigned int colour)
 {
 	struct slqb_page *page;
 	void *start;
@@ -1030,6 +1035,7 @@ static void rcu_free_slab(struct rcu_hea
 static void free_slab(struct kmem_cache *s, struct slqb_page *page)
 {
 	VM_BUG_ON(page->inuse);
+
 	if (unlikely(s->flags & SLAB_DESTROY_BY_RCU))
 		call_rcu(&page->rcu_head, rcu_free_slab);
 	else
@@ -1060,12 +1066,14 @@ static int free_object_to_page(struct km
 		l->nr_slabs--;
 		free_slab(s, page);
 		slqb_stat_inc(l, FLUSH_SLAB_FREE);
+
 		return 1;
 
 	} else if (page->inuse + 1 == s->objects) {
 		l->nr_partial++;
 		list_add(&page->lru, &l->partial);
 		slqb_stat_inc(l, FLUSH_SLAB_PARTIAL);
+
 		return 0;
 	}
 	return 0;
@@ -1146,8 +1154,8 @@ static void flush_free_list_all(struct k
  * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
  * list_lock in the case of per-node list.
  */
-static void claim_remote_free_list(struct kmem_cache *s,
-					struct kmem_cache_list *l)
+static void
+claim_remote_free_list(struct kmem_cache *s, struct kmem_cache_list *l)
 {
 	void **head, **tail;
 	int nr;
@@ -1192,8 +1200,8 @@ static void claim_remote_free_list(struc
  * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
  * list_lock in the case of per-node list.
  */
-static __always_inline void *__cache_list_get_object(struct kmem_cache *s,
-						struct kmem_cache_list *l)
+static __always_inline void *
+__cache_list_get_object(struct kmem_cache *s, struct kmem_cache_list *l)
 {
 	void *object;
 
@@ -1243,8 +1251,8 @@ static __always_inline void *__cache_lis
  * Caller must be the owner CPU in the case of per-CPU list, or hold the node's
  * list_lock in the case of per-node list.
  */
-static noinline void *__cache_list_get_page(struct kmem_cache *s,
-				struct kmem_cache_list *l)
+static noinline void *
+__cache_list_get_page(struct kmem_cache *s, struct kmem_cache_list *l)
 {
 	struct slqb_page *page;
 	void *object;
@@ -1282,12 +1290,12 @@ static noinline void *__cache_list_get_p
  *
  * Must be called with interrupts disabled.
  */
-static noinline void *__slab_alloc_page(struct kmem_cache *s,
-				gfp_t gfpflags, int node)
+static noinline void *
+__slab_alloc_page(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	struct slqb_page *page;
 	struct kmem_cache_list *l;
 	struct kmem_cache_cpu *c;
+	struct slqb_page *page;
 	unsigned int colour;
 	void *object;
 
@@ -1347,15 +1355,19 @@ static noinline void *__slab_alloc_page(
 }
 
 #ifdef CONFIG_NUMA
-static noinline int alternate_nid(struct kmem_cache *s,
-				gfp_t gfpflags, int node)
+static noinline int
+alternate_nid(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
 	if (in_interrupt() || (gfpflags & __GFP_THISNODE))
 		return node;
-	if (cpuset_do_slab_mem_spread() && (s->flags & SLAB_MEM_SPREAD))
+
+	if (cpuset_do_slab_mem_spread() && (s->flags & SLAB_MEM_SPREAD)) {
 		return cpuset_mem_spread_node();
-	else if (current->mempolicy)
-		return slab_node(current->mempolicy);
+	} else {
+		if (current->mempolicy)
+			return slab_node(current->mempolicy);
+	}
+
 	return node;
 }
 
@@ -1365,8 +1377,8 @@ static noinline int alternate_nid(struct
  *
  * Must be called with interrupts disabled.
  */
-static noinline void *__remote_slab_alloc(struct kmem_cache *s,
-				gfp_t gfpflags, int node)
+static noinline void *
+__remote_slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
 	struct kmem_cache_node *n;
 	struct kmem_cache_list *l;
@@ -1375,6 +1387,7 @@ static noinline void *__remote_slab_allo
 	n = s->node[node];
 	if (unlikely(!n)) /* node has no memory */
 		return NULL;
+
 	l = &n->list;
 
 	spin_lock(&n->list_lock);
@@ -1389,7 +1402,9 @@ static noinline void *__remote_slab_allo
 	}
 	if (likely(object))
 		slqb_stat_inc(l, ALLOC);
+
 	spin_unlock(&n->list_lock);
+
 	return object;
 }
 #endif
@@ -1399,12 +1414,12 @@ static noinline void *__remote_slab_allo
  *
  * Must be called with interrupts disabled.
  */
-static __always_inline void *__slab_alloc(struct kmem_cache *s,
-				gfp_t gfpflags, int node)
+static __always_inline void *
+__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	void *object;
-	struct kmem_cache_cpu *c;
 	struct kmem_cache_list *l;
+	struct kmem_cache_cpu *c;
+	void *object;
 
 #ifdef CONFIG_NUMA
 	if (unlikely(node != -1) && unlikely(node != numa_node_id()))
@@ -1422,6 +1437,7 @@ static __always_inline void *__slab_allo
 	}
 	if (likely(object))
 		slqb_stat_inc(l, ALLOC);
+
 	return object;
 }
 
@@ -1429,11 +1445,11 @@ static __always_inline void *__slab_allo
  * Perform some interrupts-on processing around the main allocation path
  * (debug checking and memset()ing).
  */
-static __always_inline void *slab_alloc(struct kmem_cache *s,
-				gfp_t gfpflags, int node, void *addr)
+static __always_inline void *
+slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node, void *addr)
 {
-	void *object;
 	unsigned long flags;
+	void *object;
 
 again:
 	local_irq_save(flags);
@@ -1451,10 +1467,11 @@ again:
 	return object;
 }
 
-static __always_inline void *__kmem_cache_alloc(struct kmem_cache *s,
-				gfp_t gfpflags, void *caller)
+static __always_inline void *
+__kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags, void *caller)
 {
 	int node = -1;
+
 #ifdef CONFIG_NUMA
 	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY)))
 		node = alternate_nid(s, gfpflags, node);
@@ -1487,8 +1504,8 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
  *
  * Must be called with interrupts disabled.
  */
-static void flush_remote_free_cache(struct kmem_cache *s,
-				struct kmem_cache_cpu *c)
+static void
+flush_remote_free_cache(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	struct kmlist *src;
 	struct kmem_cache_list *dst;
@@ -1575,12 +1592,12 @@ static noinline void slab_free_to_remote
  *
  * Must be called with interrupts disabled.
  */
-static __always_inline void __slab_free(struct kmem_cache *s,
-				struct slqb_page *page, void *object)
+static __always_inline void
+__slab_free(struct kmem_cache *s, struct slqb_page *page, void *object)
 {
-	struct kmem_cache_cpu *c;
-	struct kmem_cache_list *l;
 	int thiscpu = smp_processor_id();
+	struct kmem_cache_list *l;
+	struct kmem_cache_cpu *c;
 
 	c = get_cpu_slab(s, thiscpu);
 	l = &c->list;
@@ -1619,8 +1636,8 @@ static __always_inline void __slab_free(
  * Perform some interrupts-on processing around the main freeing path
  * (debug checking).
  */
-static __always_inline void slab_free(struct kmem_cache *s,
-				struct slqb_page *page, void *object)
+static __always_inline void
+slab_free(struct kmem_cache *s, struct slqb_page *page, void *object)
 {
 	unsigned long flags;
 
@@ -1683,7 +1700,7 @@ static int slab_order(int size, int max_
 	return order;
 }
 
-static int calculate_order(int size)
+static int calc_order(int size)
 {
 	int order;
 
@@ -1710,8 +1727,8 @@ static int calculate_order(int size)
 /*
  * Figure out what the alignment of the objects will be.
  */
-static unsigned long calculate_alignment(unsigned long flags,
-				unsigned long align, unsigned long size)
+static unsigned long
+calc_alignment(unsigned long flags, unsigned long align, unsigned long size)
 {
 	/*
 	 * If the user wants hardware cache aligned objects then follow that
@@ -1737,18 +1754,18 @@ static unsigned long calculate_alignment
 static void init_kmem_cache_list(struct kmem_cache *s,
 				struct kmem_cache_list *l)
 {
-	l->cache		= s;
-	l->freelist.nr		= 0;
-	l->freelist.head	= NULL;
-	l->freelist.tail	= NULL;
-	l->nr_partial		= 0;
-	l->nr_slabs		= 0;
+	l->cache		 = s;
+	l->freelist.nr		 = 0;
+	l->freelist.head	 = NULL;
+	l->freelist.tail	 = NULL;
+	l->nr_partial		 = 0;
+	l->nr_slabs		 = 0;
 	INIT_LIST_HEAD(&l->partial);
 
 #ifdef CONFIG_SMP
-	l->remote_free_check	= 0;
+	l->remote_free_check	 = 0;
 	spin_lock_init(&l->remote_free.lock);
-	l->remote_free.list.nr	= 0;
+	l->remote_free.list.nr	 = 0;
 	l->remote_free.list.head = NULL;
 	l->remote_free.list.tail = NULL;
 #endif
@@ -1758,8 +1775,7 @@ static void init_kmem_cache_list(struct 
 #endif
 }
 
-static void init_kmem_cache_cpu(struct kmem_cache *s,
-				struct kmem_cache_cpu *c)
+static void init_kmem_cache_cpu(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	init_kmem_cache_list(s, &c->list);
 
@@ -1773,8 +1789,8 @@ static void init_kmem_cache_cpu(struct k
 }
 
 #ifdef CONFIG_NUMA
-static void init_kmem_cache_node(struct kmem_cache *s,
-				struct kmem_cache_node *n)
+static void
+init_kmem_cache_node(struct kmem_cache *s, struct kmem_cache_node *n)
 {
 	spin_lock_init(&n->list_lock);
 	init_kmem_cache_list(s, &n->list);
@@ -1804,8 +1820,8 @@ static struct kmem_cache_node kmem_node_
 #endif
 
 #ifdef CONFIG_SMP
-static struct kmem_cache_cpu *alloc_kmem_cache_cpu(struct kmem_cache *s,
-				int cpu)
+static struct kmem_cache_cpu *
+alloc_kmem_cache_cpu(struct kmem_cache *s, int cpu)
 {
 	struct kmem_cache_cpu *c;
 
@@ -1910,7 +1926,7 @@ static int alloc_kmem_cache_nodes(struct
 #endif
 
 /*
- * calculate_sizes() determines the order and the distribution of data within
+ * calc_sizes() determines the order and the distribution of data within
  * a slab object.
  */
 static int calculate_sizes(struct kmem_cache *s)
@@ -1991,7 +2007,7 @@ static int calculate_sizes(struct kmem_c
 	 * user specified and the dynamic determination of cache line size
 	 * on bootup.
 	 */
-	align = calculate_alignment(flags, align, s->objsize);
+	align = calc_alignment(flags, align, s->objsize);
 
 	/*
 	 * SLQB stores one object immediately after another beginning from
@@ -2000,7 +2016,7 @@ static int calculate_sizes(struct kmem_c
 	 */
 	size = ALIGN(size, align);
 	s->size = size;
-	s->order = calculate_order(size);
+	s->order = calc_order(size);
 
 	if (s->order < 0)
 		return 0;
@@ -2210,38 +2226,38 @@ static struct kmem_cache *open_kmalloc_c
  * fls.
  */
 static s8 size_index[24] __cacheline_aligned = {
-	3,	/* 8 */
-	4,	/* 16 */
-	5,	/* 24 */
-	5,	/* 32 */
-	6,	/* 40 */
-	6,	/* 48 */
-	6,	/* 56 */
-	6,	/* 64 */
+	 3,	/* 8 */
+	 4,	/* 16 */
+	 5,	/* 24 */
+	 5,	/* 32 */
+	 6,	/* 40 */
+	 6,	/* 48 */
+	 6,	/* 56 */
+	 6,	/* 64 */
 #if L1_CACHE_BYTES < 64
-	1,	/* 72 */
-	1,	/* 80 */
-	1,	/* 88 */
-	1,	/* 96 */
+	 1,	/* 72 */
+	 1,	/* 80 */
+	 1,	/* 88 */
+	 1,	/* 96 */
 #else
-	7,
-	7,
-	7,
-	7,
-#endif
-	7,	/* 104 */
-	7,	/* 112 */
-	7,	/* 120 */
-	7,	/* 128 */
+	 7,
+	 7,
+	 7,
+	 7,
+#endif
+	 7,	/* 104 */
+	 7,	/* 112 */
+	 7,	/* 120 */
+	 7,	/* 128 */
 #if L1_CACHE_BYTES < 128
-	2,	/* 136 */
-	2,	/* 144 */
-	2,	/* 152 */
-	2,	/* 160 */
-	2,	/* 168 */
-	2,	/* 176 */
-	2,	/* 184 */
-	2	/* 192 */
+	 2,	/* 136 */
+	 2,	/* 144 */
+	 2,	/* 152 */
+	 2,	/* 160 */
+	 2,	/* 168 */
+	 2,	/* 176 */
+	 2,	/* 184 */
+	 2	/* 192 */
 #else
 	-1,
 	-1,
@@ -2278,9 +2294,8 @@ static struct kmem_cache *get_slab(size_
 
 void *__kmalloc(size_t size, gfp_t flags)
 {
-	struct kmem_cache *s;
+	struct kmem_cache *s = get_slab(size, flags);
 
-	s = get_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
@@ -2291,9 +2306,8 @@ EXPORT_SYMBOL(__kmalloc);
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node)
 {
-	struct kmem_cache *s;
+	struct kmem_cache *s = get_slab(size, flags);
 
-	s = get_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
@@ -2340,8 +2354,8 @@ EXPORT_SYMBOL(ksize);
 
 void kfree(const void *object)
 {
-	struct kmem_cache *s;
 	struct slqb_page *page;
+	struct kmem_cache *s;
 
 	if (unlikely(ZERO_OR_NULL_PTR(object)))
 		return;
@@ -2371,21 +2385,21 @@ static void kmem_cache_trim_percpu(void 
 
 int kmem_cache_shrink(struct kmem_cache *s)
 {
-#ifdef CONFIG_NUMA
-	int node;
-#endif
-
 	on_each_cpu(kmem_cache_trim_percpu, s, 1);
 
 #ifdef CONFIG_NUMA
-	for_each_node_state(node, N_NORMAL_MEMORY) {
-		struct kmem_cache_node *n = s->node[node];
-		struct kmem_cache_list *l = &n->list;
+	{
+		int node;
 
-		spin_lock_irq(&n->list_lock);
-		claim_remote_free_list(s, l);
-		flush_free_list(s, l);
-		spin_unlock_irq(&n->list_lock);
+		for_each_node_state(node, N_NORMAL_MEMORY) {
+			struct kmem_cache_node *n = s->node[node];
+			struct kmem_cache_list *l = &n->list;
+
+			spin_lock_irq(&n->list_lock);
+			claim_remote_free_list(s, l);
+			flush_free_list(s, l);
+			spin_unlock_irq(&n->list_lock);
+		}
 	}
 #endif
 
@@ -2397,8 +2411,8 @@ EXPORT_SYMBOL(kmem_cache_shrink);
 static void kmem_cache_reap_percpu(void *arg)
 {
 	int cpu = smp_processor_id();
-	struct kmem_cache *s;
 	long phase = (long)arg;
+	struct kmem_cache *s;
 
 	list_for_each_entry(s, &slab_caches, list) {
 		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
@@ -2442,8 +2456,7 @@ static void kmem_cache_reap(void)
 
 static void cache_trim_worker(struct work_struct *w)
 {
-	struct delayed_work *work =
-		container_of(w, struct delayed_work, work);
+	struct delayed_work *work;
 	struct kmem_cache *s;
 	int node;
 
@@ -2469,6 +2482,7 @@ static void cache_trim_worker(struct wor
 
 	up_read(&slqb_lock);
 out:
+	work = container_of(w, struct delayed_work, work);
 	schedule_delayed_work(work, round_jiffies_relative(3*HZ));
 }
 
@@ -2587,8 +2601,8 @@ static int slab_memory_callback(struct n
 
 void __init kmem_cache_init(void)
 {
-	int i;
 	unsigned int flags = SLAB_HWCACHE_ALIGN|SLAB_PANIC;
+	int i;
 
 	/*
 	 * All the ifdefs are rather ugly here, but it's just the setup code,
@@ -2719,8 +2733,9 @@ void __init kmem_cache_init(void)
 /*
  * Some basic slab creation sanity checks
  */
-static int kmem_cache_create_ok(const char *name, size_t size,
-		size_t align, unsigned long flags)
+static int
+kmem_cache_create_ok(const char *name, size_t size,
+		     size_t align, unsigned long flags)
 {
 	struct kmem_cache *tmp;
 
@@ -2773,8 +2788,9 @@ static int kmem_cache_create_ok(const ch
 	return 1;
 }
 
-struct kmem_cache *kmem_cache_create(const char *name, size_t size,
-		size_t align, unsigned long flags, void (*ctor)(void *))
+struct kmem_cache *
+kmem_cache_create(const char *name, size_t size,
+		  size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
 
@@ -2804,7 +2820,7 @@ EXPORT_SYMBOL(kmem_cache_create);
  * necessary.
  */
 static int __cpuinit slab_cpuup_callback(struct notifier_block *nfb,
-				unsigned long action, void *hcpu)
+					 unsigned long action, void *hcpu)
 {
 	long cpu = (long)hcpu;
 	struct kmem_cache *s;
@@ -2855,7 +2871,7 @@ static int __cpuinit slab_cpuup_callback
 }
 
 static struct notifier_block __cpuinitdata slab_notifier = {
-	.notifier_call = slab_cpuup_callback
+	.notifier_call	= slab_cpuup_callback
 };
 
 #endif
@@ -2878,11 +2894,10 @@ void *__kmalloc_track_caller(size_t size
 }
 
 void *__kmalloc_node_track_caller(size_t size, gfp_t flags, int node,
-				unsigned long caller)
+				  unsigned long caller)
 {
-	struct kmem_cache *s;
+	struct kmem_cache *s = get_slab(size, flags);
 
-	s = get_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;
 
@@ -2892,12 +2907,17 @@ void *__kmalloc_node_track_caller(size_t
 
 #if defined(CONFIG_SLQB_SYSFS) || defined(CONFIG_SLABINFO)
 struct stats_gather {
-	struct kmem_cache *s;
-	spinlock_t lock;
-	unsigned long nr_slabs;
-	unsigned long nr_partial;
-	unsigned long nr_inuse;
-	unsigned long nr_objects;
+	/*
+	 * Serialize on_each_cpu() instances updating the summary
+	 * stats structure:
+	 */
+	spinlock_t		lock;
+
+	struct kmem_cache	*s;
+	unsigned long		nr_slabs;
+	unsigned long		nr_partial;
+	unsigned long		nr_inuse;
+	unsigned long		nr_objects;
 
 #ifdef CONFIG_SLQB_STATS
 	unsigned long stats[NR_SLQB_STAT_ITEMS];
@@ -2915,25 +2935,25 @@ static void __gather_stats(void *arg)
 	struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
 	struct kmem_cache_list *l = &c->list;
 	struct slqb_page *page;
-#ifdef CONFIG_SLQB_STATS
-	int i;
-#endif
 
 	nr_slabs = l->nr_slabs;
 	nr_partial = l->nr_partial;
 	nr_inuse = (nr_slabs - nr_partial) * s->objects;
 
-	list_for_each_entry(page, &l->partial, lru) {
+	list_for_each_entry(page, &l->partial, lru)
 		nr_inuse += page->inuse;
-	}
 
 	spin_lock(&gather->lock);
 	gather->nr_slabs += nr_slabs;
 	gather->nr_partial += nr_partial;
 	gather->nr_inuse += nr_inuse;
 #ifdef CONFIG_SLQB_STATS
-	for (i = 0; i < NR_SLQB_STAT_ITEMS; i++)
-		gather->stats[i] += l->stats[i];
+	{
+		int i;
+
+		for (i = 0; i < NR_SLQB_STAT_ITEMS; i++)
+			gather->stats[i] += l->stats[i];
+	}
 #endif
 	spin_unlock(&gather->lock);
 }
@@ -2956,14 +2976,15 @@ static void gather_stats(struct kmem_cac
 		struct kmem_cache_list *l = &n->list;
 		struct slqb_page *page;
 		unsigned long flags;
-#ifdef CONFIG_SLQB_STATS
-		int i;
-#endif
 
 		spin_lock_irqsave(&n->list_lock, flags);
 #ifdef CONFIG_SLQB_STATS
-		for (i = 0; i < NR_SLQB_STAT_ITEMS; i++)
-			stats->stats[i] += l->stats[i];
+		{
+			int i;
+
+			for (i = 0; i < NR_SLQB_STAT_ITEMS; i++)
+				stats->stats[i] += l->stats[i];
+		}
 #endif
 		stats->nr_slabs += l->nr_slabs;
 		stats->nr_partial += l->nr_partial;
@@ -3039,14 +3060,15 @@ static int s_show(struct seq_file *m, vo
 	seq_printf(m, " : slabdata %6lu %6lu %6lu", stats.nr_slabs,
 			stats.nr_slabs, 0UL);
 	seq_putc(m, '\n');
+
 	return 0;
 }
 
 static const struct seq_operations slabinfo_op = {
-	.start = s_start,
-	.next = s_next,
-	.stop = s_stop,
-	.show = s_show,
+	.start		= s_start,
+	.next		= s_next,
+	.stop		= s_stop,
+	.show		= s_show,
 };
 
 static int slabinfo_open(struct inode *inode, struct file *file)
@@ -3205,8 +3227,8 @@ static ssize_t store_user_show(struct km
 }
 SLAB_ATTR_RO(store_user);
 
-static ssize_t hiwater_store(struct kmem_cache *s,
-				const char *buf, size_t length)
+static ssize_t
+hiwater_store(struct kmem_cache *s, const char *buf, size_t length)
 {
 	long hiwater;
 	int err;
@@ -3229,8 +3251,8 @@ static ssize_t hiwater_show(struct kmem_
 }
 SLAB_ATTR(hiwater);
 
-static ssize_t freebatch_store(struct kmem_cache *s,
-				const char *buf, size_t length)
+static ssize_t
+freebatch_store(struct kmem_cache *s, const char *buf, size_t length)
 {
 	long freebatch;
 	int err;
@@ -3258,91 +3280,95 @@ static int show_stat(struct kmem_cache *
 {
 	struct stats_gather stats;
 	int len;
-#ifdef CONFIG_SMP
-	int cpu;
-#endif
 
 	gather_stats(s, &stats);
 
 	len = sprintf(buf, "%lu", stats.stats[si]);
 
 #ifdef CONFIG_SMP
-	for_each_online_cpu(cpu) {
-		struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
-		struct kmem_cache_list *l = &c->list;
+	{
+		int cpu;
 
-		if (len < PAGE_SIZE - 20)
-			len += sprintf(buf+len, " C%d=%lu", cpu, l->stats[si]);
+		for_each_online_cpu(cpu) {
+			struct kmem_cache_cpu *c = get_cpu_slab(s, cpu);
+			struct kmem_cache_list *l = &c->list;
+
+			if (len < PAGE_SIZE - 20) {
+				len += sprintf(buf+len,
+						" C%d=%lu", cpu, l->stats[si]);
+			}
+		}
 	}
 #endif
 	return len + sprintf(buf + len, "\n");
 }
 
-#define STAT_ATTR(si, text) 					\
+#define STAT_ATTR(si, text)					\
 static ssize_t text##_show(struct kmem_cache *s, char *buf)	\
 {								\
 	return show_stat(s, buf, si);				\
 }								\
 SLAB_ATTR_RO(text);						\
 
-STAT_ATTR(ALLOC, alloc);
-STAT_ATTR(ALLOC_SLAB_FILL, alloc_slab_fill);
-STAT_ATTR(ALLOC_SLAB_NEW, alloc_slab_new);
-STAT_ATTR(FREE, free);
-STAT_ATTR(FREE_REMOTE, free_remote);
-STAT_ATTR(FLUSH_FREE_LIST, flush_free_list);
-STAT_ATTR(FLUSH_FREE_LIST_OBJECTS, flush_free_list_objects);
-STAT_ATTR(FLUSH_FREE_LIST_REMOTE, flush_free_list_remote);
-STAT_ATTR(FLUSH_SLAB_PARTIAL, flush_slab_partial);
-STAT_ATTR(FLUSH_SLAB_FREE, flush_slab_free);
-STAT_ATTR(FLUSH_RFREE_LIST, flush_rfree_list);
-STAT_ATTR(FLUSH_RFREE_LIST_OBJECTS, flush_rfree_list_objects);
-STAT_ATTR(CLAIM_REMOTE_LIST, claim_remote_list);
-STAT_ATTR(CLAIM_REMOTE_LIST_OBJECTS, claim_remote_list_objects);
+STAT_ATTR(ALLOC,			alloc);
+STAT_ATTR(ALLOC_SLAB_FILL,		alloc_slab_fill);
+STAT_ATTR(ALLOC_SLAB_NEW,		alloc_slab_new);
+STAT_ATTR(FREE,				free);
+STAT_ATTR(FREE_REMOTE,			free_remote);
+STAT_ATTR(FLUSH_FREE_LIST,		flush_free_list);
+STAT_ATTR(FLUSH_FREE_LIST_OBJECTS,	flush_free_list_objects);
+STAT_ATTR(FLUSH_FREE_LIST_REMOTE,	flush_free_list_remote);
+STAT_ATTR(FLUSH_SLAB_PARTIAL,		flush_slab_partial);
+STAT_ATTR(FLUSH_SLAB_FREE,		flush_slab_free);
+STAT_ATTR(FLUSH_RFREE_LIST,		flush_rfree_list);
+STAT_ATTR(FLUSH_RFREE_LIST_OBJECTS,	flush_rfree_list_objects);
+STAT_ATTR(CLAIM_REMOTE_LIST,		claim_remote_list);
+STAT_ATTR(CLAIM_REMOTE_LIST_OBJECTS,	claim_remote_list_objects);
 #endif
 
 static struct attribute *slab_attrs[] = {
-	&slab_size_attr.attr,
-	&object_size_attr.attr,
-	&objs_per_slab_attr.attr,
-	&order_attr.attr,
-	&objects_attr.attr,
-	&total_objects_attr.attr,
-	&slabs_attr.attr,
-	&ctor_attr.attr,
-	&align_attr.attr,
-	&hwcache_align_attr.attr,
-	&reclaim_account_attr.attr,
-	&destroy_by_rcu_attr.attr,
-	&red_zone_attr.attr,
-	&poison_attr.attr,
-	&store_user_attr.attr,
-	&hiwater_attr.attr,
-	&freebatch_attr.attr,
+
+	&                 slab_size_attr.attr,
+	&               object_size_attr.attr,
+	&             objs_per_slab_attr.attr,
+	&                     order_attr.attr,
+	&                   objects_attr.attr,
+	&             total_objects_attr.attr,
+	&                     slabs_attr.attr,
+	&                      ctor_attr.attr,
+	&                     align_attr.attr,
+	&             hwcache_align_attr.attr,
+	&           reclaim_account_attr.attr,
+	&            destroy_by_rcu_attr.attr,
+	&                  red_zone_attr.attr,
+	&                    poison_attr.attr,
+	&                store_user_attr.attr,
+	&                   hiwater_attr.attr,
+	&                 freebatch_attr.attr,
 #ifdef CONFIG_ZONE_DMA
-	&cache_dma_attr.attr,
+	&                 cache_dma_attr.attr,
 #endif
 #ifdef CONFIG_SLQB_STATS
-	&alloc_attr.attr,
-	&alloc_slab_fill_attr.attr,
-	&alloc_slab_new_attr.attr,
-	&free_attr.attr,
-	&free_remote_attr.attr,
-	&flush_free_list_attr.attr,
-	&flush_free_list_objects_attr.attr,
-	&flush_free_list_remote_attr.attr,
-	&flush_slab_partial_attr.attr,
-	&flush_slab_free_attr.attr,
-	&flush_rfree_list_attr.attr,
-	&flush_rfree_list_objects_attr.attr,
-	&claim_remote_list_attr.attr,
-	&claim_remote_list_objects_attr.attr,
+	&                     alloc_attr.attr,
+	&           alloc_slab_fill_attr.attr,
+	&            alloc_slab_new_attr.attr,
+	&                      free_attr.attr,
+	&               free_remote_attr.attr,
+	&           flush_free_list_attr.attr,
+	&   flush_free_list_objects_attr.attr,
+	&    flush_free_list_remote_attr.attr,
+	&        flush_slab_partial_attr.attr,
+	&           flush_slab_free_attr.attr,
+	&          flush_rfree_list_attr.attr,
+	&  flush_rfree_list_objects_attr.attr,
+	&         claim_remote_list_attr.attr,
+	& claim_remote_list_objects_attr.attr,
 #endif
 	NULL
 };
 
 static struct attribute_group slab_attr_group = {
-	.attrs = slab_attrs,
+	.attrs		= slab_attrs,
 };
 
 static ssize_t slab_attr_show(struct kobject *kobj,
@@ -3389,13 +3415,13 @@ static void kmem_cache_release(struct ko
 }
 
 static struct sysfs_ops slab_sysfs_ops = {
-	.show = slab_attr_show,
-	.store = slab_attr_store,
+	.show		= slab_attr_show,
+	.store		= slab_attr_store,
 };
 
 static struct kobj_type slab_ktype = {
-	.sysfs_ops = &slab_sysfs_ops,
-	.release = kmem_cache_release
+	.sysfs_ops	= &slab_sysfs_ops,
+	.release	= kmem_cache_release
 };
 
 static int uevent_filter(struct kset *kset, struct kobject *kobj)
@@ -3413,7 +3439,7 @@ static struct kset_uevent_ops slab_ueven
 
 static struct kset *slab_kset;
 
-static int sysfs_available __read_mostly = 0;
+static int sysfs_available __read_mostly;
 
 static int sysfs_slab_add(struct kmem_cache *s)
 {
@@ -3462,9 +3488,11 @@ static int __init slab_sysfs_init(void)
 
 	list_for_each_entry(s, &slab_caches, list) {
 		err = sysfs_slab_add(s);
-		if (err)
-			printk(KERN_ERR "SLQB: Unable to add boot slab %s"
-						" to sysfs\n", s->name);
+		if (!err)
+			continue;
+
+		printk(KERN_ERR
+			"SLQB: Unable to add boot slab %s to sysfs\n", s->name);
 	}
 
 	up_write(&slqb_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
