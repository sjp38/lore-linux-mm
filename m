From: Andi Kleen <ak@suse.de>
Subject: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
Date: Fri, 17 Feb 2006 02:23:33 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602170223.34031.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: akpm@osdl.org, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The new function to set up the node fallback lists didn't handle
holes in the node map. This happens e.g. on Opterons when 
the a CPU is missing memory, which is not that uncommon. 

Empty nodes are not initialization, but the node number is still 
allocated. And then it would early except or even triple fault here  
because it would try to set  up a fallback list for a NULL pgdat. Oops.

There was actually another bug that caused problems in this
configuration - fixed in the earlier x86-64 patchkit. But 
this is the second fix to make it actually boot.

This change makes sure the fallback list initialization really 
looks at all nodes (when there is a hole num_online_nodes() isn't 
the highest index) and also skips missing nodes.

Cc: clameter@engr.sgi.com

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -1540,12 +1540,19 @@ static int __init find_next_best_node(in
 	int i, n, val;
 	int min_val = INT_MAX;
 	int best_node = -1;
+	int highest_node = 0;
+
+	for_each_online_node(i) 
+		highest_node = i; 
 
 	for_each_online_node(i) {
 		cpumask_t tmp;
 
 		/* Start from local node */
-		n = (node+i) % num_online_nodes();
+		n = (node+i) % (highest_node + 1);
+		/* Handle holes in the nodemask */
+		if (!NODE_DATA(n))
+			continue;
 
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
