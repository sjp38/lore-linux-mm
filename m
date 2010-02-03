Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7AE26B0071
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 16:39:15 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <201002031039.710275915@firstfloor.org>
In-Reply-To: <201002031039.710275915@firstfloor.org>
Subject: [PATCH] [3/4] SLAB: Separate node initialization into separate function
Message-Id: <20100203213914.D8654B1620@basil.firstfloor.org>
Date: Wed,  3 Feb 2010 22:39:14 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


No functional changes.

Needed for next patch.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/slab.c |   34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

Index: linux-2.6.33-rc3-ak/mm/slab.c
===================================================================
--- linux-2.6.33-rc3-ak.orig/mm/slab.c
+++ linux-2.6.33-rc3-ak/mm/slab.c
@@ -1171,19 +1171,9 @@ free_array_cache:
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
@@ -1192,9 +1182,10 @@ static int __cpuinit cpuup_prepare(long
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
@@ -1213,6 +1204,23 @@ static int __cpuinit cpuup_prepare(long
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
