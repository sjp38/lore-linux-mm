Message-Id: <20070221144842.108927000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Date: Wed, 21 Feb 2007 15:43:10 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 06/29] mm: __GFP_EMERGENCY
Content-Disposition: inline; filename=mm-page_alloc-GFP_EMERGENCY.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

__GFP_EMERGENCY will allow the allocation to disregard the watermarks, 
much like PF_MEMALLOC.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/gfp.h |    7 ++++++-
 mm/internal.h       |   10 +++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

Index: linux-2.6-git/include/linux/gfp.h
===================================================================
--- linux-2.6-git.orig/include/linux/gfp.h	2006-12-14 10:02:18.000000000 +0100
+++ linux-2.6-git/include/linux/gfp.h	2006-12-14 10:02:52.000000000 +0100
@@ -35,17 +35,21 @@ struct vm_area_struct;
 #define __GFP_HIGH	((__force gfp_t)0x20u)	/* Should access emergency pools? */
 #define __GFP_IO	((__force gfp_t)0x40u)	/* Can start physical IO? */
 #define __GFP_FS	((__force gfp_t)0x80u)	/* Can call down to low-level FS? */
+
 #define __GFP_COLD	((__force gfp_t)0x100u)	/* Cache-cold page required */
 #define __GFP_NOWARN	((__force gfp_t)0x200u)	/* Suppress page allocation failure warning */
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
+
 #define __GFP_NORETRY	((__force gfp_t)0x1000u)/* Do not retry.  Might fail */
 #define __GFP_NO_GROW	((__force gfp_t)0x2000u)/* Slab internal usage */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
+
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
 #define __GFP_HARDWALL   ((__force gfp_t)0x20000u) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)0x40000u)/* No fallback, no policies */
+#define __GFP_EMERGENCY  ((__force gfp_t)0x80000u) /* Use emergency reserves */
 
 #define __GFP_BITS_SHIFT 20	/* Room for 20 __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
@@ -54,7 +58,8 @@ struct vm_area_struct;
 #define GFP_LEVEL_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS| \
 			__GFP_COLD|__GFP_NOWARN|__GFP_REPEAT| \
 			__GFP_NOFAIL|__GFP_NORETRY|__GFP_NO_GROW|__GFP_COMP| \
-			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE)
+			__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE| \
+			__GFP_EMERGENCY)
 
 /* This equals 0, but use constants in case they ever change */
 #define GFP_NOWAIT	(GFP_ATOMIC & ~__GFP_HIGH)
Index: linux-2.6-git/mm/internal.h
===================================================================
--- linux-2.6-git.orig/mm/internal.h	2006-12-14 10:02:52.000000000 +0100
+++ linux-2.6-git/mm/internal.h	2006-12-14 10:02:52.000000000 +0100
@@ -75,7 +75,9 @@ static int inline gfp_to_alloc_flags(gfp
 		alloc_flags |= ALLOC_HARDER;
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_irq() && (p->flags & PF_MEMALLOC))
+		if (gfp_mask & __GFP_EMERGENCY)
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (!in_irq() && (p->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (!in_interrupt() &&
 				unlikely(test_thread_flag(TIF_MEMDIE)))
@@ -103,7 +105,7 @@ static inline int alloc_flags_to_rank(in
 	return rank;
 }
 
-static inline int gfp_to_rank(gfp_t gfp_mask)
+static __always_inline int gfp_to_rank(gfp_t gfp_mask)
 {
 	/*
 	 * Although correct this full version takes a ~3% performance
@@ -118,7 +120,9 @@ static inline int gfp_to_rank(gfp_t gfp_
 	 */
 
 	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
-		if (!in_irq() && (current->flags & PF_MEMALLOC))
+		if (gfp_mask & __GFP_EMERGENCY)
+			return 0;
+		else if (!in_irq() && (current->flags & PF_MEMALLOC))
 			return 0;
 		else if (!in_interrupt() &&
 				unlikely(test_thread_flag(TIF_MEMDIE)))

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
