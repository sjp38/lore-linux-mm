Message-ID: <4167F572.8050900@colorfullife.com>
Date: Sat, 09 Oct 2004 16:28:02 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: slab fragmentation ?
References: <1096500963.12861.21.camel@dyn318077bld.beaverton.ibm.com>	 <20040929204143.134154bc.akpm@osdl.org>  <29460000.1096555795@[10.10.2.4]>	 <1096555693.12861.27.camel@dyn318077bld.beaverton.ibm.com>	 <415F968B.8000403@colorfullife.com>	 <1096905099.12861.117.camel@dyn318077bld.beaverton.ibm.com>	 <41617567.9010507@colorfullife.com>	 <1096987570.12861.122.camel@dyn318077bld.beaverton.ibm.com>	 <4162E0AF.4000704@colorfullife.com>	 <1097000846.12861.143.camel@dyn318077bld.beaverton.ibm.com>	 <4162ECAD.8090403@colorfullife.com> <1097074688.12861.182.camel@dyn318077bld.beaverton.ibm.com>
In-Reply-To: <1097074688.12861.182.camel@dyn318077bld.beaverton.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------010104010109050104090401"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010104010109050104090401
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Badari Pulavarty wrote:

>Am I missing something fundamental here ?
>
>  
>
No, you are right. The current implementation is just wrong(tm). 
Attached is a patch - partially tested.

Description:
kmem_cache_alloc_node allocates memory from a particular node. The patch 
fixes two problems with the current implementation:
- for !CONFIG_NUMA, kmem_cache_alloc_node is identical to kmalloc. The 
patch implements kmem_cache_alloc_node as an alias to kmalloc for 
!CONFIG_NUMA. Right now, the special node aware code runs even on 
non-NUMA systems.
- checks the slab lists instead of allocating a new slab for every 
allocation. This reduces the internal fragmentation.

Badri - could you test the patch?

Andrew, please do not merge the patch yet: it contains a severe bug: if 
a node doesn't contain any memory, then it livelocks because the loop 
never finds a suitable slab. I must think about that case.

--
    Manfred

--------------010104010109050104090401
Content-Type: text/plain;
 name="patch-nodealloc"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-nodealloc"

// $Header$
// Kernel Version:
//  VERSION = 2
//  PATCHLEVEL = 6
//  SUBLEVEL = 9
//  EXTRAVERSION = -rc2-mm3
--- 2.6/include/linux/slab.h	2004-10-02 19:30:20.000000000 +0200
+++ build-2.6/include/linux/slab.h	2004-10-09 16:15:00.127026991 +0200
@@ -61,7 +61,14 @@
 extern int kmem_cache_destroy(kmem_cache_t *);
 extern int kmem_cache_shrink(kmem_cache_t *);
 extern void *kmem_cache_alloc(kmem_cache_t *, int);
+#if CONFIG_NUMA
 extern void *kmem_cache_alloc_node(kmem_cache_t *, int);
+#else
+static inline void *kmem_cache_alloc_node(kmem_cache_t *cachep, int node)
+{
+	return kmem_cache_alloc(cachep, GFP_KERNEL);
+}
+#endif
 extern void kmem_cache_free(kmem_cache_t *, void *);
 extern unsigned int kmem_cache_size(kmem_cache_t *);
 
--- 2.6/mm/slab.c	2004-10-02 19:30:21.000000000 +0200
+++ build-2.6/mm/slab.c	2004-10-09 16:14:30.779497578 +0200
@@ -327,6 +327,7 @@
 	unsigned long		reaped;
 	unsigned long 		errors;
 	unsigned long		max_freeable;
+	unsigned long		node_allocs;
 	atomic_t		allochit;
 	atomic_t		allocmiss;
 	atomic_t		freehit;
@@ -361,6 +362,7 @@
 					(x)->high_mark = (x)->num_active; \
 				} while (0)
 #define	STATS_INC_ERR(x)	((x)->errors++)
