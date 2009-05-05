Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 504E86B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 05:15:51 -0400 (EDT)
Message-Id: <20090505091434.312182900@suse.de>
Date: Tue, 05 May 2009 19:13:44 +1000
From: npiggin@suse.de
Subject: [patch 1/3] mm: SLUB fix reclaim_state
References: <20090505091343.706910164@suse.de>
Content-Disposition: inline; filename=mm-slub-fix-reclaim_state.patch
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi
Cc: stable@kernel.org, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

SLUB does not correctly account reclaim_state.reclaimed_slab, so it will
break memory reclaim. Account it like SLAB does.

Cc: stable@kernel.org
Cc: linux-mm@kvack.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/slub.c |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c
+++ linux-2.6/mm/slub.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/swap.h> /* struct reclaim_state */
 #include <linux/module.h>
 #include <linux/bit_spinlock.h>
 #include <linux/interrupt.h>
@@ -1170,6 +1171,8 @@ static void __free_slab(struct kmem_cach
 
 	__ClearPageSlab(page);
 	reset_page_mapcount(page);
+	if (current->reclaim_state)
+		current->reclaim_state->reclaimed_slab += pages;
 	__free_pages(page, order);
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
