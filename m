Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 993D36B0047
	for <linux-mm@kvack.org>; Tue,  5 May 2009 05:15:51 -0400 (EDT)
Message-Id: <20090505091434.611071516@suse.de>
Date: Tue, 05 May 2009 19:13:46 +1000
From: npiggin@suse.de
Subject: [patch 3/3] mm: SLQB fix reclaim_state
References: <20090505091343.706910164@suse.de>
Content-Disposition: inline; filename=mm-slqb-fix-reclaim_state.patch
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi
Cc: stable@kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

SLQB does not correctly account reclaim_state.reclaimed_slab, so it will
break memory reclaim. Account it like SLAB does.

Cc: stable@kernel.org
Cc: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/slqb.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slqb.c
===================================================================
--- linux-2.6.orig/mm/slqb.c
+++ linux-2.6/mm/slqb.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/swap.h> /* struct reclaim_state */
 #include <linux/module.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
@@ -178,7 +179,8 @@ static inline struct slqb_page *virt_to_
 	return (struct slqb_page *)p;
 }
 
-static inline void __free_slqb_pages(struct slqb_page *page, unsigned int order)
+static inline void __free_slqb_pages(struct slqb_page *page, unsigned int order,
+					int pages)
 {
 	struct page *p = &page->page;
 
@@ -187,6 +189,8 @@ static inline void __free_slqb_pages(str
 	VM_BUG_ON(!(p->flags & PG_SLQB_BIT));
 	p->flags &= ~PG_SLQB_BIT;
 
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += pages;
 	__free_pages(p, order);
 }
 
@@ -1043,7 +1047,7 @@ static void __free_slab(struct kmem_cach
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
 
-	__free_slqb_pages(page, s->order);
+	__free_slqb_pages(page, s->order, pages);
 }
 
 static void rcu_free_slab(struct rcu_head *h)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
