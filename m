Message-Id: <20070806103657.858561000@chello.nl>
References: <20070806102922.907530000@chello.nl>
Date: Mon, 06 Aug 2007 12:29:23 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 01/10] mm: gfp_to_alloc_flags()
Content-Disposition: inline; filename=mm-gfp-to-alloc_flags.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

abstract out the gfp to alloc_flags mapping so it can be used in other places.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/internal.h   |   10 +++++
 mm/page_alloc.c |   98 ++++++++++++++++++++++++++++++++------------------------
 2 files changed, 66 insertions(+), 42 deletions(-)

Index: linux-2.6-2/mm/internal.h
===================================================================
--- linux-2.6-2.orig/mm/internal.h
+++ linux-2.6-2/mm/internal.h
@@ -37,4 +37,14 @@ static inline void __put_page(struct pag
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
+int gfp_to_alloc_flags(gfp_t gfp_mask);
+
 #endif
Index: linux-2.6-2/mm/page_alloc.c
===================================================================
--- linux-2.6-2.orig/mm/page_alloc.c
+++ linux-2.6-2/mm/page_alloc.c
@@ -887,14 +887,6 @@ failed:
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
@@ -1217,6 +1209,44 @@ try_next_zone:
 }
 
 /*
+ * get the deepest reaching allocation flags for the given gfp_mask
+ */
+int gfp_to_alloc_flags(gfp_t gfp_mask)
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
+/*
  * This is the 'heart' of the zoned buddy allocator.
  */
 struct page * fastcall
@@ -1268,48 +1298,28 @@ restart:
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
-				zonelist, ALLOC_NO_WATERMARKS);
-			if (page)
-				goto got_pg;
-			if (gfp_mask & __GFP_NOFAIL) {
-				congestion_wait(WRITE, HZ/50);
-				goto nofail_alloc;
-			}
+		/* go through the zonelist yet again, ignoring mins */
+		page = get_page_from_freelist(gfp_mask, order, zonelist,
+				ALLOC_NO_WATERMARKS);
+		if (page)
+			goto got_pg;
+
+		if (wait && (gfp_mask & __GFP_NOFAIL)) {
+			congestion_wait(WRITE, HZ/50);
+			goto nofail_alloc;
 		}
 		goto nopage;
 	}
@@ -1318,6 +1328,10 @@ nofail_alloc:
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
