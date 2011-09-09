Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E19B26B01FA
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 06:57:32 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/14] mm: Introduce __GFP_MEMALLOC to allow access to emergency reserves
Date: Fri,  9 Sep 2011 11:57:14 +0100
Message-Id: <1315565845-16857-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1315565845-16857-1-git-send-email-mgorman@suse.de>
References: <1315565845-16857-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

__GFP_MEMALLOC will allow the allocation to disregard the watermarks,
much like PF_MEMALLOC. It allows one to pass along the memalloc state
in object related allocation flags as opposed to task related flags,
such as sk->sk_allocation. This removes the need for ALLOC_PFMEMALLOC
as callers using __GFP_MEMALLOC can get the ALLOC_NO_WATERMARK flag
which is now enough to identify allocations related to page reclaim.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h             |   10 ++++++++--
 include/linux/mm_types.h        |    2 +-
 include/trace/events/gfpflags.h |    1 +
 mm/page_alloc.c                 |   14 ++++++--------
 mm/slab.c                       |    2 +-
 5 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 3a76faf..38acdc7 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -23,6 +23,7 @@ struct vm_area_struct;
 #define ___GFP_REPEAT		0x400u
 #define ___GFP_NOFAIL		0x800u
 #define ___GFP_NORETRY		0x1000u
+#define ___GFP_MEMALLOC		0x2000u
 #define ___GFP_COMP		0x4000u
 #define ___GFP_ZERO		0x8000u
 #define ___GFP_NOMEMALLOC	0x10000u
@@ -75,9 +76,14 @@ struct vm_area_struct;
 #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
 #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
 #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY) /* See above */
+#define __GFP_MEMALLOC	((__force gfp_t)___GFP_MEMALLOC)/* Allow access to emergency reserves */
 #define __GFP_COMP	((__force gfp_t)___GFP_COMP)	/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)	/* Return zeroed page on success */
-#define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves */
+#define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves.
+							 * This takes precedence over the
+							 * __GFP_MEMALLOC flag if both are
+							 * set
+							 */
 #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
@@ -127,7 +133,7 @@ struct vm_area_struct;
 /* Control page allocator reclaim behavior */
 #define GFP_RECLAIM_MASK (__GFP_WAIT|__GFP_HIGH|__GFP_IO|__GFP_FS|\
 			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
-			__GFP_NORETRY|__GFP_NOMEMALLOC)
+			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC)
 
 /* Control slab gfp mask during early boot */
 #define GFP_BOOT_MASK (__GFP_BITS_MASK & ~(__GFP_WAIT|__GFP_IO|__GFP_FS))
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 3716e9f..0be3d43 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -54,7 +54,7 @@ struct page {
 			pgoff_t index;		/* Our offset within mapping. */
 			void *freelist;		/* slub first free object */
 			bool pfmemalloc;	/* If set by the page allocator,
-						 * ALLOC_PFMEMALLOC was set
+						 * ALLOC_NO_WATERMARKS was set
 						 * and the low watermark was not
 						 * met implying that the system
 						 * is under some pressure. The
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
index 9fe3a366..d6fd8e5 100644
--- a/include/trace/events/gfpflags.h
+++ b/include/trace/events/gfpflags.h
@@ -30,6 +30,7 @@
 	{(unsigned long)__GFP_COMP,		"GFP_COMP"},		\
 	{(unsigned long)__GFP_ZERO,		"GFP_ZERO"},		\
 	{(unsigned long)__GFP_NOMEMALLOC,	"GFP_NOMEMALLOC"},	\
+	{(unsigned long)__GFP_MEMALLOC,		"GFP_MEMALLOC"},	\
 	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
 	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
 	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 561cb61..03fd18c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1369,7 +1369,6 @@ failed:
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-#define ALLOC_PFMEMALLOC	0x80 /* Caller has PF_MEMALLOC set */
 
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
@@ -2058,11 +2057,10 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
-	if ((current->flags & PF_MEMALLOC) ||
-			unlikely(test_thread_flag(TIF_MEMDIE))) {
-		alloc_flags |= ALLOC_PFMEMALLOC;
-
-		if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
+	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
+		if (gfp_mask & __GFP_MEMALLOC)
+			alloc_flags |= ALLOC_NO_WATERMARKS;
+		else if (likely(!(gfp_mask & __GFP_NOMEMALLOC)) && !in_interrupt())
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
 
@@ -2071,7 +2069,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 
 bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 {
-	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_PFMEMALLOC);
+	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
 }
 
 static inline struct page *
@@ -2253,7 +2251,7 @@ got_pg:
 	 * steps that will free more memory. The caller should avoid the
 	 * page being used for !PFMEMALLOC purposes.
 	 */
-	page->pfmemalloc = !!(alloc_flags & ALLOC_PFMEMALLOC);
+	page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
 
 	return page;
 }
diff --git a/mm/slab.c b/mm/slab.c
index 1dd03e0..25f69ec 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3031,7 +3031,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	if (!slabp)
 		goto opps1;
 
-	/* Record if ALLOC_PFMEMALLOC was set when allocating the slab */
+	/* Record if ALLOC_NO_WATERMARKS was set when allocating the slab */
 	if (pfmemalloc) {
 		struct array_cache *ac = cpu_cache_get(cachep);
 		slabp->pfmemalloc = true;
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
