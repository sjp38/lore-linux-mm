Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0705181002400.9372@schroedinger.engr.sgi.com>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com>
	 <1179385718.27354.17.camel@twins>
	 <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
	 <20070517175327.GX11115@waste.org>
	 <Pine.LNX.4.64.0705171101360.18085@schroedinger.engr.sgi.com>
	 <1179429499.2925.26.camel@lappy>
	 <Pine.LNX.4.64.0705171220120.3043@schroedinger.engr.sgi.com>
	 <1179437209.2925.29.camel@lappy>
	 <Pine.LNX.4.64.0705171516260.4593@schroedinger.engr.sgi.com>
	 <1179482054.2925.52.camel@lappy>
	 <Pine.LNX.4.64.0705181002400.9372@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Sun, 20 May 2007 10:39:44 +0200
Message-Id: <1179650384.7019.33.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

Ok, full reset.

I care about kernel allocations only. In particular about those that
have PF_MEMALLOC semantics.

The thing I need is that any memory allocated below
  ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER
is only ever used by processes that have ALLOC_NO_WATERMARKS rights;
for the duration of the distress.

What this patch does:
 - change the page allocator to try ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER
   if ALLOC_NO_WATERMARKS, before the actual ALLOC_NO_WATERMARKS alloc

 - set page->reserve nonzero for each page allocated with
   ALLOC_NO_WATERMARKS; which by the previous point implies that all
   available zones are below ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER

 - when a page->reserve slab is allocated store it in s->reserve_slab
   and do not update the ->cpu_slab[] (this forces subsequent allocs to
   retry the allocation).

All ALLOC_NO_WATERMARKS enabled slab allocations are served from
->reserve_slab, up until the point where a !page->reserve slab alloc
succeeds, at which point the ->reserve_slab is pushed into the partial
lists and ->reserve_slab set to NULL.

Since only the allocation of a new slab uses the gfp zone flags, and
other allocations placement hints they have to be uniform over all slab
allocs for a given kmem_cache. Thus the s->reserve_slab/page->reserve
status is kmem_cache wide.

Any holes left?

---

Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h
+++ linux-2.6-git/mm/internal.h
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/hardirq.h>
 
 static inline void set_page_count(struct page *page, int v)
 {
@@ -37,4 +38,50 @@ static inline void __put_page(struct pag
 extern void fastcall __init __free_pages_bootmem(struct page *page,
 						unsigned int order);
 
+#define ALLOC_HARDER		0x01 /* try to alloc harder */
+#define ALLOC_HIGH		0x02 /* __GFP_HIGH set */
+#define ALLOC_WMARK_MIN		0x04 /* use pages_min watermark */
+#define ALLOC_WMARK_LOW		0x08 /* use pages_low watermark */
+#define ALLOC_WMARK_HIGH	0x10 /* use pages_high watermark */
+#define ALLOC_NO_WATERMARKS	0x20 /* don't check watermarks at all */
+#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+
+/*
+ * get the deepest reaching allocation flags for the given gfp_mask
+ */
+static int inline gfp_to_alloc_flags(gfp_t gfp_mask)
+{
+	struct task_struct *p = current;
+	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
+	const gfp_t wait = gfp_mask & __GFP_WAIT;
+
+	/*
+	 * The caller may dip into page reserves a bit more if the caller
+	 * cannot run direct reclaim, or if the caller has realtime scheduling
+	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
+	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
+	 */
+	if (gfp_mask & __GFP_HIGH)
+		alloc_flags |= ALLOC_HIGH;
+
+	if (!wait) {
+		alloc_flags |= ALLOC_HARDER;
+		/*
+		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
+		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
+		 */
+		alloc_flags &= ~ALLOC_CPUSET;
+	} else if (unlikely(rt_task(p)) && !in_interrupt())
+		alloc_flags |= ALLOC_HARDER;
+
+	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
+		if (!in_interrupt() &&
+		    ((p->flags & PF_MEMALLOC) ||
+		     unlikely(test_thread_flag(TIF_MEMDIE))))
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+	}
+
+	return alloc_flags;
+}
+
 #endif
Index: linux-2.6-git/mm/page_alloc.c
===================================================================
--- linux-2.6-git.orig/mm/page_alloc.c
+++ linux-2.6-git/mm/page_alloc.c
@@ -1175,14 +1175,6 @@ failed:
 	return NULL;
 }
 
