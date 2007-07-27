From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:07 -0400
Message-Id: <20070727194407.18614.30997.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 08/14] Uncached allocator: Handle memoryless nodes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 08/14] Uncached allocator: Handle memoryless nodes

The checks for node_online in the uncached allocator are made to make sure
that memory is available on these nodes. Thus switch all the checks to use
the node_memory and for_each_memory_node functions.


Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Jes Sorensen <jes@sgi.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/kernel/uncached.c |    4 ++--
 drivers/char/mspec.c        |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

Index: Linux/arch/ia64/kernel/uncached.c
===================================================================
--- Linux.orig/arch/ia64/kernel/uncached.c	2007-07-08 19:32:17.000000000 -0400
+++ Linux/arch/ia64/kernel/uncached.c	2007-07-25 11:37:41.000000000 -0400
@@ -196,7 +196,7 @@ unsigned long uncached_alloc_page(int st
 	nid = starting_nid;
 
 	do {
-		if (!node_online(nid))
+		if (!node_state(nid, N_MEMORY))
 			continue;
 		uc_pool = &uncached_pools[nid];
 		if (uc_pool->pool == NULL)
@@ -268,7 +268,7 @@ static int __init uncached_init(void)
 {
 	int nid;
 
-	for_each_online_node(nid) {
+	for_each_node_state(nid, N_ONLINE) {
 		uncached_pools[nid].pool = gen_pool_create(PAGE_SHIFT, nid);
 		mutex_init(&uncached_pools[nid].add_chunk_mutex);
 	}
Index: Linux/drivers/char/mspec.c
===================================================================
--- Linux.orig/drivers/char/mspec.c	2007-07-25 09:29:43.000000000 -0400
+++ Linux/drivers/char/mspec.c	2007-07-25 11:37:41.000000000 -0400
@@ -344,7 +344,7 @@ mspec_init(void)
 		is_sn2 = 1;
 		if (is_shub2()) {
 			ret = -ENOMEM;
-			for_each_online_node(nid) {
+			for_each_node_state(nid, N_ONLINE) {
 				int actual_nid;
 				int nasid;
 				unsigned long phys;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
