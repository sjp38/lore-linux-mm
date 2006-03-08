Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
        by fgwmail7.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k28Dfvwi010808 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:57 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k28DfuY7006276 for <linux-mm@kvack.org>; Wed, 8 Mar 2006 22:41:56 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s12.gw.fujitsu.co.jp (s12 [127.0.0.1])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 97CE01CC11E
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:56 +0900 (JST)
Received: from ml3.s.css.fujitsu.com (ml3.s.css.fujitsu.com [10.23.4.193])
	by s12.gw.fujitsu.co.jp (Postfix) with ESMTP id 533DA1CC120
	for <linux-mm@kvack.org>; Wed,  8 Mar 2006 22:41:56 +0900 (JST)
Date: Wed, 08 Mar 2006 22:41:55 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 006/017](RFC) Memory hotplug for new nodes v.3. (move out pgdat array from mem_data for ia64)
Message-Id: <20060308212845.002E.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

This is preparing patch for updating of NODE_DATA() to make common code
of ia64 between boottime and hotplug.

Current code remembers pgdat address in mem_data which is used at just boot
time. But its information can be used at hotplug time
by moving to global value.
The following patche use this array.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/arch/ia64/mm/discontig.c
===================================================================
--- pgdat6.orig/arch/ia64/mm/discontig.c	2006-03-06 18:25:31.000000000 +0900
+++ pgdat6/arch/ia64/mm/discontig.c	2006-03-06 18:26:07.000000000 +0900
@@ -33,7 +33,6 @@
  */
 struct early_node_data {
 	struct ia64_node_data *node_data;
-	pg_data_t *pgdat;
 	unsigned long pernode_addr;
 	unsigned long pernode_size;
 	struct bootmem_data bootmem_data;
@@ -46,6 +45,8 @@ struct early_node_data {
 static struct early_node_data mem_data[MAX_NUMNODES] __initdata;
 static nodemask_t memory_less_mask __initdata;
 
+static pg_data_t *pgdat_list[MAX_NUMNODES];
+
 /*
  * To prevent cache aliasing effects, align per-node structures so that they
  * start at addresses that are strided by node number.
@@ -175,13 +176,13 @@ static void __init fill_pernode(int node
 	pernode += PERCPU_PAGE_SIZE * cpus;
 	pernode += node * L1_CACHE_BYTES;
 
-	mem_data[node].pgdat = __va(pernode);
+	pgdat_list[node] = __va(pernode);
 	pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
 	mem_data[node].node_data = __va(pernode);
 	pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 
-	mem_data[node].pgdat->bdata = bdp;
+	pgdat_list[node]->bdata = bdp;
 	pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
 	cpu_data = per_cpu_node_setup(cpu_data, node);
@@ -268,7 +269,7 @@ static int __init find_pernode_space(uns
 static int __init free_node_bootmem(unsigned long start, unsigned long len,
 				    int node)
 {
-	free_bootmem_node(mem_data[node].pgdat, start, len);
+	free_bootmem_node(pgdat_list[node], start, len);
 
 	return 0;
 }
@@ -287,7 +288,7 @@ static void __init reserve_pernode_space
 	int node;
 
 	for_each_online_node(node) {
-		pg_data_t *pdp = mem_data[node].pgdat;
+		pg_data_t *pdp = pgdat_list[node];
 
 		if (node_isset(node, memory_less_mask))
 			continue;
@@ -317,12 +318,8 @@ static void __init reserve_pernode_space
  */
 static void __init initialize_pernode_data(void)
 {
-	pg_data_t *pgdat_list[MAX_NUMNODES];
 	int cpu, node;
 
-	for_each_online_node(node)
-		pgdat_list[node] = mem_data[node].pgdat;
-
 	/* Copy the pg_data_t list to each node and init the node field */
 	for_each_online_node(node) {
 		memcpy(mem_data[node].node_data->pg_data_ptrs, pgdat_list,
@@ -372,7 +369,7 @@ static void __init *memory_less_node_all
 	if (bestnode == -1)
 		bestnode = anynode;
 
-	ptr = __alloc_bootmem_node(mem_data[bestnode].pgdat, pernodesize,
+	ptr = __alloc_bootmem_node(pgdat_list[bestnode], pernodesize,
 		PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 
 	return ptr;
@@ -476,7 +473,7 @@ void __init find_memory(void)
 		pernodesize = mem_data[node].pernode_size;
 		map = pernode + pernodesize;
 
-		init_bootmem_node(mem_data[node].pgdat,
+		init_bootmem_node(pgdat_list[node],
 				  map>>PAGE_SHIFT,
 				  bdp->node_boot_start>>PAGE_SHIFT,
 				  bdp->node_low_pfn);

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
