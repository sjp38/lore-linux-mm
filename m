Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AEEA16B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:31:03 -0400 (EDT)
Date: Fri, 24 Apr 2009 14:31:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Do not override definition of node_set_online() with macro
Message-ID: <20090424133127.GJ14283@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-22-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221602560.27097@chino.kir.corp.google.com> <20090423004427.GD26643@csn.ul.ie> <alpine.DEB.2.00.0904231226140.29561@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0904231226140.29561@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 12:29:27PM -0700, David Rientjes wrote:
> On Thu, 23 Apr 2009, Mel Gorman wrote:
> 
> > > > diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> > > > index 848025c..474e73e 100644
> > > > --- a/include/linux/nodemask.h
> > > > +++ b/include/linux/nodemask.h
> > > > @@ -408,6 +408,19 @@ static inline int num_node_state(enum node_states state)
> > > >  #define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
> > > >  
> > > >  extern int nr_node_ids;
> > > > +extern int nr_online_nodes;
> > > > +
> > > > +static inline void node_set_online(int nid)
> > > > +{
> > > > +	node_set_state(nid, N_ONLINE);
> > > > +	nr_online_nodes = num_node_state(N_ONLINE);
> > > > +}
> > > > +
> > > > +static inline void node_set_offline(int nid)
> > > > +{
> > > > +	node_clear_state(nid, N_ONLINE);
> > > > +	nr_online_nodes = num_node_state(N_ONLINE);
> > > > +}
> > > >  #else
> > > >  
> > > >  static inline int node_state(int node, enum node_states state)
> > > 
> > > The later #define's of node_set_online() and node_set_offline() in 
> > > include/linux/nodemask.h should probably be removed now.
> > > 
> > 
> > You'd think, but you can enable memory hotplug without NUMA and
> > node_set_online() is called when adding memory. Even though those
> > functions are nops on !NUMA, they're necessary.
> > 
> 
> The problem is that your new functions above are never used because 
> node_set_online and node_set_offline are macro defined later in this 
> header for all cases, not just !CONFIG_NUMA.
> 
> You need this.

You're absolutly correct, well spotted. I mistook what the #endif was
closing. Here it the patch again with a changelog. Thanks very much

==== CUT HERE ====
From: David Rientjes <rientjes@google.com>

Do not override definition of node_set_online() with macro

node_set_online() updates node_states[] and updates the value of
nr_online_nodes. However, its definition is being accidentally overridden
by a macro definition intended for use in the !CONFIG_NUMA case. This patch
fixes the problem by moving the !CONFIG_NUMA macro definition.

This should be considered a fix to the patch 
page-allocator-use-a-pre-calculated-value-instead-of-num_online_nodes-in-fast-paths.patch

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 include/linux/nodemask.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 474e73e..829b94b 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -448,6 +448,9 @@ static inline int num_node_state(enum node_states state)
 #define next_online_node(nid)	(MAX_NUMNODES)
 #define nr_node_ids		1
 #define nr_online_nodes		1
+
+#define node_set_online(node)	   node_set_state((node), N_ONLINE)
+#define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
 #endif
 
 #define node_online_map 	node_states[N_ONLINE]
@@ -467,9 +470,6 @@ static inline int num_node_state(enum node_states state)
 #define node_online(node)	node_state((node), N_ONLINE)
 #define node_possible(node)	node_state((node), N_POSSIBLE)
 
-#define node_set_online(node)	   node_set_state((node), N_ONLINE)
-#define node_set_offline(node)	   node_clear_state((node), N_ONLINE)
-
 #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
 #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