-#define ALLOC_NO_WATERMARKS	0x01 /* don't check watermarks at all */
-#define ALLOC_WMARK_MIN		0x02 /* use pages_min watermark */
-#define ALLOC_WMARK_LOW		0x04 /* use pages_low watermark */
-#define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
-#define ALLOC_HARDER		0x10 /* try to alloc harder */
-#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
-#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
 static struct fail_page_alloc_attr {
@@ -1494,6 +1486,7 @@ zonelist_scan:
 
 		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
 		if (page)
+			page->reserve = (alloc_flags & ALLOC_NO_WATERMARKS);
 			break;
 this_zone_full:
 		if (NUMA_BUILD)
@@ -1619,48 +1612,36 @@ restart:
 	 * OK, we're below the kswapd watermark and have kicked background
 	 * reclaim. Now things get more complex, so set up alloc_flags according
 	 * to how we want to proceed.
-	 *
-	 * The caller may dip into page reserves a bit more if the caller
-	 * cannot run direct reclaim, or if the caller has realtime scheduling
-	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
-	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
 	 */
-	alloc_flags = ALLOC_WMARK_MIN;
-	if ((unlikely(rt_task(p)) && !in_interrupt()) || !wait)
-		alloc_flags |= ALLOC_HARDER;
-	if (gfp_mask & __GFP_HIGH)
-		alloc_flags |= ALLOC_HIGH;
-	if (wait)
-		alloc_flags |= ALLOC_CPUSET;
+	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
-	/*
-	 * Go through the zonelist again. Let __GFP_HIGH and allocations
-	 * coming from realtime tasks go deeper into reserves.
-	 *
-	 * This is the last chance, in general, before the goto nopage.
-	 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
-	 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
-	 */
-	page = get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags);
+	/* This is the last chance, in general, before the goto nopage. */
+	page = get_page_from_freelist(gfp_mask, order, zonelist,
+			alloc_flags & ~ALLOC_NO_WATERMARKS);
 	if (page)
 		goto got_pg;
 
 	/* This allocation should allow future memory freeing. */
-
 rebalance:
