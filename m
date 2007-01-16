Message-Id: <20070116101815.843531000@taijtu.programming.kicks-ass.net>
References: <20070116094557.494892000@taijtu.programming.kicks-ass.net>
Date: Tue, 16 Jan 2007 10:46:04 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 7/9] mm: allow mempool to fall back to memalloc reserves
Content-Disposition: inline; filename=mempool_fixup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Allow the mempool to use the memalloc reserves when all else fails and
the allocation context would otherwise allow it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/mempool.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6-git/mm/mempool.c
===================================================================
--- linux-2.6-git.orig/mm/mempool.c	2007-01-12 08:03:44.000000000 +0100
+++ linux-2.6-git/mm/mempool.c	2007-01-12 10:38:57.000000000 +0100
@@ -14,6 +14,7 @@
 #include <linux/mempool.h>
 #include <linux/blkdev.h>
 #include <linux/writeback.h>
+#include "internal.h"
 
 static void add_element(mempool_t *pool, void *element)
 {
@@ -229,6 +230,15 @@ repeat_alloc:
 	}
 	spin_unlock_irqrestore(&pool->lock, flags);
 
+	/* if we really had right to the emergency reserves try those */
+	if (gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS) {
+		if (gfp_temp & __GFP_NOMEMALLOC) {
+			gfp_temp &= ~(__GFP_NOMEMALLOC|__GFP_NOWARN);
+			goto repeat_alloc;
+		} else
+			gfp_temp |= __GFP_NOMEMALLOC|__GFP_NOWARN;
+	}
+
 	/* We must not sleep in the GFP_ATOMIC case */
 	if (!(gfp_mask & __GFP_WAIT))
 		return NULL;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
