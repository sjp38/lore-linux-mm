Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 001046B005D
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 16:49:44 -0400 (EDT)
Subject: Re: [PATCH 4/6] hugetlb:  introduce alloc_nodemask_of_node
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <alpine.DEB.1.00.0909031122590.9055@chino.kir.corp.google.com>
References: <20090828160314.11080.18541.sendpatchset@localhost.localdomain>
	 <20090828160338.11080.51282.sendpatchset@localhost.localdomain>
	 <20090901144932.GB7548@csn.ul.ie>
	 <1251823334.4164.2.camel@useless.americas.hpqcorp.net>
	 <alpine.DEB.1.00.0909031122590.9055@chino.kir.corp.google.com>
Content-Type: text/plain
Date: Thu, 03 Sep 2009 16:49:48 -0400
Message-Id: <1252010988.6029.194.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-09-03 at 11:34 -0700, David Rientjes wrote:
> On Tue, 1 Sep 2009, Lee Schermerhorn wrote:
> 
> > > > Index: linux-2.6.31-rc7-mmotm-090827-0057/include/linux/nodemask.h
> > > > ===================================================================
> > > > --- linux-2.6.31-rc7-mmotm-090827-0057.orig/include/linux/nodemask.h	2009-08-28 09:21:19.000000000 -0400
> > > > +++ linux-2.6.31-rc7-mmotm-090827-0057/include/linux/nodemask.h	2009-08-28 09:21:29.000000000 -0400
> > > > @@ -245,18 +245,34 @@ static inline int __next_node(int n, con
> > > >  	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
> > > >  }
> > > >  
> > > > +#define init_nodemask_of_nodes(mask, node)				\
> > > > +	nodes_clear(*(mask));						\
> > > > +	node_set((node), *(mask));
> > > > +
> > > 
> > > Is the done thing to either make this a static inline or else wrap it in
> > > a do { } while(0) ? The reasoning being that if this is used as part of an
> > > another statement (e.g. a for loop) that it'll actually compile instead of
> > > throw up weird error messages.
> > 
> > Right.  I'll fix this [and signoff/review orders] next time [maybe last
> > time?].  It occurs to me that I can also use this for
> > huge_mpol_nodes_allowed(), so I'll move it up in the series and fix that
> > [which you've already ack'd].  I'll wait a bit to hear from David before
> > I respin.
> > 
> 
> I think it should be an inline function just so there's typechecking on 
> the first argument passed in (and so alloc_nodemask_of_node() below 
> doesn't get a NULL pointer dereference on node_set() if nmp can't be 
> allocated).

OK.  That works.  will be in v6

> 
> I've seen the issue about the signed-off-by/reviewed-by/acked-by order 
> come up before.  I've always put my signed-off-by line last whenever 
> proposing patches because it shows a clear order in who gathered those 
> lines when submitting to -mm, for example.  If I write
> 
> 	Cc: Mel Gorman <mel@csn.ul.ie>
> 	Signed-off-by: David Rientjes <rientjes@google.com>
> 
> it is clear that I cc'd Mel on the initial proposal.  If it is the other 
> way around, for example,
> 
> 	Signed-off-by: David Rientjes <rientjes@google.com>
> 	Cc: Mel Gorman <mel@csn.ul.ie>
> 	Signed-off-by: Andrew Morton...
> 
> then it indicates Andrew added the cc when merging into -mm.  That's more 
> relevant when such a line is acked-by or reviewed-by since it is now 
> possible to determine who received such acknowledgement from the 
> individual and is responsible for correctly relaying it in the patch 
> submission.
> 
> If it's done this way, it indicates that whoever is signing off the patch 
> is responsible for everything above it.  The type of line (signed-off-by, 
> reviewed-by, acked-by) is enough of an indication about the development 
> history of the patch, I believe, and it doesn't require specific ordering 
> to communicate (and the first line having to be a signed-off-by line isn't 
> really important, it doesn't replace the From: line).
> 
> It also appears to be how both Linus merges his own patches with Cc's.

???

> 
> > > > +/*
> > > > + * returns pointer to kmalloc()'d nodemask initialized to contain the
> > > > + * specified node.  Caller must free with kfree().
> > > > + */
> > > > +#define alloc_nodemask_of_node(node)					\
> > > > +({									\
> > > > +	typeof(_unused_nodemask_arg_) *nmp;				\
> > > > +	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
> > > > +	if (nmp)							\
> > > > +		init_nodemask_of_nodes(nmp, (node));			\
> > > > +	nmp;								\
> > > > +})
> > > > +
> > > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
