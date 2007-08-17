Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by netops-testserver-4.corp.sgi.com (Postfix) with ESMTP id 2F6DF61B3A
	for <linux-mm@kvack.org>; Fri, 17 Aug 2007 14:51:38 -0700 (PDT)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1IM9jG-0002of-00
	for <linux-mm@kvack.org>; Fri, 17 Aug 2007 14:51:38 -0700
Date: Fri, 17 Aug 2007 14:51:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Do not fail on broken memory configurations
Message-ID: <Pine.LNX.4.64.0708171451250.10822@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---------- Forwarded message ----------
Date: Fri, 17 Aug 2007 14:51:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
To: akpm@linux-foundation.org
Cc: linux-mm@vger.kernel.org
Subject: SLUB: Do not fail on broken memory configurations

Print a big fat warning and do what is necessary to continue if a node
is marked as up (meaning either node is online (upstream) or node has 
memory (Andrew's tree)) but allocations from the node do not succeed.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 6db1725..930e6dc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1877,9 +1877,16 @@ static struct kmem_cache_node * __init early_kmem_cache_node_alloc(gfp_t gfpflag
 
 	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
-	page = new_slab(kmalloc_caches, gfpflags | GFP_THISNODE, node);
+	page = new_slab(kmalloc_caches, gfpflags, node);
 
 	BUG_ON(!page);
+	if (page_to_nid(page) != node) {
+		printk(KERN_ERR "SLUB: Unable to allocate memory from "
+				"node %d\n", node);
+		printk(KERN_ERR "SLUB: Allocating a useless per node structure "
+				"in order to be able to continue\n");
+	}
+
 	n = page->freelist;
 	BUG_ON(!n);
 	page->freelist = get_freepointer(kmalloc_caches, n);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
