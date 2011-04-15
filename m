Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 091C390008D
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 16:13:00 -0400 (EDT)
Message-Id: <20110415201258.442821107@linux.com>
Date: Fri, 15 Apr 2011 15:12:52 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubllv333num@/21] slub: Per object NUMA support
References: <20110415201246.096634892@linux.com>
Content-Disposition: inline; filename=rr_slabs
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Currently slub applies NUMA policies per allocated slab page. Change
that to apply memory policies for each individual object allocated.

F.e. before this patch MPOL_INTERLEAVE would return objects from the
same slab page until a new slab page was allocated. Now an object
from a different page is taken for each allocation.

This increases the overhead of the fastpath under NUMA.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-04-15 12:54:42.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-04-15 13:11:25.000000000 -0500
@@ -1887,6 +1887,21 @@ debug:
 	goto unlock_out;
 }
 
+static __always_inline int alternate_slab_node(struct kmem_cache *s,
+						gfp_t flags, int node)
+{
+#ifdef CONFIG_NUMA
+	if (unlikely(node == NUMA_NO_NODE &&
+			!(flags & __GFP_THISNODE) &&
+			!in_interrupt())) {
+		if ((s->flags & SLAB_MEM_SPREAD) && cpuset_do_slab_mem_spread())
+			node = cpuset_slab_spread_node();
+		else if (current->mempolicy)
+		node = slab_node(current->mempolicy);
+	}
+#endif
+	return node;
+}
 /*
  * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
  * have the fastpath folded into their functions. So no function call
@@ -1911,6 +1926,7 @@ static __always_inline void *slab_alloc(
 	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
 
+	node = alternate_slab_node(s, gfpflags, node);
 #ifndef CONFIG_CMPXCHG_LOCAL
 	local_irq_save(flags);
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
