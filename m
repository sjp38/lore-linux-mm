Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B09790010D
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:26:33 -0400 (EDT)
Message-Id: <20110516202631.025446049@linux.com>
Date: Mon, 16 May 2011 15:26:22 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv5 17/25] slub: Add statistics for the case that the current slab does not match the node
References: <20110516202605.274023469@linux.com>
Content-Disposition: inline; filename=node_mismatch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

Slub reloads the per cpu slab if the page does not satisfy the NUMA condition. Track
those reloads since doing so has a performance impact.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |    3 +++
 2 files changed, 4 insertions(+)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2011-05-16 12:51:07.661458566 -0500
+++ linux-2.6/include/linux/slub_def.h	2011-05-16 12:51:49.901458516 -0500
@@ -24,6 +24,7 @@ enum stat_item {
 	ALLOC_FROM_PARTIAL,	/* Cpu slab acquired from partial list */
 	ALLOC_SLAB,		/* Cpu slab acquired from page allocator */
 	ALLOC_REFILL,		/* Refill cpu slab from slab freelist */
+	ALLOC_NODE_MISMATCH,	/* Switching cpu slab */
 	FREE_SLAB,		/* Slab freed to the page allocator */
 	CPUSLAB_FLUSH,		/* Abandoning of the cpu slab */
 	DEACTIVATE_FULL,	/* Cpu slab was full when deactivated */
Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-16 12:51:07.651458566 -0500
+++ linux-2.6/mm/slub.c	2011-05-16 12:51:49.901458516 -0500
@@ -1952,6 +1952,7 @@ static void *__slab_alloc(struct kmem_ca
 		goto new_slab;
 
 	if (unlikely(!node_match(c, node))) {
+		stat(s, ALLOC_NODE_MISMATCH);
 		deactivate_slab(s, c);
 		goto new_slab;
 	}
@@ -4650,6 +4651,7 @@ STAT_ATTR(FREE_REMOVE_PARTIAL, free_remo
 STAT_ATTR(ALLOC_FROM_PARTIAL, alloc_from_partial);
 STAT_ATTR(ALLOC_SLAB, alloc_slab);
 STAT_ATTR(ALLOC_REFILL, alloc_refill);
+STAT_ATTR(ALLOC_NODE_MISMATCH, alloc_node_mismatch);
 STAT_ATTR(FREE_SLAB, free_slab);
 STAT_ATTR(CPUSLAB_FLUSH, cpuslab_flush);
 STAT_ATTR(DEACTIVATE_FULL, deactivate_full);
@@ -4709,6 +4711,7 @@ static struct attribute *slab_attrs[] =
 	&alloc_from_partial_attr.attr,
 	&alloc_slab_attr.attr,
 	&alloc_refill_attr.attr,
+	&alloc_node_mismatch_attr.attr,
 	&free_slab_attr.attr,
 	&cpuslab_flush_attr.attr,
 	&deactivate_full_attr.attr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
