Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C877B6B0089
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 15:29:10 -0400 (EDT)
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id n3NJTWuZ010688
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 20:29:33 +0100
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by zps76.corp.google.com with ESMTP id n3NJT5dx009704
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 12:29:30 -0700
Received: by rv-out-0708.google.com with SMTP id b17so603043rvf.46
        for <linux-mm@kvack.org>; Thu, 23 Apr 2009 12:29:30 -0700 (PDT)
Date: Thu, 23 Apr 2009 12:29:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 21/22] Use a pre-calculated value instead of num_online_nodes()
 in fast paths
In-Reply-To: <20090423004427.GD26643@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0904231226140.29561@chino.kir.corp.google.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-22-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221602560.27097@chino.kir.corp.google.com> <20090423004427.GD26643@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Apr 2009, Mel Gorman wrote:

> > > diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> > > index 848025c..474e73e 100644
> > > --- a/include/linux/nodemask.h
> > > +++ b/include/linux/nodemask.h
> > > @@ -408,6 +408,19 @@ static inline int num_node_state(enum node_states state)
> > >  #define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
> > >  
> > >  extern int nr_node_ids;
> > > +extern int nr_online_nodes;
> > > +
> > > +static inline void node_set_online(int nid)
> > > +{
> > > +	node_set_state(nid, N_ONLINE);
> > > +	nr_online_nodes = num_node_state(N_ONLINE);
> > > +}
> > > +
> > > +static inline void node_set_offline(int nid)
> > > +{
> > > +	node_clear_state(nid, N_ONLINE);
> > > +	nr_online_nodes = num_node_state(N_ONLINE);
> > > +}
> > >  #else
> > >  
> > >  static inline int node_state(int node, enum node_states state)
> > 
> > The later #define's of node_set_online() and node_set_offline() in 
> > include/linux/nodemask.h should probably be removed now.
> > 
> 
> You'd think, but you can enable memory hotplug without NUMA and
> node_set_online() is called when adding memory. Even though those
> functions are nops on !NUMA, they're necessary.
> 

The problem is that your new functions above are never used because 
node_set_online and node_set_offline are macro defined later in this 
header for all cases, not just !CONFIG_NUMA.

You need this.
---
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
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
