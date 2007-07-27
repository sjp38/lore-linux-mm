From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:46 -0400
Message-Id: <20070727194446.18614.86160.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 14/14] Memoryless nodes:  drop one memoryless node boot warning
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 14/14] Memoryless nodes:  drop one memoryless node boot warning

get_pfn_range_for_nid() is called multiple times for each node
at boot time.  Each time, it will warn about nodes with no
memory, resulting in boot messages like:

	Node 0 active with no memory
	Node 0 active with no memory
	Node 0 active with no memory
	Node 0 active with no memory
	Node 0 active with no memory
	Node 0 active with no memory
	On node 0 totalpages: 0
	Node 0 active with no memory
	Node 0 active with no memory
	  DMA zone: 0 pages used for memmap
	Node 0 active with no memory
	Node 0 active with no memory
	  Normal zone: 0 pages used for memmap
	Node 0 active with no memory
	Node 0 active with no memory
	  Movable zone: 0 pages used for memmap

and so on for each memoryless node.

We already have the "On node N totalpages: ..." and other 
related messages, so drop the "Node N active with no memory"
warnings.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/page_alloc.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-07-26 12:34:15.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-07-26 12:35:26.000000000 -0400
@@ -3097,10 +3097,8 @@ void __meminit get_pfn_range_for_nid(uns
 		*end_pfn = max(*end_pfn, early_node_map[i].end_pfn);
 	}
 
-	if (*start_pfn == -1UL) {
-		printk(KERN_WARNING "Node %u active with no memory\n", nid);
+	if (*start_pfn == -1UL)
 		*start_pfn = 0;
-	}
 
 	/* Push the node boundaries out if requested */
 	account_node_boundary(nid, start_pfn, end_pfn);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
