Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 94CB66B00EA
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 15:34:14 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/3] slqb: Treat pages freed on a memoryless node as local node
Date: Fri, 18 Sep 2009 20:34:10 +0100
Message-Id: <1253302451-27740-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

When a page is being freed belonging to a remote node, it is added to a
separate list. When the node is memoryless, pages are always allocated
on the front for the per-cpu local and always freed remote. This is
similar to a leak and the machine quickly goes OOM and drives over the
cliff faster than Thelma and Louise.

This patch treats pages being freed from remote nodes as if they are local
if the CPU is on a memoryless node. It's now known at time of writing if this
is the best approach so reviewed-bys from those familiar with SLQB are needed.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/slqb.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/slqb.c b/mm/slqb.c
index 4d72be2..0f46b56 100644
--- a/mm/slqb.c
+++ b/mm/slqb.c
@@ -1726,6 +1726,7 @@ static __always_inline void __slab_free(struct kmem_cache *s,
 	struct kmem_cache_cpu *c;
 	struct kmem_cache_list *l;
 	int thiscpu = smp_processor_id();
+	int thisnode = numa_node_id();
 
 	c = get_cpu_slab(s, thiscpu);
 	l = &c->list;
@@ -1733,12 +1734,14 @@ static __always_inline void __slab_free(struct kmem_cache *s,
 	slqb_stat_inc(l, FREE);
 
 	if (!NUMA_BUILD || !slab_numa(s) ||
-			likely(slqb_page_to_nid(page) == numa_node_id())) {
+			likely(slqb_page_to_nid(page) == numa_node_id() ||
+			!node_state(thisnode, N_HIGH_MEMORY))) {
 		/*
 		 * Freeing fastpath. Collects all local-node objects, not
 		 * just those allocated from our per-CPU list. This allows
 		 * fast transfer of objects from one CPU to another within
-		 * a given node.
+		 * a given node. If the current node is memoryless, the
+		 * pages are treated as local
 		 */
 		set_freepointer(s, object, l->freelist.head);
 		l->freelist.head = object;
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