+#define	STATS_INC_NODEALLOCS(x)	((x)->node_allocs++)
 #define	STATS_SET_FREEABLE(x, i) \
 				do { if ((x)->max_freeable < i) \
 					(x)->max_freeable = i; \
@@ -378,6 +380,7 @@
 #define	STATS_INC_REAPED(x)	do { } while (0)
 #define	STATS_SET_HIGH(x)	do { } while (0)
 #define	STATS_INC_ERR(x)	do { } while (0)
+#define	STATS_INC_NODEALLOCS(x)	do { } while (0)
 #define	STATS_SET_FREEABLE(x, i) \
 				do { } while (0)
 
@@ -1747,7 +1750,7 @@
  * Grow (by 1) the number of slabs within a cache.  This is called by
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
-static int cache_grow (kmem_cache_t * cachep, int flags)
+static int cache_grow (kmem_cache_t * cachep, int flags, int nodeid)
 {
 	struct slab	*slabp;
 	void		*objp;
@@ -1798,7 +1801,7 @@
 
 
 	/* Get mem for the objs. */
-	if (!(objp = kmem_getpages(cachep, flags, -1)))
+	if (!(objp = kmem_getpages(cachep, flags, nodeid)))
 		goto failed;
 
 	/* Get slab management. */
@@ -2032,7 +2035,7 @@
 
 	if (unlikely(!ac->avail)) {
 		int x;
-		x = cache_grow(cachep, flags);
+		x = cache_grow(cachep, flags, -1);
 		
 		// cache_grow can reenable interrupts, then ac could change.
 		ac = ac_data(cachep);
@@ -2313,6 +2316,7 @@
 	return 0;
 }
 
+#if CONFIG_NUMA
 /**
  * kmem_cache_alloc_node - Allocate an object on the specified node
  * @cachep: The cache to allocate from.
@@ -2325,69 +2329,78 @@
  */
 void *kmem_cache_alloc_node(kmem_cache_t *cachep, int nodeid)
 {
-	size_t offset;
 	void *objp;
-	struct slab *slabp;
-	kmem_bufctl_t next;
-
-	/* The main algorithms are not node aware, thus we have to cheat:
-	 * We bypass all caches and allocate a new slab.
-	 * The following code is a streamlined copy of cache_grow().
-	 */
-
-	/* Get colour for the slab, and update the next value. */
-	spin_lock_irq(&cachep->spinlock);
-	offset = cachep->colour_next;
-	cachep->colour_next++;
-	if (cachep->colour_next >= cachep->colour)
-		cachep->colour_next = 0;
-	offset *= cachep->colour_off;
-	spin_unlock_irq(&cachep->spinlock);
-
-	/* Get mem for the objs. */
-	if (!(objp = kmem_getpages(cachep, GFP_KERNEL, nodeid)))
-		goto failed;
 
-	/* Get slab management. */
-	if (!(slabp = alloc_slabmgmt(cachep, objp, offset, GFP_KERNEL)))
-		goto opps1;
-
-	set_slab_attr(cachep, slabp, objp);
-	cache_init_objs(cachep, slabp, SLAB_CTOR_CONSTRUCTOR);
+	for (;;) {
+		struct slab *slabp;
+		struct list_head *q;
+		kmem_bufctl_t next;
 
-	/* The first object is ours: */
-	objp = slabp->s_mem + slabp->free*cachep->objsize;
-	slabp->inuse++;
-	next = slab_bufctl(slabp)[slabp->free];
-#if DEBUG
-	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-#endif
-	slabp->free = next;
+		objp = NULL;
+		check_irq_on();
+		spin_lock_irq(&cachep->spinlock);
+		/* walk through all partial and empty slab and find one
+		 * from the right node */
+		list_for_each(q,&cachep->lists.slabs_partial) {
+			slabp = list_entry(q, struct slab, list);
+
+			if (page_to_nid(virt_to_page(slabp->s_mem)) == nodeid)
+				goto got_slabp;
+		}
+		list_for_each(q, &cachep->lists.slabs_free) {
+			slabp = list_entry(q, struct slab, list);
+
+			if (page_to_nid(virt_to_page(slabp->s_mem)) == nodeid) {
+got_slabp:
+				/* found one: allocate object */
+				check_slabp(cachep, slabp);
+				check_spinlock_acquired(cachep);
+
+				STATS_INC_ALLOCED(cachep);
+				STATS_INC_ACTIVE(cachep);
+				STATS_SET_HIGH(cachep);
+				STATS_INC_NODEALLOCS(cachep);
+
+				objp = slabp->s_mem + slabp->free*cachep->objsize;
+
+				slabp->inuse++;
+				next = slab_bufctl(slabp)[slabp->free];
+#if DEBUG
+				slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
+#endif
+			       	slabp->free = next;
+				check_slabp(cachep, slabp);
+
+				/* move slabp to correct slabp list: */
+				list_del(&slabp->list);
+				if (slabp->free == BUFCTL_END)
+					list_add(&slabp->list, &cachep->lists.slabs_full);
+				else
+					list_add(&slabp->list, &cachep->lists.slabs_partial);
+
+				list3_data(cachep)->free_objects--;
+				spin_unlock_irq(&cachep->spinlock);
+				goto alloc_done;
+			}
+		}
+		spin_unlock_irq(&cachep->spinlock);
 
-	/* add the remaining objects into the cache */
-	spin_lock_irq(&cachep->spinlock);
-	check_slabp(cachep, slabp);
-	STATS_INC_GROWN(cachep);
-	/* Make slab active. */
-	if (slabp->free == BUFCTL_END) {
-		list_add_tail(&slabp->list, &(list3_data(cachep)->slabs_full));
-	} else {
-		list_add_tail(&slabp->list,
-				&(list3_data(cachep)->slabs_partial));
-		list3_data(cachep)->free_objects += cachep->num-1;
+		local_irq_disable();
+		if (!cache_grow(cachep, GFP_KERNEL, nodeid)) {
+			local_irq_enable();
+			return NULL;
+		}
+		local_irq_enable();
 	}
-	spin_unlock_irq(&cachep->spinlock);
+alloc_done:
 	objp = cache_alloc_debugcheck_after(cachep, GFP_KERNEL, objp,
 					__builtin_return_address(0));
 	return objp;
-opps1:
-	kmem_freepages(cachep, objp);
-failed:
-	return NULL;
-
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 
+#endif
+
 /**
  * kmalloc - allocate memory
  * @size: how many bytes of memory are required.
@@ -2813,15 +2826,16 @@
 		 * without _too_ many complaints.
 		 */
 #if STATS
-		seq_puts(m, "slabinfo - version: 2.0 (statistics)\n");
+		seq_puts(m, "slabinfo - version: 2.1 (statistics)\n");
 #else
-		seq_puts(m, "slabinfo - version: 2.0\n");
+		seq_puts(m, "slabinfo - version: 2.1\n");
 #endif
 		seq_puts(m, "# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab>");
 		seq_puts(m, " : tunables <batchcount> <limit> <sharedfactor>");
 		seq_puts(m, " : slabdata <active_slabs> <num_slabs> <sharedavail>");
 #if STATS
-		seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped> <error> <maxfreeable> <freelimit>");
+		seq_puts(m, " : globalstat <listallocs> <maxobjs> <grown> <reaped>"
+				" <error> <maxfreeable> <freelimit> <nodeallocs>");
 		seq_puts(m, " : cpustat <allochit> <allocmiss> <freehit> <freemiss>");
 #endif
 		seq_putc(m, '\n');
@@ -2912,10 +2926,11 @@
 		unsigned long errors = cachep->errors;
 		unsigned long max_freeable = cachep->max_freeable;
 		unsigned long free_limit = cachep->free_limit;
+		unsigned long node_allocs = cachep->node_allocs;
 
-		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu %4lu %4lu %4lu",
+		seq_printf(m, " : globalstat %7lu %6lu %5lu %4lu %4lu %4lu %4lu %4lu",
 				allocs, high, grown, reaped, errors, 
-				max_freeable, free_limit);
+				max_freeable, free_limit, node_allocs);
 	}
 	/* cpu stats */
 	{

--------------010104010109050104090401--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
