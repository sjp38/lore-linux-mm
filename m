Message-Id: <20070504103155.582370247@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:26:52 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 01/40] mm: page allocation rank
Content-Disposition: inline; filename=mm-page_alloc-rank.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

Introduce page allocation rank.

This allocation rank is an measure of the 'hardness' of the page allocation.
Where hardness refers to how deep we have to reach (and thereby if reclaim 
was activated) to obtain the page.

It basically is a mapping from the ALLOC_/gfp flags into a scalar quantity,
which allows for comparisons of the kind: 
  'would this allocation have succeeded using these gfp flags'.

For the gfp -> alloc_flags mapping we use the 'hardest' possible, those
used by __alloc_pages() right before going into direct reclaim.

The alloc_flags -> rank mapping is given by: 2*2^wmark - harder - 2*high
where wmark = { min = 1, low, high } and harder, high are booleans.
This gives:
  0 is the hardest possible allocation - ALLOC_NO_WATERMARK,
  1 is ALLOC_WMARK_MIN|ALLOC_HARDER|ALLOC_HIGH,
  ...
  15 is ALLOC_WMARK_HIGH|ALLOC_HARDER,
  16 is the softest allocation - ALLOC_WMARK_HIGH.

Rank <= 4 will have woke up kswapd and when also > 0 might have ran into
direct reclaim.

Rank > 8 rarely happens and means lots of memory free (due to parallel oom kill).

The allocation rank is stored in page->index for successful allocations.

'offline' testing of the rank is made impossible by direct reclaim and
fragmentation issues. That is, it is impossible to tell if a given allocation
will succeed without actually doing it.

The purpose of this measure is to introduce some fairness into the slab
allocator.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/internal.h   |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c |   58 +++++++++++++---------------------------------
 2 files changed, 87 insertions(+), 41 deletions(-)

Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2007-02-22 13:56:00.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2007-02-22 14:08:41.000000000 +0100
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/hardirq.h>
 
 static inline void set_page_count(struct page *page, int v)
 {
@@ -37,4 +38,73 @@ static inline void __put_page(struct pag
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
+#define MAX_ALLOC_RANK	16
+
+/*
+ * classify the allocation: 0 is hardest, 16 is easiest.
+ */
+static inline int alloc_flags_to_rank(int alloc_flags)
+{
+	int rank;
+
+	if (alloc_flags & ALLOC_NO_WATERMARKS)
+		return 0;
+
+	rank = alloc_flags & (ALLOC_WMARK_MIN|ALLOC_WMARK_LOW|ALLOC_WMARK_HIGH);
+	rank -= alloc_flags & (ALLOC_HARDER|ALLOC_HIGH);
+
+	return rank;
+}
+
+static inline int gfp_to_rank(gfp_t gfp_mask)
+{
+	return alloc_flags_to_rank(gfp_to_alloc_flags(gfp_mask));
+}
+
 #endif
Index: linux-2.6-git/mm/page_alloc.c
===================================================================
--- linux-2.6-git.orig/mm/page_alloc.c	2007-02-22 13:56:00.000000000 +0100
+++ linux-2.6-git/mm/page_alloc.c	2007-02-22 14:08:41.000000000 +0100
@@ -892,14 +892,6 @@ failed:
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
@@ -1190,6 +1182,7 @@ zonelist_scan:
 
 		page = buffered_rmqueue(zonelist, zone, order, gfp_mask);
 		if (page)
+			page->index = alloc_flags_to_rank(alloc_flags);
 			break;
 this_zone_full:
 		if (NUMA_BUILD)
@@ -1263,48 +1256,27 @@ restart:
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
@@ -1313,6 +1285,10 @@ nofail_alloc:
 	if (!wait)
 		goto nopage;
 
+	/* Avoid recursion of direct reclaim */
+	if (p->flags & PF_MEMALLOC)
+		goto nopage;
+
 	cond_resched();
 
 	/* We now go into synchronous reclaim */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
