Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F38A56B007B
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 15:54:06 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <20100211953.850854588@firstfloor.org>
In-Reply-To: <20100211953.850854588@firstfloor.org>
Subject: [PATCH] [2/4] SLAB: Separate node initialization into separate function
Message-Id: <20100211205402.02E7EB1978@basil.firstfloor.org>
Date: Thu, 11 Feb 2010 21:54:02 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>


No functional changes.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/slab.c |   34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

Index: linux-2.6.32-memhotadd/mm/slab.c
===================================================================
--- linux-2.6.32-memhotadd.orig/mm/slab.c
+++ linux-2.6.32-memhotadd/mm/slab.c
@@ -1158,19 +1158,9 @@ free_array_cache:
 	}
 }
 
-static int __cpuinit cpuup_prepare(long cpu)
+static int slab_node_prepare(int node)
 {
 	struct kmem_cache *cachep;
-	struct kmem_list3 *l3 = NULL;
-	int node = cpu_to_node(cpu);
-	const int memsize = sizeof(struct kmem_list3);
-
-	/*
-	 * We need to do this right in the beginning since
-	 * alloc_arraycache's are going to use this list.
-	 * kmalloc_node allows us to add the slab to the right
-	 * kmem_list3 and not this cpu's kmem_list3
-	 */
 
 	list_for_each_entry(cachep, &cache_chain, next) {
 		/*
@@ -1179,9 +1169,10 @@ static int __cpuinit cpuup_prepare(long
 		 * node has not already allocated this
 		 */
 		if (!cachep->nodelists[node]) {
-			l3 = kmalloc_node(memsize, GFP_KERNEL, node);
+			struct kmem_list3 *l3;
+			l3 = kmalloc_node(sizeof(struct kmem_list3), GFP_KERNEL, node);
 			if (!l3)
-				goto bad;
+				return -1;
 			kmem_list3_init(l3);
 			l3->next_reap = jiffies + REAPTIMEOUT_LIST3 +
 			    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
@@ -1200,6 +1191,23 @@ static int __cpuinit cpuup_prepare(long
 			cachep->batchcount + cachep->num;
 		spin_unlock_irq(&cachep->nodelists[node]->list_lock);
 	}
+	return 0;
+}
+
+static int __cpuinit cpuup_prepare(long cpu)
+{
+	struct kmem_cache *cachep;
+	struct kmem_list3 *l3 = NULL;
+	int node = cpu_to_node(cpu);
+
+	/*
+	 * We need to do this right in the beginning since
+	 * alloc_arraycache's are going to use this list.
+	 * kmalloc_node allows us to add the slab to the right
+	 * kmem_list3 and not this cpu's kmem_list3
+	 */
+	if (slab_node_prepare(node) < 0)
+		goto bad;
 
 	/*
 	 * Now we can go ahead with allocating the shared arrays and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
