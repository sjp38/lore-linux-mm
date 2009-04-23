Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1012D6B0114
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 20:43:50 -0400 (EDT)
Date: Thu, 23 Apr 2009 01:44:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 21/22] Use a pre-calculated value instead of
	num_online_nodes() in fast paths
Message-ID: <20090423004427.GD26643@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-22-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221602560.27097@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0904221602560.27097@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 04:04:47PM -0700, David Rientjes wrote:
> On Wed, 22 Apr 2009, Mel Gorman wrote:
> 
> > diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> > index 848025c..474e73e 100644
> > --- a/include/linux/nodemask.h
> > +++ b/include/linux/nodemask.h
> > @@ -408,6 +408,19 @@ static inline int num_node_state(enum node_states state)
> >  #define next_online_node(nid)	next_node((nid), node_states[N_ONLINE])
> >  
> >  extern int nr_node_ids;
> > +extern int nr_online_nodes;
> > +
> > +static inline void node_set_online(int nid)
> > +{
> > +	node_set_state(nid, N_ONLINE);
> > +	nr_online_nodes = num_node_state(N_ONLINE);
> > +}
> > +
> > +static inline void node_set_offline(int nid)
> > +{
> > +	node_clear_state(nid, N_ONLINE);
> > +	nr_online_nodes = num_node_state(N_ONLINE);
> > +}
> >  #else
> >  
> >  static inline int node_state(int node, enum node_states state)
> 
> The later #define's of node_set_online() and node_set_offline() in 
> include/linux/nodemask.h should probably be removed now.
> 

You'd think, but you can enable memory hotplug without NUMA and
node_set_online() is called when adding memory. Even though those
functions are nops on !NUMA, they're necessary.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
