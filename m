Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2543D6B0099
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 08:54:12 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
Date: Tue, 22 Sep 2009 13:54:13 +0100
Message-Id: <1253624054-10882-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
Cc: heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

When freeing a page, SLQB checks if the page belongs to the local node.
If it is not, it is considered a remote free. On the allocation side, it
always checks the local lists and if they are empty, the page allocator
is called. On memoryless configurations, this is effectively a memory
leak and the machine quickly kills itself in an OOM storm.

This patch records what node ID is considered local to a CPU. As the
management structure for the CPU is always allocated from the closest
node, the node the CPU structure resides on is considered "local".

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/slqb_def.h |    3 +++
 mm/slqb.c                |   23 +++++++++++++++++------
 2 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/slqb_def.h b/include/linux/slqb_def.h
index 1243dda..2ccbe7e 100644
--- a/include/linux/slqb_def.h
+++ b/include/linux/slqb_def.h
@@ -101,6 +101,9 @@ struct kmem_cache_cpu {
 	struct kmem_cache_list	list;		/* List for node-local slabs */
 	unsigned int		colour_next;	/* Next colour offset to use */
 
+	/* local_nid will be numa_node_id() except when memoryless */
+	unsigned int		local_nid;
+
 #ifdef CONFIG_SMP
 	/*
 	 * rlist is a list of objects that don't fit on list.freelist (ie.
diff --git a/mm/slqb.c b/mm/slqb.c
index 4d72be2..89fd8e4 100644
--- a/mm/slqb.c
+++ b/mm/slqb.c
@@ -1375,7 +1375,7 @@ static noinline void *__slab_alloc_page(struct kmem_cache *s,
 	if (unlikely(!page))
 		return page;
 
-	if (!NUMA_BUILD || likely(slqb_page_to_nid(page) == numa_node_id())) {
+	if (!NUMA_BUILD || likely(slqb_page_to_nid(page) == c->local_nid)) {
 		struct kmem_cache_cpu *c;
 		int cpu = smp_processor_id();
 
@@ -1501,15 +1501,16 @@ static __always_inline void *__slab_alloc(struct kmem_cache *s,
 	struct kmem_cache_cpu *c;
 	struct kmem_cache_list *l;
 
+	c = get_cpu_slab(s, smp_processor_id());
+	VM_BUG_ON(!c);
+
 #ifdef CONFIG_NUMA
-	if (unlikely(node != -1) && unlikely(node != numa_node_id())) {
+	if (unlikely(node != -1) && unlikely(node != c->local_nid)) {
 try_remote:
 		return __remote_slab_alloc(s, gfpflags, node);
 	}
 #endif
 
-	c = get_cpu_slab(s, smp_processor_id());
-	VM_BUG_ON(!c);
 	l = &c->list;
 	object = __cache_list_get_object(s, l);
 	if (unlikely(!object)) {
@@ -1518,7 +1519,7 @@ try_remote:
 			object = __slab_alloc_page(s, gfpflags, node);
 #ifdef CONFIG_NUMA
 			if (unlikely(!object)) {
-				node = numa_node_id();
+				node = c->local_nid;
 				goto try_remote;
 			}
 #endif
@@ -1733,7 +1734,7 @@ static __always_inline void __slab_free(struct kmem_cache *s,
 	slqb_stat_inc(l, FREE);
 
 	if (!NUMA_BUILD || !slab_numa(s) ||
-			likely(slqb_page_to_nid(page) == numa_node_id())) {
+			likely(slqb_page_to_nid(page) == c->local_nid)) {
 		/*
 		 * Freeing fastpath. Collects all local-node objects, not
 		 * just those allocated from our per-CPU list. This allows
@@ -1928,6 +1929,16 @@ static void init_kmem_cache_cpu(struct kmem_cache *s,
 	c->rlist.tail		= NULL;
 	c->remote_cache_list	= NULL;
 #endif
+
+	/*
+	 * Determine what the local node to this CPU is. Ordinarily
+	 * this would be cpu_to_node() but for memoryless nodes, that
+	 * is not the best value. Instead, we take the numa node that
+	 * kmem_cache_cpu is allocated from as being the best guess
+	 * as being local because it'll match what the page allocator
+	 * thinks is the most local
+	 */
+	c->local_nid = page_to_nid(virt_to_page((unsigned long)c & PAGE_MASK));
 }
 
 #ifdef CONFIG_NUMA
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
