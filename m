Date: Fri, 17 Feb 2006 08:52:30 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
 list initialization
In-Reply-To: <200602170223.34031.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0602170841190.916@g5.osdl.org>
References: <200602170223.34031.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 17 Feb 2006, Andi Kleen wrote:
> 
> The new function to set up the node fallback lists didn't handle
> holes in the node map. This happens e.g. on Opterons when 
> the a CPU is missing memory, which is not that uncommon. 

That whole function is crap. Your changes don't seem to make it any less 
crap, and depends on some insane and unreliable node ordering 
characteristic, as far as I can tell. The thing is horrid.

There is no way you can know that your

	n = (node + i) % random_value;

hits all nodes, much less a valid node. 

Think about it: because we do "for_each_online_node(i)", the "i" is _not_ 
guaranteed to be contiguous, which means that "node + i" is not guaranteed 
to be contiguous, which in turn means that you may be hopping over all the 
valid nodes, and every time (because you do that stupid and undefined 
"node + i" crap) you may hit something invalid or empty.

THE WHOLE ALGORITHM IS BROKEN.

Your patch doesn't make it any less broken, it just makes it _differently_ 
broken, and so you think it fixed something. It fixed absolutely NOTHING.

Here is a totally untested diff that may not even compile, but at least it 
makes SENSE from a conceptual standpoint. The magis is

 - don't do the "node + i" crap, because it is by definition broken.

   It has no semantic meaning, and I _guarantee_ that you can't get it to 
   work in general.

 - prefer nodes that follow the current node, by artificially inflating 
   the distance to previous nodes. This should automatically get you 
   exactly the round-robin behaviour you wanted.

NOTE! I've not tested (and thus not debugged) it. I don't even have NUMA 
enabled, so I've not even compiled it. Somebody else please test it, and 
send it back to me with a sign-off and a proper explanation, and I'll sign 
off on it again and apply it.

		Linus

----
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 62c1225..208812b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1541,29 +1541,29 @@ static int __initdata node_load[MAX_NUMN
  */
 static int __init find_next_best_node(int node, nodemask_t *used_node_mask)
 {
-	int i, n, val;
+	int n, val;
 	int min_val = INT_MAX;
 	int best_node = -1;
 
-	for_each_online_node(i) {
-		cpumask_t tmp;
+	/* Use the local node if we haven't already */
+	if (!node_isset(node, *used_node_mask)) {
+		node_set(node, *used_node_mask);
+		return node;
+	}
 
-		/* Start from local node */
-		n = (node+i) % num_online_nodes();
+	for_each_online_node(n) {
+		cpumask_t tmp;
 
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
 
-		/* Use the local node if we haven't already */
-		if (!node_isset(node, *used_node_mask)) {
-			best_node = node;
-			break;
-		}
-
 		/* Use the distance array to find the distance */
 		val = node_distance(node, n);
 
+		/* Penalize nodes under us ("prefer the next node") */
+		val += (n < node);
+
 		/* Give preference to headless and unused nodes */
 		tmp = node_to_cpumask(n);
 		if (!cpus_empty(tmp))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
