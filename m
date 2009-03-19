Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EE7156B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 17:29:16 -0400 (EDT)
Date: Thu, 19 Mar 2009 21:29:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for num_online_nodes()
Message-ID: <20090319212912.GB24586@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161207500.32577@qirst.com> <20090316163626.GJ24293@csn.ul.ie> <alpine.DEB.1.10.0903161247170.17730@qirst.com> <20090318150833.GC4629@csn.ul.ie> <alpine.DEB.1.10.0903181256440.15570@qirst.com> <20090318180152.GB24462@csn.ul.ie> <alpine.DEB.1.10.0903181508030.10154@qirst.com> <alpine.DEB.1.10.0903191642160.22425@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903191642160.22425@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 19, 2009 at 04:43:55PM -0400, Christoph Lameter wrote:
> Trying to the same in the style of nr_node_ids etc.
> 
> 
> Subject: Provide nr_online_nodes and nr_possible_nodes
> 
> It seems that its beneficial to have a less expensive way to check for the
> number of currently active and possible nodes in a NUMA system. This will
> simplify further kernel optimizations for the cases in which only a single
> node is online or possible.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 

heh, funningily enough we ended up doing something similar because I
couldn't leave the cost of num_online_nodes() so high.

This patch actually alters the API. node_set_online() called when
MAX_NUMNODES == 1 will now fail to compile. That situation wouldn't make
any sense anyway but is it intentional?

For reference here is the patch I had for a similar goal which kept the
API as it was. I'll drop it if you prefer your own version.

================

commit d767ff28677178659e3260b04b6535e608af68b7
Author: Mel Gorman <mel@csn.ul.ie>
Date:   Wed Mar 18 21:12:31 2009 +0000

    Use a pre-calculated value for num_online_nodes()
    
    num_online_nodes() is called in a number of places but most often by the
    page allocator when deciding whether the zonelist needs to be filtered based
    on cpusets or the zonelist cache.  This is actually a heavy function and
    touches a number of cache lines.  This patch stores the number of online
    nodes at boot time and updates the value when nodes get onlined and offlined.
    
    Signed-off-by: Mel Gorman <mel@csn.ul.ie>

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 848025c..48e8d4a 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -381,6 +381,10 @@ enum node_states {
 extern nodemask_t node_states[NR_NODE_STATES];
 
 #if MAX_NUMNODES > 1
+
+extern int nr_node_ids;
+extern int nr_online_nodes;
+
 static inline int node_state(int node, enum node_states state)
 {
 	return node_isset(node, node_states[state]);
@@ -389,11 +393,15 @@ static inline int node_state(int node, enum node_states state)
 static inline void node_set_state(int node, enum node_states state)
 {
 	__node_set(node, &node_states[state]);
+	if (state == N_ONLINE)
+		nr_online_nodes = num_node_state(N_ONLINE);
 }
 
 static inline void node_clear_state(int node, enum node_states state)
 {
 	__node_clear(node, &node_states[state]);
+	if (state == N_ONLINE)
+		nr_online_nodes = num_node_state(N_ONLINE);
 }
 
 static inline int num_node_state(enum node_states state)
@@ -407,7 +415,6 @@ static inline int num_node_state(enum node_states state)
 #define first_online_node	first_node(node_states[N_ONLINE])
 #define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
 
-extern int nr_node_ids;
 #else
 
 static inline int node_state(int node, enum node_states state)
@@ -434,6 +441,7 @@ static inline int num_node_state(enum node_states state)
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
+#define nr_online_nodes		1
 
 #endif
 
@@ -449,7 +457,8 @@ static inline int num_node_state(enum node_states state)
 	node;					\
 })
 
-#define num_online_nodes()	num_node_state(N_ONLINE)
+
+#define num_online_nodes()	(nr_online_nodes)
 #define num_possible_nodes()	num_node_state(N_POSSIBLE)
 #define node_online(node)	node_state((node), N_ONLINE)
 #define node_possible(node)	node_state((node), N_POSSIBLE)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18f0b56..67ac93a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -164,7 +164,9 @@ static unsigned long __meminitdata dma_reserve;
 
 #if MAX_NUMNODES > 1
 int nr_node_ids __read_mostly = MAX_NUMNODES;
+int nr_online_nodes __read_mostly;
 EXPORT_SYMBOL(nr_node_ids);
+EXPORT_SYMBOL(nr_online_nodes);
 #endif
 
 int page_group_by_mobility_disabled __read_mostly;

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
