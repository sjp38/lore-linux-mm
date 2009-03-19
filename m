Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AB2E66B004D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:33:57 -0400 (EDT)
Date: Thu, 19 Mar 2009 22:33:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for num_online_nodes()
Message-ID: <20090319223353.GE24586@csn.ul.ie>
References: <alpine.DEB.1.10.0903161207500.32577@qirst.com> <20090316163626.GJ24293@csn.ul.ie> <alpine.DEB.1.10.0903161247170.17730@qirst.com> <20090318150833.GC4629@csn.ul.ie> <alpine.DEB.1.10.0903181256440.15570@qirst.com> <20090318180152.GB24462@csn.ul.ie> <alpine.DEB.1.10.0903181508030.10154@qirst.com> <alpine.DEB.1.10.0903191642160.22425@qirst.com> <20090319212912.GB24586@csn.ul.ie> <alpine.DEB.1.10.0903191817250.31984@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903191817250.31984@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 19, 2009 at 06:22:38PM -0400, Christoph Lameter wrote:
> On Thu, 19 Mar 2009, Mel Gorman wrote:
> 
> > This patch actually alters the API. node_set_online() called when
> > MAX_NUMNODES == 1 will now fail to compile. That situation wouldn't make
> > any sense anyway but is it intentional?
> 
> Yes MAX_NUMNODES means that this is not a NUMA configuration. Setting an
> ode online would make no sense. Node 0 is always online.
> 

Right.

> > For reference here is the patch I had for a similar goal which kept the
> > API as it was. I'll drop it if you prefer your own version.
> 
> Lets look through it and get the best pieces from both.
> 

I posted an amalgamation. Sorry for the cross-over mails but I wanted to
get tests going before I fell asleep. They take a few hours to complete.

> >  static inline void node_set_state(int node, enum node_states state)
> >  {
> >  	__node_set(node, &node_states[state]);
> > +	if (state == N_ONLINE)
> > +		nr_online_nodes = num_node_state(N_ONLINE);
> >  }
> 
> That assumes uses of node_set_state N_ONLINE. Are there such users or are
> all using node_set_online()?
> 

node_set_online() calls node_set_state(node, N_ONLINE) so it should have
worked out.

> > @@ -449,7 +457,8 @@ static inline int num_node_state(enum node_states state)
> >  	node;					\
> >  })
> >
> > -#define num_online_nodes()	num_node_state(N_ONLINE)
> > +
> > +#define num_online_nodes()	(nr_online_nodes)
> >  #define num_possible_nodes()	num_node_state(N_POSSIBLE)
> >  #define node_online(node)	node_state((node), N_ONLINE)
> >  #define node_possible(node)	node_state((node), N_POSSIBLE)
> 
> Hmmmm... Yes we could get rid of those.
> 
> I'd also like to see nr_possible_nodes(). nr_possible_nodes is important
> if you want to check if the system could ever bring up a second node
> (which would make the current optimization not viable) whereas
> nr_online_nodes is the check for how many nodes are currently online.
> 

I redid your patch to drop the nr_possible_nodes() because I couldn't convince
myself it was correct in all cases and it isn't as important as avoiding
num_online_nodes() in fast paths.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