-	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
-			&& !in_interrupt()) {
-		if (!(gfp_mask & __GFP_NOMEMALLOC)) {
+	if (alloc_flags & ALLOC_NO_WATERMARKS) {
 nofail_alloc:
-			/* go through the zonelist yet again, ignoring mins */
-			page = get_page_from_freelist(gfp_mask, order,
+		/*
+		 * Before going bare metal, try to get a page above the
+		 * critical threshold - ignoring CPU sets.
+		 */
+		page = get_page_from_freelist(gfp_mask, order, zonelist,
+				ALLOC_MIN|ALLOC_HIGH|ALLOC_HARDER);
+		if (page)
+			goto got_pg;
+
+		/* go through the zonelist yet again, ignoring mins */
+		page = get_page_from_freelist(gfp_mask, order,
 				zonelist, ALLOC_NO_WATERMARKS);
-			if (page)
-				goto got_pg;
-			if (gfp_mask & __GFP_NOFAIL) {
-				congestion_wait(WRITE, HZ/50);
-				goto nofail_alloc;
-			}
+		if (page)
+			goto got_pg;
+		if (wait && (gfp_mask & __GFP_NOFAIL)) {
+			congestion_wait(WRITE, HZ/50);
+			goto nofail_alloc;
 		}
 		goto nopage;
 	}
@@ -1669,6 +1650,10 @@ nofail_alloc:
 	if (!wait)
 		goto nopage;
 
+	/* Avoid recursion of direct reclaim */
+	if (p->flags & PF_MEMALLOC)
+		goto nopage;
+
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
Index: linux-2.6-git/include/linux/mm_types.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm_types.h
+++ linux-2.6-git/include/linux/mm_types.h
@@ -60,6 +60,7 @@ struct page {
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
+		int reserve;		/* page_alloc: page is a reserve page */
 	};
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
Index: linux-2.6-git/include/linux/slub_def.h
===================================================================
--- linux-2.6-git.orig/include/linux/slub_def.h
+++ linux-2.6-git/include/linux/slub_def.h
@@ -46,6 +46,8 @@ struct kmem_cache {
 	struct list_head list;	/* List of slab caches */
 	struct kobject kobj;	/* For sysfs */
 
+	struct page *reserve_slab;
+
 #ifdef CONFIG_NUMA
 	int defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
Index: linux-2.6-git/mm/slub.c
===================================================================
--- linux-2.6-git.orig/mm/slub.c
+++ linux-2.6-git/mm/slub.c
@@ -20,11 +20,13 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include "internal.h"
 
 /*
  * Lock order:
- *   1. slab_lock(page)
- *   2. slab->list_lock
+ *   1. reserve_lock
+ *   2. slab_lock(page)
+ *   3. node->list_lock
  *
  *   The slab_lock protects operations on the object of a particular
  *   slab and its metadata in the page struct. If the slab lock
@@ -259,6 +261,8 @@ static int sysfs_slab_alias(struct kmem_
 static void sysfs_slab_remove(struct kmem_cache *s) {}
 #endif
 
+static DEFINE_SPINLOCK(reserve_lock);
+
 /********************************************************************
  * 			Core slab cache functions
  *******************************************************************/
@@ -1007,7 +1011,7 @@ static void setup_object(struct kmem_cac
 		s->ctor(object, s, 0);
 }
 
-static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *reserve)
 {
 	struct page *page;
 	struct kmem_cache_node *n;
@@ -1025,6 +1029,7 @@ static struct page *new_slab(struct kmem
 	if (!page)
 		goto out;
 
+	*reserve = page->reserve;
 	n = get_node(s, page_to_nid(page));
 	if (n)
 		atomic_long_inc(&n->nr_slabs);
@@ -1395,6 +1400,7 @@ static void *__slab_alloc(struct kmem_ca
 {
 	void **object;
 	int cpu = smp_processor_id();
+	int reserve = 0;
 
 	if (!page)
 		goto new_slab;
@@ -1424,10 +1430,25 @@ new_slab:
 	if (page) {
 		s->cpu_slab[cpu] = page;
 		goto load_freelist;
-	}
+	} else if (unlikely(gfp_to_alloc_flags(gfpflags) & ALLOC_NO_WATERMARKS))
+		goto try_reserve;
 
-	page = new_slab(s, gfpflags, node);
-	if (page) {
+alloc_slab:
+	page = new_slab(s, gfpflags, node, &reserve);
+	if (page && !reserve) {
+		if (unlikely(s->reserve_slab)) {
+			struct page *reserve;
+
+			spin_lock(&reserve_lock);
+			reserve = s->reserve_slab;
+			s->reserve_slab = NULL;
+			spin_unlock(&reserve_lock);
+
+			if (reserve) {
+				slab_lock(reserve);
+				unfreeze_slab(s, reserve);
+			}
+		}
 		cpu = smp_processor_id();
 		if (s->cpu_slab[cpu]) {
 			/*
@@ -1455,6 +1476,18 @@ new_slab:
 		SetSlabFrozen(page);
 		s->cpu_slab[cpu] = page;
 		goto load_freelist;
+	} else if (page) {
+		spin_lock(&reserve_lock);
+		if (s->reserve_slab) {
+			discard_slab(s, page);
+			page = s->reserve_slab;
+			goto got_reserve;
+		}
+		slab_lock(page);
+		SetSlabFrozen(page);
+		s->reserve_slab = page;
+		spin_unlock(&reserve_lock);
+		goto use_reserve;
 	}
 	return NULL;
 debug:
@@ -1470,6 +1503,31 @@ debug:
 	page->freelist = object[page->offset];
 	slab_unlock(page);
 	return object;
+
+try_reserve:
+	spin_lock(&reserve_lock);
+	page = s->reserve_slab;
+	if (!page) {
+		spin_unlock(&reserve_lock);
+		goto alloc_slab;
+	}
+
+got_reserve:
+	slab_lock(page);
+	if (!page->freelist) {
+		s->reserve_slab = NULL;
+		spin_unlock(&reserve_lock);
+		unfreeze_slab(s, page);
+		goto alloc_slab;
+	}
+	spin_unlock(&reserve_lock);
+
+use_reserve:
+	object = page->freelist;
+	page->inuse++;
+	page->freelist = object[page->offset];
+	slab_unlock(page);
+	return object;
 }
 
 /*
@@ -1807,10 +1865,11 @@ static struct kmem_cache_node * __init e
 {
 	struct page *page;
 	struct kmem_cache_node *n;
+	int reserve;
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node);
+	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node, &reserve);
 	/* new_slab() disables interupts */
 	local_irq_enable();
 
@@ -2018,6 +2077,8 @@ static int kmem_cache_open(struct kmem_c
 #ifdef CONFIG_NUMA
 	s->defrag_ratio = 100;
 #endif
+	s->reserve_slab = NULL;
+
 	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		return 1;
 error:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
