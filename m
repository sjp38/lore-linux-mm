Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6CF46600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 09:24:59 -0400 (EDT)
From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: [PATCH 03/31] mm: expose gfp_to_alloc_flags()
Date: Thu,  1 Oct 2009 19:35:03 +0530
Message-Id: <1254405903-15760-1-git-send-email-sjayaraman@suse.de>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: netdev@vger.kernel.org, Neil Brown <neilb@suse.de>, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no, Suresh Jayaraman <sjayaraman@suse.de>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl> 

Expose the gfp to alloc_flags mapping, so we can use it in other parts
of the vm.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
---
 mm/internal.h   |   15 +++++++++++++++
 mm/page_alloc.c |   16 +---------------
 2 files changed, 16 insertions(+), 15 deletions(-)

Index: mmotm/mm/internal.h
===================================================================
--- mmotm.orig/mm/internal.h
+++ mmotm/mm/internal.h
@@ -194,6 +194,21 @@ static inline struct page *mem_map_next(
 #define __paginginit __init
 #endif
 
+/* The ALLOC_WMARK bits are used as an index to zone->watermark */
+#define ALLOC_WMARK_MIN		WMARK_MIN
+#define ALLOC_WMARK_LOW		WMARK_LOW
+#define ALLOC_WMARK_HIGH	WMARK_HIGH
+#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
+
+/* Mask to get the watermark bits */
+#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
+
+#define ALLOC_HARDER		0x10 /* try to alloc harder */
+#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
+#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+
+int gfp_to_alloc_flags(gfp_t gfp_mask);
+
 /* Memory initialisation debug and verification */
 enum mminit_level {
 	MMINIT_WARNING,
Index: mmotm/mm/page_alloc.c
===================================================================
--- mmotm.orig/mm/page_alloc.c
+++ mmotm/mm/page_alloc.c
@@ -1190,19 +1190,6 @@ failed:
 	return NULL;
 }
 
-/* The ALLOC_WMARK bits are used as an index to zone->watermark */
-#define ALLOC_WMARK_MIN		WMARK_MIN
-#define ALLOC_WMARK_LOW		WMARK_LOW
-#define ALLOC_WMARK_HIGH	WMARK_HIGH
-#define ALLOC_NO_WATERMARKS	0x04 /* don't check watermarks at all */
-
-/* Mask to get the watermark bits */
-#define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
-
-#define ALLOC_HARDER		0x10 /* try to alloc harder */
-#define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
-#define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
 static struct fail_page_alloc_attr {
@@ -1691,8 +1678,7 @@ void wake_all_kswapd(unsigned int order,
 		wakeup_kswapd(zone, order);
 }
 
-static inline int
-gfp_to_alloc_flags(gfp_t gfp_mask)
+int gfp_to_alloc_flags(gfp_t gfp_mask)
 {
 	struct task_struct *p = current;
 	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
