Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 11DD76B0055
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:52:55 -0400 (EDT)
Date: Thu, 19 Mar 2009 22:52:52 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for num_online_nodes()
Message-ID: <20090319225252.GF24586@csn.ul.ie>
References: <alpine.DEB.1.10.0903161247170.17730@qirst.com> <20090318150833.GC4629@csn.ul.ie> <alpine.DEB.1.10.0903181256440.15570@qirst.com> <20090318180152.GB24462@csn.ul.ie> <alpine.DEB.1.10.0903181508030.10154@qirst.com> <alpine.DEB.1.10.0903191642160.22425@qirst.com> <20090319212912.GB24586@csn.ul.ie> <alpine.DEB.1.10.0903191817250.31984@qirst.com> <20090319223353.GE24586@csn.ul.ie> <alpine.DEB.1.10.0903191841040.15549@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903191841040.15549@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 19, 2009 at 06:42:39PM -0400, Christoph Lameter wrote:
> On Thu, 19 Mar 2009, Mel Gorman wrote:
> 
> > I posted an amalgamation. Sorry for the cross-over mails but I wanted to
> > get tests going before I fell asleep. They take a few hours to complete.
> >
> > > >  static inline void node_set_state(int node, enum node_states state)
> > > >  {
> > > >  	__node_set(node, &node_states[state]);
> > > > +	if (state == N_ONLINE)
> > > > +		nr_online_nodes = num_node_state(N_ONLINE);
> > > >  }
> > >
> > > That assumes uses of node_set_state N_ONLINE. Are there such users or are
> > > all using node_set_online()?
> > >
> >
> > node_set_online() calls node_set_state(node, N_ONLINE) so it should have
> > worked out.
> 
> But this adds a surprising side effect to all uses of node_set_state.
> Node_set_state is generating more code now.
> 

Fair point.

> > > if you want to check if the system could ever bring up a second node
> > > (which would make the current optimization not viable) whereas
> > > nr_online_nodes is the check for how many nodes are currently online.
> > >
> >
> > I redid your patch to drop the nr_possible_nodes() because I couldn't convince
> > myself it was correct in all cases and it isn't as important as avoiding
> > num_online_nodes() in fast paths.
> 
> I was more thinking about getting the infrastructure right so that we can
> avoid future hacks like the one in slab.
> 

Which is fair enough and you're right in that it's worth fixing.  One horribly
large patchset and associcate thread at a time though so I'll be putting
it on the wrong finger rather than adding this to the pile right now :).

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
