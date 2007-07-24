Subject: [PATCH/RFC] Memoryless nodes:  Suppress redundant "node with no
	memory" messages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com>
	 <20070711182250.005856256@sgi.com>
	 <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 24 Jul 2007 16:35:13 -0400
Message-Id: <1185309313.5649.75.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, kxr@sgi.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Suppress redundant "node with no memory" messages

Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless
node series.

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

and so on for each memoryless node.  Track [in init data]
memoryless nodes that we've already reported to suppress
the redundant messages.

OR, we could eliminate the message altogether?  We do
report zero totalpages.  Sufficient?

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/page_alloc.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-07-13 15:52:22.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-07-24 12:37:35.000000000 -0400
@@ -3081,6 +3081,8 @@ static void __meminit account_node_bound
  * with no available memory, a warning is printed and the start and end
  * PFNs will be 0.
  */
+static nodemask_t __meminitdata memoryless_nodes;
+
 void __meminit get_pfn_range_for_nid(unsigned int nid,
 			unsigned long *start_pfn, unsigned long *end_pfn)
 {
@@ -3094,7 +3096,11 @@ void __meminit get_pfn_range_for_nid(uns
 	}
 
 	if (*start_pfn == -1UL) {
-		printk(KERN_WARNING "Node %u active with no memory\n", nid);
+		if (!node_isset(nid, memoryless_nodes)) {
+			printk(KERN_WARNING "Node %u active with no memory\n",
+						 nid);
+			node_set(nid, memoryless_nodes);
+		}
 		*start_pfn = 0;
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
