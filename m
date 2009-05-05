Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 26F706B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 05:15:57 -0400 (EDT)
Message-Id: <20090505091434.456070042@suse.de>
Date: Tue, 05 May 2009 19:13:45 +1000
From: npiggin@suse.de
Subject: [patch 2/3] mm: SLOB fix reclaim_state
References: <20090505091343.706910164@suse.de>
Content-Disposition: inline; filename=mm-slob-fix-reclaim_state.patch
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi
Cc: stable@kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

SLOB does not correctly account reclaim_state.reclaimed_slab, so it will
break memory reclaim. Account it like SLAB does.

Cc: stable@kernel.org
Cc: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/slob.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c
+++ linux-2.6/mm/slob.c
@@ -60,6 +60,7 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
+#include <linux/swap.h> /* struct reclaim_state */
 #include <linux/cache.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -255,6 +256,8 @@ static void *slob_new_pages(gfp_t gfp, i
 
 static void slob_free_pages(void *b, int order)
 {
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += 1 << order;
 	free_pages((unsigned long)b, order);
 }
 
@@ -407,7 +410,7 @@ static void slob_free(void *block, int s
 		spin_unlock_irqrestore(&slob_lock, flags);
 		clear_slob_page(sp);
 		free_slob_page(sp);
-		free_page((unsigned long)b);
+		slob_free_pages(b, 0);
 		return;
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
