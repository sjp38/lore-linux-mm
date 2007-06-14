Message-Id: <20070614075335.700401475@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:33 -0700
From: clameter@sgi.com
Subject: [RFC 07/13] Uncached allocator: Handle memoryless nodes
Content-Disposition: inline; filename=nodeless_mspec
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The checks for node_online in the uncached allocator are made to make sure
that memory is available on these nodes. Thus switch all the checks to use
the node_memory and for_each_memory_node functions.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/arch/ia64/kernel/uncached.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/arch/ia64/kernel/uncached.c	2007-06-13 23:29:58.000000000 -0700
+++ linux-2.6.22-rc4-mm2/arch/ia64/kernel/uncached.c	2007-06-13 23:32:35.000000000 -0700
@@ -196,7 +196,7 @@ unsigned long uncached_alloc_page(int st
 	nid = starting_nid;
 
 	do {
-		if (!node_online(nid))
+		if (!node_memory(nid))
 			continue;
 		uc_pool = &uncached_pools[nid];
 		if (uc_pool->pool == NULL)
@@ -268,7 +268,7 @@ static int __init uncached_init(void)
 {
 	int nid;
 
-	for_each_online_node(nid) {
+	for_each_memory_node(nid) {
 		uncached_pools[nid].pool = gen_pool_create(PAGE_SHIFT, nid);
 		mutex_init(&uncached_pools[nid].add_chunk_mutex);
 	}
Index: linux-2.6.22-rc4-mm2/drivers/char/mspec.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/drivers/char/mspec.c	2007-06-13 23:28:15.000000000 -0700
+++ linux-2.6.22-rc4-mm2/drivers/char/mspec.c	2007-06-13 23:29:35.000000000 -0700
@@ -353,7 +353,7 @@ mspec_init(void)
 		is_sn2 = 1;
 		if (is_shub2()) {
 			ret = -ENOMEM;
-			for_each_online_node(nid) {
+			for_each_memory_node(nid) {
 				int actual_nid;
 				int nasid;
 				unsigned long phys;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
